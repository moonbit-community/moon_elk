///|
// Public graph objects remain integer handles for API compatibility. Handles
// increase monotonically, while this map resolves each live handle to a storage
// slot that may be reused after disposal. Removing the mapping makes stale
// handles invalid even when their old slot now contains another object.
fn graph_handle_allocate(
  slot : Int,
  next_handle : Ref[Int],
  handle_slots : Map[Int, Int],
  slot_handles : Array[Int],
) -> Int {
  if next_handle.val == 0x7fffffff {
    abort("graph model exhausted its handle space")
  }
  let handle = next_handle.val
  next_handle.val += 1
  handle_slots[handle] = slot
  slot_handles[slot] = handle
  handle
}

///|
fn graph_handle_release(
  handle : Int,
  slot : Int,
  handle_slots : Map[Int, Int],
  slot_handles : Array[Int],
  free_slots : Array[Int],
) -> Unit {
  ignore(handle_slots.remove(handle))
  slot_handles[slot] = -1
  free_slots.push(slot)
}
