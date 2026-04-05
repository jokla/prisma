// Date formatting — mirrors scripts/resolve-profile.js so the website and CV
// render dates the same way.
const MONTHS = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

export function formatDate(d: string | number | null | undefined): string {
  if (!d || d === 'present') return 'Present';
  const s = String(d);
  const [year, month] = s.split('-');
  return month ? `${MONTHS[Number.parseInt(month, 10) - 1]} ${year}` : year;
}

export function formatRange(start: string | number | undefined, end: string | number | undefined): string {
  const s = start != null ? formatDate(start) : '';
  const e = end != null ? formatDate(end) : '';
  if (!s && !e) return '';
  if (!e || s === e) return s;
  return `${s} — ${e}`;
}

// Parse a YAML date string into a comparable number so we can sort newest-first.
// "present" sorts highest, then YYYY-MM, then YYYY.
export function dateKey(d: string | number | null | undefined): number {
  if (!d || d === 'present') return Number.POSITIVE_INFINITY;
  const s = String(d);
  const [year, month] = s.split('-');
  const y = Number.parseInt(year, 10);
  const m = month ? Number.parseInt(month, 10) : 1;
  return y * 100 + m;
}
