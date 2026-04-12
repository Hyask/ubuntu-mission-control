<script>
  import { onMount } from 'svelte'
  import RefreshControl from './RefreshControl.svelte'

  let {
    releases         = [],
    selectedIndex    = 0,
    clockStr         = '—',
    todayDisplay     = '',
    lastUpdated      = null,
    autoRefresh      = false,
    refreshInterval  = 120,
    countdown        = null,
    isLoading        = false,
    productCount     = null,
    onMilestoneChange   = () => {},
    onAutoRefreshToggle = () => {},
    onIntervalChange    = () => {},
    onManualRefresh     = () => {},
  } = $props()

  let selectedRelease = $derived(releases[selectedIndex])

  let isDark = $state(true)

  onMount(() => {
    isDark = localStorage.getItem('theme') !== 'light'
    document.documentElement.dataset.theme = isDark ? 'dark' : 'light'
  })

  function toggleTheme() {
    isDark = !isDark
    const theme = isDark ? 'dark' : 'light'
    document.documentElement.dataset.theme = theme
    localStorage.setItem('theme', theme)
  }
</script>

<header class="header">
  <!-- Logo + title -->
  <div class="logo">
    <img src="https://assets.ubuntu.com/v1/82818827-CoF_white.svg" alt="Ubuntu" />
    <span class="title">Ubuntu Mission Control</span>
  </div>

  <span class="sep">|</span>

  <!-- Release selector -->
  <div class="milestone">
    {#if releases.length > 1}
      <select
        value={selectedIndex}
        onchange={e => onMilestoneChange(Number(e.target.value))}
      >
        {#each releases as r, i}
          <option value={i}>{r.release.charAt(0).toUpperCase() + r.release.slice(1)}</option>
        {/each}
      </select>
    {:else if selectedRelease}
      <span class="release-name">
        {selectedRelease.release.charAt(0).toUpperCase() + selectedRelease.release.slice(1)}
      </span>
    {/if}
    {#if selectedRelease}
      <span class="milestone-meta">
        {productCount} builds · {todayDisplay}
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
    <button class="theme-toggle" onclick={toggleTheme} title="{isDark ? 'Switch to light mode' : 'Switch to dark mode'}">
      {isDark ? '☀' : '☾'}
    </button>
    <div class="clock">{clockStr}</div>
  </div>
</header>

<style>
  .header {
    flex-shrink: 0;
    display: flex;
    align-items: center;
    gap: 1.35rem;
    padding: 0 1.35rem;
    height: 60px;
    background: var(--bg-panel);
    border-bottom: 2px solid var(--accent);
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-shrink: 0;
  }

  .logo img { height: 30px; }

  .title {
    font-size: 1.08rem;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--accent);
  }

  .sep {
    color: var(--border-strong);
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
    border: 1px solid var(--border-mid);
    color: var(--text);
    padding: 0.2rem 0.55rem;
    border-radius: 3px;
    font-size: 0.96rem;
    font-weight: 700;
    font-family: inherit;
    cursor: pointer;
  }

  .release-name {
    font-size: 0.96rem;
    font-weight: 700;
    color: var(--text);
  }

  .milestone-meta {
    color: var(--text-muted);
    font-size: 0.88rem;
  }

  .right {
    margin-left: auto;
    display: flex;
    align-items: center;
    gap: 1.25rem;
  }

  .theme-toggle {
    background: none;
    border: 1px solid var(--border-strong);
    color: var(--text-muted);
    font-size: 1.1rem;
    cursor: pointer;
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    line-height: 1;
    transition: color 0.15s, border-color 0.15s;
  }
  .theme-toggle:hover {
    color: var(--text);
    border-color: var(--accent);
  }

  .clock {
    font-size: 1.32rem;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
    color: var(--text-normal);
    min-width: 6rem;
    text-align: right;
  }
</style>
