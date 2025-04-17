// backend/models/orm/presence.orm.js

const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Utilisateurs = require('./utilisateurs.orm');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');

const Presence = sequelize.define('Presence', {
  IdPresence: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,allowNull: false,field: 'IdPresence'},
  IdControleurFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdControleurFk'},
  IdControleFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdControleFk'},
  IdStatutPresenceFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdStatutPresenceFk'},
  DatePresence: {type: DataTypes.DATEONLY,allowNull: false,field: 'DatePresence'},
  ValidePresence: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: true,field: 'ValidePresence'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Presence',
  timestamps: false,
  freezeTableName: true,
});

// Associations
Presence.belongsTo(Utilisateurs, { foreignKey: 'IdControleFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Presence.belongsTo(Utilisateurs, { foreignKey: 'IdControleurFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Presence.belongsTo(Generique, { foreignKey: 'IdStatutPresenceFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Presence.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Presence;
