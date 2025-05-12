const express = require('express');
const Router = express.Router();
const { login, register,currentUser } = require('../controllers/auth.js');
const verifyToken = require('../middlewares/auth.js');


// Route to handle user login
Router.post('/auth/login', login);
Router.post('/auth/register', register);
Router.get('/auth/me', verifyToken, currentUser);


// Export the router
module.exports = Router;