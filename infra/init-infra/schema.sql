-- Simple table tracking accounts and balance
CREATE TABLE IF NOT EXISTS accounts (
  id TEXT PRIMARY KEY,
  balance NUMERIC NOT NULL,
  version BIGINT NOT NULL DEFAULT 0
);

