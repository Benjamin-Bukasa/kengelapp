const express = require('express');
const router = express.Router();
const EvaluationsController = require('../../controllers/orm/evaluations.controller.orm');

// Routes pour les login
router.get('/', EvaluationsController.getAll);
router.get('/:id', EvaluationsController.getById);
router.post('/', EvaluationsController.create);
router.put('/:id', EvaluationsController.update);
router.delete('/:id', EvaluationsController.delete);

module.exports = router;