///|
let next_layout_execution_listener_id_ref : Ref[Int] = Ref::new(0)

///|
fn next_layout_execution_listener_id() -> Int {
  let id = next_layout_execution_listener_id_ref.val
  next_layout_execution_listener_id_ref.val = id + 1
  id
}

///|
pub fn reset_layout_execution_listener_ids_for_test() -> Unit {
  next_layout_execution_listener_id_ref.val = 0
}

///|
pub struct ILayoutExecutionListener[G] {
  id : Int
  layout_processor_ready_fn : (Int, G, Bool) -> Unit
  layout_processor_finished_fn : (Int, G, Bool) -> Unit
}

///|
pub fn[G] new_layout_execution_listener(
  layout_processor_ready_fn : (Int, G, Bool) -> Unit,
  layout_processor_finished_fn : (Int, G, Bool) -> Unit,
) -> ILayoutExecutionListener[G] {
  {
    id: next_layout_execution_listener_id(),
    layout_processor_ready_fn,
    layout_processor_finished_fn,
  }
}

///|
pub fn[G] ILayoutExecutionListener::layout_processor_ready(
  self : ILayoutExecutionListener[G],
  processor_id : Int,
  graph : G,
  is_root : Bool,
) -> Unit {
  (self.layout_processor_ready_fn)(processor_id, graph, is_root)
}

///|
pub fn[G] ILayoutExecutionListener::layout_processor_finished(
  self : ILayoutExecutionListener[G],
  processor_id : Int,
  graph : G,
  is_root : Bool,
) -> Unit {
  (self.layout_processor_finished_fn)(processor_id, graph, is_root)
}

///|
pub fn[G] ILayoutExecutionListener::listener_id(
  self : ILayoutExecutionListener[G],
) -> Int {
  self.id
}

///|
pub struct TestController[G] {
  layout_algorithm_id : String
  mut current_layout_provider : IWhiteBoxTestable[G]?
  listeners : Array[ILayoutExecutionListener[G]]
}

///|
pub fn[G] new_test_controller(
  layout_algorithm_id : String,
) -> TestController[G] {
  { layout_algorithm_id, current_layout_provider: None, listeners: [] }
}

///|
pub fn[G] TestController::get_target_algorithm_id(
  self : TestController[G],
) -> String {
  self.layout_algorithm_id
}

///|
pub fn[G] TestController::targets(
  self : TestController[G],
  algorithm_data : LayoutAlgorithmData,
) -> Bool {
  algorithm_data.get_id() == self.layout_algorithm_id
}

///|
pub fn[G] TestController::install(
  self : TestController[G],
  layout_provider : IWhiteBoxTestable[G],
) -> Unit {
  if self.current_layout_provider is Some(_) {
    abort(
      "Test controller may be installed on only one layout provider at a time",
    )
  }
  self.current_layout_provider = Some(layout_provider)
  layout_provider.set_test_controller(Some(self))
}

///|
pub fn[G] TestController::uninstall(self : TestController[G]) -> Unit {
  match self.current_layout_provider {
    Some(layout_provider) => {
      layout_provider.set_test_controller(None)
      self.current_layout_provider = None
    }
    None => ()
  }
}

///|
pub fn[P, G] TestController::notify_processor_ready(
  self : TestController[G],
  graph : G,
  processor : ILayoutProcessor[P, G],
) -> Unit {
  for listener in self.listeners {
    listener.layout_processor_ready(processor.instance_id(), graph, false)
  }
}

///|
pub fn[P, G] TestController::notify_processor_finished(
  self : TestController[G],
  graph : G,
  processor : ILayoutProcessor[P, G],
) -> Unit {
  for listener in self.listeners {
    listener.layout_processor_finished(processor.instance_id(), graph, false)
  }
}

///|
pub fn[P, G] TestController::notify_root_processor_ready(
  self : TestController[G],
  graph : G,
  processor : ILayoutProcessor[P, G],
) -> Unit {
  for listener in self.listeners {
    listener.layout_processor_ready(processor.instance_id(), graph, true)
  }
}

///|
pub fn[P, G] TestController::notify_root_processor_finished(
  self : TestController[G],
  graph : G,
  processor : ILayoutProcessor[P, G],
) -> Unit {
  for listener in self.listeners {
    listener.layout_processor_finished(processor.instance_id(), graph, true)
  }
}

///|
fn[G] test_controller_has_listener(
  listeners : Array[ILayoutExecutionListener[G]],
  listener_id : Int,
) -> Bool {
  for listener in listeners {
    if listener.listener_id() == listener_id {
      return true
    }
  }
  false
}

///|
pub fn[G] TestController::add_layout_execution_listener(
  self : TestController[G],
  listener : ILayoutExecutionListener[G],
) -> Unit {
  if !test_controller_has_listener(self.listeners, listener.listener_id()) {
    self.listeners.push(listener)
  }
}

///|
pub fn[G] TestController::remove_layout_execution_listener(
  self : TestController[G],
  listener : ILayoutExecutionListener[G],
) -> Unit {
  // Keep upstream behavior: remove adds again.
  self.listeners.push(listener)
}
