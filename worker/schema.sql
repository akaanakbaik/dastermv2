CREATE TABLE IF NOT EXISTS usage_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event TEXT NOT NULL,
  version TEXT,
  distro TEXT,
  distro_version TEXT,
  arch TEXT,
  virt TEXT,
  lang TEXT,
  mode TEXT,
  machine_hash TEXT,
  date TEXT,
  user_agent_hash TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_usage_event ON usage_events(event);
CREATE INDEX IF NOT EXISTS idx_usage_distro ON usage_events(distro);
CREATE INDEX IF NOT EXISTS idx_usage_virt ON usage_events(virt);
CREATE INDEX IF NOT EXISTS idx_usage_lang ON usage_events(lang);
CREATE INDEX IF NOT EXISTS idx_usage_mode ON usage_events(mode);
CREATE INDEX IF NOT EXISTS idx_usage_machine ON usage_events(machine_hash);
CREATE INDEX IF NOT EXISTS idx_usage_date ON usage_events(date);
CREATE INDEX IF NOT EXISTS idx_usage_created_at ON usage_events(created_at);

CREATE TABLE IF NOT EXISTS rate_limits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  bucket TEXT NOT NULL UNIQUE,
  count INTEGER NOT NULL DEFAULT 0,
  reset_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_rate_limits_bucket ON rate_limits(bucket);
CREATE INDEX IF NOT EXISTS idx_rate_limits_reset_at ON rate_limits(reset_at);