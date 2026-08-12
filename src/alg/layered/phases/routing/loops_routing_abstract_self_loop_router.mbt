///|
pub struct AbstractSelfLoopRouter {
  route_self_loops_fn : (@runtime.SelfLoopHolder) -> Unit raise
}

///|
pub fn new_abstract_self_loop_router(
  route_self_loops_fn : (@runtime.SelfLoopHolder) -> Unit raise,
) -> AbstractSelfLoopRouter {
  { route_self_loops_fn, }
}

///|
pub fn AbstractSelfLoopRouter::route_self_loops(
  self : AbstractSelfLoopRouter,
  sl_holder : @runtime.SelfLoopHolder,
) -> Unit raise {
  (self.route_self_loops_fn)(sl_holder)
}
