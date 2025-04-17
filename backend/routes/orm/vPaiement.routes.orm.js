const express = require('express');
const router = express.Router();
const VPaiementController = require('../../controllers/orm/vPaiement.controller.orm');

// GET all paiements
router.get('/', VPaiementController.getAll);

module.exports = router;
