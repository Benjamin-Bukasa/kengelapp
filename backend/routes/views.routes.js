//backend/routes/views.routes.js
const express = require('express');
const router = express.Router();
const viewsController = require('../controllers/views.controller');
const getPrismaViews = require('../utils/getPrismaViews'); // Fonction pour récupérer les vues de la base de données

// Dynamique : ajouter une route pour chaque vue
getPrismaViews().then((views) => {
  views.forEach((view) => {
    const routePath = `/${view.toLowerCase()}`;
    router.get(routePath, viewsController.getView(view)); // Associer le contrôleur aux vues
  });
});

module.exports = router;
