const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: false },
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: false },
    serviceId: { type: mongoose.Schema.Types.ObjectId, ref: "Service", required: true },
    date: { type: String, required: true },
    time: { type: String, required: true },
    status: {
      type: String,
      enum: ["requested", "accepted", "rejected", "completed", "cancelled"],
      default: "requested"
    },
    paymentStatus: {
      type: String,
      enum: ["pending", "paid", "failed", "refunded"],
      default: "pending"
    },
    amount: { type: Number, required: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Booking", bookingSchema);
