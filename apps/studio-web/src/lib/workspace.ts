import type { Platform } from 'studio-api-client'

export type { Platform, Project, ProjectSummary } from 'studio-api-client'

export const platformLabels: Record<Platform, string> = {
  android: 'Android',
  ios: 'iOS',
  macos: 'macOS',
  windows: 'Windows',
  linux: 'Linux',
  web: 'Web',
}

export function formatPlatforms(platforms: Array<Platform>): string {
  return platforms.map((platform) => platformLabels[platform]).join(' · ')
}
