const express = require('express');
const router = express.Router();
const VLoginController = require('../../controllers/orm/vLogin.controller.orm');

// GET all logins
router.get('/', VLoginController.getAll);

module.exports = router;
