const express = require('express');
const router = express.Router();
const VUtilisateurController = require('../../controllers/orm/vUtilisateur.controller.orm');

router.get('/', VUtilisateurController.getAll);

module.exports = router;
