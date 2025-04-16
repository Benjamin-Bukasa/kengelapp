-- Ce script a été généré par l'outil ERD (Éditeur de diagramme entité-association) dans pgAdmin 4.
-- Si vous trouvez des bogues, veuillez les signaler sur https://github.com/pgadmin-org/pgadmin4/issues/new/choose. Merci de préciser les étapes de reproduction.
BEGIN;


CREATE TABLE IF NOT EXISTS public."T_ActiviteParticipants"
(
    "IdParticipant" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdActiviteFk" integer NOT NULL,
    "IdApprenantFk" integer NOT NULL,
    "DateInscription" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdEntiteFk" integer,
    CONSTRAINT "T_ActiviteParticipants_pkey" PRIMARY KEY ("IdParticipant")
);

CREATE TABLE IF NOT EXISTS public."T_ActivitesParascolaires"
(
    "IdActivite" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "NomActivite" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "DescriptionActivite" text COLLATE pg_catalog."default",
    "DateActivite" date NOT NULL,
    "HeureDebut" time without time zone,
    "HeureFin" time without time zone,
    "IdEncadrantFk" integer,
    "ValideActivite" boolean DEFAULT true,
    "IdEntiteFk" integer,
    CONSTRAINT "T_ActivitesParascolaires_pkey" PRIMARY KEY ("IdActivite")
);

CREATE TABLE IF NOT EXISTS public."T_Apprenant"
(
    "IdApprenant" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "CodeApprenant" character varying(25) COLLATE pg_catalog."default",
    "DateNaissanceApprenant" date,
    "IdParentApprenantFk" integer,
    "IdUserFk" integer,
    "ValideApprenant" boolean NOT NULL DEFAULT true,
    "AgeApprenant" integer,
    "IdNiveauApprenantFk" integer,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdApprenant" PRIMARY KEY ("IdApprenant"),
    CONSTRAINT "T_Enseignes_IdUserFk_key" UNIQUE ("IdUserFk")
);

CREATE TABLE IF NOT EXISTS public."T_Audit_Log"
(
    "IdLog" serial NOT NULL,
    "TableName" text COLLATE pg_catalog."default",
    "Operation" text COLLATE pg_catalog."default",
    "OldData" jsonb,
    "NewData" jsonb,
    "ChangedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdEntiteFk" integer,
    CONSTRAINT "T_Audit_Log_pkey" PRIMARY KEY ("IdLog")
);

CREATE TABLE IF NOT EXISTS public."T_Caisse"
(
    "IdCaisse" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdDeviseFk" integer NOT NULL,
    "MontantCaisse" numeric(10, 2) DEFAULT 0,
    "IdEntiteFk" integer,
    CONSTRAINT "T_Caisse_pkey" PRIMARY KEY ("IdCaisse"),
    CONSTRAINT "UQ_IdDeviseFk" UNIQUE ("IdDeviseFk")
);

CREATE TABLE IF NOT EXISTS public."T_CategorieGenerique"
(
    "IdCategorieGenerique" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "NomCategorieGenerique" character varying(25) COLLATE pg_catalog."default" NOT NULL,
    "ModuleCategorieGenerique" character varying(100) COLLATE pg_catalog."default",
    "ValideCategorieGenerique" boolean NOT NULL DEFAULT true,
    CONSTRAINT "Pk_IdCategorieGenerique" PRIMARY KEY ("IdCategorieGenerique")
);

CREATE TABLE IF NOT EXISTS public."T_Communication"
(
    "IdCommunication" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdUserFk" integer,
    "IdTypeCommunication" integer,
    "ContenuCommunication" text COLLATE pg_catalog."default",
    "DateCommunication" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ObsCommunication" text COLLATE pg_catalog."default",
    "ValideCommunication" boolean NOT NULL DEFAULT true,
    "LectureCommunication" boolean NOT NULL DEFAULT false,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdCommunication" PRIMARY KEY ("IdCommunication")
);

CREATE TABLE IF NOT EXISTS public."T_Cours"
(
    "IdCours" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "DescriptionCours" text COLLATE pg_catalog."default",
    "IdEnseignantFk" integer,
    "ObsCours" text COLLATE pg_catalog."default",
    "ValideCours" boolean NOT NULL DEFAULT true,
    "PonderationCours" integer,
    "PointMax" integer NOT NULL,
    "IdNiveauCoursFk" integer,
    "IdNomCoursFk" integer,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdCours" PRIMARY KEY ("IdCours")
);

CREATE TABLE IF NOT EXISTS public."T_EmploisTemps"
(
    "IdEmploisTemps" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdNomCoursFk" integer,
    "JourSemaine" text COLLATE pg_catalog."default",
    "HeureDebut" time without time zone,
    "HeureFin" time without time zone,
    "ObsEmploisTemps" text COLLATE pg_catalog."default",
    "ValideEmploisTemps" boolean DEFAULT true,
    "IdNiveauFk" integer,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdEmploisTemps" PRIMARY KEY ("IdEmploisTemps")
);

CREATE TABLE IF NOT EXISTS public."T_Enseignant"
(
    "IdEnseignant" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdUserFk" integer,
    "IdSpecialiteEnseignantFk" integer,
    "SalaireEnseignant" integer,
    "DateEmbaucheEnseignant" date,
    "ValideEnseignant" boolean NOT NULL DEFAULT true,
    "CodeEnseignant" character varying(25) COLLATE pg_catalog."default",
    "IdDeviseFk" integer NOT NULL,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_Enseignant" PRIMARY KEY ("IdEnseignant")
);

CREATE TABLE IF NOT EXISTS public."T_Entite"
(
    "IdEntite" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "NomEntite" text COLLATE pg_catalog."default" NOT NULL,
    "PhoneEntite" text COLLATE pg_catalog."default",
    "EmailEntite" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "AdresseEntite" text COLLATE pg_catalog."default",
    "DateCreationEntite" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdTypeEntiteFk" integer,
    "ValideEntite" boolean DEFAULT true,
    CONSTRAINT "Pk_IdEntite" PRIMARY KEY ("IdEntite"),
    CONSTRAINT "T_Entite_EmailEntite_key" UNIQUE ("EmailEntite"),
    CONSTRAINT "T_Entite_PhoneEntite_key" UNIQUE ("PhoneEntite")
);

CREATE TABLE IF NOT EXISTS public."T_Evaluations"
(
    "IdEvaluation" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdCibleFk" integer,
    "IdEvaluateurFk" integer,
    "NoteEvaluation" numeric,
    "ObsEvaluation" text COLLATE pg_catalog."default",
    "DateEvaluation" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdTypeEvaluationFk" integer,
    "CodeEvaluation" text COLLATE pg_catalog."default",
    "ValideEvaluation" boolean NOT NULL DEFAULT true,
    "IdCoursFk" integer,
    "MaxNoteEvaluation" integer,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdEvaluation" PRIMARY KEY ("IdEvaluation")
);

CREATE TABLE IF NOT EXISTS public."T_Generique"
(
    "IdGenerique" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "NomGenerique" character varying(25) COLLATE pg_catalog."default" NOT NULL,
    "CodeGenerique" character varying(25) COLLATE pg_catalog."default" NOT NULL,
    "ObsGenerique" character varying COLLATE pg_catalog."default",
    "ValideGenerique" boolean NOT NULL DEFAULT true,
    "IdCategorieGeneriqueFk" integer,
    CONSTRAINT "Pk_IdGenerique" PRIMARY KEY ("IdGenerique")
);

CREATE TABLE IF NOT EXISTS public."T_Licence"
(
    "IdLicence" integer NOT NULL,
    "IdEntiteFk" integer NOT NULL,
    "CleLicence" uuid DEFAULT gen_random_uuid(),
    "DateDebut" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "DateFin" timestamp without time zone NOT NULL,
    "IdStatutLicenceFk" integer NOT NULL,
    "ValideLicence" boolean DEFAULT true,
    "ExpireeLicence" boolean DEFAULT false,
    CONSTRAINT "Pk_IdLicence" PRIMARY KEY ("IdLicence")
);

CREATE TABLE IF NOT EXISTS public."T_Login"
(
    "IdLogin" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdUserFk" integer NOT NULL,
    "IdTypeLoginFk" integer NOT NULL,
    "DateLogin" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdLogin" PRIMARY KEY ("IdLogin")
);

CREATE TABLE IF NOT EXISTS public."T_Paiement"
(
    "IdPaiement" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "CodePaiement" character(25) COLLATE pg_catalog."default",
    "IdUserFk" integer NOT NULL,
    "IdTypePaiementFk" integer NOT NULL,
    "MontantPaiement" numeric(10, 2) NOT NULL,
    "IdStatutPaiementFk" integer,
    "DatePaiement" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "ObsPaiement" text COLLATE pg_catalog."default",
    "ValidePaiement" boolean NOT NULL DEFAULT true,
    "IdDeviseFk" integer NOT NULL,
    "IdPayeurFk" integer,
    "IdTypeMouvementFk" integer,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdPaiement" PRIMARY KEY ("IdPaiement")
);

CREATE TABLE IF NOT EXISTS public."T_Paiement_Archive"
(
    "IdPaiement" integer,
    "CodePaiement" character(25) COLLATE pg_catalog."default",
    "IdUserFk" integer,
    "IdTypePaiementFk" integer,
    "MontantPaiement" numeric(10, 2),
    "IdStatutPaiementFk" integer,
    "DatePaiement" timestamp without time zone,
    "ObsPaiement" text COLLATE pg_catalog."default",
    "ValidePaiement" boolean,
    "IdDeviseFk" integer,
    "IdPayeurFk" integer,
    "IdTypeMouvementFk" integer,
    "DateArchivage" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdEntiteFk" integer
);

CREATE TABLE IF NOT EXISTS public."T_Presence"
(
    "IdPresence" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "IdControleurFk" integer,
    "IdControleFk" integer,
    "IdStatutPresenceFk" integer NOT NULL,
    "DatePresence" date NOT NULL,
    "ValidePresence" boolean NOT NULL DEFAULT true,
    "IdEntiteFk" integer,
    CONSTRAINT "Pk_IdPresence" PRIMARY KEY ("IdPresence")
);

CREATE TABLE IF NOT EXISTS public."T_Salle"
(
    "IdSalle" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "NomSalle" character varying(25) COLLATE pg_catalog."default" NOT NULL,
    "CapaciteSalle" numeric NOT NULL,
    "IdEntiteFk" integer,
    CONSTRAINT "T_Salle_pkey" PRIMARY KEY ("IdSalle")
);

CREATE TABLE IF NOT EXISTS public."T_Utilisateurs"
(
    "IdUser" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "NomUser" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "PrenomUser" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "EmailUser" character varying(150) COLLATE pg_catalog."default" NOT NULL,
    "MotdepasseUser" text COLLATE pg_catalog."default" NOT NULL,
    "PhoneUser" character varying(20) COLLATE pg_catalog."default",
    "DatecreationUser" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdRoleFk" integer,
    "ValideUser" boolean NOT NULL DEFAULT true,
    "SexeUser" character(1) COLLATE pg_catalog."default" NOT NULL,
    "DateModificationUser" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UrlPhoto" text COLLATE pg_catalog."default",
    "IdEntiteFk" integer,
    "Is_staff" boolean NOT NULL DEFAULT false,
    "Is_Admin" boolean NOT NULL DEFAULT false,
    CONSTRAINT "Pk_IdUser" PRIMARY KEY ("IdUser"),
    CONSTRAINT utilisateurs_emailuser_key UNIQUE ("EmailUser")
);

ALTER TABLE IF EXISTS public."T_ActiviteParticipants"
    ADD CONSTRAINT "Fk_IdActivite" FOREIGN KEY ("IdActiviteFk")
    REFERENCES public."T_ActivitesParascolaires" ("IdActivite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public."T_ActiviteParticipants"
    ADD CONSTRAINT "Fk_IdApprenant" FOREIGN KEY ("IdApprenantFk")
    REFERENCES public."T_Apprenant" ("IdApprenant") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public."T_ActiviteParticipants"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public."T_ActivitesParascolaires"
    ADD CONSTRAINT "Fk_IdEncadrant" FOREIGN KEY ("IdEncadrantFk")
    REFERENCES public."T_Enseignant" ("IdEnseignant") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_ActivitesParascolaires"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public."T_Apprenant"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Apprenant"
    ADD CONSTRAINT "Fk_IdParentApprenant" FOREIGN KEY ("IdParentApprenantFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_apprenant_parent
    ON public."T_Apprenant"("IdParentApprenantFk");


ALTER TABLE IF EXISTS public."T_Apprenant"
    ADD CONSTRAINT "Fk_IdUser" FOREIGN KEY ("IdUserFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS "T_Enseignes_IdUserFk_key"
    ON public."T_Apprenant"("IdUserFk");


ALTER TABLE IF EXISTS public."T_Apprenant"
    ADD CONSTRAINT "Fk_NiveauApprenant" FOREIGN KEY ("IdNiveauApprenantFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Audit_Log"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_audit_log_entite
    ON public."T_Audit_Log"("IdEntiteFk");


ALTER TABLE IF EXISTS public."T_Caisse"
    ADD CONSTRAINT "Fk_IdDevise" FOREIGN KEY ("IdDeviseFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS "UQ_IdDeviseFk"
    ON public."T_Caisse"("IdDeviseFk");


ALTER TABLE IF EXISTS public."T_Caisse"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Communication"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Communication"
    ADD CONSTRAINT "Fk_IdTypeCommunication" FOREIGN KEY ("IdTypeCommunication")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Communication"
    ADD CONSTRAINT "Fk_IdUser" FOREIGN KEY ("IdUserFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Cours"
    ADD CONSTRAINT "Fk_IdEnseignant" FOREIGN KEY ("IdEnseignantFk")
    REFERENCES public."T_Enseignant" ("IdEnseignant") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_cours_enseignant
    ON public."T_Cours"("IdEnseignantFk");


ALTER TABLE IF EXISTS public."T_Cours"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Cours"
    ADD CONSTRAINT "Fk_IdNiveauCours" FOREIGN KEY ("IdNiveauCoursFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Cours"
    ADD CONSTRAINT "Fk_IdNomCours" FOREIGN KEY ("IdNomCoursFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_EmploisTemps"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_emplois_temps_entite
    ON public."T_EmploisTemps"("IdEntiteFk");


ALTER TABLE IF EXISTS public."T_EmploisTemps"
    ADD CONSTRAINT "Fk_IdNiveau" FOREIGN KEY ("IdNiveauFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_emplois_temps_niveau
    ON public."T_EmploisTemps"("IdNiveauFk");


ALTER TABLE IF EXISTS public."T_EmploisTemps"
    ADD CONSTRAINT "Fk_IdNomCours" FOREIGN KEY ("IdNomCoursFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_emplois_temps_nom_cours
    ON public."T_EmploisTemps"("IdNomCoursFk");


ALTER TABLE IF EXISTS public."T_Enseignant"
    ADD CONSTRAINT "Fk_IdDevise" FOREIGN KEY ("IdDeviseFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Enseignant"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Enseignant"
    ADD CONSTRAINT "Fk_IdUser" FOREIGN KEY ("IdUserFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_enseignant_user
    ON public."T_Enseignant"("IdUserFk");


ALTER TABLE IF EXISTS public."T_Enseignant"
    ADD CONSTRAINT "Fk_SpecialiteEnseignant" FOREIGN KEY ("IdSpecialiteEnseignantFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_enseignant_specialite
    ON public."T_Enseignant"("IdSpecialiteEnseignantFk");


ALTER TABLE IF EXISTS public."T_Entite"
    ADD CONSTRAINT "Fk_TypeEntite" FOREIGN KEY ("IdTypeEntiteFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdCibleFk" FOREIGN KEY ("IdCibleFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_evaluations_cible
    ON public."T_Evaluations"("IdCibleFk");


ALTER TABLE IF EXISTS public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdCours" FOREIGN KEY ("IdCoursFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdEvaluateur" FOREIGN KEY ("IdEvaluateurFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_evaluations_evaluateur
    ON public."T_Evaluations"("IdEvaluateurFk");


ALTER TABLE IF EXISTS public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdTypeEvaluation" FOREIGN KEY ("IdTypeEvaluationFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_evaluations_type
    ON public."T_Evaluations"("IdTypeEvaluationFk");


ALTER TABLE IF EXISTS public."T_Generique"
    ADD CONSTRAINT "Fk_IdCategorieGenerique" FOREIGN KEY ("IdCategorieGeneriqueFk")
    REFERENCES public."T_CategorieGenerique" ("IdCategorieGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Licence"
    ADD CONSTRAINT "Fk_Entite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_licence_entite
    ON public."T_Licence"("IdEntiteFk");


ALTER TABLE IF EXISTS public."T_Licence"
    ADD CONSTRAINT "Fk_StatutLicence" FOREIGN KEY ("IdStatutLicenceFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_licence_statut
    ON public."T_Licence"("IdStatutLicenceFk");


ALTER TABLE IF EXISTS public."T_Login"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Login"
    ADD CONSTRAINT "Fk_IdTypeLogin" FOREIGN KEY ("IdTypeLoginFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Login"
    ADD CONSTRAINT "Fk_IdUserFk" FOREIGN KEY ("IdUserFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Paiement"
    ADD CONSTRAINT "Fk_IdDevise" FOREIGN KEY ("IdDeviseFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_paiement_devise
    ON public."T_Paiement"("IdDeviseFk");


ALTER TABLE IF EXISTS public."T_Paiement"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public."T_Paiement"
    ADD CONSTRAINT "Fk_IdPayeurFk" FOREIGN KEY ("IdPayeurFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Paiement"
    ADD CONSTRAINT "Fk_IdStatut" FOREIGN KEY ("IdStatutPaiementFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_paiement_statut
    ON public."T_Paiement"("IdStatutPaiementFk");


ALTER TABLE IF EXISTS public."T_Paiement"
    ADD CONSTRAINT "Fk_IdTypeMouvement" FOREIGN KEY ("IdTypeMouvementFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Paiement"
    ADD CONSTRAINT "Fk_IdTypePaiement" FOREIGN KEY ("IdTypePaiementFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Paiement"
    ADD CONSTRAINT "Fk_IdUserFk" FOREIGN KEY ("IdUserFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_paiement_user
    ON public."T_Paiement"("IdUserFk");


ALTER TABLE IF EXISTS public."T_Paiement_Archive"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Presence"
    ADD CONSTRAINT "Fk_IdControle" FOREIGN KEY ("IdControleFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_presence_user
    ON public."T_Presence"("IdControleFk");


ALTER TABLE IF EXISTS public."T_Presence"
    ADD CONSTRAINT "Fk_IdControleur" FOREIGN KEY ("IdControleurFk")
    REFERENCES public."T_Utilisateurs" ("IdUser") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Presence"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Presence"
    ADD CONSTRAINT "Fk_IdStatutPresence" FOREIGN KEY ("IdStatutPresenceFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_fk_presence_statut
    ON public."T_Presence"("IdStatutPresenceFk");


ALTER TABLE IF EXISTS public."T_Salle"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Utilisateurs"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk")
    REFERENCES public."T_Entite" ("IdEntite") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;


ALTER TABLE IF EXISTS public."T_Utilisateurs"
    ADD CONSTRAINT "Fk_RoleFk" FOREIGN KEY ("IdRoleFk")
    REFERENCES public."T_Generique" ("IdGenerique") MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS "fki_Fk_RoleFk"
    ON public."T_Utilisateurs"("IdRoleFk");

END;