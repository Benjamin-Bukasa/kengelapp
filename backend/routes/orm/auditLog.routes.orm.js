const express = require('express');
const router = express.Router();
const AuditLogController = require('../../controllers/orm/auditLog.controller.orm');

// Routes CRUD pour les AuditLogs
router.get('/', AuditLogController.getAll); 
router.get('/:id', AuditLogController.getById); 
router.post('/', AuditLogController.create); 
router.put('/:id', AuditLogController.update); 
router.delete('/:id', AuditLogController.delete); 

module.exports = router;

