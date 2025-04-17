const Apprenant = require('../../models/orm/apprenant.orm'); 

const ApprenantController = {
  getAll: async (req, res) => {
    try {
      const apprenants = await Apprenant.findAll(); // Récupérer tous les apprenants
      res.status(200).json(apprenants);
    } catch (error) {
      console.error('Erreur lors de la récupération des apprenants :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  getById: async (req, res) => {
    try {
      const apprenant = await Apprenant.findByPk(req.params.id); // Récupérer un apprenant par ID
      if (apprenant) {
        res.status(200).json(apprenant);
      } else {
        res.status(404).json({ message: 'Apprenant non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'apprenant :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  create: async (req, res) => {
    try {
      const newApprenant = await Apprenant.create(req.body); // Créer un nouvel apprenant
      res.status(201).json(newApprenant);
    } catch (error) {
      console.error('Erreur lors de la création de l\'apprenant :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  update: async (req, res) => {
    try {
      const [updated] = await Apprenant.update(req.body, {
        where: { IdApprenant: req.params.id } // Mettre à jour un apprenant par ID
      });
      if (updated) {
        const updatedApprenant = await Apprenant.findByPk(req.params.id);
        res.status(200).json(updatedApprenant);
      } else {
        res.status(404).json({ message: 'Apprenant non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'apprenant :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  },

  delete: async (req, res) => {
    try {
      const deleted = await Apprenant.destroy({
        where: { IdApprenant: req.params.id } // Supprimer un apprenant par ID
      });
      if (deleted) {
        res.status(200).json({ message: 'Apprenant supprimé' });
      } else {
        res.status(404).json({ message: 'Apprenant non trouvé' });
      }
    } catch (error) {
      console.error('Erreur lors de la suppression de l\'apprenant :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = ApprenantController;
