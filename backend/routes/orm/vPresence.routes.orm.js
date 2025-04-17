const express = require('express');
const router = express.Router();
const VPresenceController = require('../../controllers/orm/vPresence.controller.orm');

router.get('/', VPresenceController.getAll);

module.exports = router;
