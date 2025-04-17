const express = require('express');
const router = express.Router();
const VEvaluationsController = require('../../controllers/orm/vEvaluations.controller.orm');

// GET all evaluations
router.get('/', VEvaluationsController.getAll);

module.exports = router;
