BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "collection_def" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "label" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "collection_def_name_uidx" ON "collection_def" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "collection_field" (
    "id" bigserial PRIMARY KEY,
    "collectionDefId" bigint NOT NULL,
    "name" text NOT NULL,
    "fieldType" text NOT NULL,
    "required" boolean NOT NULL DEFAULT false,
    "fieldOrder" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "collection_field_name_by_collection" ON "collection_field" USING btree ("collectionDefId", "name");
CREATE INDEX "collection_field_def_idx" ON "collection_field" USING btree ("collectionDefId");


--
-- MIGRATION VERSION FOR spod_lite
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('spod_lite', '20260420100036230', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260420100036230', "timestamp" = now();

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
