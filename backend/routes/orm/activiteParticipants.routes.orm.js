const express = require('express');
const router = express.Router();
const ActivitesParticipantsController = require('../../controllers/orm/activiteParticipants.controller.orm');

// Routes CRUD pour les ActivitesParticipantss
router.get('/', ActivitesParticipantsController.getAll); 
router.get('/:id', ActivitesParticipantsController.getById); 
router.post('/', ActivitesParticipantsController.create); 
router.put('/:id', ActivitesParticipantsController.update); 
router.delete('/:id', ActivitesParticipantsController.delete); 

module.exports = router;

