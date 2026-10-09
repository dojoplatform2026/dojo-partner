
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

exports.checkBackend = onCall((request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Please sign in first."
    );
  }

  return {
    success: true,
    message: "DOJO Partner backend is connected.",
  };
});
