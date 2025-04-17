const AuditLogModel = require('../../models/orm/auditLog.orm');

const AuditLogController = {
  getAll: async (req, res) => {
    try {
      const logs = await AuditLogModel.findAll();
      res.status(200).json(logs);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  getById: async (req, res) => {
    try {
      const log = await AuditLogModel.findByPk(req.params.id);
      if (!log) {
        return res.status(404).json({ message: 'Log non trouvé' });
      }
      res.status(200).json(log);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  create: async (req, res) => {
    try {
      const newLog = await AuditLogModel.create(req.body);
      res.status(201).json(newLog);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  update: async (req, res) => {
    try {
      const log = await AuditLogModel.findByPk(req.params.id);
      if (!log) {
        return res.status(404).json({ message: 'Log non trouvé' });
      }
      await log.update(req.body);
      res.status(200).json(log);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  delete: async (req, res) => {
    try {
      const log = await AuditLogModel.findByPk(req.params.id);
      if (!log) {
        return res.status(404).json({ message: 'Log non trouvé' });
      }
      await log.destroy();
      res.status(200).json({ message: 'Log supprimé' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = AuditLogController;
