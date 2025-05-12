const express = require('express');
const Router = express.Router();
const { login, register, currentUser, loginWithGoogle } = require('../controllers/auth');
const verifyToken = require('../middlewares/auth');

// Connexion manuelle
Router.post('/auth/login', login);

// Connexion Google
Router.post('/auth/login/google', loginWithGoogle);

// Inscription
Router.post('/auth/register', register);

// Récupérer l'utilisateur connecté
Router.get('/auth/me', verifyToken, currentUser);

module.exports = Router;
