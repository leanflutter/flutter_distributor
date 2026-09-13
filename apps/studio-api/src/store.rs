use serde::Deserialize;
use studio_core::api::ApiError;
use studio_core::config::FastforgeConfig;
use studio_core::model::{Platform, Project, ProjectSummary, project_id_for_path};
use worker::{D1Database, Env};

use crate::error::{Handled, internal};

/// Binding name for the D1 database. Declared in `wrangler.toml`.
const DB_BINDING: &str = "DB";

pub fn database(env: &Env) -> Handled<D1Database> {
    env.d1(DB_BINDING)
        .map_err(|error| internal("D1 binding `DB` is not available", error))
}

/// One row of `projects`.
///
/// `config_yaml` holds the same document a local checkout keeps at
/// `.fastforge/config.yaml`. Storing the file rather than a normalised schema
/// means `studio_core::config` parses it unchanged in both hosts, and
/// a project can move between them without a translation step.
#[derive(Debug, Clone, Deserialize)]
pub struct ProjectRow {
    pub id: String,
    pub name: String,
    pub repo: Option<String>,
    pub platforms: Option<String>,
    pub config_yaml: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

impl ProjectRow {
    pub fn into_project(self) -> Project {
        Project {
            platforms: parse_platforms(self.platforms.as_deref()),
            has_fastforge_config: self
                .config_yaml
                .as_deref()
                .is_some_and(|config| !config.trim().is_empty()),
            id: self.id,
            name: self.name,
            path: None,
            repo: self.repo,
            created_at: self.created_at,
            updated_at: self.updated_at,
        }
    }

    pub fn into_summary(self) -> ProjectSummary {
        ProjectSummary {
            platforms: parse_platforms(self.platforms.as_deref()),
            has_fastforge_config: self
                .config_yaml
                .as_deref()
                .is_some_and(|config| !config.trim().is_empty()),
            id: self.id,
            name: self.name,
            path: None,
            // Hosted projects have no directory to go missing.
            missing: false,
        }
    }

    pub fn config(&self) -> Handled<FastforgeConfig> {
        let Some(yaml) = self.config_yaml.as_deref() else {
            return Ok(FastforgeConfig::default());
        };
        FastforgeConfig::parse(yaml).map_err(|error| {
            ApiError::bad_request(
                "CONFIG_INVALID",
                format!("The project's stored configuration is not valid YAML: {error}"),
            )
        })
    }
}

/// Stored as a comma-separated list: the set is small, fixed, and only ever
/// read whole, so a join table would cost a query to say nothing more.
fn parse_platforms(value: Option<&str>) -> Vec<Platform> {
    value
        .unwrap_or_default()
        .split(',')
        .filter_map(|item| Platform::parse(item.trim()))
        .collect()
}

/// Hosted project ids follow the same rule as local ones — derived from what
/// identifies the project — so an id is reproducible rather than random.
pub fn project_id(owner: &str, slug: &str) -> String {
    project_id_for_path(&format!("{owner}/{slug}"))
}

pub async fn list_projects(db: &D1Database, owner: &str) -> Handled<Vec<ProjectRow>> {
    let statement = db
        .prepare("SELECT * FROM projects WHERE owner_id = ?1 ORDER BY name")
        .bind(&[owner.into()])
        .map_err(|error| internal("failed to bind the project query", error))?;

    statement
        .all()
        .await
        .map_err(|error| internal("failed to list projects", error))?
        .results::<ProjectRow>()
        .map_err(|error| internal("failed to read projects", error))
}

pub async fn get_project(db: &D1Database, owner: &str, id: &str) -> Handled<ProjectRow> {
    let statement = db
        .prepare("SELECT * FROM projects WHERE owner_id = ?1 AND id = ?2")
        .bind(&[owner.into(), id.into()])
        .map_err(|error| internal("failed to bind the project query", error))?;

    statement
        .first::<ProjectRow>(None)
        .await
        .map_err(|error| internal("failed to read the project", error))?
        .ok_or_else(|| ApiError::not_found("PROJECT_NOT_FOUND", format!("No project `{id}`")))
}
