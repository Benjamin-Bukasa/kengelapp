const express = require('express');
const router = express.Router();
const VEmploisTempsController = require('../../controllers/orm/vEmploisTemps.controller.orm');

// GET all emplois du temps
router.get('/', VEmploisTempsController.getAll);

module.exports = router;
