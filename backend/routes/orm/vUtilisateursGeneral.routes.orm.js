const express = require('express');
const router = express.Router();
const VUtilisateursGeneralController = require('../../controllers/orm/vUtilisateursGeneral.controller.orm');

router.get('/', VUtilisateursGeneralController.getAll);

module.exports = router;
