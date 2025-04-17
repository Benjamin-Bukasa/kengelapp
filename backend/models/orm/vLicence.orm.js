const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VLicence = sequelize.define('VLicence', {
  IdLicence: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdLicence' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  IdTypeEntiteFk: { type: DataTypes.INTEGER, field: 'IdTypeEntiteFk' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' },
  CleLicence: { type: DataTypes.STRING, field: 'CleLicence' },
  DateDebut: { type: DataTypes.DATE, field: 'DateDebut' },
  DateFin: { type: DataTypes.DATE, field: 'DateFin' },
  IdStatutLicenceFk: { type: DataTypes.INTEGER, field: 'IdStatutLicenceFk' },
  statut: { type: DataTypes.STRING, field: 'statut' },
  ValideLicence: { type: DataTypes.BOOLEAN, field: 'ValideLicence' },
  ExpireeLicence: { type: DataTypes.BOOLEAN, field: 'ExpireeLicence' }
}, {
  tableName: 'V_Licence',
  timestamps: false,
  freezeTableName: true
});

module.exports = VLicence;
