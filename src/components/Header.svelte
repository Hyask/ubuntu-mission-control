<script>
  import RefreshControl from './RefreshControl.svelte'

  let {
    milestones       = [],
    selectedIndex    = 0,
    clockStr         = '—',
    todayDisplay     = '',
    lastUpdated      = null,
    autoRefresh      = false,
    refreshInterval  = 120,
    countdown        = null,
    isLoading        = false,
    onMilestoneChange   = () => {},
    onAutoRefreshToggle = () => {},
    onIntervalChange    = () => {},
    onManualRefresh     = () => {},
  } = $props()

  let selectedMs = $derived(milestones[selectedIndex])
</script>

<header class="header">
  <!-- Logo + title -->
  <div class="logo">
    <img src="https://assets.ubuntu.com/v1/82818827-CoF_white.svg" alt="Ubuntu" />
    <span class="title">Release Mission Control</span>
  </div>

  <span class="sep">|</span>

  <!-- Milestone selector -->
  <div class="milestone">
    <select
      value={selectedIndex}
      onchange={e => onMilestoneChange(Number(e.target.value))}
    >
      {#each milestones as ms, i}
        <option value={i}>
          {ms.release.charAt(0).toUpperCase() + ms.release.slice(1)}
          {#if ms.name} — {ms.name}{/if}
        </option>
      {/each}
    </select>
    {#if selectedMs}
      <span class="milestone-meta">
        {selectedMs.builds.length} builds · {todayDisplay}
      </span>
    {/if}
  </div>

  <!-- Right side -->
  <div class="right">
    <RefreshControl
      {autoRefresh}
      {refreshInterval}
      {countdown}
      {isLoading}
      {lastUpdated}
      onToggle={onAutoRefreshToggle}
      {onIntervalChange}
      {onManualRefresh}
    />
    <div class="clock">{clockStr}</div>
  </div>
</header>

<style>
  .header {
    flex-shrink: 0;
    display: flex;
    align-items: center;
    gap: 1.5rem;
    padding: 0 1.5rem;
    height: 56px;
    background: var(--bg-panel);
    border-bottom: 2px solid var(--accent);
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-shrink: 0;
  }

  .logo img { height: 28px; }

  .title {
    font-size: 1rem;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--accent);
  }

  .sep {
    color: #444;
    user-select: none;
    flex-shrink: 0;
  }

  .milestone {
    display: flex;
    align-items: center;
    gap: 0.6rem;
  }

  .milestone select {
    background: var(--bg-raised);
    border: 1px solid #333;
    color: var(--text);
    padding: 0.25rem 0.6rem;
    border-radius: 3px;
    font-size: 0.9rem;
    font-weight: 700;
    font-family: inherit;
    cursor: pointer;
  }

  .milestone-meta {
    color: var(--text-muted);
    font-size: 0.8125rem;
  }

  .right {
    margin-left: auto;
    display: flex;
    align-items: center;
    gap: 1.25rem;
  }

  .clock {
    font-size: 1.25rem;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
    color: #ccc;
    min-width: 6rem;
    text-align: right;
  }
</style>
