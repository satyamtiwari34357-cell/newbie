const express = require("express");
const auth = require("../middleware/auth");
const { getVendors, getVendorById, updateVendorProfile } = require("../controllers/vendorController");

const router = express.Router();

router.get("/", getVendors);
router.put("/profile", auth, updateVendorProfile);
router.get("/:id", getVendorById);

module.exports = router;
