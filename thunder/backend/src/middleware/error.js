function notFound(req, res) {
  res.status(404).json({ success: false, message: `Route not found: ${req.originalUrl}` });
}

function errorHandler(err, req, res, next) {
  console.error("DEBUG ERROR:", err);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || "Internal server error",
    stack: process.env.NODE_ENV === "development" ? err.stack : undefined
  });
}

module.exports = { notFound, errorHandler };
