/**
 * Centralized OSS URL helpers.
 *
 * Every view that builds upload-action URLs or download URLs should import
 * from here instead of hard-coding `http://localhost:9999`.
 */

const BASE = (process.env.VUE_APP_BASE_API || '').replace(/\/+$/, '')
const ABSOLUTE_URL_RE = /^(https?:)?\/\//i
const INLINE_URL_RE = /^(data:|blob:)/i
const DOWNLOAD_PATH_RE = /^\/?oss\/file\/download\?/i
const INVALID_IMAGE_MARKERS = ['无法创建存储目录', '保存失败', '文件为空', '[object Object]']
const INVALID_IMAGE_VALUES = ['null', 'undefined', 'nan']

/** Full download URL for a given file name */
export function ossDownloadUrl(name) {
  return `${BASE}/oss/file/download?name=${name}`
}

/** Upload action URL for a given module (e.g. "photo", "lunbo") */
export function ossUploadAction(module) {
  return `${BASE}/oss/file/upload?module=${module}`
}

/** WangEditor image upload endpoint */
export const ossUploadImgServer = `${BASE}/oss/file/uploadImg`

/** Raw base (for the rare case where the caller needs it) */
export const ossBase = BASE

export function extractUploadFileName(response) {
  if (!response || response.code !== 20000 || typeof response.data !== 'string') {
    return ''
  }
  return response.data.trim()
}

export function normalizeImageUrl(value) {
  if (value === null || value === undefined) {
    return ''
  }

  const raw = String(value).trim()
  if (!raw) {
    return ''
  }

  if (INVALID_IMAGE_MARKERS.some(marker => raw.includes(marker))) {
    return ''
  }

  const lowered = raw.toLowerCase()
  if (INVALID_IMAGE_VALUES.includes(lowered)) {
    return ''
  }

  if (INLINE_URL_RE.test(raw) || ABSOLUTE_URL_RE.test(raw)) {
    return raw
  }

  if (DOWNLOAD_PATH_RE.test(raw)) {
    return raw.startsWith('/') ? `${BASE}${raw}` : `${BASE}/${raw}`
  }

  if (raw.startsWith('/')) {
    return `${BASE}${raw}`
  }

  if (raw.includes('/')) {
    return `${BASE}/${raw.replace(/^\/+/, '')}`
  }

  return ossDownloadUrl(raw)
}
