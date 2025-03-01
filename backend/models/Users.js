
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

class User {
  constructor(name, email, profileImage,password, role = "visitor") {
    this.name = name;
    this.email = email;
    this.password = password;
    this.profileImage = profileImage || "";
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
        enum: ["visitor", "author", "editor", "admin"], 
        default: "visitor"
      },
      createdAt: { type: Date, default: Date.now }
    });

    // // Kullanıcı kaydedilmeden önce şifreyi hashle
    // schema.pre('save', async function (next) {
    //   if (!this.isModified('password')) return next();
  
    //   // Şifre zaten hashlenmiş mi, kontrol et
    //   if (this.password.startsWith("$2a$10$")) {
    //       return next(); // Eğer şifre zaten hashlenmişse tekrar hashleme
    //   }
  
    //   const salt = await bcrypt.genSalt(10);
    //   this.password = await bcrypt.hash(this.password, salt);
    //   next();
    // });
  

    return schema;
  }

  static getModel() {
    return mongoose.models.User || mongoose.model('User', this.getSchema());
  }
}

module.exports = User.getModel();
