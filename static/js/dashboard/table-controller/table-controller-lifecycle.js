// File: static/js/table-controller/table-controller-lifecycle.js
/**
 * 🔄 TABLE CONTROLLER LIFECYCLE MIXIN
 * Gestionează ciclul de viață al controller-ului
 *
 * RESPONSABILITĂȚI:
 * ✅ Container resize observer
 * ✅ Setup și cleanup
 * ✅ Performance tracking
 *
 * @version 1.0.0
 */

export const tableControllerLifecycleMixin = {
  /**
   * 🔍 SETUP CONTAINER RESIZE
   */
  setupContainerResize() {
    const mainContainer = document.body;

    if ('ResizeObserver' in window) {
      // Browserele moderne (Chrome 64+, Firefox 69+)
      this.resizeObserver = new ResizeObserver((entries) => {
        for (const entry of entries) {
          const { width, height } = entry.contentRect;
          this.log(`📦 Container resize: ${width}x${height}px`);

          // Emit doar dacă schimbarea e semnificativă (opțional)
          if (
            Math.abs(width - this.lastContainerWidth) > 10 ||
            Math.abs(height - this.lastContainerHeight) > 10
          ) {
            this.lastContainerWidth = width;
            this.lastContainerHeight = height;
            this.eventBus.emit(this.EVENTS.TABLE_RESIZE);
          } else {
            // Dacă schimbarea nu e semnificativă, nu emite evenimentul
            this.log(`🔄 Schimbare nesemnificativă (${width}x${height}px), nu emite TABLE_RESIZE`);
          }
        }
      });

      this.resizeObserver.observe(mainContainer);
      this.log('🎯 ResizeObserver attachat pe main-container');
    } else {
      // Fallback pentru browsere vechi (IE, Safari vechi)
      this.log.error('⚠️ ResizeObserver nu e suportat!');
    }
  },
};
