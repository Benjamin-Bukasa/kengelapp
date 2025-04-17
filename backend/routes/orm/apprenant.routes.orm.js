const express = require('express');
const router = express.Router();
const ApprenantController = require('../../controllers/orm/apprenant.controller.orm');

// Routes CRUD pour les apprenants
router.get('/', ApprenantController.getAll); 
router.get('/:id', ApprenantController.getById); 
router.post('/', ApprenantController.create); 
router.put('/:id', ApprenantController.update); 
router.delete('/:id', ApprenantController.delete); 

module.exports = router;

