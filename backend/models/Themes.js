// models/ThemeModel.js
const mongoose = require("mongoose");

const themeSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  description: { type: String },
  isDefault: { type: Boolean, default: false },
  createdBy: { type: String, default: "admin" }, // ya "admin" ya da userId
  components: {
    primaryColor: { type: String, required: true },
    scaffoldBackgroundColor: { type: String, required: true },
    appBarColor: { type: String, required: true },
    bottomNavSelected: { type: String, required: true },
    bottomNavUnselected: { type: String, required: true },
    cardColor: { type: String, required: true },
    buttonBackground: { type: String, required: true },
    tabSelected: { type: String, required: true },
    tabUnselected: { type: String, required: true },
    inputFill: { type: String, required: true },
    textColor: { type: String, required: true },
  },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Theme", themeSchema);
