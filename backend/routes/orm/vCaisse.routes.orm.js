const express = require('express'); 
const router = express.Router();
const VCaisseController = require('../../controllers/orm/vCaisse.controller.orm');

// GET all
router.get('/', VCaisseController.getAll);

module.exports = router;
