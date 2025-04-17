const express = require('express');
const router = express.Router();
const ActivitesParascolairesController = require('../../controllers/orm/activitesParascolaires.controller.orm');

// Routes CRUD pour les ActivitesParascolairess
router.get('/', ActivitesParascolairesController.getAll); 
router.get('/:id', ActivitesParascolairesController.getById); 
router.post('/', ActivitesParascolairesController.create); 
router.put('/:id', ActivitesParascolairesController.update); 
router.delete('/:id', ActivitesParascolairesController.delete); 

module.exports = router;

