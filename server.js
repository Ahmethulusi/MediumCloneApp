require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const bodyParser = require('body-parser');
const path = require('path');

const userRoutes = require('./routes/users');
const articleRoutes = require('./routes/articles');
const categoryRoutes = require('./routes/categories');
const authrouter = require('./routes/auth');
const adminRouter = require('./routes/admin');
// const adminRouter = require('./routes/admin');
const notificationRouter = require('./routes/notification');
const reportsRouter = require("./routes/reports");
const commentRouter = require("./routes/comment");

const uploadRoutes = require('./routes/uploads');

// Görselleri sunmak için:



const app = express();

app.use(express.json());
app.use(cors());
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true }));

app.use('/public', express.static('public'));





const PORT = process.env.PORT || 8000;

mongoose.connect(process.env.MONGO_URL,{
}).then(() => {
    console.log('MongoDB Connected');
}).catch((err) => {
    console.log(err);
    console.log('MongoDB Connection Failed:',process.env.MONGO_URL);
})

app.get('/',(req,res)=>{
    res.send('Backend is working');
})



app.use('/api/articles',articleRoutes);
app.use('/api/users',userRoutes);
app.use('/api/admin',adminRouter);
app.use('/api/categories',categoryRoutes);
app.use('/api/auth',authrouter);
app.use("/api/reports", reportsRouter);
app.use("/api/notification", notificationRouter);
app.use("/api/comment", commentRouter);
app.use('/api/uploads', uploadRoutes);
app.use('/images', express.static('public/images'));





app.listen(PORT,()=>{
    console.log('Server is running on port',PORT);
})



