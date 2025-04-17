const Licence = require('../../models/orm/licence.orm'); 

const LicenceController = {
  // GET /api/licence
  getAll: async (req, res) => {
    try {
      const Licences = await Licence.findAll();
      res.status(200).json(Licences);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // GET /api/licence/:id
  getById: async (req, res) => {
    try {
      const Licence = await Licence.findByPk(req.params.id);
      if (!Licence) {
        return res.status(404).json({ message: 'Licence non trouvée' });
      }
      res.status(200).json(Licence);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // POST /api/licence
  create: async (req, res) => {
    try {
      const newLicence = await Licence.create(req.body);
      res.status(201).json(newLicence);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // PUT /api/licence/:id
  update: async (req, res) => {
    try {
      const Licence = await Licence.findByPk(req.params.id);
      if (!Licence) {
        return res.status(404).json({ message: 'Licence non trouvée' });
      }
      await Licence.update(req.body);
      res.status(200).json(Licence);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // DELETE /api/licence/:id
  delete: async (req, res) => {
    try {
      const Licence = await Licence.findByPk(req.params.id);
      if (!Licence) {
        return res.status(404).json({ message: 'Licence non trouvée' });
      }
      await Licence.destroy();
      res.status(200).json({ message: 'Licence supprimée' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = LicenceController;
