const express = require('express');
const router = express.Router();
const VGeneriqueController = require('../../controllers/orm/vGenerique.controller.orm');

// GET all
router.get('/', VGeneriqueController.getAll);

module.exports = router;
