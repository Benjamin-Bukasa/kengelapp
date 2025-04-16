// backend/app.js
const express = require('express');
const app = express();

// Middleware global pour parser les requêtes JSON
app.use(express.json());

// Import des fichiers de routes
const categorieGeneriqueOrmRoutes = require('./routes/orm/categorieGenerique.routes.orm');
const categorieGeneriqueDbaRoutes = require('./routes/dba/categorieGenerique.routes.dba');

// Définition des routes pour ORM
app.use('/api/orm/categories-generiques', categorieGeneriqueOrmRoutes);

// Définition des routes pour DBA
app.use('/api/dba/categories-generiques', categorieGeneriqueDbaRoutes);

// Middleware de fallback (404 Not Found)
app.use((req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

module.exports = app;
