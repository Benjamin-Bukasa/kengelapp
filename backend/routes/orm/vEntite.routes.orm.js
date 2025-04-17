const express = require('express');
const router = express.Router();
const VEntiteController = require('../../controllers/orm/vEntite.controller.orm');

// GET all entités
router.get('/', VEntiteController.getAll);

module.exports = router;
