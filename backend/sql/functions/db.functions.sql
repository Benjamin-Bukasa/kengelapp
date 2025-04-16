-- FUNCTION: public.archive_paiements()

-- DROP FUNCTION IF EXISTS public.archive_paiements();

CREATE OR REPLACE FUNCTION public.archive_paiements()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
 -- Archiver les paiements de plus de 2 ans
BEGIN
  INSERT INTO "T_Paiement_Archive"
  SELECT *, NOW() FROM "T_Paiement" 
  WHERE "DatePaiement" < NOW() - INTERVAL '2 years';
  -- Supprimer les paiements archivés
  DELETE FROM "T_Paiement" WHERE "DatePaiement" < NOW() - INTERVAL '2 years';
  RETURN NULL;
END;
$BODY$;

ALTER FUNCTION public.archive_paiements()
    OWNER TO postgres;

COMMENT ON FUNCTION public.archive_paiements()
    IS 'Archiver les paiements de plus de 2 ans';

-- FUNCTION: public.audit_log_function()

-- DROP FUNCTION IF EXISTS public.audit_log_function();

CREATE OR REPLACE FUNCTION public.audit_log_function()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    entite_id INTEGER;
BEGIN
    -- Récupération de l'IdEntiteFk si la table concernée en possède une
    SELECT CASE 
        WHEN TG_OP IN ('DELETE', 'UPDATE') THEN OLD."IdEntiteFk"
        WHEN TG_OP = 'INSERT' THEN NEW."IdEntiteFk"
        ELSE NULL 
    END INTO entite_id
    FROM (SELECT 1) AS dummy  -- Hack pour éviter les erreurs si la colonne n'existe pas
    WHERE EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = TG_TABLE_NAME AND column_name = 'IdEntiteFk');
    
    -- Insertion dans T_Audit_Log
    INSERT INTO public."T_Audit_Log" ("TableName", "Operation", "OldData", "NewData", "ChangedAt", "IdEntiteFk")
    VALUES (
        TG_TABLE_NAME,  -- Nom de la table modifiée
        TG_OP,          -- Type d’opération (INSERT, UPDATE, DELETE)
        CASE WHEN TG_OP IN ('DELETE', 'UPDATE') THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
        NOW(),          -- Date et heure de modification
        entite_id       -- IdEntiteFk récupéré
    );
    
    RETURN NULL;
END;
$BODY$;

ALTER FUNCTION public.audit_log_function()
    OWNER TO postgres;

COMMENT ON FUNCTION public.audit_log_function()
    IS 'Capture les modifications des tables avec gestion de IdEntiteFk si disponible.';

-- FUNCTION: public.calculate_age_apprenant()

-- DROP FUNCTION IF EXISTS public.calculate_age_apprenant();

CREATE OR REPLACE FUNCTION public.calculate_age_apprenant()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    NEW."AgeApprenant" := DATE_PART('year', AGE(NEW."DateNaissanceApprenant"));
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.calculate_age_apprenant()
    OWNER TO postgres;

-- FUNCTION: public.format_phone_number()

-- DROP FUNCTION IF EXISTS public.format_phone_number();

CREATE OR REPLACE FUNCTION public.format_phone_number()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    NEW."PhoneUser" := regexp_replace(NEW."PhoneUser", '[^0-9]', '', 'g');
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.format_phone_number()
    OWNER TO postgres;

-- FUNCTION: public.gestion_caisse_on_paiement()

-- DROP FUNCTION IF EXISTS public.gestion_caisse_on_paiement();

CREATE OR REPLACE FUNCTION public.gestion_caisse_on_paiement()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    montant_old NUMERIC := 0;
    montant_new NUMERIC := 0;
BEGIN
    -- 🔥 Cas d'un paiement supprimé (DELETE) : On retire son montant de la caisse
    IF TG_OP = 'DELETE' THEN
        IF OLD."IdStatutPaiementFk" = 21 
        AND OLD."IdTypeMouvementFk" IN (80, 81) 
        AND OLD."IdDeviseFk" IN (36, 37) THEN
            
            -- Déterminer l'ancien montant à soustraire
            montant_old := CASE 
                WHEN OLD."IdTypeMouvementFk" = 81 THEN -OLD."MontantPaiement" -- Retirer une entrée
                ELSE OLD."MontantPaiement" -- Rendre une sortie positive pour l'annuler
            END;

            -- Supprimer l'impact de ce paiement sur la caisse
            UPDATE public."T_Caisse"
            SET "MontantCaisse" = "MontantCaisse" + montant_old
            WHERE "IdDeviseFk" = OLD."IdDeviseFk" AND "IdEntiteFk" = OLD."IdEntiteFk";
        END IF;
    END IF;

    -- 🔥 Cas d'un paiement inséré (INSERT) ou mis à jour (UPDATE)
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Vérifier si le paiement est validé et concerne un type de mouvement et une devise définis
        IF (NEW."IdStatutPaiementFk" = 21) 
        AND (NEW."IdTypeMouvementFk" IN (80, 81)) 
        AND (NEW."IdDeviseFk" IN (36, 37)) THEN

            -- Déterminer le nouveau montant à ajouter/soustraire
            montant_new := CASE 
                WHEN NEW."IdTypeMouvementFk" = 81 THEN NEW."MontantPaiement" -- Entrée
                ELSE -NEW."MontantPaiement" -- Sortie
            END;

            -- 🔥 Gestion des mises à jour (UPDATE) : Annuler l'ancienne valeur et appliquer la nouvelle
            IF TG_OP = 'UPDATE' THEN
                montant_old := CASE 
                    WHEN OLD."IdTypeMouvementFk" = 81 THEN -OLD."MontantPaiement"
                    ELSE OLD."MontantPaiement"
                END;

                -- Si la devise ou l'entité change, ajuster l'ancienne et la nouvelle caisse séparément
                IF OLD."IdDeviseFk" <> NEW."IdDeviseFk" OR OLD."IdEntiteFk" <> NEW."IdEntiteFk" THEN
                    -- Enlever l'ancien montant de l'ancienne caisse
                    UPDATE public."T_Caisse"
                    SET "MontantCaisse" = "MontantCaisse" + montant_old
                    WHERE "IdDeviseFk" = OLD."IdDeviseFk" AND "IdEntiteFk" = OLD."IdEntiteFk";

                    -- Ajouter le nouveau montant dans la nouvelle caisse
                    montant_old := 0; -- On évite de double soustraire l'ancien montant
                END IF;
            END IF;

            -- 🔥 Vérifier si la caisse pour cette entité et devise existe déjà
            IF EXISTS (SELECT 1 FROM public."T_Caisse" WHERE "IdDeviseFk" = NEW."IdDeviseFk" AND "IdEntiteFk" = NEW."IdEntiteFk") THEN
                -- Mise à jour du montant de la caisse
                UPDATE public."T_Caisse"
                SET "MontantCaisse" = "MontantCaisse" + montant_old + montant_new
                WHERE "IdDeviseFk" = NEW."IdDeviseFk" AND "IdEntiteFk" = NEW."IdEntiteFk";
            ELSE
                -- Si la caisse n'existe pas encore pour cette entité et devise, créer une nouvelle ligne
                INSERT INTO public."T_Caisse" ("IdDeviseFk", "MontantCaisse", "IdEntiteFk")
                VALUES (NEW."IdDeviseFk", montant_new, NEW."IdEntiteFk");
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.gestion_caisse_on_paiement()
    OWNER TO postgres;

COMMENT ON FUNCTION public.gestion_caisse_on_paiement()
    IS 'Gérer tous les mouvements venant de T_Paiement';

-- FUNCTION: public.notification_new_course()

-- DROP FUNCTION IF EXISTS public.notification_new_course();

CREATE OR REPLACE FUNCTION public.notification_new_course()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
    enseignant_user_id INT;
    type_notif INT;
BEGIN
    SELECT "IdUserFk" INTO enseignant_user_id 
	FROM "T_Enseignant" 
	WHERE "IdEnseignant" = NEW."IdEnseignantFk";
	
    IF enseignant_user_id IS NOT NULL THEN
        SELECT "IdGenerique" INTO type_notif 
		FROM "T_Generique" 
		WHERE "NomGenerique" = 'Notification';
		
        INSERT INTO "T_Communication" ("IdUserFk", "IdTypeCommunication", "ContenuCommunication", "DateCommunication", "ValideCommunication", "LectureCommunication","IdEntiteFk")
        VALUES (enseignant_user_id, type_notif, 'Un nouveau cours a été ajouté.', NOW(), TRUE, FALSE,NEW."IdEntiteFk");
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.notification_new_course()
    OWNER TO postgres;

COMMENT ON FUNCTION public.notification_new_course()
    IS 'S''il y a une nouvelle attribution des cours dans T_Cours';

-- FUNCTION: public.notification_parent_absence()

-- DROP FUNCTION IF EXISTS public.notification_parent_absence();

CREATE OR REPLACE FUNCTION public.notification_parent_absence()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
    parent_id INT;
    apprenant_nom VARCHAR;
	statut_presence VARCHAR;
    type_notif INT;
BEGIN
    SELECT a."IdParentApprenantFk", u."NomUser" || ' ' || u."PrenomUser" INTO parent_id, apprenant_nom
    FROM "T_Apprenant" a
    JOIN "T_Utilisateurs" u ON a."IdUserFk" = u."IdUser"
    WHERE a."IdUserFk" = NEW."IdControleFk";
    
	SELECT "IdGenerique" INTO type_notif 
	FROM "T_Generique" 
	WHERE "NomGenerique" = 'Notification';

	
    IF (parent_id IS NOT NULL) and (NEW."IdStatutPresenceFk"=26) THEN
        INSERT INTO "T_Communication" ("IdUserFk", "IdTypeCommunication", "ContenuCommunication", "DateCommunication", "ValideCommunication", "LectureCommunication","IdEntiteFk")
        VALUES (parent_id, type_notif, 'Votre enfant ' || apprenant_nom || ' est absent(e) aujourd''hui.', NOW(), TRUE, FALSE,NEW."IdEntiteFk");
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.notification_parent_absence()
    OWNER TO postgres;

COMMENT ON FUNCTION public.notification_parent_absence()
    IS 'Notification au parent à l''absence de l''apprenant T_Presence';

-- FUNCTION: public.notification_parent_activite()

-- DROP FUNCTION IF EXISTS public.notification_parent_activite();

CREATE OR REPLACE FUNCTION public.notification_parent_activite()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
    parent_id INT;
    apprenant_nom VARCHAR;
    activite_nom VARCHAR;
    type_notif INT;
BEGIN
    -- Récupérer l'ID du parent et le nom de l'apprenant
    SELECT a."IdParentApprenantFk", CONCAT(u."NomUser", ' ', u."PrenomUser")
    INTO parent_id, apprenant_nom
    FROM "T_Apprenant" a
    JOIN "T_Utilisateurs" u ON a."IdUserFk" = u."IdUser"
    WHERE a."IdUserFk" = NEW."IdApprenantFk";

    -- Récupérer le nom de l'activité
    SELECT "NomActivite" INTO activite_nom 
    FROM "T_ActivitesParascolaires" 
    WHERE "IdActivite" = NEW."IdActiviteFk";

    -- Récupérer l'ID du type de communication "Notification"
    SELECT "IdGenerique" INTO type_notif 
    FROM "T_Generique" 
    WHERE "NomGenerique" = 'Notification';

    -- Vérifier si le parent existe
    IF parent_id IS NOT NULL THEN
        -- Insérer la notification pour le parent
        INSERT INTO "T_Communication" 
        ("IdUserFk", "IdTypeCommunication", "ContenuCommunication", "DateCommunication", "ValideCommunication", "LectureCommunication","IdEntiteFk")
        VALUES 
        (parent_id, type_notif, 
         'Votre enfant ' || apprenant_nom || ' a été inscrit à l’activité "' || activite_nom || '".', 
         NOW(), TRUE, FALSE,NEW."IdEntiteFk");
    END IF;

    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.notification_parent_activite()
    OWNER TO postgres;

COMMENT ON FUNCTION public.notification_parent_activite()
    IS 'Informer le parent lorsque l''apprenant est inscrit à une activité T_ActiviteParticipants';

-- FUNCTION: public.notification_parent_evaluation()

-- DROP FUNCTION IF EXISTS public.notification_parent_evaluation();

CREATE OR REPLACE FUNCTION public.notification_parent_evaluation()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
    parent_id INT;
    apprenant_nom VARCHAR;
    cours_nom VARCHAR;
	type_evaluation VARCHAR;
    type_notif INT;
BEGIN
    -- IF NEW."NoteEvaluation" < 8 THEN
        SELECT a."IdParentApprenantFk", u."NomUser" || ' ' || u."PrenomUser"
        INTO parent_id, apprenant_nom
        FROM "T_Apprenant" a
        JOIN "T_Utilisateurs" u ON a."IdUserFk" = u."IdUser"
        WHERE a."IdUserFk" = NEW."IdCibleFk";

        SELECT "NomGenerique" INTO cours_nom 
        FROM "T_Generique" 
        WHERE "IdGenerique" = NEW."IdCoursFk";

		SELECT "NomGenerique" INTO type_evaluation 
        FROM "T_Generique" 
        WHERE "IdGenerique" = NEW."IdTypeEvaluationFk";

        SELECT "IdGenerique" INTO type_notif 
        FROM "T_Generique" 
        WHERE "NomGenerique" = 'Notification';

        IF parent_id IS NOT NULL THEN
            INSERT INTO "T_Communication" 
            ("IdUserFk", "IdTypeCommunication", "ContenuCommunication", "DateCommunication", "ValideCommunication", "LectureCommunication","IdEntiteFk")
            VALUES 
            (parent_id, type_notif, 
             'Votre enfant ' || apprenant_nom || ' a obtenu une note de ' || NEW."NoteEvaluation" || ' sur ' || NEW."MaxNoteEvaluation" ||
             ' dans le cours de ' || cours_nom || '.Evaluaion : '|| type_evaluation ||'.', 
             NOW(), TRUE, FALSE,NEW."IdEntiteFk");
        END IF;
    -- END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.notification_parent_evaluation()
    OWNER TO postgres;

COMMENT ON FUNCTION public.notification_parent_evaluation()
    IS 'Informer le parent les points de l''évaluation T_Evaluation';

-- FUNCTION: public.notification_payment_success()

-- DROP FUNCTION IF EXISTS public.notification_payment_success();

CREATE OR REPLACE FUNCTION public.notification_payment_success()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
    utilisateur_id INT;
    montant NUMERIC(10,2);
    devise_nom VARCHAR;
    statut_nom VARCHAR;
    mouvement_nom VARCHAR;
    type_notif INT;
BEGIN
    -- Récupérer les noms associés aux IDs
    SELECT "NomGenerique" INTO statut_nom FROM "T_Generique" WHERE "IdGenerique" = NEW."IdStatutPaiementFk";
    SELECT "NomGenerique" INTO devise_nom FROM "T_Generique" WHERE "IdGenerique" = NEW."IdDeviseFk";
    SELECT "NomGenerique" INTO mouvement_nom FROM "T_Generique" WHERE "IdGenerique" = NEW."IdTypeMouvementFk";
    SELECT "IdGenerique" INTO type_notif FROM "T_Generique" WHERE "NomGenerique" = 'Notification';
    
    utilisateur_id := NEW."IdUserFk";
    montant := NEW."MontantPaiement";
    
    -- Vérifier que le statut n'est pas "En attente"
    IF statut_nom NOT IN ('En attente') THEN
        INSERT INTO "T_Communication" ("IdUserFk", "IdTypeCommunication", "ContenuCommunication", "DateCommunication", "ValideCommunication", "LectureCommunication","IdEntiteFk")
        VALUES (
            utilisateur_id, 
            type_notif, 
            'Votre paiement de ' || montant || ' ' || devise_nom || ' a été reçu avec succès. Statut: ' || statut_nom || ', Mouvement: ' || mouvement_nom || '.',
            NOW(),TRUE, FALSE,NEW."IdEntiteFk");
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.notification_payment_success()
    OWNER TO postgres;

COMMENT ON FUNCTION public.notification_payment_success()
    IS 'Notifier le parent sur le paiement T_Paiement';

-- FUNCTION: public.notify_licence_expiry()

-- DROP FUNCTION IF EXISTS public.notify_licence_expiry();

CREATE OR REPLACE FUNCTION public.notify_licence_expiry()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
    days_remaining INT;
    user_id INT;
    type_notif INT;
BEGIN
    SELECT DATE_PART('day', NEW."DateFin" - NOW()) INTO days_remaining;
    IF days_remaining = 7 THEN
        SELECT "IdUser" INTO user_id 
        FROM public."T_Utilisateurs"
        WHERE "IdUser" = (SELECT "IdUser" FROM public."T_Utilisateurs" u 
                          JOIN public."T_Entite" e ON e."IdEntite" = NEW."IdEntiteFk"
                          WHERE u."IdRoleFk" = (SELECT "IdGenerique" FROM public."T_Generique" WHERE "NomGenerique" = 'Admin Entité'));
        SELECT "IdGenerique" INTO type_notif 
        FROM public."T_Generique" 
        WHERE "NomGenerique" = 'Notification';
        INSERT INTO public."T_Communication" ("IdUserFk", "IdTypeCommunication", "ContenuCommunication", "DateCommunication", "ValideCommunication", "LectureCommunication","IdEntiteFk")
        VALUES (user_id, type_notif, 'Votre licence expirera dans 7 jours. Veuillez la renouveler.', NOW(), TRUE, FALSE,NEW."IdEntiteFk");
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.notify_licence_expiry()
    OWNER TO postgres;

COMMENT ON FUNCTION public.notify_licence_expiry()
    IS 'Envoie une notification 7 jours avant expiration de la licence';

-- FUNCTION: public.prevent_multiple_active_licenses()

-- DROP FUNCTION IF EXISTS public.prevent_multiple_active_licenses();

CREATE OR REPLACE FUNCTION public.prevent_multiple_active_licenses()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE existing_count INT;
BEGIN
    SELECT COUNT(*) INTO existing_count 
    FROM public."T_Licence" 
    WHERE "IdEntiteFk" = NEW."IdEntiteFk" 
    AND "ExpireeLicence" = FALSE;
    IF existing_count > 0 THEN
        RAISE EXCEPTION 'Cette entité possède déjà une licence active.';
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.prevent_multiple_active_licenses()
    OWNER TO postgres;

COMMENT ON FUNCTION public.prevent_multiple_active_licenses()
    IS 'Empêche l''ajout de plusieurs licences actives pour une même entité';

-- FUNCTION: public.prevention_delete_if_dependent()

-- DROP FUNCTION IF EXISTS public.prevention_delete_if_dependent();

CREATE OR REPLACE FUNCTION public.prevention_delete_if_dependent()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
  IF EXISTS (SELECT 1 FROM "T_Evaluations" WHERE "IdCibleFk" = OLD."IdUser") OR
     EXISTS (SELECT 1 FROM "T_Paiement" WHERE "IdUserFk" = OLD."IdUser") OR
     EXISTS (SELECT 1 FROM "T_Presence" WHERE "IdControleFk" = OLD."IdUser") THEN
    RAISE EXCEPTION 'Suppression impossible : cet utilisateur a des dépendances dans le système.';
  END IF;
  RETURN OLD;
END;
$BODY$;

ALTER FUNCTION public.prevention_delete_if_dependent()
    OWNER TO postgres;

COMMENT ON FUNCTION public.prevention_delete_if_dependent()
    IS 'Suppression impossible de l'' utilisateur ayant des dépendances dans le système';

-- FUNCTION: public.update_date_modification()

-- DROP FUNCTION IF EXISTS public.update_date_modification();

CREATE OR REPLACE FUNCTION public.update_date_modification()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    NEW."DateModificationUser" := NOW();
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.update_date_modification()
    OWNER TO postgres;

-- FUNCTION: public.update_licence_status()

-- DROP FUNCTION IF EXISTS public.update_licence_status();

CREATE OR REPLACE FUNCTION public.update_licence_status()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW."DateFin" < NOW() THEN
        NEW."ExpireeLicence" = TRUE;
    ELSE
        NEW."ExpireeLicence" = FALSE;
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.update_licence_status()
    OWNER TO postgres;

COMMENT ON FUNCTION public.update_licence_status()
    IS 'Met à jour automatiquement le statut ExpiréeLicence';
