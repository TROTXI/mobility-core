import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('public privacy and deletion pages', () => {
  for (const name of ['privacy', 'delete-account']) {
    it(`${name} works without signing in or running JavaScript`, () => {
      const html = readFileSync(`public/${name}.html`, 'utf8');
      const doc = new DOMParser().parseFromString(html, 'text/html');
      expect(doc.querySelectorAll('h1')).toHaveLength(1);
      expect(doc.querySelector('main#content')).not.toBeNull();
      expect(doc.querySelector('.brand img')?.getAttribute('alt')).toBe('Trotxi');
      expect(doc.querySelector('.brand img')?.getAttribute('src')).toBe(
        './trotxi-wordmark-light.png',
      );
      expect(doc.querySelector('.brand source')?.getAttribute('srcset')).toBe(
        './trotxi-wordmark-dark.png',
      );
      for (const variant of ['light', 'dark']) {
        expect(
          readFileSync(`public/trotxi-wordmark-${variant}.png`).equals(
            readFileSync(`../trotxi_driver/assets/brand/trotxi-wordmark-${variant}.png`),
          ),
        ).toBe(true);
      }
      expect(doc.querySelector('a.skip')?.getAttribute('href')).toBe('#content');
      expect(doc.querySelectorAll('script, iframe, form')).toHaveLength(0);
      expect(doc.querySelector('link[rel="stylesheet"]')?.getAttribute('href')).toBe('./legal.css');
      expect(html).not.toContain('minokuda55@gmail.com');
      expect(doc.querySelector('a[href="./privacy"]')).not.toBeNull();
      expect(doc.querySelector('a[href="./delete-account"]')).not.toBeNull();
      for (const link of doc.querySelectorAll('a[href^="./"]')) {
        const href = link.getAttribute('href');
        for (const path of [
          '/privacy',
          '/delete-account',
          '/privacy.html',
          '/delete-account.html',
        ]) {
          const target = new URL(href, `https://example.com${path}`);
          expect(target.origin).toBe('https://example.com');
          expect(['/privacy', '/delete-account']).toContain(target.pathname);
        }
      }
    });
  }
  it('routes clean URLs to static pages before the Ops fallback and shares them with both apps', () => {
    const blueprint = readFileSync('../../render.yaml', 'utf8');
    expect(blueprint).toMatch(
      /routes:\s+- type: rewrite\s+source: \/privacy\s+destination: \/privacy\.html\s+- type: rewrite\s+source: \/delete-account\s+destination: \/delete-account\.html\s+- type: rewrite\s+source: \/\*\s+destination: \/index\.html/,
    );
    const sharedLinks = readFileSync('../trotxi_client/lib/public_information.dart', 'utf8');
    expect(sharedLinks).toContain("'https://trotxi-ops-staging.onrender.com/privacy'");
    expect(sharedLinks).toContain("'https://trotxi-ops-staging.onrender.com/delete-account'");
    expect(sharedLinks).not.toContain('.html');
  });
  it('does not promise automatic deletion or universal retention', () => {
    const html = readFileSync('public/delete-account.html', 'utf8');
    expect(html).toContain('we verify identity first');
    expect(html).toContain('Do not send your PIN');
    expect(html).toContain('30 days');
    expect(html).toContain('active hold');
    const doc = new DOMParser().parseFromString(html, 'text/html');
    expect(doc.querySelector('a[href^="mailto:privacy@trotxi.com"]')).not.toBeNull();
    expect(html).not.toContain('awaiting owner confirmation');
  });
});
