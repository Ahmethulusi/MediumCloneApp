const express = require('express');
const Comment = require('../models/Comment');
const router = express.Router();

router.post('/', async (req, res) => {
    try {
      const { articleId, userId, text } = req.body;
  
      // Eksik alan kontrolü
      if (!articleId || !userId || !text) {
        return res.status(400).json({ message: "Tüm alanlar zorunludur." });
      }
  
      // Yeni yorum oluştur
      const newComment = new Comment({
        articleId,
        userId,
        text
      });
  
      await newComment.save();
  
      res.status(201).json({
        message: "Yorum başarıyla gönderildi.",
        comment: newComment
      });
    } catch (err) {
      res.status(500).json({
        message: "Sunucu hatası",
        error: err.message
      });
    }
  });
  
  
  router.get('/:articleId', async (req, res) => {
    try {   
        const comments = await Comment.find({ articleId: req.params.articleId })
        .populate('userId', 'name')
        .sort({ createdAt: -1 });
      
      console.log(comments); // 👈 BURAYA BAK!
      
      res.json(comments);
    } catch (err) {
      res.status(500).json({ message: 'Yorumlar alınamadı', error: err.message });
    }
  });

module.exports = router;
  