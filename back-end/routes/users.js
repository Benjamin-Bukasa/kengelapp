const express = require('express');
const Router = express.Router();
const {getAllUsers, getUserById} = require('../controllers/users.js');
const {verifyToken} = require('../utils/jwt.js');

Router.get('/users', getAllUsers);
Router.get('/user/:id', getUserById);

module.exports = Router;