const express = require('express');
const router = express.Router();
const PresenceController = require('../../controllers/orm/presence.controller.orm');

// Routes pour les Presence
router.get('/', PresenceController.getAll);
router.get('/:id', PresenceController.getById);
router.post('/', PresenceController.create);
router.put('/:id', PresenceController.update);
router.delete('/:id', PresenceController.delete);

module.exports = router;
