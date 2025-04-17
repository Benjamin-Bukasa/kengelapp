const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VCours = sequelize.define('VCours', {
  IdCours: { type: DataTypes.INTEGER, field: 'IdCours', primaryKey: true },
  IdNomCoursFk: { type: DataTypes.INTEGER, field: 'IdNomCoursFk' },
  nom_cours: { type: DataTypes.STRING, field: 'nom_cours' },
  PonderationCours: { type: DataTypes.FLOAT, field: 'PonderationCours' },
  PointMax: { type: DataTypes.FLOAT, field: 'PointMax' },
  IdNiveauCoursFk: { type: DataTypes.INTEGER, field: 'IdNiveauCoursFk' },
  niveau_cours: { type: DataTypes.STRING, field: 'niveau_cours' },
  DescriptionCours: { type: DataTypes.STRING, field: 'DescriptionCours' },
  IdEnseignantFk: { type: DataTypes.INTEGER, field: 'IdEnseignantFk' },
  nom_enseignant: { type: DataTypes.STRING, field: 'nom_enseignant' },
  ObsCours: { type: DataTypes.STRING, field: 'ObsCours' },
  ValideCours: { type: DataTypes.BOOLEAN, field: 'ValideCours' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' },
}, {
  tableName: 'V_Cours',
  timestamps: false,
  freezeTableName: true
});

module.exports = VCours;
