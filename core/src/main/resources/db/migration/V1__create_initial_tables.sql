-- ============================================================
-- V1: 初期テーブル作成
-- ============================================================

-- ------------------------------------------------------------
-- menu: メニュー
-- ------------------------------------------------------------
CREATE TABLE menu (
	id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name              VARCHAR(50) NOT NULL,
	description       VARCHAR(500),
	duration_minutes  INTEGER NOT NULL,
	price             INTEGER NOT NULL,
	display_order     INTEGER NOT NULL DEFAULT 0,
	published         BOOLEAN NOT NULL DEFAULT TRUE,
	version           INTEGER NOT NULL DEFAULT 0,
	created_at        TIMESTAMPTZ NOT NULL,
	updated_at        TIMESTAMPTZ NOT NULL,

	CONSTRAINT ck_menu_name_not_blank CHECK ( btrim(name, E' \r\n\t　') <> '' ),
	CONSTRAINT ck_menu_duration_minutes_positive CHECK ( duration_minutes > 0 ),
	CONSTRAINT ck_menu_price_non_negative CHECK ( price >= 0 )
);

-- ------------------------------------------------------------
-- staff: 担当者
-- ------------------------------------------------------------
CREATE TABLE staff (
	id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name           VARCHAR(50) NOT NULL,
	display_order  INTEGER NOT NULL DEFAULT 0,
	active         BOOLEAN NOT NULL DEFAULT TRUE,
	version        INTEGER NOT NULL DEFAULT 0,
	created_at     TIMESTAMPTZ NOT NULL,
	updated_at     TIMESTAMPTZ NOT NULL,

	CONSTRAINT ck_staff_name_not_blank CHECK ( btrim(name, E' \r\n\t　') <> '' )
);

-- ------------------------------------------------------------
-- slot: 予約枠
-- ------------------------------------------------------------
CREATE TABLE slot (
	id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	staff_id    BIGINT NOT NULL,
	slot_date   DATE NOT NULL,
	start_time  TIME NOT NULL,
	end_time    TIME NOT NULL,
	version     INTEGER NOT NULL DEFAULT 0,
	created_at  TIMESTAMPTZ NOT NULL,
	updated_at  TIMESTAMPTZ NOT NULL,

	CONSTRAINT fk_slot_staff_id FOREIGN KEY ( staff_id ) REFERENCES staff ( id ),
	CONSTRAINT uq_slot_staff_id_slot_date_start_time UNIQUE ( staff_id, slot_date, start_time ),
	CONSTRAINT ck_slot_end_time_after_start_time CHECK ( end_time > start_time )
);

-- ------------------------------------------------------------
-- account: ログインアカウント
-- ------------------------------------------------------------
CREATE TABLE account (
	id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	login_id       VARCHAR(50) NOT NULL,
	password_hash  VARCHAR(100) NOT NULL,
	role           VARCHAR(20) NOT NULL,
	staff_id       BIGINT,
	enabled        BOOLEAN NOT NULL DEFAULT TRUE,
	version        INTEGER NOT NULL DEFAULT 0,
	created_at     TIMESTAMPTZ NOT NULL,
	updated_at     TIMESTAMPTZ NOT NULL,

	CONSTRAINT fk_account_staff_id FOREIGN KEY ( staff_id ) REFERENCES staff ( id ),
	CONSTRAINT uq_account_login_id UNIQUE ( login_id ),
	CONSTRAINT uq_account_staff_id UNIQUE ( staff_id ),
	CONSTRAINT ck_account_role_in_allowed_values CHECK ( role IN ('ADMIN', 'STAFF') ),
	CONSTRAINT ck_account_staff_role_requires_staff_id CHECK ( role <> 'STAFF' OR staff_id IS NOT NULL )
);
