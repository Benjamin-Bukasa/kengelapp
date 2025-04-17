const VLogin = require('../../models/orm/vLogin.orm');

const VLoginController = {
  getAll: async (req, res) => {
    try {
      const data = await VLogin.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des connexions :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VLoginController;
