const express = require('express');
const User = require('../Models/Users');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

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

    const token = jwt.sign({ id: user.id }, 'SECRET_KEY', { expiresIn: '1h' });

    res.json({
        userId: user.id,  // 🚀 userId döndüğümüzden emin ol!
        name: user.name,
        email: user.email,
        profileImage: user.profileImage,
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
            role: "author"
        });

        await newUser.save();
        res.json({message:"Kullanici basariyla olusturuldu",user:newUser});

    }catch(error){
        res.status(500).json({error:error.message});
    }
})




module.exports = router;
