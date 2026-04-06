<script>
  /** @type {{ label: string, value: string|number, sub: string, pct: number|null, color?: string }} */
  let { label, value, sub, pct, color = 'neutral' } = $props()
</script>

<div class="kpi" class:green={color === 'green'} class:amber={color === 'amber'} class:red={color === 'red'} class:blue={color === 'blue'}>
  <div class="label">{label}</div>
  <div class="value">{value}</div>
  <div class="sub">{sub}</div>
  <div class="bar">
    <div class="bar-fill" style="width: {pct ?? 0}%"></div>
  </div>
</div>

<style>
  .kpi {
    padding: 1rem 1.5rem;
    border-right: 1px solid var(--border);
    position: relative;
    overflow: hidden;
  }

  .label {
    font-size: 0.6875rem;
    font-weight: 700;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--text-dim);
    margin-bottom: 0.4rem;
  }

  .value {
    font-size: 3rem;
    font-weight: 700;
    line-height: 1;
    font-variant-numeric: tabular-nums;
    color: var(--text-muted);
    transition: color 0.3s;
  }

  .sub {
    font-size: 0.875rem;
    color: var(--text-muted);
    margin-top: 0.3rem;
    font-variant-numeric: tabular-nums;
  }

  .bar {
    margin-top: 0.5rem;
    height: 4px;
    background: var(--bg-raised);
    border-radius: 2px;
    overflow: hidden;
  }

  .bar-fill {
    height: 100%;
    border-radius: 2px;
    background: var(--text-dim);
    transition: width 0.6s ease, background 0.3s;
  }

  /* Color variants */
  .green .value  { color: var(--green); }
  .green .bar-fill { background: var(--green); }

  .amber .value  { color: var(--amber); }
  .amber .bar-fill { background: var(--amber); }

  .red .value    { color: var(--red); }
  .red .bar-fill { background: var(--red); }

  .blue .value   { color: var(--blue); }
  .blue .bar-fill { background: var(--blue); }
</style>
