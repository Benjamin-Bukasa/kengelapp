const express = require('express');
const router = express.Router();
const CoursController = require('../../controllers/orm/cours.controller.orm');

// Routes CRUD
router.get('/', CoursController.getAll);
router.get('/:id', CoursController.getById);
router.post('/', CoursController.create);
router.put('/:id', CoursController.update);
router.delete('/:id', CoursController.delete);

module.exports = router;