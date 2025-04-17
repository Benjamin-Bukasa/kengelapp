const PaiementArchive = require('../../models/orm/paiementArchive.orm');

const PaiementArchiveController = {
  getAll: async (req, res) => {
    try {
      const paiements = await PaiementArchive.findAll();
      res.status(200).json(paiements);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  getById: async (req, res) => {
    try {
      const paiement = await PaiementArchive.findByPk(req.params.id);
      if (!paiement) {
        return res.status(404).json({ message: 'Paiement archivé non trouvé' });
      }
      res.status(200).json(paiement);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  create: async (req, res) => {
    try {
      const nouveauPaiement = await PaiementArchive.create(req.body);
      res.status(201).json(nouveauPaiement);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  update: async (req, res) => {
    try {
      const paiement = await PaiementArchive.findByPk(req.params.id);
      if (!paiement) {
        return res.status(404).json({ message: 'Paiement archivé non trouvé' });
      }
      await paiement.update(req.body);
      res.status(200).json(paiement);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  delete: async (req, res) => {
    try {
      const paiement = await PaiementArchive.findByPk(req.params.id);
      if (!paiement) {
        return res.status(404).json({ message: 'Paiement archivé non trouvé' });
      }
      await paiement.destroy();
      res.status(200).json({ message: 'Paiement archivé supprimé' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = PaiementArchiveController;
