/**
 * 🔓 ADMIN UNLOCK - SPECIALIZED ACCOUNT MANAGEMENT
 * Modular JavaScript pentru gestionarea avansată a conturilor blocate
 */

// ========== CONFIGURAȚIE ==========
const UNLOCK_CONFIG = {
    refreshInterval: 15000, // 15 secunde
    toastDuration: 4000,
    endpoints: {
        blockedAccounts: '/admin/api/blocked-accounts',
        unlockAccount: '/admin/api/unlock-account',
        unlockAll: '/admin/api/unlock-all',
        stats: '/admin/api/stats'
    },
    debug: true
};

// ========== UTILITIES ==========
class UnlockUtils {
    static log(message, type = 'info', data = null) {
        if (!UNLOCK_CONFIG.debug) return;
        
        const now = new Date();
const timestamp = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now.getMilliseconds().toString().padStart(3, '0')}`;
        const styles = {
            info: 'color: #3b82f6',
            success: 'color: #10b981',
            warning: 'color: #f59e0b',
            error: 'color: #ef4444'
        };
        
    let CPN ='UNLOCK';
        console.log(`%c[${timestamp}] [${CPN.padEnd(15)}] ${message}`, styles[type] || styles.info, data || '');
    }
    
    static formatTimeRemaining(minutes) {
        if (minutes < 1) return 'Sub 1 minut';
        if (minutes < 60) return `${Math.round(minutes)} min`;
        
        const hours = Math.floor(minutes / 60);
        const remainingMinutes = Math.round(minutes % 60);
        return `${hours}h ${remainingMinutes}m`;
    }
    
    static getTypeIcon(type) {
        return type === 'admin' ? '🛡️' : '👤';
    }
    
    static getStatusColor(status) {
        return status === 'blocked' ? 'status-blocked' : 'status-warning';
    }
    
    static sanitizeEmail(email) {
        return email.replace(/[<>]/g, '');
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
}

// ========== TOAST MANAGER ==========
class UnlockToastManager {
    constructor() {
        this.container = document.getElementById('toastContainer');
        this.toasts = [];
    }
    
    show(message, type = 'info', duration = UNLOCK_CONFIG.toastDuration) {
        const toast = this.createToast(message, type);
        this.container.appendChild(toast);
        this.toasts.push(toast);
        
        setTimeout(() => {
            this.remove(toast);
        }, duration);
        
        UnlockUtils.log(`Toast: ${message}`, type);
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
            <button class="toast-close" onclick="unlockToast.remove(this.parentElement)">✕</button>
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

// ========== API MANAGER ==========
class UnlockApiManager {
    constructor() {
        this.cache = new Map();
        this.requestCount = 0;
    }
    
    async request(endpoint, options = {}) {
        this.requestCount++;
        
        try {
            UnlockUtils.log(`API Request #${this.requestCount}: ${endpoint}`, 'info', options);
            
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
            UnlockUtils.log(`API Response #${this.requestCount}: ${endpoint}`, 'success', data);
            return data;
            
        } catch (error) {
            UnlockUtils.log(`API Error #${this.requestCount}: ${endpoint}`, 'error', error);
            throw error;
        }
    }
    
    clearCache() {
        this.cache.clear();
        UnlockUtils.log('API Cache cleared', 'info');
    }
}

// ========== LOADING MANAGER ==========
class UnlockLoadingManager {
    constructor() {
        this.overlay = document.getElementById('loadingOverlay');
        this.text = this.overlay.querySelector('.loading-text');
        this.activeOperations = 0;
    }
    
    show(message = 'Se procesează...') {
        this.activeOperations++;
        this.text.textContent = message;
        this.overlay.classList.add('active');
        UnlockUtils.log(`Loading: ${message}`, 'info');
    }
    
    hide() {
        this.activeOperations = Math.max(0, this.activeOperations - 1);
        if (this.activeOperations === 0) {
            this.overlay.classList.remove('active');
            UnlockUtils.log('Loading hidden', 'info');
        }
    }
    
    isVisible() {
        return this.overlay.classList.contains('active');
    }
}

// ========== CONFIRM MODAL MANAGER ==========
class UnlockConfirmManager {
    constructor() {
        this.modal = document.getElementById('confirmModal');
        this.title = document.getElementById('confirmTitle');
        this.message = document.getElementById('confirmMessage');
        this.details = document.getElementById('confirmDetails');
        this.confirmBtn = document.getElementById('confirmButton');
        this.onConfirm = null;
        this.isOpen = false;
        
        // Keyboard support
        document.addEventListener('keydown', (e) => {
            if (this.isOpen) {
                if (e.key === 'Escape') {
                    this.close();
                } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
                    this.executeConfirm();
                }
            }
        });
    }
    
    show(title, message, details = '', onConfirm = null) {
        this.title.textContent = title;
        this.message.textContent = message;
        this.details.innerHTML = details;
        this.onConfirm = onConfirm;
        this.modal.classList.add('active');
        this.isOpen = true;
        
        // Focus on confirm button
        this.confirmBtn.focus();
        
        UnlockUtils.log(`Confirm modal opened: ${title}`, 'info');
    }
    
    close() {
        this.modal.classList.remove('active');
        this.isOpen = false;
        this.onConfirm = null;
        UnlockUtils.log('Confirm modal closed', 'info');
    }
    
    executeConfirm() {
        if (this.onConfirm) {
            this.onConfirm();
        }
        this.close();
    }
}

// ========== STATS MANAGER ==========
class UnlockStatsManager {
    constructor(apiManager) {
        this.api = apiManager;
        this.elements = {
            totalBlocked: document.getElementById('totalBlocked'),
            usersBlocked: document.getElementById('usersBlocked'),
            adminBlocked: document.getElementById('adminBlocked'),
            warningsCount: document.getElementById('warningsCount'),
            adminName: document.getElementById('adminName')
        };
    }
    
    async refresh() {
        try {
            const data = await this.api.request(UNLOCK_CONFIG.endpoints.stats);
            
            if (data.success && data.stats) {
                this.updateStats(data.stats);
            }
        } catch (error) {
            UnlockUtils.log('Error refreshing stats', 'error', error);
        }
    }
    
    updateStats(stats) {
        if (stats.redis && stats.redis.connected) {
            const userBlocked = stats.redis.user_blocked_accounts || 0;
            const adminBlocked = stats.redis.admin_blocked_accounts || 0;
            const userAttempts = stats.redis.user_failed_attempts || 0;
            const adminAttempts = stats.redis.admin_failed_attempts || 0;
            
            this.elements.totalBlocked.textContent = userBlocked + adminBlocked;
            this.elements.usersBlocked.textContent = userBlocked;
            this.elements.adminBlocked.textContent = adminBlocked;
            this.elements.warningsCount.textContent = userAttempts + adminAttempts;
        }
        
        if (stats.admin && stats.admin.current_admin) {
            this.elements.adminName.textContent = stats.admin.current_admin;
        }
    }
}

// ========== ACCOUNTS MANAGER ==========
class UnlockAccountsManager {
    constructor(apiManager, toastManager) {
        this.api = apiManager;
        this.toast = toastManager;
        this.accounts = [];
        this.filteredAccounts = [];
        this.selectedAccounts = new Set();
        
        this.elements = {
            list: document.getElementById('accountsList'),
            count: document.getElementById('accountsCount'),
            unlockSelectedBtn: document.querySelector('.unlock-selected-btn')
        };
        
        this.filters = {
            type: '',
            status: '',
            email: '',
            sortBy: 'email'
        };
    }
    
    async refresh() {
        try {
            UnlockUtils.log('Refreshing accounts list...', 'info');
            this.showLoading();
            
            const data = await this.api.request(UNLOCK_CONFIG.endpoints.blockedAccounts);
            
            if (data.success) {
                this.accounts = data.blocked_accounts || [];
                this.applyFilters();
                UnlockUtils.log(`Loaded ${this.accounts.length} accounts`, 'success');
            } else {
                throw new Error(data.error || 'Failed to load accounts');
            }
        } catch (error) {
            UnlockUtils.log('Error refreshing accounts', 'error', error);
            this.showError('Eroare la încărcarea conturilor');
        }
    }
    
    applyFilters() {
        let filtered = [...this.accounts];
        
        // Apply filters
        if (this.filters.type) {
            filtered = filtered.filter(account => account.type === this.filters.type);
        }
        
        if (this.filters.status) {
            filtered = filtered.filter(account => account.status === this.filters.status);
        }
        
        if (this.filters.email) {
            const searchTerm = this.filters.email.toLowerCase();
            filtered = filtered.filter(account => 
                account.email.toLowerCase().includes(searchTerm)
            );
        }
        
        // Apply sorting
        filtered.sort((a, b) => {
            switch (this.filters.sortBy) {
                case 'email':
                    return a.email.localeCompare(b.email);
                case 'time':
                    return (a.remaining_minutes || 0) - (b.remaining_minutes || 0);
                case 'type':
                    return a.type.localeCompare(b.type);
                case 'status':
                    return a.status.localeCompare(b.status);
                default:
                    return 0;
            }
        });
        
        this.filteredAccounts = filtered;
        this.render();
        this.updateCount();
        
        UnlockUtils.log(`Applied filters: ${filtered.length}/${this.accounts.length} accounts`, 'info');
    }
    
    render() {
        if (this.filteredAccounts.length === 0) {
            this.showEmpty();
            return;
        }
        
        const html = this.filteredAccounts.map(account => this.createAccountHTML(account)).join('');
        this.elements.list.innerHTML = html;
        
        // Restore selections
        this.selectedAccounts.forEach(email => {
            const checkbox = document.querySelector(`[data-email="${email}"] .account-checkbox`);
            if (checkbox) {
                checkbox.checked = true;
                checkbox.closest('.account-item').classList.add('selected');
            }
        });
        
        this.updateSelectedButton();
    }
    
    createAccountHTML(account) {
        const statusClass = UnlockUtils.getStatusColor(account.status);
        const typeIcon = UnlockUtils.getTypeIcon(account.type);
        const statusText = account.status === 'blocked' ? 'BLOCAT' : 'AVERTIZARE';
        
        let timeInfo = '';
        if (account.status === 'blocked') {
            timeInfo = `Expiră în ${UnlockUtils.formatTimeRemaining(account.remaining_minutes)}`;
        } else {
            timeInfo = `${account.attempts || 0} încercări eșuate`;
        }
        
        return `
            <div class="account-item" data-email="${account.email}" data-type="${account.type}">
                <input type="checkbox" class="account-checkbox" 
                       onchange="unlockAccounts.toggleSelection('${account.email}')">
                
                <div class="account-info">
                    <div class="account-email">
                        <span class="account-type-icon">${typeIcon}</span>
                        ${UnlockUtils.sanitizeEmail(account.email)}
                    </div>
                    <div class="account-details">
                        <span class="account-status ${statusClass}">${statusText}</span>
                        <span>${timeInfo}</span>
                        <span>Tip: ${account.type}</span>
                    </div>
                </div>
                
                <div class="account-actions">
                    <button class="unlock-btn" onclick="unlockAccounts.unlockSingle('${account.email}', '${account.type}')">
                        🔓 Deblocare
                    </button>
                </div>
            </div>
        `;
    }
    
    showLoading() {
        this.elements.list.innerHTML = `
            <div class="loading-state">
                <span class="loading-spinner">⏳</span>
                <span>Încărcare conturi...</span>
            </div>
        `;
    }
    
    showEmpty() {
        const message = this.accounts.length === 0 
            ? 'Nu există conturi blocate! 🎉' 
            : 'Niciun cont nu se potrivește filtrelor aplicate.';
            
        this.elements.list.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">🔍</div>
                <div>${message}</div>
            </div>
        `;
    }
    
    showError(message) {
        this.elements.list.innerHTML = `
            <div class="loading-state">
                <span style="color: var(--error-color);">❌</span>
                <span>${message}</span>
            </div>
        `;
    }
    
    updateCount() {
        this.elements.count.textContent = `(${this.filteredAccounts.length})`;
    }
    
    toggleSelection(email) {
        const checkbox = document.querySelector(`[data-email="${email}"] .account-checkbox`);
        const item = checkbox.closest('.account-item');
        
        if (checkbox.checked) {
            this.selectedAccounts.add(email);
            item.classList.add('selected');
        } else {
            this.selectedAccounts.delete(email);
            item.classList.remove('selected');
        }
        
        this.updateSelectedButton();
        UnlockUtils.log(`Selection toggled: ${email} (${this.selectedAccounts.size} selected)`, 'info');
    }
    
    selectAll() {
        this.selectedAccounts.clear();
        this.filteredAccounts.forEach(account => {
            this.selectedAccounts.add(account.email);
        });
        this.render();
        UnlockUtils.log(`Selected all: ${this.selectedAccounts.size} accounts`, 'info');
    }
    
    deselectAll() {
        this.selectedAccounts.clear();
        this.render();
        UnlockUtils.log('Deselected all accounts', 'info');
    }
    
    updateSelectedButton() {
        const count = this.selectedAccounts.size;
        this.elements.unlockSelectedBtn.disabled = count === 0;
        this.elements.unlockSelectedBtn.innerHTML = `
            <span>🔓</span> Deblocare Selectate (${count})
        `;
    }
    
    async unlockSingle(email, type) {
        try {
            UnlockUtils.log(`Unlocking single account: ${email} (${type})`, 'info');
            
            const data = await this.api.request(UNLOCK_CONFIG.endpoints.unlockAccount, {
                method: 'POST',
                body: { email, type }
            });
            
            if (data.success) {
                this.toast.show(data.message, 'success');
                activityLogger.log(`Deblocat: ${email} (${type})`, 'success');
                await this.refresh();
                statsManager.refresh();
            } else {
                throw new Error(data.message || 'Failed to unlock account');
            }
        } catch (error) {
            UnlockUtils.log(`Error unlocking account: ${email}`, 'error', error);
            this.toast.show(`Eroare la deblocarea contului: ${error.message}`, 'error');
             activityLogger.log(`EROARE la deblocarea ${email}: ${error.message}`, 'error');
       }
   }
   
   async unlockSelected() {
       if (this.selectedAccounts.size === 0) return;
       
       const selectedList = Array.from(this.selectedAccounts);
       const accountsInfo = selectedList.map(email => {
           const account = this.accounts.find(acc => acc.email === email);
           return `${UnlockUtils.getTypeIcon(account.type)} ${email}`;
       }).join('<br>');
       
       confirmManager.show(
           '🔓 Deblocare Conturi Selectate',
           `Confirmați deblocarea a ${selectedList.length} conturi selectate?`,
           `<ul>${selectedList.map(email => `<li>${email}</li>`).join('')}</ul>`,
           async () => {
               try {
                   loadingManager.show(`Deblocare ${selectedList.length} conturi...`);
                   
                   let successCount = 0;
                   let errorCount = 0;
                   
                   for (const email of selectedList) {
                       try {
                           const account = this.accounts.find(acc => acc.email === email);
                           const data = await this.api.request(UNLOCK_CONFIG.endpoints.unlockAccount, {
                               method: 'POST',
                               body: { email, type: account.type }
                           });
                           
                           if (data.success) {
                               successCount++;
                               activityLogger.log(`Deblocat: ${email} (${account.type})`, 'success');
                           } else {
                               errorCount++;
                               activityLogger.log(`EROARE la deblocarea ${email}: ${data.message}`, 'error');
                           }
                       } catch (error) {
                           errorCount++;
                           activityLogger.log(`EROARE la deblocarea ${email}: ${error.message}`, 'error');
                       }
                   }
                   
                   // Show results
                   if (successCount > 0) {
                       this.toast.show(`${successCount} conturi deblocate cu succes!`, 'success');
                   }
                   if (errorCount > 0) {
                       this.toast.show(`${errorCount} conturi nu au putut fi deblocate`, 'error');
                   }
                   
                   // Clear selections and refresh
                   this.selectedAccounts.clear();
                   await this.refresh();
                   statsManager.refresh();
                   
               } catch (error) {
                   UnlockUtils.log('Error in bulk unlock', 'error', error);
                   this.toast.show('Eroare la deblocarea în masă', 'error');
               } finally {
                   loadingManager.hide();
               }
           }
       );
   }
   
   setFilter(key, value) {
       this.filters[key] = value;
       this.applyFilters();
       UnlockUtils.log(`Filter applied: ${key} = ${value}`, 'info');
   }
   
   clearFilters() {
       this.filters = {
           type: '',
           status: '',
           email: '',
           sortBy: 'email'
       };
       
       // Reset UI
       document.getElementById('typeFilter').value = '';
       document.getElementById('statusFilter').value = '';
       document.getElementById('searchEmail').value = '';
       document.getElementById('sortBy').value = 'email';
       
       this.applyFilters();
       UnlockUtils.log('Filters cleared', 'info');
   }
}

// ========== ACTIVITY LOGGER ==========
class ActivityLogger {
   constructor() {
       this.container = document.getElementById('activityLog');
       this.maxEntries = 50;
   }
   
   log(message, type = 'info') {
       const time = new Date().toLocaleTimeString();
       const entry = document.createElement('div');
       entry.className = `activity-item activity-${type}`;
       
       entry.innerHTML = `
           <span class="activity-time">${time}</span>
           <span class="activity-message">${message}</span>
       `;
       
       // Add to top
       this.container.insertBefore(entry, this.container.firstChild);
       
       // Remove old entries
       while (this.container.children.length > this.maxEntries) {
           this.container.removeChild(this.container.lastChild);
       }
       
       // Scroll to top
       this.container.scrollTop = 0;
       
       UnlockUtils.log(`Activity logged: ${message}`, type);
   }
   
   clear() {
       this.container.innerHTML = `
           <div class="activity-item">
               <span class="activity-time">Gata</span>
               <span class="activity-message">Jurnal șters</span>
           </div>
       `;
       UnlockUtils.log('Activity log cleared', 'info');
   }
}

// ========== MANUAL UNLOCK MANAGER ==========
class ManualUnlockManager {
   constructor(apiManager, toastManager) {
       this.api = apiManager;
       this.toast = toastManager;
       
       this.elements = {
           email: document.getElementById('manualEmail'),
           type: document.getElementById('manualType')
       };
       
       // Enter key support
       this.elements.email.addEventListener('keydown', (e) => {
           if (e.key === 'Enter') {
               this.unlock();
           }
       });
   }
   
   async unlock() {
       const email = this.elements.email.value.trim();
       const type = this.elements.type.value;
       
       if (!email) {
           this.toast.show('Introduceți email-ul pentru deblocare!', 'warning');
           this.elements.email.focus();
           return;
       }
       
       if (!this.isValidEmail(email)) {
           this.toast.show('Format email invalid!', 'error');
           this.elements.email.focus();
           return;
       }
       
       try {
           UnlockUtils.log(`Manual unlock: ${email} (${type})`, 'info');
           
           const data = await this.api.request(UNLOCK_CONFIG.endpoints.unlockAccount, {
               method: 'POST',
               body: { email, type }
           });
           
           if (data.success) {
               this.toast.show(data.message, 'success');
               activityLogger.log(`Deblocare manuală: ${email} (${type})`, 'success');
               
               // Clear form
               this.elements.email.value = '';
               
               // Refresh data
               unlockAccounts.refresh();
               statsManager.refresh();
               
           } else {
               throw new Error(data.message || 'Failed to unlock account');
           }
       } catch (error) {
           UnlockUtils.log(`Error in manual unlock: ${email}`, 'error', error);
           this.toast.show(`Eroare: ${error.message}`, 'error');
           activityLogger.log(`EROARE deblocare manuală ${email}: ${error.message}`, 'error');
       }
   }
   
   isValidEmail(email) {
       return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
   }
}

// ========== EMERGENCY UNLOCK MANAGER ==========
class EmergencyUnlockManager {
   constructor(apiManager, toastManager) {
       this.api = apiManager;
       this.toast = toastManager;
   }
   
   async unlock(type) {
       const typeNames = {
           'user': 'utilizatori',
           'admin': 'administratori',
           'all': 'toate conturile'
       };
       
       const typeName = typeNames[type] || type;
       
       confirmManager.show(
           '🚨 Deblocare Urgență',
           `ATENȚIE! Această acțiune va debloca ${typeName} blocate.`,
           `
               <div style="background: var(--bg-danger); padding: 15px; border-radius: 8px; margin: 10px 0;">
                   <strong>⚠️ Avertizare:</strong> Această acțiune nu poate fi anulată!
               </div>
               <div>Tip deblocare: <strong>${typeName.toUpperCase()}</strong></div>
               <div>Data și ora: <strong>${new Date().toLocaleString()}</strong></div>
           `,
           async () => {
               try {
                   loadingManager.show('Deblocare urgență în curs...');
                   
                   const data = await this.api.request(UNLOCK_CONFIG.endpoints.unlockAll, {
                       method: 'POST',
                       body: { type }
                   });
                   
                   if (data.success) {
                       this.toast.show(data.message, 'success');
                       activityLogger.log(`DEBLOCARE URGENȚĂ: ${typeName} (${data.unlocked_keys} chei)`, 'success');
                       
                       // Refresh all data
                       unlockAccounts.refresh();
                       statsManager.refresh();
                       
                   } else {
                       throw new Error(data.error || 'Failed to unlock all accounts');
                   }
               } catch (error) {
                   UnlockUtils.log(`Error in emergency unlock: ${type}`, 'error', error);
                   this.toast.show(`Eroare la deblocarea de urgență: ${error.message}`, 'error');
                   activityLogger.log(`EROARE deblocare urgență ${typeName}: ${error.message}`, 'error');
               } finally {
                   loadingManager.hide();
               }
           }
       );
   }
}

// ========== MAIN UNLOCK APPLICATION ==========
class UnlockApp {
   constructor() {
       this.initializeManagers();
       this.setupEventListeners();
       this.startAutoRefresh();
       this.initialLoad();
       
       UnlockUtils.log('🔓 Unlock App initialized successfully', 'success');
   }
   
   initializeManagers() {
       // Initialize all managers
       window.unlockToast = new UnlockToastManager();
       window.unlockApi = new UnlockApiManager();
       window.loadingManager = new UnlockLoadingManager();
       window.confirmManager = new UnlockConfirmManager();
       window.statsManager = new UnlockStatsManager(unlockApi);
       window.unlockAccounts = new UnlockAccountsManager(unlockApi, unlockToast);
       window.activityLogger = new ActivityLogger();
       window.manualUnlock = new ManualUnlockManager(unlockApi, unlockToast);
       window.emergencyUnlock = new EmergencyUnlockManager(unlockApi, unlockToast);
   }
   
   setupEventListeners() {
       // Keyboard shortcuts
       document.addEventListener('keydown', (e) => {
           if (e.ctrlKey || e.metaKey) {
               switch (e.key) {
                   case 'r':
                       e.preventDefault();
                       this.refreshAll();
                       break;
                   case 'f':
                       e.preventDefault();
                       document.getElementById('searchEmail').focus();
                       break;
                   case 'a':
                       e.preventDefault();
                       unlockAccounts.selectAll();
                       break;
                   case 'd':
                       e.preventDefault();
                       unlockAccounts.deselectAll();
                       break;
               }
           }
       });
       
       // Page visibility change
       document.addEventListener('visibilitychange', () => {
           if (!document.hidden) {
               this.refreshAll();
           }
       });
       
       // Filter change handlers
       document.getElementById('typeFilter').addEventListener('change', (e) => {
           unlockAccounts.setFilter('type', e.target.value);
       });
       
       document.getElementById('statusFilter').addEventListener('change', (e) => {
           unlockAccounts.setFilter('status', e.target.value);
       });
       
       document.getElementById('searchEmail').addEventListener('input', 
           UnlockUtils.debounce((e) => {
               unlockAccounts.setFilter('email', e.target.value);
           }, 300)
       );
       
       document.getElementById('sortBy').addEventListener('change', (e) => {
           unlockAccounts.setFilter('sortBy', e.target.value);
       });
   }
   
   startAutoRefresh() {
       setInterval(() => {
           if (!document.hidden && !loadingManager.isVisible()) {
               this.refreshAll();
           }
       }, UNLOCK_CONFIG.refreshInterval);
       
       UnlockUtils.log(`Auto-refresh started (${UNLOCK_CONFIG.refreshInterval/1000}s)`, 'info');
   }
   
   async initialLoad() {
       try {
           await this.refreshAll();
           activityLogger.log('Sistem de deblocare inițializat și gata de utilizare', 'success');
       } catch (error) {
           UnlockUtils.log('Initial load failed', 'error', error);
           unlockToast.show('Eroare la încărcarea inițială', 'error');
       }
   }
   
   async refreshAll() {
       try {
           // Update refresh icon
           const refreshIcon = document.getElementById('refreshIcon');
           refreshIcon.style.animation = 'spin 1s linear';
           
           // Refresh all data
           await Promise.all([
               statsManager.refresh(),
               unlockAccounts.refresh()
           ]);
           
           // Reset refresh icon
           setTimeout(() => {
               refreshIcon.style.animation = '';
           }, 1000);
           
           UnlockUtils.log('Full refresh completed', 'success');
           
       } catch (error) {
           UnlockUtils.log('Refresh failed', 'error', error);
       }
   }
}

// ========== GLOBAL FUNCTIONS (for onclick handlers) ==========
function refreshAll() {
   unlockApp.refreshAll();
}

function emergencyUnlock(type) {
   emergencyUnlock.unlock(type);
}

function manualUnlock() {
   manualUnlock.unlock();
}

function selectAll() {
   unlockAccounts.selectAll();
}

function deselectAll() {
   unlockAccounts.deselectAll();
}

function unlockSelected() {
   unlockAccounts.unlockSelected();
}

function applyFilters() {
   // Filters are applied automatically through event listeners
}

function clearFilters() {
   unlockAccounts.clearFilters();
}

function clearActivityLog() {
   activityLogger.clear();
}

function closeConfirmModal() {
   confirmManager.close();
}

function executeConfirm() {
   confirmManager.executeConfirm();
}

// ========== INITIALIZATION ==========
document.addEventListener('DOMContentLoaded', () => {
   // Initialize the unlock application
   window.unlockApp = new UnlockApp();
   
   // Add additional CSS for animations
   const style = document.createElement('style');
   style.textContent = `
       @keyframes spin {
           from { transform: rotate(0deg); }
           to { transform: rotate(360deg); }
       }
       
       .account-item.selected {
           animation: selectedPulse 0.3s ease-out;
       }
       
       @keyframes selectedPulse {
           0% { background: var(--bg-secondary); }
           50% { background: var(--bg-success); }
           100% { background: var(--bg-success); }
       }
   `;
   document.head.appendChild(style);
   
   UnlockUtils.log('🔓 Admin Unlock System loaded successfully', 'success');
});

// ========== ERROR HANDLING ==========
window.addEventListener('error', (e) => {
   UnlockUtils.log('Global error caught', 'error', e.error);
   if (window.unlockToast) {
       unlockToast.show('A apărut o eroare neașteptată', 'error');
   }
});

window.addEventListener('unhandledrejection', (e) => {
   UnlockUtils.log('Unhandled promise rejection', 'error', e.reason);
   if (window.unlockToast) {
       unlockToast.show('Eroare de procesare', 'error');
   }
});

// ========== EXPORT FOR TESTING ==========
if (typeof module !== 'undefined' && module.exports) {
   module.exports = {
       UnlockUtils,
       UnlockApp,
       UNLOCK_CONFIG
   };
}