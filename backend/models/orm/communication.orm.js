// backend/models/orm/communication.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Entite = require('./entite.orm');
const Generique = require('./generique.orm');
const Utilisateur = require('./utilisateurs.orm');

const Communication = sequelize.define('Communication', {
  IdCommunication: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdCommunication'},
  IdUserFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdUserFk'},
  IdTypeCommunication: {type: DataTypes.INTEGER,allowNull: true,field: 'IdTypeCommunication' },
  ContenuCommunication: {type: DataTypes.TEXT,field: 'ContenuCommunication'},
  DateCommunication: {type: DataTypes.DATE,allowNull: false,defaultValue: DataTypes.NOW,field: 'DateCommunication'},
  ObsCommunication: {type: DataTypes.TEXT,field: 'ObsCommunication'},
  ValideCommunication: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: true,field: 'ValideCommunication'},
  LectureCommunication: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: false,field: 'LectureCommunication'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Communication',
  timestamps: false,
  freezeTableName: true,
});

// Associations
Communication.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Communication.belongsTo(Generique, { foreignKey: 'IdTypeCommunication', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Communication.belongsTo(Utilisateur, { foreignKey: 'IdUserFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Communication;
