const VLicence = require('../../models/orm/vLicence.orm');

const VLicenceController = {
  getAll: async (req, res) => {
    try {
      const data = await VLicence.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des licences :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VLicenceController;
