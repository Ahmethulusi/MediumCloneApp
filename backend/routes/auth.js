const express = require('express');
const User = require('../Models/Users');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const router = express.Router();
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Kullanıcıyı MongoDB'de bul
        const user = await User.findOne({ email });
        if (!user) {
            console.log("Kullanıcı bulunamadı!");
            return res.status(400).json({ error: "Geçersiz e-posta adresi" });
        }

        // MongoDB'deki şifreyi ve girilen şifreyi konsola yazdır
        console.log("Veritabanındaki Hashlenmiş Şifre:", user.password);
        console.log("Girilen Şifre:", password);

        // Şifreyi doğrula
        const isMatch = await bcrypt.compare(password, user.password);
        console.log("Karşılaştırma Sonucu:", isMatch);

        if (!isMatch) {
            return res.status(400).json({ error: "Geçersiz şifre" });
        }

        // JWT Token oluştur
        const payload = {
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role
        };

        const token = jwt.sign(payload, process.env.JWT_SECRET_KEY, { expiresIn: "1h" });

        res.status(200);
        res.json({ message: "Giriş başarılı", token });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
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
            role: "author"
        });

        await newUser.save();
        res.json({message:"Kullanici basariyla olusturuldu",user:newUser});

    }catch(error){
        res.status(500).json({error:error.message});
    }
})




module.exports = router;
