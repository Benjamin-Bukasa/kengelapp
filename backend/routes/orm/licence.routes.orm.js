const express = require('express');
const router = express.Router();
const LicenceController = require('../../controllers/orm/licence.controller.orm');

// Routes pour les Licence
router.get('/', LicenceController.getAll);
router.get('/:id', LicenceController.getById);
router.post('/', LicenceController.create);
router.put('/:id', LicenceController.update);
router.delete('/:id', LicenceController.delete);

module.exports = router;
