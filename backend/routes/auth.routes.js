// Backend/routes/auth.routes.js
const express = require('express');
const Router = express.Router();
const { login, register, currentUser,refresh,logout} = require('../controllers/auth.controller');
const verifyToken = require('../middlewares/verifyToken');

Router.post('/auth/login', login);
Router.post('/auth/logout', verifyToken, logout);
Router.post('/auth/register', register);
Router.get('/auth/me', verifyToken, currentUser);
Router.post('/auth/refresh', refresh);

module.exports = Router;
