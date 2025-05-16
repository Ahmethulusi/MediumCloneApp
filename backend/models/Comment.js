const mongoose = require('mongoose');

class Comment {
  constructor(articleId, userId, text) {
    this.articleId = articleId;
    this.userId = userId;
    this.text = text;
    this.createdAt = new Date();
  }

  static getSchema() {
    return new mongoose.Schema({
      articleId: { type: mongoose.Schema.Types.ObjectId, ref: 'Article', required: true },
      userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
      text: { type: String, required: true },
      createdAt: { type: Date, default: Date.now }
    });
  }

  static getModel() {
    return mongoose.model('Comment', this.getSchema());
  }
  
}

module.exports = Comment.getModel();
