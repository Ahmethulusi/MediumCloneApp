const express = require('express');
const router = express.Router();

const Article = require('../models/Article');
const Comment = require('../models/Comment');

// routes/notifications.js
router.get('/:userId', async (req, res) => {
    try {
      const { userId } = req.params;
  
      const articles = await Article.find({ 'author._id': userId }).select('_id title');
      const articleIds = articles.map(a => a._id);
  
      // Yorumları getir
      const comments = await Comment.find({ articleId: { $in: articleIds } })
        .populate('userId', 'name')
        .populate('articleId', 'title')
        .sort({ createdAt: -1 });
  
      // Beğenileri işle
      const likedArticles = await Article.find({
        _id: { $in: articleIds },
        likes: { $exists: true, $ne: [] }
      }).populate('likes', 'name');
  
      const likes = [];
      likedArticles.forEach(article => {
        article.likes.forEach(user => {
          likes.push({
            articleTitle: article.title,
            userName: user.name,
            articleId: article._id,
            userId: user._id
          });
        });
      });
  
      res.json({ comments, likes });
    } catch (err) {
      res.status(500).json({ message: "Sunucu hatası", error: err.message });
    }
  });
  
module.exports = router;