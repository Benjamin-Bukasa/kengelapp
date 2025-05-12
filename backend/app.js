//backend/app.js
const express = require('express');
const app = express();
const routes = require('./routes/index.routes'); 
const viewsRoutes = require('./routes/views.routes');
const errorHandler = require('./middlewares/errorHandler');
const authRoutes = require('./routes/auth.routes'); // Importer les routes d'authentification

// Middleware pour gérer les requêtes JSON
app.use(express.json());

// Routes générales
app.use('/api', routes);

// Routes pour les vues (ex : V_Apprenant, VS_Exemple, etc.)
app.use('/api', viewsRoutes); 

//pour le token
app.use('/kengelapp', authRoutes);

// Gestion des erreurs globales
app.use(errorHandler);

module.exports = app;

