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
        userId: user.id,
        name: user.name,
        email: user.email,
        profileImage: user.profileImage,
        role:user.role,
        isBanned:user.isBanned,
        showInterestScreen:user.showInterestScreen,
        token

    });
});


router.post('/register',async(req,res)=>{
    try{
        const {name,email,password,role} = req.body;

        const existingUser = await User.findOne({email});
        if(existingUser) return res.status(400).json({message:"Bu email adresi zaten kullaniliyor"});
        
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password,salt);

        const newUser = new User({  
            name,
            email,
            password: hashedPassword,
            profileImage:"",
            role: role || "author",
            showInterestScreen:true,
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
       
        // Şifre sıfırlama tokeni oluştur ve veritabanına kaydet
        const resetToken = crypto.randomBytes(20).toString('hex');
        user.resetPasswordToken = resetToken;
        user.resetPasswordExpires = Date.now() + 3600000; // 1 saat geçerli

        await user.save(); // ✅ Token veritabanına kaydediliyor

        console.log("📩 Kaydedilen Token:", resetToken); // ✅ Debug için terminalde yazdır

        const transporter = nodemailer.createTransport({ 
            service:'Gmail',
            auth:{
                user:'ahmet4112004@gmail.com',
                pass:process.env.MAIL_APP_PASSWORD
            }
        })

        const mailOptions = {
            title:'Flutter Project',
            from:'ahmet4112004@gmail.com',
            to: user.email,
            subject: 'Şifre Sıfırlama',
            html: `
                <p>Şifrenizi sıfırlamak için aşağıya yeni şifrenizi girin ve "Şifreyi Güncelle" butonuna basın:</p>
                <form action="http://localhost:8000/api/auth/reset-password/${resetToken}" method="POST">
                    <input type="password" name="password" placeholder="Yeni Şifre" required style="padding: 8px; margin-right: 8px;"/>
                    <button type="submit" style="background-color: blue; color: white; padding: 8px; border: none;">Şifreyi Güncelle</button>
                </form>
                <p>Bağlantıya tıkladıktan sonra yeni şifrenizi belirleyebilirsiniz.</p>
            `
        };
 
        await transporter.sendMail(mailOptions);

        return res.json({ message: 'Şifre sıfırlama bağlantısı e-posta ile gönderildi.' });

    } catch (error) {
        console.error("❌ Forgot Password Hatası:", error);
        return res.status(500).json({ error: error.message });
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

router.post('/reset-password/:token', async (req, res) => {
    try {
        const user = await User.findOne({
            resetPasswordToken: req.params.token,
            resetPasswordExpires: { $gt: Date.now() } // Token süresi dolmamış olmalı
        });

        if (!user) {
            return res.send('<h1>Geçersiz veya süresi dolmuş token</h1>');
        }

        // Yeni şifreyi kontrol et
        if (!req.body.password) {
            console.log(req.body);
            return res.status(400).send('<h3>❌ Lütfen geçerli bir şifre girin.</h3>');

        }
        // Yeni şifreyi hashle
        const newPassword = await bcrypt.hash(req.body.password, 10);
        
        user.password = newPassword;
        user.resetPasswordToken = null;
        user.resetPasswordExpires = null;
        console.log("New password", newPassword);
        await user.save();

        res.send('<h1>✅ Şifreniz başarıyla güncellendi! Artık giriş yapabilirsiniz.</h1>');
    } catch (error) {
        res.status(500).send('<h3>❌ Bir hata oluştu. Lütfen tekrar deneyin.</h3>');
        console.log("Hata", error);
    }
});


router.get('/verify-account/:token', async (req, res) => {
    try {
        const user = await User.findOne({
            resetPasswordToken: req.params.token,
            resetPasswordExpires: { $gt: Date.now() } // Token süresi dolmamış olmalı
        });

        if (!user) {
            return res.status(400).send('<h1>Geçersiz veya süresi dolmuş token</h1>');
        }

        // Token geçerliyse sadece mesaj göster
        res.send('<h1>Hesabınız doğrulandı. Lütfen uygulamaya dönün.</h1>');
    } catch (error) {
        res.status(500).send('<h1>Sunucu hatası</h1>');
    }
});


module.exports = router;
