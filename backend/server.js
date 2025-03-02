require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const userRoutes = require('./routes/users');
const articleRoutes = require('./Routes/articles');
const categoryRoutes = require('./routes/categories');
const authrouter = require('./routes/auth');

const app = express();
app.use(express.json());
app.use(cors());
app.use(bodyParser.json());

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
app.use('/api/categories',categoryRoutes);
app.use('/api/auth',authrouter);


app.listen(PORT,()=>{
    console.log('Server is running on port',PORT);
})



