const PROFILE_MODE_ARTIST = 'artist'
const PROFILE_MODE_CLIENT = 'client'

const centerProfileConfig = {
  self: {
    artist: {
      defaultTab: 'submissions',
      primaryTabs: [
        { key: 'submissions', label: '投稿' },
        { key: 'favorites', label: '收藏' },
        { key: 'orders', label: '订单' }
      ],
      secondaryTabs: {
        submissions: [
          { key: 'works', label: '作品' },
          { key: 'showcase', label: '橱窗' }
        ],
        favorites: [
          { key: 'projects', label: '企划' }
        ]
      }
    },
    client: {
      defaultTab: 'projects',
      primaryTabs: [
        { key: 'projects', label: '企划' },
        { key: 'favorites', label: '收藏' },
        { key: 'cart', label: '购物车' },
        { key: 'orders', label: '订单' }
      ],
      secondaryTabs: {
        favorites: [
          { key: 'works', label: '作品' },
          { key: 'showcase', label: '橱窗' }
        ]
      }
    }
  },
  other: {
    artist: {
      defaultTab: 'featuredWorks',
      primaryTabs: [
        { key: 'featuredWorks', label: '精选作品' },
        { key: 'showcase', label: '橱窗' }
      ],
      secondaryTabs: {}
    },
    client: {
      defaultTab: 'projects',
      primaryTabs: [
        { key: 'projects', label: '企划' }
      ],
      secondaryTabs: {}
    }
  }
}

const dropdownItemsByMode = {
  artist: [
    { command: 'center', label: '个人中心', icon: 'el-icon-user' },
    { command: 'submissions', label: '投稿', icon: 'el-icon-edit' },
    { command: 'favorites', label: '收藏', icon: 'el-icon-star-off' },
    { command: 'orders', label: '订单', icon: 'el-icon-document' }
  ],
  client: [
    { command: 'center', label: '个人中心', icon: 'el-icon-user' },
    { command: 'projects', label: '企划', icon: 'el-icon-s-flag' },
    { command: 'favorites', label: '收藏', icon: 'el-icon-star-off' },
    { command: 'cart', label: '购物车', icon: 'el-icon-shopping-cart-2' },
    { command: 'orders', label: '订单', icon: 'el-icon-document' }
  ]
}

export function normalizeProfileViewMode(mode, fallback = PROFILE_MODE_CLIENT) {
  if (mode === PROFILE_MODE_ARTIST || mode === PROFILE_MODE_CLIENT) {
    return mode
  }
  return fallback
}

export function getPersistedDisplayMode() {
  if (typeof window === 'undefined' || !window.localStorage) {
    return PROFILE_MODE_CLIENT
  }
  return normalizeProfileViewMode(window.localStorage.getItem('artistsion_display_mode'))
}

export function getCenterProfileConfig(isSelf, viewMode) {
  const scope = isSelf ? 'self' : 'other'
  const fallbackMode = isSelf ? PROFILE_MODE_CLIENT : PROFILE_MODE_ARTIST
  const resolvedMode = normalizeProfileViewMode(viewMode, fallbackMode)
  return centerProfileConfig[scope][resolvedMode]
}

export function resolveCenterProfileState({ isSelf, viewMode, tab, sub }) {
  const fallbackMode = isSelf ? PROFILE_MODE_CLIENT : PROFILE_MODE_ARTIST
  const resolvedMode = normalizeProfileViewMode(viewMode, fallbackMode)
  const config = getCenterProfileConfig(isSelf, resolvedMode)
  const primaryTabs = config.primaryTabs.map(item => ({ ...item }))
  const resolvedTab = primaryTabs.some(item => item.key === tab) ? tab : config.defaultTab
  const secondaryTabs = (config.secondaryTabs[resolvedTab] || []).map(item => ({ ...item }))
  const resolvedSub = secondaryTabs.length
    ? (secondaryTabs.some(item => item.key === sub) ? sub : secondaryTabs[0].key)
    : ''

  return {
    viewMode: resolvedMode,
    tab: resolvedTab,
    sub: resolvedSub,
    primaryTabs,
    secondaryTabs
  }
}

export function buildCenterProfileRoute({ isSelf = true, userId = null, viewMode, tab, sub }) {
  const state = resolveCenterProfileState({
    isSelf,
    viewMode,
    tab,
    sub
  })
  const path = isSelf ? '/center/profile' : `/center/profile/${userId}`
  const query = {
    view: state.viewMode,
    tab: state.tab
  }

  if (state.sub) {
    query.sub = state.sub
  }

  return {
    path,
    query
  }
}

export function getCenterDropdownItems(displayMode) {
  const mode = normalizeProfileViewMode(displayMode)
  return dropdownItemsByMode[mode].map(item => ({ ...item }))
}

export function getCenterDropdownRoute(command, displayMode) {
  const mode = normalizeProfileViewMode(displayMode)

  switch (command) {
    case 'center':
      return buildCenterProfileRoute({ isSelf: true, viewMode: mode })
    case 'submissions':
      return buildCenterProfileRoute({ isSelf: true, viewMode: PROFILE_MODE_ARTIST, tab: 'submissions', sub: 'works' })
    case 'projects':
      return buildCenterProfileRoute({ isSelf: true, viewMode: PROFILE_MODE_CLIENT, tab: 'projects' })
    case 'favorites':
      return buildCenterProfileRoute({
        isSelf: true,
        viewMode: mode,
        tab: 'favorites',
        sub: mode === PROFILE_MODE_ARTIST ? 'projects' : 'works'
      })
    case 'cart':
      return buildCenterProfileRoute({ isSelf: true, viewMode: PROFILE_MODE_CLIENT, tab: 'cart' })
    case 'orders':
      return buildCenterProfileRoute({ isSelf: true, viewMode: mode, tab: 'orders' })
    default:
      return buildCenterProfileRoute({ isSelf: true, viewMode: mode })
  }
}
