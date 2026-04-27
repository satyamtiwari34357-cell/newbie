const { body, param } = require("express-validator");
const asyncHandler = require("../utils/asyncHandler");
const validate = require("../middleware/validate");
const apiResponse = require("../utils/apiResponse");
const ApiFeatures = require("../utils/apiFeatures");
const Booking = require("../models/Booking");
const User = require("../models/User");
const Service = require("../models/Service");
const VendorProfile = require("../models/VendorProfile");
const { sendPushNotification } = require("../services/notificationService");
const { createOrder } = require("../services/paymentService");

const createBookingValidators = [
  body("vendorId").optional().isMongoId(),
  body("serviceId").isMongoId(),
  body("date").notEmpty(),
  body("time").notEmpty(),
  validate
];

const statusValidators = [
  param("id").isMongoId(),
  body("status").isIn(["accepted", "rejected", "completed", "cancelled"]),
  validate
];

const createBooking = asyncHandler(async (req, res) => {
  console.log("Incoming Booking Request:", req.body);
  const { vendorId, serviceId, date, time } = req.body;
  
  const fetchedData = await Promise.all([
    vendorId ? User.findById(vendorId) : Promise.resolve(null),
    Service.findById(serviceId)
  ]);
  
  const vendor = fetchedData[0];
  let service = fetchedData[1];

  // Fallback for development if serviceId is a dummy or not found
  if (!service) {
    console.log(`Warning: Service with ID ${serviceId} not found. Using fallback.`);
    service = {
      _id: serviceId,
      name: "General Service",
      price: 350
    };
  }

  const booking = await Booking.create({
    userId: req.user?._id || null,
    vendorId: vendorId || null,
    serviceId: service._id,
    date,
    time,
    amount: service.price
  });

  let order = null;
  try {
    order = await createOrder({
      amount: service.price * 100,
      receipt: `booking_${booking._id}`
    });
  } catch (error) {
    console.error("Payment order creation failed:", error.message);
    // Continue without payment order for now - helps in development
  }

  // Notify Vendor(s)
  try {
    if (vendor && vendor.fcmToken) {
      await sendPushNotification({
        token: vendor.fcmToken,
        title: "New booking request",
        body: `You have a new request for ${service.name} from ${req.user?.name || "Customer"}`,
        data: { bookingId: booking._id.toString() }
      });
    } else if (!vendorId) {
      // Broadcast: Notify all vendors within 10km
      const nearbyVendors = await User.find({
        role: { $in: ["vendor", "both"] },
        fcmToken: { $exists: true, $ne: null },
        location: {
          $near: {
            $geometry: req.user?.location || { type: "Point", coordinates: [0, 0] },
            $maxDistance: 10000 // 10km
          }
        }
      });

      const notificationPromises = nearbyVendors.map(v => 
        sendPushNotification({
          token: v.fcmToken,
          title: "New Job Available!",
          body: `A new ${service.name} job is available near you.`,
          data: { bookingId: booking._id.toString(), type: "broadcast" }
        })
      );
      await Promise.all(notificationPromises);
      console.log(`Broadcasted to ${nearbyVendors.length} individual vendors`);

      // ALSO broadcast to the "all_users" topic so everyone (even non-logged in) sees it
      await sendPushNotification({
        topic: "all_users",
        title: "New Service Request!",
        body: `A new ${service.name} job is available. Check it out now!`,
        data: { bookingId: booking._id.toString() }
      });
    }
  } catch (error) {
    console.error("Vendor notification failed:", error.message);
  }

  // Notify Customer
  try {
    if (req.user?.fcmToken) {
      await sendPushNotification({
        token: req.user.fcmToken,
        title: "Booking Requested",
        body: `Your booking for ${service.name} has been placed successfully!`,
        data: { bookingId: booking._id.toString() }
      });
    }
  } catch (error) {
    console.error("Customer notification failed:", error.message);
  }

  return apiResponse(res, 201, { booking, paymentOrder: order }, "Booking requested");
});

const getBookings = asyncHandler(async (req, res) => {
  const isVendorMode = req.user.activeMode === "vendor";
  
  let filter = {};
  if (req.user.activeMode === "vendor") {
    // Vendors see their assigned jobs OR unassigned broadcast jobs
    filter = {
      $or: [{ vendorId: req.user._id }, { vendorId: null }]
    };
  } else {
    // Customers only see their own bookings
    filter = { userId: req.user._id };
  }

  const query = Booking.find(filter)
    .populate("serviceId")
    .populate("vendorId", "name phone");

  const features = new ApiFeatures(query, req.query);
  const { page, limit } = features.paginate();
  const items = await features.query.sort({ createdAt: -1 });

  return apiResponse(res, 200, {
    items,
    pagination: { page, limit, total: items.length }
  });
});

const updateBookingStatus = asyncHandler(async (req, res) => {
  const booking = await Booking.findById(req.params.id)
    .populate("serviceId")
    .populate("vendorId")
    .populate("userId");
    
  if (!booking) return apiResponse(res, 404, null, "Booking not found");

  const nextStatus = req.body.status;
  const isVendor = booking.vendorId._id.toString() === req.user._id.toString();
  const isCustomer = booking.userId._id.toString() === req.user._id.toString();

  // If it was unassigned and a vendor is accepting, assign it to them
  if (isUnassigned && nextStatus === "accepted") {
    booking.vendorId = req.user._id;
  }

  if (nextStatus === "cancelled" && !isCustomer) {
    return apiResponse(res, 403, null, "Only customer can cancel this booking");
  }

  booking.status = nextStatus;
  if (nextStatus === "completed") {
    booking.paymentStatus = "paid";
    if (booking.vendorId) {
      await VendorProfile.updateOne(
        { userId: booking.vendorId._id || booking.vendorId },
        { $inc: { earnings: booking.amount } },
        { upsert: true }
      );
    }
  }

  await booking.save();
  
  // Repopulate for notifications (we need vendor name and tokens)
  await booking.populate(["serviceId", "vendorId", "userId"]);

  // Notifications for status updates
  let customerTitle = "";
  let customerBody = "";
  let vendorTitle = "";
  let vendorBody = "";

  if (nextStatus === "accepted") {
    customerTitle = "Booking Accepted!";
    customerBody = `Your booking for ${booking.serviceId?.name || "the service"} has been accepted by ${booking.vendorId?.name || "a vendor"}.`;
  } else if (nextStatus === "rejected") {
    customerTitle = "Booking Rejected";
    customerBody = `Sorry, your booking for ${booking.serviceId?.name || "the service"} was rejected.`;
  } else if (nextStatus === "completed") {
    customerTitle = "Service Completed";
    customerBody = `Your service for ${booking.serviceId?.name || "the service"} is marked as completed. Thank you!`;
    vendorTitle = "Booking Completed";
    vendorBody = `You have completed the service for ${booking.userId?.name || "the customer"}.`;
  } else if (nextStatus === "cancelled") {
    vendorTitle = "Booking Cancelled";
    vendorBody = `The booking for ${booking.serviceId?.name || "the service"} has been cancelled by the customer.`;
  }

  // Send to Customer
  if (customerTitle && booking.userId && booking.userId.fcmToken) {
    await sendPushNotification({
      token: booking.userId.fcmToken,
      title: customerTitle,
      body: customerBody,
      data: { bookingId: booking._id.toString(), status: nextStatus }
    });
  }

  // Send to Vendor
  if (vendorTitle && booking.vendorId && booking.vendorId.fcmToken) {
    await sendPushNotification({
      token: booking.vendorId.fcmToken,
      title: vendorTitle,
      body: vendorBody,
      data: { bookingId: booking._id.toString(), status: nextStatus }
    });
  }

  // Notifications for status updates
  let customerTitle = "";
  let customerBody = "";
  let vendorTitle = "";
  let vendorBody = "";

  if (nextStatus === "accepted") {
    customerTitle = "Booking Accepted!";
    customerBody = `Your booking for ${booking.serviceId.name} has been accepted by ${booking.vendorId.name}.`;
  } else if (nextStatus === "rejected") {
    customerTitle = "Booking Rejected";
    customerBody = `Sorry, your booking for ${booking.serviceId.name} was rejected.`;
  } else if (nextStatus === "completed") {
    customerTitle = "Service Completed";
    customerBody = `Your service for ${booking.serviceId.name} is marked as completed. Thank you!`;
    vendorTitle = "Booking Completed";
    vendorBody = `You have completed the service for ${booking.userId.name}.`;
  } else if (nextStatus === "cancelled") {
    vendorTitle = "Booking Cancelled";
    vendorBody = `The booking for ${booking.serviceId.name} has been cancelled by the customer.`;
  }

  // Send to Customer
  if (customerTitle) {
    await sendPushNotification({
      token: booking.userId.fcmToken,
      title: customerTitle,
      body: customerBody,
      data: { bookingId: booking._id.toString(), status: nextStatus }
    });
  }

  // Send to Vendor
  if (vendorTitle) {
    await sendPushNotification({
      token: booking.vendorId.fcmToken,
      title: vendorTitle,
      body: vendorBody,
      data: { bookingId: booking._id.toString(), status: nextStatus }
    });
  }

  return apiResponse(res, 200, booking, "Booking status updated");
});

module.exports = {
  createBooking,
  getBookings,
  updateBookingStatus,
  createBookingValidators,
  statusValidators
};
