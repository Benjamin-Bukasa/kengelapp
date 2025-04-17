const VGenerique = require('../../models/orm/vGenerique.orm');

const VGeneriqueController = {
  getAll: async (req, res) => {
    try {
      const data = await VGenerique.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_Generique :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VGeneriqueController;
