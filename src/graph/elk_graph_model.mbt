///|
pub fn reset_graph_model_for_test() -> Unit {
  node_store.val.clear()
  node_next_handle.val = 0
  node_free_slots.val.clear()
  node_handle_slots.val.clear()
  node_slot_handles.val.clear()
  node_arena_store.val.clear()
  port_store.val.clear()
  port_next_handle.val = 0
  port_free_slots.val.clear()
  port_handle_slots.val.clear()
  port_slot_handles.val.clear()
  port_arena_store.val.clear()
  edge_store.val.clear()
  edge_next_handle.val = 0
  edge_free_slots.val.clear()
  edge_handle_slots.val.clear()
  edge_slot_handles.val.clear()
  edge_arena_store.val.clear()
  edge_section_store.val.clear()
  edge_section_next_handle.val = 0
  edge_section_free_slots.val.clear()
  edge_section_handle_slots.val.clear()
  edge_section_slot_handles.val.clear()
  edge_section_arena_store.val.clear()
  label_store.val.clear()
  label_next_handle.val = 0
  label_free_slots.val.clear()
  label_handle_slots.val.clear()
  label_slot_handles.val.clear()
  label_arena_store.val.clear()
  graph_arena_store.val.clear()
  graph_arena_next_handle.val = 0
  graph_arena_free_slots.val.clear()
  graph_arena_handle_slots.val.clear()
  graph_arena_slot_handles.val.clear()
}
