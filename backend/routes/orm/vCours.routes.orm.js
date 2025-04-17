const express = require('express');
const router = express.Router();
const VCoursController = require('../../controllers/orm/vCours.controller.orm');

// GET all
router.get('/', VCoursController.getAll);

module.exports = router;
