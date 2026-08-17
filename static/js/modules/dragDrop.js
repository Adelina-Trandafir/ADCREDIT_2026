// js/modules/dragDrop.js
export function initDragDrop(onReorder) {
  let draggedEl = null;
  let draggedIdx = null;

  document.addEventListener('dragstart', (e) => {
    if (!e.target.classList.contains('column-item')) return;
    draggedEl = e.target;
    draggedIdx = +draggedEl.dataset.index;
    e.target.classList.add('dragging');
  });

  document.addEventListener('dragend', (e) => {
    e.target.classList.remove('dragging');
    document.querySelectorAll('.drag-over').forEach((el) => el.classList.remove('drag-over'));
  });

  document.addEventListener('dragover', (e) => {
    const target = e.target.closest('.column-item');
    if (!target || target === draggedEl) return;
    e.preventDefault();
    target.classList.add('drag-over');
  });

  document.addEventListener('dragleave', (e) => {
    const target = e.target.closest('.column-item');
    if (target) target.classList.remove('drag-over');
  });

  document.addEventListener('drop', (e) => {
    const target = e.target.closest('.column-item');
    if (!target || target === draggedEl) return;
    e.preventDefault();
    const targetIdx = +target.dataset.index;
    const newOrder = [...State.columns];
    const [removed] = newOrder.splice(draggedIdx, 1);
    newOrder.splice(targetIdx, 0, removed);
    newOrder.forEach((c, i) => (c.Pozitie = i + 1));
    State.columns = newOrder;
    State.check();
    onReorder();
  });
}
