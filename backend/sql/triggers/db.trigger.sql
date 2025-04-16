-- Trigger: trigger_audit_T_ActiviteParticipants

-- DROP TRIGGER IF EXISTS "trigger_audit_T_ActiviteParticipants" ON public."T_ActiviteParticipants";

CREATE OR REPLACE TRIGGER "trigger_audit_T_ActiviteParticipants"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_ActiviteParticipants"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_notification_parent_activite

-- DROP TRIGGER IF EXISTS trigger_notification_parent_activite ON public."T_ActiviteParticipants";

CREATE OR REPLACE TRIGGER trigger_notification_parent_activite
    AFTER INSERT
    ON public."T_ActiviteParticipants"
    FOR EACH ROW
    EXECUTE FUNCTION public.notification_parent_activite();

-- Trigger: trigger_audit_T_ActivitesParascolaires

-- DROP TRIGGER IF EXISTS "trigger_audit_T_ActivitesParascolaires" ON public."T_ActivitesParascolaires";

CREATE OR REPLACE TRIGGER "trigger_audit_T_ActivitesParascolaires"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_ActivitesParascolaires"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

CREATE OR REPLACE TRIGGER "trigger_audit_T_Apprenant"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Apprenant"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_calculate_age_apprenant

-- DROP TRIGGER IF EXISTS trigger_calculate_age_apprenant ON public."T_Apprenant";

CREATE OR REPLACE TRIGGER trigger_calculate_age_apprenant
    BEFORE INSERT OR UPDATE 
    ON public."T_Apprenant"
    FOR EACH ROW
    EXECUTE FUNCTION public.calculate_age_apprenant();

-- Trigger: trigger_audit_T_CategorieGenerique

-- DROP TRIGGER IF EXISTS "trigger_audit_T_CategorieGenerique" ON public."T_CategorieGenerique";

CREATE OR REPLACE TRIGGER "trigger_audit_T_CategorieGenerique"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_CategorieGenerique"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_audit_T_Communication

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Communication" ON public."T_Communication";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Communication"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Communication"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_audit_T_Cours

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Cours" ON public."T_Cours";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Cours"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Cours"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_notification_new_course

-- DROP TRIGGER IF EXISTS trigger_notification_new_course ON public."T_Cours";

CREATE OR REPLACE TRIGGER trigger_notification_new_course
    AFTER INSERT
    ON public."T_Cours"
    FOR EACH ROW
    EXECUTE FUNCTION public.notification_new_course();

-- Trigger: trigger_audit_T_EmploisTemps

-- DROP TRIGGER IF EXISTS "trigger_audit_T_EmploisTemps" ON public."T_EmploisTemps";

CREATE OR REPLACE TRIGGER "trigger_audit_T_EmploisTemps"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_EmploisTemps"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_notification_new_course

-- DROP TRIGGER IF EXISTS trigger_notification_new_course ON public."T_EmploisTemps";

CREATE OR REPLACE TRIGGER trigger_notification_new_course
    AFTER INSERT
    ON public."T_EmploisTemps"
    FOR EACH ROW
    EXECUTE FUNCTION public.notification_new_course();

-- Trigger: trigger_audit_T_Enseignant

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Enseignant" ON public."T_Enseignant";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Enseignant"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Enseignant"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_audit_T_Evaluations

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Evaluations" ON public."T_Evaluations";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Evaluations"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Evaluations"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_notification_parent_evaluation

-- DROP TRIGGER IF EXISTS trigger_notification_parent_evaluation ON public."T_Evaluations";

CREATE OR REPLACE TRIGGER trigger_notification_parent_evaluation
    AFTER INSERT
    ON public."T_Evaluations"
    FOR EACH ROW
    EXECUTE FUNCTION public.notification_parent_evaluation();

-- Trigger: trigger_audit_T_Generique

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Generique" ON public."T_Generique";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Generique"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Generique"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_notify_licence_expiry

-- DROP TRIGGER IF EXISTS trigger_notify_licence_expiry ON public."T_Licence";

CREATE OR REPLACE TRIGGER trigger_notify_licence_expiry
    AFTER INSERT OR UPDATE 
    ON public."T_Licence"
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_licence_expiry();

-- Trigger: trigger_prevent_multiple_licenses

-- DROP TRIGGER IF EXISTS trigger_prevent_multiple_licenses ON public."T_Licence";

CREATE OR REPLACE TRIGGER trigger_prevent_multiple_licenses
    BEFORE INSERT
    ON public."T_Licence"
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_multiple_active_licenses();

-- Trigger: trigger_update_licence_status

-- DROP TRIGGER IF EXISTS trigger_update_licence_status ON public."T_Licence";

CREATE OR REPLACE TRIGGER trigger_update_licence_status
    BEFORE INSERT OR UPDATE 
    ON public."T_Licence"
    FOR EACH ROW
    EXECUTE FUNCTION public.update_licence_status();

-- Trigger: trigger_audit_T_Login

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Login" ON public."T_Login";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Login"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Login"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_audit_T_Paiement

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Paiement" ON public."T_Paiement";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Paiement"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Paiement"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_gestion_caisse_on_paiement

-- DROP TRIGGER IF EXISTS trigger_gestion_caisse_on_paiement ON public."T_Paiement";

CREATE OR REPLACE TRIGGER trigger_gestion_caisse_on_paiement
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Paiement"
    FOR EACH ROW
    EXECUTE FUNCTION public.gestion_caisse_on_paiement();

-- Trigger: trigger_notification_payment_success

-- DROP TRIGGER IF EXISTS trigger_notification_payment_success ON public."T_Paiement";

CREATE OR REPLACE TRIGGER trigger_notification_payment_success
    AFTER INSERT OR UPDATE 
    ON public."T_Paiement"
    FOR EACH ROW
    EXECUTE FUNCTION public.notification_payment_success();

-- Trigger: trigger_audit_T_Paiement_Archive

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Paiement_Archive" ON public."T_Paiement_Archive";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Paiement_Archive"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Paiement_Archive"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_audit_T_Presence

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Presence" ON public."T_Presence";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Presence"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Presence"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_notification_parent_absence

-- DROP TRIGGER IF EXISTS trigger_notification_parent_absence ON public."T_Presence";

CREATE OR REPLACE TRIGGER trigger_notification_parent_absence
    AFTER INSERT
    ON public."T_Presence"
    FOR EACH ROW
    EXECUTE FUNCTION public.notification_parent_absence();

-- Trigger: trigger_audit_T_Utilisateurs

-- DROP TRIGGER IF EXISTS "trigger_audit_T_Utilisateurs" ON public."T_Utilisateurs";

CREATE OR REPLACE TRIGGER "trigger_audit_T_Utilisateurs"
    AFTER INSERT OR DELETE OR UPDATE 
    ON public."T_Utilisateurs"
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_log_function();

-- Trigger: trigger_format_phone_number

-- DROP TRIGGER IF EXISTS trigger_format_phone_number ON public."T_Utilisateurs";

CREATE OR REPLACE TRIGGER trigger_format_phone_number
    BEFORE INSERT OR UPDATE 
    ON public."T_Utilisateurs"
    FOR EACH ROW
    EXECUTE FUNCTION public.format_phone_number();

-- Trigger: trigger_prevention_delete_utilisateur

-- DROP TRIGGER IF EXISTS trigger_prevention_delete_utilisateur ON public."T_Utilisateurs";

CREATE OR REPLACE TRIGGER trigger_prevention_delete_utilisateur
    BEFORE DELETE
    ON public."T_Utilisateurs"
    FOR EACH ROW
    EXECUTE FUNCTION public.prevention_delete_if_dependent();

-- Trigger: trigger_update_date_modification

-- DROP TRIGGER IF EXISTS trigger_update_date_modification ON public."T_Utilisateurs";

CREATE OR REPLACE TRIGGER trigger_update_date_modification
    BEFORE UPDATE 
    ON public."T_Utilisateurs"
    FOR EACH ROW
    EXECUTE FUNCTION public.update_date_modification();



