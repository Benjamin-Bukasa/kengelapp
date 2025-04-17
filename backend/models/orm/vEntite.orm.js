const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VEntite = sequelize.define('VEntite', {
  IdEntite: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdEntite' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' },
  PhoneEntite: { type: DataTypes.STRING, field: 'PhoneEntite' },
  EmailEntite: { type: DataTypes.STRING, field: 'EmailEntite' },
  AdresseEntite: { type: DataTypes.STRING, field: 'AdresseEntite' },
  DateCreationEntite: { type: DataTypes.DATE, field: 'DateCreationEntite' },
  ValideEntite: { type: DataTypes.BOOLEAN, field: 'ValideEntite' }
}, {
  tableName: 'V_Entite',
  timestamps: false,
  freezeTableName: true
});

module.exports = VEntite;
