// backend/models/orm/evaluations.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Utilisateurs = require('./utilisateurs.orm');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');

const Evaluations = sequelize.define('Evaluations', {
  IdEvaluation: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdEvaluation'},
  IdCibleFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdCibleFk'},
  IdEvaluateurFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEvaluateurFk'},
  NoteEvaluation: {type: DataTypes.DECIMAL,allowNull: true,field: 'NoteEvaluation'},
  ObsEvaluation: {type: DataTypes.TEXT,allowNull: true,field: 'ObsEvaluation'},
  DateEvaluation: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,field: 'DateEvaluation'},
  IdTypeEvaluationFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdTypeEvaluationFk'},
  CodeEvaluation: {type: DataTypes.TEXT,allowNull: true,field: 'CodeEvaluation'},
  ValideEvaluation: {type: DataTypes.BOOLEAN,defaultValue: true,field: 'ValideEvaluation'},
  IdCoursFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdCoursFk' },
  MaxNoteEvaluation: {type: DataTypes.INTEGER,allowNull: true,field: 'MaxNoteEvaluation'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Evaluations',
  timestamps: false,
  freezeTableName: true,
});

// Associations
Evaluations.belongsTo(Utilisateurs, { foreignKey: 'IdCibleFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Evaluations.belongsTo(Utilisateurs, { foreignKey: 'IdEvaluateurFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Evaluations.belongsTo(Generique, { foreignKey: 'IdTypeEvaluationFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Evaluations.belongsTo(Generique, { foreignKey: 'IdCoursFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Evaluations.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Evaluations;
