pub mod pull;
pub mod push;
mod screenshots;

use crate::cli::GlobalArgs;
use anyhow::Result;
use clap::{Args, Subcommand};
use serde::{Deserialize, Serialize};
use serde_json::Value;

pub use pull::PullArgs;
pub use push::PushArgs;

#[derive(Debug, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
struct VersionMetadata {
    #[serde(rename = "_id", default, skip_serializing_if = "Option::is_none")]
    id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    platform: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    version_string: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    state: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    copyright: Option<String>,
}

const APP_INFO_CATEGORY_FIELDS: &str = "primaryCategory,primarySubcategoryOne,primarySubcategoryTwo,secondaryCategory,secondarySubcategoryOne,secondarySubcategoryTwo";

#[derive(Clone, Debug, Default, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
struct AppInfoCategories {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    primary_category: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    primary_subcategory_one: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    primary_subcategory_two: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    secondary_category: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    secondary_subcategory_one: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    secondary_subcategory_two: Option<String>,
}

impl AppInfoCategories {
    fn from_relationships(relationships: &Value) -> Self {
        Self {
            primary_category: relationship_id(relationships, "primaryCategory"),
            primary_subcategory_one: relationship_id(relationships, "primarySubcategoryOne"),
            primary_subcategory_two: relationship_id(relationships, "primarySubcategoryTwo"),
            secondary_category: relationship_id(relationships, "secondaryCategory"),
            secondary_subcategory_one: relationship_id(relationships, "secondarySubcategoryOne"),
            secondary_subcategory_two: relationship_id(relationships, "secondarySubcategoryTwo"),
        }
    }

    fn is_empty(&self) -> bool {
        self.primary_category.is_none()
            && self.primary_subcategory_one.is_none()
            && self.primary_subcategory_two.is_none()
            && self.secondary_category.is_none()
            && self.secondary_subcategory_one.is_none()
            && self.secondary_subcategory_two.is_none()
    }
}

fn relationship_id(relationships: &Value, name: &str) -> Option<String> {
    relationships[name]["data"]["id"]
        .as_str()
        .map(str::to_owned)
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn categories_are_read_from_app_info_relationships() {
        let categories = AppInfoCategories::from_relationships(&json!({
            "primaryCategory": {
                "data": { "type": "appCategories", "id": "GAMES" }
            },
            "primarySubcategoryOne": {
                "data": { "type": "appCategories", "id": "GAMES_ACTION" }
            },
            "secondaryCategory": { "data": null }
        }));

        assert_eq!(categories.primary_category.as_deref(), Some("GAMES"));
        assert_eq!(
            categories.primary_subcategory_one.as_deref(),
            Some("GAMES_ACTION")
        );
        assert_eq!(categories.secondary_category, None);
    }

    #[test]
    fn category_yaml_uses_app_store_relationship_names() {
        let categories = AppInfoCategories {
            primary_category: Some("GAMES".into()),
            secondary_category: Some("ENTERTAINMENT".into()),
            ..Default::default()
        };

        let yaml = serde_yaml::to_string(&categories).unwrap();
        assert!(yaml.contains("primaryCategory: GAMES"));
        assert!(yaml.contains("secondaryCategory: ENTERTAINMENT"));
        assert!(!yaml.contains("primarySubcategoryOne"));

        assert_eq!(
            serde_yaml::from_str::<AppInfoCategories>(&yaml).unwrap(),
            categories
        );
    }
}

#[derive(Args, Debug)]
pub struct CatalogArgs {
    #[command(subcommand)]
    pub command: CatalogCommand,
}

#[derive(Subcommand, Debug)]
pub enum CatalogCommand {
    #[command(about = "Pull store data to a local directory for editing")]
    Pull(PullArgs),
    #[command(about = "Push local changes back to the store")]
    Push(PushArgs),
}

pub async fn execute(args: &CatalogArgs, global: &GlobalArgs) -> Result<()> {
    match &args.command {
        CatalogCommand::Pull(pull_args) => pull::execute(pull_args, global).await,
        CatalogCommand::Push(push_args) => push::execute(push_args, global).await,
    }
}
