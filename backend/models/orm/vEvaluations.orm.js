const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VEvaluations = sequelize.define('VEvaluations', {
  DateEvaluation: { type: DataTypes.DATE, field: 'DateEvaluation' },
  IdEvaluation: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdEvaluation' },
  type_evaluation: { type: DataTypes.STRING, field: 'type_evaluation' },
  CodeEvaluation: { type: DataTypes.STRING, field: 'CodeEvaluation' },
  nom_apprenant: { type: DataTypes.STRING, field: 'nom_apprenant' },
  nom_evaluateur: { type: DataTypes.STRING, field: 'nom_evaluateur' },
  NoteEvaluation: { type: DataTypes.FLOAT, field: 'NoteEvaluation' },
  nom_cours: { type: DataTypes.STRING, field: 'nom_cours' },
  ObsEvaluation: { type: DataTypes.STRING, field: 'ObsEvaluation' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_Evaluations',
  timestamps: false,
  freezeTableName: true
});

module.exports = VEvaluations;
