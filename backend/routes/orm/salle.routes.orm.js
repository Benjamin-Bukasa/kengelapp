const express = require('express');
const router = express.Router();
const SalleController = require('../../controllers/orm/salle.controller.orm');

// Routes pour les login
router.get('/', SalleController.getAll);
router.get('/:id', SalleController.getById);
router.post('/', SalleController.create);
router.put('/:id', SalleController.update);
router.delete('/:id', SalleController.delete);

module.exports = router;