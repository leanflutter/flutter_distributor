import { createFileRoute } from '@tanstack/react-router'
import { PackageIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { PageHeader } from '#/components/page-header'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/artifacts/')({
  component: Artifacts,
})

function Artifacts() {
  const { t } = useI18n()
  return (
    <>
      <PageHeader crumbs={[{ label: t('Artifacts') }]} />
      <PageBody>
        <PageTitle
          title={t('Artifacts')}
          description={t(
            'Every package the packagers produced — APK, AAB, IPA, DMG, PKG, ZIP.',
          )}
        />
        <EmptyState
          icon={PackageIcon}
          title={t('No artifacts yet')}
          description={t(
            'Packages appear here once a run finishes. Each one can be analyzed and published from its detail page.',
          )}
        />
      </PageBody>
    </>
  )
}
