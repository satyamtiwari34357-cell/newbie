const express = require("express");
const auth = require("../middleware/auth");
const { login, verifyOtp, getMe, loginValidators, verifyOtpValidators } = require("../controllers/authController");

const router = express.Router();

router.post("/login", loginValidators, login);
router.post("/verify-otp", verifyOtpValidators, verifyOtp);
router.get("/me", auth, getMe);

module.exports = router;
