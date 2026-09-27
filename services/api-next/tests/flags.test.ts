import assert from 'node:assert/strict';
import test from 'node:test';
import { inRollout } from '../src/config/service.js';

// Fixed inputs, so every share below is exact and repeatable rather than a
// statistical hope: the same hash of the same ids gives the same answer.
const people = Array.from({ length: 100000 }, (_, i) => `person-${i}`);
const share = (key: string, percentage: number) =>
  people.filter((p) => inRollout(p, key, percentage)).length / people.length;

test('FLG-01 nothing below zero and everything at a hundred', () => {
  for (const p of people.slice(0, 500)) {
    assert.equal(inRollout(p, 'map.live', 0), false);
    assert.equal(inRollout(p, 'map.live', -5), false);
    assert.equal(inRollout(p, 'map.live', 100), true);
  }
});

test('FLG-02 a person gets the same answer on every launch', () => {
  for (const p of people.slice(0, 500))
    assert.equal(inRollout(p, 'map.live', 25), inRollout(p, 'map.live', 25));
});

test('FLG-03 a rollout reaches the share it says it does', () => {
  assert.ok(Math.abs(share('map.live', 25) - 0.25) < 0.005, `25% gave ${share('map.live', 25)}`);
  // The column holds two decimals. 12.5% must not round to 12 or 13.
  const half = share('map.live', 12.5);
  assert.ok(Math.abs(half - 0.125) < 0.003, `12.5% gave ${half}`);
});

test('FLG-04 each flag draws its own sample, not the same unlucky people', () => {
  const a = new Set(people.filter((p) => inRollout(p, 'map.live', 50)));
  const both = people.filter((p) => a.has(p) && inRollout(p, 'commute.transfers', 50)).length;
  // Independent halves overlap on about a quarter. Identical ones would overlap
  // on half, which is what hashing the person alone would produce.
  assert.ok(Math.abs(both / people.length - 0.25) < 0.005, `overlap ${both / people.length}`);
});

test('FLG-05 raising a rollout only ever adds people', () => {
  // A rider inside 10% stays inside at 20%: a widening rollout must not take
  // the feature away from someone who already had it.
  for (const p of people.slice(0, 5000))
    if (inRollout(p, 'map.live', 10)) assert.equal(inRollout(p, 'map.live', 20), true);
});
