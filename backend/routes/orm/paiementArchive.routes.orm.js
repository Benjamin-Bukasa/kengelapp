const express = require('express');
const router = express.Router();
const PaiementArchiveController = require('../../controllers/orm/paiementArchive.controller.orm');

// Routes CRUD pour les PaiementArchives
router.get('/', PaiementArchiveController.getAll); 
router.get('/:id', PaiementArchiveController.getById); 
router.post('/', PaiementArchiveController.create); 
router.put('/:id', PaiementArchiveController.update); 
router.delete('/:id', PaiementArchiveController.delete); 

module.exports = router;
