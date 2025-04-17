const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();

// Middleware global pour parser les requêtes JSON
app.use(express.json());

// Dynamically load all ORM route files
const ormRoutesDir = path.join(__dirname, 'routes', 'orm');

fs.readdirSync(ormRoutesDir).forEach(file => {
  if (file.endsWith('.routes.orm.js')) {
    const route = require(path.join(ormRoutesDir, file));

    // Exemple : vGenerique.routes.orm.js → /api/orm/v-generique
    const routeName = file
      .replace('.routes.orm.js', '')
      .replace(/([A-Z])/g, '-$1') // camelCase → kebab-case (vGenerique → v-generique)
      .toLowerCase();

    app.use(`/api/orm/${routeName}`, route);
  }
});

// Middleware de fallback (404 Not Found)
app.use((req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

module.exports = app;
