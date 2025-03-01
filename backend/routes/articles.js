const express = require('express');
const Article = require('../Models/Article');
const Category = require('../Models/Category'); // Dosya yolunu kontrol edin ve doğru olduğundan emin olun
const authMiddleware = require('../middlewares/authmiddleware'); 

const router = express.Router();

// Yeni Makale Ekleme (Sadece Yazarlar ve Üstü)
router.post('/newArticle', async (req, res) => {
  try {
    const { title, content, author, categoryNames } = req.body;

    // Kategorileri bul veya oluştur
    const categories = await Promise.all(
      categoryNames.map(async (name) => {
        let category = await Category.findOne({ name });
        if (!category) {
          category = new Category({ name });
          await category.save();
        }
        return category._id;
      })
    );

    // Makale oluştur
    const newArticle = new Article({
      title,
      content,
      author,
      categories
    });

    await newArticle.save();
    res.json({ message: "Makale başarıyla oluşturuldu", article: newArticle });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const articles = await Article.find().populate('categories');
    res.json(articles);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;