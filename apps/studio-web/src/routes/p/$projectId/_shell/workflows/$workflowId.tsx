import { createFileRoute } from '@tanstack/react-router'
import { WorkflowIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { PageHeader } from '#/components/page-header'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute(
  '/p/$projectId/_shell/workflows/$workflowId',
)({
  component: WorkflowDetail,
})

function WorkflowDetail() {
  const { projectId, workflowId } = Route.useParams()
  const { t } = useI18n()

  return (
    <>
      <PageHeader
        crumbs={[
          {
            label: t('Workflows'),
            link: { to: '/p/$projectId/workflows', params: { projectId } },
          },
          { label: workflowId },
        ]}
      />
      <PageBody>
        <PageTitle
          title={`${workflowId}`}
          description={t(
            'Definition, dispatch inputs and run history for this workflow.',
          )}
        />
        <EmptyState
          icon={WorkflowIcon}
          title={t('Workflow definition')}
          description={t(
            'The YAML source, its workflow_dispatch inputs and a manual trigger will live here.',
          )}
        />
      </PageBody>
    </>
  )
}
