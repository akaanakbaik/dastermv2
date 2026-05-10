const allowedEvents = new Set(["install", "run", "update", "respeedtest", "ai", "doctor"]);
const allowedLang = new Set(["id", "en"]);
const allowedMode = new Set(["lite", "full"]);
const allowedArch = new Set(["x86_64", "amd64", "aarch64", "arm64", "armv7l", "i386", "i686", "unknown"]);
const allowedVirt = new Set(["kvm", "qemu", "lxc", "docker", "wsl", "vmware", "oracle", "microsoft", "physical", "physical/unknown", "none", "unknown"]);

function json(data, status = 200) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
      "access-control-allow-origin": "*"
    }
  });
}

function svg(text, value, color = "111827") {
  const left = String(text || "badge");
  const right = String(value || "0");
  const leftWidth = Math.max(72, left.length * 7 + 20);
  const rightWidth = Math.max(48, right.length * 7 + 20);
  const total = leftWidth + rightWidth;
  const body = `<svg xmlns="http://www.w3.org/2000/svg" width="${total}" height="20" role="img" aria-label="${escapeXml(left)}: ${escapeXml(right)}"><linearGradient id="s" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><clipPath id="r"><rect width="${total}" height="20" rx="3" fill="#fff"/></clipPath><g clip-path="url(#r)"><rect width="${leftWidth}" height="20" fill="#555"/><rect x="${leftWidth}" width="${rightWidth}" height="20" fill="#${color}"/><rect width="${total}" height="20" fill="url(#s)"/></g><g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" text-rendering="geometricPrecision" font-size="110"><text aria-hidden="true" x="${leftWidth * 5}" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="${(leftWidth - 20) * 10}">${escapeXml(left)}</text><text x="${leftWidth * 5}" y="140" transform="scale(.1)" fill="#fff" textLength="${(leftWidth - 20) * 10}">${escapeXml(left)}</text><text aria-hidden="true" x="${leftWidth * 10 + rightWidth * 5}" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="${(rightWidth - 20) * 10}">${escapeXml(right)}</text><text x="${leftWidth * 10 + rightWidth * 5}" y="140" transform="scale(.1)" fill="#fff" textLength="${(rightWidth - 20) * 10}">${escapeXml(right)}</text></g></svg>`;
  return new Response(body, {
    headers: {
      "content-type": "image/svg+xml; charset=utf-8",
      "cache-control": "public, max-age=300",
      "access-control-allow-origin": "*"
    }
  });
}

function escapeXml(input) {
  return String(input).replace(/[<>&'"]/g, c => ({
    "<": "&lt;",
    ">": "&gt;",
    "&": "&amp;",
    "'": "&apos;",
    "\"": "&quot;"
  })[c]);
}

function cleanText(value, fallback = "unknown", max = 64) {
  const text = String(value || fallback).trim().toLowerCase();
  const cleaned = text.replace(/[^a-z0-9._+:/ -]/g, "").slice(0, max);
  return cleaned || fallback;
}

function cleanVersion(value) {
  const text = String(value || "unknown").trim();
  const cleaned = text.replace(/[^a-zA-Z0-9._+-]/g, "").slice(0, 32);
  return cleaned || "unknown";
}

function cleanHash(value) {
  const text = String(value || "").trim().toLowerCase();
  if (!/^[a-f0-9]{32,128}$/.test(text)) return "";
  return text.slice(0, 128);
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

async function sha256(text) {
  const data = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(hash)].map(x => x.toString(16).padStart(2, "0")).join("");
}

async function readJson(request, env) {
  const max = Number(env.MAX_BODY_SIZE || 4096);
  const len = Number(request.headers.get("content-length") || 0);
  if (len > max) throw new Error("body too large");
  const data = await request.json();
  return data && typeof data === "object" ? data : {};
}

async function rateLimit(env, key, limit, windowSeconds) {
  const now = Math.floor(Date.now() / 1000);
  const bucket = key.slice(0, 160);
  const row = await env.DB.prepare("SELECT count, reset_at FROM rate_limits WHERE bucket = ?").bind(bucket).first();
  if (!row || Number(row.reset_at) <= now) {
    await env.DB.prepare("INSERT OR REPLACE INTO rate_limits(bucket, count, reset_at) VALUES(?, ?, ?)").bind(bucket, 1, now + windowSeconds).run();
    return true;
  }
  if (Number(row.count) >= limit) return false;
  await env.DB.prepare("UPDATE rate_limits SET count = count + 1 WHERE bucket = ?").bind(bucket).run();
  return true;
}

async function handleUsage(request, env) {
  if (request.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "access-control-allow-origin": "*",
        "access-control-allow-methods": "POST, OPTIONS",
        "access-control-allow-headers": "content-type"
      }
    });
  }
  if (request.method !== "POST") return json({ success: false, error: "method not allowed" }, 405);
  let body;
  try {
    body = await readJson(request, env);
  } catch {
    return json({ success: false, error: "invalid json" }, 400);
  }
  const event = cleanText(body.event, "", 32);
  if (!allowedEvents.has(event)) return json({ success: false, error: "invalid event" }, 400);
  const machine = cleanHash(body.machine_hash);
  if (!machine) return json({ success: false, error: "invalid machine hash" }, 400);
  const ip = request.headers.get("cf-connecting-ip") || request.headers.get("x-forwarded-for") || "unknown";
  const ua = request.headers.get("user-agent") || "unknown";
  const uaHash = await sha256(`${ip}:${ua}:${today()}`);
  const ipOk = await rateLimit(env, `ip:${event}:${ip}:${today()}`, 120, 86400);
  const machineLimit = event === "run" ? 30 : event === "install" ? 3 : 10;
  const machineOk = await rateLimit(env, `machine:${event}:${machine}:${today()}`, machineLimit, 86400);
  if (!ipOk || !machineOk) return json({ success: false, error: "rate limited" }, 429);
  const version = cleanVersion(body.version);
  const distro = cleanText(body.distro, "unknown", 48);
  const distroVersion = cleanVersion(body.distro_version);
  const archRaw = cleanText(body.arch, "unknown", 32);
  const arch = allowedArch.has(archRaw) ? archRaw : "unknown";
  const virtRaw = cleanText(body.virt, "unknown", 48);
  const virt = allowedVirt.has(virtRaw) ? virtRaw : virtRaw.slice(0, 48);
  const langRaw = cleanText(body.lang, "id", 8);
  const lang = allowedLang.has(langRaw) ? langRaw : "id";
  const modeRaw = cleanText(body.mode, "lite", 16);
  const mode = allowedMode.has(modeRaw) ? modeRaw : "lite";
  const date = /^\d{4}-\d{2}-\d{2}$/.test(String(body.date || "")) ? String(body.date) : today();
  await env.DB.prepare("INSERT INTO usage_events(event, version, distro, distro_version, arch, virt, lang, mode, machine_hash, date, user_agent_hash) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)").bind(event, version, distro, distroVersion, arch, virt, lang, mode, machine, date, uaHash).run();
  return json({ success: true });
}

async function countValue(env, query, binds = []) {
  const stmt = env.DB.prepare(query).bind(...binds);
  const row = await stmt.first();
  return row ? Object.values(row)[0] ?? 0 : 0;
}

async function topValue(env, column, offset = 0) {
  const allowed = new Set(["distro", "virt", "lang", "mode", "arch"]);
  if (!allowed.has(column)) return { name: "unknown", total: 0 };
  const row = await env.DB.prepare(`SELECT ${column} AS name, COUNT(*) AS total FROM usage_events WHERE ${column} IS NOT NULL AND ${column} != '' GROUP BY ${column} ORDER BY total DESC LIMIT 1 OFFSET ?`).bind(offset).first();
  return row || { name: "unknown", total: 0 };
}

async function handleBadge(path, env) {
  if (path === "/badge/installs") {
    const total = await countValue(env, "SELECT COUNT(DISTINCT machine_hash) FROM usage_events WHERE event = 'install'");
    return svg("installs", formatNumber(total), "7c3aed");
  }
  if (path === "/badge/runs") {
    const total = await countValue(env, "SELECT COUNT(*) FROM usage_events WHERE event = 'run'");
    return svg("runs", formatNumber(total), "0ea5e9");
  }
  if (path === "/badge/top-os-1") {
    const row = await topValue(env, "distro", 0);
    return svg("top os #1", `${row.name} ${formatNumber(row.total)}`, "22c55e");
  }
  if (path === "/badge/top-os-2") {
    const row = await topValue(env, "distro", 1);
    return svg("top os #2", `${row.name} ${formatNumber(row.total)}`, "16a34a");
  }
  if (path === "/badge/top-virt") {
    const row = await topValue(env, "virt", 0);
    return svg("top virt", `${row.name} ${formatNumber(row.total)}`, "f97316");
  }
  if (path === "/badge/top-lang") {
    const row = await topValue(env, "lang", 0);
    return svg("top lang", `${row.name} ${formatNumber(row.total)}`, "eab308");
  }
  if (path === "/badge/top-mode") {
    const row = await topValue(env, "mode", 0);
    return svg("top mode", `${row.name} ${formatNumber(row.total)}`, "ec4899");
  }
  return svg("dasterm", "v2", "111827");
}

function formatNumber(value) {
  return new Intl.NumberFormat("en-US").format(Number(value || 0));
}

async function handleStats(env) {
  const installs = await countValue(env, "SELECT COUNT(DISTINCT machine_hash) FROM usage_events WHERE event = 'install'");
  const runs = await countValue(env, "SELECT COUNT(*) FROM usage_events WHERE event = 'run'");
  const updates = await countValue(env, "SELECT COUNT(*) FROM usage_events WHERE event = 'update'");
  const topOs1 = await topValue(env, "distro", 0);
  const topOs2 = await topValue(env, "distro", 1);
  const topVirt = await topValue(env, "virt", 0);
  const topLang = await topValue(env, "lang", 0);
  const topMode = await topValue(env, "mode", 0);
  return json({
    success: true,
    project: env.PROJECT_NAME || "Dasterm",
    installs,
    runs,
    updates,
    top: {
      os1: topOs1,
      os2: topOs2,
      virt: topVirt,
      lang: topLang,
      mode: topMode
    }
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/api/usage") return handleUsage(request, env);
    if (url.pathname.startsWith("/badge/")) return handleBadge(url.pathname, env);
    if (url.pathname === "/stats") return handleStats(env);
    if (url.pathname === "/") {
      return json({
        success: true,
        name: env.PROJECT_NAME || "Dasterm",
        endpoints: [
          "POST /api/usage",
          "GET /badge/installs",
          "GET /badge/runs",
          "GET /badge/top-os-1",
          "GET /badge/top-os-2",
          "GET /badge/top-virt",
          "GET /badge/top-lang",
          "GET /badge/top-mode",
          "GET /stats"
        ]
      });
    }
    return json({ success: false, error: "not found" }, 404);
  }
};