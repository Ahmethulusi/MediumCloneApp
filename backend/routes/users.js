const express = require('express');
const User = require('../Models/Users');

const router = express.Router();


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


module.exports = router;