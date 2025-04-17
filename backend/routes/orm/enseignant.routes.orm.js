const express = require('express');
const router = express.Router();
const EnseignantController = require('../../controllers/orm/enseignant.controller.orm');

// Routes CRUD
router.get('/', EnseignantController.getAll);
router.get('/:id', EnseignantController.getById);
router.post('/', EnseignantController.create);
router.put('/:id', EnseignantController.update);
router.delete('/:id', EnseignantController.delete);

module.exports = router;
