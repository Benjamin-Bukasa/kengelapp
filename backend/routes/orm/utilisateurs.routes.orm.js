const express = require('express');
const router = express.Router();
const UtilisateursController = require('../../controllers/orm/utilisateurs.controller.orm');


// Routes CRUD pour les utilisateurs
router.get('/', UtilisateursController.getAll);
router.get('/:id', UtilisateursController.getById);
router.post('/', UtilisateursController.create);
router.put('/:id', UtilisateursController.update);
router.delete('/:id', UtilisateursController.delete);

module.exports = router;
