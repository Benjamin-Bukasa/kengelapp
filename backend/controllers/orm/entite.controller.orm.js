const Entite = require('../../models/orm/entite.orm');

const EntiteController = {
  getAll: async (req, res) => {
    try {
      const data = await Entite.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des entités :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  getById: async (req, res) => {
    try {
      const entite = await Entite.findByPk(req.params.id);
      if (entite) {
        res.status(200).json(entite);
      } else {
        res.status(404).json({ message: 'Entité non trouvée' });
      }
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'entité :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  create: async (req, res) => {
    try {
      const newEntite = await Entite.create(req.body);
      res.status(201).json(newEntite);
    } catch (error) {
      console.error('Erreur lors de la création de l\'entité :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  update: async (req, res) => {
    try {
      const [updated] = await Entite.update(req.body, {
        where: { IdEntite: req.params.id }
      });
      if (updated) {
        const updatedEntite = await Entite.findByPk(req.params.id);
        res.status(200).json(updatedEntite);
      } else {
        res.status(404).json({ message: 'Entité non trouvée' });
      }
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'entité :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  delete: async (req, res) => {
    try {
      const deleted = await Entite.destroy({
        where: { IdEntite: req.params.id }
      });
      if (deleted) {
        res.status(200).json({ message: 'Entité supprimée' });
      } else {
        res.status(404).json({ message: 'Entité non trouvée' });
      }
    } catch (error) {
      console.error('Erreur lors de la suppression de l\'entité :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = EntiteController;
