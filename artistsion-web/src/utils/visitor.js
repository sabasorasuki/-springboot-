const VISITOR_ID_KEY = 'artistsion_visitor_id'
const SESSION_ID_KEY = 'artistsion_session_id'

function canUseStorage(storage) {
  try {
    return typeof window !== 'undefined' && !!storage
  } catch (e) {
    return false
  }
}

function createId(prefix) {
  return `${prefix}_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 10)}`
}

function getOrCreateId(storage, key, prefix) {
  if (!canUseStorage(storage)) {
    return createId(prefix)
  }
  let value = storage.getItem(key)
  if (!value) {
    value = createId(prefix)
    storage.setItem(key, value)
  }
  return value
}

export function getVisitorId() {
  const storage = typeof window !== 'undefined' ? window.localStorage : null
  return getOrCreateId(storage, VISITOR_ID_KEY, 'visitor')
}

export function getSessionId() {
  const storage = typeof window !== 'undefined' ? window.sessionStorage : null
  return getOrCreateId(storage, SESSION_ID_KEY, 'session')
}

export function createClientEventId(prefix = 'evt') {
  return createId(prefix)
}
