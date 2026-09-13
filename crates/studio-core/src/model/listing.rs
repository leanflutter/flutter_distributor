use serde::{Deserialize, Serialize};
use serde_yaml::Value;

use super::catalog::CatalogEntryKind;
use super::store::StoreKind;

/// A store listing, assembled from a pulled catalog.
///
/// This is the shape of a product page — what the store shows a customer —
/// rather than the shape of the files it came from. The two differ: a catalog
/// splits one listing across `info/`, `versions/` and a screenshot tree, and
/// `pull` writes only the fields a version actually changed, so reading any one
/// file gives a partial picture.
// `Eq` is out: a rollout is a fraction, and floats have no total equality.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct StoreListing {
    pub store_app_id: String,
    pub store: StoreKind,
    pub identifier: String,

    /// Every locale the catalog holds, and the one this listing is for.
    pub locales: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub locale: Option<String>,
    /// App Store versions, or Google Play tracks.
    pub versions: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub version: Option<String>,

    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub subtitle: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub promotional_text: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub whats_new: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub keywords: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub copyright: Option<String>,

    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub marketing_url: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub support_url: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub privacy_policy_url: Option<String>,

    /// Category identifiers, primary first.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub categories: Vec<String>,

    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub media: Vec<ListingMediaGroup>,
    /// Google Play only.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub tracks: Vec<ListingTrack>,

    /// True when the catalog has nothing for the selected locale and version.
    pub empty: bool,
}

/// Screenshots for one device class, or previews of one type.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ListingMediaGroup {
    /// The directory name the store uses, e.g. `APP_IPHONE_67`.
    pub id: String,
    /// The same thing, readable.
    pub label: String,
    pub items: Vec<ListingMediaItem>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ListingMediaItem {
    /// Path relative to the catalog directory — fetch through `catalog/raw`.
    pub path: String,
    pub name: String,
    pub kind: CatalogEntryKind,
}

// `Eq` is out: a rollout is a fraction, and floats have no total equality.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ListingTrack {
    pub name: String,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub releases: Vec<ListingTrackRelease>,
}

// `Eq` is out: a rollout is a fraction, and floats have no total equality.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ListingTrackRelease {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub status: Option<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub version_codes: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub user_fraction: Option<f64>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub release_notes: Option<String>,
}

/// The raw documents a host read out of the catalog.
///
/// The host does the walking — which locales exist, which versions, which
/// screenshot directories — because that is filesystem work. Everything about
/// what the documents *mean* happens here.
#[derive(Debug, Clone, Default)]
pub struct ListingSource {
    pub locales: Vec<String>,
    pub locale: Option<String>,
    pub versions: Vec<String>,
    pub version: Option<String>,

    /// `app_info.yaml`
    pub app_info_yaml: Option<String>,
    /// `info/<locale>.yaml`
    pub info_yaml: Option<String>,
    /// `versions/<platform>/<version>/<locale>/localization.yaml`, selected
    /// version first, then earlier ones — see [`build_listing`].
    pub localization_yaml: Vec<String>,
    /// `versions/<platform>/<version>/version.yaml`, same ordering.
    pub version_yaml: Vec<String>,

    /// `listings/<language>.yaml` (Google Play)
    pub listing_yaml: Option<String>,
    /// `tracks/<track>.yaml` (Google Play)
    pub track_yaml: Vec<String>,

    pub media: Vec<ListingMediaGroup>,
}

/// Assembles a listing from the documents a catalog holds.
///
/// Fields are merged across versions, nearest first. `fastforge … catalog pull`
/// writes a version's localization only where it *differs* from the previous
/// one, so a version whose description never changed has no description on
/// disk — reading its file alone would show a blank page for an app whose
/// listing is perfectly fine.
pub fn build_listing(store: StoreKind, identifier: &str, source: ListingSource) -> StoreListing {
    let info = parse(source.info_yaml.as_deref());
    let app_info = parse(source.app_info_yaml.as_deref());
    let listing = parse(source.listing_yaml.as_deref());
    let localizations = parse_all(&source.localization_yaml);
    let versions_docs = parse_all(&source.version_yaml);
    let tracks: Vec<ListingTrack> = source
        .track_yaml
        .iter()
        .filter_map(|yaml| parse(Some(yaml)))
        .map(track_from)
        .collect();

    let (name, subtitle, description, whats_new) = match store {
        StoreKind::AppStore => (
            info.as_ref().and_then(|doc| text(doc, "name")),
            info.as_ref().and_then(|doc| text(doc, "subtitle")),
            first_text(&localizations, "description"),
            first_text(&localizations, "whatsNew"),
        ),
        StoreKind::GooglePlay => (
            listing.as_ref().and_then(|doc| text(doc, "title")),
            listing
                .as_ref()
                .and_then(|doc| text(doc, "shortDescription")),
            listing
                .as_ref()
                .and_then(|doc| text(doc, "fullDescription")),
            // Google Play keeps release notes on the track, not the listing.
            tracks
                .iter()
                .flat_map(|track| track.releases.iter())
                .find_map(|release| release.release_notes.clone()),
        ),
    };

    let listing = StoreListing {
        store_app_id: super::store::store_app_id(store, identifier),
        store,
        identifier: identifier.to_owned(),
        locales: source.locales,
        locale: source.locale,
        versions: source.versions,
        version: source.version,
        name,
        subtitle,
        promotional_text: first_text(&localizations, "promotionalText"),
        description,
        whats_new,
        keywords: first_text(&localizations, "keywords"),
        copyright: first_text(&versions_docs, "copyright"),
        marketing_url: first_text(&localizations, "marketingUrl"),
        support_url: first_text(&localizations, "supportUrl"),
        privacy_policy_url: info.as_ref().and_then(|doc| text(doc, "privacyPolicyUrl")),
        categories: categories_from(app_info.as_ref()),
        media: source.media,
        tracks,
        empty: false,
    };

    StoreListing {
        empty: is_empty(&listing),
        ..listing
    }
}

/// Whether there is anything worth rendering. Media alone counts: a catalog
/// pulled for its screenshots is not an empty listing.
fn is_empty(listing: &StoreListing) -> bool {
    listing.name.is_none()
        && listing.subtitle.is_none()
        && listing.description.is_none()
        && listing.whats_new.is_none()
        && listing.promotional_text.is_none()
        && listing.keywords.is_none()
        && listing.categories.is_empty()
        && listing.media.is_empty()
        && listing.tracks.is_empty()
}

/// Categories, primary first, skipping the ones the app did not set.
fn categories_from(app_info: Option<&Value>) -> Vec<String> {
    const FIELDS: [&str; 6] = [
        "primaryCategory",
        "primarySubcategoryOne",
        "primarySubcategoryTwo",
        "secondaryCategory",
        "secondarySubcategoryOne",
        "secondarySubcategoryTwo",
    ];
    let Some(app_info) = app_info else {
        return Vec::new();
    };
    FIELDS
        .iter()
        .filter_map(|field| text(app_info, field))
        .collect()
}

fn track_from(doc: Value) -> ListingTrack {
    let releases = doc
        .get("releases")
        .and_then(Value::as_sequence)
        .map(|releases| releases.iter().map(release_from).collect())
        .unwrap_or_default();

    ListingTrack {
        name: text(&doc, "track").unwrap_or_else(|| "unknown".to_owned()),
        releases,
    }
}

fn release_from(doc: &Value) -> ListingTrackRelease {
    ListingTrackRelease {
        name: text(doc, "name"),
        status: text(doc, "status"),
        version_codes: doc
            .get("versionCodes")
            .and_then(Value::as_sequence)
            .map(|codes| {
                codes
                    .iter()
                    .filter_map(|code| match code {
                        Value::String(code) => Some(code.clone()),
                        Value::Number(code) => Some(code.to_string()),
                        _ => None,
                    })
                    .collect()
            })
            .unwrap_or_default(),
        user_fraction: doc.get("userFraction").and_then(Value::as_f64),
        // Release notes are per-language; the first is the one to show beside a
        // listing that is already scoped to one locale.
        release_notes: doc
            .get("releaseNotes")
            .and_then(Value::as_sequence)
            .and_then(|notes| notes.first())
            .and_then(|note| text(note, "text")),
    }
}

fn parse(yaml: Option<&str>) -> Option<Value> {
    let yaml = yaml?;
    if yaml.trim().is_empty() {
        return None;
    }
    // A document Studio cannot parse is skipped rather than fatal: one broken
    // locale file should not blank out the rest of the listing.
    serde_yaml::from_str(yaml).ok()
}

fn parse_all(documents: &[String]) -> Vec<Value> {
    documents
        .iter()
        .filter_map(|yaml| parse(Some(yaml)))
        .collect()
}

fn text(doc: &Value, key: &str) -> Option<String> {
    doc.get(key)?
        .as_str()
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(str::to_owned)
}

/// The first document that carries this field — the merge that reverses
/// `pull`'s per-version diffing.
fn first_text(documents: &[Value], key: &str) -> Option<String> {
    documents.iter().find_map(|doc| text(doc, key))
}

/// A readable name for a screenshot directory.
///
/// Both stores name these by device class in their own casing —
/// `APP_IPHONE_67`, `phone_screenshots` — which is fine in a file tree and
/// wrong above a gallery.
pub fn media_group_label(id: &str) -> String {
    const KNOWN: [(&str, &str); 20] = [
        ("APP_IPHONE_67", "iPhone 6.7\""),
        ("APP_IPHONE_65", "iPhone 6.5\""),
        ("APP_IPHONE_61", "iPhone 6.1\""),
        ("APP_IPHONE_58", "iPhone 5.8\""),
        ("APP_IPHONE_55", "iPhone 5.5\""),
        ("APP_IPHONE_47", "iPhone 4.7\""),
        ("APP_IPAD_PRO_3GEN_129", "iPad Pro 12.9\" (3rd gen)"),
        ("APP_IPAD_PRO_3GEN_11", "iPad Pro 11\" (3rd gen)"),
        ("APP_IPAD_PRO_129", "iPad Pro 12.9\""),
        ("APP_IPAD_105", "iPad 10.5\""),
        ("APP_IPAD_97", "iPad 9.7\""),
        ("APP_DESKTOP", "Mac"),
        ("APP_APPLE_TV", "Apple TV"),
        ("APP_APPLE_VISION_PRO", "Apple Vision Pro"),
        ("phone_screenshots", "Phone"),
        ("seven_inch_screenshots", "7-inch tablet"),
        ("ten_inch_screenshots", "10-inch tablet"),
        ("tv_screenshots", "TV"),
        ("wear_screenshots", "Wear"),
        ("feature_graphic", "Feature graphic"),
    ];

    if let Some((_, label)) = KNOWN.iter().find(|(known, _)| *known == id) {
        return (*label).to_owned();
    }

    // Anything the stores add later still reads as words rather than a token.
    let words: Vec<String> = id
        .split(['_', '-'])
        .filter(|word| !word.is_empty())
        .map(|word| {
            let mut characters = word.chars();
            match characters.next() {
                Some(first) => {
                    first.to_uppercase().collect::<String>() + &characters.as_str().to_lowercase()
                }
                None => String::new(),
            }
        })
        .collect();
    if words.is_empty() {
        id.to_owned()
    } else {
        words.join(" ")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn source() -> ListingSource {
        ListingSource {
            locales: vec!["en-US".into()],
            locale: Some("en-US".into()),
            versions: vec!["1.2.0".into(), "1.1.0".into()],
            version: Some("1.2.0".into()),
            ..Default::default()
        }
    }

    #[test]
    fn an_app_store_listing_reads_from_info_and_localization() {
        let listing = build_listing(
            StoreKind::AppStore,
            "com.example.app",
            ListingSource {
                info_yaml: Some(
                    "locale: en-US\nname: Demo App\nsubtitle: Ship faster\nprivacyPolicyUrl: https://example.com/privacy\n"
                        .into(),
                ),
                localization_yaml: vec![
                    "description: A demo.\nkeywords: demo,app\nwhatsNew: Bug fixes\nsupportUrl: https://example.com/help\n"
                        .into(),
                ],
                version_yaml: vec!["copyright: 2026 Example\n".into()],
                app_info_yaml: Some("primaryCategory: DEVELOPER_TOOLS\n".into()),
                ..source()
            },
        );

        assert_eq!(listing.name.as_deref(), Some("Demo App"));
        assert_eq!(listing.subtitle.as_deref(), Some("Ship faster"));
        assert_eq!(listing.description.as_deref(), Some("A demo."));
        assert_eq!(listing.whats_new.as_deref(), Some("Bug fixes"));
        assert_eq!(listing.keywords.as_deref(), Some("demo,app"));
        assert_eq!(listing.copyright.as_deref(), Some("2026 Example"));
        assert_eq!(
            listing.support_url.as_deref(),
            Some("https://example.com/help")
        );
        assert_eq!(
            listing.privacy_policy_url.as_deref(),
            Some("https://example.com/privacy")
        );
        assert_eq!(listing.categories, ["DEVELOPER_TOOLS"]);
        assert_eq!(listing.store_app_id, "appstore:com.example.app");
        assert!(!listing.empty);
    }

    #[test]
    fn fields_fall_back_to_earlier_versions() {
        // What `pull` actually writes: 1.2.0 changed only its release notes, so
        // the description lives with the version that last changed it.
        let listing = build_listing(
            StoreKind::AppStore,
            "com.example.app",
            ListingSource {
                localization_yaml: vec![
                    "whatsNew: Faster startup\n".into(),
                    "description: The original description.\nwhatsNew: First release\n".into(),
                ],
                ..source()
            },
        );

        assert_eq!(listing.whats_new.as_deref(), Some("Faster startup"));
        assert_eq!(
            listing.description.as_deref(),
            Some("The original description."),
            "an unchanged field is still part of the listing"
        );
    }

    #[test]
    fn blank_fields_do_not_shadow_earlier_ones() {
        let listing = build_listing(
            StoreKind::AppStore,
            "com.example.app",
            ListingSource {
                localization_yaml: vec![
                    "description: '   '\n".into(),
                    "description: Real text.\n".into(),
                ],
                ..source()
            },
        );
        assert_eq!(listing.description.as_deref(), Some("Real text."));
    }

    #[test]
    fn a_google_play_listing_reads_from_listings_and_tracks() {
        let listing = build_listing(
            StoreKind::GooglePlay,
            "com.example.app",
            ListingSource {
                listing_yaml: Some(
                    "language: en-US\ntitle: Demo App\nshortDescription: Ship faster\nfullDescription: A demo.\n"
                        .into(),
                ),
                track_yaml: vec![
                    "track: production\nreleases:\n  - name: 1.2.0\n    status: completed\n    versionCodes: [7]\n    releaseNotes:\n      - language: en-US\n        text: Bug fixes\n"
                        .into(),
                ],
                versions: vec!["production".into()],
                version: Some("production".into()),
                ..source()
            },
        );

        assert_eq!(listing.name.as_deref(), Some("Demo App"));
        assert_eq!(listing.subtitle.as_deref(), Some("Ship faster"));
        assert_eq!(listing.description.as_deref(), Some("A demo."));
        assert_eq!(listing.whats_new.as_deref(), Some("Bug fixes"));

        let track = &listing.tracks[0];
        assert_eq!(track.name, "production");
        assert_eq!(track.releases[0].name.as_deref(), Some("1.2.0"));
        assert_eq!(track.releases[0].version_codes, ["7"]);
        assert_eq!(track.releases[0].status.as_deref(), Some("completed"));
    }

    #[test]
    fn a_catalog_with_only_screenshots_is_not_empty() {
        let listing = build_listing(
            StoreKind::AppStore,
            "com.example.app",
            ListingSource {
                media: vec![ListingMediaGroup {
                    id: "APP_IPHONE_67".into(),
                    label: media_group_label("APP_IPHONE_67"),
                    items: vec![ListingMediaItem {
                        path: "versions/IOS/1.2.0/en-US/screenshots/APP_IPHONE_67/01.png".into(),
                        name: "01.png".into(),
                        kind: CatalogEntryKind::Image,
                    }],
                }],
                ..source()
            },
        );
        assert!(!listing.empty);
        assert_eq!(listing.media[0].label, "iPhone 6.7\"");
    }

    #[test]
    fn nothing_at_all_is_empty() {
        assert!(build_listing(StoreKind::AppStore, "com.example.app", source()).empty);
    }

    #[test]
    fn a_malformed_document_is_skipped_rather_than_fatal() {
        let listing = build_listing(
            StoreKind::AppStore,
            "com.example.app",
            ListingSource {
                info_yaml: Some("name: [unclosed\n".into()),
                localization_yaml: vec!["description: Still here.\n".into()],
                ..source()
            },
        );
        assert!(listing.name.is_none());
        assert_eq!(listing.description.as_deref(), Some("Still here."));
    }

    #[test]
    fn unknown_device_classes_still_read_as_words() {
        assert_eq!(media_group_label("APP_IPHONE_67"), "iPhone 6.7\"");
        assert_eq!(media_group_label("phone_screenshots"), "Phone");
        assert_eq!(media_group_label("APP_WATCH_ULTRA"), "App Watch Ultra");
        assert_eq!(media_group_label("someNewType"), "Somenewtype");
    }
}
