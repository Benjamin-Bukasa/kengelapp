const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VGenerique = sequelize.define('VGenerique', {
  IdGenerique: {type: DataTypes.INTEGER,primaryKey: true,field: 'IdGenerique' },
  IdCategorieGeneriqueFk: {type: DataTypes.INTEGER,field: 'IdCategorieGeneriqueFk'},
  categorie: {type: DataTypes.STRING(25),field: 'categorie' },
  nom: {type: DataTypes.STRING(100),field: 'nom' }
}, {
  tableName: 'V_Generique',
  timestamps: false,  
  freezeTableName: true  
});

module.exports = VGenerique;
