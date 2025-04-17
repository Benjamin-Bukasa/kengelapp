const express = require('express');
const router = express.Router();
const GeneriqueController = require('../../controllers/orm/generique.controller.orm');

// Routes CRUD
router.get('/', GeneriqueController.getAll);
router.get('/:id', GeneriqueController.getById);
router.post('/', GeneriqueController.create);
router.put('/:id', GeneriqueController.update);
router.delete('/:id', GeneriqueController.delete);

module.exports = router;

