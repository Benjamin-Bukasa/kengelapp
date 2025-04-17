const ActivitesParascolaires = require('../../models/orm/activitesParascolaires.orm');

const ActivitesParascolairesController = {
  getAll: async (req, res) => {
    try {
      const activites = await ActivitesParascolaires.findAll();
      res.status(200).json(activites);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  getById: async (req, res) => {
    try {
      const activite = await ActivitesParascolaires.findByPk(req.params.id);
      if (!activite) {
        return res.status(404).json({ message: 'Activité non trouvée' });
      }
      res.status(200).json(activite);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  create: async (req, res) => {
    try {
      const nouvelleActivite = await ActivitesParascolaires.create(req.body);
      res.status(201).json(nouvelleActivite);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  update: async (req, res) => {
    try {
      const activite = await ActivitesParascolaires.findByPk(req.params.id);
      if (!activite) {
        return res.status(404).json({ message: 'Activité non trouvée' });
      }
      await activite.update(req.body);
      res.status(200).json(activite);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  delete: async (req, res) => {
    try {
      const activite = await ActivitesParascolaires.findByPk(req.params.id);
      if (!activite) {
        return res.status(404).json({ message: 'Activité non trouvée' });
      }
      await activite.destroy();
      res.status(200).json({ message: 'Activité supprimée' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = ActivitesParascolairesController;
