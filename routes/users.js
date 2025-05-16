const express = require('express');
const User = require('../Models/Users');
const Article = require('../models/Article');
const multer = require('multer');
const path = require('path');
const router = express.Router();



const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/images/'); // Yüklenen resimler "images" klasörüne kaydedilecek
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname)); // Dosya ismini benzersiz yap
    }
});

const upload = multer({ storage: storage });


router.get('/', async (req, res) => {
    try {
        const users = await User.find();
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    try {
        console.log(`Kullanıcı ID: ${req.params.id}`); // Gelen ID'yi kontrol et
        const user = await User.findById(req.params.id).select('-password');

        if (!user) {
            console.log('Kullanıcı bulunamadı');
            return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
        }

        console.log('Kullanıcı bulundu:', user);
        res.json(user);
    } catch (error) {
        console.error('Hata:', error.message);
        res.status(500).json({ error: error.message });
    }
});


router.put('/update-profile/:userId', async (req, res) => {
    try {
        const { name, profileImage, jobTitle, bio } = req.body;

        console.log("📩 Gelen güncelleme isteği:", req.body);

        // Kullanıcıyı bul ve güncelle
        const updatedUser = await User.findByIdAndUpdate(
            req.params.userId,
            {
                name: name,
                profileImage: profileImage,
                jobTitle: jobTitle,
                bio: bio
            },
            { new: true } // Güncellenmiş kullanıcıyı döndür
        );

        if (!updatedUser) {
            return res.status(404).json({ message: 'Kullanıcı bulunamadı!' });
        }

        console.log("✅ Kullanıcı başarıyla güncellendi:", updatedUser);
        res.json(updatedUser);
    } catch (error) {
        console.error("🚨 Profil güncelleme hatası:", error);
        res.status(500).json({ message: 'Sunucu hatası' });
    }
});



router.post('/upload-profile-image', upload.single('profileImage'), async (req, res) => {
    try {
        console.log("📩 İstek geldi! Kullanıcı ID:", req.body.userId);
        console.log("📂 Yüklenen dosya:", req.file);

        if (!req.file) {
            return res.status(400).json({ error: 'Dosya yüklenemedi!' });
        }

        const imageUrl = `http://localhost:8000/public/images/${req.file.filename}`;

        // Kullanıcıyı güncelle (MongoDB'de profileImage URL'sini kaydet)
        const updatedUser = await User.findByIdAndUpdate(
            req.body.userId,
            { profileImage: imageUrl },
            { new: true } // Güncellenmiş kullanıcıyı döndür
        );

        if (!updatedUser) {
            return res.status(404).json({ error: 'Kullanıcı bulunamadı!' });
        }

        res.json({ imageUrl: updatedUser.profileImage, message: "Profil resmi güncellendi!" });
    } catch (error) {
        console.error("🚨 Hata:", error);
        res.status(500).json({ error: 'Sunucu hatası!' });
    }
});

// :id -> takip edilecek kullanıcının ID'si
router.post('/:id/follow', async (req, res) => {
    const currentUserId = req.body.userId;
    const targetUserId = req.params.id;
  
    if (currentUserId === targetUserId) {
      return res.status(400).json({ message: "Kendinizi takip edemezsiniz." });
    }
  
    try {
      const currentUser = await User.findById(currentUserId);
      const targetUser = await User.findById(targetUserId);
  
      if (!currentUser || !targetUser) {
        return res.status(404).json({ message: "Kullanıcı bulunamadı." });
      }
  
      const isFollowing = currentUser.following.includes(targetUserId);
  
      if (isFollowing) {
        // Takibi bırak
        currentUser.following.pull(targetUserId);
        targetUser.followers.pull(currentUserId);
      } else {
        // Takip et
        currentUser.following.push(targetUserId);
        targetUser.followers.push(currentUserId);
      }
  
      await currentUser.save();
      await targetUser.save();
  
      res.status(200).json({
        message: isFollowing ? "Takipten çıkarıldı." : "Takip edildi.",
      });
    } catch (err) {
      res.status(500).json({ message: "Sunucu hatası", error: err.message });
    }
  });
  
  // :id -> kullanıcı ID'si
router.post('/:id/save-article', async (req, res) => {
  const { articleId } = req.body;
  const userId = req.params.id;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "Kullanıcı bulunamadı." });

    const alreadySaved = user.savedArticles.includes(articleId);

    if (alreadySaved) {
      user.savedArticles.pull(articleId);
    } else {
      user.savedArticles.push(articleId);
    }

    await user.save();

    res.status(200).json({
      message: alreadySaved ? "Makaleden çıkarıldı." : "Makale kaydedildi.",
    });
  } catch (err) {
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

router.get('/:userId/saved-articles', async (req, res) => {
    try {
      const userId = req.params.userId;
  
      const user = await User.findById(userId).populate({
        path: 'savedArticles',
        populate: { path: 'author', select: 'name jobTitle' }, // yazar bilgisi de gelsin
      });
  
      if (!user) {
        return res.status(404).json({ message: "Kullanıcı bulunamadı" });
      }
  
      res.json({ savedArticles: user.savedArticles || [] });
    } catch (err) {
      console.error("❌ Hata:", err);
      res.status(500).json({ message: "Sunucu hatası", error: err.message });
    }
  });
  
  // [PUT] /api/users/:id/preferences
  router.patch('/:id/interests', async (req, res) => {
    const userId = req.params.id;
    const selectedCategories = req.body.interests; // kategori id listesi
  
    try {
      const user = await User.findByIdAndUpdate(
        userId,
        {
          preferredCategories: selectedCategories,
          showInterestScreen: false, // ✅ artık bu ekran bir daha gösterilmez
        },
        { new: true }
      );
  
      if (!user) return res.status(404).json({ message: 'User not found' });
  
      res.json({ message: 'İlgi alanları kaydedildi', user });
    } catch (err) {
      res.status(500).json({ message: 'Sunucu hatası', error: err.message });
    }
  });
  




module.exports = router;