/**
 * Distribution targets. These are deliberately data rather than navigation:
 * Fastforge ships eight publishers already and keeps adding them, so they are
 * listed on a page instead of enumerated in the sidebar.
 *
 * Stores used to live here too. They now come from the API, read out of the
 * project's own `.fastforge/config.yaml` — see the stores routes.
 */

export type Target = {
  id: string
  name: string
  description: string
  /** Shown under the name once the target is configured. */
  detail?: string
  connected: boolean
}

/**
 * Publishers upload one artifact to one destination.
 *
 * Still placeholder data: publishers are out of scope for this round, and the
 * page says as much rather than pretending to be connected to anything.
 */
export const publisherTargets: Array<Target> = [
  {
    id: 'firebase',
    name: 'Firebase App Distribution',
    description: 'Internal and tester distribution for Android and iOS.',
    detail: 'testers · qa, internal',
    connected: true,
  },
  {
    id: 'github',
    name: 'GitHub Releases',
    description: 'Attach artifacts to a tagged GitHub release.',
    detail: 'fastforgedev/fastforge',
    connected: true,
  },
  {
    id: 's3',
    name: 'S3-compatible storage',
    description: 'Any bucket that speaks the S3 API.',
    connected: false,
  },
  {
    id: 'fir',
    name: 'fir.im',
    description: 'Hosted install pages for Android and iOS builds.',
    connected: false,
  },
  {
    id: 'vercel',
    name: 'Vercel',
    description: 'Publish artifacts alongside a Vercel deployment.',
    connected: false,
  },
  {
    id: 'appstore',
    name: 'App Store',
    description: 'Upload an IPA without managing the listing.',
    connected: false,
  },
  {
    id: 'appgallery',
    name: 'AppGallery',
    description: 'Upload to Huawei AppGallery.',
    connected: false,
  },
  {
    id: 'custom',
    name: 'Custom',
    description: 'Run your own command to move the artifact.',
    connected: false,
  },
]
