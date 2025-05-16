const express = require('express');
const Category = require('../Models/Category');
const authMiddleware = require('../middlewares/authmiddleware');

const router = express.Router();

// Yeni kategori ekle (Sadece Adminler)
router.post('/',  async (req, res) => {
  try {
    const { name, parentId } = req.body;

    // Kategori zaten var mı kontrol et
    const existingCategory = await Category.findOne({ name });
    if (existingCategory) {
      return res.status(400).json({ message: "Bu kategori zaten var" });
    }

    let parentCategory = null;

    // Eğer `parentId` varsa, bu üst kategoriyi kontrol et
    if (parentId) {
      parentCategory = await Category.findById(parentId);
      if (!parentCategory) {
        return res.status(400).json({ message: "Geçersiz üst kategori ID" });
      }
    }

    // Yeni kategori oluştur
    const newCategory = new Category({
      name,
      parent: parentCategory ? parentCategory._id : null
    });

    await newCategory.save();

    res.json({ message: "Kategori başarıyla oluşturuldu", category: newCategory });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Tüm Kategorileri Getir (Alt Kategoriler Dahil)
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find().populate('parent', 'name'); // Üst kategoriyi isim olarak getir
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;