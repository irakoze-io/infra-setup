\c nirva;
-- create sequence public.users_userid_seq;

alter sequence public.users_userid_seq owner to postgres;
comment on type pg_catalog.aclitem is 'access control list';
comment on type pg_catalog.bit is 'fixed-length bit string';
comment on type pg_catalog.bool is 'boolean, format ''t''/''f''';
comment on type pg_catalog.box is 'geometric box, format ''lower left point,upper right point''';
comment on type pg_catalog.bpchar is '''char(length)'' blank-padded string, fixed storage length';
comment on type pg_catalog.bytea is 'variable-length string, binary values escaped';
comment on type pg_catalog.char is 'single character';
comment on type pg_catalog.cid is 'command identifier type, sequence in transaction id';
comment on type pg_catalog.cidr is 'network IP address/netmask, network address';
comment on type pg_catalog.circle is 'geometric circle, format ''<center point,radius>''';
comment on type pg_catalog.date is 'date';
comment on type pg_catalog.float4 is 'single-precision floating point number, 4-byte storage';
comment on type pg_catalog.float8 is 'double-precision floating point number, 8-byte storage';
comment on type pg_catalog.gtsvector is 'GiST index internal text representation for text search';
comment on type pg_catalog.inet is 'IP address/netmask, host address, netmask optional';
comment on type pg_catalog.int2 is '-32 thousand to 32 thousand, 2-byte storage';
comment on type pg_catalog.int4 is '-2 billion to 2 billion integer, 4-byte storage';

-- create domain information_schema.cardinal_number as integer
--    constraint cardinal_number_domain_check check (VALUE >= 0);
comment on type pg_catalog.int8 is '~18 digit integer, 8-byte storage';
comment on type pg_catalog.interval is 'time interval, format ''number units ...''';
comment on type pg_catalog.json is 'JSON stored as text';
comment on type pg_catalog.jsonb is 'Binary JSON';
comment on type pg_catalog.jsonpath is 'JSON path';
comment on type pg_catalog.line is 'geometric line, formats ''{A,B,C}''/''[point1,point2]''';
comment on type pg_catalog.lseg is 'geometric line segment, format ''[point1,point2]''';
comment on type pg_catalog.macaddr is 'XX:XX:XX:XX:XX:XX, MAC address';
comment on type pg_catalog.macaddr8 is 'XX:XX:XX:XX:XX:XX:XX:XX, MAC address';
comment on type pg_catalog.money is 'monetary amounts, $d,ddd.cc';
comment on type pg_catalog.name is '63-byte type for storing system identifiers';
comment on type pg_catalog.numeric is '''numeric(precision, scale)'' arbitrary precision number';
comment on type pg_catalog.oid is 'object identifier(oid), maximum 4 billion';
comment on type pg_catalog.path is 'geometric path, format ''(point1,...)''';
comment on type pg_catalog.pg_brin_bloom_summary is 'pseudo-type representing BRIN bloom summary';
comment on type pg_catalog.pg_brin_minmax_multi_summary is 'pseudo-type representing BRIN minmax-multi summary';
comment on type pg_catalog.pg_dependencies is 'multivariate dependencies';
comment on type pg_catalog.pg_lsn is 'PostgreSQL LSN';
comment on type pg_catalog.pg_mcv_list is 'multivariate MCV list';
comment on type pg_catalog.pg_ndistinct is 'multivariate ndistinct coefficients';
comment on type pg_catalog.pg_node_tree is 'string representing an internal node tree';
comment on type pg_catalog.pg_snapshot is 'transaction snapshot';
comment on type pg_catalog.point is 'geometric point, format ''(x,y)''';
comment on type pg_catalog.polygon is 'geometric polygon, format ''(point1,...)''';
comment on type pg_catalog.refcursor is 'reference to cursor (portal name)';
comment on type pg_catalog.regclass is 'registered class';
comment on type pg_catalog.regcollation is 'registered collation';
comment on type pg_catalog.regconfig is 'registered text search configuration';
comment on type pg_catalog.regdictionary is 'registered text search dictionary';
comment on type pg_catalog.regnamespace is 'registered namespace';
comment on type pg_catalog.regoper is 'registered operator';
comment on type pg_catalog.regoperator is 'registered operator (with args)';
comment on type pg_catalog.regproc is 'registered procedure';
comment on type pg_catalog.regprocedure is 'registered procedure (with args)';
comment on type pg_catalog.regrole is 'registered role';
comment on type pg_catalog.regtype is 'registered type';

-- create domain information_schema.sql_identifier as name;
comment on type pg_catalog.text is 'variable-length string, no limit specified';
comment on type pg_catalog.tid is 'tuple physical location, format ''(block,offset)''';
comment on type pg_catalog.time is 'time of day';
comment on type pg_catalog.timestamp is 'date and time';
comment on type pg_catalog.timestamptz is 'date and time with time zone';

-- create domain information_schema.time_stamp as timestamp(2) with time zone
--     default CURRENT_TIMESTAMP(2);
comment on type pg_catalog.timetz is 'time of day with time zone';
comment on type pg_catalog.tsquery is 'query representation for text search';
comment on type pg_catalog.tsvector is 'text representation for text search';
comment on type pg_catalog.txid_snapshot is 'transaction snapshot';
comment on type pg_catalog.uuid is 'UUID';
comment on type pg_catalog.varbit is 'variable-length bit string';
comment on type pg_catalog.varchar is '''varchar(length)'' non-blank-padded string, variable storage length';

-- create domain information_schema.character_data as varchar;
comment on type pg_catalog.xid is 'transaction id';
comment on type pg_catalog.xid8 is 'full transaction id';
comment on type pg_catalog.xml is 'XML content';

-- create domain information_schema.yes_or_no as varchar(3)
--     constraint yes_or_no_check check ((VALUE)::text = ANY
--                                       ((ARRAY ['YES'::character varying, 'NO'::character varying])::text[]));

/*create table if not exists public.customers
(
    "customerId"  bigint       not null
        primary key,
    account       varchar(50)  not null
        unique,
    "firstName"   varchar(100) not null,
    "lastName"    varchar(100) not null,
    msisdn        varchar(20)  not null
        unique,
    gender        varchar(10),
    "dateOfBirth" date,
    "homeAddress" text,
    city          varchar(100),
    "postalCode"  varchar(20),
    "houseHoldId" varchar(50),
    "createdAt"   timestamp with time zone default now()
);

alter table public.customers
    owner to postgres;

create unique index customers_account_idx
    on public.customers (account);

create unique index customers_msisdn_idx
    on public.customers (msisdn);

create index "customers_houseHoldId_idx"
    on public.customers ("houseHoldId");

create index "customers_lastName_firstName_idx"
    on public.customers ("lastName", "firstName");

create table public.users
(
    "userId"       bigint                   default nextval('users_userid_seq'::regclass) not null
        primary key,
    "customerId"   bigint
        references public.customers
        references public.customers,
    "firstName"    varchar(100)
        constraint users_username_key
            unique,
    "lastName"     varchar(100),
    username       varchar(50)                                                            not null
        unique
        constraint users_username_check
            check ((username)::text ~* '^[a-zA-Z0-9._-]+$'::text)
        constraint users_username_check1
            check ((username)::text = lower((username)::text))
        constraint users_username_check2
            check (length((username)::text) >= 3)
        constraint users_username_check3
            check (length((username)::text) <= 50)
        constraint users_username_check4
            check ((username)::text <> ALL
                   ((ARRAY ['admin'::character varying, 'root'::character varying, 'superuser'::character varying])::text[]))
        constraint users_username_check5
            check ((username)::text !~~ '%@%'::text)
        constraint users_username_check6
            check ((username)::text !~~ '% %'::text),
    "passwordHash" text                                                                   not null,
    role           varchar(20)              default 'USER'::character varying             not null,
    "createdAt"    timestamp with time zone default now(),
    "lastLogin"    timestamp with time zone,
    primary key (
)
    );

alter table public.users
    owner to postgres;

create unique index users_username_idx
    on public.users (username);

create index "users_customerId_idx"
    on public.users ("customerId");

create table public.sessions
(
    "sessionId" integer generated always as identity
        primary key,
    "userId"    bigint
        references public.users,
    "loginTime" timestamp with time zone default now(),
    "ipAddress" varchar(45),
    "createdAt" timestamp with time zone default now(),
    "expiresAt" timestamp with time zone
);

alter table public.sessions
    owner to postgres;

create index "sessions_userId_idx"
    on public.sessions ("userId");

create index "sessions_ipAddress_idx"
    on public.sessions ("ipAddress");

create table public.vendor
(
    id                   integer generated always as identity
        primary key,
    name                 varchar(50) not null,
    "shortName"          varchar(20) not null
        constraint "assets_customerId_fkey"
            references public.customers,
    type                 varchar(50) not null,
    "accountNumber"      varchar(20) not null
        unique,
    api_key_hash         text,
    api_secret_encrypted text,
    ip_address           varchar(45)
        constraint "assets_vendorId_fkey"
            references ??? (),
    "createdAt"          timestamp with time zone default now(),
    primary key (
)
    );

alter table public.vendor
    owner to postgres;

create unique index "vendor_accountNumber_idx"
    on public.vendor (name);

create index vendor_name_idx
    on public.vendor (type);

create unique index "vendor_accountNumber_idx"
    on public.vendor ();

create index vendor_name_idx
    on public.vendor ();

create table public.assets
(
    id                integer generated always as identity
        primary key,
    name              varchar(100),
    "customerId"      bigint
        references public.customers,
    "vendorId"        integer
        references public.vendor,
    type              varchar(50),
    value             numeric(15, 2),
    "institutionName" varchar(100),
    "accountNumber"   varchar(50),
    active            boolean default true
);

alter table public.assets
    owner to postgres;

create index "assets_customerId_idx"
    on public.assets (type);

create index "assets_vendorId_idx"
    on public.assets (name);

create index "assets_customerId_idx"
    on public.assets ("customerId");

create index "assets_vendorId_idx"
    on public.assets ("vendorId");

create index "assets_accountNumber_idx"
    on public.assets ("accountNumber");

create table public."vendorAccount"
(
    id              integer generated always as identity
        primary key,
    "vendorId"      integer not null,
    "bankName"      varchar(50),
    "accountNumber" varchar(50)
        unique,
    active          boolean default true
);

alter table public."vendorAccount"
    owner to postgres;

create index "vendorAccount_vendorId_idx"
    on public."vendorAccount" ("accountNumber");

create unique index "vendorAccount_accountNumber_idx"
    on public."vendorAccount" (???);

create index "vendorAccount_vendorId_idx"
    on public."vendorAccount" ();

create unique index "vendorAccount_accountNumber_idx"
    on public."vendorAccount" ();

create table public."customerAccount"
(
    id              integer generated always as identity
        primary key,
    "customerId"    bigint not null,
    "bankName"      varchar(50),
    "accountNumber" varchar(50)
        unique,
    active          boolean default true
);

alter table public."customerAccount"
    owner to postgres;

create index "customerAccount_customerId_idx"
    on public."customerAccount" ("customerId");

create index "customerAccount_accountNumber_idx"
    on public."customerAccount" ("accountNumber");

create index "customerAccount_customerId_idx"
    on public."customerAccount" ("customerId");

create index "customerAccount_accountNumber_idx"
    on public."customerAccount" ("accountNumber");

create table public.transactions
(
    id              bigint not null
        primary key,
    credit          boolean,
    "customerId"    bigint
        references public.customers,
    "vendorId"      integer
        references public.vendor,
    "accountDebit"  varchar(50),
    "accountCredit" varchar(50),
    amount          numeric(15, 2),
    type            varchar(50),
    remarks         text,
    dated           timestamp with time zone default now()
);

alter table public.transactions
    owner to postgres;

create index "transactions_customerId_idx"
    on public.transactions (credit);

create index "transactions_vendorId_idx"
    on public.transactions ("vendorId");

create index "transactions_customerId_idx"
    on public.transactions ("customerId");

create index "transactions_vendorId_idx"
    on public.transactions ("vendorId");

create index transactions_dated_idx
    on public.transactions (dated);

create index "transactions_customerId_dated_idx"
    on public.transactions ("customerId", dated);*/

create function public.sp_log_user_session(p_userid bigint, p_ipaddress character varying) returns void
    language plpgsql
as
$$
begin
    insert into "sessions" ("userId", "ipAddress")
    values (p_userId, p_ipAddress);
exception
    when others then
        -- Log the error or handle it as needed
        raise notice 'Error logging user session: %', sqlerrm;
end;
$$;

alter function public.sp_log_user_session(bigint, varchar) owner to postgres;

create function public.sp_create_user(p_customerid bigint, p_firstname character varying, p_lastname character varying,
                                      p_password text, p_role character varying DEFAULT 'USER'::character varying)
    returns TABLE
            (
                success   boolean,
                message   text,
                newuserid bigint
            )
    language plpgsql
as
$$

declare
    v_userId   bigint;
    v_username varchar(50);
begin
    -- Generate ID with next sequence
    select coalesce(max("userId"), 0) + 1 into v_userId from "users";

    -- Validate input parameters
    if p_firstname is null
        or p_lastname is null
        or p_password is null then
        return query
            select false,
                   'First name, last name and password are required',
                   v_userId;
        return;
    end if;

-- Generate username based on first and last name
    v_username := lower(p_firstname || '.' || p_lastname);
    v_username := regexp_replace(v_username, '[^a-z0-9._-]', '', 'g'); -- Remove invalid characters
    v_username := regexp_replace(v_username, '\.{2,}', '.', 'g'); -- Replace multiple dots with a single dot
    v_username := regexp_replace(v_username, '^\.|\.$', '', 'g'); -- Remove leading and trailing dots
    v_username := left(v_username, 50);
    -- Ensure username does not exceed 50 characters

-- Ensure the customer exists if a customerId is provided
    if p_customerId is not null
        and not exists (select 1
                        from customers
                        where "customerId" = p_customerId) then
        return query
            select false,
                   'Customer does not exist',
                   v_userId;
        return;
    end if;

-- Validation to prevent duplicate usernames
    if exists (select 1
               from "users"
               where "username" = lower(v_username)) then
        return query
            select false,
                   'Username already exists',
                   v_userId;
        return;
    end if;

    insert into "users" ("userId",
                         "firstName",
                         "lastName",
                         "customerId",
                         "username",
                         "passwordHash",
                         "role")
    values (v_userId,
            p_firstname,
            p_lastname,
            p_customerId,
            lower(v_username),
            crypt(p_password, gen_salt('bf')),
            upper(p_role)); -- returning "userId";
    return query select true,
                        'User created successfully',
                        -- currval(pg_get_serial_sequence('"users"', '"userId"'));
                        v_userId;
    -- lastval();

exception
    when others then return query
        select false,
               sqlerrm,
               v_userId;
end;
$$;

alter function public.sp_create_user(bigint, varchar, varchar, text, varchar) owner to postgres;

create function public.sp_user_login(p_username character varying, p_password text, p_ipaddress character varying)
    returns TABLE
            (
                success    boolean,
                message    text,
                identifier bigint,
                lastlogin  timestamp with time zone,
                "userRole" character varying
            )
    language plpgsql
as
$$
declare
    v_userId    bigint;
    v_lastLogin timestamp with time zone;
    v_role      varchar;
begin
    if p_username is null or p_password is null then
        return query select false,
                            'Username and password are required',
                            null::bigint,
                            null::timestamp with time zone,
                            null::varchar;
        return;
    end if;

    -- if exists (select 1
    --            from "users"
    --            where "username" = lower(p_username)
    --              and "passwordHash" = crypt(p_password, "passwordHash")) then
    --     update "users"
    --     set "lastLogin" = now()
    --     where "username" = lower(p_username);

    --     select "userId" into v_userId
    --         from "users"
    --     where "username" = lower(p_username);

    --     -- Log the user session after successful creation
    --     perform sp_log_user_session(v_userId, p_ipAddress);

    --     return query
    --         select true, 'Login successful', "userId", "lastLogin", "role"
    --         from "users"
    --         where "username" = lower(p_username);
    update "users"
    set "lastLogin" = now()
    where "username" = lower(p_username)
      and "passwordHash" = crypt(p_password, "passwordHash")
    returning "userId", "lastLogin", "role"
        into v_userId, v_lastLogin, v_role;

    if found then
        -- Log the user session after successful login
        perform sp_log_user_session(v_userId, p_ipAddress);

        return query select true,
                            'Login successful',
                            v_userId,
                            v_lastLogin,
                            v_role;
    else
        return query select false,
                            'Invalid username or password',
                            null::bigint,
                            null::timestamp with time zone,
                            null::varchar;
    end if;

exception
    when others then
        -- return
        --     query select false,
        --                  sqlerrm,
        --                  null::bigint,
        --                  null::timestamp with time zone,
        --                  null::varchar;
        raise notice 'Error during user login: %', sqlerrm;
        return query select false,
                            'An error occurred during login',
                            null::bigint,
                            null::timestamp with time zone,
                            null::varchar;
end;
$$;

alter function public.sp_user_login(varchar, text, varchar) owner to postgres;

create function public.sp_create_customer(p_account character varying, p_firstname character varying,
                                          p_lastname character varying, p_msisdn character varying,
                                          p_gender character varying, p_dateofbirth date, p_homeaddress text,
                                          p_city character varying, p_postalcode character varying,
                                          p_householdid character varying)
    returns TABLE
            (
                success         boolean,
                message         text,
                "newCustomerId" bigint
            )
    language plpgsql
as
$$
declare
    v_customerId bigint;
begin
    select coalesce(max("customerId"), 0) + 1 into v_customerId from customers;
    if p_account is null
        or p_firstname is null
        or p_lastname is null
        or p_msisdn is null then
        return query select false,
                            'Account, first name, last name and MSISDN are required',
                            null::bigint;
        return;
    end if;
    if exists (select 1
               from customers
               where "account" = p_account) then
        return query select false,
                            'Account already exists',
                            null::bigint;
        return;
    end if;
    if exists (select 1
               from customers
               where p_msisdn = msisdn) then
        return query select false,
                            'MSISDN already exists',
                            null::bigint;
        return;
    end if;

    insert into customers ("customerId",
                           account,
                           "firstName",
                           "lastName",
                           msisdn,
                           "gender",
                           "dateOfBirth",
                           "homeAddress",
                           "city",
                           "postalCode",
                           "houseHoldId")
    values (v_customerId,
            p_account,
            p_firstname,
            p_lastname,
            p_msisdn,
            p_gender,
            p_dateOfBirth,
            p_homeAddress,
            p_city,
            p_postalCode,
            p_houseHoldId);
    return query select true, 'Customer created successfully', v_customerId;
end;
$$;

alter function public.sp_create_customer(varchar, varchar, varchar, varchar, varchar, date, text, varchar, varchar, varchar) owner to postgres;

create function public.sp_add_customer_account("p_customerId" bigint, "p_accountNumber" character varying,
                                               "p_bankName" character varying)
    returns TABLE
            (
                success boolean,
                message text
            )
    language plpgsql
as
$$
declare
    v_existing_account bigint;
begin
    if "p_customerId" is null
        or "p_customerId" is null
        or "p_bankName" is null then
        return query select false, 'One or multiple required parameters are missing';
        return;
    end if;

    if exists(select 1
              from customers
              where "customerId" = "p_customerId"
                and account = "p_accountNumber")
    then
        return query select false, 'The account is already in use';
        return;
    end if;

    if exists(select 1
              from "customerAccount"
              where "customerId" = "p_customerId"
                and "accountNumber" = "p_accountNumber")
    then
        return query select false,
                            'The account is already assigned to the customer. Please choose from available list.';
    end if;

    update "customers"
    set account = "p_accountNumber"
    where "customerId" = "p_customerId"
    returning "customerId" into v_existing_account;

    if found then
        raise log 'Success';

        if exists(select 1 from "customerAccount" where "customerId" = "p_customerId") then
            update "customerAccount" set active = false where "customerId" = "p_customerId";
            insert into "customerAccount" ("customerId", "bankName", "accountNumber", active)
            values ("p_customerId", "p_bankName", "p_accountNumber", false);
            return query
                select true, 'Operation successful';
            return;
        end if;
        insert into "customerAccount" ("customerId", "bankName", "accountNumber", active)
        values ("p_customerId", '', v_existing_account, false),
               ("p_customerId", "p_bankName", "p_accountNumber", false);
        return query
            select true, 'Operation successful';
        return;
    end if;
    return query select false, 'No match found with provided parameters';
    return;

exception
    when others then
        return query select false, SQLERRM;
end;
$$;

alter function public.sp_add_customer_account(bigint, varchar, varchar) owner to postgres;

create function public.sp_activate_customer_account("p_customerId" bigint, "p_accountNumber" character varying)
    returns TABLE
            (
                success boolean,
                message text
            )
    language plpgsql
as
$$
begin
    update "customerAccount"
    set active = true
    where "customerId" = "p_customerId"
      and "accountNumber" = "p_accountNumber";

    if found then
        return query select true, 'Operation successful';
        return;
    end if;

    raise internal_error using message = 'No match found';
    -- return query select false, 'No match found with provided parameters';

exception
    when others then
        raise log 'An error has occurred: %', sqlerrm;

        return query select false, SQLERRM;
        return;
end;
$$;

alter function public.sp_activate_customer_account(bigint, varchar) owner to postgres;