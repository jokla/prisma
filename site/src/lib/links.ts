// Mirrors the CV's `linkify-text` in cv/template.typ: every occurrence of a
// `highlight_links` label inside a highlight becomes a link.

export interface InlineLink {
  label: string;
  url: string;
}

export interface TextSegment {
  text: string;
  url?: string;
}

export function linkifyText(value: string, links: InlineLink[] = []): TextSegment[] {
  const [link, ...rest] = links;
  if (!link) return [{ text: value }];
  if (!link.label || !value.includes(link.label)) return linkifyText(value, rest);

  return value.split(link.label).flatMap((part, index, parts) => [
    ...(part ? linkifyText(part, rest) : []),
    ...(index < parts.length - 1 ? [{ text: link.label, url: link.url }] : []),
  ]);
}
