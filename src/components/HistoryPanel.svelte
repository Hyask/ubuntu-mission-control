<script>
  import { onMount } from 'svelte'
  import { fetchArtefact, fetchArtefactVersions, fetchBuilds, fetchTestResults } from '../api/client.js'

  /** @type {{ product: import('../lib/processor.js').Product }} */
  let { product } = $props()

  let loading  = $state(true)
  let error    = $state(null)
  let days     = $state([])   // 30 entries, index 0 = oldest
  let rate     = $state(null) // { built, approved, total }

  onMount(async () => {
    try {
      // The /versions endpoint returns all historical daily builds for this
      // product, each with its own artefact_id (e.g. [{version:"20260411", artefact_id:12174}]).
      const rawVersions = await fetchArtefactVersions(product.id)

      // Build date → artefact_id map, keeping highest version string per day.
      const byDate = new Map()
      for (const v of rawVersions) {
        const base = (v.version ?? '').slice(0, 8)
        if (!/^\d{8}$/.test(base)) continue
        const key = `${base.slice(0, 4)}-${base.slice(4, 6)}-${base.slice(6, 8)}`
        const prev = byDate.get(key)
        if (!prev || v.version > prev.version) byDate.set(key, v.artefact_id)
      }

      // Ensure today's artifact (product.id) is always included — the API may
      // omit the latest version from the /versions list.
      const productBase = (product.version ?? '').slice(0, 8)
      if (/^\d{8}$/.test(productBase)) {
        const todayKey = `${productBase.slice(0, 4)}-${productBase.slice(4, 6)}-${productBase.slice(6, 8)}`
        if (!byDate.has(todayKey)) byDate.set(todayKey, product.id)
      }

      // Build the 30-day window (oldest → newest, today is index 29)
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const dayData = Array.from({ length: 30 }, (_, i) => {
        const d = new Date(today)
        d.setDate(d.getDate() - (29 - i))
        const key = d.toISOString().slice(0, 10)
        return { date: key, artefactId: byDate.get(key) ?? null, artefact: null, tests: null }
      })

      // For every day that had a build, fetch artefact status + executions in parallel.
      await Promise.all(
        dayData.map(async day => {
          if (!day.artefactId) return
          const [artefact, builds] = await Promise.all([
            fetchArtefact(day.artefactId),
            fetchBuilds(day.artefactId).catch(() => []),
          ])
          day.artefact = artefact
          const execs = builds
            .flatMap(b => b.test_executions ?? [])
            .filter(te => te.test_plan === 'Manual Testing')

          // Phase 2: execution-level status counts (coarse, matches processor.js)
          let passed     = execs.filter(e => e.status === 'PASSED').length
          let failed     = execs.filter(e => ['FAILED', 'ENDED_PREMATURELY'].includes(e.status)).length
          let inProgress = execs.filter(e => e.status === 'IN_PROGRESS').length
          let notStarted = execs.filter(e => ['NOT_STARTED', 'NOT_TESTED'].includes(e.status)).length

          // Phase 3: fetch individual test results and overwrite with real counts.
          // Mirrors processor.js enrichWithBugs — execution status stays IN_PROGRESS
          // even after results are submitted, so per-result tallying is the source of truth.
          let resultPassed = 0
          let resultFailed = 0
          const execsWithResults = new Set()
          await Promise.all(
            execs.map(async exec => {
              const results = await fetchTestResults(exec.id).catch(() => [])
              if (results.length > 0) {
                execsWithResults.add(exec.id)
                for (const r of results) {
                  if (r.status === 'PASSED')      resultPassed++
                  else if (r.status === 'FAILED') resultFailed++
                }
              }
            }),
          )
          if (resultPassed + resultFailed > 0) {
            passed     = resultPassed
            failed     = resultFailed
            inProgress = Math.max(0, inProgress - execsWithResults.size)
          }

          day.tests = { passed, failed, inProgress, notStarted }
        }),
      )

      days = dayData
      const built    = dayData.filter(d => d.artefact).length
      const approved = dayData.filter(d => d.artefact?.status === 'APPROVED').length
      rate = { built, approved, total: 30 }
    } catch (e) {
      error = e.message
    } finally {
      loading = false
    }
  })

  function dayLabel(dateStr) {
    const [y, m, d] = dateStr.split('-').map(Number)
    return new Date(y, m - 1, d).toLocaleDateString('en-GB', {
      month: 'short',
      day:   'numeric',
    })
  }

  function isToday(dateStr) {
    return dateStr === new Date().toISOString().slice(0, 10)
  }

  // Block is green when built, red when no build that day.
  function statusClass(day) {
    return day.artefact ? 'built' : 'miss'
  }

  // Approval overlay shown on built blocks only.
  function approvalMark(day) {
    if (!day.artefact)                               return { mark: '', cls: '' }
    if (day.artefact.status === 'APPROVED')          return { mark: '✓', cls: 'mark-ok' }
    if (day.artefact.status === 'MARKED_AS_FAILED')  return { mark: '✗', cls: 'mark-fail' }
    return { mark: '', cls: '' }
  }

  function testLine(tests) {
    if (!tests) return null
    const parts = []
    if (tests.passed)     parts.push(`${tests.passed}✓`)
    if (tests.failed)     parts.push(`${tests.failed}✗`)
    if (tests.inProgress) parts.push(`${tests.inProgress}…`)
    return parts.length ? parts.join(' ') : null
  }

  // Rate bar width — build rate (days with a build / 30)
  let ratePct = $derived(
    rate ? Math.round((rate.built / rate.total) * 100) : 0,
  )
  let rateColor = $derived(
    ratePct >= 70 ? '#4caf50'
    : ratePct >= 40 ? '#ff9800'
    : '#e53935',
  )
</script>

<div class="history-panel">
  <!-- ── Summary header ──────────────────────────────────────────── -->
  {#if !loading && !error && rate}
    <div class="summary">
      <div class="summary-left">
        <span class="summary-title">30-day build history</span>
        <span class="summary-sub">{rate.built} of {rate.total} days built · {rate.approved} approved</span>
      </div>
      <div class="rate-wrap">
        <span class="rate-label" style="color: {rateColor}">{ratePct}%</span>
        <div class="rate-track">
          <div class="rate-fill" style="width: {ratePct}%; background: {rateColor}"></div>
        </div>
        <span class="rate-desc">build rate</span>
      </div>
    </div>
  {/if}

  <!-- ── State messages ──────────────────────────────────────────── -->
  {#if loading}
    <div class="hist-state">Loading 30-day history…</div>
  {:else if error}
    <div class="hist-state err">Error: {error}</div>
  {:else if days.every(d => !d.artefact)}
    <div class="hist-state">No historical data found for this product.</div>
  {:else}
    <!-- ── Day columns ──────────────────────────────────────────────── -->
    <div class="day-grid">
      {#each days as day}
        {@const sc             = statusClass(day)}
        {@const { mark, cls } = approvalMark(day)}
        {@const tl             = testLine(day.tests)}
        <div class="day-col" class:today={isToday(day.date)}>
          <!-- Test metrics -->
          <div class="test-line" class:has-data={!!tl}>
            {#if tl}
              {#each tl.split(' ') as chunk}
                <span class="tl-chip"
                      class:tl-pass={chunk.endsWith('✓')}
                      class:tl-fail={chunk.endsWith('✗')}
                      class:tl-prog={chunk.endsWith('…')}
                >{chunk}</span>
              {/each}
            {:else if day.artefact}
              <span class="tl-none">—</span>
            {/if}
          </div>

          <!-- Status block -->
          <div class="day-block {sc}" title="{day.date}{day.artefact ? ' · ' + (day.artefact.status ?? 'UNDECIDED') : ' · no build'}">
            <span class="day-mark {cls}">{mark}</span>
          </div>

          <!-- Date label -->
          <div class="day-label" class:today-label={isToday(day.date)}>
            {dayLabel(day.date)}
          </div>
        </div>
      {/each}
    </div>

    <!-- Legend -->
    <div class="legend">
      <span class="leg-item"><span class="leg-swatch built"></span>Built</span>
      <span class="leg-item"><span class="leg-swatch miss"></span>No build</span>
      <span class="leg-item"><span class="mark-ok leg-mark">✓</span>Approved</span>
      <span class="leg-item"><span class="mark-fail leg-mark">✗</span>Not approved</span>
    </div>
  {/if}
</div>

<style>
  .history-panel {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: 1rem 1.54rem 1.25rem;
  }

  /* ── Summary ──────────────────────────────────────────────────── */
  .summary {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1.5rem;
    flex-wrap: wrap;
  }

  .summary-left {
    display: flex;
    flex-direction: column;
    gap: 0.2rem;
  }

  .summary-title {
    font-size: 1rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--text-dim);
  }

  .summary-sub {
    font-size: 1rem;
    color: var(--text-muted);
  }

  .rate-wrap {
    display: flex;
    align-items: center;
    gap: 0.55rem;
  }

  .rate-label {
    font-size: 1.35rem;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
    min-width: 3.2rem;
    text-align: right;
  }

  .rate-track {
    width: 110px;
    height: 7px;
    background: var(--bg-raised);
    border-radius: 4px;
    overflow: hidden;
  }

  .rate-fill {
    height: 100%;
    border-radius: 4px;
    transition: width 0.4s ease;
  }

  .rate-desc {
    font-size: 0.88rem;
    color: var(--text-muted);
    white-space: nowrap;
  }

  /* ── State message ────────────────────────────────────────────── */
  .hist-state {
    font-size: 1.06rem;
    color: var(--text-dim);
    padding: 1.25rem 0;
    text-align: center;
  }
  .hist-state.err { color: var(--red); }

  /* ── Day grid ─────────────────────────────────────────────────── */
  .day-grid {
    display: flex;
    gap: 3px;
  }

  .day-col {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3px;
    flex-shrink: 0;
    width: 32px;
  }

  .day-col.today .day-block {
    outline: 2px solid var(--accent);
    outline-offset: 1px;
  }

  /* Test metrics line */
  .test-line {
    display: flex;
    gap: 1px;
    align-items: center;
    justify-content: center;
    height: 14px;
    font-size: 0.58rem;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
  }

  .tl-chip {
    padding: 0 1px;
    border-radius: 2px;
    line-height: 1.3;
  }
  .tl-pass { color: #5ddb5d; }
  .tl-fail { color: var(--red); }
  .tl-prog { color: var(--blue); }
  .tl-none { color: var(--text-dim); font-size: 0.6rem; }

  /* Status block */
  .day-block {
    width: 32px;
    height: 38px;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.95rem;
    font-weight: 700;
    transition: transform 0.1s;
    cursor: default;
  }
  .day-block:hover { transform: scaleY(1.06); }

  /* Green = built, grey = no build data */
  .day-block.built { background: #1a4d1a; }
  .day-block.miss  { background: var(--bg-raised); border: 1px solid var(--border-mid); }

  .day-mark { line-height: 1; font-size: 0.9rem; }
  .mark-ok   { color: #5ddb5d; }
  .mark-fail { color: var(--red); }

  /* Date label */
  .day-label {
    font-size: 0.55rem;
    color: var(--text-muted);
    text-align: center;
    white-space: nowrap;
    line-height: 1.2;
  }

  .today-label {
    color: var(--accent);
    font-weight: 700;
  }

  /* ── Legend ───────────────────────────────────────────────────── */
  .legend {
    display: flex;
    gap: 1.25rem;
    flex-wrap: wrap;
    padding-top: 0.25rem;
  }

  .leg-item {
    display: flex;
    align-items: center;
    gap: 0.35rem;
    font-size: 0.82rem;
    color: var(--text-muted);
  }

  .leg-swatch {
    width: 12px;
    height: 12px;
    border-radius: 3px;
    flex-shrink: 0;
  }
  .leg-swatch.built { background: #1a4d1a; }
  .leg-swatch.miss  { background: var(--bg-raised); border: 1px solid var(--border-mid); }
  .leg-mark { font-size: 0.85rem; font-weight: 700; }
</style>
