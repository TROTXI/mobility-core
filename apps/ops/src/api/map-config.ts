/** GET /flags returns Bootstrap directly, without the v1 data envelope. */
export function mapStyleFromBootstrap(body: unknown, appearance: 'dark' | 'light'): string | null {
  if (!body || typeof body !== 'object' || !('mapTiles' in body)) return null;
  const tiles = body.mapTiles;
  if (!tiles || typeof tiles !== 'object') return null;
  const darkStyle = 'darkStyleUrl' in tiles ? tiles.darkStyleUrl : null;
  const lightStyle = 'styleUrl' in tiles ? tiles.styleUrl : null;
  const style = appearance === 'dark' && darkStyle ? darkStyle : lightStyle;
  return typeof style === 'string' && style.length > 0 ? style : null;
}
