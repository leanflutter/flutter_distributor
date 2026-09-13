-- Projects are the top-level object: there is no workspace above them yet.
--
-- `owner_id` is the seam for that. When workspaces arrive they take this
-- column's place, and nothing below a project — stores, apps, catalogs — has to
-- change, because none of it is keyed by anything above the project.
CREATE TABLE IF NOT EXISTS projects (
  id          TEXT PRIMARY KEY,
  owner_id    TEXT NOT NULL,
  slug        TEXT NOT NULL,
  name        TEXT NOT NULL,
  repo        TEXT,
  -- Comma-separated, from the fixed platform set. Read whole, never queried by
  -- member, so a join table would cost a query to say nothing more.
  platforms   TEXT,
  -- The same document a local checkout keeps at `.fastforge/config.yaml`.
  -- Storing the file rather than a normalised schema lets one parser serve both
  -- hosts, and lets a project move between them unchanged.
  config_yaml TEXT,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS projects_owner_slug ON projects (owner_id, slug);
CREATE INDEX IF NOT EXISTS projects_owner ON projects (owner_id);
