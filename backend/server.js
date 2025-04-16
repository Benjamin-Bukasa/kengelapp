// backend/server.js
const express = require('express');
const app = express();
const port = process.env.PORT || 5000; // Utilisation de la variable d'environnement PORT pour plus de flexibilité

// Import des routes
const categorieGeneriqueOrmRoutes = require('./routes/orm/categorieGenerique.routes.orm');
const categorieGeneriqueDbaRoutes = require('./routes/dba/categorieGenerique.routes.dba');

// Middleware global pour parser les données JSON
app.use(express.json());


// Enregistrement des routes dans le serveur
app.use('/api/orm/categories-generiques', categorieGeneriqueOrmRoutes);  // Routes pour ORM
app.use('/api/dba/categories-generiques', categorieGeneriqueDbaRoutes);  // Routes pour DBA

// Middleware de gestion des erreurs 404 (Route non trouvée)
app.use((req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

// Lancer le serveur
app.listen(port, () => {
  console.log(`Serveur Express démarré sur le port ${port}`);
});
