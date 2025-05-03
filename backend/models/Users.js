const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

class User {
  constructor(name, email, profileImage, password,role,bio,jobTitle,isBanned,isFrozen) {
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
  }

  static getSchema() {
    const schema = new mongoose.Schema({
      name: { type: String, required: true },
      email: { type: String, required: true, unique: true },
      password: { type: String, required: true },
      profileImage: { type: String, default: "" },
      role: { 
        type: String, 
        enum: [ "author", "editor", "admin"], 
        default: "author"
      },
      createdAt: { type: Date, default: Date.now },
      resetPasswordToken: { type: String, default: null },  // Şifre sıfırlama tokeni
      resetPasswordExpires: { type: Date, default: null },    //  Tokenin süresi
      jobTitle: { type: String, required: false },
      bio: { type: String, required: false },
      isBanned: { type: Boolean, default: false },
      isFrozen: { type: Boolean, default: false },
    });
  
    return schema;
  }

  static getModel() {
    return mongoose.models.User || mongoose.model('User', this.getSchema());
  }
}

module.exports = User.getModel();
