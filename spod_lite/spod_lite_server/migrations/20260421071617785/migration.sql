BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "oauth_provider_config" (
    "id" bigserial PRIMARY KEY,
    "provider" text NOT NULL,
    "clientId" text NOT NULL,
    "clientSecret" text,
    "enabled" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "oauth_provider_config_uidx" ON "oauth_provider_config" USING btree ("provider");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_oauth_link" (
    "id" bigserial PRIMARY KEY,
    "appUserId" bigint NOT NULL,
    "provider" text NOT NULL,
    "providerUserId" text NOT NULL,
    "emailAtLink" text NOT NULL,
    "linkedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "user_oauth_link_uidx" ON "user_oauth_link" USING btree ("provider", "providerUserId");
CREATE INDEX "user_oauth_link_user_idx" ON "user_oauth_link" USING btree ("appUserId");


--
-- MIGRATION VERSION FOR spod_lite
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('spod_lite', '20260421071617785', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260421071617785', "timestamp" = now();

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
