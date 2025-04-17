// backend/models/orm/oractiviteParticipants.orm.js

const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const ActivitesParascolaires = require('./activitesParascolaires.orm');
const Apprenant = require('./apprenant.orm');
const Entite = require('./entite.orm');

const ActiviteParticipants = sequelize.define('ActiviteParticipants', {
  IdParticipant: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,allowNull: false,field: 'IdParticipant'},
  IdActiviteFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdActiviteFk'},
  IdApprenantFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdApprenantFk'},
  DateInscription: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,field: 'DateInscription'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_ActiviteParticipants',
  timestamps: false,
  freezeTableName: true,
});

// Associations
ActiviteParticipants.belongsTo(ActivitesParascolaires, {foreignKey: 'IdActiviteFk',onUpdate: 'CASCADE',onDelete: 'CASCADE'});
ActiviteParticipants.belongsTo(Apprenant, {foreignKey: 'IdApprenantFk',onUpdate: 'CASCADE',onDelete: 'CASCADE'});
ActiviteParticipants.belongsTo(Entite, {foreignKey: 'IdEntiteFk',onUpdate: 'CASCADE',onDelete: 'CASCADE'});

module.exports = ActiviteParticipants;
