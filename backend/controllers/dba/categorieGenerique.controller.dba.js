// backend/controllers/dba/categorieGenerique.controller.dba.js

const CategorieGenerique = require('../../models/dba/categorieGenerique.dba');

const CategorieGeneriqueController = {
  getAll: async (req, res) => {
    try {
      const categories = await CategorieGenerique.getAll();
      res.status(200).json(categories);
    } catch (error) {
      console.error('Erreur getAll CategorieGenerique :', error);
      res.status(500).json({ error: 'Erreur serveur lors de la récupération des catégories' });
    }
  },

  getById: async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ error: 'ID invalide' });

    try {
      const category = await CategorieGenerique.getById(id);
      if (!category) return res.status(404).json({ error: 'Catégorie non trouvée' });

      res.status(200).json(category);
    } catch (error) {
      console.error('Erreur getById CategorieGenerique :', error);
      res.status(500).json({ error: 'Erreur serveur lors de la récupération de la catégorie' });
    }
  },

  create: async (req, res) => {
    try {
      const nouvelleCategorie = await CategorieGenerique.create(req.body);
      res.status(201).json(nouvelleCategorie);
    } catch (error) {
      console.error('Erreur create CategorieGenerique :', error);
      res.status(400).json({ error: 'Erreur lors de la création de la catégorie' });
    }
  },

  update: async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ error: 'ID invalide' });

    try {
      const updated = await CategorieGenerique.update(id, req.body);
      if (!updated) return res.status(404).json({ error: 'Catégorie non trouvée' });

      res.status(200).json(updated);
    } catch (error) {
      console.error('Erreur update CategorieGenerique :', error);
      res.status(400).json({ error: 'Erreur lors de la mise à jour de la catégorie' });
    }
  },

  delete: async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ error: 'ID invalide' });

    try {
      await CategorieGenerique.delete(id);
      res.status(204).end();
    } catch (error) {
      console.error('Erreur delete CategorieGenerique :', error);
      res.status(500).json({ error: 'Erreur lors de la suppression de la catégorie' });
    }
  }
};

module.exports = CategorieGeneriqueController;
