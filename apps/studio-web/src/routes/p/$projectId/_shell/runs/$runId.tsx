import { createFileRoute } from '@tanstack/react-router'
import { ScrollTextIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { PageHeader } from '#/components/page-header'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/runs/$runId')({
  component: RunDetail,
})

function RunDetail() {
  const { projectId, runId } = Route.useParams()
  const { t } = useI18n()

  return (
    <>
      <PageHeader
        crumbs={[
          {
            label: t('Runs'),
            link: { to: '/p/$projectId/runs', params: { projectId } },
          },
          { label: runId },
        ]}
      />
      <PageBody>
        <PageTitle
          title={t('Run {id}', { id: runId })}
          description={t(
            'Step timeline, logs and the artifacts this run produced.',
          )}
        />
        <EmptyState
          icon={ScrollTextIcon}
          title={t('Run log')}
          description={t(
            'Streaming step output and per-step timings will render here.',
          )}
        />
      </PageBody>
    </>
  )
}
