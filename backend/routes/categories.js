const express = require('express');
const Category = require('../Models/Category');
const Article = require('../models/Article');
const User = require('../Models/Users');

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


// Sadece içinde makale olan kategorileri getir
router.get('/with-articles', async (req, res) => {
  try {
    const articles = await Article.find({}, 'categories');
    const usedCategoryIds = new Set();

    articles.forEach(article => {
      article.categories.forEach(catId => usedCategoryIds.add(catId.toString()));
    });

    const categoriesWithArticles = await Category.find({
      _id: { $in: Array.from(usedCategoryIds) }
    }).populate('parent', 'name');

    res.json(categoriesWithArticles);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.post('/suggestions', async (req, res) => {
  const { userId } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });

    const allCategories = await Category.find();
    const suggestions = [];

    for (const cat of allCategories) {
      const catId = cat._id.toString();
      if (user.preferredCategories.map(id => id.toString()).includes(catId)) continue;

      const articleCount = await Article.countDocuments({ categories: cat._id });
      const followerCount = await User.countDocuments({ preferredCategories: cat._id });

      suggestions.push({
        _id: cat._id,
        name: cat.name,
        articleCount,
        followerCount,
      });
    }

    res.json(suggestions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get('/suggestions/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });

    const allCategories = await Category.find();
    const suggestions = [];

    for (const cat of allCategories) {
      const catId = cat._id.toString();
      if (user.preferredCategories.map(id => id.toString()).includes(catId)) continue;

      const articleCount = await Article.countDocuments({ categories: cat._id });
      const followerCount = await User.countDocuments({ preferredCategories: cat._id });

      suggestions.push({
        _id: cat._id,
        name: cat.name,
        articleCount,
        followerCount,
      });
    }

    res.json(suggestions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});





module.exports = router;