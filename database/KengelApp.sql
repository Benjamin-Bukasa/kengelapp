--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-03-26 19:31:09

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 337 (class 1255 OID 42845)
-- Name: archive_paiements(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.archive_paiements() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ -- Archiver les paiements de plus de 2 ans
BEGIN
  INSERT INTO "T_Paiement_Archive"
  SELECT *, NOW() FROM "T_Paiement" 
  WHERE "DatePaiement" < NOW() - INTERVAL '2 years';
  -- Supprimer les paiements archivés
  DELETE FROM "T_Paiement" WHERE "DatePaiement" < NOW() - INTERVAL '2 years';
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.archive_paiements() OWNER TO postgres;

--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 337
-- Name: FUNCTION archive_paiements(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.archive_paiements() IS 'Archiver les paiements de plus de 2 ans';


--
-- TOC entry 344 (class 1255 OID 42865)
-- Name: audit_log_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.audit_log_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.audit_log_function() OWNER TO postgres;

--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 344
-- Name: FUNCTION audit_log_function(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.audit_log_function() IS 'Capture les modifications des tables avec gestion de IdEntiteFk si disponible.';


--
-- TOC entry 335 (class 1255 OID 42857)
-- Name: calculate_age_apprenant(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_age_apprenant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."AgeApprenant" := DATE_PART('year', AGE(NEW."DateNaissanceApprenant"));
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_age_apprenant() OWNER TO postgres;

--
-- TOC entry 334 (class 1255 OID 42855)
-- Name: format_phone_number(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.format_phone_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."PhoneUser" := regexp_replace(NEW."PhoneUser", '[^0-9]', '', 'g');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.format_phone_number() OWNER TO postgres;

--
-- TOC entry 338 (class 1255 OID 42951)
-- Name: gestion_caisse_on_paiement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gestion_caisse_on_paiement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
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
END;$$;


ALTER FUNCTION public.gestion_caisse_on_paiement() OWNER TO postgres;

--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 338
-- Name: FUNCTION gestion_caisse_on_paiement(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.gestion_caisse_on_paiement() IS 'Gérer tous les mouvements venant de T_Paiement';


--
-- TOC entry 339 (class 1255 OID 42853)
-- Name: notification_new_course(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notification_new_course() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
END;$$;


ALTER FUNCTION public.notification_new_course() OWNER TO postgres;

--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 339
-- Name: FUNCTION notification_new_course(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.notification_new_course() IS 'S''il y a une nouvelle attribution des cours dans T_Cours';


--
-- TOC entry 336 (class 1255 OID 42859)
-- Name: notification_parent_absence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notification_parent_absence() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
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
END;$$;


ALTER FUNCTION public.notification_parent_absence() OWNER TO postgres;

--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION notification_parent_absence(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.notification_parent_absence() IS 'Notification au parent à l''absence de l''apprenant T_Presence';


--
-- TOC entry 340 (class 1255 OID 42863)
-- Name: notification_parent_activite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notification_parent_activite() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.notification_parent_activite() OWNER TO postgres;

--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION notification_parent_activite(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.notification_parent_activite() IS 'Informer le parent lorsque l''apprenant est inscrit à une activité T_ActiviteParticipants';


--
-- TOC entry 341 (class 1255 OID 42847)
-- Name: notification_parent_evaluation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notification_parent_evaluation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.notification_parent_evaluation() OWNER TO postgres;

--
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 341
-- Name: FUNCTION notification_parent_evaluation(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.notification_parent_evaluation() IS 'Informer le parent les points de l''évaluation T_Evaluation';


--
-- TOC entry 343 (class 1255 OID 42861)
-- Name: notification_payment_success(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notification_payment_success() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.notification_payment_success() OWNER TO postgres;

--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION notification_payment_success(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.notification_payment_success() IS 'Notifier le parent sur le paiement T_Paiement';


--
-- TOC entry 342 (class 1255 OID 43171)
-- Name: notify_licence_expiry(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_licence_expiry() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.notify_licence_expiry() OWNER TO postgres;

--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 342
-- Name: FUNCTION notify_licence_expiry(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.notify_licence_expiry() IS 'Envoie une notification 7 jours avant expiration de la licence';


--
-- TOC entry 329 (class 1255 OID 43175)
-- Name: prevent_multiple_active_licenses(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_multiple_active_licenses() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.prevent_multiple_active_licenses() OWNER TO postgres;

--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION prevent_multiple_active_licenses(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.prevent_multiple_active_licenses() IS 'Empêche l''ajout de plusieurs licences actives pour une même entité';


--
-- TOC entry 332 (class 1255 OID 42849)
-- Name: prevention_delete_if_dependent(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevention_delete_if_dependent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM "T_Evaluations" WHERE "IdCibleFk" = OLD."IdUser") OR
     EXISTS (SELECT 1 FROM "T_Paiement" WHERE "IdUserFk" = OLD."IdUser") OR
     EXISTS (SELECT 1 FROM "T_Presence" WHERE "IdControleFk" = OLD."IdUser") THEN
    RAISE EXCEPTION 'Suppression impossible : cet utilisateur a des dépendances dans le système.';
  END IF;
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.prevention_delete_if_dependent() OWNER TO postgres;

--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION prevention_delete_if_dependent(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.prevention_delete_if_dependent() IS 'Suppression impossible de l'' utilisateur ayant des dépendances dans le système';


--
-- TOC entry 333 (class 1255 OID 42851)
-- Name: update_date_modification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_date_modification() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."DateModificationUser" := NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_date_modification() OWNER TO postgres;

--
-- TOC entry 331 (class 1255 OID 43169)
-- Name: update_licence_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_licence_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."DateFin" < NOW() THEN
        NEW."ExpireeLicence" = TRUE;
    ELSE
        NEW."ExpireeLicence" = FALSE;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_licence_status() OWNER TO postgres;

--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION update_licence_status(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.update_licence_status() IS 'Met à jour automatiquement le statut ExpiréeLicence';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 247 (class 1259 OID 42187)
-- Name: T_ActiviteParticipants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_ActiviteParticipants" (
    "IdParticipant" integer NOT NULL,
    "IdActiviteFk" integer NOT NULL,
    "IdApprenantFk" integer NOT NULL,
    "DateInscription" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_ActiviteParticipants" OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 42186)
-- Name: T_ActiviteParticipants_IdParticipant_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_ActiviteParticipants_IdParticipant_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."T_ActiviteParticipants_IdParticipant_seq" OWNER TO postgres;

--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 246
-- Name: T_ActiviteParticipants_IdParticipant_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_ActiviteParticipants_IdParticipant_seq" OWNED BY public."T_ActiviteParticipants"."IdParticipant";


--
-- TOC entry 249 (class 1259 OID 42210)
-- Name: T_ActiviteParticipants_IdParticipant_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_ActiviteParticipants" ALTER COLUMN "IdParticipant" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_ActiviteParticipants_IdParticipant_seq1"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 42172)
-- Name: T_ActivitesParascolaires; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_ActivitesParascolaires" (
    "IdActivite" integer NOT NULL,
    "NomActivite" character varying(100) NOT NULL,
    "DescriptionActivite" text,
    "DateActivite" date NOT NULL,
    "HeureDebut" time without time zone,
    "HeureFin" time without time zone,
    "IdEncadrantFk" integer,
    "ValideActivite" boolean DEFAULT true,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_ActivitesParascolaires" OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 42171)
-- Name: T_ActivitesParascolaires_IdActivite_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_ActivitesParascolaires_IdActivite_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."T_ActivitesParascolaires_IdActivite_seq" OWNER TO postgres;

--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 244
-- Name: T_ActivitesParascolaires_IdActivite_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_ActivitesParascolaires_IdActivite_seq" OWNED BY public."T_ActivitesParascolaires"."IdActivite";


--
-- TOC entry 248 (class 1259 OID 42209)
-- Name: T_ActivitesParascolaires_IdActivite_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_ActivitesParascolaires" ALTER COLUMN "IdActivite" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_ActivitesParascolaires_IdActivite_seq1"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 24802)
-- Name: T_Apprenant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Apprenant" (
    "IdApprenant" integer NOT NULL,
    "CodeApprenant" character(25),
    "DateNaissanceApprenant" date,
    "IdParentApprenantFk" integer NOT NULL,
    "IdUserFk" integer NOT NULL,
    "ValideApprenant" boolean DEFAULT true NOT NULL,
    "AgeApprenant" integer,
    "IdNiveauApprenantFk" integer,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Apprenant" OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 25572)
-- Name: T_Audit_Log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Audit_Log" (
    "IdLog" integer NOT NULL,
    "TableName" text,
    "Operation" text,
    "OldData" jsonb,
    "NewData" jsonb,
    "ChangedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Audit_Log" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 25571)
-- Name: T_Audit_Log_IdLog_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_Audit_Log_IdLog_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."T_Audit_Log_IdLog_seq" OWNER TO postgres;

--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 241
-- Name: T_Audit_Log_IdLog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_Audit_Log_IdLog_seq" OWNED BY public."T_Audit_Log"."IdLog";


--
-- TOC entry 296 (class 1259 OID 42926)
-- Name: T_Caisse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Caisse" (
    "IdCaisse" integer NOT NULL,
    "IdDeviseFk" integer NOT NULL,
    "MontantCaisse" numeric DEFAULT 0,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Caisse" OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 42925)
-- Name: T_Caisse_IdCaisse_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Caisse" ALTER COLUMN "IdCaisse" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Caisse_IdCaisse_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 24635)
-- Name: T_CategorieGenerique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_CategorieGenerique" (
    "IdCategorieGenerique" integer NOT NULL,
    "NomCategorieGenerique" character varying(25) NOT NULL,
    "ModuleCategorieGenerique" character varying,
    "ValideCategorieGenerique" boolean DEFAULT true NOT NULL,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_CategorieGenerique" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24641)
-- Name: T_CategorieGenerique_IdCategorieGenerique_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_CategorieGenerique" ALTER COLUMN "IdCategorieGenerique" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_CategorieGenerique_IdCategorieGenerique_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 25013)
-- Name: T_Communication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Communication" (
    "IdCommunication" integer NOT NULL,
    "IdUserFk" integer,
    "IdTypeCommunication" integer,
    "ContenuCommunication" text,
    "DateCommunication" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "ObsCommunication" text,
    "ValideCommunication" boolean DEFAULT true NOT NULL,
    "LectureCommunication" boolean DEFAULT false NOT NULL,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Communication" OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 32812)
-- Name: T_Communication_IdCommunication_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Communication" ALTER COLUMN "IdCommunication" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Communication_IdCommunication_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 24977)
-- Name: T_Cours; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Cours" (
    "IdCours" integer NOT NULL,
    "DescriptionCours" text,
    "IdEnseignantFk" integer,
    "ObsCours" text,
    "ValideCours" boolean DEFAULT true NOT NULL,
    "PonderationCours" integer,
    "PointMax" integer NOT NULL,
    "IdNiveauCoursFk" integer,
    "IdNomCoursFk" integer,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Cours" OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 24989)
-- Name: T_Cours_IdCours_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Cours" ALTER COLUMN "IdCours" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Cours_IdCours_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 24996)
-- Name: T_EmploisTemps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_EmploisTemps" (
    "IdEmploisTemps" integer NOT NULL,
    "IdNomCoursFk" integer,
    "JourSemaine" text,
    "HeureDebut" time without time zone,
    "HeureFin" time without time zone,
    "ObsEmploisTemps" text,
    "ValideEmploisTemps" boolean DEFAULT true,
    "IdNiveauFk" integer,
    "IdEntiteFk" integer,
    CONSTRAINT chk_heure_debut_fin CHECK (("HeureDebut" < "HeureFin"))
);


ALTER TABLE public."T_EmploisTemps" OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 25031)
-- Name: T_EmploisTemps_IdEmploisTemps_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_EmploisTemps" ALTER COLUMN "IdEmploisTemps" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_EmploisTemps_IdEmploisTemps_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 24758)
-- Name: T_Enseignant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Enseignant" (
    "IdEnseignant" integer NOT NULL,
    "IdUserFk" integer,
    "IdSpecialiteEnseignantFk" integer,
    "SalaireEnseignant" integer,
    "DateEmbaucheEnseignant" date,
    "ValideEnseignant" boolean DEFAULT true NOT NULL,
    "CodeEnseignant" character(25),
    "IdDeviseFk" integer NOT NULL,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Enseignant" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24892)
-- Name: T_Enseignant_IdEnseigant_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Enseignant" ALTER COLUMN "IdEnseignant" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Enseignant_IdEnseigant_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 24893)
-- Name: T_Enseignes_IdEnseignes_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Apprenant" ALTER COLUMN "IdApprenant" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Enseignes_IdEnseignes_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 304 (class 1259 OID 43145)
-- Name: T_Entite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Entite" (
    "IdEntite" integer NOT NULL,
    "NomEntite" text NOT NULL,
    "PhoneEntite" text,
    "EmailEntite" character varying(255) NOT NULL,
    "AdresseEntite" text,
    "DateCreationEntite" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdTypeEntiteFk" integer NOT NULL,
    "ValideEntite" boolean DEFAULT true
);


ALTER TABLE public."T_Entite" OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 43144)
-- Name: T_Entite_IdEntite_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Entite" ALTER COLUMN "IdEntite" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Entite_IdEntite_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 24938)
-- Name: T_Evaluations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Evaluations" (
    "IdEvaluation" integer NOT NULL,
    "IdCibleFk" integer,
    "IdEvaluateurFk" integer,
    "NoteEvaluation" numeric,
    "ObsEvaluation" text,
    "DateEvaluation" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdTypeEvaluationFk" integer,
    "CodeEvaluation" text,
    "ValideEvaluation" boolean DEFAULT true NOT NULL,
    "IdCoursFk" integer,
    "MaxNoteEvaluation" integer,
    "IdEntiteFk" integer,
    CONSTRAINT chk_note_evaluation CHECK ((("NoteEvaluation" >= (0)::numeric) AND ("NoteEvaluation" <= ("MaxNoteEvaluation")::numeric)))
);


ALTER TABLE public."T_Evaluations" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 24961)
-- Name: T_Evaluations_IdEvaluation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Evaluations" ALTER COLUMN "IdEvaluation" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Evaluations_IdEvaluation_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 217 (class 1259 OID 24632)
-- Name: T_Generique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Generique" (
    "IdGenerique" integer NOT NULL,
    "NomGenerique" character varying(25) NOT NULL,
    "CodeGenerique" character varying(25) NOT NULL,
    "ObsGenerique" character varying,
    "ValideGenerique" boolean DEFAULT true NOT NULL,
    "IdCategorieGeneriqueFk" integer
);


ALTER TABLE public."T_Generique" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24740)
-- Name: T_Generique_IdGenerique_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Generique" ALTER COLUMN "IdGenerique" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Generique_IdGenerique_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 302 (class 1259 OID 43122)
-- Name: T_Licence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Licence" (
    "IdLicence" integer NOT NULL,
    "IdEntiteFk" integer NOT NULL,
    "CleLicence" uuid DEFAULT gen_random_uuid(),
    "DateDebut" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "DateFin" timestamp without time zone NOT NULL,
    "IdStatutLicenceFk" integer NOT NULL,
    "ValideLicence" boolean DEFAULT true,
    "ExpireeLicence" boolean DEFAULT false,
    CONSTRAINT "Chk_DateFin" CHECK (("DateFin" > "DateDebut"))
);


ALTER TABLE public."T_Licence" OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 43121)
-- Name: T_Licence_IdLicence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_Licence_IdLicence_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."T_Licence_IdLicence_seq" OWNER TO postgres;

--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 301
-- Name: T_Licence_IdLicence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_Licence_IdLicence_seq" OWNED BY public."T_Licence"."IdLicence";


--
-- TOC entry 238 (class 1259 OID 25038)
-- Name: T_Login; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Login" (
    "IdLogin" integer NOT NULL,
    "IdUserFk" integer NOT NULL,
    "IdTypeLoginFk" integer NOT NULL,
    "DateLogin" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Login" OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 25037)
-- Name: T_Login_IdLogin_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Login" ALTER COLUMN "IdLogin" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Login_IdLogin_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 24846)
-- Name: T_Paiement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Paiement" (
    "IdPaiement" integer NOT NULL,
    "CodePaiement" character(25),
    "IdUserFk" integer NOT NULL,
    "IdTypePaiementFk" integer NOT NULL,
    "MontantPaiement" numeric(10,2) NOT NULL,
    "IdStatutPaiementFk" integer,
    "DatePaiement" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "ObsPaiement" text,
    "ValidePaiement" boolean DEFAULT true NOT NULL,
    "IdDeviseFk" integer NOT NULL,
    "IdPayeurFk" integer,
    "IdTypeMouvementFk" integer,
    "IdEntiteFk" integer,
    CONSTRAINT chk_montant_paiement CHECK (("MontantPaiement" > (0)::numeric))
);


ALTER TABLE public."T_Paiement" OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 42352)
-- Name: T_Paiement_Archive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Paiement_Archive" (
    "IdPaiement" integer,
    "CodePaiement" character(25),
    "IdUserFk" integer,
    "IdTypePaiementFk" integer,
    "MontantPaiement" numeric(10,2),
    "IdStatutPaiementFk" integer,
    "DatePaiement" timestamp without time zone,
    "ObsPaiement" text,
    "ValidePaiement" boolean,
    "IdDeviseFk" integer,
    "IdPayeurFk" integer,
    "IdTypeMouvementFk" integer,
    "DateArchivage" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Paiement_Archive" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24894)
-- Name: T_Paiement_IdPaiement_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Paiement" ALTER COLUMN "IdPaiement" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Paiement_IdPaiement_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 240 (class 1259 OID 25065)
-- Name: T_Presence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Presence" (
    "IdPresence" integer NOT NULL,
    "IdControleurFk" integer,
    "IdControleFk" integer,
    "IdStatutPresenceFk" integer NOT NULL,
    "DatePresence" date NOT NULL,
    "ValidePresence" boolean DEFAULT true NOT NULL,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Presence" OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 25064)
-- Name: T_Presence_IdPresence_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Presence" ALTER COLUMN "IdPresence" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Presence_IdPresence_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 300 (class 1259 OID 43002)
-- Name: T_Salle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Salle" (
    "IdSalle" integer NOT NULL,
    "NomSalle" character(25) NOT NULL,
    "CapaciteSalle" numeric NOT NULL,
    "IdEntiteFk" integer
);


ALTER TABLE public."T_Salle" OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 43001)
-- Name: T_Salle_IdSalle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Salle" ALTER COLUMN "IdSalle" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Salle_IdSalle_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 24713)
-- Name: T_Utilisateurs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_Utilisateurs" (
    "IdUser" integer NOT NULL,
    "NomUser" character varying(100) NOT NULL,
    "PrenomUser" character varying(100) NOT NULL,
    "EmailUser" character varying(150) NOT NULL,
    "MotdepasseUser" text NOT NULL,
    "PhoneUser" character varying(20),
    "DatecreationUser" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "IdRoleFk" integer,
    "ValideUser" boolean DEFAULT true NOT NULL,
    "SexeUser" character(1) NOT NULL,
    "DateModificationUser" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UrlPhoto" text,
    "IdEntiteFk" integer,
    CONSTRAINT chk_sexe_utilisateur CHECK (("SexeUser" = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


ALTER TABLE public."T_Utilisateurs" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24739)
-- Name: T_Utilisateurs_IdUser_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."T_Utilisateurs" ALTER COLUMN "IdUser" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."T_Utilisateurs_IdUser_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 269 (class 1259 OID 42741)
-- Name: VS_ApprenantAge; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_ApprenantAge" AS
 SELECT
        CASE
            WHEN ((date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) >= (5)::double precision) AND (date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) <= (10)::double precision)) THEN '5-10 ans'::text
            WHEN ((date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) >= (11)::double precision) AND (date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) <= (15)::double precision)) THEN '11-15 ans'::text
            WHEN ((date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) >= (16)::double precision) AND (date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) <= (20)::double precision)) THEN '16-20 ans'::text
            ELSE '21 ans et plus'::text
        END AS tranche_age,
    count(a."IdApprenant") AS nombre_apprenants,
    a."IdEntiteFk",
    ent."NomEntite"
   FROM (public."T_Apprenant" a
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
  GROUP BY
        CASE
            WHEN ((date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) >= (5)::double precision) AND (date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) <= (10)::double precision)) THEN '5-10 ans'::text
            WHEN ((date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) >= (11)::double precision) AND (date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) <= (15)::double precision)) THEN '11-15 ans'::text
            WHEN ((date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) >= (16)::double precision) AND (date_part('year'::text, age((a."DateNaissanceApprenant")::timestamp with time zone)) <= (20)::double precision)) THEN '16-20 ans'::text
            ELSE '21 ans et plus'::text
        END, a."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_ApprenantAge" OWNER TO postgres;

--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 269
-- Name: VIEW "VS_ApprenantAge"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_ApprenantAge" IS 'Nombre total d''apprenants par tranche d''âge';


--
-- TOC entry 263 (class 1259 OID 42697)
-- Name: VS_ApprenantNiveau; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_ApprenantNiveau" AS
 SELECT a."IdNiveauApprenantFk",
    g_niveau."NomGenerique" AS niveau_cours,
    count(a."IdApprenant") AS nombre_apprenants,
    a."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Apprenant" a
     JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
  GROUP BY a."IdNiveauApprenantFk", g_niveau."NomGenerique", a."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_ApprenantNiveau" OWNER TO postgres;

--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 263
-- Name: VIEW "VS_ApprenantNiveau"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_ApprenantNiveau" IS 'Nombre total d''apprenants par niveau';


--
-- TOC entry 272 (class 1259 OID 42755)
-- Name: VS_ApprenantSexe; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_ApprenantSexe" AS
 SELECT u."SexeUser" AS sexe,
    count(a."IdApprenant") AS nombre_apprenants,
    a."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Apprenant" a
     JOIN public."T_Utilisateurs" u ON ((a."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
  GROUP BY u."SexeUser", a."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_ApprenantSexe" OWNER TO postgres;

--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 272
-- Name: VIEW "VS_ApprenantSexe"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_ApprenantSexe" IS 'Répartition des apprenants par sexe';


--
-- TOC entry 308 (class 1259 OID 43197)
-- Name: VS_Bulletin_Annee_Apprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_Bulletin_Annee_Apprenant" AS
 SELECT a."IdApprenant",
    (((u."NomUser")::text || ' '::text) || (u."PrenomUser")::text) AS "Nom_Apprenant",
    g_niveau."NomGenerique" AS "Niveau",
    g_cours."NomGenerique" AS "Matière",
    round(avg(e."NoteEvaluation"), 2) AS "Moyenne",
    sum(e."NoteEvaluation") AS "Total_Points",
    sum(c."PointMax") AS "Points_Max",
        CASE
            WHEN (round(avg(e."NoteEvaluation"), 2) >= (10)::numeric) THEN 'Réussi'::text
            ELSE 'Ajourné'::text
        END AS "Mention",
    e."IdEntiteFk",
    ent."NomEntite"
   FROM ((((((public."T_Evaluations" e
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
     JOIN public."T_Apprenant" a ON ((e."IdCibleFk" = a."IdUserFk")))
     JOIN public."T_Utilisateurs" u ON ((a."IdUserFk" = u."IdUser")))
     JOIN public."T_Cours" c ON ((e."IdCoursFk" = c."IdCours")))
     JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
  WHERE (EXTRACT(year FROM e."DateEvaluation") = EXTRACT(year FROM CURRENT_DATE))
  GROUP BY a."IdApprenant", u."NomUser", u."PrenomUser", g_niveau."NomGenerique", g_cours."NomGenerique", e."IdEntiteFk", ent."NomEntite"
  ORDER BY a."IdApprenant", g_cours."NomGenerique";


ALTER VIEW public."VS_Bulletin_Annee_Apprenant" OWNER TO postgres;

--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 308
-- Name: VIEW "VS_Bulletin_Annee_Apprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_Bulletin_Annee_Apprenant" IS 'Vue affichant les moyennes annuelles des apprenants avec mention';


--
-- TOC entry 289 (class 1259 OID 42881)
-- Name: VS_ClassementEnseignant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_ClassementEnseignant" AS
 SELECT concat_ws(' '::text, u."NomUser", u."PrenomUser") AS enseignant,
    g_typeeva."NomGenerique" AS type_evaluation,
    round(avg(ev."NoteEvaluation"), 2) AS moyenne_evaluation
   FROM (((public."T_Evaluations" ev
     JOIN public."T_Utilisateurs" u ON ((ev."IdCibleFk" = u."IdUser")))
     JOIN public."T_Enseignant" e ON ((ev."IdCibleFk" = e."IdUserFk")))
     JOIN public."T_Generique" g_typeeva ON ((ev."IdTypeEvaluationFk" = g_typeeva."IdGenerique")))
  GROUP BY (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g_typeeva."NomGenerique";


ALTER VIEW public."VS_ClassementEnseignant" OWNER TO postgres;

--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 289
-- Name: VIEW "VS_ClassementEnseignant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_ClassementEnseignant" IS 'Classement des enseignants par évaluation';


--
-- TOC entry 270 (class 1259 OID 42746)
-- Name: VS_CommunicationNombre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_CommunicationNombre" AS
 SELECT g."IdGenerique",
    g."NomGenerique" AS type_communication,
    count(c."IdCommunication") AS nombre_messages,
    c."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Communication" c
     JOIN public."T_Generique" g ON ((c."IdTypeCommunication" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((c."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g."IdGenerique", g."NomGenerique", c."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_CommunicationNombre" OWNER TO postgres;

--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 270
-- Name: VIEW "VS_CommunicationNombre"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_CommunicationNombre" IS 'Statistiques des communications envoyées par type';


--
-- TOC entry 316 (class 1259 OID 43344)
-- Name: VS_EnseignantCoursNbreApprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_EnseignantCoursNbreApprenant" AS
 SELECT e."IdEnseignant",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS enseignant_nom,
    g_cours."NomGenerique" AS nomcours,
    g_niveau."NomGenerique" AS niveaucours,
    count(c."IdCours") AS nombre_apprenant,
    e."IdEntiteFk",
    ent."NomEntite"
   FROM (((((((public."T_Enseignant" e
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     JOIN public."T_Cours" c ON ((c."IdEnseignantFk" = e."IdEnseignant")))
     JOIN public."T_EmploisTemps" edt ON ((edt."IdNomCoursFk" = c."IdNomCoursFk")))
     JOIN public."T_Apprenant" a ON ((a."IdNiveauApprenantFk" = edt."IdNiveauFk")))
     LEFT JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Generique" g_niveau ON ((c."IdNiveauCoursFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
  GROUP BY e."IdEnseignant", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g_cours."NomGenerique", g_niveau."NomGenerique", e."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_EnseignantCoursNbreApprenant" OWNER TO postgres;

--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 316
-- Name: VIEW "VS_EnseignantCoursNbreApprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_EnseignantCoursNbreApprenant" IS 'Classement des enseignants par évaluation';


--
-- TOC entry 284 (class 1259 OID 42815)
-- Name: VS_EnseignantNombreCours; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_EnseignantNombreCours" AS
 SELECT concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_enseignant,
    count(c."IdCours") AS nombre_cours,
    c."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Cours" c
     JOIN public."T_Enseignant" e ON ((c."IdEnseignantFk" = e."IdEnseignant")))
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((c."IdEntiteFk" = ent."IdEntite")))
  GROUP BY (concat_ws(' '::text, u."NomUser", u."PrenomUser")), c."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_EnseignantNombreCours" OWNER TO postgres;

--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 284
-- Name: VIEW "VS_EnseignantNombreCours"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_EnseignantNombreCours" IS 'Répartition des cours par enseignant';


--
-- TOC entry 273 (class 1259 OID 42760)
-- Name: VS_EnseignantSexe; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_EnseignantSexe" AS
 SELECT u."SexeUser" AS sexe,
    count(e."IdEnseignant") AS nombre_enseignants,
    e."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Enseignant" e
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
  GROUP BY u."SexeUser", e."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_EnseignantSexe" OWNER TO postgres;

--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 273
-- Name: VIEW "VS_EnseignantSexe"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_EnseignantSexe" IS 'Nombre d''enseignants par genre';


--
-- TOC entry 288 (class 1259 OID 42835)
-- Name: VS_EnseignantSurcharge; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_EnseignantSurcharge" AS
 SELECT concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_enseignant,
    count(c."IdCours") AS nombre_cours,
    sum((EXTRACT(epoch FROM (e."HeureFin" - e."HeureDebut")) / (3600)::numeric)) AS heures_totales
   FROM (((public."T_Cours" c
     JOIN public."T_Enseignant" ens ON ((c."IdEnseignantFk" = ens."IdEnseignant")))
     JOIN public."T_Utilisateurs" u ON ((ens."IdUserFk" = u."IdUser")))
     JOIN public."T_EmploisTemps" e ON ((c."IdNomCoursFk" = e."IdNomCoursFk")))
  GROUP BY (concat_ws(' '::text, u."NomUser", u."PrenomUser"))
 HAVING ((count(c."IdCours") > 5) AND (sum((EXTRACT(epoch FROM (e."HeureFin" - e."HeureDebut")) / (3600)::numeric)) > (20)::numeric));


ALTER VIEW public."VS_EnseignantSurcharge" OWNER TO postgres;

--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 288
-- Name: VIEW "VS_EnseignantSurcharge"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_EnseignantSurcharge" IS 'Vérification des enseignants surchargés';


--
-- TOC entry 274 (class 1259 OID 42765)
-- Name: VS_EvaluationsMatiere; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_EvaluationsMatiere" AS
 SELECT g_niveau."NomGenerique" AS niveau_cours,
    g_cours."NomGenerique" AS matiere,
    type_ev."NomGenerique" AS type_evaluation,
    count(e."IdEvaluation") AS nombre_evaluations,
    e."IdEntiteFk",
    ent."NomEntite"
   FROM (((((public."T_Evaluations" e
     JOIN public."T_Cours" c ON ((e."IdCoursFk" = c."IdNomCoursFk")))
     JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Generique" type_ev ON ((e."IdTypeEvaluationFk" = type_ev."IdGenerique")))
     LEFT JOIN public."T_Generique" g_niveau ON ((c."IdNiveauCoursFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g_niveau."NomGenerique", g_cours."NomGenerique", type_ev."NomGenerique", e."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_EvaluationsMatiere" OWNER TO postgres;

--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 274
-- Name: VIEW "VS_EvaluationsMatiere"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_EvaluationsMatiere" IS 'Nombre d''évaluations par matière';


--
-- TOC entry 264 (class 1259 OID 42701)
-- Name: VS_InscriptionsAnnee; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_InscriptionsAnnee" AS
 SELECT EXTRACT(year FROM u."DatecreationUser") AS annee_inscription,
    count(a."IdApprenant") AS nombre_inscriptions
   FROM (public."T_Apprenant" a
     JOIN public."T_Utilisateurs" u ON ((a."IdUserFk" = u."IdUser")))
  GROUP BY (EXTRACT(year FROM u."DatecreationUser"));


ALTER VIEW public."VS_InscriptionsAnnee" OWNER TO postgres;

--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 264
-- Name: VIEW "VS_InscriptionsAnnee"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_InscriptionsAnnee" IS 'Nombre total d''apprenants inscrits cette année';


--
-- TOC entry 268 (class 1259 OID 42736)
-- Name: VS_LoginNombre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_LoginNombre" AS
 SELECT l."IdUserFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_user,
    g."NomGenerique" AS type_login,
    count(l."IdLogin") AS nombre_connexions,
    l."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Login" l
     JOIN public."T_Utilisateurs" u ON ((l."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Generique" g ON ((l."IdTypeLoginFk" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((l."IdEntiteFk" = ent."IdEntite")))
  GROUP BY l."IdUserFk", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g."NomGenerique", l."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_LoginNombre" OWNER TO postgres;

--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 268
-- Name: VIEW "VS_LoginNombre"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_LoginNombre" IS 'Suivi des connexions des utilisateurs';


--
-- TOC entry 290 (class 1259 OID 42891)
-- Name: VS_MoyenneApprenantNiveau; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_MoyenneApprenantNiveau" AS
 SELECT g_niveau."NomGenerique" AS niveau_apprenant,
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS apprenant,
    g_typeeva."NomGenerique" AS type_evaluation,
    round(avg(ev."NoteEvaluation"), 2) AS moyenne,
    ev."IdEntiteFk",
    ent."NomEntite"
   FROM (((((public."T_Evaluations" ev
     JOIN public."T_Utilisateurs" u ON ((ev."IdCibleFk" = u."IdUser")))
     JOIN public."T_Apprenant" a ON ((u."IdUser" = a."IdUserFk")))
     LEFT JOIN public."T_Generique" g_typeeva ON ((ev."IdTypeEvaluationFk" = g_typeeva."IdGenerique")))
     LEFT JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((ev."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g_niveau."NomGenerique", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g_typeeva."NomGenerique", ev."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_MoyenneApprenantNiveau" OWNER TO postgres;

--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 290
-- Name: VIEW "VS_MoyenneApprenantNiveau"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_MoyenneApprenantNiveau" IS 'Moyenne générale des apprenants par niveau';


--
-- TOC entry 275 (class 1259 OID 42770)
-- Name: VS_MoyenneEnseignantMatiere; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_MoyenneEnseignantMatiere" AS
 SELECT type_ev."NomGenerique" AS type_evaluation,
    g_cours."NomGenerique" AS matiere,
    round(avg(e."NoteEvaluation"), 2) AS moyenne_evaluation,
    e."IdEntiteFk",
    ent."NomEntite"
   FROM ((((public."T_Evaluations" e
     JOIN public."T_Cours" c ON ((e."IdCoursFk" = c."IdNomCoursFk")))
     LEFT JOIN public."T_Generique" type_ev ON ((e."IdTypeEvaluationFk" = type_ev."IdGenerique")))
     LEFT JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
  GROUP BY type_ev."NomGenerique", g_cours."NomGenerique", e."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_MoyenneEnseignantMatiere" OWNER TO postgres;

--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 275
-- Name: VIEW "VS_MoyenneEnseignantMatiere"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_MoyenneEnseignantMatiere" IS 'Moyenne des enseignants par matière';


--
-- TOC entry 260 (class 1259 OID 42683)
-- Name: VS_MoyenneEvaluation; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_MoyenneEvaluation" AS
 SELECT u."IdUser",
    apprenant."IdApprenant",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS noms,
    round(avg(ev."NoteEvaluation"), 2) AS moyenne_generale,
    g_cours."NomGenerique" AS cours,
    ev."IdEntiteFk",
    ent."NomEntite"
   FROM ((((public."T_Evaluations" ev
     JOIN public."T_Utilisateurs" u ON ((ev."IdCibleFk" = u."IdUser")))
     LEFT JOIN public."T_Generique" g_cours ON ((ev."IdCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Apprenant" apprenant ON ((u."IdUser" = apprenant."IdUserFk")))
     LEFT JOIN public."T_Entite" ent ON ((ev."IdEntiteFk" = ent."IdEntite")))
  GROUP BY u."IdUser", apprenant."IdApprenant", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g_cours."NomGenerique", ev."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_MoyenneEvaluation" OWNER TO postgres;

--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 260
-- Name: VIEW "VS_MoyenneEvaluation"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_MoyenneEvaluation" IS 'Vue des évaluations et moyennes des apprenants';


--
-- TOC entry 283 (class 1259 OID 42810)
-- Name: VS_MoyenneMatiere; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_MoyenneMatiere" AS
 SELECT g_cours."NomGenerique" AS matiere,
    type_ev."NomGenerique" AS type_evaluation,
    round(avg(e."NoteEvaluation"), 2) AS moyenne_generale,
    e."IdEntiteFk",
    ent."NomEntite"
   FROM ((((public."T_Evaluations" e
     JOIN public."T_Cours" c ON ((e."IdCoursFk" = c."IdNomCoursFk")))
     LEFT JOIN public."T_Generique" type_ev ON ((e."IdTypeEvaluationFk" = type_ev."IdGenerique")))
     LEFT JOIN public."T_Generique" g_cours ON ((c."IdNiveauCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g_cours."NomGenerique", type_ev."NomGenerique", e."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_MoyenneMatiere" OWNER TO postgres;

--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 283
-- Name: VIEW "VS_MoyenneMatiere"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_MoyenneMatiere" IS 'Moyenne des apprenants par matière';


--
-- TOC entry 286 (class 1259 OID 42825)
-- Name: VS_MoyenneNoteTrimestre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_MoyenneNoteTrimestre" AS
 SELECT g_niveau."NomGenerique" AS niveauapprenant,
    EXTRACT(year FROM e."DateEvaluation") AS annee,
        CASE
            WHEN ((EXTRACT(month FROM e."DateEvaluation") >= (1)::numeric) AND (EXTRACT(month FROM e."DateEvaluation") <= (3)::numeric)) THEN 'Trimestre 1'::text
            WHEN ((EXTRACT(month FROM e."DateEvaluation") >= (4)::numeric) AND (EXTRACT(month FROM e."DateEvaluation") <= (6)::numeric)) THEN 'Trimestre 2'::text
            WHEN ((EXTRACT(month FROM e."DateEvaluation") >= (7)::numeric) AND (EXTRACT(month FROM e."DateEvaluation") <= (9)::numeric)) THEN 'Trimestre 3'::text
            ELSE 'Trimestre 4'::text
        END AS trimestre,
    round(avg(e."NoteEvaluation"), 2) AS moyenne_generale,
    e."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Evaluations" e
     JOIN public."T_Apprenant" a ON ((e."IdCibleFk" = a."IdUserFk")))
     LEFT JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g_niveau."NomGenerique", (EXTRACT(year FROM e."DateEvaluation")),
        CASE
            WHEN ((EXTRACT(month FROM e."DateEvaluation") >= (1)::numeric) AND (EXTRACT(month FROM e."DateEvaluation") <= (3)::numeric)) THEN 'Trimestre 1'::text
            WHEN ((EXTRACT(month FROM e."DateEvaluation") >= (4)::numeric) AND (EXTRACT(month FROM e."DateEvaluation") <= (6)::numeric)) THEN 'Trimestre 2'::text
            WHEN ((EXTRACT(month FROM e."DateEvaluation") >= (7)::numeric) AND (EXTRACT(month FROM e."DateEvaluation") <= (9)::numeric)) THEN 'Trimestre 3'::text
            ELSE 'Trimestre 4'::text
        END, e."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_MoyenneNoteTrimestre" OWNER TO postgres;

--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 286
-- Name: VIEW "VS_MoyenneNoteTrimestre"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_MoyenneNoteTrimestre" IS 'Evolution des notes moyennes des apprenants par trimestre';


--
-- TOC entry 292 (class 1259 OID 42900)
-- Name: VS_NombreApprenantCours; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombreApprenantCours" AS
 SELECT c."IdNomCoursFk",
    g_cours."NomGenerique" AS nom_cours,
    count(a."IdApprenant") AS nombre_apprenant
   FROM (((public."T_Cours" c
     JOIN public."T_EmploisTemps" edt ON ((c."IdNomCoursFk" = edt."IdNomCoursFk")))
     JOIN public."T_Apprenant" a ON ((edt."IdNiveauFk" = a."IdNiveauApprenantFk")))
     LEFT JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
  GROUP BY c."IdNomCoursFk", g_cours."NomGenerique";


ALTER VIEW public."VS_NombreApprenantCours" OWNER TO postgres;

--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 292
-- Name: VIEW "VS_NombreApprenantCours"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombreApprenantCours" IS 'Vue nombre d''apprenants par cours';


--
-- TOC entry 291 (class 1259 OID 42896)
-- Name: VS_NombreApprenantNiveau; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombreApprenantNiveau" AS
 SELECT g_niveau."NomGenerique" AS niveau_apprenant,
    count(*) AS nombre_apprenant,
    a."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Apprenant" a
     JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g_niveau."NomGenerique", a."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_NombreApprenantNiveau" OWNER TO postgres;

--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 291
-- Name: VIEW "VS_NombreApprenantNiveau"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombreApprenantNiveau" IS 'Vue nombre d''apprenants par niveau';


--
-- TOC entry 317 (class 1259 OID 43359)
-- Name: VS_NombreCoursEnseignant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombreCoursEnseignant" AS
 SELECT e."IdEnseignant",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS enseignant,
    count(c."IdCours") AS nombre_cours,
    c."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Cours" c
     JOIN public."T_Enseignant" e ON ((c."IdEnseignantFk" = e."IdEnseignant")))
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((c."IdEntiteFk" = ent."IdEntite")))
  GROUP BY e."IdEnseignant", u."NomUser", u."PrenomUser", c."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_NombreCoursEnseignant" OWNER TO postgres;

--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 317
-- Name: VIEW "VS_NombreCoursEnseignant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombreCoursEnseignant" IS 'Nombre total de cours dispensés par enseignant';


--
-- TOC entry 280 (class 1259 OID 42795)
-- Name: VS_NombreCoursNiveau; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombreCoursNiveau" AS
 SELECT g_niveau."NomGenerique" AS niveau_cours,
    count(c."IdNomCoursFk") AS nombre_cours,
    c."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Cours" c
     JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     JOIN public."T_Generique" g_niveau ON ((c."IdNiveauCoursFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((c."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g_niveau."NomGenerique", c."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_NombreCoursNiveau" OWNER TO postgres;

--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 280
-- Name: VIEW "VS_NombreCoursNiveau"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombreCoursNiveau" IS 'Nombre total de cours par niveau';


--
-- TOC entry 279 (class 1259 OID 42790)
-- Name: VS_NombreHeuresCoursEnseignant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombreHeuresCoursEnseignant" AS
 SELECT concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_enseignant,
    round(sum((EXTRACT(epoch FROM (e."HeureFin" - e."HeureDebut")) / (3600)::numeric)), 2) AS total_heures
   FROM (((public."T_EmploisTemps" e
     JOIN public."T_Cours" c ON ((e."IdNomCoursFk" = c."IdNomCoursFk")))
     LEFT JOIN public."T_Enseignant" ens ON ((c."IdEnseignantFk" = ens."IdEnseignant")))
     LEFT JOIN public."T_Utilisateurs" u ON ((ens."IdUserFk" = u."IdUser")))
  GROUP BY (concat_ws(' '::text, u."NomUser", u."PrenomUser"));


ALTER VIEW public."VS_NombreHeuresCoursEnseignant" OWNER TO postgres;

--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 279
-- Name: VIEW "VS_NombreHeuresCoursEnseignant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombreHeuresCoursEnseignant" IS 'VS_NombreHeuresCoursEnseignant';


--
-- TOC entry 277 (class 1259 OID 42780)
-- Name: VS_NombrePresenceApprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombrePresenceApprenant" AS
 SELECT EXTRACT(year FROM p."DatePresence") AS annee,
    EXTRACT(month FROM p."DatePresence") AS mois,
    count(p."IdPresence") AS nombre,
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS noms_apprenant,
    g."NomGenerique" AS type_presence,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM ((((public."T_Presence" p
     JOIN public."T_Generique" g ON ((p."IdStatutPresenceFk" = g."IdGenerique")))
     JOIN public."T_Utilisateurs" u ON ((p."IdControleFk" = u."IdUser")))
     JOIN public."T_Apprenant" apprenant ON ((u."IdUser" = apprenant."IdUserFk")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  GROUP BY (EXTRACT(year FROM p."DatePresence")), (EXTRACT(month FROM p."DatePresence")), g."NomGenerique", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_NombrePresenceApprenant" OWNER TO postgres;

--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 277
-- Name: VIEW "VS_NombrePresenceApprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombrePresenceApprenant" IS 'Statistiques des présences des apprenants';


--
-- TOC entry 276 (class 1259 OID 42775)
-- Name: VS_NombrePresenceEnseignant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombrePresenceEnseignant" AS
 SELECT EXTRACT(year FROM p."DatePresence") AS annee,
    EXTRACT(month FROM p."DatePresence") AS mois,
    count(p."IdPresence") AS nombre,
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS noms_enseignant,
    g."NomGenerique" AS type_presence
   FROM (((public."T_Presence" p
     JOIN public."T_Generique" g ON ((p."IdStatutPresenceFk" = g."IdGenerique")))
     JOIN public."T_Utilisateurs" u ON ((p."IdControleFk" = u."IdUser")))
     JOIN public."T_Enseignant" enseignant ON ((u."IdUser" = enseignant."IdUserFk")))
  GROUP BY (EXTRACT(year FROM p."DatePresence")), (EXTRACT(month FROM p."DatePresence")), g."NomGenerique", (concat_ws(' '::text, u."NomUser", u."PrenomUser"));


ALTER VIEW public."VS_NombrePresenceEnseignant" OWNER TO postgres;

--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 276
-- Name: VIEW "VS_NombrePresenceEnseignant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombrePresenceEnseignant" IS 'Statistiques des présences des enseignants';


--
-- TOC entry 278 (class 1259 OID 42785)
-- Name: VS_NombrePresenceUtilisateur; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombrePresenceUtilisateur" AS
 SELECT p."IdControleFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS noms_use,
    count(*) AS total_jours,
    sum(
        CASE
            WHEN (p."IdStatutPresenceFk" = 25) THEN 1
            ELSE 0
        END) AS jours_presents,
    round((((sum(
        CASE
            WHEN (p."IdStatutPresenceFk" = 25) THEN 1
            ELSE 0
        END))::numeric * 100.0) / (count(*))::numeric), 2) AS taux_presence,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Presence" p
     JOIN public."T_Utilisateurs" u ON ((p."IdControleFk" = u."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  WHERE (p."IdStatutPresenceFk" = 25)
  GROUP BY p."IdControleFk", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_NombrePresenceUtilisateur" OWNER TO postgres;

--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 278
-- Name: VIEW "VS_NombrePresenceUtilisateur"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombrePresenceUtilisateur" IS 'Statistiques des présences des Utilisateurs';


--
-- TOC entry 287 (class 1259 OID 42830)
-- Name: VS_NombrePresencesHebdomadaires; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_NombrePresencesHebdomadaires" AS
 SELECT EXTRACT(year FROM p."DatePresence") AS annee,
    EXTRACT(week FROM p."DatePresence") AS semaine,
    count(
        CASE
            WHEN ((g."NomGenerique")::text = 'Présent(e)'::text) THEN 1
            ELSE NULL::integer
        END) AS nombre_presences,
    count(
        CASE
            WHEN ((g."NomGenerique")::text = 'Absent(e)'::text) THEN 1
            ELSE NULL::integer
        END) AS nombre_absences,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Presence" p
     JOIN public."T_Generique" g ON ((p."IdStatutPresenceFk" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  GROUP BY (EXTRACT(year FROM p."DatePresence")), (EXTRACT(week FROM p."DatePresence")), p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_NombrePresencesHebdomadaires" OWNER TO postgres;

--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 287
-- Name: VIEW "VS_NombrePresencesHebdomadaires"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_NombrePresencesHebdomadaires" IS 'Suivi des présences hebdomadaires';


--
-- TOC entry 285 (class 1259 OID 42820)
-- Name: VS_PaiementApprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_PaiementApprenant" AS
 SELECT concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_apprenant,
    count(p."IdPaiement") AS nombre_paiements,
    sum(p."MontantPaiement") AS montant_total,
    g_devise."NomGenerique" AS nom_devise,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM ((((public."T_Paiement" p
     JOIN public."T_Utilisateurs" u ON ((p."IdPayeurFk" = u."IdUser")))
     JOIN public."T_Apprenant" a ON ((u."IdUser" = a."IdUserFk")))
     LEFT JOIN public."T_Generique" g_devise ON ((p."IdDeviseFk" = g_devise."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  GROUP BY (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g_devise."NomGenerique", p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_PaiementApprenant" OWNER TO postgres;

--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 285
-- Name: VIEW "VS_PaiementApprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_PaiementApprenant" IS 'Nombre de paiements effectués par apprenant';


--
-- TOC entry 282 (class 1259 OID 42805)
-- Name: VS_PaiementDevise; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_PaiementDevise" AS
 SELECT g."NomGenerique" AS devise,
    count(p."IdPaiement") AS nombre_paiements,
    sum(p."MontantPaiement") AS montant_total,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Paiement" p
     JOIN public."T_Generique" g ON ((p."IdDeviseFk" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g."NomGenerique", p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_PaiementDevise" OWNER TO postgres;

--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 282
-- Name: VIEW "VS_PaiementDevise"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_PaiementDevise" IS 'Répartition des paiements par devise';


--
-- TOC entry 265 (class 1259 OID 42706)
-- Name: VS_PaiementMensuels; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_PaiementMensuels" AS
 SELECT EXTRACT(year FROM p."DatePaiement") AS annee,
    EXTRACT(month FROM p."DatePaiement") AS mois,
    count(p."IdPaiement") AS nombre_paiements,
    sum(p."MontantPaiement") AS montant_total,
    devise."NomGenerique" AS "Devise",
    p."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Paiement" p
     LEFT JOIN public."T_Generique" devise ON ((p."IdDeviseFk" = devise."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  GROUP BY (EXTRACT(year FROM p."DatePaiement")), (EXTRACT(month FROM p."DatePaiement")), devise."NomGenerique", p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_PaiementMensuels" OWNER TO postgres;

--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 265
-- Name: VIEW "VS_PaiementMensuels"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_PaiementMensuels" IS 'Nombre de paiements effectués par mois';


--
-- TOC entry 267 (class 1259 OID 42721)
-- Name: VS_PaiementStatut; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_PaiementStatut" AS
 SELECT g."NomGenerique" AS statut_paiement,
    count(p."IdPaiement") AS nombre_paiements,
    sum(p."MontantPaiement") AS montant_total,
    devise."NomGenerique" AS devise,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Paiement" p
     JOIN public."T_Generique" g ON ((p."IdStatutPaiementFk" = g."IdGenerique")))
     JOIN public."T_Generique" devise ON ((p."IdDeviseFk" = devise."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g."NomGenerique", devise."NomGenerique", p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_PaiementStatut" OWNER TO postgres;

--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 267
-- Name: VIEW "VS_PaiementStatut"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_PaiementStatut" IS 'Répartition des paiements par statut';


--
-- TOC entry 293 (class 1259 OID 42905)
-- Name: VS_ProgressionApprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_ProgressionApprenant" AS
 SELECT u."IdUser",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS enseignant,
    g_typeeva."NomGenerique" AS type_evaluation,
    min(ev."NoteEvaluation") AS premiere_note,
    max(ev."NoteEvaluation") AS derniere_note,
    round(avg(ev."NoteEvaluation"), 2) AS moyenne_generale,
    ev."IdEntiteFk",
    ent."NomEntite"
   FROM ((((public."T_Evaluations" ev
     JOIN public."T_Utilisateurs" u ON ((ev."IdCibleFk" = u."IdUser")))
     JOIN public."T_Apprenant" a ON ((ev."IdCibleFk" = a."IdUserFk")))
     JOIN public."T_Generique" g_typeeva ON ((ev."IdTypeEvaluationFk" = g_typeeva."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((ev."IdEntiteFk" = ent."IdEntite")))
  GROUP BY u."IdUser", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g_typeeva."NomGenerique", ev."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_ProgressionApprenant" OWNER TO postgres;

--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 293
-- Name: VIEW "VS_ProgressionApprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_ProgressionApprenant" IS 'Vue progession des apprenants par évaluation';


--
-- TOC entry 294 (class 1259 OID 42910)
-- Name: VS_RepartitionNotesEvaluation; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_RepartitionNotesEvaluation" AS
 SELECT ev."NoteEvaluation",
    g_typeeva."NomGenerique" AS type_evaluation,
    count(*) AS nombre_notes,
    ev."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Evaluations" ev
     JOIN public."T_Generique" g_typeeva ON ((ev."IdTypeEvaluationFk" = g_typeeva."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((ev."IdEntiteFk" = ent."IdEntite")))
  GROUP BY ev."NoteEvaluation", g_typeeva."NomGenerique", ev."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_RepartitionNotesEvaluation" OWNER TO postgres;

--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 294
-- Name: VIEW "VS_RepartitionNotesEvaluation"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_RepartitionNotesEvaluation" IS 'Vue repartition des notes par évaluation';


--
-- TOC entry 262 (class 1259 OID 42693)
-- Name: VS_SpecialiteEnseignant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_SpecialiteEnseignant" AS
 SELECT e."IdSpecialiteEnseignantFk",
    g."NomGenerique" AS specialite_enseignant,
    count(e."IdEnseignant") AS nombre_enseignants,
    e."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Enseignant" e
     LEFT JOIN public."T_Generique" g ON ((e."IdSpecialiteEnseignantFk" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
  GROUP BY e."IdSpecialiteEnseignantFk", g."NomGenerique", e."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_SpecialiteEnseignant" OWNER TO postgres;

--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 262
-- Name: VIEW "VS_SpecialiteEnseignant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_SpecialiteEnseignant" IS 'Nombre total d''enseignants par spécialité';


--
-- TOC entry 266 (class 1259 OID 42716)
-- Name: VS_TauxAbsenceApprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_TauxAbsenceApprenant" AS
 SELECT EXTRACT(year FROM p."DatePresence") AS annee,
    EXTRACT(month FROM p."DatePresence") AS mois,
    p."IdControleFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS apprenant,
    g_statutpresence."NomGenerique" AS statut_presence,
    count(*) AS total_jours,
    sum(
        CASE
            WHEN ((g_statutpresence."NomGenerique")::text = 'Absent'::text) THEN 1
            ELSE 0
        END) AS jours_absences,
    round((((sum(
        CASE
            WHEN ((g_statutpresence."NomGenerique")::text = 'Absent'::text) THEN 1
            ELSE 0
        END))::numeric * 100.0) / (count(*))::numeric), 2) AS taux_absenteisme,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Presence" p
     JOIN public."T_Utilisateurs" u ON ((p."IdControleFk" = u."IdUser")))
     JOIN public."T_Generique" g_statutpresence ON ((p."IdStatutPresenceFk" = g_statutpresence."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  GROUP BY p."IdControleFk", (EXTRACT(year FROM p."DatePresence")), (EXTRACT(month FROM p."DatePresence")), (concat_ws(' '::text, u."NomUser", u."PrenomUser")), g_statutpresence."NomGenerique", p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_TauxAbsenceApprenant" OWNER TO postgres;

--
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 266
-- Name: VIEW "VS_TauxAbsenceApprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_TauxAbsenceApprenant" IS 'Taux d''absence par apprenant';


--
-- TOC entry 271 (class 1259 OID 42750)
-- Name: VS_TauxParticipationEvaluation; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_TauxParticipationEvaluation" AS
 SELECT g_niveau."NomGenerique" AS niveau_cours,
    g_typeeva."NomGenerique" AS type_evaluation,
    count(DISTINCT ev."IdCibleFk") AS apprenant_evalues,
    count(DISTINCT a."IdUserFk") AS apprenant_total,
    round((((count(DISTINCT ev."IdCibleFk"))::numeric * 100.0) / (count(DISTINCT a."IdUserFk"))::numeric), 2) AS taux_participation,
    ev."IdEntiteFk",
    ent."NomEntite"
   FROM ((((public."T_Evaluations" ev
     JOIN public."T_Apprenant" a ON ((ev."IdCibleFk" = a."IdUserFk")))
     JOIN public."T_Generique" g_typeeva ON ((ev."IdTypeEvaluationFk" = g_typeeva."IdGenerique")))
     JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((ev."IdEntiteFk" = ent."IdEntite")))
  GROUP BY g_niveau."NomGenerique", g_typeeva."NomGenerique", ev."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_TauxParticipationEvaluation" OWNER TO postgres;

--
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 271
-- Name: VIEW "VS_TauxParticipationEvaluation"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_TauxParticipationEvaluation" IS 'Taux de participation aux évaluations';


--
-- TOC entry 281 (class 1259 OID 42800)
-- Name: VS_TauxPresenceApprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_TauxPresenceApprenant" AS
 SELECT g."NomGenerique" AS statut_presence,
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS noms_apprenant,
    count(p."IdPresence") AS total_presences,
    round((((count(
        CASE
            WHEN ((g."NomGenerique")::text = 'Présent'::text) THEN 1
            ELSE NULL::integer
        END))::numeric * 100.0) / (count(p."IdPresence"))::numeric), 2) AS taux_presence,
    p."IdEntiteFk",
    ent."NomEntite"
   FROM (((public."T_Presence" p
     JOIN public."T_Utilisateurs" u ON ((p."IdControleFk" = u."IdUser")))
     JOIN public."T_Generique" g ON ((p."IdStatutPresenceFk" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
  WHERE (u."IdUser" IN ( SELECT "T_Apprenant"."IdUserFk"
           FROM public."T_Apprenant"))
  GROUP BY g."NomGenerique", (concat_ws(' '::text, u."NomUser", u."PrenomUser")), p."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_TauxPresenceApprenant" OWNER TO postgres;

--
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 281
-- Name: VIEW "VS_TauxPresenceApprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_TauxPresenceApprenant" IS 'Taux de présence moyen par élève';


--
-- TOC entry 318 (class 1259 OID 43378)
-- Name: VS_TauxReussiteApprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_TauxReussiteApprenant" AS
 WITH moyenne_notes AS (
         SELECT g_niveau."NomGenerique" AS niveau_cours,
            g_typeeva."NomGenerique" AS type_evaluation,
            ev."IdCibleFk",
            avg(ev."NoteEvaluation") AS moyenne_note,
            ev."IdEntiteFk",
            ent."NomEntite"
           FROM ((((public."T_Evaluations" ev
             JOIN public."T_Apprenant" a ON ((ev."IdCibleFk" = a."IdUserFk")))
             JOIN public."T_Generique" g_typeeva ON ((ev."IdTypeEvaluationFk" = g_typeeva."IdGenerique")))
             JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
             LEFT JOIN public."T_Entite" ent ON ((ev."IdEntiteFk" = ent."IdEntite")))
          GROUP BY g_niveau."NomGenerique", g_typeeva."NomGenerique", ev."IdCibleFk", ev."IdEntiteFk", ent."NomEntite"
        )
 SELECT niveau_cours,
    type_evaluation,
    count(*) AS nombre_apprenant,
    sum(
        CASE
            WHEN (moyenne_note >= (10)::numeric) THEN 1
            ELSE 0
        END) AS nombre_reussites,
    round((((sum(
        CASE
            WHEN (moyenne_note >= (10)::numeric) THEN 1
            ELSE 0
        END))::numeric * 100.0) / (count(*))::numeric), 2) AS taux_reussite,
    "IdEntiteFk",
    "NomEntite"
   FROM moyenne_notes mn
  GROUP BY niveau_cours, type_evaluation, "IdEntiteFk", "NomEntite";


ALTER VIEW public."VS_TauxReussiteApprenant" OWNER TO postgres;

--
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 318
-- Name: VIEW "VS_TauxReussiteApprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_TauxReussiteApprenant" IS 'Taux de réussite par niveau';


--
-- TOC entry 261 (class 1259 OID 42688)
-- Name: VS_UtilisateurRole; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VS_UtilisateurRole" AS
 SELECT u."IdRoleFk",
    g."NomGenerique" AS role_utilisateur,
    count(u."IdUser") AS nombre_utilisateurs,
    u."IdEntiteFk",
    ent."NomEntite"
   FROM ((public."T_Utilisateurs" u
     LEFT JOIN public."T_Generique" g ON ((u."IdRoleFk" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((u."IdEntiteFk" = ent."IdEntite")))
  GROUP BY u."IdRoleFk", g."NomGenerique", u."IdEntiteFk", ent."NomEntite";


ALTER VIEW public."VS_UtilisateurRole" OWNER TO postgres;

--
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 261
-- Name: VIEW "VS_UtilisateurRole"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."VS_UtilisateurRole" IS 'Nombre total d''utilisateurs par rôle';


--
-- TOC entry 310 (class 1259 OID 43297)
-- Name: V_ActivitesParascolaires; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_ActivitesParascolaires" AS
 SELECT a."NomActivite",
    a."DateActivite",
    a."HeureDebut",
    a."HeureFin",
    u."NomUser" AS nom_encadrant,
    u."PrenomUser" AS prenom_encadrant,
    a."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((public."T_ActivitesParascolaires" a
     LEFT JOIN public."T_Enseignant" e ON ((a."IdEncadrantFk" = e."IdEnseignant")))
     LEFT JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_ActivitesParascolaires" OWNER TO postgres;

--
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 310
-- Name: VIEW "V_ActivitesParascolaires"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_ActivitesParascolaires" IS 'Vue des activités parascolaires';


--
-- TOC entry 309 (class 1259 OID 43292)
-- Name: V_ActivitesParticipants; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_ActivitesParticipants" AS
 SELECT ap."IdApprenant",
    u."NomUser" AS nom_apprenant,
    u."PrenomUser" AS prenom_apprenant,
    u."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((public."T_ActiviteParticipants" p
     JOIN public."T_Apprenant" ap ON ((p."IdApprenantFk" = ap."IdApprenant")))
     JOIN public."T_Utilisateurs" u ON ((ap."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_ActivitesParticipants" OWNER TO postgres;

--
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 309
-- Name: VIEW "V_ActivitesParticipants"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_ActivitesParticipants" IS 'Vue des participants aux activités parascolaires';


--
-- TOC entry 311 (class 1259 OID 43302)
-- Name: V_Apprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Apprenant" AS
 SELECT a."IdApprenant",
    a."CodeApprenant",
    a."DateNaissanceApprenant",
    a."IdNiveauApprenantFk",
    g_niveau."NomGenerique" AS niveau_apprenant,
    a."IdParentApprenantFk",
    concat_ws(' '::text, parent."NomUser", parent."PrenomUser") AS parent,
    a."IdUserFk",
    apprenant."NomUser" AS nom_apprenant,
    apprenant."PrenomUser" AS prenom_apprenant,
    apprenant."EmailUser",
    apprenant."PhoneUser",
    apprenant."IdRoleFk",
    g_role."NomGenerique" AS role_apprenant,
    apprenant."ValideUser",
    a."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((((public."T_Apprenant" a
     JOIN public."T_Utilisateurs" apprenant ON ((apprenant."IdUser" = a."IdUserFk")))
     JOIN public."T_Utilisateurs" parent ON ((a."IdParentApprenantFk" = parent."IdUser")))
     LEFT JOIN public."T_Generique" g_role ON ((apprenant."IdRoleFk" = g_role."IdGenerique")))
     LEFT JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Apprenant" OWNER TO postgres;

--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 311
-- Name: VIEW "V_Apprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Apprenant" IS 'Vue des apprenants';


--
-- TOC entry 312 (class 1259 OID 43307)
-- Name: V_ApprenantsParent; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_ApprenantsParent" AS
 SELECT a."IdApprenant",
    apprenant."NomUser" AS nom_apprenant,
    apprenant."PrenomUser" AS prenom_apprenant,
    g_niveau."NomGenerique" AS niveau_apprenant,
    COALESCE(concat_ws(' '::text, parent."NomUser", parent."PrenomUser"), 'Non renseigné'::text) AS nom_parent,
    COALESCE(parent."PhoneUser", 'Non renseigné'::character varying) AS telephone_parent,
    a."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((((public."T_Apprenant" a
     JOIN public."T_Utilisateurs" apprenant ON ((a."IdUserFk" = apprenant."IdUser")))
     LEFT JOIN public."T_Utilisateurs" parent ON ((a."IdParentApprenantFk" = parent."IdUser")))
     LEFT JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_ApprenantsParent" OWNER TO postgres;

--
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 312
-- Name: VIEW "V_ApprenantsParent"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_ApprenantsParent" IS 'Vue des apprenants avec leurs parents';


--
-- TOC entry 307 (class 1259 OID 43192)
-- Name: V_Bulletin_Apprenant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Bulletin_Apprenant" AS
 SELECT a."IdApprenant",
    (((u."NomUser")::text || ' '::text) || (u."PrenomUser")::text) AS "Nom_Apprenant",
    g_niveau."NomGenerique" AS "Niveau",
    g_cours."NomGenerique" AS "Matière",
    e."NoteEvaluation" AS "Note",
    g_eval."NomGenerique" AS "Type_Evaluation",
    e."DateEvaluation" AS "Date_Evaluation",
    (((ens."NomUser")::text || ' '::text) || (ens."PrenomUser")::text) AS "Nom_Enseignant",
    e."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((((((((public."T_Evaluations" e
     JOIN public."T_Apprenant" a ON ((e."IdCibleFk" = a."IdUserFk")))
     JOIN public."T_Utilisateurs" u ON ((a."IdUserFk" = u."IdUser")))
     JOIN public."T_Cours" c ON ((e."IdCoursFk" = c."IdNomCoursFk")))
     JOIN public."T_Enseignant" en ON ((c."IdEnseignantFk" = en."IdEnseignant")))
     JOIN public."T_Utilisateurs" ens ON ((en."IdUserFk" = ens."IdUser")))
     LEFT JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Generique" g_eval ON ((e."IdTypeEvaluationFk" = g_eval."IdGenerique")))
     LEFT JOIN public."T_Generique" g_niveau ON ((a."IdNiveauApprenantFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Bulletin_Apprenant" OWNER TO postgres;

--
-- TOC entry 5501 (class 0 OID 0)
-- Dependencies: 307
-- Name: VIEW "V_Bulletin_Apprenant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Bulletin_Apprenant" IS 'Vue affichant les évaluations des apprenants avec détails des cours et enseignants';


--
-- TOC entry 297 (class 1259 OID 42938)
-- Name: V_Caisse; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Caisse" AS
 SELECT c."IdCaisse",
    c."IdDeviseFk",
    c."MontantCaisse" AS montant_caisse,
    g_devise."NomGenerique" AS nom_devise,
    c."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((public."T_Caisse" c
     JOIN public."T_Generique" g_devise ON ((c."IdDeviseFk" = g_devise."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((c."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Caisse" OWNER TO postgres;

--
-- TOC entry 5502 (class 0 OID 0)
-- Dependencies: 297
-- Name: VIEW "V_Caisse"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Caisse" IS 'vue caisse';


--
-- TOC entry 251 (class 1259 OID 42609)
-- Name: V_Communication; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Communication" AS
 SELECT c."IdCommunication",
    c."IdUserFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_utilisateur,
    c."IdTypeCommunication",
    g."NomGenerique" AS type_comm,
    c."ContenuCommunication",
    c."DateCommunication",
    c."ObsCommunication",
    c."ValideCommunication",
    c."LectureCommunication",
    c."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((public."T_Communication" c
     JOIN public."T_Utilisateurs" u ON ((c."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Generique" g ON ((c."IdTypeCommunication" = g."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((u."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Communication" OWNER TO postgres;

--
-- TOC entry 5503 (class 0 OID 0)
-- Dependencies: 251
-- Name: VIEW "V_Communication"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Communication" IS 'Vue des communications envoyées';


--
-- TOC entry 252 (class 1259 OID 42614)
-- Name: V_Cours; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Cours" AS
 SELECT c."IdCours",
    c."IdNomCoursFk",
    g_cours."NomGenerique" AS nom_cours,
    c."PonderationCours",
    c."PointMax",
    c."IdNiveauCoursFk",
    g_niveau."NomGenerique" AS niveau_cours,
    c."DescriptionCours",
    c."IdEnseignantFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_enseignant,
    c."ObsCours",
    c."ValideCours",
    c."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((((public."T_Cours" c
     JOIN public."T_Enseignant" e ON ((c."IdEnseignantFk" = e."IdEnseignant")))
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     JOIN public."T_Generique" g_niveau ON ((c."IdNiveauCoursFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((c."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Cours" OWNER TO postgres;

--
-- TOC entry 5504 (class 0 OID 0)
-- Dependencies: 252
-- Name: VIEW "V_Cours"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Cours" IS 'Vue des cours';


--
-- TOC entry 253 (class 1259 OID 42629)
-- Name: V_EmploisTemps; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_EmploisTemps" AS
 SELECT e."IdEmploisTemps",
    e."IdNomCoursFk",
    g_cours."NomGenerique" AS nom_cours,
    e."IdNiveauFk",
    g_niveau."NomGenerique" AS nom_niveau,
    e."JourSemaine",
    e."HeureDebut",
    e."HeureFin",
    e."ObsEmploisTemps",
    e."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((public."T_EmploisTemps" e
     LEFT JOIN public."T_Generique" g_cours ON ((e."IdNomCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Generique" g_niveau ON ((e."IdNiveauFk" = g_niveau."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_EmploisTemps" OWNER TO postgres;

--
-- TOC entry 5505 (class 0 OID 0)
-- Dependencies: 253
-- Name: VIEW "V_EmploisTemps"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_EmploisTemps" IS 'Vue des emplois du temps';


--
-- TOC entry 313 (class 1259 OID 43318)
-- Name: V_Enseignant; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Enseignant" AS
 SELECT e."IdEnseignant",
    e."CodeEnseignant",
    e."IdSpecialiteEnseignantFk",
    g."NomGenerique" AS specialite,
    concat_ws(' '::text, e."SalaireEnseignant", g_devise."NomGenerique") AS salaire_enseignant,
    e."IdDeviseFk",
    g_devise."NomGenerique" AS nom_devise,
    e."DateEmbaucheEnseignant",
    e."ValideEnseignant",
    u."NomUser" AS nom_enseignant,
    u."PrenomUser" AS prenom_enseignant,
    u."EmailUser",
    u."PhoneUser",
    u."IdRoleFk",
    r."NomGenerique" AS roles,
    u."ValideUser",
    u."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((((public."T_Enseignant" e
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Generique" g ON ((e."IdSpecialiteEnseignantFk" = g."IdGenerique")))
     LEFT JOIN public."T_Generique" r ON ((u."IdRoleFk" = r."IdGenerique")))
     LEFT JOIN public."T_Generique" g_devise ON ((e."IdDeviseFk" = g_devise."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Enseignant" OWNER TO postgres;

--
-- TOC entry 5506 (class 0 OID 0)
-- Dependencies: 313
-- Name: VIEW "V_Enseignant"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Enseignant" IS 'Vue des enseignants';


--
-- TOC entry 314 (class 1259 OID 43323)
-- Name: V_EnseignantSalaire; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_EnseignantSalaire" AS
 SELECT e."IdEnseignant",
    e."CodeEnseignant",
    e."IdUserFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_enseignant,
    e."IdSpecialiteEnseignantFk",
    g_specialite."NomGenerique",
    concat_ws(' '::text, e."SalaireEnseignant", g_devise."NomGenerique") AS salaire,
    e."IdDeviseFk",
    e."DateEmbaucheEnseignant",
    e."ValideEnseignant",
    e."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((((public."T_Enseignant" e
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Generique" g_specialite ON ((e."IdSpecialiteEnseignantFk" = g_specialite."IdGenerique")))
     LEFT JOIN public."T_Generique" g_devise ON ((e."IdDeviseFk" = g_devise."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_EnseignantSalaire" OWNER TO postgres;

--
-- TOC entry 5507 (class 0 OID 0)
-- Dependencies: 314
-- Name: VIEW "V_EnseignantSalaire"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_EnseignantSalaire" IS 'Vue des salaires des enseignants';


--
-- TOC entry 315 (class 1259 OID 43334)
-- Name: V_EnseignantsCours; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_EnseignantsCours" AS
 SELECT e."IdUserFk",
    e."IdEnseignant",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS nom_enseignant,
    e."IdSpecialiteEnseignantFk",
    g."NomGenerique" AS specialite,
    c."IdCours",
    g_cours."NomGenerique" AS nom_cours,
    c."DescriptionCours",
    c."ValideCours",
    c."ObsCours",
    u."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((((public."T_Enseignant" e
     JOIN public."T_Utilisateurs" u ON ((e."IdUserFk" = u."IdUser")))
     LEFT JOIN public."T_Generique" g ON ((e."IdSpecialiteEnseignantFk" = g."IdGenerique")))
     LEFT JOIN public."T_Cours" c ON ((c."IdEnseignantFk" = e."IdEnseignant")))
     LEFT JOIN public."T_Generique" g_cours ON ((c."IdNomCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((u."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_EnseignantsCours" OWNER TO postgres;

--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 315
-- Name: VIEW "V_EnseignantsCours"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_EnseignantsCours" IS 'Vue des enseignants avec leurs spécialités et leurs cours';


--
-- TOC entry 305 (class 1259 OID 43177)
-- Name: V_Entite; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Entite" AS
 SELECT ent."IdEntite",
    ent."NomEntite",
    g_type."NomGenerique" AS type_entite,
    ent."PhoneEntite",
    ent."EmailEntite",
    ent."AdresseEntite",
    ent."DateCreationEntite",
    ent."ValideEntite"
   FROM (public."T_Entite" ent
     JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Entite" OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 42639)
-- Name: V_Evaluations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Evaluations" AS
 SELECT e."DateEvaluation",
    e."IdEvaluation",
    e."IdTypeEvaluationFk",
    g."NomGenerique" AS type_evaluation,
    e."CodeEvaluation",
    e."IdCibleFk",
    concat_ws(' '::text, u_cible."NomUser", u_cible."PrenomUser") AS nom_apprenant,
    e."IdEvaluateurFk",
    concat_ws(' '::text, u_evaluateur."NomUser", u_evaluateur."PrenomUser") AS nom_evaluateur,
    e."NoteEvaluation",
    e."IdCoursFk",
    g_cours."NomGenerique" AS nom_cours,
    e."ObsEvaluation",
    e."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((((public."T_Evaluations" e
     JOIN public."T_Utilisateurs" u_cible ON ((e."IdCibleFk" = u_cible."IdUser")))
     JOIN public."T_Utilisateurs" u_evaluateur ON ((e."IdEvaluateurFk" = u_evaluateur."IdUser")))
     LEFT JOIN public."T_Generique" g ON ((e."IdTypeEvaluationFk" = g."IdGenerique")))
     LEFT JOIN public."T_Generique" g_cours ON ((e."IdCoursFk" = g_cours."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((e."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Evaluations" OWNER TO postgres;

--
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 254
-- Name: VIEW "V_Evaluations"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Evaluations" IS 'Vue des evaluations';


--
-- TOC entry 255 (class 1259 OID 42644)
-- Name: V_Generique; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Generique" AS
 SELECT g."IdCategorieGeneriqueFk",
    cat_g."NomCategorieGenerique" AS categorie,
    g."IdGenerique",
    g."NomGenerique" AS nom,
    cat_g."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((public."T_Generique" g
     JOIN public."T_CategorieGenerique" cat_g ON ((cat_g."IdCategorieGenerique" = g."IdCategorieGeneriqueFk")))
     LEFT JOIN public."T_Entite" ent ON ((cat_g."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Generique" OWNER TO postgres;

--
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 255
-- Name: VIEW "V_Generique"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Generique" IS 'Vue des generiques';


--
-- TOC entry 306 (class 1259 OID 43187)
-- Name: V_Licence; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Licence" AS
 SELECT l."IdLicence",
    l."IdEntiteFk",
    ent."NomEntite",
    ent."IdTypeEntiteFk",
    g_typeentite."NomGenerique" AS type_entite,
    l."CleLicence",
    l."DateDebut",
    l."DateFin",
    l."IdStatutLicenceFk",
    g_statut."NomGenerique" AS statut,
    l."ValideLicence",
    l."ExpireeLicence"
   FROM (((public."T_Licence" l
     JOIN public."T_Entite" ent ON ((l."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_statut ON ((l."IdStatutLicenceFk" = g_statut."IdGenerique")))
     LEFT JOIN public."T_Generique" g_typeentite ON ((ent."IdTypeEntiteFk" = g_typeentite."IdGenerique")));


ALTER VIEW public."V_Licence" OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 42648)
-- Name: V_Login; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Login" AS
 SELECT l."DateLogin",
    l."IdLogin",
    l."IdUserFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS noms,
    u."IdRoleFk",
    g_role."NomGenerique" AS roles,
    l."IdTypeLoginFk",
    g_typelogin."NomGenerique" AS type_login,
    u."EmailUser",
    l."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((((public."T_Login" l
     JOIN public."T_Utilisateurs" u ON ((u."IdUser" = l."IdUserFk")))
     LEFT JOIN public."T_Generique" g_role ON ((u."IdRoleFk" = g_role."IdGenerique")))
     LEFT JOIN public."T_Generique" g_typelogin ON ((l."IdTypeLoginFk" = g_typelogin."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((l."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Login" OWNER TO postgres;

--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 256
-- Name: VIEW "V_Login"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Login" IS 'Vue des connexions des utilisateurs';


--
-- TOC entry 298 (class 1259 OID 42945)
-- Name: V_Paiement; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Paiement" AS
 SELECT p."IdPaiement",
    p."DatePaiement",
    p."CodePaiement",
    p."IdUserFk",
    concat(u."NomUser", u."PrenomUser") AS utilisateur,
    p."IdPayeurFk",
    concat(payeur."NomUser", payeur."PrenomUser") AS payeur,
    p."IdTypePaiementFk",
    g_typepaiement."NomGenerique" AS type_paiement,
    p."IdDeviseFk",
    concat_ws(' '::text, p."MontantPaiement", g_devise."NomGenerique") AS montant,
    p."IdStatutPaiementFk",
    g_statutpaiement."NomGenerique" AS statut,
    p."IdTypeMouvementFk",
    g_mouvement."NomGenerique" AS type_mouvement,
    p."ObsPaiement",
    p."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM ((((((((public."T_Paiement" p
     JOIN public."T_Utilisateurs" u ON ((p."IdUserFk" = u."IdUser")))
     JOIN public."T_Utilisateurs" payeur ON ((p."IdPayeurFk" = payeur."IdUser")))
     LEFT JOIN public."T_Generique" g_typepaiement ON ((p."IdTypePaiementFk" = g_typepaiement."IdGenerique")))
     LEFT JOIN public."T_Generique" g_statutpaiement ON ((p."IdStatutPaiementFk" = g_statutpaiement."IdGenerique")))
     LEFT JOIN public."T_Generique" g_devise ON ((p."IdDeviseFk" = g_devise."IdGenerique")))
     LEFT JOIN public."T_Generique" g_mouvement ON ((p."IdTypeMouvementFk" = g_mouvement."IdGenerique")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Paiement" OWNER TO postgres;

--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 298
-- Name: VIEW "V_Paiement"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Paiement" IS 'Vue des paiements';


--
-- TOC entry 257 (class 1259 OID 42658)
-- Name: V_Presence; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Presence" AS
 SELECT p."IdPresence",
    p."DatePresence",
    p."IdControleurFk",
    concat_ws(' '::text, c."NomUser", c."PrenomUser") AS controleur,
    p."IdControleFk",
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS controle,
    p."IdStatutPresenceFk",
    g."NomGenerique" AS type_presence,
    p."ValidePresence",
    p."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((((public."T_Presence" p
     JOIN public."T_Utilisateurs" u ON ((p."IdControleFk" = u."IdUser")))
     LEFT JOIN public."T_Generique" g ON ((p."IdStatutPresenceFk" = g."IdGenerique")))
     LEFT JOIN public."T_Utilisateurs" c ON ((p."IdControleurFk" = c."IdUser")))
     LEFT JOIN public."T_Entite" ent ON ((p."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Presence" OWNER TO postgres;

--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 257
-- Name: VIEW "V_Presence"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Presence" IS 'Vue des présences des apprenants';


--
-- TOC entry 258 (class 1259 OID 42663)
-- Name: V_Utilisateur; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_Utilisateur" AS
 SELECT a."DatecreationUser",
    a."IdUser",
    a."IdRoleFk",
    b."NomGenerique" AS roles,
    concat_ws(' '::text, a."NomUser", a."PrenomUser") AS noms,
    a."EmailUser" AS email,
    a."MotdepasseUser" AS mot_de_passe,
    a."PhoneUser" AS phone,
    a."ValideUser" AS valide,
    a."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((public."T_Utilisateurs" a
     LEFT JOIN public."T_Entite" ent ON ((a."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" b ON ((a."IdRoleFk" = b."IdGenerique")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_Utilisateur" OWNER TO postgres;

--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 258
-- Name: VIEW "V_Utilisateur"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_Utilisateur" IS 'Vue des utilisateurs';


--
-- TOC entry 259 (class 1259 OID 42668)
-- Name: V_UtilisateursGeneral; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."V_UtilisateursGeneral" AS
 SELECT u."IdUser",
    u."IdRoleFk",
    g_role."NomGenerique" AS roles,
    concat_ws(' '::text, u."NomUser", u."PrenomUser") AS noms,
    u."EmailUser",
    u."MotdepasseUser",
    u."PhoneUser",
    u."DatecreationUser",
    u."ValideUser",
    COALESCE(a."IdApprenant", e."IdEnseignant") AS idpersonne,
    COALESCE(a."CodeApprenant", e."CodeEnseignant") AS codepersonne,
        CASE
            WHEN (a."IdApprenant" IS NOT NULL) THEN 'Apprenant'::character varying
            WHEN (e."IdEnseignant" IS NOT NULL) THEN 'Enseignant'::character varying
            ELSE g_role."NomGenerique"
        END AS typeutilisateur,
    u."IdEntiteFk",
    ent."NomEntite",
    g_type."IdGenerique" AS id_type_entite,
    g_type."NomGenerique" AS type_entite
   FROM (((((public."T_Utilisateurs" u
     LEFT JOIN public."T_Generique" g_role ON ((u."IdRoleFk" = g_role."IdGenerique")))
     LEFT JOIN public."T_Apprenant" a ON ((u."IdUser" = a."IdUserFk")))
     LEFT JOIN public."T_Enseignant" e ON ((u."IdUser" = e."IdUserFk")))
     LEFT JOIN public."T_Entite" ent ON ((u."IdEntiteFk" = ent."IdEntite")))
     LEFT JOIN public."T_Generique" g_type ON ((ent."IdTypeEntiteFk" = g_type."IdGenerique")));


ALTER VIEW public."V_UtilisateursGeneral" OWNER TO postgres;

--
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 259
-- Name: VIEW "V_UtilisateursGeneral"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public."V_UtilisateursGeneral" IS 'Vue générale des tous les utilisateurs ';


--
-- TOC entry 220 (class 1259 OID 24712)
-- Name: utilisateurs_iduser_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utilisateurs_iduser_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utilisateurs_iduser_seq OWNER TO postgres;

--
-- TOC entry 5516 (class 0 OID 0)
-- Dependencies: 220
-- Name: utilisateurs_iduser_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utilisateurs_iduser_seq OWNED BY public."T_Utilisateurs"."IdUser";


--
-- TOC entry 5011 (class 2604 OID 25575)
-- Name: T_Audit_Log IdLog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Audit_Log" ALTER COLUMN "IdLog" SET DEFAULT nextval('public."T_Audit_Log_IdLog_seq"'::regclass);


--
-- TOC entry 5425 (class 0 OID 42187)
-- Dependencies: 247
-- Data for Name: T_ActiviteParticipants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_ActiviteParticipants" ("IdParticipant", "IdActiviteFk", "IdApprenantFk", "DateInscription", "IdEntiteFk") FROM stdin;
\.


--
-- TOC entry 5423 (class 0 OID 42172)
-- Dependencies: 245
-- Data for Name: T_ActivitesParascolaires; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_ActivitesParascolaires" ("IdActivite", "NomActivite", "DescriptionActivite", "DateActivite", "HeureDebut", "HeureFin", "IdEncadrantFk", "ValideActivite", "IdEntiteFk") FROM stdin;
4	Club de robotique	Initiation à la programmation .	2025-04-10	14:00:00	16:00:00	\N	t	1
5	Club de robotique	Initiation à la programmation .	2025-04-10	14:00:00	16:00:00	\N	t	1
6	Club de robotique	Initiation à la programmation .	2025-04-10	14:00:00	16:00:00	\N	t	1
\.


--
-- TOC entry 5403 (class 0 OID 24802)
-- Dependencies: 225
-- Data for Name: T_Apprenant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Apprenant" ("IdApprenant", "CodeApprenant", "DateNaissanceApprenant", "IdParentApprenantFk", "IdUserFk", "ValideApprenant", "AgeApprenant", "IdNiveauApprenantFk", "IdEntiteFk") FROM stdin;
8	El001                    	1995-03-18	8	9	t	30	59	1
\.


--
-- TOC entry 5420 (class 0 OID 25572)
-- Dependencies: 242
-- Data for Name: T_Audit_Log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Audit_Log" ("IdLog", "TableName", "Operation", "OldData", "NewData", "ChangedAt", "IdEntiteFk") FROM stdin;
108	T_Paiement	UPDATE	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 60.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 50.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	2025-03-26 18:34:46.1673	1
109	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 14, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:34:46.1673", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	2025-03-26 18:34:46.1673	\N
110	T_Enseignant	UPDATE	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdEnseignant": 3, "CodeEnseignant": "E001                     ", "ValideEnseignant": true, "SalaireEnseignant": 100, "DateEmbaucheEnseignant": "2025-03-18", "IdSpecialiteEnseignantFk": 5}	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdEnseignant": 3, "CodeEnseignant": "E001                     ", "ValideEnseignant": true, "SalaireEnseignant": 200, "DateEmbaucheEnseignant": "2025-03-18", "IdSpecialiteEnseignantFk": 5}	2025-03-26 18:36:58.269856	1
111	T_Paiement	UPDATE	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 50.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 60.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	2025-03-26 18:49:26.72593	1
112	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 15, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:49:26.72593", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 60.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	2025-03-26 18:49:26.72593	\N
113	T_Paiement	UPDATE	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 60.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	{"IdUserFk": 8, "IdDeviseFk": 37, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 60.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	2025-03-26 18:49:54.664159	1
114	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 16, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:49:54.664159", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 60.00 CDF a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	2025-03-26 18:49:54.664159	\N
115	T_Paiement	UPDATE	{"IdUserFk": 8, "IdDeviseFk": 37, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 60.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdPaiement": 2, "IdPayeurFk": 9, "ObsPaiement": "ok", "CodePaiement": "P001                     ", "DatePaiement": "2025-03-19T01:01:38.297805", "ValidePaiement": true, "MontantPaiement": 60.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	2025-03-26 18:50:21.563844	1
116	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 17, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:50:21.563844", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 60.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	2025-03-26 18:50:21.563844	\N
117	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 1, "ObsCommunication": null, "DateCommunication": "2025-03-19T00:54:41.824693", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre enfant PINGEDI Franklin est absent(e) aujourd'hui.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	1
118	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 2, "ObsCommunication": null, "DateCommunication": "2025-03-19T00:55:26.055985", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre enfant PINGEDI Franklin est absent(e) aujourd'hui.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	1
119	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 3, "ObsCommunication": null, "DateCommunication": "2025-03-19T00:57:09.736124", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre enfant PINGEDI Franklin est absent(e) aujourd'hui.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	1
120	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 4, "ObsCommunication": null, "DateCommunication": "2025-03-19T01:01:38.297805", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	1
121	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 8, "ObsCommunication": null, "DateCommunication": "2025-03-25T19:13:28.846557", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	1
122	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 9, "ObsCommunication": null, "DateCommunication": "2025-03-25T19:13:33.470962", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	1
123	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 10, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:13:31.375119", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	\N
124	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 13, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:33:59.252661", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 60.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	\N
125	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 14, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:34:46.1673", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	\N
126	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 15, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:49:26.72593", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 60.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	\N
127	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 16, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:49:54.664159", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 60.00 CDF a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	\N
128	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 17, "ObsCommunication": null, "DateCommunication": "2025-03-26T18:50:21.563844", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 60.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	\N	2025-03-26 18:54:57.417769	\N
131	T_Cours	INSERT	\N	{"IdCours": 4, "ObsCours": null, "PointMax": 100, "IdEntiteFk": 1, "ValideCours": true, "IdNomCoursFk": 47, "IdEnseignantFk": 3, "IdNiveauCoursFk": 59, "DescriptionCours": null, "PonderationCours": 4}	2025-03-26 19:01:36.565567	1
132	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 18, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:01:36.565567", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Un nouveau cours a été ajouté.", "LectureCommunication": false}	2025-03-26 19:01:36.565567	\N
133	T_Cours	DELETE	{"IdCours": 4, "ObsCours": null, "PointMax": 100, "IdEntiteFk": 1, "ValideCours": true, "IdNomCoursFk": 47, "IdEnseignantFk": 3, "IdNiveauCoursFk": 59, "DescriptionCours": null, "PonderationCours": 4}	\N	2025-03-26 19:06:28.545798	1
134	T_Cours	INSERT	\N	{"IdCours": 5, "ObsCours": null, "PointMax": 100, "IdEntiteFk": 1, "ValideCours": true, "IdNomCoursFk": 47, "IdEnseignantFk": 3, "IdNiveauCoursFk": 59, "DescriptionCours": null, "PonderationCours": 4}	2025-03-26 19:06:32.719166	1
135	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 19, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:06:32.719166", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Un nouveau cours a été ajouté.", "LectureCommunication": false}	2025-03-26 19:06:32.719166	1
136	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": null, "IdCommunication": 18, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:01:36.565567", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Un nouveau cours a été ajouté.", "LectureCommunication": false}	\N	2025-03-26 19:07:06.220915	\N
137	T_Communication	DELETE	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 19, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:06:32.719166", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Un nouveau cours a été ajouté.", "LectureCommunication": false}	\N	2025-03-26 19:07:06.220915	1
138	T_Cours	INSERT	\N	{"IdCours": 6, "ObsCours": null, "PointMax": 100, "IdEntiteFk": 1, "ValideCours": true, "IdNomCoursFk": 47, "IdEnseignantFk": 3, "IdNiveauCoursFk": 59, "DescriptionCours": null, "PonderationCours": 4}	2025-03-26 19:07:12.34067	1
139	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 20, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:07:12.34067", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Un nouveau cours a été ajouté.", "LectureCommunication": false}	2025-03-26 19:07:12.34067	1
140	T_Presence	DELETE	{"IdEntiteFk": 1, "IdPresence": 1, "DatePresence": "2025-03-19", "IdControleFk": 9, "IdControleurFk": 8, "ValidePresence": true, "IdStatutPresenceFk": 26}	\N	2025-03-26 19:12:47.880724	1
141	T_Presence	DELETE	{"IdEntiteFk": 1, "IdPresence": 2, "DatePresence": "2025-03-19", "IdControleFk": 9, "IdControleurFk": 8, "ValidePresence": true, "IdStatutPresenceFk": 26}	\N	2025-03-26 19:12:47.880724	1
142	T_Presence	DELETE	{"IdEntiteFk": 1, "IdPresence": 3, "DatePresence": "2025-03-19", "IdControleFk": 9, "IdControleurFk": 8, "ValidePresence": true, "IdStatutPresenceFk": 25}	\N	2025-03-26 19:12:47.880724	1
143	T_Presence	DELETE	{"IdEntiteFk": 1, "IdPresence": 4, "DatePresence": "2025-03-19", "IdControleFk": 9, "IdControleurFk": 8, "ValidePresence": true, "IdStatutPresenceFk": 25}	\N	2025-03-26 19:12:47.880724	1
144	T_Presence	DELETE	{"IdEntiteFk": 1, "IdPresence": 5, "DatePresence": "2025-03-19", "IdControleFk": 9, "IdControleurFk": 8, "ValidePresence": true, "IdStatutPresenceFk": 26}	\N	2025-03-26 19:12:47.880724	1
146	T_Presence	INSERT	\N	{"IdEntiteFk": 1, "IdPresence": 7, "DatePresence": "2025-03-26", "IdControleFk": 9, "IdControleurFk": 8, "ValidePresence": true, "IdStatutPresenceFk": 26}	2025-03-26 19:14:22.392663	1
147	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 21, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:14:22.392663", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre enfant PINGEDI Franklin est absent(e) aujourd'hui.", "LectureCommunication": false}	2025-03-26 19:14:22.392663	1
148	T_Evaluations	DELETE	{"IdCibleFk": 9, "IdCoursFk": 44, "IdEntiteFk": 1, "IdEvaluation": 5, "ObsEvaluation": null, "CodeEvaluation": "D001", "DateEvaluation": "2025-03-19T00:25:57.04562", "IdEvaluateurFk": 8, "NoteEvaluation": 10, "ValideEvaluation": true, "MaxNoteEvaluation": 10, "IdTypeEvaluationFk": 33}	\N	2025-03-26 19:20:08.314133	1
149	T_Evaluations	INSERT	\N	{"IdCibleFk": 9, "IdCoursFk": 44, "IdEntiteFk": 1, "IdEvaluation": 6, "ObsEvaluation": null, "CodeEvaluation": "D001", "DateEvaluation": "2025-03-26T19:20:46.983444", "IdEvaluateurFk": 8, "NoteEvaluation": 10, "ValideEvaluation": true, "MaxNoteEvaluation": 10, "IdTypeEvaluationFk": 33}	2025-03-26 19:20:46.983444	1
150	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 22, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:20:46.983444", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre enfant PINGEDI Franklin a obtenu une note de 10 sur 10 dans le cours de Mathématique.Evaluaion : Devoir.", "LectureCommunication": false}	2025-03-26 19:20:46.983444	1
151	T_Paiement	INSERT	\N	{"IdUserFk": 8, "IdDeviseFk": 36, "IdEntiteFk": 1, "IdPaiement": 3, "IdPayeurFk": 9, "ObsPaiement": null, "CodePaiement": "P001                     ", "DatePaiement": "2025-03-26T19:24:20.116734", "ValidePaiement": true, "MontantPaiement": 50.00, "IdTypePaiementFk": 18, "IdTypeMouvementFk": 81, "IdStatutPaiementFk": 21}	2025-03-26 19:24:20.116734	1
152	T_Communication	INSERT	\N	{"IdUserFk": 8, "IdEntiteFk": 1, "IdCommunication": 23, "ObsCommunication": null, "DateCommunication": "2025-03-26T19:24:20.116734", "IdTypeCommunication": 28, "ValideCommunication": true, "ContenuCommunication": "Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.", "LectureCommunication": false}	2025-03-26 19:24:20.116734	1
\.


--
-- TOC entry 5430 (class 0 OID 42926)
-- Dependencies: 296
-- Data for Name: T_Caisse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Caisse" ("IdCaisse", "IdDeviseFk", "MontantCaisse", "IdEntiteFk") FROM stdin;
2	37	0.00	1
1	36	110.00	1
\.


--
-- TOC entry 5396 (class 0 OID 24635)
-- Dependencies: 218
-- Data for Name: T_CategorieGenerique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_CategorieGenerique" ("IdCategorieGenerique", "NomCategorieGenerique", "ModuleCategorieGenerique", "ValideCategorieGenerique", "IdEntiteFk") FROM stdin;
1	Role	\N	t	1
2	Type Enseignant	\N	t	1
3	Poste	\N	t	1
4	Mode paiement	\N	t	1
5	Fonction	\N	t	1
7	Type de caisse	\N	t	1
8	Condition de paiement	\N	t	1
9	Spécialité	\N	t	1
10	Type paiement	\N	t	1
11	Statut paiement	\N	t	1
12	Type utilisateur	\N	t	1
13	Statut presence	\N	t	1
14	Type communication	\N	t	1
15	Type evaluation	\N	t	1
17	Devise	\N	t	1
18	Cours	\N	t	1
19	Niveau	\N	t	1
16	Type login	\N	t	1
21	Type mouvement paiement	\N	t	1
22	Statut licence	\N	t	1
23	Type entite	\N	t	1
\.


--
-- TOC entry 5413 (class 0 OID 25013)
-- Dependencies: 235
-- Data for Name: T_Communication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Communication" ("IdCommunication", "IdUserFk", "IdTypeCommunication", "ContenuCommunication", "DateCommunication", "ObsCommunication", "ValideCommunication", "LectureCommunication", "IdEntiteFk") FROM stdin;
20	8	28	Un nouveau cours a été ajouté.	2025-03-26 19:07:12.34067	\N	t	f	1
21	8	28	Votre enfant PINGEDI Franklin est absent(e) aujourd'hui.	2025-03-26 19:14:22.392663	\N	t	f	1
22	8	28	Votre enfant PINGEDI Franklin a obtenu une note de 10 sur 10 dans le cours de Mathématique.Evaluaion : Devoir.	2025-03-26 19:20:46.983444	\N	t	f	1
23	8	28	Votre paiement de 50.00 USD a été reçu avec succès. Statut: Payé(e), Mouvement: Entrée.	2025-03-26 19:24:20.116734	\N	t	f	1
\.


--
-- TOC entry 5410 (class 0 OID 24977)
-- Dependencies: 232
-- Data for Name: T_Cours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Cours" ("IdCours", "DescriptionCours", "IdEnseignantFk", "ObsCours", "ValideCours", "PonderationCours", "PointMax", "IdNiveauCoursFk", "IdNomCoursFk", "IdEntiteFk") FROM stdin;
1	\N	3	\N	t	4	100	59	44	1
5	\N	3	\N	t	4	100	59	47	1
6	\N	3	\N	t	4	100	59	47	1
\.


--
-- TOC entry 5412 (class 0 OID 24996)
-- Dependencies: 234
-- Data for Name: T_EmploisTemps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_EmploisTemps" ("IdEmploisTemps", "IdNomCoursFk", "JourSemaine", "HeureDebut", "HeureFin", "ObsEmploisTemps", "ValideEmploisTemps", "IdNiveauFk", "IdEntiteFk") FROM stdin;
\.


--
-- TOC entry 5402 (class 0 OID 24758)
-- Dependencies: 224
-- Data for Name: T_Enseignant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Enseignant" ("IdEnseignant", "IdUserFk", "IdSpecialiteEnseignantFk", "SalaireEnseignant", "DateEmbaucheEnseignant", "ValideEnseignant", "CodeEnseignant", "IdDeviseFk", "IdEntiteFk") FROM stdin;
3	8	5	200	2025-03-18	t	E001                     	36	1
\.


--
-- TOC entry 5436 (class 0 OID 43145)
-- Dependencies: 304
-- Data for Name: T_Entite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Entite" ("IdEntite", "NomEntite", "PhoneEntite", "EmailEntite", "AdresseEntite", "DateCreationEntite", "IdTypeEntiteFk", "ValideEntite") FROM stdin;
1	École Kengel	+243900000000	contact@ecolekengel.com	123 Avenue de l'Éducation, Kinshasa	2025-03-19 11:14:47.893202	84	t
\.


--
-- TOC entry 5408 (class 0 OID 24938)
-- Dependencies: 230
-- Data for Name: T_Evaluations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Evaluations" ("IdEvaluation", "IdCibleFk", "IdEvaluateurFk", "NoteEvaluation", "ObsEvaluation", "DateEvaluation", "IdTypeEvaluationFk", "CodeEvaluation", "ValideEvaluation", "IdCoursFk", "MaxNoteEvaluation", "IdEntiteFk") FROM stdin;
6	9	8	10	\N	2025-03-26 19:20:46.983444	33	D001	t	44	10	1
\.


--
-- TOC entry 5395 (class 0 OID 24632)
-- Dependencies: 217
-- Data for Name: T_Generique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Generique" ("IdGenerique", "NomGenerique", "CodeGenerique", "ObsGenerique", "ValideGenerique", "IdCategorieGeneriqueFk") FROM stdin;
1	Admin	Admin	\N	t	1
2	Manager	Manager	\N	t	1
4	User	User	\N	t	1
5	Mathématique	Maths	\N	t	9
6	Informatique	Info	\N	t	9
7	Physique	Phys	\N	t	9
8	Chimie	Chimie	\N	t	9
9	Biologie	Bio	\N	t	9
10	Économie	Econo	\N	t	9
11	Gestion	Gestion	\N	t	9
12	Statistiques	Stats	\N	t	9
13	Ingénierie	Ingenierie	\N	t	9
14	Médecine	Med	\N	t	9
15	Droit	Droit	\N	t	9
16	Architecture	Arch	\N	t	9
3	Super-admin	Super-admin	\N	t	1
18	Frais scolaires	Frais scolaires	\N	t	10
19	Salaire	Salaire	\N	t	10
20	En attente	En attente	\N	t	11
21	Payé(e)	Payé(e)	\N	t	11
22	Annulé(e)	Annulé(e)	\N	t	11
23	Eleve	Eleve	\N	t	12
24	Enseignant(e)	Enseignant(e)	\N	t	12
25	Présent(e)	Présent(e)	\N	t	13
26	Absent(e)	Absent(e)	\N	t	13
27	Retard	Retard	\N	t	13
28	Notification	Notification	\N	t	14
29	Message	Message	\N	t	14
30	Annonce	Annonce	\N	t	14
31	Interrogation	Interrogation	\N	t	15
32	Examen	Examen	\N	t	15
33	Devoir	Devoir	\N	t	15
34	Connexion	Connexion	\N	t	16
35	Déconnexion	Déconnexion	\N	t	16
36	USD	USD	\N	t	17
37	CDF	CDF	\N	t	17
41	Avertissement	Avertissement	\N	t	14
42	Rappel	Rappel	\N	t	14
43	En retard	En retard	\N	t	11
44	Mathématique	Mathématique	\N	t	18
45	Français	Français	\N	t	18
46	Physique	Physique	\N	t	18
47	Chimie	Chimie	\N	t	18
48	Biologie	Biologie	\N	t	18
49	Informatique	Informatique	\N	t	18
50	Histoire	Histoire	\N	t	18
51	Géographie	Géographie	\N	t	18
52	Anglais	Anglais	\N	t	18
53	Espagnol	Espagnol	\N	t	18
54	Philosophie	Philosophie	\N	t	18
55	Éducation Physique	EPS	\N	t	18
56	Musique	Musique	\N	t	18
57	Art	Art	\N	t	18
58	Économie	Économie	\N	t	18
59	1ère Maternelle	1M	Maternelle	t	19
60	2ème Maternelle	2M	Maternelle	t	19
61	3ème Maternelle	3M	Maternelle	t	19
62	1ère Primaire	1P	Primaire	t	19
63	2ème Primaire	2P	Primaire	t	19
64	3ème Primaire	3P	Primaire	t	19
65	4ème Primaire	4P	Primaire	t	19
66	5ème Primaire	5P	Primaire	t	19
67	6ème Primaire	6P	Primaire	t	19
68	6ème	6C	Collège	t	19
69	5ème	5C	Collège	t	19
70	4ème	4C	Collège	t	19
71	3ème	3C	Collège	t	19
72	Seconde	2L	Lycée	t	19
73	Première	1L	Lycée	t	19
74	Terminale	TL	Lycée	t	19
75	1ère année Université	1U	Université	t	19
76	2ème année Université	2U	Université	t	19
77	3ème année Université	3U	Université	t	19
78	4ème année Université	4U	Université	t	19
79	5ème année Université	5U	Université	t	19
80	Sortie	Sortie	\N	t	21
81	Entrée	Entrée	\N	t	21
84	Ecole	Ecole	\N	t	23
85	Université	Université	\N	t	23
82	Active	Active	\N	t	22
83	Inactive	Inactive	\N	t	22
86	Admin Entité	Admin Entité	\N	t	1
\.


--
-- TOC entry 5434 (class 0 OID 43122)
-- Dependencies: 302
-- Data for Name: T_Licence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Licence" ("IdLicence", "IdEntiteFk", "CleLicence", "DateDebut", "DateFin", "IdStatutLicenceFk", "ValideLicence", "ExpireeLicence") FROM stdin;
1	1	9ad27627-8db2-4c05-8c7e-ecb4a0a24f83	2025-03-19 11:27:27.80327	2026-03-18 00:00:00	82	t	f
\.


--
-- TOC entry 5416 (class 0 OID 25038)
-- Dependencies: 238
-- Data for Name: T_Login; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Login" ("IdLogin", "IdUserFk", "IdTypeLoginFk", "DateLogin", "IdEntiteFk") FROM stdin;
1	8	34	2025-03-18 23:09:33.500575+01	1
\.


--
-- TOC entry 5404 (class 0 OID 24846)
-- Dependencies: 226
-- Data for Name: T_Paiement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Paiement" ("IdPaiement", "CodePaiement", "IdUserFk", "IdTypePaiementFk", "MontantPaiement", "IdStatutPaiementFk", "DatePaiement", "ObsPaiement", "ValidePaiement", "IdDeviseFk", "IdPayeurFk", "IdTypeMouvementFk", "IdEntiteFk") FROM stdin;
2	P001                     	8	18	60.00	21	2025-03-19 01:01:38.297805	ok	t	36	9	81	1
3	P001                     	8	18	50.00	21	2025-03-26 19:24:20.116734	\N	t	36	9	81	1
\.


--
-- TOC entry 5428 (class 0 OID 42352)
-- Dependencies: 250
-- Data for Name: T_Paiement_Archive; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Paiement_Archive" ("IdPaiement", "CodePaiement", "IdUserFk", "IdTypePaiementFk", "MontantPaiement", "IdStatutPaiementFk", "DatePaiement", "ObsPaiement", "ValidePaiement", "IdDeviseFk", "IdPayeurFk", "IdTypeMouvementFk", "DateArchivage", "IdEntiteFk") FROM stdin;
\.


--
-- TOC entry 5418 (class 0 OID 25065)
-- Dependencies: 240
-- Data for Name: T_Presence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Presence" ("IdPresence", "IdControleurFk", "IdControleFk", "IdStatutPresenceFk", "DatePresence", "ValidePresence", "IdEntiteFk") FROM stdin;
7	8	9	26	2025-03-26	t	1
\.


--
-- TOC entry 5432 (class 0 OID 43002)
-- Dependencies: 300
-- Data for Name: T_Salle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Salle" ("IdSalle", "NomSalle", "CapaciteSalle", "IdEntiteFk") FROM stdin;
\.


--
-- TOC entry 5399 (class 0 OID 24713)
-- Dependencies: 221
-- Data for Name: T_Utilisateurs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_Utilisateurs" ("IdUser", "NomUser", "PrenomUser", "EmailUser", "MotdepasseUser", "PhoneUser", "DatecreationUser", "IdRoleFk", "ValideUser", "SexeUser", "DateModificationUser", "UrlPhoto", "IdEntiteFk") FROM stdin;
8	MUPANZI	Benjamin	john.doe@email.com	hashed_password_123	123456789	2025-03-18 22:58:20.168264	3	t	M	2025-03-25 19:10:48.360062	\N	1
9	PINGEDI	Franklin	jane.smith@email.com	hashed_password_456	987654321	2025-03-18 22:58:20.168264	4	t	M	2025-03-25 19:10:48.360062	\N	1
\.


--
-- TOC entry 5517 (class 0 OID 0)
-- Dependencies: 246
-- Name: T_ActiviteParticipants_IdParticipant_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_ActiviteParticipants_IdParticipant_seq"', 1, false);


--
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 249
-- Name: T_ActiviteParticipants_IdParticipant_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_ActiviteParticipants_IdParticipant_seq1"', 1, false);


--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 244
-- Name: T_ActivitesParascolaires_IdActivite_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_ActivitesParascolaires_IdActivite_seq"', 2, true);


--
-- TOC entry 5520 (class 0 OID 0)
-- Dependencies: 248
-- Name: T_ActivitesParascolaires_IdActivite_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_ActivitesParascolaires_IdActivite_seq1"', 6, true);


--
-- TOC entry 5521 (class 0 OID 0)
-- Dependencies: 241
-- Name: T_Audit_Log_IdLog_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Audit_Log_IdLog_seq"', 152, true);


--
-- TOC entry 5522 (class 0 OID 0)
-- Dependencies: 295
-- Name: T_Caisse_IdCaisse_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Caisse_IdCaisse_seq"', 2, true);


--
-- TOC entry 5523 (class 0 OID 0)
-- Dependencies: 219
-- Name: T_CategorieGenerique_IdCategorieGenerique_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_CategorieGenerique_IdCategorieGenerique_seq"', 23, true);


--
-- TOC entry 5524 (class 0 OID 0)
-- Dependencies: 243
-- Name: T_Communication_IdCommunication_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Communication_IdCommunication_seq"', 23, true);


--
-- TOC entry 5525 (class 0 OID 0)
-- Dependencies: 233
-- Name: T_Cours_IdCours_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Cours_IdCours_seq"', 6, true);


--
-- TOC entry 5526 (class 0 OID 0)
-- Dependencies: 236
-- Name: T_EmploisTemps_IdEmploisTemps_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_EmploisTemps_IdEmploisTemps_seq"', 1, false);


--
-- TOC entry 5527 (class 0 OID 0)
-- Dependencies: 227
-- Name: T_Enseignant_IdEnseigant_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Enseignant_IdEnseigant_seq"', 3, true);


--
-- TOC entry 5528 (class 0 OID 0)
-- Dependencies: 228
-- Name: T_Enseignes_IdEnseignes_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Enseignes_IdEnseignes_seq"', 8, true);


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 303
-- Name: T_Entite_IdEntite_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Entite_IdEntite_seq"', 1, true);


--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 231
-- Name: T_Evaluations_IdEvaluation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Evaluations_IdEvaluation_seq"', 6, true);


--
-- TOC entry 5531 (class 0 OID 0)
-- Dependencies: 223
-- Name: T_Generique_IdGenerique_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Generique_IdGenerique_seq"', 86, true);


--
-- TOC entry 5532 (class 0 OID 0)
-- Dependencies: 301
-- Name: T_Licence_IdLicence_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Licence_IdLicence_seq"', 1, true);


--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 237
-- Name: T_Login_IdLogin_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Login_IdLogin_seq"', 1, true);


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 229
-- Name: T_Paiement_IdPaiement_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Paiement_IdPaiement_seq"', 3, true);


--
-- TOC entry 5535 (class 0 OID 0)
-- Dependencies: 239
-- Name: T_Presence_IdPresence_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Presence_IdPresence_seq"', 7, true);


--
-- TOC entry 5536 (class 0 OID 0)
-- Dependencies: 299
-- Name: T_Salle_IdSalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Salle_IdSalle_seq"', 1, false);


--
-- TOC entry 5537 (class 0 OID 0)
-- Dependencies: 222
-- Name: T_Utilisateurs_IdUser_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_Utilisateurs_IdUser_seq"', 9, true);


--
-- TOC entry 5538 (class 0 OID 0)
-- Dependencies: 220
-- Name: utilisateurs_iduser_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilisateurs_iduser_seq', 1, false);


--
-- TOC entry 5042 (class 2606 OID 24762)
-- Name: T_Enseignant Pk_Enseignant; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Enseignant"
    ADD CONSTRAINT "Pk_Enseignant" PRIMARY KEY ("IdEnseignant");


--
-- TOC entry 5048 (class 2606 OID 24806)
-- Name: T_Apprenant Pk_IdApprenant; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Apprenant"
    ADD CONSTRAINT "Pk_IdApprenant" PRIMARY KEY ("IdApprenant");


--
-- TOC entry 5031 (class 2606 OID 24646)
-- Name: T_CategorieGenerique Pk_IdCategorieGenerique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_CategorieGenerique"
    ADD CONSTRAINT "Pk_IdCategorieGenerique" PRIMARY KEY ("IdCategorieGenerique");


--
-- TOC entry 5074 (class 2606 OID 25020)
-- Name: T_Communication Pk_IdCommunication; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Communication"
    ADD CONSTRAINT "Pk_IdCommunication" PRIMARY KEY ("IdCommunication");


--
-- TOC entry 5069 (class 2606 OID 24983)
-- Name: T_Cours Pk_IdCours; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Cours"
    ADD CONSTRAINT "Pk_IdCours" PRIMARY KEY ("IdCours");


--
-- TOC entry 5072 (class 2606 OID 25002)
-- Name: T_EmploisTemps Pk_IdEmploisTemps; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_EmploisTemps"
    ADD CONSTRAINT "Pk_IdEmploisTemps" PRIMARY KEY ("IdEmploisTemps");


--
-- TOC entry 5101 (class 2606 OID 43153)
-- Name: T_Entite Pk_IdEntite; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Entite"
    ADD CONSTRAINT "Pk_IdEntite" PRIMARY KEY ("IdEntite");


--
-- TOC entry 5063 (class 2606 OID 24945)
-- Name: T_Evaluations Pk_IdEvaluation; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Evaluations"
    ADD CONSTRAINT "Pk_IdEvaluation" PRIMARY KEY ("IdEvaluation");


--
-- TOC entry 5029 (class 2606 OID 24678)
-- Name: T_Generique Pk_IdGenerique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Generique"
    ADD CONSTRAINT "Pk_IdGenerique" PRIMARY KEY ("IdGenerique");


--
-- TOC entry 5097 (class 2606 OID 43131)
-- Name: T_Licence Pk_IdLicence; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Licence"
    ADD CONSTRAINT "Pk_IdLicence" PRIMARY KEY ("IdLicence");


--
-- TOC entry 5076 (class 2606 OID 25043)
-- Name: T_Login Pk_IdLogin; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Login"
    ADD CONSTRAINT "Pk_IdLogin" PRIMARY KEY ("IdLogin");


--
-- TOC entry 5055 (class 2606 OID 24851)
-- Name: T_Paiement Pk_IdPaiement; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Pk_IdPaiement" PRIMARY KEY ("IdPaiement");


--
-- TOC entry 5078 (class 2606 OID 25070)
-- Name: T_Presence Pk_IdPresence; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Presence"
    ADD CONSTRAINT "Pk_IdPresence" PRIMARY KEY ("IdPresence");


--
-- TOC entry 5033 (class 2606 OID 24721)
-- Name: T_Utilisateurs Pk_IdUser; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Utilisateurs"
    ADD CONSTRAINT "Pk_IdUser" PRIMARY KEY ("IdUser");


--
-- TOC entry 5089 (class 2606 OID 42193)
-- Name: T_ActiviteParticipants T_ActiviteParticipants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_ActiviteParticipants"
    ADD CONSTRAINT "T_ActiviteParticipants_pkey" PRIMARY KEY ("IdParticipant");


--
-- TOC entry 5087 (class 2606 OID 42180)
-- Name: T_ActivitesParascolaires T_ActivitesParascolaires_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_ActivitesParascolaires"
    ADD CONSTRAINT "T_ActivitesParascolaires_pkey" PRIMARY KEY ("IdActivite");


--
-- TOC entry 5085 (class 2606 OID 25580)
-- Name: T_Audit_Log T_Audit_Log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Audit_Log"
    ADD CONSTRAINT "T_Audit_Log_pkey" PRIMARY KEY ("IdLog");


--
-- TOC entry 5091 (class 2606 OID 42930)
-- Name: T_Caisse T_Caisse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Caisse"
    ADD CONSTRAINT "T_Caisse_pkey" PRIMARY KEY ("IdCaisse");


--
-- TOC entry 5050 (class 2606 OID 24808)
-- Name: T_Apprenant T_Enseignes_IdUserFk_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Apprenant"
    ADD CONSTRAINT "T_Enseignes_IdUserFk_key" UNIQUE ("IdUserFk");


--
-- TOC entry 5103 (class 2606 OID 43157)
-- Name: T_Entite T_Entite_EmailEntite_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Entite"
    ADD CONSTRAINT "T_Entite_EmailEntite_key" UNIQUE ("EmailEntite");


--
-- TOC entry 5105 (class 2606 OID 43155)
-- Name: T_Entite T_Entite_PhoneEntite_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Entite"
    ADD CONSTRAINT "T_Entite_PhoneEntite_key" UNIQUE ("PhoneEntite");


--
-- TOC entry 5095 (class 2606 OID 43008)
-- Name: T_Salle T_Salle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Salle"
    ADD CONSTRAINT "T_Salle_pkey" PRIMARY KEY ("IdSalle");


--
-- TOC entry 5093 (class 2606 OID 42965)
-- Name: T_Caisse UQ_IdDeviseFk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Caisse"
    ADD CONSTRAINT "UQ_IdDeviseFk" UNIQUE ("IdDeviseFk");


--
-- TOC entry 5040 (class 2606 OID 24723)
-- Name: T_Utilisateurs utilisateurs_emailuser_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Utilisateurs"
    ADD CONSTRAINT utilisateurs_emailuser_key UNIQUE ("EmailUser");


--
-- TOC entry 5034 (class 1259 OID 24747)
-- Name: fki_Fk_RoleFk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_Fk_RoleFk" ON public."T_Utilisateurs" USING btree ("IdRoleFk");


--
-- TOC entry 5043 (class 1259 OID 25545)
-- Name: idx_enseignant_nom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enseignant_nom ON public."T_Enseignant" USING btree ("IdUserFk");


--
-- TOC entry 5044 (class 1259 OID 25551)
-- Name: idx_enseignant_specialite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enseignant_specialite ON public."T_Enseignant" USING btree ("IdSpecialiteEnseignantFk");


--
-- TOC entry 5064 (class 1259 OID 25556)
-- Name: idx_evaluations_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_evaluations_date ON public."T_Evaluations" USING btree ("DateEvaluation");


--
-- TOC entry 5065 (class 1259 OID 25549)
-- Name: idx_evaluations_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_evaluations_type ON public."T_Evaluations" USING btree ("IdTypeEvaluationFk");


--
-- TOC entry 5051 (class 1259 OID 25535)
-- Name: idx_fk_apprenant_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_apprenant_parent ON public."T_Apprenant" USING btree ("IdParentApprenantFk");


--
-- TOC entry 5052 (class 1259 OID 25534)
-- Name: idx_fk_apprenant_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_apprenant_user ON public."T_Apprenant" USING btree ("IdUserFk");


--
-- TOC entry 5070 (class 1259 OID 25537)
-- Name: idx_fk_cours_enseignant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_cours_enseignant ON public."T_Cours" USING btree ("IdEnseignantFk");


--
-- TOC entry 5045 (class 1259 OID 25536)
-- Name: idx_fk_enseignant_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_enseignant_user ON public."T_Enseignant" USING btree ("IdUserFk");


--
-- TOC entry 5066 (class 1259 OID 25542)
-- Name: idx_fk_evaluations_cible; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_evaluations_cible ON public."T_Evaluations" USING btree ("IdCibleFk");


--
-- TOC entry 5067 (class 1259 OID 25543)
-- Name: idx_fk_evaluations_evaluateur; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_evaluations_evaluateur ON public."T_Evaluations" USING btree ("IdEvaluateurFk");


--
-- TOC entry 5098 (class 1259 OID 43142)
-- Name: idx_fk_licence_entite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_licence_entite ON public."T_Licence" USING btree ("IdEntiteFk");


--
-- TOC entry 5099 (class 1259 OID 43143)
-- Name: idx_fk_licence_statut; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_licence_statut ON public."T_Licence" USING btree ("IdStatutLicenceFk");


--
-- TOC entry 5056 (class 1259 OID 25539)
-- Name: idx_fk_paiement_statut; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_paiement_statut ON public."T_Paiement" USING btree ("IdStatutPaiementFk");


--
-- TOC entry 5057 (class 1259 OID 25538)
-- Name: idx_fk_paiement_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_paiement_user ON public."T_Paiement" USING btree ("IdUserFk");


--
-- TOC entry 5079 (class 1259 OID 25541)
-- Name: idx_fk_presence_statut; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_presence_statut ON public."T_Presence" USING btree ("IdStatutPresenceFk");


--
-- TOC entry 5080 (class 1259 OID 25540)
-- Name: idx_fk_presence_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_presence_user ON public."T_Presence" USING btree ("IdControleFk");


--
-- TOC entry 5058 (class 1259 OID 25554)
-- Name: idx_paiement_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_paiement_date ON public."T_Paiement" USING btree ("DatePaiement");


--
-- TOC entry 5059 (class 1259 OID 25552)
-- Name: idx_paiement_devise; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_paiement_devise ON public."T_Paiement" USING btree ("IdDeviseFk");


--
-- TOC entry 5060 (class 1259 OID 25547)
-- Name: idx_paiement_statut; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_paiement_statut ON public."T_Paiement" USING btree ("IdStatutPaiementFk");


--
-- TOC entry 5053 (class 1259 OID 25529)
-- Name: idx_pk_apprenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_pk_apprenant ON public."T_Apprenant" USING btree ("IdApprenant");


--
-- TOC entry 5046 (class 1259 OID 25530)
-- Name: idx_pk_enseignant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_pk_enseignant ON public."T_Enseignant" USING btree ("IdEnseignant");


--
-- TOC entry 5061 (class 1259 OID 25532)
-- Name: idx_pk_paiement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_pk_paiement ON public."T_Paiement" USING btree ("IdPaiement");


--
-- TOC entry 5081 (class 1259 OID 25533)
-- Name: idx_pk_presence; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_pk_presence ON public."T_Presence" USING btree ("IdPresence");


--
-- TOC entry 5035 (class 1259 OID 25531)
-- Name: idx_pk_utilisateur; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_pk_utilisateur ON public."T_Utilisateurs" USING btree ("IdUser");


--
-- TOC entry 5082 (class 1259 OID 25555)
-- Name: idx_presence_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_presence_date ON public."T_Presence" USING btree ("DatePresence");


--
-- TOC entry 5083 (class 1259 OID 25548)
-- Name: idx_presence_statut; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_presence_statut ON public."T_Presence" USING btree ("IdStatutPresenceFk");


--
-- TOC entry 5036 (class 1259 OID 25553)
-- Name: idx_utilisateur_date_creation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_utilisateur_date_creation ON public."T_Utilisateurs" USING btree ("DatecreationUser");


--
-- TOC entry 5037 (class 1259 OID 25544)
-- Name: idx_utilisateur_nom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_utilisateur_nom ON public."T_Utilisateurs" USING btree ("NomUser", "PrenomUser");


--
-- TOC entry 5038 (class 1259 OID 25550)
-- Name: idx_utilisateur_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_utilisateur_role ON public."T_Utilisateurs" USING btree ("IdRoleFk");


--
-- TOC entry 5169 (class 2620 OID 42846)
-- Name: T_Paiement trigger_archive_paiements; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_archive_paiements AFTER INSERT OR UPDATE ON public."T_Paiement" FOR EACH STATEMENT EXECUTE FUNCTION public.archive_paiements();

ALTER TABLE public."T_Paiement" DISABLE TRIGGER trigger_archive_paiements;


--
-- TOC entry 5183 (class 2620 OID 42878)
-- Name: T_ActiviteParticipants trigger_audit_T_ActiviteParticipants; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_ActiviteParticipants" AFTER INSERT OR DELETE OR UPDATE ON public."T_ActiviteParticipants" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5182 (class 2620 OID 42877)
-- Name: T_ActivitesParascolaires trigger_audit_T_ActivitesParascolaires; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_ActivitesParascolaires" AFTER INSERT OR DELETE OR UPDATE ON public."T_ActivitesParascolaires" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5167 (class 2620 OID 42879)
-- Name: T_Apprenant trigger_audit_T_Apprenant; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Apprenant" AFTER INSERT OR DELETE OR UPDATE ON public."T_Apprenant" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5161 (class 2620 OID 42868)
-- Name: T_CategorieGenerique trigger_audit_T_CategorieGenerique; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_CategorieGenerique" AFTER INSERT OR DELETE OR UPDATE ON public."T_CategorieGenerique" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5178 (class 2620 OID 42869)
-- Name: T_Communication trigger_audit_T_Communication; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Communication" AFTER INSERT OR DELETE OR UPDATE ON public."T_Communication" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5175 (class 2620 OID 42871)
-- Name: T_Cours trigger_audit_T_Cours; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Cours" AFTER INSERT OR DELETE OR UPDATE ON public."T_Cours" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5177 (class 2620 OID 42870)
-- Name: T_EmploisTemps trigger_audit_T_EmploisTemps; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_EmploisTemps" AFTER INSERT OR DELETE OR UPDATE ON public."T_EmploisTemps" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5166 (class 2620 OID 42876)
-- Name: T_Enseignant trigger_audit_T_Enseignant; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Enseignant" AFTER INSERT OR DELETE OR UPDATE ON public."T_Enseignant" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5173 (class 2620 OID 42866)
-- Name: T_Evaluations trigger_audit_T_Evaluations; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Evaluations" AFTER INSERT OR DELETE OR UPDATE ON public."T_Evaluations" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5160 (class 2620 OID 42867)
-- Name: T_Generique trigger_audit_T_Generique; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Generique" AFTER INSERT OR DELETE OR UPDATE ON public."T_Generique" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5179 (class 2620 OID 42872)
-- Name: T_Login trigger_audit_T_Login; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Login" AFTER INSERT OR DELETE OR UPDATE ON public."T_Login" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5170 (class 2620 OID 42875)
-- Name: T_Paiement trigger_audit_T_Paiement; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Paiement" AFTER INSERT OR DELETE OR UPDATE ON public."T_Paiement" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5185 (class 2620 OID 42880)
-- Name: T_Paiement_Archive trigger_audit_T_Paiement_Archive; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Paiement_Archive" AFTER INSERT OR DELETE OR UPDATE ON public."T_Paiement_Archive" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5180 (class 2620 OID 42873)
-- Name: T_Presence trigger_audit_T_Presence; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Presence" AFTER INSERT OR DELETE OR UPDATE ON public."T_Presence" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5162 (class 2620 OID 42874)
-- Name: T_Utilisateurs trigger_audit_T_Utilisateurs; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_T_Utilisateurs" AFTER INSERT OR DELETE OR UPDATE ON public."T_Utilisateurs" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5186 (class 2620 OID 43186)
-- Name: T_Licence trigger_audit_log_T_Licence; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trigger_audit_log_T_Licence" AFTER INSERT OR DELETE OR UPDATE ON public."T_Licence" FOR EACH ROW EXECUTE FUNCTION public.audit_log_function();


--
-- TOC entry 5168 (class 2620 OID 42858)
-- Name: T_Apprenant trigger_calculate_age_apprenant; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_calculate_age_apprenant BEFORE INSERT OR UPDATE ON public."T_Apprenant" FOR EACH ROW EXECUTE FUNCTION public.calculate_age_apprenant();


--
-- TOC entry 5163 (class 2620 OID 42856)
-- Name: T_Utilisateurs trigger_format_phone_number; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_format_phone_number BEFORE INSERT OR UPDATE ON public."T_Utilisateurs" FOR EACH ROW EXECUTE FUNCTION public.format_phone_number();


--
-- TOC entry 5171 (class 2620 OID 42952)
-- Name: T_Paiement trigger_gestion_caisse_on_paiement; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_gestion_caisse_on_paiement AFTER INSERT OR DELETE OR UPDATE ON public."T_Paiement" FOR EACH ROW EXECUTE FUNCTION public.gestion_caisse_on_paiement();


--
-- TOC entry 5176 (class 2620 OID 42854)
-- Name: T_Cours trigger_notification_new_course; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_notification_new_course AFTER INSERT ON public."T_Cours" FOR EACH ROW EXECUTE FUNCTION public.notification_new_course();


--
-- TOC entry 5181 (class 2620 OID 42860)
-- Name: T_Presence trigger_notification_parent_absence; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_notification_parent_absence AFTER INSERT ON public."T_Presence" FOR EACH ROW EXECUTE FUNCTION public.notification_parent_absence();


--
-- TOC entry 5184 (class 2620 OID 42864)
-- Name: T_ActiviteParticipants trigger_notification_parent_activite; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_notification_parent_activite AFTER INSERT ON public."T_ActiviteParticipants" FOR EACH ROW EXECUTE FUNCTION public.notification_parent_activite();


--
-- TOC entry 5174 (class 2620 OID 42848)
-- Name: T_Evaluations trigger_notification_parent_evaluation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_notification_parent_evaluation AFTER INSERT ON public."T_Evaluations" FOR EACH ROW EXECUTE FUNCTION public.notification_parent_evaluation();


--
-- TOC entry 5172 (class 2620 OID 42862)
-- Name: T_Paiement trigger_notification_payment_success; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_notification_payment_success AFTER INSERT OR UPDATE ON public."T_Paiement" FOR EACH ROW EXECUTE FUNCTION public.notification_payment_success();


--
-- TOC entry 5187 (class 2620 OID 43172)
-- Name: T_Licence trigger_notify_licence_expiry; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_notify_licence_expiry AFTER INSERT OR UPDATE ON public."T_Licence" FOR EACH ROW EXECUTE FUNCTION public.notify_licence_expiry();


--
-- TOC entry 5188 (class 2620 OID 43176)
-- Name: T_Licence trigger_prevent_multiple_licenses; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_prevent_multiple_licenses BEFORE INSERT ON public."T_Licence" FOR EACH ROW EXECUTE FUNCTION public.prevent_multiple_active_licenses();


--
-- TOC entry 5164 (class 2620 OID 42850)
-- Name: T_Utilisateurs trigger_prevention_delete_utilisateur; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_prevention_delete_utilisateur BEFORE DELETE ON public."T_Utilisateurs" FOR EACH ROW EXECUTE FUNCTION public.prevention_delete_if_dependent();


--
-- TOC entry 5165 (class 2620 OID 42852)
-- Name: T_Utilisateurs trigger_update_date_modification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_date_modification BEFORE UPDATE ON public."T_Utilisateurs" FOR EACH ROW EXECUTE FUNCTION public.update_date_modification();


--
-- TOC entry 5189 (class 2620 OID 43170)
-- Name: T_Licence trigger_update_licence_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_licence_status BEFORE INSERT OR UPDATE ON public."T_Licence" FOR EACH ROW EXECUTE FUNCTION public.update_licence_status();


--
-- TOC entry 5157 (class 2606 OID 43163)
-- Name: T_Licence Fk_Entite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Licence"
    ADD CONSTRAINT "Fk_Entite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 5150 (class 2606 OID 42194)
-- Name: T_ActiviteParticipants Fk_IdActivite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_ActiviteParticipants"
    ADD CONSTRAINT "Fk_IdActivite" FOREIGN KEY ("IdActiviteFk") REFERENCES public."T_ActivitesParascolaires"("IdActivite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5151 (class 2606 OID 42199)
-- Name: T_ActiviteParticipants Fk_IdApprenant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_ActiviteParticipants"
    ADD CONSTRAINT "Fk_IdApprenant" FOREIGN KEY ("IdApprenantFk") REFERENCES public."T_Apprenant"("IdApprenant") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5106 (class 2606 OID 24679)
-- Name: T_Generique Fk_IdCategorieGenerique; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Generique"
    ADD CONSTRAINT "Fk_IdCategorieGenerique" FOREIGN KEY ("IdCategorieGeneriqueFk") REFERENCES public."T_CategorieGenerique"("IdCategorieGenerique") NOT VALID;


--
-- TOC entry 5125 (class 2606 OID 24946)
-- Name: T_Evaluations Fk_IdCibleFk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdCibleFk" FOREIGN KEY ("IdCibleFk") REFERENCES public."T_Utilisateurs"("IdUser") ON UPDATE CASCADE;


--
-- TOC entry 5143 (class 2606 OID 25076)
-- Name: T_Presence Fk_IdControle; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Presence"
    ADD CONSTRAINT "Fk_IdControle" FOREIGN KEY ("IdControleFk") REFERENCES public."T_Utilisateurs"("IdUser");


--
-- TOC entry 5144 (class 2606 OID 25071)
-- Name: T_Presence Fk_IdControleur; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Presence"
    ADD CONSTRAINT "Fk_IdControleur" FOREIGN KEY ("IdControleurFk") REFERENCES public."T_Utilisateurs"("IdUser");


--
-- TOC entry 5126 (class 2606 OID 42342)
-- Name: T_Evaluations Fk_IdCours; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdCours" FOREIGN KEY ("IdCoursFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5118 (class 2606 OID 25241)
-- Name: T_Paiement Fk_IdDevise; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Fk_IdDevise" FOREIGN KEY ("IdDeviseFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5110 (class 2606 OID 25267)
-- Name: T_Enseignant Fk_IdDevise; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Enseignant"
    ADD CONSTRAINT "Fk_IdDevise" FOREIGN KEY ("IdDeviseFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5154 (class 2606 OID 42933)
-- Name: T_Caisse Fk_IdDevise; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Caisse"
    ADD CONSTRAINT "Fk_IdDevise" FOREIGN KEY ("IdDeviseFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5148 (class 2606 OID 42181)
-- Name: T_ActivitesParascolaires Fk_IdEncadrant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_ActivitesParascolaires"
    ADD CONSTRAINT "Fk_IdEncadrant" FOREIGN KEY ("IdEncadrantFk") REFERENCES public."T_Enseignant"("IdEnseignant") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5130 (class 2606 OID 24984)
-- Name: T_Cours Fk_IdEnseignant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Cours"
    ADD CONSTRAINT "Fk_IdEnseignant" FOREIGN KEY ("IdEnseignantFk") REFERENCES public."T_Enseignant"("IdEnseignant") ON UPDATE CASCADE;


--
-- TOC entry 5114 (class 2606 OID 43202)
-- Name: T_Apprenant Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Apprenant"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5131 (class 2606 OID 43207)
-- Name: T_Cours Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Cours"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5152 (class 2606 OID 43212)
-- Name: T_ActiviteParticipants Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_ActiviteParticipants"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5149 (class 2606 OID 43217)
-- Name: T_ActivitesParascolaires Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_ActivitesParascolaires"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5155 (class 2606 OID 43222)
-- Name: T_Caisse Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Caisse"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5107 (class 2606 OID 43227)
-- Name: T_CategorieGenerique Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_CategorieGenerique"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5137 (class 2606 OID 43232)
-- Name: T_Communication Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Communication"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5134 (class 2606 OID 43237)
-- Name: T_EmploisTemps Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_EmploisTemps"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5111 (class 2606 OID 43242)
-- Name: T_Enseignant Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Enseignant"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5127 (class 2606 OID 43247)
-- Name: T_Evaluations Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5140 (class 2606 OID 43252)
-- Name: T_Login Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Login"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5119 (class 2606 OID 43257)
-- Name: T_Paiement Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5153 (class 2606 OID 43262)
-- Name: T_Paiement_Archive Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement_Archive"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5145 (class 2606 OID 43267)
-- Name: T_Presence Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Presence"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5156 (class 2606 OID 43272)
-- Name: T_Salle Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Salle"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5108 (class 2606 OID 43277)
-- Name: T_Utilisateurs Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Utilisateurs"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5147 (class 2606 OID 43282)
-- Name: T_Audit_Log Fk_IdEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Audit_Log"
    ADD CONSTRAINT "Fk_IdEntite" FOREIGN KEY ("IdEntiteFk") REFERENCES public."T_Entite"("IdEntite") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5128 (class 2606 OID 24951)
-- Name: T_Evaluations Fk_IdEvaluateur; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdEvaluateur" FOREIGN KEY ("IdEvaluateurFk") REFERENCES public."T_Utilisateurs"("IdUser") ON UPDATE CASCADE;


--
-- TOC entry 5135 (class 2606 OID 42241)
-- Name: T_EmploisTemps Fk_IdNiveau; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_EmploisTemps"
    ADD CONSTRAINT "Fk_IdNiveau" FOREIGN KEY ("IdNiveauFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5132 (class 2606 OID 42247)
-- Name: T_Cours Fk_IdNiveauCours; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Cours"
    ADD CONSTRAINT "Fk_IdNiveauCours" FOREIGN KEY ("IdNiveauCoursFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5133 (class 2606 OID 42297)
-- Name: T_Cours Fk_IdNomCours; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Cours"
    ADD CONSTRAINT "Fk_IdNomCours" FOREIGN KEY ("IdNomCoursFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5136 (class 2606 OID 42307)
-- Name: T_EmploisTemps Fk_IdNomCours; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_EmploisTemps"
    ADD CONSTRAINT "Fk_IdNomCours" FOREIGN KEY ("IdNomCoursFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5115 (class 2606 OID 43090)
-- Name: T_Apprenant Fk_IdParentApprenant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Apprenant"
    ADD CONSTRAINT "Fk_IdParentApprenant" FOREIGN KEY ("IdParentApprenantFk") REFERENCES public."T_Utilisateurs"("IdUser") NOT VALID;


--
-- TOC entry 5120 (class 2606 OID 25290)
-- Name: T_Paiement Fk_IdPayeurFk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Fk_IdPayeurFk" FOREIGN KEY ("IdPayeurFk") REFERENCES public."T_Utilisateurs"("IdUser") ON UPDATE CASCADE NOT VALID;


--
-- TOC entry 5121 (class 2606 OID 24862)
-- Name: T_Paiement Fk_IdStatut; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Fk_IdStatut" FOREIGN KEY ("IdStatutPaiementFk") REFERENCES public."T_Generique"("IdGenerique") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5146 (class 2606 OID 25081)
-- Name: T_Presence Fk_IdStatutPresence; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Presence"
    ADD CONSTRAINT "Fk_IdStatutPresence" FOREIGN KEY ("IdStatutPresenceFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5138 (class 2606 OID 25026)
-- Name: T_Communication Fk_IdTypeCommunication; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Communication"
    ADD CONSTRAINT "Fk_IdTypeCommunication" FOREIGN KEY ("IdTypeCommunication") REFERENCES public."T_Generique"("IdGenerique") ON UPDATE CASCADE;


--
-- TOC entry 5129 (class 2606 OID 24956)
-- Name: T_Evaluations Fk_IdTypeEvaluation; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Evaluations"
    ADD CONSTRAINT "Fk_IdTypeEvaluation" FOREIGN KEY ("IdTypeEvaluationFk") REFERENCES public."T_Generique"("IdGenerique") ON UPDATE CASCADE;


--
-- TOC entry 5141 (class 2606 OID 25049)
-- Name: T_Login Fk_IdTypeLogin; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Login"
    ADD CONSTRAINT "Fk_IdTypeLogin" FOREIGN KEY ("IdTypeLoginFk") REFERENCES public."T_Generique"("IdGenerique");


--
-- TOC entry 5122 (class 2606 OID 42347)
-- Name: T_Paiement Fk_IdTypeMouvement; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Fk_IdTypeMouvement" FOREIGN KEY ("IdTypeMouvementFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5123 (class 2606 OID 24857)
-- Name: T_Paiement Fk_IdTypePaiement; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Fk_IdTypePaiement" FOREIGN KEY ("IdTypePaiementFk") REFERENCES public."T_Generique"("IdGenerique") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5116 (class 2606 OID 24809)
-- Name: T_Apprenant Fk_IdUser; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Apprenant"
    ADD CONSTRAINT "Fk_IdUser" FOREIGN KEY ("IdUserFk") REFERENCES public."T_Utilisateurs"("IdUser") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5139 (class 2606 OID 25021)
-- Name: T_Communication Fk_IdUser; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Communication"
    ADD CONSTRAINT "Fk_IdUser" FOREIGN KEY ("IdUserFk") REFERENCES public."T_Utilisateurs"("IdUser") ON UPDATE CASCADE;


--
-- TOC entry 5112 (class 2606 OID 43084)
-- Name: T_Enseignant Fk_IdUser; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Enseignant"
    ADD CONSTRAINT "Fk_IdUser" FOREIGN KEY ("IdUserFk") REFERENCES public."T_Utilisateurs"("IdUser") NOT VALID;


--
-- TOC entry 5124 (class 2606 OID 24852)
-- Name: T_Paiement Fk_IdUserFk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Paiement"
    ADD CONSTRAINT "Fk_IdUserFk" FOREIGN KEY ("IdUserFk") REFERENCES public."T_Utilisateurs"("IdUser") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5142 (class 2606 OID 25044)
-- Name: T_Login Fk_IdUserFk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Login"
    ADD CONSTRAINT "Fk_IdUserFk" FOREIGN KEY ("IdUserFk") REFERENCES public."T_Utilisateurs"("IdUser");


--
-- TOC entry 5117 (class 2606 OID 42236)
-- Name: T_Apprenant Fk_NiveauApprenant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Apprenant"
    ADD CONSTRAINT "Fk_NiveauApprenant" FOREIGN KEY ("IdNiveauApprenantFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5109 (class 2606 OID 43079)
-- Name: T_Utilisateurs Fk_RoleFk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Utilisateurs"
    ADD CONSTRAINT "Fk_RoleFk" FOREIGN KEY ("IdRoleFk") REFERENCES public."T_Generique"("IdGenerique") NOT VALID;


--
-- TOC entry 5113 (class 2606 OID 24768)
-- Name: T_Enseignant Fk_SpecialiteEnseignant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Enseignant"
    ADD CONSTRAINT "Fk_SpecialiteEnseignant" FOREIGN KEY ("IdSpecialiteEnseignantFk") REFERENCES public."T_Generique"("IdGenerique") ON UPDATE CASCADE;


--
-- TOC entry 5158 (class 2606 OID 43137)
-- Name: T_Licence Fk_StatutLicence; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Licence"
    ADD CONSTRAINT "Fk_StatutLicence" FOREIGN KEY ("IdStatutLicenceFk") REFERENCES public."T_Generique"("IdGenerique");


--
-- TOC entry 5159 (class 2606 OID 43158)
-- Name: T_Entite Fk_TypeEntite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_Entite"
    ADD CONSTRAINT "Fk_TypeEntite" FOREIGN KEY ("IdTypeEntiteFk") REFERENCES public."T_Generique"("IdGenerique") ON UPDATE CASCADE ON DELETE SET NULL;


-- Completed on 2025-03-26 19:31:09

--
-- PostgreSQL database dump complete
--

