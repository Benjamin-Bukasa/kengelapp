
Object.defineProperty(exports, "__esModule", { value: true });

const {
  Decimal,
  objectEnumValues,
  makeStrictEnum,
  Public,
  getRuntime,
  skip
} = require('./runtime/index-browser.js')


const Prisma = {}

exports.Prisma = Prisma
exports.$Enums = {}

/**
 * Prisma Client JS version: 6.6.0
 * Query Engine version: f676762280b54cd07c770017ed3711ddde35f37a
 */
Prisma.prismaVersion = {
  client: "6.6.0",
  engine: "f676762280b54cd07c770017ed3711ddde35f37a"
}

Prisma.PrismaClientKnownRequestError = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`PrismaClientKnownRequestError is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)};
Prisma.PrismaClientUnknownRequestError = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`PrismaClientUnknownRequestError is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.PrismaClientRustPanicError = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`PrismaClientRustPanicError is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.PrismaClientInitializationError = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`PrismaClientInitializationError is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.PrismaClientValidationError = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`PrismaClientValidationError is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.Decimal = Decimal

/**
 * Re-export of sql-template-tag
 */
Prisma.sql = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`sqltag is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.empty = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`empty is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.join = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`join is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.raw = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`raw is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.validator = Public.validator

/**
* Extensions
*/
Prisma.getExtensionContext = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`Extensions.getExtensionContext is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}
Prisma.defineExtension = () => {
  const runtimeName = getRuntime().prettyName;
  throw new Error(`Extensions.defineExtension is unable to run in this browser environment, or has been bundled for the browser (running in ${runtimeName}).
In case this error is unexpected for you, please report it in https://pris.ly/prisma-prisma-bug-report`,
)}

/**
 * Shorthand utilities for JSON filtering
 */
Prisma.DbNull = objectEnumValues.instances.DbNull
Prisma.JsonNull = objectEnumValues.instances.JsonNull
Prisma.AnyNull = objectEnumValues.instances.AnyNull

Prisma.NullTypes = {
  DbNull: objectEnumValues.classes.DbNull,
  JsonNull: objectEnumValues.classes.JsonNull,
  AnyNull: objectEnumValues.classes.AnyNull
}



/**
 * Enums
 */

exports.Prisma.TransactionIsolationLevel = makeStrictEnum({
  ReadUncommitted: 'ReadUncommitted',
  ReadCommitted: 'ReadCommitted',
  RepeatableRead: 'RepeatableRead',
  Serializable: 'Serializable'
});

exports.Prisma.T_ActiviteParticipantsScalarFieldEnum = {
  IdParticipant: 'IdParticipant',
  IdActiviteFk: 'IdActiviteFk',
  IdApprenantFk: 'IdApprenantFk',
  DateInscription: 'DateInscription',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_ActivitesParascolairesScalarFieldEnum = {
  IdActivite: 'IdActivite',
  NomActivite: 'NomActivite',
  DescriptionActivite: 'DescriptionActivite',
  DateActivite: 'DateActivite',
  HeureDebut: 'HeureDebut',
  HeureFin: 'HeureFin',
  IdEncadrantFk: 'IdEncadrantFk',
  ValideActivite: 'ValideActivite',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_ApprenantScalarFieldEnum = {
  IdApprenant: 'IdApprenant',
  CodeApprenant: 'CodeApprenant',
  DateNaissanceApprenant: 'DateNaissanceApprenant',
  IdParentApprenantFk: 'IdParentApprenantFk',
  IdUserFk: 'IdUserFk',
  ValideApprenant: 'ValideApprenant',
  AgeApprenant: 'AgeApprenant',
  IdNiveauApprenantFk: 'IdNiveauApprenantFk',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_Audit_LogScalarFieldEnum = {
  IdLog: 'IdLog',
  TableName: 'TableName',
  Operation: 'Operation',
  OldData: 'OldData',
  NewData: 'NewData',
  ChangedAt: 'ChangedAt',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_CaisseScalarFieldEnum = {
  IdCaisse: 'IdCaisse',
  IdDeviseFk: 'IdDeviseFk',
  MontantCaisse: 'MontantCaisse',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_CategorieGeneriqueScalarFieldEnum = {
  IdCategorieGenerique: 'IdCategorieGenerique',
  NomCategorieGenerique: 'NomCategorieGenerique',
  ModuleCategorieGenerique: 'ModuleCategorieGenerique',
  ValideCategorieGenerique: 'ValideCategorieGenerique'
};

exports.Prisma.T_CommunicationScalarFieldEnum = {
  IdCommunication: 'IdCommunication',
  IdUserFk: 'IdUserFk',
  IdTypeCommunication: 'IdTypeCommunication',
  ContenuCommunication: 'ContenuCommunication',
  DateCommunication: 'DateCommunication',
  ObsCommunication: 'ObsCommunication',
  ValideCommunication: 'ValideCommunication',
  LectureCommunication: 'LectureCommunication',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_CoursScalarFieldEnum = {
  IdCours: 'IdCours',
  DescriptionCours: 'DescriptionCours',
  IdEnseignantFk: 'IdEnseignantFk',
  ObsCours: 'ObsCours',
  ValideCours: 'ValideCours',
  PonderationCours: 'PonderationCours',
  PointMax: 'PointMax',
  IdNiveauCoursFk: 'IdNiveauCoursFk',
  IdNomCoursFk: 'IdNomCoursFk',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_EmploisTempsScalarFieldEnum = {
  IdEmploisTemps: 'IdEmploisTemps',
  IdNomCoursFk: 'IdNomCoursFk',
  JourSemaine: 'JourSemaine',
  HeureDebut: 'HeureDebut',
  HeureFin: 'HeureFin',
  ObsEmploisTemps: 'ObsEmploisTemps',
  ValideEmploisTemps: 'ValideEmploisTemps',
  IdNiveauFk: 'IdNiveauFk',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_EnseignantScalarFieldEnum = {
  IdEnseignant: 'IdEnseignant',
  IdUserFk: 'IdUserFk',
  IdSpecialiteEnseignantFk: 'IdSpecialiteEnseignantFk',
  SalaireEnseignant: 'SalaireEnseignant',
  DateEmbaucheEnseignant: 'DateEmbaucheEnseignant',
  ValideEnseignant: 'ValideEnseignant',
  CodeEnseignant: 'CodeEnseignant',
  IdDeviseFk: 'IdDeviseFk',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_EntiteScalarFieldEnum = {
  IdEntite: 'IdEntite',
  NomEntite: 'NomEntite',
  PhoneEntite: 'PhoneEntite',
  EmailEntite: 'EmailEntite',
  AdresseEntite: 'AdresseEntite',
  DateCreationEntite: 'DateCreationEntite',
  IdTypeEntiteFk: 'IdTypeEntiteFk',
  ValideEntite: 'ValideEntite'
};

exports.Prisma.T_EvaluationsScalarFieldEnum = {
  IdEvaluation: 'IdEvaluation',
  IdCibleFk: 'IdCibleFk',
  IdEvaluateurFk: 'IdEvaluateurFk',
  NoteEvaluation: 'NoteEvaluation',
  ObsEvaluation: 'ObsEvaluation',
  DateEvaluation: 'DateEvaluation',
  IdTypeEvaluationFk: 'IdTypeEvaluationFk',
  CodeEvaluation: 'CodeEvaluation',
  ValideEvaluation: 'ValideEvaluation',
  IdCoursFk: 'IdCoursFk',
  MaxNoteEvaluation: 'MaxNoteEvaluation',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_GeneriqueScalarFieldEnum = {
  IdGenerique: 'IdGenerique',
  NomGenerique: 'NomGenerique',
  CodeGenerique: 'CodeGenerique',
  ObsGenerique: 'ObsGenerique',
  ValideGenerique: 'ValideGenerique',
  IdCategorieGeneriqueFk: 'IdCategorieGeneriqueFk'
};

exports.Prisma.T_LicenceScalarFieldEnum = {
  IdLicence: 'IdLicence',
  IdEntiteFk: 'IdEntiteFk',
  CleLicence: 'CleLicence',
  DateDebut: 'DateDebut',
  DateFin: 'DateFin',
  IdStatutLicenceFk: 'IdStatutLicenceFk',
  ValideLicence: 'ValideLicence',
  ExpireeLicence: 'ExpireeLicence'
};

exports.Prisma.T_LoginScalarFieldEnum = {
  IdLogin: 'IdLogin',
  IdUserFk: 'IdUserFk',
  IdTypeLoginFk: 'IdTypeLoginFk',
  DateLogin: 'DateLogin',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_PaiementScalarFieldEnum = {
  IdPaiement: 'IdPaiement',
  CodePaiement: 'CodePaiement',
  IdUserFk: 'IdUserFk',
  IdTypePaiementFk: 'IdTypePaiementFk',
  MontantPaiement: 'MontantPaiement',
  IdStatutPaiementFk: 'IdStatutPaiementFk',
  DatePaiement: 'DatePaiement',
  ObsPaiement: 'ObsPaiement',
  ValidePaiement: 'ValidePaiement',
  IdDeviseFk: 'IdDeviseFk',
  IdPayeurFk: 'IdPayeurFk',
  IdTypeMouvementFk: 'IdTypeMouvementFk',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_PresenceScalarFieldEnum = {
  IdPresence: 'IdPresence',
  IdControleurFk: 'IdControleurFk',
  IdControleFk: 'IdControleFk',
  IdStatutPresenceFk: 'IdStatutPresenceFk',
  DatePresence: 'DatePresence',
  ValidePresence: 'ValidePresence',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_SalleScalarFieldEnum = {
  IdSalle: 'IdSalle',
  NomSalle: 'NomSalle',
  CapaciteSalle: 'CapaciteSalle',
  IdEntiteFk: 'IdEntiteFk'
};

exports.Prisma.T_UtilisateursScalarFieldEnum = {
  IdUser: 'IdUser',
  NomUser: 'NomUser',
  PrenomUser: 'PrenomUser',
  EmailUser: 'EmailUser',
  MotdepasseUser: 'MotdepasseUser',
  PhoneUser: 'PhoneUser',
  DatecreationUser: 'DatecreationUser',
  IdRoleFk: 'IdRoleFk',
  ValideUser: 'ValideUser',
  SexeUser: 'SexeUser',
  DateModificationUser: 'DateModificationUser',
  UrlPhoto: 'UrlPhoto',
  IdEntiteFk: 'IdEntiteFk',
  Is_staff: 'Is_staff',
  Is_Admin: 'Is_Admin'
};

exports.Prisma.SortOrder = {
  asc: 'asc',
  desc: 'desc'
};

exports.Prisma.NullableJsonNullValueInput = {
  DbNull: Prisma.DbNull,
  JsonNull: Prisma.JsonNull
};

exports.Prisma.NullsOrder = {
  first: 'first',
  last: 'last'
};

exports.Prisma.QueryMode = {
  default: 'default',
  insensitive: 'insensitive'
};

exports.Prisma.JsonNullValueFilter = {
  DbNull: Prisma.DbNull,
  JsonNull: Prisma.JsonNull,
  AnyNull: Prisma.AnyNull
};


exports.Prisma.ModelName = {
  T_ActiviteParticipants: 'T_ActiviteParticipants',
  T_ActivitesParascolaires: 'T_ActivitesParascolaires',
  T_Apprenant: 'T_Apprenant',
  T_Audit_Log: 'T_Audit_Log',
  T_Caisse: 'T_Caisse',
  T_CategorieGenerique: 'T_CategorieGenerique',
  T_Communication: 'T_Communication',
  T_Cours: 'T_Cours',
  T_EmploisTemps: 'T_EmploisTemps',
  T_Enseignant: 'T_Enseignant',
  T_Entite: 'T_Entite',
  T_Evaluations: 'T_Evaluations',
  T_Generique: 'T_Generique',
  T_Licence: 'T_Licence',
  T_Login: 'T_Login',
  T_Paiement: 'T_Paiement',
  T_Presence: 'T_Presence',
  T_Salle: 'T_Salle',
  T_Utilisateurs: 'T_Utilisateurs'
};

/**
 * This is a stub Prisma Client that will error at runtime if called.
 */
class PrismaClient {
  constructor() {
    return new Proxy(this, {
      get(target, prop) {
        let message
        const runtime = getRuntime()
        if (runtime.isEdge) {
          message = `PrismaClient is not configured to run in ${runtime.prettyName}. In order to run Prisma Client on edge runtime, either:
- Use Prisma Accelerate: https://pris.ly/d/accelerate
- Use Driver Adapters: https://pris.ly/d/driver-adapters
`;
        } else {
          message = 'PrismaClient is unable to run in this browser environment, or has been bundled for the browser (running in `' + runtime.prettyName + '`).'
        }

        message += `
If this is unexpected, please open an issue: https://pris.ly/prisma-prisma-bug-report`

        throw new Error(message)
      }
    })
  }
}

exports.PrismaClient = PrismaClient

Object.assign(exports, Prisma)
