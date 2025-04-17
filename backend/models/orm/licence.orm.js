// backend/models/orm/licence.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Entite = require('./entite.orm');
const Generique = require('./generique.orm');

const Licence = sequelize.define('Licence', {
  IdLicence: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: false,field: 'IdLicence'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdEntiteFk'},
  CleLicence: {type: DataTypes.UUID,defaultValue: DataTypes.UUIDV4,field: 'CleLicence'},
  DateDebut: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,field: 'DateDebut'},
  DateFin: {type: DataTypes.DATE,allowNull: false,field: 'DateFin'},
  IdStatutLicenceFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdStatutLicenceFk'},
  ValideLicence: {type: DataTypes.BOOLEAN,defaultValue: true,field: 'ValideLicence'},
  ExpireeLicence: {type: DataTypes.BOOLEAN,defaultValue: false,field: 'ExpireeLicence'}
}, 
{
  tableName: 'T_Licence',
  timestamps: false,
  freezeTableName: true,
});

// Associations
Licence.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Licence.belongsTo(Generique, { foreignKey: 'IdStatutLicenceFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Licence;
