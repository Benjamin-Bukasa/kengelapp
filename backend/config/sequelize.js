require('dotenv').config(); 
const { Sequelize } = require('sequelize');

// Création de l'instance Sequelize
const sequelize = new Sequelize(
  process.env.DB_NAME ,
  process.env.DB_USER ,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
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
