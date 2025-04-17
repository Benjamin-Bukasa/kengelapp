const express = require('express');
const router = express.Router();
const LoginController = require('../../controllers/orm/login.controller.orm');

// Routes pour les login
router.get('/', LoginController.getAll);
router.get('/:id', LoginController.getById);
router.post('/', LoginController.create);
router.put('/:id', LoginController.update);
router.delete('/:id', LoginController.delete);

module.exports = router;
