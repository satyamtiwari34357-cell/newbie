const express = require("express");
const auth = require("../middleware/auth");
const {
  createBooking,
  getBookings,
  updateBookingStatus,
  createBookingValidators,
  statusValidators
} = require("../controllers/bookingController");

const router = express.Router();

router.post("/", createBookingValidators, createBooking);
router.get("/", auth, getBookings);
router.put("/:id/status", auth, statusValidators, updateBookingStatus);

module.exports = router;
