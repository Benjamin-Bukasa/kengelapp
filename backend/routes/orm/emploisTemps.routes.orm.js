const express = require('express');
const router = express.Router();
const EmploisTempsController = require('../../controllers/orm/emploisTemps.controller.orm');

// Routes CRUD pour EmploisTemps
router.get('/', EmploisTempsController.getAll);
router.get('/:id', EmploisTempsController.getById);
router.post('/', EmploisTempsController.create);
router.put('/:id', EmploisTempsController.update);
router.delete('/:id', EmploisTempsController.delete);

module.exports = router;
