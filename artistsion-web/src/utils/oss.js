/**
 * Centralized OSS URL helpers.
 *
 * Every view that builds upload-action URLs or download URLs should import
 * from here instead of hard-coding `http://localhost:9999`.
 */

const BASE = (process.env.VUE_APP_BASE_API || '').replace(/\/+$/, '')

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
