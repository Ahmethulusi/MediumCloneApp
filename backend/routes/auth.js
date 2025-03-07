const express = require('express');
const User = require('../Models/Users');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

const router = express.Router();
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    const user = await User.findOne({ email });

    if (!user) {
        return res.status(400).json({ message: 'Geçersiz kimlik bilgileri' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
        return res.status(400).json({ message: 'Geçersiz kimlik bilgileri' });
    }

    const token = jwt.sign(
        { id: user.id },
         'SECRET_KEY',
        { expiresIn: '1h' });

    res.json({
        userId: user.id,  // 🚀 userId döndüğümüzden emin ol!
        name: user.name,
        email: user.email,
        profileImage: user.profileImage,
        role:user.role,
        token
    });
});





router.post('/register',async(req,res)=>{
    try{
        const {name,email,password,profileImage,role} = req.body;

        const existingUser = await User.findOne({email});
        if(existingUser) return res.status(400).json({message:"Bu email adresi zaten kullaniliyor"});
        
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password,salt);

        const newUser = new User({
            name,
            email,
            password: hashedPassword,
            profileImage:profileImage || "",
            role: role || "author"
        });

        await newUser.save();
        res.json({message:"Kullanici basariyla olusturuldu",user:newUser});

    }catch(error){
        res.status(500).json({error:error.message});
    }
})


router.post('/forgot-password', async (req, res) => {
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.' });
        }

        // Şifre sıfırlama tokeni oluştur
        const resetToken = crypto.randomBytes(20).toString('hex');
        user.resetPasswordToken = resetToken;
        user.resetPasswordExpires = Date.now() + 3600000; // 1 saat geçerli

        await user.save();

        // E-posta gönderme
        const transporter = nodemailer.createTransport({
            service: 'Gmail',
            auth: {
                user: 'ahmet4112004@gmail.com',
                pass: 'zyzl vfkd ihez gcpu'
            }
        });

        const mailOptions = {
            to: user.email,
            subject: 'Şifre Sıfırlama Talebi',
            text: `Şifrenizi sıfırlamak için aşağıdaki bağlantıya tıklayın:\n\n http://localhost:8000/api/auth/reset-password/${resetToken}`
        };

        transporter.sendMail(mailOptions, (err, response) => {
            if (err) {
                console.error('E-posta gönderme hatası:', err);
                return res.status(500).json({ message: 'E-posta gönderme başarısız' });
            }
            res.json({ message: 'Şifre sıfırlama bağlantısı e-posta ile gönderildi.' });
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/reset-password/:token', async (req, res) => {
    try {
        const user = await User.findOne({
            resetPasswordToken: req.params.token,
            resetPasswordExpires: { $gt: Date.now() } // Token süresi dolmamış olmalı
        });

        if (!user) {
            return res.status(400).json({ message: 'Geçersiz veya süresi dolmuş token' });
        }

        // Burada frontend'deki şifre sıfırlama sayfasına yönlendirme yap
        res.redirect(`http://localhost:8000/api/auth/reset-password/${req.params.token}`);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});



module.exports = router;
