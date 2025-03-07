
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

class User {
  constructor(name, email, profileImage,password, role = "visitor") {
    this.name = name;
    this.email = email;
    this.password = password;
    this.profileImage = profileImage || "https://via.placeholder.com/150";
    this.role = role;
    this.createdAt = new Date();
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
      createdAt: { type: Date, default: Date.now }
    });
  
    return schema;
  }

  static getModel() {
    return mongoose.models.User || mongoose.model('User', this.getSchema());
  }
}

module.exports = User.getModel();
