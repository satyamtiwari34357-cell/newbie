const mongoose = require("mongoose");
const Service = require("./src/models/Service");
require("dotenv").config();

async function check() {
  await mongoose.connect(process.env.MONGO_URI);
  const services = await Service.find().limit(5);
  console.log("Found services:", JSON.stringify(services, null, 2));
  process.exit(0);
}

check().catch(err => {
  console.error(err);
  process.exit(1);
});
