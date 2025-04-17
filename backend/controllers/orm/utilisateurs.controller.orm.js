const Utilisateurs = require('../../models/orm/utilisateurs.orm');

const UtilisateursController = {
  getAll: async (req, res) => {
    try {
      const utilisateurs = await Utilisateurs.findAll();
      res.status(200).json(utilisateurs);
    } catch (error) {
      console.error('Erreur lors de la récupération des utilisateurs :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  getById: async (req, res) => {
    try {
      const utilisateur = await Utilisateurs.findByPk(req.params.id);
      if (utilisateur) {
        res.status(200).json(utilisateur);
      } else {
        res.status(404).json({ message: 'Utilisateur non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'utilisateur :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  create: async (req, res) => {
    try {
      const newUtilisateur = await Utilisateurs.create(req.body);
      res.status(201).json(newUtilisateur);
    } catch (error) {
      console.error('Erreur lors de la création de l\'utilisateur :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  update: async (req, res) => {
    try {
      const [updated] = await Utilisateurs.update(req.body, {
        where: { IdUser: req.params.id }
      });
      if (updated) {
        const updatedUtilisateur = await Utilisateurs.findByPk(req.params.id);
        res.status(200).json(updatedUtilisateur);
      } else {
        res.status(404).json({ message: 'Utilisateur non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'utilisateur :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  delete: async (req, res) => {
    try {
      const deleted = await Utilisateurs.destroy({
        where: { IdUser: req.params.id }
      });
      if (deleted) {
        res.status(200).json({ message: 'Utilisateur supprimé' });
      } else {
        res.status(404).json({ message: 'Utilisateur non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la suppression de l\'utilisateur :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = UtilisateursController;
