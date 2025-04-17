const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VEnseignantsCours = sequelize.define('VEnseignantsCours', {
  IdUserFk: { type: DataTypes.INTEGER, field: 'IdUserFk' },
  IdEnseignant: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdEnseignant' },
  nom_enseignant: { type: DataTypes.STRING, field: 'nom_enseignant' },
  IdSpecialiteEnseignantFk: { type: DataTypes.INTEGER, field: 'IdSpecialiteEnseignantFk' },
  specialite: { type: DataTypes.STRING, field: 'specialite' },
  IdCours: { type: DataTypes.INTEGER, field: 'IdCours' },
  nom_cours: { type: DataTypes.STRING, field: 'nom_cours' },
  DescriptionCours: { type: DataTypes.TEXT, field: 'DescriptionCours' },
  ValideCours: { type: DataTypes.BOOLEAN, field: 'ValideCours' },
  ObsCours: { type: DataTypes.TEXT, field: 'ObsCours' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_EnseignantsCours',
  timestamps: false,
  freezeTableName: true
});

module.exports = VEnseignantsCours;
