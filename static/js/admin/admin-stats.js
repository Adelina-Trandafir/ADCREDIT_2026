/* ========== admin-stats.js ========== */

import { CalendarManager } from '../components/calendar/calendar-manager.js';
import { TreeView } from '../components/treeview/treeview.js';
import overlayManager from '../utils/overlay-manager.js';

// ---- Theme ----
const themeManager = {
    theme: localStorage.getItem('admin-theme') || 'dark',
    icon: null,
    init() {
        this.icon = document.getElementById('themeIcon');
        this.apply();
    },
    apply() {
        document.documentElement.setAttribute('data-theme', this.theme);
        if (this.icon) this.icon.textContent = this.theme === 'light' ? '🌙' : '☀️';
    },
    toggle() {
        this.theme = this.theme === 'light' ? 'dark' : 'light';
        this.apply();
        localStorage.setItem('admin-theme', this.theme);
    }
};
window.toggleTheme = () => themeManager.toggle();

// ---- Chart instances (kept for destroy before re-render) ----
const charts = {
    leadsSursa: null,
    feedbackStatus: null,
    dosareStatus: null,
    dosareBanca: null,
    trendLinii: null,
    trendValoare: null,
};

// ---- Color palette ----
const PALETTE = [
    "#667eea", "#764ba2", "#10b981", "#f59e0b", "#ef4444",
    "#3b82f6", "#8b5cf6", "#06b6d4", "#ec4899", "#84cc16",
    "#f97316", "#14b8a6", "#a855f7", "#0ea5e9", "#d946ef",
];

function paletteFor(n) {
    const colors = [];
    for (let i = 0; i < n; i++) colors.push(PALETTE[i % PALETTE.length]);
    return colors;
}

// ---- State ----
let selectedDb = "SVN_IM";

// ---- Formatting ----
function fmtNum(v) {
    if (v === null || v === undefined) return "-";
    return Number(v).toLocaleString("ro-RO");
}

function fmtRon(v) {
    if (v === null || v === undefined) return "-";
    return Number(v).toLocaleString("ro-RO", { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}

function fmtPct(num, total) {
    if (!total) return "0%";
    return ((num / total) * 100).toFixed(1) + "%";
}

// ---- Toast ----
function showToast(msg, type) {
    const container = document.getElementById("toastContainer");
    if (!container) return;
    const toast = document.createElement("div");
    toast.className = "toast " + (type || "info");
    toast.innerHTML = `<span class="toast-message">${msg}</span>`;
    container.appendChild(toast);
    setTimeout(() => { toast.remove(); }, 4000);
}

// ---- Tab switching ----
function switchToTab(tabName) {
    const btns = document.querySelectorAll(".tab-btn");
    btns.forEach(b => {
        const isTarget = b.dataset.tab === tabName;
        b.classList.toggle("active", isTarget);
    });
    document.querySelectorAll(".tab-content").forEach(s => s.classList.remove("active"));
    const section = document.getElementById("tab-" + tabName);
    if (section) section.classList.add("active");
}

function initTabs() {
    const btns = document.querySelectorAll(".tab-btn");
    btns.forEach(btn => {
        btn.addEventListener("click", () => switchToTab(btn.dataset.tab));
    });
}

// ---- DB selector ----
function initDbSelector() {
    const sel = document.getElementById("dbSelector");
    if (!sel) return;
    sel.addEventListener("change", () => {
        selectedDb = sel.value;
        reloadAll();
    });
}

// ---- Destroy chart helper ----
function destroyChart(key) {
    if (charts[key]) {
        charts[key].destroy();
        charts[key] = null;
    }
}

// ---- Spinner helpers ----
function setKpiLoading() {
    const ids = [
        "kpi-total-leads", "kpi-leads-noi", "kpi-leads-azi", "kpi-leads-30zile",
        "kpi-total-dosare", "kpi-dosare-debursate", "kpi-dosare-respinse",
        "kpi-total-clienti", "kpi-valoare-totala", "kpi-valoare-debursata",
    ];
    ids.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.innerHTML = '<span class="kpi-spinner"></span>';
    });
}

function setTableLoading(tbodyId, cols) {
    const el = document.getElementById(tbodyId);
    if (el) el.innerHTML = `<tr><td colspan="${cols}" class="table-loading">Se incarca...</td></tr>`;
}

// ---- loadKpis ----
async function loadKpis() {
    setKpiLoading();
    try {
        const res = await fetch(`/admin/api/business-kpis?db=${selectedDb}`);
        const json = await res.json();
        if (!json.success) throw new Error(json.error || "Eroare server");
        const d = json.data;
        document.getElementById("kpi-total-leads").textContent = fmtNum(d.total_leads);
        document.getElementById("kpi-leads-noi").textContent = fmtNum(d.leads_noi);
        document.getElementById("kpi-leads-azi").textContent = fmtNum(d.leads_azi);
        document.getElementById("kpi-leads-30zile").textContent = fmtNum(d.leads_30zile);
        document.getElementById("kpi-total-dosare").textContent = fmtNum(d.total_dosare);
        document.getElementById("kpi-dosare-debursate").textContent = fmtNum(d.dosare_debursate);
        document.getElementById("kpi-dosare-respinse").textContent = fmtNum(d.dosare_respinse);
        document.getElementById("kpi-total-clienti").textContent = fmtNum(d.total_clienti);
        document.getElementById("kpi-valoare-totala").textContent = fmtRon(d.valoare_totala_ron);
        document.getElementById("kpi-valoare-debursata").textContent = fmtRon(d.valoare_debursata_ron);
    } catch (e) {
        showToast("Eroare KPI: " + e.message, "error");
        ["kpi-total-leads","kpi-leads-noi","kpi-leads-azi","kpi-leads-30zile",
         "kpi-total-dosare","kpi-dosare-debursate","kpi-dosare-respinse",
         "kpi-total-clienti","kpi-valoare-totala","kpi-valoare-debursata"]
            .forEach(id => { const el=document.getElementById(id); if(el) el.textContent="-"; });
    }
}

// ---- loadLeadsBySource ----
async function loadLeadsBySource() {
    setTableLoading("tbodyLeadsSursa", 4);
    try {
        const res = await fetch(`/admin/api/leads-by-source?db=${selectedDb}`);
        const json = await res.json();
        if (!json.success) throw new Error(json.error || "Eroare server");
        const rows = json.data;
        const total = rows.reduce((s, r) => s + r.total, 0);

        // Update subtitle
        const sub = document.getElementById("leadsSursaSubtitle");
        if (sub) sub.textContent = "Top " + rows.length + " surse";

        // Chart
        destroyChart("leadsSursa");
        const ctx = document.getElementById("chartLeadsSursa");
        if (ctx && rows.length > 0) {
            charts.leadsSursa = new Chart(ctx, {
                type: "doughnut",
                data: {
                    labels: rows.map(r => r.Sursa),
                    datasets: [{
                        data: rows.map(r => r.total),
                        backgroundColor: paletteFor(rows.length),
                        borderWidth: 2,
                        borderColor: "#1a1a2e",
                    }],
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: "right",
                            labels: { color: "#cbd5e1", font: { size: 12 }, boxWidth: 14 },
                        },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => {
                                    const v = ctx.parsed;
                                    return ` ${ctx.label}: ${fmtNum(v)} (${fmtPct(v, total)})`;
                                },
                            },
                        },
                    },
                },
            });
        }

        // Table
        const tbody = document.getElementById("tbodyLeadsSursa");
        if (tbody) {
            if (rows.length === 0) {
                tbody.innerHTML = `<tr><td colspan="4" class="table-empty">Nu exista date</td></tr>`;
            } else {
                tbody.innerHTML = rows.map((r, i) => `
                    <tr>
                        <td class="td-num">${i + 1}</td>
                        <td>${r.Sursa}</td>
                        <td class="td-num">${fmtNum(r.total)}</td>
                        <td class="td-num">${fmtPct(r.total, total)}</td>
                    </tr>
                `).join("");
            }
        }
    } catch (e) {
        showToast("Eroare surse: " + e.message, "error");
        setTableLoading("tbodyLeadsSursa", 4);
    }
}

// ---- loadFeedbackByStatus ----
async function loadFeedbackByStatus() {
    try {
        const res = await fetch(`/admin/api/feedback-by-status?db=${selectedDb}`);
        const json = await res.json();
        if (!json.success) throw new Error(json.error || "Eroare server");
        const rows = json.data;

        destroyChart("feedbackStatus");
        const ctx = document.getElementById("chartFeedbackStatus");
        if (ctx && rows.length > 0) {
            charts.feedbackStatus = new Chart(ctx, {
                type: "doughnut",
                data: {
                    labels: rows.map(r => r.FelStatus),
                    datasets: [{
                        data: rows.map(r => r.total),
                        backgroundColor: paletteFor(rows.length),
                        borderWidth: 2,
                        borderColor: "#1a1a2e",
                    }],
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: "right",
                            labels: { color: "#cbd5e1", font: { size: 12 }, boxWidth: 14 },
                        },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => ` ${ctx.label}: ${fmtNum(ctx.parsed)}`,
                            },
                        },
                    },
                },
            });
        }
    } catch (e) {
        showToast("Eroare feedback: " + e.message, "error");
    }
}

// ---- loadDosareByStatus ----
async function loadDosareByStatus() {
    try {
        const res = await fetch(`/admin/api/dosare-by-status?db=${selectedDb}`);
        const json = await res.json();
        if (!json.success) throw new Error(json.error || "Eroare server");
        const rows = json.data;

        destroyChart("dosareStatus");
        const ctx = document.getElementById("chartDosareStatus");
        if (ctx && rows.length > 0) {
            charts.dosareStatus = new Chart(ctx, {
                type: "bar",
                data: {
                    labels: rows.map(r => r.FelStatus),
                    datasets: [
                        {
                            label: "Nr. Dosare",
                            data: rows.map(r => r.total),
                            backgroundColor: paletteFor(rows.length),
                            borderRadius: 6,
                            yAxisID: "yLeft",
                        },
                        {
                            label: "Valoare RON",
                            data: rows.map(r => r.valoare),
                            backgroundColor: "rgba(102,126,234,0.35)",
                            borderColor: "#667eea",
                            borderWidth: 2,
                            type: "line",
                            yAxisID: "yRight",
                            tension: 0.3,
                            pointRadius: 4,
                        },
                    ],
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { labels: { color: "#cbd5e1" } },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => {
                                    if (ctx.dataset.label === "Valoare RON") {
                                        return ` Valoare: ${fmtRon(ctx.parsed.y)} RON`;
                                    }
                                    return ` Dosare: ${fmtNum(ctx.parsed.y)}`;
                                },
                            },
                        },
                    },
                    scales: {
                        x: { ticks: { color: "#94a3b8" }, grid: { color: "rgba(255,255,255,0.05)" } },
                        yLeft: { ticks: { color: "#94a3b8" }, grid: { color: "rgba(255,255,255,0.05)" }, position: "left" },
                        yRight: {
                            ticks: { color: "#667eea", callback: (v) => fmtRon(v) },
                            grid: { display: false },
                            position: "right",
                        },
                    },
                },
            });
        }
    } catch (e) {
        showToast("Eroare dosare status: " + e.message, "error");
    }
}

// ---- loadDosareByBank ----
async function loadDosareByBank() {
    setTableLoading("tbodyDosareBanca", 4);
    try {
        const res = await fetch(`/admin/api/dosare-by-bank?db=${selectedDb}`);
        const json = await res.json();
        if (!json.success) throw new Error(json.error || "Eroare server");
        const rows = json.data;

        destroyChart("dosareBanca");
        const ctx = document.getElementById("chartDosareBanca");
        if (ctx && rows.length > 0) {
            charts.dosareBanca = new Chart(ctx, {
                type: "bar",
                data: {
                    labels: rows.map(r => r.Banca),
                    datasets: [{
                        label: "Nr. Dosare",
                        data: rows.map(r => r.total),
                        backgroundColor: paletteFor(rows.length),
                        borderRadius: 6,
                    }],
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: "y",
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => ` Dosare: ${fmtNum(ctx.parsed.x)}`,
                                afterLabel: (ctx) => {
                                    const row = rows[ctx.dataIndex];
                                    return ` Valoare: ${fmtRon(row.valoare)} RON`;
                                },
                            },
                        },
                    },
                    scales: {
                        x: { ticks: { color: "#94a3b8" }, grid: { color: "rgba(255,255,255,0.05)" } },
                        y: { ticks: { color: "#cbd5e1" }, grid: { color: "rgba(255,255,255,0.05)" } },
                    },
                },
            });
        }

        // Table
        const tbody = document.getElementById("tbodyDosareBanca");
        if (tbody) {
            if (rows.length === 0) {
                tbody.innerHTML = `<tr><td colspan="4" class="table-empty">Nu exista date</td></tr>`;
            } else {
                tbody.innerHTML = rows.map((r, i) => `
                    <tr>
                        <td class="td-num">${i + 1}</td>
                        <td>${r.Banca}</td>
                        <td class="td-num">${fmtNum(r.total)}</td>
                        <td class="td-num">${fmtRon(r.valoare)}</td>
                    </tr>
                `).join("");
            }
        }
    } catch (e) {
        showToast("Eroare banci: " + e.message, "error");
        setTableLoading("tbodyDosareBanca", 4);
    }
}

// ---- loadTopConsultants ----
let consultantsData = [];
let sortCol = "dosare";
let sortDir = "desc";

async function loadTopConsultants() {
    setTableLoading("tbodyConsultanti", 8);
    try {
        const res = await fetch(`/admin/api/top-consultants?db=${selectedDb}`);
        const json = await res.json();
        if (!json.success) throw new Error(json.error || "Eroare server");
        consultantsData = json.data;
        renderConsultantsTable();
    } catch (e) {
        showToast("Eroare consultanti: " + e.message, "error");
        setTableLoading("tbodyConsultanti", 8);
    }
}

function renderConsultantsTable() {
    const tbody = document.getElementById("tbodyConsultanti");
    if (!tbody) return;

    const data = [...consultantsData].sort((a, b) => {
        let va = a[sortCol], vb = b[sortCol];
        if (sortCol === "NumeConsultant") {
            va = (va || "").toLowerCase();
            vb = (vb || "").toLowerCase();
            if (va < vb) return sortDir === "asc" ? -1 : 1;
            if (va > vb) return sortDir === "asc" ? 1 : -1;
            return 0;
        }
        if (sortCol === "rata") {
            va = a.dosare > 0 ? (a.debursate / a.dosare) : 0;
            vb = b.dosare > 0 ? (b.debursate / b.dosare) : 0;
        }
        return sortDir === "asc" ? va - vb : vb - va;
    });

    if (data.length === 0) {
        tbody.innerHTML = `<tr><td colspan="8" class="table-empty">Nu exista date</td></tr>`;
        return;
    }

    tbody.innerHTML = data.map((r, i) => {
        const rata = r.dosare > 0 ? ((r.debursate / r.dosare) * 100).toFixed(1) + "%" : "0%";
        const rataVal = r.dosare > 0 ? (r.debursate / r.dosare) : 0;
        const rataClass = rataVal >= 0.5 ? "rata-high" : rataVal >= 0.25 ? "rata-med" : "rata-low";
        const safeName = r.NumeConsultant.replace(/'/g, "\\'");
        return `<tr>
            <td class="td-num">${i + 1}</td>
            <td class="td-name">${r.NumeConsultant}</td>
            <td class="td-num">${fmtNum(r.dosare)}</td>
            <td class="td-num">${fmtRon(r.valoare)}</td>
            <td class="td-num td-green">${fmtNum(r.debursate)}</td>
            <td class="td-num td-red">${fmtNum(r.respinse)}</td>
            <td class="td-num"><span class="rata-badge ${rataClass}">${rata}</span></td>
            <td class="td-action"><button class="ai-jump-btn" onclick="analyzeConsultant(${r.IdConsultant || 0}, '${safeName}')" title="Analiză AI">&#129302;</button></td>
        </tr>`;
    }).join("");
}

function initConsultantsSort() {
    const table = document.getElementById("tableConsultanti");
    if (!table) return;
    table.querySelectorAll("th.sortable").forEach(th => {
        th.style.cursor = "pointer";
        th.addEventListener("click", () => {
            const col = th.dataset.col;
            if (sortCol === col) {
                sortDir = sortDir === "asc" ? "desc" : "asc";
            } else {
                sortCol = col;
                sortDir = "desc";
            }
            table.querySelectorAll("th").forEach(t => t.classList.remove("sort-active", "sort-asc", "sort-desc"));
            th.classList.add("sort-active", sortDir === "asc" ? "sort-asc" : "sort-desc");
            renderConsultantsTable();
        });
    });
}

// ---- loadMonthlyTrend ----
async function loadMonthlyTrend() {
    try {
        const res = await fetch(`/admin/api/monthly-trend?db=${selectedDb}`);
        const json = await res.json();
        if (!json.success) throw new Error(json.error || "Eroare server");
        const rows = json.data;

        const labels = rows.map(r => r.luna);
        const leadsData = rows.map(r => r.leads);
        const dosareData = rows.map(r => r.dosare);
        const valoareData = rows.map(r => r.valoare);

        // Line chart - leads & dosare
        destroyChart("trendLinii");
        const ctx1 = document.getElementById("chartTrendLinii");
        if (ctx1) {
            charts.trendLinii = new Chart(ctx1, {
                type: "line",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "Leads",
                            data: leadsData,
                            borderColor: "#667eea",
                            backgroundColor: "rgba(102,126,234,0.15)",
                            tension: 0.3,
                            fill: true,
                            pointRadius: 5,
                            pointHoverRadius: 7,
                        },
                        {
                            label: "Dosare",
                            data: dosareData,
                            borderColor: "#10b981",
                            backgroundColor: "rgba(16,185,129,0.15)",
                            tension: 0.3,
                            fill: true,
                            pointRadius: 5,
                            pointHoverRadius: 7,
                        },
                    ],
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: { mode: "index", intersect: false },
                    plugins: {
                        legend: { labels: { color: "#cbd5e1" } },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => ` ${ctx.dataset.label}: ${fmtNum(ctx.parsed.y)}`,
                            },
                        },
                    },
                    scales: {
                        x: { ticks: { color: "#94a3b8" }, grid: { color: "rgba(255,255,255,0.05)" } },
                        y: { ticks: { color: "#94a3b8" }, grid: { color: "rgba(255,255,255,0.05)" }, beginAtZero: true },
                    },
                },
            });
        }

        // Bar chart - valoare
        destroyChart("trendValoare");
        const ctx2 = document.getElementById("chartTrendValoare");
        if (ctx2) {
            charts.trendValoare = new Chart(ctx2, {
                type: "bar",
                data: {
                    labels,
                    datasets: [{
                        label: "Valoare Credite (RON)",
                        data: valoareData,
                        backgroundColor: paletteFor(labels.length),
                        borderRadius: 6,
                    }],
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: (ctx) => ` ${fmtRon(ctx.parsed.y)} RON`,
                            },
                        },
                    },
                    scales: {
                        x: { ticks: { color: "#94a3b8" }, grid: { color: "rgba(255,255,255,0.05)" } },
                        y: {
                            ticks: { color: "#94a3b8", callback: (v) => fmtRon(v) },
                            grid: { color: "rgba(255,255,255,0.05)" },
                            beginAtZero: true,
                        },
                    },
                },
            });
        }
    } catch (e) {
        showToast("Eroare tendinte: " + e.message, "error");
    }
}

// ---- Feedback Analysis (AI tab) ----

const TAG_COLORS = {
    consultant_comunicare_slaba: "#f59e0b",
    consultant_agresiv: "#ef4444",
    "consultant_nepregătit": "#f97316",
    consultant_pozitiv: "#10b981",
    client_refuz_credit: "#8b5cf6",
    client_informatii_insuficiente: "#06b6d4",
    client_probleme_financiare: "#ec4899",
    client_contact_imposibil: "#3b82f6",
    lead_calitate_slaba: "#ef4444",
    oportunitate_buna: "#84cc16",
};

const INSIGHT_ICONS = { danger: "🔴", warning: "🟡", success: "🟢", info: "🔵", neutral: "⚪" };

let aiAnalysisData = [];
let aiCalFrom = null;
let aiCalTo = null;
let aiTree = null;

// ---- AI controls init ----
async function initAiControls() {
    const calMgr = new CalendarManager();

    const inputFrom = document.getElementById("aiDateFrom");
    const inputTo = document.getElementById("aiDateTo");
    if (inputFrom) {
        aiCalFrom = calMgr.createCalendarForInput(inputFrom, {
            allowPast: true, allowFuture: false,
            customDate: true,
            showTimeSelector: false,
        }, false);
        aiCalFrom.setEnabled(true);
        // Default: first day of current month
        const now = new Date();
        const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
        aiCalFrom.setDate(firstDay);
        // Hide the DD/MM/YYYY control while calendar is open, restore on close
        const ctrlFrom = inputFrom.parentElement?.querySelector('.custom-date-container');
        if (ctrlFrom) {
            const _showFrom = aiCalFrom.show.bind(aiCalFrom);
            const _hideFrom = aiCalFrom.hide.bind(aiCalFrom);
            aiCalFrom.show = () => { ctrlFrom.style.visibility = 'hidden'; _showFrom(); };
            aiCalFrom.hide = () => { _hideFrom(); setTimeout(() => { ctrlFrom.style.visibility = ''; }, 260); };
        }
    }
    if (inputTo) {
        aiCalTo = calMgr.createCalendarForInput(inputTo, {
            allowPast: true, allowFuture: false,
            customDate: true,
            showTimeSelector: false,
        }, false);
        aiCalTo.setEnabled(true);
        aiCalTo.setDate(new Date());
        // Hide the DD/MM/YYYY control while calendar is open, restore on close
        const ctrlTo = inputTo.parentElement?.querySelector('.custom-date-container');
        if (ctrlTo) {
            const _showTo = aiCalTo.show.bind(aiCalTo);
            const _hideTo = aiCalTo.hide.bind(aiCalTo);
            aiCalTo.show = () => { ctrlTo.style.visibility = 'hidden'; _showTo(); };
            aiCalTo.hide = () => { _hideTo(); setTimeout(() => { ctrlTo.style.visibility = ''; }, 260); };
        }
    }

    const treeContainer = document.getElementById("aiConsultantTree");
    if (treeContainer) {
        aiTree = new TreeView(treeContainer, {
            placeholder: "Toți consultanții...",
            showSearchBox: true,
            dropdownHeight: 320,
            onSelect: () => { /* selection is read on demand */ },
        });

        // Page-level patch: single click selects any item;
        // parents stay open, leaves close normally.
        aiTree.handleDropdownClick = function(e) {
            const target = e.target;
            e.stopPropagation();

            // Ignore search box
            if (aiTree.searchInput &&
                (target === aiTree.searchInput || target.closest('.treeview-search-wrapper'))) {
                return;
            }

            // Expander arrow — just toggle, no selection
            if (target.classList.contains('treeview-expander')) {
                const nodeId = target.dataset.nodeId;
                aiTree.toggleNode(nodeId, e.shiftKey);
                return;
            }

            const item = target.closest('.treeview-item');
            if (!item) return;

            const nodeId = item.dataset.value;
            const text   = item.dataset.text || '';
            const level  = parseInt(item.dataset.level || '1');
            const hasChildren = item.dataset.hasChildren === 'true';

            // Parse path (format: "id,label;id,label;...")
            const pathString = item.dataset.path || '';
            const path = pathString
                ? pathString.split(';').map(p => { const [id, label] = p.split(','); return { id, label }; })
                : [{ id: nodeId, label: text }];

            // Always update selection state + input text
            aiTree.selectedValue = nodeId;
            aiTree.selectedText  = text;
            aiTree.selectedPath  = path;
            aiTree.input.value   = text;

            if (hasChildren) {
                // Expand/collapse branch but keep dropdown open
                aiTree.toggleNode(nodeId, e.shiftKey);
                if (aiTree.options.onSelect) {
                    aiTree.options.onSelect({ id: nodeId, label: text, path, level });
                }
            } else {
                // Leaf: close tree + overlay (original selectValue behavior)
                aiTree.selectFromItem(item);
            }
        };

        await loadConsultantTree();
    }
}

async function loadConsultantTree() {
    if (!aiTree) return;
    aiTree.showLoader();
    try {
        const resp = await fetch(`/admin/api/consultants-tree?db=${selectedDb}`);
        const json = await resp.json();
        if (!json.success) throw new Error(json.error);
        const treeData = json.data || [];
        aiTree.updateResults(treeData, '');
        // Expand root nodes by default
        treeData.forEach(node => {
            if (node.id != null) aiTree.expandedNodes.add(String(node.id));
        });
    } catch (e) {
        // showError needs createElements() to have run first; render empty + log instead
        try { aiTree.updateResults([], ''); } catch (_) { /* ignore */ }
        showToast("Eroare la încărcarea consultanților. Repornește serverul.", "error");
    } finally {
        aiTree.hideLoader();
    }
}

// ---- Build URL params from controls ----
function buildAiParams() {
    const params = new URLSearchParams({ db: selectedDb });
    const dateFrom = aiCalFrom?.getValue?.() || "";
    const dateTo = aiCalTo?.getValue?.() || "";
    if (dateFrom) params.set("date_from", dateFrom.split("T")[0]);
    if (dateTo) params.set("date_to", dateTo.split("T")[0]);
    const cid = aiTree?.getSelectedValue?.() || "";
    if (cid) params.set("consultant_id", cid);
    return params;
}

// ---- Load analysis ----
async function loadFeedbackAnalysis() {
    const grid = document.getElementById("aiAnalysisGrid");
    const summaryEl = document.getElementById("aiSummaryText");
    if (!grid) return;

    grid.innerHTML = '<div class="ai-loading"><span>&#9200;</span> Se analizeaz&#259; feedback-urile...</div>';
    if (summaryEl) summaryEl.textContent = "Se procesează...";

    try {
        const params = buildAiParams();
        const resp = await fetch(`/admin/api/feedback-analysis?${params}`);
        const json = await resp.json();
        if (!json.success) throw new Error(json.error || "Eroare server");

        aiAnalysisData = json.data || [];
        const total = json.total_analyzed || 0;

        if (summaryEl) {
            const consultant = aiTree?.getSelectedText?.() || "";
            const label = consultant && consultant !== "— Toți consultanții —"
                ? `${consultant}: ` : "";
            summaryEl.textContent = `${label}${total.toLocaleString("ro-RO")} feedback-uri → ${aiAnalysisData.length} consultanți`;
        }

        renderAnalysisGrid(aiAnalysisData);
    } catch (e) {
        grid.innerHTML = `<div class="ai-error">&#10060; Eroare: ${e.message}</div>`;
        showToast("Eroare analiză AI: " + e.message, "error");
    }
}

function renderAnalysisGrid(data) {
    const grid = document.getElementById("aiAnalysisGrid");
    if (!grid) return;
    if (!data.length) {
        grid.innerHTML = '<div class="ai-placeholder"><div class="ai-placeholder-icon">&#128269;</div><div class="ai-placeholder-text">Niciun consultant g&#259;sit pentru criteriile selectate.</div></div>';
        return;
    }

    grid.innerHTML = data.map(c => {
        const insightHtml = c.insights.map(i =>
            `<span class="insight-badge insight-${i.type}">${INSIGHT_ICONS[i.type] || "•"} ${i.msg}</span>`
        ).join("");

        const maxCount = c.top_tags.length ? c.top_tags[0].count : 1;
        const barsHtml = c.top_tags.slice(0, 4).map(t => {
            const pct = Math.round((t.count / maxCount) * 100);
            const color = TAG_COLORS[t.tag] || "#667eea";
            return `<div class="tag-bar-row">
                <span class="tag-bar-label" title="${t.label}">${t.label}</span>
                <div class="tag-bar-track">
                    <div class="tag-bar-fill" style="width:${pct}%;background:${color}"></div>
                </div>
                <span class="tag-bar-count">${t.count}</span>
            </div>`;
        }).join("");

        const scoreClass = c.score_negativ > c.score_pozitiv ? "score-neg" : "score-pos";
        const safeName = c.NumeConsultant.replace(/'/g, "\\'").replace(/"/g, "&quot;");

        return `<div class="consultant-card">
            <div class="consultant-card-header">
                <div class="consultant-name">${c.NumeConsultant}</div>
                <div class="consultant-meta">
                    <span class="feedback-count">${c.total_feedback} feedback</span>
                    <span class="score-badge ${scoreClass}">▲${c.score_pozitiv} ▼${c.score_negativ}</span>
                </div>
            </div>
            <div class="consultant-insights">${insightHtml || '<span class="insight-badge insight-neutral">⚪ F&#259;r&#259; semnale</span>'}</div>
            <div class="tag-bars">${barsHtml}</div>
            <div class="consultant-card-footer">
                <button class="detail-btn" onclick="openConsultantDetail(${c.IdConsultant}, '${safeName}')">
                    &#128269; Detalii feedback
                </button>
            </div>
        </div>`;
    }).join("");
}

async function openConsultantDetail(cid, name) {
    const modal = document.getElementById("aiDetailModal");
    const title = document.getElementById("aiModalTitle");
    const body = document.getElementById("aiModalBody");
    if (!modal) return;

    title.textContent = name;
    body.innerHTML = '<div class="ai-loading">&#9200; Se incarca...</div>';
    modal.style.display = "flex";

    try {
        const params = buildAiParams();
        params.set("consultant_id", cid);  // override with specific consultant
        const resp = await fetch(`/admin/api/feedback-analysis/consultant/${cid}?${params}`);
        const json = await resp.json();
        if (!json.success) throw new Error(json.error || "Eroare");

        const items = json.data || [];
        if (!items.length) {
            body.innerHTML = '<p style="color:#94a3b8;padding:1rem;">Niciun feedback g&#259;sit.</p>';
            return;
        }

        body.innerHTML = items.map(fb => {
            const tagsHtml = fb.tags.map(t =>
                `<span class="insight-badge insight-info" style="font-size:0.65rem">${t.label}</span>`
            ).join(" ");
            return `<div class="fb-item">
                <div class="fb-meta">
                    <span class="fb-status">${fb.FelStatus}</span>
                    <span class="fb-date">${fb.DataConectare}</span>
                    ${tagsHtml}
                </div>
                <div class="fb-text">${fb.Feedback}</div>
            </div>`;
        }).join("");
    } catch (e) {
        body.innerHTML = `<p style="color:#ef4444;padding:1rem;">Eroare: ${e.message}</p>`;
    }
}

function closeAiModal() {
    const modal = document.getElementById("aiDetailModal");
    if (modal) modal.style.display = "none";
}

// Called from consultant table rows: switch to AI tab and pre-select consultant
function analyzeConsultant(id, name) {
    switchToTab("analiza-ai");
    if (aiTree && id) {
        aiTree.setValue(id, name);
    }
    loadFeedbackAnalysis();
}

// ---- reloadAll ----
function reloadAll() {
    const icon = document.getElementById("refreshIcon");
    if (icon) icon.style.animation = "spin 0.8s linear infinite";
    Promise.all([
        loadKpis(),
        loadLeadsBySource(),
        loadFeedbackByStatus(),
        loadDosareByStatus(),
        loadDosareByBank(),
        loadTopConsultants(),
        loadMonthlyTrend(),
    ]).finally(() => {
        if (icon) icon.style.animation = "";
    });
}

// ---- Expose globals for onclick handlers in HTML ----
window.reloadAll = reloadAll;
window.loadFeedbackAnalysis = loadFeedbackAnalysis;
window.openConsultantDetail = openConsultantDetail;
window.closeAiModal = closeAiModal;
window.analyzeConsultant = analyzeConsultant;

// ---- Init ----
document.addEventListener("DOMContentLoaded", async () => {
    overlayManager.init();
    themeManager.init();
    initTabs();
    initDbSelector();
    initConsultantsSort();
    reloadAll();
    await initAiControls();

    // Reload consultant tree when DB changes
    document.getElementById("dbSelector")?.addEventListener("change", () => {
        loadConsultantTree();
    });
});
