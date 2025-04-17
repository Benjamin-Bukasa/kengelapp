const express = require('express');
const router = express.Router();
const VLicenceController = require('../../controllers/orm/vLicence.controller.orm');

// GET all licences
router.get('/', VLicenceController.getAll);

module.exports = router;
