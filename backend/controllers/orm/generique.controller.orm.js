const Generique = require('../../models/orm/generique.orm');

const GeneriqueController = {
  getAll: async (req, res) => {
    try {
      const data = await Generique.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des génériques :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  getById: async (req, res) => {
    try {
      const item = await Generique.findByPk(req.params.id);
      if (item) {
        res.status(200).json(item);
      } else {
        res.status(404).json({ message: 'Générique non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la récupération du générique :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  create: async (req, res) => {
    try {
      const newItem = await Generique.create(req.body);
      res.status(201).json(newItem);
    } catch (error) {
      console.error('Erreur lors de la création du générique :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  update: async (req, res) => {
    try {
      const [updated] = await Generique.update(req.body, {
        where: { IdGenerique: req.params.id }
      });
      if (updated) {
        const updatedItem = await Generique.findByPk(req.params.id);
        res.status(200).json(updatedItem);
      } else {
        res.status(404).json({ message: 'Générique non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la mise à jour du générique :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  delete: async (req, res) => {
    try {
      const deleted = await Generique.destroy({
        where: { IdGenerique: req.params.id }
      });
      if (deleted) {
        res.status(200).json({ message: 'Générique supprimé' });
      } else {
        res.status(404).json({ message: 'Générique non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la suppression du générique :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = GeneriqueController;
