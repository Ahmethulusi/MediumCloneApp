const express = require('express');
const User = require('../Models/Users');
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


router.get("/editProfile/",async(req,res)=>{
    const {email,name,profileImage,bio,jobTitle} = req.body;
    try{
        const user = await User.findById(userId);
        if(!user){
            return res.status(404).json({message:"Kullanıcı bulunamadı"});
        }



        res.json(user);
    }catch(error){
        res.status(500).json({error:error.message});
    }
})

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



module.exports = router;