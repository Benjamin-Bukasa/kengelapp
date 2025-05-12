const express = require('express');
const Router = express.Router();
const { login, register, currentUser } = require('../controllers/auth.controller');
const verifyToken = require('../middlewares/verifyToken');

Router.post('/auth/login', login);
Router.post('/auth/register', register);
Router.get('/auth/me', verifyToken, currentUser);

module.exports = Router;
