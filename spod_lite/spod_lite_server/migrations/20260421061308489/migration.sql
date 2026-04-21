BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_user" ADD COLUMN "emailVerified" boolean NOT NULL DEFAULT false;
ALTER TABLE "app_user" ADD COLUMN "emailVerificationCode" text;
ALTER TABLE "app_user" ADD COLUMN "emailVerificationExpiresAt" timestamp without time zone;
ALTER TABLE "app_user" ADD COLUMN "passwordResetCode" text;
ALTER TABLE "app_user" ADD COLUMN "passwordResetExpiresAt" timestamp without time zone;

--
-- MIGRATION VERSION FOR spod_lite
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('spod_lite', '20260421061308489', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260421061308489', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
