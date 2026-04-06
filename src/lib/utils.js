/** Returns today as YYYYMMDD — matches the artifact version date format. */
export function todayStr() {
  return new Date().toISOString().slice(0, 10).replace(/-/g, '')
}

/** Formats a Date as HH:MM:SS */
export function fmtTime(d) {
  return d.toLocaleTimeString('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })
}

/** Formats a Date as YYYY-MM-DD */
export function fmtDate(d) {
  return d.toISOString().slice(0, 10)
}

/**
 * Derives a human-readable type label from an artifact filename.
 * e.g. "resolute-live-server-amd64.iso" → "live-server"
 */
export function artifactTypeLabel(name, release) {
  let n = name || ''
  if (release && n.startsWith(release + '-')) n = n.slice(release.length + 1)
  // Strip trailing arch + extension(s)
  n = n.replace(
    /[-_]?(amd64|arm64(\+[\w]+)?|armhf|ppc64el|riscv64|s390x)([-+].+)?(\.\w+)+$/,
    '',
  )
  return n || name
}

/**
 * Returns a color class name ('green' | 'amber' | 'red' | 'neutral')
 * based on a 0-100 percentage value.
 */
export function pctColor(pct) {
  if (pct === null || pct === undefined) return 'neutral'
  if (pct >= 80) return 'green'
  if (pct >= 50) return 'amber'
  return 'red'
}

/** Formats seconds as M:SS */
export function fmtCountdown(secs) {
  const m = Math.floor(secs / 60)
  const s = secs % 60
  return `${m}:${String(s).padStart(2, '0')}`
}
