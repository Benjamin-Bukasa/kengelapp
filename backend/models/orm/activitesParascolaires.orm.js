
  // backend/models/orm/activitesParascolaires.orm.js

const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Enseignant = require('./enseignant.orm');
const Entite = require('./entite.orm');

const ActivitesParascolaires = sequelize.define('ActivitesParascolaires', {
  IdActivite: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,allowNull: false,field: 'IdActivite' },
  NomActivite: {type: DataTypes.STRING(100),allowNull: false,field: 'NomActivite'},
  DescriptionActivite: {type: DataTypes.TEXT,allowNull: true,field: 'DescriptionActivite'},
  DateActivite: {type: DataTypes.DATEONLY,allowNull: false,field: 'DateActivite'},
  HeureDebut: {type: DataTypes.TIME,allowNull: true,field: 'HeureDebut'},
  HeureFin: {type: DataTypes.TIME,allowNull: true,field: 'HeureFin'},
  IdEncadrantFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEncadrantFk'},
  ValideActivite: {type: DataTypes.BOOLEAN,defaultValue: true,field: 'ValideActivite'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_ActivitesParascolaires',
  timestamps: false
});

// Associations
ActivitesParascolaires.belongsTo(Enseignant, { foreignKey: 'IdEncadrantFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});
ActivitesParascolaires.belongsTo(Entite, {foreignKey: 'IdEntiteFk',onUpdate: 'CASCADE', onDelete: 'CASCADE'});

module.exports = ActivitesParascolaires;
