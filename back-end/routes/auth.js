const express = require('express');
const Router = express.Router();
const { login, register,currentUser,loginWithGoogle } = require('../controllers/auth.js');
const verifyToken = require('../middlewares/auth.js');


// Route to handle user login
Router.post('/auth/login', login);

// Route to handle Google login
Router.post('/auth/login/google', loginWithGoogle);

// Route to handle user registration
Router.post('/auth/register', register);

// Route to get the current user
// This route is protected and requires a valid token
Router.get('/auth/me', verifyToken, currentUser);


// Export the router
module.exports = Router;