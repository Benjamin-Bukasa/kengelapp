// backend/utils/primaryKeys.js
// Charge dynamiquement les clés primaires des modèles Prisma

const fs = require('fs');
const path = require('path');

const cacheFile = path.join(__dirname, 'primaryKeys.cache.js');
const generatorScript = path.join(__dirname, 'generatePrimaryKeys.js');

const regeneratePrimaryKeys = () => {
  try {
    require(generatorScript); // Exécute le script de génération
  } catch (error) {
    console.error('❌ Échec de génération des clés primaires :', error.message);
    throw error;
  }
};

// Si le cache n’existe pas ou est vide → régénérer
const cacheExists = fs.existsSync(cacheFile);
const cacheIsEmpty = cacheExists && fs.readFileSync(cacheFile, 'utf-8').trim().length === 0;

if (!cacheExists || cacheIsEmpty) {
  console.log('🔄 Génération du fichier primaryKeys.cache.js...');
  regeneratePrimaryKeys();
}

try {
  module.exports = require('./primaryKeys.cache.js');
} catch (err) {
  console.error('❌ Impossible de charger primaryKeys.cache.js');
  throw err;
}
