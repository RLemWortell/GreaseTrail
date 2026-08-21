import { Alert } from "react-native";
import * as FileSystem from "expo-file-system";
import * as Sharing from "expo-sharing";
import * as Print from "expo-print";
import { TYPE_META } from "./templates";
import { formatDate, formatOdo, formatLogLine } from "../format";

function stamp() {
  return new Date().toISOString().slice(0, 10);
}

function csvCell(value) {
  const s = value == null ? "" : String(value);
  if (/[",\n\r]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

function esc(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function typeLabel(type) {
  return TYPE_META[type]?.label || type || "";
}

function slug(name) {
  return (
    String(name || "export")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")
      .slice(0, 40) || "export"
  );
}

function allLogs(vehicles) {
  return vehicles
    .flatMap((v) =>
      (v.logs || []).map((l) => ({
        ...l,
        vehicle: v,
        vehicleName: v.name,
        vehicleType: typeLabel(v.type),
        vehicleModel: v.model || "",
      }))
    )
    .sort((a, b) => new Date(b.date) - new Date(a.date));
}

export function buildJson(vehicles) {
  return JSON.stringify(
    {
      app: "GreaseTrail",
      version: 1,
      exportedAt: new Date().toISOString(),
      vehicles,
    },
    null,
    2
  );
}

export function buildCsv(vehicles) {
  const header = ["Vehicle", "Type", "Model", "Date", "Odometer_km", "Category", "Service", "Values", "Note"];
  const rows = allLogs(vehicles).map((l) =>
    [
      l.vehicleName,
      l.vehicleType,
      l.vehicleModel,
      l.date,
      l.odometer,
      l.categoryName,
      l.service || "",
      formatLogLine(l.vehicle, l),
      l.note || "",
    ].map(csvCell)
  );
  return [header.join(","), ...rows].join("\n");
}

function pdfDetails(vehicle, log) {
  const parts = [];
  if (log.service) parts.push(`<div class="svc">${esc(log.service)}</div>`);
  const line = formatLogLine(vehicle, log);
  if (line) parts.push(`<div>${esc(line)}</div>`);
  if (log.note) parts.push(`<div class="note">${esc(log.note)}</div>`);
  return parts.join("") || "—";
}

export function buildPdfHtml(vehicles) {
  const single = vehicles.length === 1;
  const blocks = vehicles
    .map((v) => {
      const logs = [...(v.logs || [])].sort((a, b) => new Date(b.date) - new Date(a.date));
      const rows =
        logs.length === 0
          ? `<p class="empty">No log entries.</p>`
          : `<table>
              <thead>
                <tr>
                  <th>Date</th>
                  <th>km</th>
                  <th>Category</th>
                  <th>Details</th>
                </tr>
              </thead>
              <tbody>
                ${logs
                  .map(
                    (l) => `<tr>
                      <td>${esc(formatDate(l.date))}</td>
                      <td>${esc(formatOdo(l.odometer))}</td>
                      <td>${esc(l.categoryName)}</td>
                      <td>${pdfDetails(v, l)}</td>
                    </tr>`
                  )
                  .join("")}
              </tbody>
            </table>`;

      const heading = single
        ? ""
        : `<h2>${esc(v.name)}</h2>
        <p class="meta">${esc([v.model, typeLabel(v.type), `${formatOdo(v.odometer)} km`].filter(Boolean).join("  ·  "))}</p>`;

      return `<section>
        ${heading}
        ${rows}
      </section>`;
    })
    .join("");

  const title = single ? vehicles[0].name : "GreaseTrail";
  const sub = single
    ? [
        formatDate(new Date().toISOString()),
        vehicles[0].model,
        typeLabel(vehicles[0].type),
        `${formatOdo(vehicles[0].odometer)} km`,
      ]
        .filter(Boolean)
        .join("  ·  ")
    : `${formatDate(new Date().toISOString())}  ·  ${vehicles.length} vehicles`;

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <style>
    body { font-family: -apple-system, Helvetica, Arial, sans-serif; color: #1A1A1A; background: #F5F5F0; padding: 28px; }
    h1 { font-size: 22px; letter-spacing: 0.08em; text-transform: uppercase; margin: 0 0 6px; }
    .sub { color: #8A8A84; font-size: 11px; letter-spacing: 0.12em; text-transform: uppercase; margin-bottom: 28px; }
    h2 { font-size: 16px; letter-spacing: 0.04em; text-transform: uppercase; margin: 28px 0 4px; }
    .meta { color: #8A8A84; font-size: 12px; margin: 0 0 12px; }
    .empty { color: #8A8A84; font-size: 13px; }
    .svc { font-weight: 600; margin-bottom: 2px; }
    .note { color: #8A8A84; margin-top: 2px; }
    table { width: 100%; border-collapse: collapse; }
    th { text-align: left; font-size: 10px; letter-spacing: 0.12em; text-transform: uppercase; color: #8A8A84; padding: 8px 8px 8px 0; border-bottom: 1px solid #E4E2DC; }
    td { font-size: 12px; padding: 8px 8px 8px 0; border-bottom: 1px solid #E4E2DC; vertical-align: top; }
    section { page-break-inside: avoid; }
  </style>
</head>
<body>
  <h1>${esc(title)}</h1>
  <p class="sub">${esc(sub)}</p>
  ${blocks || `<p class="empty">No vehicles.</p>`}
</body>
</html>`;
}

async function shareFile(uri, mimeType, dialogTitle) {
  const available = await Sharing.isAvailableAsync();
  if (!available) {
    Alert.alert("Share", "Sharing is not available on this device.");
    return;
  }
  await Sharing.shareAsync(uri, {
    mimeType,
    dialogTitle,
    UTI: mimeType === "application/pdf" ? "com.adobe.pdf" : mimeType === "text/csv" ? "public.comma-separated-values-text" : "public.json",
  });
}

async function writeCache(name, contents, encoding = FileSystem.EncodingType.UTF8) {
  const uri = `${FileSystem.cacheDirectory}${name}`;
  await FileSystem.writeAsStringAsync(uri, contents, { encoding });
  return uri;
}

export async function exportJson(vehicles) {
  const uri = await writeCache(`greasetrail-${stamp()}.json`, buildJson(vehicles));
  await shareFile(uri, "application/json", "Export JSON");
}

export async function exportCsv(vehicles) {
  const uri = await writeCache(`greasetrail-${stamp()}.csv`, buildCsv(vehicles));
  await shareFile(uri, "text/csv", "Export CSV");
}

export async function exportPdf(vehicles) {
  const label = vehicles.length === 1 ? slug(vehicles[0].name) : "all";
  const { uri } = await Print.printToFileAsync({ html: buildPdfHtml(vehicles) });
  const dest = `${FileSystem.cacheDirectory}greasetrail-${label}-${stamp()}.pdf`;
  if (uri !== dest) {
    try {
      await FileSystem.copyAsync({ from: uri, to: dest });
      await shareFile(dest, "application/pdf", "Export PDF");
      return;
    } catch (e) {
      // Fall through and share the print file as-is.
    }
  }
  await shareFile(uri, "application/pdf", "Export PDF");
}

export async function shareJsonFile(filename, contents, title) {
  const uri = await writeCache(filename, contents);
  await shareFile(uri, "application/json", title);
}
