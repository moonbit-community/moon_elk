///|
pub struct AbstractSelfLoopRouter {
  route_self_loops_fn : (SelfLoopHolder) -> Unit
}

///|
pub fn new_abstract_self_loop_router(
  route_self_loops_fn : (SelfLoopHolder) -> Unit,
) -> AbstractSelfLoopRouter {
  { route_self_loops_fn }
}

///|
pub fn AbstractSelfLoopRouter::route_self_loops(
  self : AbstractSelfLoopRouter,
  sl_holder : SelfLoopHolder,
) -> Unit {
  (self.route_self_loops_fn)(sl_holder)
}
