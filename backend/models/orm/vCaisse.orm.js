const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VCaisse = sequelize.define('VCaisse', {
  IdCaisse: { type: DataTypes.INTEGER, primaryKey: true,field: 'IdCaisse'},
  IdDeviseFk: { type: DataTypes.INTEGER, field: 'IdDeviseFk' },
  montant_caisse: { type: DataTypes.DECIMAL(10, 2), field: 'montant_caisse' },  
  nom_devise: { type: DataTypes.STRING(100), field: 'nom_devise' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING(100), field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING(100), field: 'type_entite' }
}, {
  tableName: 'V_Caisse',
  timestamps: false,
  freezeTableName: true,
});

module.exports = VCaisse;