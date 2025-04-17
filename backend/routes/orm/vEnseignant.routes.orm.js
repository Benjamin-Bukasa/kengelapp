const express = require('express');
const router = express.Router();
const VEnseignantController = require('../../controllers/orm/vEnseignant.controller.orm');

// GET all enseignants
router.get('/', VEnseignantController.getAll);

module.exports = router;
