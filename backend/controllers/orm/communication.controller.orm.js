const Communication = require('../../models/orm/communication.orm'); 

const EmploisTempsController = {
  getAll: async (req, res) => {
    try {
      const emploisTemps = await Communication.findAll();
      res.status(200).json(emploisTemps);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  getById: async (req, res) => {
    try {
      const emploi = await Communication.findByPk(req.params.id);
      if (!emploi) {
        return res.status(404).json({ message: 'Emploi du temps non trouvé' });
      }
      res.status(200).json(emploi);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  create: async (req, res) => {
    try {
      const newEmploi = await Communication.create(req.body);
      res.status(201).json(newEmploi);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  update: async (req, res) => {
    try {
      const emploi = await Communication.findByPk(req.params.id);
      if (!emploi) {
        return res.status(404).json({ message: 'Emploi du temps non trouvé' });
      }
      await emploi.update(req.body);
      res.status(200).json(emploi);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  delete: async (req, res) => {
    try {
      const emploi = await Communication.findByPk(req.params.id);
      if (!emploi) {
        return res.status(404).json({ message: 'Emploi du temps non trouvé' });
      }
      await emploi.destroy();
      res.status(200).json({ message: 'Emploi du temps supprimé' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = EmploisTempsController;
