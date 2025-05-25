
const User = require('../models/Users');
const Theme = require('../models/Themes');


const express = require('express');

const router = express.Router();

// [GET] Tüm temaları getir
router.get('/', async (req, res) => {
  try {
    const themes = await Theme.find();
    res.json(themes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Belirli bir kullanıcının temasını getir
router.get('/user/:userId/theme', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).populate('themeId');

    if (!user) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    }

    if (!user.themeId) {
      return res.status(404).json({ error: 'Kullanıcının bir tema tercihi yok' });
    }

    res.json(user.themeId);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// [PATCH] Kullanıcının temasını güncelle
router.patch('/user/:userId/theme', async (req, res) => {
  const { themeId } = req.body;

  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.params.userId,
      { themeId },
      { new: true }
    ).populate('themeId');

    if (!updatedUser) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    }

    res.json({
      message: 'Tema başarıyla güncellendi',
      theme: updatedUser.themeId,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// [POST] Yeni tema oluştur
router.post('/', async (req, res) => {
  try {
    const newTheme = new Theme(req.body);
    const savedTheme = await newTheme.save();
    res.status(201).json(savedTheme);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// [GET] Belirli tema ID'si ile getir
router.get('/:id', async (req, res) => {
  try { 
    const theme = await Theme.findById(req.params.id);
    if (!theme) return res.status(404).json({ error: 'Tema bulunamadı' });
    res.json(theme);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// [PUT] Temayı güncelle
router.put('/:id', async (req, res) => {
  try {
    const updated = await Theme.findByIdAndUpdate(req.params.id, req.body, {
      new: true
    });
    if (!updated) return res.status(404).json({ error: 'Tema bulunamadı' });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// [DELETE] Temayı sil
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Theme.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ error: 'Tema bulunamadı' });
    res.json({ message: 'Tema silindi' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
