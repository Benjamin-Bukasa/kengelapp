const Paiement = require('../../models/orm/paiement.orm'); // Assurez-vous que le modèle existe

const PaiementController = {
  // GET /api/paiements
  getAll: async (req, res) => {
    try {
      const paiements = await Paiement.findAll();
      res.status(200).json(paiements);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // GET /api/paiements/:id
  getById: async (req, res) => {
    try {
      const paiement = await Paiement.findByPk(req.params.id);
      if (!paiement) {
        return res.status(404).json({ message: 'Paiement non trouvé' });
      }
      res.status(200).json(paiement);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // POST /api/paiements
  create: async (req, res) => {
    try {
      const newPaiement = await Paiement.create(req.body);
      res.status(201).json(newPaiement);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // PUT /api/paiements/:id
  update: async (req, res) => {
    try {
      const paiement = await Paiement.findByPk(req.params.id);
      if (!paiement) {
        return res.status(404).json({ message: 'Paiement non trouvé' });
      }
      await paiement.update(req.body);
      res.status(200).json(paiement);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // DELETE /api/paiements/:id
  delete: async (req, res) => {
    try {
      const paiement = await Paiement.findByPk(req.params.id);
      if (!paiement) {
        return res.status(404).json({ message: 'Paiement non trouvé' });
      }
      await paiement.destroy();
      res.status(200).json({ message: 'Paiement supprimé' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = PaiementController;
