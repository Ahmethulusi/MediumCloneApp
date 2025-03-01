const mongoose = require('mongoose');

class Category {
  constructor(name, parent = null) {
    this.name = name;
    this.parent = parent;
    this.createdAt = new Date();
  }

  static getSchema() {
    return new mongoose.Schema({
      name: { type: String, required: true, unique: true },
      parent: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', default: null }, // Üst kategori referansı
      createdAt: { type: Date, default: Date.now }
    });
  }

  static getModel() {
    return mongoose.models.Category || mongoose.model('Category', this.getSchema());
  }
}

module.exports = Category.getModel();
