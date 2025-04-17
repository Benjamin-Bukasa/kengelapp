const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VPresence = sequelize.define('VPresence', {
  IdPresence: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdPresence' },
  DatePresence: { type: DataTypes.DATE, field: 'DatePresence' },
  IdControleurFk: { type: DataTypes.INTEGER, field: 'IdControleurFk' },
  controleur: { type: DataTypes.STRING, field: 'controleur' },
  IdControleFk: { type: DataTypes.INTEGER, field: 'IdControleFk' },
  controle: { type: DataTypes.STRING, field: 'controle' },
  IdStatutPresenceFk: { type: DataTypes.INTEGER, field: 'IdStatutPresenceFk' },
  type_presence: { type: DataTypes.STRING, field: 'type_presence' },
  ValidePresence: { type: DataTypes.BOOLEAN, field: 'ValidePresence' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_Presence',
  timestamps: false,
  freezeTableName: true
});

module.exports = VPresence;
