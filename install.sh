#!/bin/sh
set -e

REPO="fastforgedev/fastforge"
BINARY_NAME="fastforge"
INSTALL_DIR="${FASTFORGE_INSTALL_DIR:-/usr/local/bin}"

# ── Terminal colors ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { printf "${CYAN}info${RESET}  %s\n" "$1"; }
success() { printf "${GREEN}✓${RESET}     %s\n" "$1"; }
warn()    { printf "${YELLOW}warn${RESET}  %s\n" "$1"; }
error()   { printf "${RED}error${RESET} %s\n" "$1" >&2; exit 1; }

# ── Detect OS / arch ──────────────────────────────────────────────────────────
detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Linux)  OS_NAME="linux" ;;
    Darwin) OS_NAME="darwin" ;;
    *)      error "Unsupported operating system: $OS" ;;
  esac

  case "$ARCH" in
    x86_64 | amd64)  ARCH_NAME="x86_64" ;;
    aarch64 | arm64) ARCH_NAME="aarch64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
  esac

  PLATFORM="${OS_NAME}-${ARCH_NAME}"
}

# ── Map platform to Rust target triple ────────────────────────────────────────
resolve_target() {
  case "$PLATFORM" in
    darwin-aarch64) TARGET="aarch64-apple-darwin" ;;
    darwin-x86_64)  TARGET="x86_64-apple-darwin" ;;
    linux-aarch64)  TARGET="aarch64-unknown-linux-gnu" ;;
    linux-x86_64)   TARGET="x86_64-unknown-linux-gnu" ;;
    *) error "No prebuilt binary available for platform: $PLATFORM" ;;
  esac
}

# ── Fetch release JSON from GitHub API ────────────────────────────────────────
fetch_releases() {
  API_URL="https://api.github.com/repos/${REPO}/releases"

  if [ -n "$GITHUB_TOKEN" ]; then
    if command -v curl >/dev/null 2>&1; then
      RELEASE_JSON="$(curl -fsSL -H "Authorization: Bearer ${GITHUB_TOKEN}" "$API_URL")"
    elif command -v wget >/dev/null 2>&1; then
      RELEASE_JSON="$(wget -qO- --header="Authorization: Bearer ${GITHUB_TOKEN}" "$API_URL")"
    else
      error "Neither curl nor wget is available. Please install one and retry."
    fi
  else
    if command -v curl >/dev/null 2>&1; then
      RELEASE_JSON="$(curl -fsSL "$API_URL")"
    elif command -v wget >/dev/null 2>&1; then
      RELEASE_JSON="$(wget -qO- "$API_URL")"
    else
      error "Neither curl nor wget is available. Please install one and retry."
    fi
  fi

  if [ -z "$RELEASE_JSON" ]; then
    error "Failed to fetch release information from GitHub API."
  fi
}

# ── Resolve version + download URL ────────────────────────────────────────────
resolve_release() {
  if [ -n "$FASTFORGE_VERSION" ]; then
    VERSION="$FASTFORGE_VERSION"
    info "Using specified version: $VERSION"

    # When version is manually specified, fall back to constructing the URL
    ARCHIVE_NAME="${BINARY_NAME}-${VERSION}-${TARGET}.tar.gz"
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${ARCHIVE_NAME}"
    return
  fi

  info "Fetching latest release version..."
  fetch_releases

  # Pick the newest release that ships a binary for this target (releases are
  # listed newest first; releases from the Dart era carry no binaries).
  ARCHIVE_NAME="$(printf '%s' "$RELEASE_JSON" \
    | grep -o "\"name\": *\"${BINARY_NAME}-[^\"]*-${TARGET}\.tar\.gz\"" \
    | head -1 \
    | sed 's/.*"\([^"]*\)"$/\1/')"

  if [ -z "$ARCHIVE_NAME" ]; then
    error "No release provides a prebuilt binary for ${TARGET}. Set FASTFORGE_VERSION to specify one manually."
  fi

  VERSION="${ARCHIVE_NAME#"${BINARY_NAME}-"}"
  VERSION="${VERSION%"-${TARGET}.tar.gz"}"

  info "Latest version: $VERSION"

  # asset "url" field = API download endpoint (works for draft assets with token)
  # Strategy: find the line with "url": ".../releases/assets/..." that appears just
  # before the line containing the archive name (POSIX awk + sed, no gawk needed).
  ASSET_API_URL="$(printf '%s' "$RELEASE_JSON" \
    | awk -v name="$ARCHIVE_NAME" '
        /"url":.*releases\/assets\// { last = $0 }
        index($0, name) && last { print last; last = ""; exit }
      ' \
    | sed 's/[^"]*"url"[^"]*"\([^"]*\)".*/\1/')"

  # browser_download_url = public CDN link (only works for published releases)
  DOWNLOAD_URL="$(printf '%s' "$RELEASE_JSON" | grep '"browser_download_url"' | grep "${ARCHIVE_NAME}" | head -1 | sed 's/[^"]*"browser_download_url"[^"]*"\([^"]*\)".*/\1/')"

  if [ -z "$DOWNLOAD_URL" ] && [ -z "$ASSET_API_URL" ]; then
    error "No download asset found for target ${TARGET} in the latest release. The release may not have finished uploading assets yet."
  fi
}

# ── Download ──────────────────────────────────────────────────────────────────
download() {
  TMP_DIR="$(mktemp -d)"
  ARCHIVE_PATH="${TMP_DIR}/${ARCHIVE_NAME}"

  # Use API asset URL with token for draft releases, otherwise use browser_download_url
  if [ -n "$GITHUB_TOKEN" ] && [ -n "$ASSET_API_URL" ]; then
    info "Downloading ${ARCHIVE_NAME} (via API)..."
    info "  from ${ASSET_API_URL}"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL --progress-bar \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "Accept: application/octet-stream" \
        "$ASSET_API_URL" -o "$ARCHIVE_PATH" || \
        error "Download failed. Check your network or verify that version v${VERSION} exists."
    elif command -v wget >/dev/null 2>&1; then
      wget -q --show-progress \
        --header="Authorization: Bearer ${GITHUB_TOKEN}" \
        --header="Accept: application/octet-stream" \
        "$ASSET_API_URL" -O "$ARCHIVE_PATH" 2>&1 || \
        error "Download failed. Check your network or verify that version v${VERSION} exists."
    fi
  else
    info "Downloading ${ARCHIVE_NAME}..."
    info "  from ${DOWNLOAD_URL}"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL --progress-bar "$DOWNLOAD_URL" -o "$ARCHIVE_PATH" || \
        error "Download failed. Check your network or verify that version v${VERSION} exists."
    elif command -v wget >/dev/null 2>&1; then
      wget -q --show-progress "$DOWNLOAD_URL" -O "$ARCHIVE_PATH" 2>&1 || \
        error "Download failed. Check your network or verify that version v${VERSION} exists."
    fi
  fi

  success "Downloaded ${ARCHIVE_NAME}"
}

# ── Install ───────────────────────────────────────────────────────────────────
install_binary() {
  info "Extracting archive..."
  tar -xzf "$ARCHIVE_PATH" -C "$TMP_DIR"

  BINARY_PATH="${TMP_DIR}/${BINARY_NAME}-${VERSION}-${TARGET}/${BINARY_NAME}"

  if [ ! -f "$BINARY_PATH" ]; then
    error "Binary not found in archive at expected path: ${BINARY_PATH}"
  fi

  chmod +x "$BINARY_PATH"

  if [ ! -d "$INSTALL_DIR" ]; then
    info "Creating install directory: ${INSTALL_DIR}"
    mkdir -p "$INSTALL_DIR" 2>/dev/null || sudo mkdir -p "$INSTALL_DIR"
  fi

  if [ -w "$INSTALL_DIR" ]; then
    mv "$BINARY_PATH" "${INSTALL_DIR}/${BINARY_NAME}"
  else
    info "Requesting elevated permissions to install into ${INSTALL_DIR}..."
    sudo mv "$BINARY_PATH" "${INSTALL_DIR}/${BINARY_NAME}"
  fi

  rm -rf "$TMP_DIR"

  success "Installed ${BINARY_NAME} to ${INSTALL_DIR}/${BINARY_NAME}"
}

# ── Verify ────────────────────────────────────────────────────────────────────
verify() {
  if command -v "$BINARY_NAME" >/dev/null 2>&1; then
    INSTALLED_VERSION="$("${INSTALL_DIR}/${BINARY_NAME}" --version 2>/dev/null || true)"
    success "Installation verified: ${INSTALLED_VERSION}"
  else
    warn "${BINARY_NAME} is not on your PATH."
    warn "Add the following line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    warn "  export PATH=\"${INSTALL_DIR}:\$PATH\""
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  printf "\n${BOLD}fastforge installer${RESET}\n\n"

  detect_platform
  resolve_target
  resolve_release
  download
  install_binary
  verify

  printf "\n${BOLD}${GREEN}fastforge ${VERSION} installed successfully!${RESET}\n\n"
  printf "Run ${CYAN}fastforge --help${RESET} to get started.\n\n"
}

main
