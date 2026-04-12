const API_BASE = '/api'

async function apiFetch(path) {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { 'X-CSRF-Token': '1' },
  })
  if (!res.ok) throw new Error(`HTTP ${res.status} — ${path}`)
  return res.json()
}

export const fetchArtefacts = (family = 'image') =>
  apiFetch(`/v1/artefacts?family=${family}`)

export const fetchArtefactVersions = artefactId =>
  apiFetch(`/v1/artefacts/${artefactId}/versions`)

export const fetchArtefact = artefactId =>
  apiFetch(`/v1/artefacts/${artefactId}`)

export const fetchBuilds = artefactId =>
  apiFetch(`/v1/artefacts/${artefactId}/builds`)

export const fetchTestResults = execId =>
  apiFetch(`/v1/test-executions/${execId}/test-results`)
