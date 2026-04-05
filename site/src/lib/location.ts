const COUNTRY_CODES = new Map<string, string>([
    ['UK', 'GB'],
    ['United Kingdom', 'GB'],
    ['England', 'GB'],
    ['France', 'FR'],
    ['Italy', 'IT'],
    ['Netherlands', 'NL'],
    ['Germany', 'DE'],
    ['Switzerland', 'CH'],
    ['USA', 'US'],
    ['United States', 'US'],
]);

function toFlagEmoji(code: string): string {
    return code
        .toUpperCase()
        .split('')
        .map((char) => String.fromCodePoint(127397 + (char.codePointAt(0) ?? 0)))
        .join('');
}

export function getLocationFlag(location: string | undefined): string | undefined {
    if (!location) return undefined;

    const country = location.split(',').pop()?.trim();
    if (!country) return undefined;

    const code = COUNTRY_CODES.get(country);
    return code ? toFlagEmoji(code) : undefined;
}