const express = require('express');
const router = express.Router();
const EntiteController = require('../../controllers/orm/entite.controller.orm');

// Routes CRUD
router.get('/', EntiteController.getAll);
router.get('/:id', EntiteController.getById);
router.post('/', EntiteController.create);
router.put('/:id', EntiteController.update);
router.delete('/:id', EntiteController.delete);

module.exports = router;
