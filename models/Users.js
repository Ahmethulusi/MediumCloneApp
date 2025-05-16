const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

class User {
  constructor(name, email, profileImage, password,role,bio,jobTitle,isBanned,isFrozen,followers,following,
    savedArticles, preferredCategories,showInterestScreen
  ) {
    this.name = name;
    this.bio = bio;
    this.jobTitle = jobTitle
    this.email = email;
    this.password = password;
    this.profileImage = profileImage || "";
    this.role = role;
    this.createdAt = new Date();
    this.isBanned = isBanned;
    this.isFrozen = isFrozen;
    this.followers = followers || [];
    this.following= following || [];
    this.savedArticles = savedArticles || [];
    this.preferredCategories = preferredCategories || [];
    this.showInterestScreen = showInterestScreen || true;
  }

  static getSchema() {
    const schema = new mongoose.Schema({
      name: { type: String, required: true },
      email: { type: String, required: true, unique: true },
      password: { type: String, required: true },
      profileImage: { type: String, default: "" },
      role: { 
        type: String, 
        enum: ["author", "editor", "admin"], 
        default: "author"
      },
      createdAt: { type: Date, default: Date.now },
      resetPasswordToken: { type: String, default: null },
      resetPasswordExpires: { type: Date, default: null },
      jobTitle: { type: String, required: false },
      bio: { type: String, required: false },
      isBanned: { type: Boolean, default: false },
      isFrozen: { type: Boolean, default: false },
  
      // 🔁 Takip sistemi
      followers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
      following: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  
      // 📚 Kaydedilen makaleler
      savedArticles: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Article' }],
      preferredCategories: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Category' }],
      showInterestScreen: { type: Boolean, default: true }

    });
  
    return schema;
  }
  

  static getModel() {
    return mongoose.models.User || mongoose.model('User', this.getSchema());
  }
}

module.exports = User.getModel();
