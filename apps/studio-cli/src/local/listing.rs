use std::cmp::Ordering;
use std::path::Path;

use studio_core::model::{
    CatalogEntryKind, ListingMediaGroup, ListingMediaItem, ListingSource, StoreKind, StoreListing,
    build_listing, media_group_label,
};

use super::catalog::catalog_path;

/// Assembles the listing a store would show, out of a pulled catalog.
///
/// A catalog on disk is organised for syncing — split by locale, by version, by
/// device class, with only the fields each version changed. A listing is
/// organised for reading. This is where one becomes the other; the merging
/// rules live in `studio_core`.
///
/// An unpulled catalog is not an error: it yields an empty listing, and the
/// page says so. There is nothing wrong with a store app nobody has pulled yet.
pub fn listing(
    project: &Path,
    store: StoreKind,
    identifier: &str,
    locale: Option<&str>,
    version: Option<&str>,
) -> StoreListing {
    let root = catalog_path(project, store, identifier);
    if !root.is_dir() {
        return build_listing(store, identifier, ListingSource::default());
    }

    let source = match store {
        StoreKind::AppStore => app_store_source(&root, locale, version),
        StoreKind::GooglePlay => google_play_source(&root, locale, version),
    };
    build_listing(store, identifier, source)
}

fn app_store_source(root: &Path, locale: Option<&str>, version: Option<&str>) -> ListingSource {
    // `versions/<PLATFORM>/<VERSION>`, kept as one id so two platforms sharing
    // a version string stay distinct.
    let mut versions: Vec<String> = Vec::new();
    for platform in child_dirs(&root.join("versions")) {
        for version_dir in child_dirs(&root.join("versions").join(&platform)) {
            versions.push(format!("{platform}/{version_dir}"));
        }
    }
    versions.sort_by(|left, right| compare_versions(right, left));

    let mut locales = yaml_stems(&root.join("info"));
    if locales.is_empty() {
        // A catalog can carry version localizations without app-level info.
        locales = versions
            .first()
            .map(|version| child_dirs(&root.join("versions").join(version)))
            .unwrap_or_default();
    }

    let selected_locale = pick_locale(&locales, locale);
    let selected_version = pick(&versions, version);

    // Nearest first: the selected version, then the rest newest-first. Core
    // merges across them, which is what undoes `pull`'s per-version diffing.
    let ordered: Vec<&String> = selected_version
        .iter()
        .chain(
            versions
                .iter()
                .filter(|candidate| Some(*candidate) != selected_version.as_ref()),
        )
        .collect();

    let localization_yaml = selected_locale
        .as_ref()
        .map(|locale| {
            ordered
                .iter()
                .filter_map(|version| {
                    read(
                        &root
                            .join("versions")
                            .join(version)
                            .join(locale)
                            .join("localization.yaml"),
                    )
                })
                .collect()
        })
        .unwrap_or_default();

    let version_yaml = ordered
        .iter()
        .filter_map(|version| read(&root.join("versions").join(version).join("version.yaml")))
        .collect();

    // Screenshots are deduplicated across versions the same way text is, so a
    // version that changed nothing visual has no screenshot directory. Fall
    // back through the versions until one has media.
    let media = ordered
        .iter()
        .find_map(|version| {
            let locale = selected_locale.as_ref()?;
            let locale_dir = root.join("versions").join(version).join(locale);
            let groups = [
                media_groups(&locale_dir.join("screenshots"), root),
                media_groups(&locale_dir.join("previews"), root),
            ]
            .concat();
            (!groups.is_empty()).then_some(groups)
        })
        .unwrap_or_default();

    ListingSource {
        locales,
        locale: selected_locale.clone(),
        versions,
        version: selected_version,
        app_info_yaml: read(&root.join("app_info.yaml")),
        info_yaml: selected_locale
            .as_ref()
            .and_then(|locale| read(&root.join("info").join(format!("{locale}.yaml")))),
        localization_yaml,
        version_yaml,
        media,
        ..Default::default()
    }
}

fn google_play_source(root: &Path, locale: Option<&str>, track: Option<&str>) -> ListingSource {
    let locales = yaml_stems(&root.join("listings"));
    let mut tracks = yaml_stems(&root.join("tracks"));
    // Production first, then the rest alphabetically — the order a release
    // manager thinks in, rather than the order the filesystem returns.
    tracks.sort_by_key(|name| (name != "production", name.clone()));

    let selected_locale = pick_locale(&locales, locale);
    let selected_track = pick(&tracks, track);

    // Selected track first: core takes its release notes as "what's new".
    let track_yaml = selected_track
        .iter()
        .chain(
            tracks
                .iter()
                .filter(|candidate| Some(*candidate) != selected_track.as_ref()),
        )
        .filter_map(|name| read(&root.join("tracks").join(format!("{name}.yaml"))))
        .collect();

    let media = selected_locale
        .as_ref()
        .map(|locale| media_groups(&root.join("screenshots").join(locale), root))
        .unwrap_or_default();

    ListingSource {
        locales,
        locale: selected_locale.clone(),
        versions: tracks,
        version: selected_track,
        listing_yaml: selected_locale
            .as_ref()
            .and_then(|locale| read(&root.join("listings").join(format!("{locale}.yaml")))),
        track_yaml,
        media,
        ..Default::default()
    }
}

/// One group per device-class directory, each holding its images in file order
/// — which is the order `push` uploads them in, so it is the order that
/// matters.
fn media_groups(parent: &Path, root: &Path) -> Vec<ListingMediaGroup> {
    let mut groups: Vec<ListingMediaGroup> = child_dirs(parent)
        .into_iter()
        .filter_map(|group| {
            let dir = parent.join(&group);
            let mut items: Vec<ListingMediaItem> = std::fs::read_dir(&dir)
                .ok()?
                .flatten()
                .filter(|entry| entry.file_type().is_ok_and(|kind| kind.is_file()))
                .filter_map(|entry| {
                    let name = entry.file_name().to_string_lossy().into_owned();
                    let kind = CatalogEntryKind::for_path(&name);
                    if !matches!(kind, CatalogEntryKind::Image | CatalogEntryKind::Video) {
                        return None;
                    }
                    Some(ListingMediaItem {
                        path: relative(root, &entry.path())?,
                        name,
                        kind,
                    })
                })
                .collect();
            items.sort_by(|left, right| left.name.cmp(&right.name));

            (!items.is_empty()).then(|| ListingMediaGroup {
                label: media_group_label(&group),
                id: group,
                items,
            })
        })
        .collect();
    groups.sort_by(|left, right| left.id.cmp(&right.id));
    groups
}

/// Prefers the requested value, then `en-US`, then whatever comes first.
///
/// The English default is not chauvinism: `en-US` is the App Store's primary
/// locale for most apps, and landing on an arbitrary one would make the page
/// look different every time the filesystem reordered.
fn pick_locale(locales: &[String], requested: Option<&str>) -> Option<String> {
    if let Some(requested) = requested
        && locales.iter().any(|locale| locale == requested)
    {
        return Some(requested.to_owned());
    }
    locales
        .iter()
        .find(|locale| *locale == "en-US")
        .or_else(|| locales.first())
        .cloned()
}

fn pick(candidates: &[String], requested: Option<&str>) -> Option<String> {
    if let Some(requested) = requested
        && candidates.iter().any(|candidate| candidate == requested)
    {
        return Some(requested.to_owned());
    }
    candidates.first().cloned()
}

/// Newest last — callers reverse it. Compares numeric segments as numbers, so
/// `1.10.0` sorts above `1.9.0` rather than below it.
fn compare_versions(left: &str, right: &str) -> Ordering {
    let mut left_parts = left.split(['/', '.', '-']);
    let mut right_parts = right.split(['/', '.', '-']);

    loop {
        match (left_parts.next(), right_parts.next()) {
            (None, None) => return Ordering::Equal,
            (None, Some(_)) => return Ordering::Less,
            (Some(_), None) => return Ordering::Greater,
            (Some(left), Some(right)) => {
                let ordering = match (left.parse::<u64>(), right.parse::<u64>()) {
                    (Ok(left), Ok(right)) => left.cmp(&right),
                    _ => left.cmp(right),
                };
                if ordering != Ordering::Equal {
                    return ordering;
                }
            }
        }
    }
}

fn child_dirs(parent: &Path) -> Vec<String> {
    let Ok(entries) = std::fs::read_dir(parent) else {
        return Vec::new();
    };
    let mut names: Vec<String> = entries
        .flatten()
        .filter(|entry| entry.file_type().is_ok_and(|kind| kind.is_dir()))
        .map(|entry| entry.file_name().to_string_lossy().into_owned())
        .collect();
    names.sort();
    names
}

/// File stems of the `*.yaml` files in a directory — locale codes under
/// `info/` and `listings/`, track names under `tracks/`.
fn yaml_stems(parent: &Path) -> Vec<String> {
    let Ok(entries) = std::fs::read_dir(parent) else {
        return Vec::new();
    };
    let mut names: Vec<String> = entries
        .flatten()
        .filter(|entry| entry.file_type().is_ok_and(|kind| kind.is_file()))
        .filter_map(|entry| {
            let name = entry.file_name().to_string_lossy().into_owned();
            // `.manifest.yaml` and friends are machine-owned bookkeeping.
            let stem = name.strip_suffix(".yaml")?;
            (!stem.starts_with('.')).then(|| stem.to_owned())
        })
        .collect();
    names.sort();
    names
}

fn read(path: &Path) -> Option<String> {
    std::fs::read_to_string(path).ok()
}

fn relative(root: &Path, path: &Path) -> Option<String> {
    Some(
        path.strip_prefix(root)
            .ok()?
            .to_string_lossy()
            .replace('\\', "/"),
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;
    use tempfile::TempDir;

    fn write(path: PathBuf, content: &str) {
        std::fs::create_dir_all(path.parent().unwrap()).unwrap();
        std::fs::write(path, content).unwrap();
    }

    /// A catalog shaped the way `fastforge appstore catalog pull` writes one,
    /// including its per-version diffing: 1.2.0 changed only its release notes.
    fn app_store_catalog() -> TempDir {
        let temp = TempDir::new().unwrap();
        let root = catalog_path(temp.path(), StoreKind::AppStore, "com.example.app");

        write(
            root.join("app_info.yaml"),
            "primaryCategory: PRODUCTIVITY\n",
        );
        write(
            root.join("info/en-US.yaml"),
            "locale: en-US\nname: Demo App\nsubtitle: Ship faster\n",
        );
        write(root.join("info/de-DE.yaml"), "locale: de-DE\nname: Demo\n");
        write(
            root.join("versions/IOS/1.1.0/version.yaml"),
            "copyright: 2025 Example\n",
        );
        write(
            root.join("versions/IOS/1.1.0/en-US/localization.yaml"),
            "description: The original description.\nwhatsNew: First release\n",
        );
        write(
            root.join("versions/IOS/1.2.0/en-US/localization.yaml"),
            "whatsNew: Faster startup\n",
        );
        write(
            root.join("versions/IOS/1.1.0/en-US/screenshots/APP_IPHONE_67/02.png"),
            "b",
        );
        write(
            root.join("versions/IOS/1.1.0/en-US/screenshots/APP_IPHONE_67/01.png"),
            "a",
        );
        temp
    }

    #[test]
    fn an_unpulled_catalog_is_an_empty_listing_rather_than_an_error() {
        let temp = TempDir::new().unwrap();
        let listing = listing(
            temp.path(),
            StoreKind::AppStore,
            "com.example.app",
            None,
            None,
        );
        assert!(listing.empty);
        assert!(listing.locales.is_empty());
        assert!(listing.versions.is_empty());
    }

    #[test]
    fn the_newest_version_and_en_us_are_the_defaults() {
        let temp = app_store_catalog();
        let listing = listing(
            temp.path(),
            StoreKind::AppStore,
            "com.example.app",
            None,
            None,
        );

        assert_eq!(listing.versions, ["IOS/1.2.0", "IOS/1.1.0"]);
        assert_eq!(listing.version.as_deref(), Some("IOS/1.2.0"));
        assert_eq!(listing.locales, ["de-DE", "en-US"]);
        assert_eq!(listing.locale.as_deref(), Some("en-US"));
    }

    #[test]
    fn text_missing_from_a_version_comes_from_the_one_that_last_changed_it() {
        let temp = app_store_catalog();
        let listing = listing(
            temp.path(),
            StoreKind::AppStore,
            "com.example.app",
            None,
            None,
        );

        assert_eq!(listing.name.as_deref(), Some("Demo App"));
        assert_eq!(listing.subtitle.as_deref(), Some("Ship faster"));
        assert_eq!(listing.whats_new.as_deref(), Some("Faster startup"));
        assert_eq!(
            listing.description.as_deref(),
            Some("The original description."),
            "1.2.0 never changed the description, so it is 1.1.0's"
        );
        assert_eq!(listing.copyright.as_deref(), Some("2025 Example"));
        assert_eq!(listing.categories, ["PRODUCTIVITY"]);
    }

    #[test]
    fn screenshots_fall_back_to_the_version_that_has_them() {
        let temp = app_store_catalog();
        let listing = listing(
            temp.path(),
            StoreKind::AppStore,
            "com.example.app",
            None,
            None,
        );

        assert_eq!(listing.media.len(), 1);
        let group = &listing.media[0];
        assert_eq!(group.id, "APP_IPHONE_67");
        assert_eq!(group.label, "iPhone 6.7\"");
        let names: Vec<&str> = group.items.iter().map(|item| item.name.as_str()).collect();
        assert_eq!(names, ["01.png", "02.png"], "file order is upload order");
        assert_eq!(
            group.items[0].path,
            "versions/IOS/1.1.0/en-US/screenshots/APP_IPHONE_67/01.png"
        );
    }

    #[test]
    fn an_explicit_locale_and_version_are_honoured() {
        let temp = app_store_catalog();
        let listing = listing(
            temp.path(),
            StoreKind::AppStore,
            "com.example.app",
            Some("de-DE"),
            Some("IOS/1.1.0"),
        );
        assert_eq!(listing.locale.as_deref(), Some("de-DE"));
        assert_eq!(listing.version.as_deref(), Some("IOS/1.1.0"));
        assert_eq!(listing.name.as_deref(), Some("Demo"));
    }

    #[test]
    fn an_unknown_locale_falls_back_instead_of_showing_nothing() {
        let temp = app_store_catalog();
        let listing = listing(
            temp.path(),
            StoreKind::AppStore,
            "com.example.app",
            Some("fr-FR"),
            None,
        );
        assert_eq!(listing.locale.as_deref(), Some("en-US"));
    }

    #[test]
    fn google_play_reads_listings_tracks_and_screenshots() {
        let temp = TempDir::new().unwrap();
        let root = catalog_path(temp.path(), StoreKind::GooglePlay, "com.example.app");

        write(
            root.join("listings/en-US.yaml"),
            "language: en-US\ntitle: Demo App\nshortDescription: Ship faster\nfullDescription: A demo.\n",
        );
        write(
            root.join("tracks/production.yaml"),
            "track: production\nreleases:\n  - name: 1.2.0\n    status: completed\n    versionCodes: [7]\n    releaseNotes:\n      - language: en-US\n        text: Bug fixes\n",
        );
        write(root.join("tracks/beta.yaml"), "track: beta\nreleases: []\n");
        write(
            root.join("screenshots/en-US/phone_screenshots/001_a.png"),
            "a",
        );

        let listing = listing(
            temp.path(),
            StoreKind::GooglePlay,
            "com.example.app",
            None,
            None,
        );

        assert_eq!(listing.name.as_deref(), Some("Demo App"));
        assert_eq!(listing.description.as_deref(), Some("A demo."));
        assert_eq!(listing.whats_new.as_deref(), Some("Bug fixes"));
        assert_eq!(
            listing.versions,
            ["production", "beta"],
            "production leads, whatever the filesystem says"
        );
        assert_eq!(listing.tracks.len(), 2);
        assert_eq!(listing.media[0].label, "Phone");
    }

    #[test]
    fn versions_sort_numerically_not_lexically() {
        let mut versions = vec![
            "IOS/1.9.0".to_owned(),
            "IOS/1.10.0".to_owned(),
            "IOS/1.2.0".to_owned(),
        ];
        versions.sort_by(|left, right| compare_versions(right, left));
        assert_eq!(versions, ["IOS/1.10.0", "IOS/1.9.0", "IOS/1.2.0"]);
    }

    #[test]
    fn machine_owned_files_are_not_locales() {
        let temp = TempDir::new().unwrap();
        let root = catalog_path(temp.path(), StoreKind::GooglePlay, "com.example.app");
        write(root.join("listings/en-US.yaml"), "title: Demo\n");
        write(root.join("listings/.manifest.yaml"), "screenshots: []\n");

        let listing = listing(
            temp.path(),
            StoreKind::GooglePlay,
            "com.example.app",
            None,
            None,
        );
        assert_eq!(listing.locales, ["en-US"]);
    }
}
