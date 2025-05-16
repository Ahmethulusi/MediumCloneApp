const mongoose = require('mongoose');

class Article {
  constructor(title, content,status, author, categories,coverImage,likes=[],readCount) {
    this.title = title;
    this.content = content;
    this.status = status;
    this.author = author;
    this.categories = categories || []; // Çoka-çok ilişki için kategori referansları
    this.coverImage = coverImage;
    this.likes = likes;
    this.readCount = readCount || 0;
    this.createdAt = new Date();
  }

  static getSchema() {
    return new mongoose.Schema({
      title: { type: String, required: true },
      content: { type: String, required: true },
      coverImage: { type: String, default: '' }, // ✅ yeni alan
      status: {
        type: String,
        enum: ['public', 'draft'],
        default: 'draft'
      },
      author: {
        _id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        name: String,
        jobTitle: String
      },
      categories: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Category' }],
      likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
      readCount: { type: Number, default: 0 },
      createdAt: { type: Date, default: Date.now }
    });
  }
  

  static getModel() {
    return mongoose.model('Article', this.getSchema());
  }
}

module.exports = Article.getModel();
