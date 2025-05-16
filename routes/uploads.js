const express = require('express');
const multer = require('multer');
const path = require('path');
const router = express.Router();

// Storage yapılandırması
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/images/'); // 👈 buraya kaydedilecek
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

// Route tanımı
router.post('/', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'Dosya yüklenemedi.' });
  }

  // Görsel yolu
  const imageUrl = `/images/${req.file.filename}`;
  res.status(200).json({ imageUrl });
});

module.exports = router;
