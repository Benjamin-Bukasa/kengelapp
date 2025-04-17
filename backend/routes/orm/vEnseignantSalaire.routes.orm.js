const express = require('express');
const router = express.Router();
const VEnseignantSalaireController = require('../../controllers/orm/vEnseignantSalaire.controller.orm');

// GET all enseignants salaires
router.get('/', VEnseignantSalaireController.getAll);

module.exports = router;
