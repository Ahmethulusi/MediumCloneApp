const mongoose = require("mongoose");

const reportSchema = new mongoose.Schema({
  article: { type: mongoose.Schema.Types.ObjectId, ref: "Article", required: true },
  reason: { type: String, required: true }, // telif, spam, uygunsuz içerik, diğer
  description: { type: String}, // Eğer kullanıcı açıklama yazmak isterse
  resolved: { type: Boolean, default: false },
  reportedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Report", reportSchema);
