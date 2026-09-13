import { createFileRoute } from '@tanstack/react-router'

import { PageBody, PageTitle } from '#/components/page-body'
import { TargetList } from '#/components/target-list'
import { publisherTargets } from '#/lib/targets'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/settings/publishers/')({
  component: Publishers,
})

function Publishers() {
  const { projectId } = Route.useParams()
  const { t } = useI18n()

  return (
    <>
      <PageBody>
        <PageTitle
          title={t('Publishers')}
          description={t(
            'Upload targets for finished artifacts. They have no listing and no review state, so they are configuration rather than something to check on.',
          )}
        />
        <TargetList
          targets={publisherTargets}
          detailLink={(target) => ({
            to: '/p/$projectId/settings/publishers/$publisherId',
            params: { projectId, publisherId: target.id },
          })}
        />
      </PageBody>
    </>
  )
}
