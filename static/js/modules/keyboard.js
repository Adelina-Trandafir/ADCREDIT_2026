// js/modules/keyboard.js
export function initKeyboard() {
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
      e.preventDefault();
      if (State.hasChanges) window.saveSettings();
    }
    if (e.key === 'Escape') {
      document.querySelectorAll('.actions-dropdown').forEach((d) => d.classList.remove('show'));
    }
  });
}
// This function initializes keyboard shortcuts for the application.
// It listens for keydown events and performs actions based on the keys pressed.
