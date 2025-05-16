const express = require('express');
const Article = require('../models/Article');
const Users = require('../Models/Users');
const Category = require('../Models/Category'); // Dosya yolunu kontrol edin ve doğru olduğundan emin olun
const ReadLog = require('../models/ReadLog');
const authMiddleware = require('../middlewares/authmiddleware'); 
const router = express.Router();
const { convertHtmlToDelta,convertDeltaToHtml } = require('node-quill-converter');


// Yeni Makale Ekleme (Sadece Yazarlar ve Üstü)
router.post('/newArticle', async (req, res) => {
  const { title, content, authorId, status, categories,coverImage } = req.body;

  try {
    const author = await Users.findById(authorId);
    if (!author) return res.status(404).json({ message: "User not found" });

    const deltaOps = JSON.parse(content);
    const html = convertDeltaToHtml(deltaOps);

    const newArticle = new Article({
      title,
      content: html, // ✅ Doğru alan adı bu!
      status,
      categories,
      coverImage: coverImage || '',
      author: {
        _id: author._id,
        name: author.name,
        jobTitle: author.jobTitle,
      },
    });
    await newArticle.save();
    res.status(201).json(newArticle);
  } catch (err) {
    res.status(500).json({ message: err.message });
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

router.get('/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    const stories = await Article.find({ 'author._id': userId }).sort({ createdAt: -1 });

    res.json({ stories });
  } catch (error) {
    console.error('Makale alma hatası:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// routes/articles.js
router.get('/explore/random', async (req, res) => {
  try {
    const articles = await Article.aggregate([
      { $match: { status: "public" } },
      { $sample: { size: 10 } } // random 10 makale
    ]);
    res.json({ articles });
  } catch (err) {
    res.status(500).json({ message: "Sunucu hatası" });
  }
});

router.get('/all', async (req, res) => {
  try {
    const articles = await Article.find({ status: 'public' }).sort({ createdAt: -1 });
    res.json({ articles });
  } catch (error) {
    console.error("Makale alma hatası:", error);
    res.status(500).json({ message: "Sunucu hatası" });
  }
});

// routes/articles.js
router.post('/increment-read/:articleId', async (req, res) => {
  const { articleId } = req.params;

  try {
    await Article.findByIdAndUpdate(articleId, { $inc: { readCount: 1 } });

    await ReadLog.create({
      articleId,
      userId: req.body.userId || null, // frontend gönderirse userId al
    });

    res.json({ message: 'Okunma sayısı artırıldı ve loglandı' });
  } catch (err) {
    console.error('Okunma log hatası:', err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});


// routes/articles.js
router.post('/like/:articleId', async (req, res) => {
  const { userId } = req.body;
  try {
    const article = await Article.findById(req.params.articleId);
    if (!article.likes.includes(userId)) {
      article.likes.push(userId);
    } else {
      article.likes = article.likes.filter(id => id.toString() !== userId);
    }
    await article.save();
    res.status(200).json({ message: "Like durumu güncellendi" });
  } catch (error) {
    res.status(500).json({ message: "Sunucu hatası" });
  }
});

router.get('/byCategory/:categoryId', async (req, res) => {
  const categoryId = req.params.categoryId;

  try {
    const articles = await Article.find({
      categories: categoryId,
      status: 'public'
    })
      .sort({ createdAt: -1 });

    res.json({ articles });
  } catch (err) {
    console.error("❌ Kategoriye göre makaleler alınamadı:", err);
    res.status(500).json({ message: "Kategoriye göre makaleler alınamadı", error: err.message });
  }
});



router.put('/:id/update', async (req, res) => { 
  const { title, content, coverImage, categories } = req.body;

  try {
    const article = await Article.findById(req.params.id);
    if (!article) return res.status(404).json({ message: "Makale bulunamadı." });

    article.title = title || article.title;
    // article.content = JSON.stringify(content); // Delta içeriği string olarak kaydet

    // Delta'dan HTML üret (opsiyonel ama iyi olur)
    const deltaContent = content;
    const html = convertDeltaToHtml(deltaContent);
    article.html = html;

    article.coverImage = coverImage || article.coverImage;
    article.categories = categories || article.categories;

    await article.save();

    res.status(200).json({ message: "Makale güncellendi.", article });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});


router.get('/:id/content-delta', async (req, res) => {
  try {
    const article = await Article.findById(req.params.id).select('content');
    if (!article) {
      return res.status(404).json({ message: 'Makale bulunamadı' });
    }

    const htmlContent = article.content || '';
    const delta = convertHtmlToDelta(htmlContent);

    res.json({ delta });
  } catch (err) {
    console.error("💥 Dönüştürme hatası:", err);
    res.status(500).json({ message: 'Sunucu hatası', error: err.message });
  }
});

router.delete('/:id/delete', async (req, res) => {
  try {
    const article = await Article.deleteOne(req.params.id)
    if (!article) {
      return res.status(404).json({ message: 'Makale bulunamadı' });
    }

    await article.save();
    
  } catch (err) {
    console.error("💥 Dönüştürme hatası:", err);
    res.status(500).json({ message: 'Sunucu hatası', error: err.message });
  }
});


// GET /api/articles/byPreferredCategories/:userId

router.get('/byPreferredCategories/:userId', async (req, res) => {
  const userId = req.params.userId;
  try {
    const user = await Users.findById(userId);
    if (!user) return res.status(404).json({ message: 'Kullanıcı bulunamadı' });

    const articles = await Article.find({
      categories: { $in: user.preferredCategories },
      status: 'public'
    }).sort({ createdAt: -1 });

    res.json({ articles });
  } catch (err) {
    res.status(500).json({ message: 'Sunucu hatası', error: err.message });
  }
});

// GET /api/articles/byFollowing/:userId
router.get('/byFollowing/:userId', async (req, res) => {
  const userId = req.params.userId;
  try {
    const user = await Users.findById(userId);
    if (!user) return res.status(404).json({ message: 'Kullanıcı bulunamadı' });

    const articles = await Article.find({
      'author._id': { $in: user.following },
      status: 'public'
    }).sort({ createdAt: -1 });

    res.json({ articles });
  } catch (err) {
    res.status(500).json({ message: 'Sunucu hatası', error: err.message });
  }
});


module.exports = router;
