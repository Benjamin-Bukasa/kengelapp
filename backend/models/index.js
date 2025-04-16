const fs = require('fs');
const path = require('path');
const sequelize = require('../config/sequelize');
const { Sequelize } = require('sequelize');

const db = {};

// Fonction pour charger les modèles
const loadModels = () => {
  const modelsPath = __dirname;

  fs.readdirSync(modelsPath)
    .filter((file) => file.endsWith('.orm.js'))
    .forEach((file) => {
      try {
        const model = require(path.join(modelsPath, file))(sequelize, Sequelize.DataTypes);
        db[model.name] = model;
      } catch (error) {
        console.error(`Erreur lors du chargement du modèle ${file}:`, error);
      }
    });
};

// Fonction pour gérer les associations
const setupAssociations = () => {
  Object.keys(db).forEach((modelName) => {
    if (db[modelName].associate) {
      db[modelName].associate(db);
    }
  });
};

// Fonction pour synchroniser la base de données
const syncDatabase = async () => {
  try {
    if (process.env.NODE_ENV !== 'production') {
      // En développement, on peut forcer la synchronisation des tables (attention en production)
      await sequelize.sync({ force: true });
      console.log("Les tables ont été synchronisées avec succès");
    } else {
      // En production, il est préférable de ne pas forcer la synchronisation
      await sequelize.sync();
      console.log("Les tables ont été synchronisées sans perte de données");
    }
  } catch (error) {
    console.error("Erreur lors de la synchronisation des tables :", error);
  }
};

// Exécution des fonctions
loadModels();
setupAssociations();
syncDatabase();

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
