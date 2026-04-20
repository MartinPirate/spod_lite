BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "collection_def" ADD COLUMN "listRule" text NOT NULL DEFAULT 'admin'::text;
ALTER TABLE "collection_def" ADD COLUMN "viewRule" text NOT NULL DEFAULT 'admin'::text;
ALTER TABLE "collection_def" ADD COLUMN "createRule" text NOT NULL DEFAULT 'admin'::text;
ALTER TABLE "collection_def" ADD COLUMN "updateRule" text NOT NULL DEFAULT 'admin'::text;
ALTER TABLE "collection_def" ADD COLUMN "deleteRule" text NOT NULL DEFAULT 'admin'::text;

--
-- MIGRATION VERSION FOR spod_lite
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('spod_lite', '20260420103903293', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260420103903293', "timestamp" = now();

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
