import { createFileRoute } from '@tanstack/react-router'
import { RocketIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { PageHeader } from '#/components/page-header'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/releases/')({
  component: Releases,
})

function Releases() {
  const { t } = useI18n()
  return (
    <>
      <PageHeader crumbs={[{ label: t('Releases') }]} />
      <PageBody>
        <PageTitle
          title={t('Releases')}
          description={t(
            'One row per version, showing where that version currently stands on each channel.',
          )}
        />
        <EmptyState
          icon={RocketIcon}
          title={t('No releases yet')}
          description={t(
            'A release groups the artifacts of one version and tracks their status across every store and publisher.',
          )}
        />
      </PageBody>
    </>
  )
}
