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
      expect(doc.querySelector('a[href="./privacy.html"]')).not.toBeNull();
      expect(doc.querySelector('a[href="./delete-account.html"]')).not.toBeNull();
      for (const link of doc.querySelectorAll('a[href^="./"]')) {
        const href = link.getAttribute('href');
        expect(new URL(href, 'file:///preview/privacy.html').pathname).toMatch(/^\/preview\//);
        expect(new URL(href, 'https://example.com/privacy.html').origin).toBe(
          'https://example.com',
        );
      }
    });
  }
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
