// backend/config/sequelize.js
const { Sequelize } = require('sequelize');

// Création de l'instance Sequelize
const sequelize = new Sequelize(
  'KengelApp',
  'postgres',
  'PostgreSQL2025',
  {
    host: 'localhost',
    port: 5432,
    dialect: 'postgres',
    logging: false,
    define: {
      freezeTableName: true,
      underscored: true,
    },
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

// Vérification immédiate de la connexion
(async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Connexion Sequelize réussie à PostgreSQL');
  } catch (error) {
    console.error('❌ Échec de la connexion Sequelize :', error);
  }
})();


module.exports = sequelize;
