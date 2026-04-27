const initFirebase = require("../config/firebase");

async function sendPushNotification({ token, topic, title, body, data = {} }) {
  const admin = initFirebase();
  if (!admin) return null;
  if (!token && !topic) return null;

  const message = {
    notification: { title, body },
    data
  };

  if (token) message.token = token;
  else if (topic) message.topic = topic;

  return admin.messaging().send(message);
}

module.exports = { sendPushNotification };
