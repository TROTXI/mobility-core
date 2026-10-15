import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('public legal and account-information pages', () => {
  for (const name of ['terms', 'privacy', 'delete-account']) {
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
      expect(doc.querySelector('a[href="./terms"]')).not.toBeNull();
      for (const link of doc.querySelectorAll('a[href^="./"]')) {
        const href = link.getAttribute('href');
        for (const path of [
          '/privacy',
          '/delete-account',
          '/terms',
          '/privacy.html',
          '/delete-account.html',
          '/terms.html',
        ]) {
          const target = new URL(href, `https://example.com${path}`);
          expect(target.origin).toBe('https://example.com');
          expect(['/terms', '/privacy', '/delete-account']).toContain(target.pathname);
        }
      }
    });
  }
  it('routes clean URLs to static pages before the Ops fallback and shares them with both apps', () => {
    const blueprint = readFileSync('../../render.yaml', 'utf8');
    expect(blueprint).toMatch(
      /routes:\s+- type: rewrite\s+source: \/terms\s+destination: \/terms\.html\s+- type: rewrite\s+source: \/privacy\s+destination: \/privacy\.html\s+- type: rewrite\s+source: \/delete-account\s+destination: \/delete-account\.html\s+- type: rewrite\s+source: \/\*\s+destination: \/index\.html/,
    );
    // The apps build these clean paths on PUBLIC_SITE_URL; staging points
    // that at this site, and production supplies its own.
    const sharedLinks = readFileSync('../trotxi_client/lib/public_information.dart', 'utf8');
    expect(sharedLinks).toContain("_page('terms')");
    expect(sharedLinks).toContain("_page('privacy')");
    expect(sharedLinks).toContain("_page('delete-account')");
    expect(sharedLinks).not.toContain('.html');
    const staging = JSON.parse(readFileSync('../trotxi_commuter/config/staging.json', 'utf8'));
    expect(staging.PUBLIC_SITE_URL).toBe('https://trotxi-ops-staging.onrender.com');
  });
  it('publishes the same version the app submits and keeps privacy separate', () => {
    const html = readFileSync('public/terms.html', 'utf8');
    const sharedLinks = readFileSync('../trotxi_client/lib/public_information.dart', 'utf8');
    const apiTerms = readFileSync('../../services/api-next/src/auth/terms.ts', 'utf8');
    const contract = readFileSync('../../docs/design/contracts/target-contract.mjs', 'utf8');
    const compactContract = contract.replace(/\s+/g, '');
    expect(html).toContain('Version 2026-10-14');
    expect(sharedLinks).toContain("currentTermsVersion = '2026-10-14'");
    expect(apiTerms).toContain("currentCommuterTermsVersion = '2026-10-14'");
    expect(
      compactContract.match(/termsVersion:z\.string\(\)\.regex\(\/\^2026-10-14\$\/\)/g),
    ).toHaveLength(4);
    expect(html).toContain('separate from these Terms');
    expect(html).toContain('weekly, biweekly or monthly');
    expect(html).not.toMatch(/annual plan/i);
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
