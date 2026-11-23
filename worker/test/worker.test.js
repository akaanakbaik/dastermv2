import { test } from 'node:test';
import assert from 'node:assert/strict';
import { DatabaseSync } from 'node:sqlite';
import { readFileSync } from 'node:fs';
import worker from '../src/index.js';

function fixture() {
  const db = new DatabaseSync(':memory:');
  db.exec(readFileSync(new URL('../schema.sql', import.meta.url), 'utf8'));
  const env = { DB: { prepare(sql) {
    return { bind(...args) {
      const statement = db.prepare(sql);
      return { async first() { return statement.get(...args); },
               async run() { return statement.run(...args); } };
    } };
  } } };
  const send = (path, options) => worker.fetch(new Request('https://test.invalid' + path, options), env);
  const usage = (body) => send('/api/usage', {method:'POST', body:JSON.stringify(body)});
  return {db, env, send, usage};
}

const valid = {event:'install', machine_hash:'a'.repeat(64), distro:'alpine',
  distro_version:'3.22', arch:'aarch64', virt:'openvz', lang:'en', mode:'full'};

test('usage persists to actual SQLite schema and stats/badges read it', async () => {
  const {db, send, usage} = fixture();
  try {
    assert.equal((await usage(valid)).status, 200);
    assert.equal((await usage({...valid, event:'run'})).status, 200);
    const row = db.prepare('SELECT * FROM usage_events LIMIT 1').get();
    assert.equal(row.arch, 'aarch64');
    assert.equal(row.virt, 'openvz');
    const stats = await (await send('/stats')).json();
    assert.equal(stats.installs, 1);
    assert.equal(stats.runs, 1);
    assert.equal(stats.top.os1.name, 'alpine');
    for (const name of ['installs','runs','top-os-1','top-os-2','top-virt','top-lang','top-mode']) {
      const response = await send('/badge/' + name);
      assert.equal(response.status, 200);
      assert.match(response.headers.get('content-type'), /image\/svg/);
      assert.match(await response.text(), /<svg/);
    }
  } finally { db.close(); }
});

test('validation and unsupported methods do not persist events', async () => {
  const {db, send, usage} = fixture();
  try {
    assert.equal((await send('/api/usage')).status, 405);
    assert.equal((await send('/api/usage', {method:'OPTIONS'})).status, 200);
    assert.equal((await usage({...valid, event:'invalid'})).status, 400);
    assert.equal((await usage({...valid, machine_hash:'bad'})).status, 400);
    assert.equal((await send('/api/usage', {method:'POST', body:'{broken'})).status, 400);
    assert.equal(db.prepare('SELECT COUNT(*) AS n FROM usage_events').get().n, 0);
    assert.equal((await send('/missing')).status, 404);
    assert.equal((await send('/')).status, 200);
  } finally { db.close(); }
});

test('machine rate limit and expired bucket recovery', async () => {
  const {db, usage} = fixture();
  try {
    for (let i=0; i<3; i++) assert.equal((await usage(valid)).status, 200);
    assert.equal((await usage(valid)).status, 429);
    db.exec('UPDATE rate_limits SET reset_at=0');
    assert.equal((await usage(valid)).status, 200);
  } finally { db.close(); }
});
