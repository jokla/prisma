// Date formatting mirrors scripts/resolve-profile.js so the website and CV
// render dates the same way.
const MONTHS = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

export function formatDate(d: string | number | Date | null | undefined): string {
  if (d == null || d === '') return 'Present';
  if (d === 'present') return 'Present';

  if (d instanceof Date) {
    return `${d.getUTCDate()} ${MONTHS[d.getUTCMonth()]} ${d.getUTCFullYear()}`;
  }

  const s = String(d).trim();

  const yearToPresent = /^(\d{4})-present$/i.exec(s);
  if (yearToPresent) {
    return `${yearToPresent[1]} - Present`;
  }

  const isoDate = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
  if (isoDate) {
    return `${Number.parseInt(isoDate[3], 10)} ${MONTHS[Number.parseInt(isoDate[2], 10) - 1]} ${isoDate[1]}`;
  }

  const isoMonth = /^(\d{4})-(\d{2})$/.exec(s);
  if (isoMonth) {
    return `${MONTHS[Number.parseInt(isoMonth[2], 10) - 1]} ${isoMonth[1]}`;
  }

  if (/^\d{4}$/.test(s)) return s;

  return s;
}

export function formatRange(start: string | number | Date | undefined, end: string | number | Date | undefined): string {
  const s = start == null ? '' : formatDate(start);
  const e = end == null ? '' : formatDate(end);
  if (!s && !e) return '';
  if (!e || s === e) return s;
  return `${s} - ${e}`;
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
