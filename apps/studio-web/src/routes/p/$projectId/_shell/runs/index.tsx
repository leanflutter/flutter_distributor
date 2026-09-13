import { Link, createFileRoute } from '@tanstack/react-router'

import { PageBody, PageTitle } from '#/components/page-body'
import { PageHeader } from '#/components/page-header'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/runs/')({
  component: Runs,
})

/**
 * One timeline for every kind of execution. `build`, `package`, `publish` and
 * `workflow run` all land here rather than in separate per-stage histories.
 */
const runs = [
  {
    id: '1042',
    kind: 'workflow',
    label: 'Release',
    target: 'ios · ipa',
    status: 'Succeeded',
    when: '12m ago',
  },
  {
    id: '1041',
    kind: 'package',
    label: 'Package',
    target: 'android · aab',
    status: 'Succeeded',
    when: '1h ago',
  },
  {
    id: '1040',
    kind: 'publish',
    label: 'Publish',
    target: 'firebase',
    status: 'Failed',
    when: '3h ago',
  },
]

const kinds = ['All', 'Build', 'Package', 'Publish', 'Workflow']

function Runs() {
  const { projectId } = Route.useParams()
  const { t } = useI18n()

  return (
    <>
      <PageHeader crumbs={[{ label: t('Runs') }]} />
      <PageBody>
        <PageTitle
          title={t('Runs')}
          description={t(
            'Every build, package, publish and workflow execution, newest first.',
          )}
        />

        <div className="flex flex-wrap gap-2">
          {kinds.map((kind, index) => (
            <button
              key={kind}
              type="button"
              data-active={index === 0}
              className="rounded-full border px-3 py-1 text-xs font-medium text-muted-foreground transition-colors hover:bg-muted data-active:bg-secondary data-active:text-secondary-foreground"
            >
              {t(kind)}
            </button>
          ))}
        </div>

        <ul className="divide-y rounded-xl border bg-card">
          {runs.map((run) => (
            <li key={run.id}>
              <Link
                to="/p/$projectId/runs/$runId"
                params={{ projectId, runId: run.id }}
                className="flex items-center gap-4 p-4 transition-colors hover:bg-muted/40"
              >
                <div className="min-w-0 flex-1">
                  <p className="font-medium">
                    {t(run.label)}{' '}
                    <span className="font-normal text-muted-foreground">
                      #{run.id}
                    </span>
                  </p>
                  <p className="truncate text-sm text-muted-foreground">
                    {run.kind} · {run.target}
                  </p>
                </div>
                <span className="shrink-0 rounded-full border px-2.5 py-0.5 text-xs font-medium">
                  {t(run.status)}
                </span>
                <span className="hidden w-16 shrink-0 text-right text-xs text-muted-foreground sm:block">
                  {t(run.when)}
                </span>
              </Link>
            </li>
          ))}
        </ul>
      </PageBody>
    </>
  )
}
