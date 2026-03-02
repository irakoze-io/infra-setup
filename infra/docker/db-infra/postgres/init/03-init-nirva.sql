CREATE DATABASE nirva;
\c nirva;
create table "customers" (
    "customer_id" bigint primary key,
    "account" varchar(50) unique not null,
    "first_name" varchar(100) not null,
    "last_name" varchar(100) not null,
    "msisdn" varchar(20) unique not null,
    "gender" varchar(10),
    "dob" date,
    "address" text,
    "city" varchar(100),
    "postal_code" varchar(20),
    "house_hold_id" varchar(50),
    "created_at" timestamp with time zone default now()
);
create table "users" (
    "user_id" bigint primary key,
    "customer_id" bigint references customers("customer_id"),
    "first_name" varchar(100),
    "last_name" varchar(100),
    "username" varchar(50) unique not null 
    CHECK (username ~* '^[a-zA-Z0-9._-]+$')
    CHECK (username = lower(username))
    CHECK (length(username) >= 3)
    CHECK (length(username) <= 50)
    CHECK (username NOT IN ('admin', 'root', 'superuser'))
    CHECK (username NOT LIKE '%@%')
    CHECK (username NOT LIKE '% %'),
    "password" text not null,
    "role" varchar(20) not null default 'USER',
    "created_at" timestamp with time zone default now(),
    "last_login_time" timestamp with time zone
);
create table "sessions" (
    "session_id" integer primary key generated always as identity,
    "user_id" bigint references users("user_id"),
    "login_time" timestamp with time zone default now(),
    "ip_address" varchar(45),
    "created_at" timestamp with time zone default now(),
    "expires_at" timestamp with time zone
);
create table "vendor" (
    "id" integer primary key generated always as identity,
    "name" varchar(50) not null,
    "short_name" varchar(20) not null,
    "type" varchar(50) not null,
    "account_number" varchar(20) not null unique,
    "api_key_hash" text,
    "api_secret_encrypted" text,
    "ip_address" varchar(45),
    "created_at" timestamp with time zone default now()
);
create table "assets" (
    "id" integer primary key generated always as identity,
    "name" varchar(100),
    "customer_id" bigint references customers("customer_id"),
    "vendor_id" integer references vendor(id),
    "type" varchar(50),
    "value" numeric(15, 2),
    "institution_name" varchar(100),
    "account_number" varchar(50),
    "active" boolean default true
);
create table "vendorAccount" (
    "id" integer primary key generated always as identity,
    "vendor_id" integer not null,
    "bank_name" varchar(50),
    "account_number" varchar(50) unique,
    "active" boolean default true
);
create table "customerAccount" (
    "id" integer primary key generated always as identity,
    "customer_id" bigint not null,
    "bank_name" varchar(50),
    "account_number" varchar(50) unique,
    "active" boolean default true
);
create table "transactions" (
    "id" bigint primary key,
    "credit" boolean,
    "customer_id" bigint references customers("customer_id"),
    "vendor_id" integer references vendor(id),
    "account_debit" varchar(50),
    "account_credit" varchar(50),
    "amount" numeric(15, 2),
    "type" varchar(50),
    "remarks" text,
    "dated" timestamp with time zone default now()
);
CREATE SEQUENCE IF NOT EXISTS users_userid_seq;
alter table "users"
alter column "user_id"
set default nextval('users_userid_seq');

--create sequence if not exists customers_customerid_seq;
--alter table "customers"
--alter column "customer_id"
--set default nextval('customers_customerid_seq');

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE UNIQUE INDEX ON "customers" ("account");
CREATE UNIQUE INDEX ON "customers" ("msisdn");
CREATE INDEX ON "customers" ("house_hold_id");
CREATE INDEX ON "customers" ("last_name", "first_name");
CREATE UNIQUE INDEX ON "users" ("username");
CREATE INDEX ON "users" ("customer_id");
CREATE INDEX ON "sessions" ("user_id");
create index on "sessions" ("ip_address");
CREATE UNIQUE INDEX ON "vendor" ("account_number");
CREATE INDEX ON "vendor" ("name");
CREATE INDEX ON "assets" ("customer_id");
CREATE INDEX ON "assets" ("vendor_id");
CREATE INDEX ON "assets" ("account_number");
CREATE INDEX ON "vendorAccount" ("vendor_id");
CREATE UNIQUE INDEX ON "vendorAccount" ("account_number");
CREATE INDEX ON "customerAccount" ("customer_id");
CREATE INDEX ON "customerAccount" ("account_number");
CREATE INDEX ON "transactions" ("customer_id");
CREATE INDEX ON "transactions" ("vendor_id");
CREATE INDEX ON "transactions" ("dated");
CREATE INDEX ON "transactions" ("customer_id", "dated");
COPY customers (
    "customer_id",
    account,
    "first_name",
    "last_name",
    msisdn,
    gender,
    "dob",
    "address",
    city,
    "postal_code",
    "house_hold_id"
)
FROM '/docker-entrypoint-initdb.d/data/customers.csv' DELIMITER ',' CSV HEADER;
COPY vendor (id, name, "account_number", "short_name", type)
FROM '/docker-entrypoint-initdb.d/data/vendors.csv' DELIMITER ',' CSV HEADER;