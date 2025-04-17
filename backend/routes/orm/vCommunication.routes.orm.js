const express = require('express');
const router = express.Router();
const VCommunicationController = require('../../controllers/orm/vCommunication.controller.orm');

// GET all
router.get('/', VCommunicationController.getAll);

module.exports = router;
