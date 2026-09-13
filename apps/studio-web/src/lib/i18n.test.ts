import { describe, expect, it } from 'vitest'

import { translate } from './i18n'

describe('translate', () => {
  it('returns Chinese translations', () => {
    expect(translate('zh-CN', 'Projects')).toBe('项目')
  })

  it('interpolates translated values', () => {
    expect(translate('zh-CN', 'Back to {name}', { name: 'Demo' })).toBe(
      '返回 Demo',
    )
  })

  it('returns Japanese translations', () => {
    expect(translate('ja', 'Projects')).toBe('プロジェクト')
    expect(translate('ja', 'Build')).toBe('ビルド')
  })

  it('returns Korean translations', () => {
    expect(translate('ko', 'Projects')).toBe('프로젝트')
    expect(translate('ko', 'Stores')).toBe('앱 스토어')
  })

  it('uses the source text when a translation is unavailable', () => {
    expect(translate('zh-CN', 'User-provided content')).toBe(
      'User-provided content',
    )
    expect(translate('en', 'Projects')).toBe('Projects')
    expect(translate('ja', 'User-provided content')).toBe(
      'User-provided content',
    )
    expect(translate('ko', 'User-provided content')).toBe(
      'User-provided content',
    )
  })
})
