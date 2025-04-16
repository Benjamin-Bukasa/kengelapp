// backend/models/dba/categorieGenerique.dba.js
const pool = require("../../config/db");

const CategorieGenerique = {
  // Récupérer toutes les catégories génériques
  getAll: async () => {
    try {
      const res = await pool.query('SELECT * FROM "T_CategorieGenerique" ORDER BY "IdCategorieGenerique"');
      return res.rows;
    } catch (err) {
      console.error('Erreur lors de la récupération des catégories génériques:', err);
      throw new Error('Impossible de récupérer les catégories génériques');
    }
  },

  // Récupérer une catégorie générique par ID
  getById: async (id) => {
    try {
      const res = await pool.query('SELECT * FROM "T_CategorieGenerique" WHERE "IdCategorieGenerique" = $1', [id]);
      if (res.rows.length === 0) {
        throw new Error('Catégorie générique non trouvée');
      }
      return res.rows[0];
    } catch (err) {
      console.error(`Erreur lors de la récupération de la catégorie générique avec ID ${id}:`, err);
      throw err;
    }
  },

  // Créer une nouvelle catégorie générique
  create: async (data) => {
    try {
      const { LibelleCategorieGenerique } = data;
      
      // Validation simple
      if (!LibelleCategorieGenerique || typeof LibelleCategorieGenerique !== 'string') {
        throw new Error('Le libellé de la catégorie générique est invalide');
      }
      
      const res = await pool.query(
        'INSERT INTO "T_CategorieGenerique" ("LibelleCategorieGenerique") VALUES ($1) RETURNING *',
        [LibelleCategorieGenerique]
      );
      return res.rows[0];
    } catch (err) {
      console.error('Erreur lors de la création de la catégorie générique:', err);
      throw new Error('Impossible de créer la catégorie générique');
    }
  },

  // Mettre à jour une catégorie générique
  update: async (id, data) => {
    try {
      const { LibelleCategorieGenerique } = data;

      // Validation simple
      if (!LibelleCategorieGenerique || typeof LibelleCategorieGenerique !== 'string') {
        throw new Error('Le libellé de la catégorie générique est invalide');
      }

      const res = await pool.query(
        'UPDATE "T_CategorieGenerique" SET "LibelleCategorieGenerique" = $1 WHERE "IdCategorieGenerique" = $2 RETURNING *',
        [LibelleCategorieGenerique, id]
      );
      
      if (res.rows.length === 0) {
        throw new Error('Catégorie générique non trouvée pour mise à jour');
      }
      
      return res.rows[0];
    } catch (err) {
      console.error(`Erreur lors de la mise à jour de la catégorie générique avec ID ${id}:`, err);
      throw err;
    }
  },

  // Supprimer une catégorie générique
  delete: async (id) => {
    try {
      const res = await pool.query('DELETE FROM "T_CategorieGenerique" WHERE "IdCategorieGenerique" = $1 RETURNING *', [id]);
      if (res.rows.length === 0) {
        throw new Error('Catégorie générique non trouvée pour suppression');
      }
      return res.rows[0];  // Retourner la catégorie supprimée
    } catch (err) {
      console.error(`Erreur lors de la suppression de la catégorie générique avec ID ${id}:`, err);
      throw err;
    }
  },
};

module.exports = CategorieGenerique;
