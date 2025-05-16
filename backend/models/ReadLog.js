const mongoose = require('mongoose');

const readLogSchema = new mongoose.Schema({
  articleId: { type: mongoose.Schema.Types.ObjectId, ref: 'Article', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // optional
  readAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ReadLog', readLogSchema);
