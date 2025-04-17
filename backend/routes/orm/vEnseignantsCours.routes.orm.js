const express = require('express');
const router = express.Router();
const VEnseignantsCoursController = require('../../controllers/orm/vEnseignantsCours.controller.orm');

// GET all enseignants cours
router.get('/', VEnseignantsCoursController.getAll);

module.exports = router;
