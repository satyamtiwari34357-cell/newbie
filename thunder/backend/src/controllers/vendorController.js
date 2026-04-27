const asyncHandler = require("../utils/asyncHandler");
const apiResponse = require("../utils/apiResponse");
const ApiFeatures = require("../utils/apiFeatures");
const User = require("../models/User");
const VendorProfile = require("../models/VendorProfile");

const getVendors = asyncHandler(async (req, res) => {
  const { lng, lat, maxDistance = 10000 } = req.query;
  let query = User.find({ role: { $in: ["vendor", "both"] } });

  if (lng && lat) {
    query = User.find({
      role: { $in: ["vendor", "both"] },
      location: {
        $near: {
          $geometry: { type: "Point", coordinates: [Number(lng), Number(lat)] },
          $maxDistance: Number(maxDistance)
        }
      }
    });
  }

  const features = new ApiFeatures(query, req.query);
  const { page, limit } = features.paginate();
  const vendors = await features.query;

  return apiResponse(res, 200, {
    items: vendors,
    pagination: { page, limit, total: vendors.length }
  });
});

const getVendorById = asyncHandler(async (req, res) => {
  const [vendor, profile] = await Promise.all([
    User.findById(req.params.id),
    VendorProfile.findOne({ userId: req.params.id }).populate("services")
  ]);

  if (!vendor) return apiResponse(res, 404, null, "Vendor not found");
  return apiResponse(res, 200, { vendor, profile });
});

const updateVendorProfile = asyncHandler(async (req, res) => {
  const { name, baseCharges, bio } = req.body;

  const [updatedUser, updatedProfile] = await Promise.all([
    User.findByIdAndUpdate(req.user._id, { name }, { new: true }),
    VendorProfile.findOneAndUpdate(
      { userId: req.user._id },
      { baseCharges, bio },
      { new: true, upsert: true }
    )
  ]);

  return apiResponse(res, 200, { user: updatedUser, profile: updatedProfile }, "Profile updated successfully");
});

module.exports = { getVendors, getVendorById, updateVendorProfile };
