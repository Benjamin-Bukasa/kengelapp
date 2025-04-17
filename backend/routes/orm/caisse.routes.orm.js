const express = require('express');
const router = express.Router();
const CaisseController = require('../../controllers/orm/caisse.controller.orm');

// Routes pour les login
router.get('/', CaisseController.getAll);
router.get('/:id', CaisseController.getById);
router.post('/', CaisseController.create);
router.put('/:id', CaisseController.update);
router.delete('/:id', CaisseController.delete);

module.exports = router;