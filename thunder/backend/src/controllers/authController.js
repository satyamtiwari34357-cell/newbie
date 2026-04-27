const { body } = require("express-validator");
const asyncHandler = require("../utils/asyncHandler");
const validate = require("../middleware/validate");
const apiResponse = require("../utils/apiResponse");
const User = require("../models/User");
const VendorProfile = require("../models/VendorProfile");
const { generateOTP, verifyOTP } = require("../services/otpService");
const { signToken } = require("../services/jwtService");

const loginValidators = [body("phone").isLength({ min: 10, max: 15 }), validate];

const verifyOtpValidators = [
  body("phone").isLength({ min: 10, max: 15 }),
  body("otp").isLength({ min: 6, max: 6 }),
  validate
];

const login = asyncHandler(async (req, res) => {
  const { phone } = req.body;
  const otp = generateOTP(phone);

  return apiResponse(
    res,
    200,
    { phone, otpForDev: process.env.NODE_ENV === "development" ? otp : undefined },
    "OTP sent successfully"
  );
});

const verifyOtp = asyncHandler(async (req, res) => {
  const { phone, otp, fcmToken } = req.body;
  const valid = verifyOTP(phone, otp);
  if (!valid) {
    return apiResponse(res, 400, null, "Invalid or expired OTP");
  }

  let user = await User.findOne({ phone });
  if (!user) {
    user = await User.create({ phone, role: "customer", activeMode: "customer", fcmToken });
  } else if (fcmToken) {
    user.fcmToken = fcmToken;
    await user.save();
  }

  const token = signToken({ userId: user._id.toString() });
  return apiResponse(res, 200, { token, user }, "Login successful");
});

const getMe = asyncHandler(async (req, res) => {
  const profile = await VendorProfile.findOne({ userId: req.user._id });
  return apiResponse(res, 200, { user: req.user, profile });
});

module.exports = {
  login,
  verifyOtp,
  getMe,
  loginValidators,
  verifyOtpValidators
};
