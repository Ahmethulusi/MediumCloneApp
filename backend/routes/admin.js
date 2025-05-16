const express = require('express');
const User = require("../Models/Users");
const router = express.Router();
const Article = require("../models/Article");
const ReadLog = require('../models/ReadLog');

// ✅ Kullanıcıya Mesaj Gönder
router.post('/message', async (req, res) => {
    const { userId, message } = req.body;
  
    if (!userId || !message) {
      return res.status(400).json({ message: "Eksik bilgi" });
    }
  
    try {
      // İsterseniz DB'ye kaydedebilirsiniz
      console.log(`📩 Admin'den kullanıcıya mesaj: ${userId} - ${message}`);
  
      // TODO: Email gönderme, notification, vs.
      res.status(200).json({ message: "Mesaj başarıyla gönderildi" });
    } catch (err) {
      console.error("Mesaj gönderme hatası:", err);
      res.status(500).json({ message: "Sunucu hatası" });
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

router.get('/stats/top-articles', async (req, res) => {
  try {
    const articles = await Article.find({ status: 'public' })
      .sort({ readCount: -1 }) // okunma sayısına göre sırala
      .limit(10)
      .populate('author', 'name'); // sadece yazarın ismini getir

    res.status(200).json({ articles });
  } catch (err) {
    console.error(" Hata:", err);
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

// router.get('/statistics/daily-reads', async (req, res) => {
//   const start = new Date();
//   start.setDate(start.getDate() - 6); // son 7 gün

//   const data = await ReadLog.aggregate([
//     { $match: { readAt: { $gte: start } } },
//     {
//       $group: {
//         _id: { $dateToString: { format: "%Y-%m-%d", date: "$readAt" } },
//         count: { $sum: 1 }
//       }
//     },
//     { $sort: { _id: 1 } }
//   ]);

//   res.json(data);
// });

// router.get('/statistics/monthly-reads', async (req, res) => {
//   const start = new Date();
//   start.setMonth(start.getMonth() - 5); // son 6 ay

//   const data = await ReadLog.aggregate([
//     { $match: { readAt: { $gte: start } } },
//     {
//       $group: {
//         _id: { $dateToString: { format: "%Y-%m", date: "$readAt" } },
//         count: { $sum: 1 }
//       }
//     },
//     { $sort: { _id: 1 } }
//   ]);

//   res.json(data);
// });


 
module.exports = router;