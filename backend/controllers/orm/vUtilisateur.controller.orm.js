const VUtilisateur = require('../../models/orm/vUtilisateur.orm');

const VUtilisateurController = {
  getAll: async (req, res) => {
    try {
      const data = await VUtilisateur.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des utilisateurs :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VUtilisateurController;
