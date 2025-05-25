const express = require('express');
const User = require("../Models/Users");
const router = express.Router();
const Article = require("../models/Article");
const ReadLog = require('../models/ReadLog');
const Comment = require('../models/Comment');
const Message = require('../models/Messages');


// ✅ Kullanıcıya Mesaj Gönder
router.post('/message', async (req, res) => {
  const { userId, message } = req.body;

  if (!userId || !message) {
    return res.status(400).json({ message: "Eksik bilgi" });
  }

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "Kullanıcı bulunamadı" });

    // Örnek olarak sabit bir admin ID kullanalım (oturum yönetimi yoksa)
    const adminId = "67ce249230f3cf4d1f3ac178"; // kendi admin ID'nle değiştir

    const newMessage = new Message({
      sender: adminId,
      receiver: userId,
      content: message,
    });

    await newMessage.save();

    res.status(200).json({ message: "Mesaj gönderildi" });
  } catch (err) {
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

// bütün mesajları getir (test için)
router.get('/messages', async (req, res) => {
    try {
        const messages = await Message.find();
        res.json(messages);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// [PATCH] /api/messages/mark-read/:messageId
router.patch('/messages/mark-read/:messageId', async (req, res) => {
  try {
    await Message.findByIdAndUpdate(req.params.messageId, { isRead: true });
    res.status(200).json({ message: 'Mesaj okundu olarak işaretlendi' });
  } catch (err) {
    res.status(500).json({ message: 'İşaretleme hatası', error: err.message });
  }
});

// [GET] /api/messages/unread/:userId
router.get('/messages/unread/:userId', async (req, res) => {

  try {
    const messages = await Message.find({
      receiver: req.params.userId,
      isRead: false,
    }).sort({ createdAt: -1 });

    res.status(200).json({ messages });
  } catch (err) {
    res.status(500).json({ message: 'Hata oluştu', error: err.message });
  }
});



// ✅ Banla
router.post("/action/ban", async (req, res) => {
  const { userId } = req.body;

  try {
    await User.findByIdAndUpdate(userId, { isBanned: true });
    res.json({ message: "Kullanıcı banlandı" });
  } catch (error) {
    res.status(500).json({ message: "Banlama işlemi başarısız" });
  }
});
// ✅ Banı Kaldır
router.post("/action/unban", async (req, res) => {
  const { userId } = req.body;

  try {
    await User.findByIdAndUpdate(userId, { isBanned: false });
    res.json({ message: "Kullanıcı banlandı" });
  } catch (error) {
    res.status(500).json({ message: "Banlama işlemi başarısız" });
  }
});


// ✅ Dondur
router.post("/action/freeze", async (req, res) => {
  const { userId } = req.body;
  try {
    await User.findByIdAndUpdate(userId, { isFrozen: true });
    res.json({ message: "Hesap donduruldu" });
  } catch (error) {
    res.status(500).json({ message: "Dondurma işlemi başarısız" });
  }
});


// ✅ Hesap Sil
router.delete("/action/delete/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    await User.findByIdAndDelete(userId);
    res.json({ message: "Kullanıcı silindi" });
  } catch (error) {
    res.status(500).json({ message: "Silme işlemi başarısız" });
  }
});

// routes/articles.js
router.delete('/delete/:articleId', async (req, res) => {
  try {
    const articleId = req.params.articleId;
    await Article.findByIdAndDelete(articleId);
    res.status(200).json({ message: 'Makale silindi' });
  } catch (err) {
    console.error('Makale silme hatası:', err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});


router.get('/total-users', async (req, res) => {
  try {
    const count = await User.countDocuments(); // kullanıcı sayısı
    res.json({ totalUsers: count });
  } catch (error) {
    console.error("Toplam kullanıcı sayısı hatası:", error);
    res.status(500).json({ message: "Sunucu hatası" });
  }
});

router.get('/stats/users-count', async (req, res) => {
  const count = await User.countDocuments();
  res.json({ totalUsers: count });
});

router.get('/stats/articles-count', async (req, res) => {
  const count = await Article.countDocuments({ status: 'public' });
  res.json({ totalArticles: count });
});

router.get('/top-articles/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const articles = await Article.find({ 
        status: 'public',
        'author._id': userId
      })
      .sort({ readCount: -1 }) // okunma sayısına göre sırala
      .limit(10)
      .populate('author', 'name'); // sadece yazar ismi

    res.status(200).json({ articles });
  } catch (err) {
    console.error("Hata:", err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

router.get('/stats/top-authors', async (req, res) => {
  const result = await Article.aggregate([
    { $match: { status: 'public' } },
    { $group: { _id: '$author._id', name: { $first: '$author.name' }, count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: 5 }
  ]);
  res.json({ topAuthors: result });
});

// Sayısal Istatistikler
router.get('/statistics', async (req, res) => {
  try {
    const userCount = await User.countDocuments();
    const articleCount = await Article.countDocuments();

    const allArticles = await Article.find({}, 'readCount likes');

    const totalReadCount = allArticles.reduce((sum, article) => sum + (article.readCount || 0), 0);
    const totalLikeCount = allArticles.reduce(
      (sum, article) => sum + (article.likes ? article.likes.length : 0),
      0
    );

    res.json({
      userCount,
      articleCount,
      totalReadCount,
      totalLikeCount,
    });
  } catch (err) {
    console.error("İstatistik alma hatası:", err);
    res.status(500).json({ message: "Sunucu hatası" });
  }
});



// [GET] /api/admin/stats/top-liked/:userId
router.get('/top-liked/:userId', async (req, res) => {
  try {
    const articles = await Article.find({ "author._id": req.params.userId })
      .sort({ likes: -1 }) // MongoDB'de array uzunluğuna göre sıralama
      .limit(10);

    res.status(200).json({ articles });
  } catch (err) {
    res.status(500).json({ message: 'Veri alınamadı', error: err.message });
  }
});


// [GET] /api/admin/stats/top-saved/:userId
router.get('/top-saved/:userId', async (req, res) => {
  try {
    const users = await User.find({ savedArticles: { $exists: true, $ne: [] } });

    // Tüm makaleId'leri say
    const articleCountMap = {};

    users.forEach(user => {
      user.savedArticles.forEach(articleId => {
        articleCountMap[articleId] = (articleCountMap[articleId] || 0) + 1;
      });
    });

    // Bu kullanıcıya ait makaleleri filtrele
    const articles = await Article.find({ "author._id": req.params.userId });

    const result = articles
      .map(article => ({
        ...article.toObject(),
        saveCount: articleCountMap[article._id] || 0,
      }))
      .sort((a, b) => b.saveCount - a.saveCount)
      .slice(0, 10);

    res.status(200).json({ articles: result });
  } catch (err) {
    res.status(500).json({ message: 'Veri alınamadı', error: err.message });
  }
});

// [GET] /api/admin/stats/top-commented/:userId
router.get('/top-commented/:userId', async (req, res) => {
  try {
    const articles = await Article.find({ "author._id": req.params.userId });

    const commentCounts = await Promise.all(
      articles.map(async (article) => {
        const count = await Comment.countDocuments({ articleId: article._id });
        return { article, commentCount: count };
      })
    );

    const sorted = commentCounts
      .sort((a, b) => b.commentCount - a.commentCount)
      .slice(0, 10)
      .map(item => ({
        ...item.article.toObject(),
        commentCount: item.commentCount
      }));

    res.status(200).json({ articles: sorted });
  } catch (err) {
    res.status(500).json({ message: 'Veri alınamadı', error: err.message });
  }
});


 
module.exports = router;