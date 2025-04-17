const Cours = require('../../models/orm/cours.orm'); 

const CoursController = {
  // GET /api/cours
  getAll: async (req, res) => {
    try {
      const cours = await Cours.findAll();
      res.status(200).json(cours);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // GET /api/cours/:id
  getById: async (req, res) => {
    try {
      const cours = await Cours.findByPk(req.params.id);
      if (!cours) {
        return res.status(404).json({ message: 'Cours non trouvé' });
      }
      res.status(200).json(cours);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // POST /api/cours
  create: async (req, res) => {
    try {
      const newCours = await Cours.create(req.body);
      res.status(201).json(newCours);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // PUT /api/cours/:id
  update: async (req, res) => {
    try {
      const cours = await Cours.findByPk(req.params.id);
      if (!cours) {
        return res.status(404).json({ message: 'Cours non trouvé' });
      }
      await cours.update(req.body);
      res.status(200).json(cours);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // DELETE /api/cours/:id
  delete: async (req, res) => {
    try {
      const cours = await Cours.findByPk(req.params.id);
      if (!cours) {
        return res.status(404).json({ message: 'Cours non trouvé' });
      }
      await cours.destroy();
      res.status(200).json({ message: 'Cours supprimé' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = CoursController;
