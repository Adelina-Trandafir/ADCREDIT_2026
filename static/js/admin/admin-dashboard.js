/**
 * 🎛️ ADMIN DASHBOARD - MODULAR JAVASCRIPT
 * Organizat în clase și module pentru debugging ușor
 */

// ========== CONFIGURAȚIE GLOBALĂ ==========
const DASHBOARD_CONFIG = {
    refreshInterval: 30000, // 30 secunde
    toastDuration: 5000, // 5 secunde
    loadingDelay: 300, // 0.3 secunde
    endpoints: {
        stats: '/admin/api/stats',
        blockedAccounts: '/admin/api/blocked-accounts',
        unlockAccount: '/admin/api/unlock-account',
        unlockAll: '/admin/api/unlock-all',
        systemInfo: '/admin/api/system-info'
    },
    debug: true
};

// ========== UTILITY FUNCTIONS ==========
class Utils {
    static log(message, type = 'info', data = null) {
        if (!DASHBOARD_CONFIG.debug) return;
        
        const now = new Date();
const timestamp = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now.getMilliseconds().toString().padStart(3, '0')}`;
        const styles = {
            info: 'color: #3b82f6',
            success: 'color: #10b981',
            warning: 'color: #f59e0b',
            error: 'color: #ef4444'
        };
        
        console.log(`%c[${timestamp}] ${message}`, styles[type] || styles.info, data || '');
    }
    
    static formatTime(minutes) {
        if (minutes < 60) {
            return `${Math.round(minutes)} min`;
        }
        const hours = Math.floor(minutes / 60);
        const remainingMinutes = Math.round(minutes % 60);
        return `${hours}h ${remainingMinutes}m`;
    }
    
    static formatNumber(num) {
        return new Intl.NumberFormat('ro-RO').format(num);
    }
    
    static debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    static async sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// ========== API MANAGER ==========
class ApiManager {
    constructor() {
        this.cache = new Map();
        this.requestQueue = [];
        this.isProcessing = false;
    }
    
    async request(endpoint, options = {}) {
        const cacheKey = `${endpoint}_${JSON.stringify(options)}`;
        const cached = this.cache.get(cacheKey);
        
        // Return cached result if less than 10 seconds old
        if (cached && Date.now() - cached.timestamp < 10000) {
            Utils.log(`Cache hit for ${endpoint}`, 'info');
            return cached.data;
        }
        
        try {
            Utils.log(`API Request: ${endpoint}`, 'info', options);
            
            const response = await fetch(endpoint, {
                method: options.method || 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                    ...options.headers
                },
                body: options.body ? JSON.stringify(options.body) : undefined,
                credentials: 'same-origin'
            });
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const data = await response.json();
            
            // Cache successful responses
            if (data.success !== false) {
                this.cache.set(cacheKey, {
                    data,
                    timestamp: Date.now()
                });
            }
            
            Utils.log(`API Response: ${endpoint}`, 'success', data);
            return data;
            
        } catch (error) {
            Utils.log(`API Error: ${endpoint}`, 'error', error);
            throw error;
        }
    }
    
    clearCache() {
        this.cache.clear();
        Utils.log('API Cache cleared', 'info');
    }
}

// ========== TOAST NOTIFICATIONS ==========
class ToastManager {
    constructor() {
        this.container = document.getElementById('toastContainer');
        this.toasts = [];
    }
    
    show(message, type = 'info', duration = DASHBOARD_CONFIG.toastDuration) {
        const toast = this.createToast(message, type);
        this.container.appendChild(toast);
        this.toasts.push(toast);
        
        // Auto remove
        setTimeout(() => {
            this.remove(toast);
        }, duration);
        
        Utils.log(`Toast: ${message}`, type);
    }
    
    createToast(message, type) {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const icons = {
            success: '✅',
            error: '❌',
            warning: '⚠️',
            info: 'ℹ️'
        };
        
        toast.innerHTML = `
            <span class="toast-icon">${icons[type] || icons.info}</span>
            <span class="toast-message">${message}</span>
            <button class="toast-close" onclick="toastManager.remove(this.parentElement)">✕</button>
        `;
        
        return toast;
    }
    
    remove(toast) {
        if (toast && toast.parentElement) {
            toast.style.animation = 'toastSlideOut 0.3s ease-out';
            setTimeout(() => {
                toast.remove();
                this.toasts = this.toasts.filter(t => t !== toast);
            }, 300);
        }
    }
    
    clear() {
        this.toasts.forEach(toast => this.remove(toast));
    }
}

// ========== MODAL MANAGER ==========
class ModalManager {
    constructor() {
        this.overlay = document.getElementById('modalOverlay');
        this.title = document.getElementById('modalTitle');
        this.body = document.getElementById('modalBody');
        this.footer = document.getElementById('modalFooter');
        this.isOpen = false;
        
        // Close on escape
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.isOpen) {
                this.close();
            }
        });
    }
    
    show(title, body, footer = '') {
        this.title.textContent = title;
        this.body.innerHTML = body;
        this.footer.innerHTML = footer;
        this.overlay.classList.add('active');
        this.isOpen = true;
        
        // Focus management
        const firstButton = this.footer.querySelector('button');
        if (firstButton) {
            firstButton.focus();
        }
        
        Utils.log(`Modal opened: ${title}`, 'info');
    }
    
    close() {
        this.overlay.classList.remove('active');
        this.isOpen = false;
        Utils.log('Modal closed', 'info');
    }
    
    confirm(title, message, onConfirm, onCancel = null) {
        const footer = `
            <button class="header-btn" onclick="modalManager.close(); ${onCancel ? `(${onCancel})()` : ''}">
                Anulare
            </button>
            <button class="unlock-single-btn" onclick="modalManager.close(); (${onConfirm})()">
                Confirmare
            </button>
        `;
        
        this.show(title, `<p>${message}</p>`, footer);
    }
}

// ========== LOADING MANAGER ==========
class LoadingManager {
    constructor() {
        this.overlay = document.getElementById('loadingOverlay');
        this.text = this.overlay.querySelector('.loading-text');
        this.activeRequests = 0;
    }
    
    show(message = 'Se procesează...') {
        this.activeRequests++;
        this.text.textContent = message;
        this.overlay.classList.add('active');
        Utils.log(`Loading: ${message}`, 'info');
    }
    
    hide() {
        this.activeRequests = Math.max(0, this.activeRequests - 1);
        if (this.activeRequests === 0) {
            this.overlay.classList.remove('active');
            Utils.log('Loading hidden', 'info');
        }
    }
}

// ========== STATS MANAGER ==========
class StatsManager {
    constructor(apiManager) {
        this.api = apiManager;
        this.elements = {
            redisStatus: document.getElementById('redisStatus'),
            redisDetail: document.getElementById('redisDetail'),
            activeUsers: document.getElementById('activeUsers'),
            usersDetail: document.getElementById('usersDetail'),
            blockedCount: document.getElementById('blockedCount'),
            blockedDetail: document.getElementById('blockedDetail'),
            sessionDuration: document.getElementById('sessionDuration'),
            sessionDetail: document.getElementById('sessionDetail'),
            redisVersion: document.getElementById('redisVersion'),
            memoryUsed: document.getElementById('memoryUsed'),
            totalKeys: document.getElementById('totalKeys'),
            lastUpdate: document.getElementById('lastUpdate'),
            adminName: document.getElementById('adminName')
        };
    }
    
    async refresh() {
        try {
            Utils.log('Refreshing stats...', 'info');
            const data = await this.api.request(DASHBOARD_CONFIG.endpoints.stats);
            
            if (data.success) {
                this.updateStats(data.stats);
                this.updateSystemInfo(data.stats);
                Utils.log('Stats updated successfully', 'success');
            } else {
                throw new Error(data.error || 'Failed to load stats');
            }
        } catch (error) {
            Utils.log('Error refreshing stats', 'error', error);
            this.showError();
        }
    }
    
    updateStats(stats) {
        // Redis stats
        if (stats.redis && stats.redis.connected) {
            this.elements.redisStatus.textContent = 'Conectat';
            this.elements.redisStatus.style.color = 'var(--success-color)';
            this.elements.redisDetail.textContent = `v${stats.redis.version}`;
        } else {
            this.elements.redisStatus.textContent = 'Deconectat';
            this.elements.redisStatus.style.color = 'var(--error-color)';
            this.elements.redisDetail.textContent = 'Eroare conexiune';
        }
        
        // User stats
        if (stats.users && !stats.users.error) {
            this.elements.activeUsers.textContent = Utils.formatNumber(stats.users.total_active);
            this.elements.usersDetail.textContent = `din ${Utils.formatNumber(stats.users.total_all)} total`;
        } else {
            this.elements.activeUsers.textContent = 'Eroare';
            this.elements.usersDetail.textContent = 'Nu se poate încărca';
        }
        
        // Blocked accounts
        if (stats.redis && stats.redis.connected) {
            const totalBlocked = stats.redis.user_blocked_accounts + stats.redis.admin_blocked_accounts;
            this.elements.blockedCount.textContent = Utils.formatNumber(totalBlocked);
            this.elements.blockedDetail.textContent = `${stats.redis.user_blocked_accounts} utilizatori, ${stats.redis.admin_blocked_accounts} admin`;
        } else {
            this.elements.blockedCount.textContent = '-';
            this.elements.blockedDetail.textContent = 'Indisponibil';
        }
        
        // Admin session
        if (stats.admin) {
            this.elements.sessionDuration.textContent = Utils.formatTime(stats.admin.session_duration_minutes);
            this.elements.sessionDetail.textContent = 'minute active';
            if (stats.admin.current_admin) {
                this.elements.adminName.textContent = stats.admin.current_admin;
            }
        }
    }
    
    updateSystemInfo(stats) {
        this.elements.redisVersion.textContent = stats.redis?.version || 'N/A';
        this.elements.memoryUsed.textContent = stats.redis?.memory_used || 'N/A';
        this.elements.totalKeys.textContent = Utils.formatNumber(stats.redis?.total_keys || 0);
        this.elements.lastUpdate.textContent = new Date().toLocaleTimeString();
    }
    
    showError() {
        this.elements.redisStatus.textContent = 'Eroare';
        this.elements.redisStatus.style.color = 'var(--error-color)';
        this.elements.redisDetail.textContent = 'Nu se poate încărca';
        this.elements.lastUpdate.textContent = new Date().toLocaleTimeString();
    }
}

// ========== BLOCKED ACCOUNTS MANAGER ==========
class BlockedAccountsManager {
    constructor(apiManager, toastManager) {
        this.api = apiManager;
        this.toast = toastManager;
        this.container = document.getElementById('blockedAccountsList');
        this.accounts = [];
    }
    
    async refresh() {
        try {
            Utils.log('Refreshing blocked accounts...', 'info');
            this.showLoading();
            
            const data = await this.api.request(DASHBOARD_CONFIG.endpoints.blockedAccounts);
            
            if (data.success) {
                this.accounts = data.blocked_accounts;
                this.render();
                Utils.log(`Loaded ${this.accounts.length} blocked accounts`, 'success');
            } else {
                throw new Error(data.error || 'Failed to load blocked accounts');
            }
        } catch (error) {
            Utils.log('Error refreshing blocked accounts', 'error', error);
            this.showError();
        }
    }
    
    render() {
        if (this.accounts.length === 0) {
            this.showEmpty();
            return;
        }
        
        const html = this.accounts.map(account => this.createAccountHTML(account)).join('');
        this.container.innerHTML = html;
    }
    
    createAccountHTML(account) {
        const statusClass = account.status === 'blocked' ? 'status-blocked' : 'status-warning';
        const statusText = account.status === 'blocked' ? 'BLOCAT' : 'AVERTIZARE';
        const typeIcon = account.type === 'admin' ? '🛡️' : '👤';
        
        let timeInfo = '';
        if (account.status === 'blocked') {
            timeInfo = `Expiră în ${Utils.formatTime(account.remaining_minutes)}`;
        } else {
            timeInfo = `${account.attempts || 0} încercări eșuate`;
        }
        
        return `
            <div class="blocked-item" data-email="${account.email}" data-type="${account.type}">
                <div class="blocked-info">
                    <div class="blocked-email">
                        ${typeIcon} ${account.email}
                    </div>
                    <div class="blocked-details">
                        <span class="blocked-status ${statusClass}">${statusText}</span>
                        <span>${timeInfo}</span>
                        <span>Tip: ${account.type}</span>
                    </div>
                </div>
                <div class="blocked-actions">
                    <button class="unlock-single-btn" onclick="blockedAccountsManager.unlockAccount('${account.email}', '${account.type}')">
                        🔓 Deblocare
                    </button>
                </div>
            </div>
        `;
    }
    
    showLoading() {
        this.container.innerHTML = `
            <div class="loading-state">
                <span class="loading-spinner">⏳</span>
                Încărcare conturi blocate...
            </div>
        `;
    }
    
    showEmpty() {
        this.container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">🎉</div>
                <div>Nu există conturi blocate!</div>
                <small>Toate conturile sunt funcționale.</small>
            </div>
        `;
    }
    
    showError() {
        this.container.innerHTML = `
            <div class="loading-state">
                <span style="color: var(--error-color);">❌</span>
                Eroare la încărcarea conturilor blocate
            </div>
        `;
    }
    
    async unlockAccount(email, type) {
        try {
            Utils.log(`Unlocking account: ${email} (${type})`, 'info');
            
            const data = await this.api.request(DASHBOARD_CONFIG.endpoints.unlockAccount, {
                method: 'POST',
                body: { email, type }
            });
            
            if (data.success) {
                this.toast.show(data.message, 'success');
                await this.refresh(); // Refresh list
                statsManager.refresh(); // Refresh stats
                Utils.log(`Account unlocked successfully: ${email}`, 'success');
            } else {
                throw new Error(data.message || 'Failed to unlock account');
            }
        } catch (error) {
            Utils.log(`Error unlocking account: ${email}`, 'error', error);
            this.toast.show(`Eroare la deblocarea contului: ${error.message}`, 'error');
        }
    }
}

// ========== THEME MANAGER ==========
class ThemeManager {
    constructor() {
        this.theme = localStorage.getItem('admin-theme') || 'light';
        this.icon = document.getElementById('themeIcon');
        this.applyTheme();
    }
    
    toggle() {
        this.theme = this.theme === 'light' ? 'dark' : 'light';
        this.applyTheme();
        localStorage.setItem('admin-theme', this.theme);
        Utils.log(`Theme changed to: ${this.theme}`, 'info');
    }
    
    applyTheme() {
        document.documentElement.setAttribute('data-theme', this.theme);
        this.icon.textContent = this.theme === 'light' ? '🌙' : '☀️';
    }
}

// ========== MAIN DASHBOARD CLASS ==========
class AdminDashboard {
    constructor() {
        this.initializeManagers();
        this.setupEventListeners();
        this.startAutoRefresh();
        this.initialLoad();
        
        Utils.log('Admin Dashboard initialized', 'success');
    }
    
    initializeManagers() {
        // Initialize all managers
        window.apiManager = new ApiManager();
        window.toastManager = new ToastManager();
        window.modalManager = new ModalManager();
        window.loadingManager = new LoadingManager();
        window.statsManager = new StatsManager(apiManager);
        window.blockedAccountsManager = new BlockedAccountsManager(apiManager, toastManager);
        window.themeManager = new ThemeManager();
    }
    
    setupEventListeners() {
        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey || e.metaKey) {
                switch (e.key) {
                    case 'r':
                        e.preventDefault();
                        this.refresh();
                        break;
                    case 'u':
                        e.preventDefault();
                        openUnlockPage();
                        break;
                }
            }
        });
        
        // Page visibility change
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden) {
                this.refresh();
            }
        });
    }
    
    startAutoRefresh() {
        setInterval(() => {
            if (!document.hidden) {
                this.refresh();
            }
        }, DASHBOARD_CONFIG.refreshInterval);
        
        Utils.log(`Auto-refresh started (${DASHBOARD_CONFIG.refreshInterval/1000}s)`, 'info');
    }
    
    async initialLoad() {
        try {
            await this.refresh();
        } catch (error) {
            Utils.log('Initial load failed', 'error', error);
            toastManager.show('Eroare la încărcarea inițială', 'error');
        }
    }
    
    async refresh() {
        try {
            // Refresh all data
            await Promise.all([
                statsManager.refresh(),
                blockedAccountsManager.refresh()
            ]);
            
            // Update refresh icon
            const refreshIcon = document.getElementById('refreshIcon');
            refreshIcon.style.animation = 'spin 1s linear';
            setTimeout(() => {
                refreshIcon.style.animation = '';
            }, 1000);
            
        } catch (error) {
            Utils.log('Refresh failed', 'error', error);
        }
    }
}

// ========== GLOBAL FUNCTIONS (for onclick handlers) ==========
function refreshDashboard() {
    dashboard.refresh();
}

function toggleTheme() {
    themeManager.toggle();
}

function openUnlockPage() {
    window.location.href = '/admin/unlock';
}

function showDetailedStats() {
    modalManager.show(
        '📈 Statistici Detaliate',
        `
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Conturi Active:</span>
                    <span class="info-value">${document.getElementById('activeUsers').textContent}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Conturi Blocate:</span>
                    <span class="info-value">${document.getElementById('blockedCount').textContent}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Memorie Redis:</span>
                    <span class="info-value">${document.getElementById('memoryUsed').textContent}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Total Chei:</span>
                    <span class="info-value">${document.getElementById('totalKeys').textContent}</span>
                </div>
            </div>
        `,
        '<button class="header-btn" onclick="modalManager.close()">Închide</button>'
    );
}

function showSystemLogs() {
    modalManager.show(
        '📋 Jurnale Sistem',
        `
            <div style="background: var(--bg-tertiary); padding: 15px; border-radius: 8px; font-family: monospace; font-size: 0.9rem;">
                <div>🔍 Verificare sistem în curs...</div>
                <div>⏱️ Ultima actualizare: ${new Date().toLocaleString()}</div>
                <div>🛡️ Admin activ: ${document.getElementById('adminName').textContent}</div>
                <div>📊 Redis: ${document.getElementById('redisStatus').textContent}</div>
                <div>🔄 Auto-refresh: ${DASHBOARD_CONFIG.refreshInterval/1000}s</div>
            </div>
        `,
        '<button class="header-btn" onclick="modalManager.close()">Închide</button>'
    );
}

function emergencyUnlockAll() {
    modalManager.confirm(
        '🚨 Deblocare Urgență',
        'Această acțiune va debloca TOATE conturile blocate (utilizatori și admin). Continuați?',
        async () => {
            try {
                loadingManager.show('Deblocare în curs...');
                
                const data = await apiManager.request(DASHBOARD_CONFIG.endpoints.unlockAll, {
                    method: 'POST',
                    body: { type: 'all' }
                });
                
                if (data.success) {
                    toastManager.show(data.message, 'success');
                    dashboard.refresh();
                    Utils.log('Emergency unlock completed', 'success');
                } else {
                    throw new Error(data.error || 'Failed to unlock all accounts');
                }
            } catch (error) {
                Utils.log('Emergency unlock failed', 'error', error);
                toastManager.show(`Eroare: ${error.message}`, 'error');
            } finally {
                loadingManager.hide();
            }
        }
    );
}

function refreshBlockedAccounts() {
    blockedAccountsManager.refresh();
}

function closeModal() {
    modalManager.close();
}

// ========== INITIALIZATION ==========
document.addEventListener('DOMContentLoaded', () => {
    // Initialize dashboard
    window.dashboard = new AdminDashboard();
    
    // Add CSS for animations
    const style = document.createElement('style');
    style.textContent = `
        @keyframes toastSlideOut {
            from {
                opacity: 1;
                transform: translateX(0);
            }
            to {
                opacity: 0;
                transform: translateX(100%);
            }
        }
        
        .loading-spinner {
            animation: spin 1s linear infinite;
        }
    `;
    document.head.appendChild(style);
    
    Utils.log('🎛️ Admin Dashboard loaded successfully', 'success');
});

// ========== ERROR HANDLING ==========
window.addEventListener('error', (e) => {
    Utils.log('Global error caught', 'error', e.error);
    if (window.toastManager) {
        toastManager.show('A apărut o eroare neașteptată', 'error');
    }
});

window.addEventListener('unhandledrejection', (e) => {
    Utils.log('Unhandled promise rejection', 'error', e.reason);
    if (window.toastManager) {
        toastManager.show('Eroare de procesare', 'error');
    }
});