///|
let layout_listener_next_id_ref : Ref[Int] = Ref::new(0)

///|
fn next_layout_listener_id() -> Int {
  let id = layout_listener_next_id_ref.val
  layout_listener_next_id_ref.val = id + 1
  id
}

///|
pub fn reset_layout_listener_ids_for_test() -> Unit {
  layout_listener_next_id_ref.val = 0
}

///|
pub(all) struct ILayoutListener {
  id : Int
  layout_about_to_start_fn : (LayoutMapping, @core.IElkProgressMonitor) -> Unit
  layout_done_fn : (LayoutMapping, @core.IElkProgressMonitor) -> Unit
}

///|
pub fn new_layout_listener(
  layout_about_to_start_fn? : (LayoutMapping, @core.IElkProgressMonitor) -> Unit = (
    _,
    _,
  ) => (),
  layout_done_fn? : (LayoutMapping, @core.IElkProgressMonitor) -> Unit = (_, _) => (),
) -> ILayoutListener {
  { id: next_layout_listener_id(), layout_about_to_start_fn, layout_done_fn }
}

///|
pub fn ILayoutListener::layout_about_to_start(
  self : ILayoutListener,
  mapping : LayoutMapping,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  (self.layout_about_to_start_fn)(mapping, progress_monitor)
}

///|
pub fn ILayoutListener::layout_done(
  self : ILayoutListener,
  mapping : LayoutMapping,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  (self.layout_done_fn)(mapping, progress_monitor)
}
