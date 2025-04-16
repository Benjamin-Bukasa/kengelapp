// backend/models/orm/auditLog.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Entite = require('./entite.orm');

const AuditLog = sequelize.define('AuditLog', {
  IdLog: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdLog'},
  TableName: {type: DataTypes.TEXT,allowNull: true,field: 'TableName' },
  Operation: {type: DataTypes.TEXT,allowNull: true,field: 'Operation'},
  OldData: {type: DataTypes.JSONB, allowNull: true, field: 'OldData' },
  NewData: {type: DataTypes.JSONB,allowNull: true, field: 'NewData' },
  ChangedAt: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,field: 'ChangedAt'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Audit_Log',
  timestamps: false
});

// Associations
AuditLog.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = AuditLog;
