///|
/// Direction shared by component placement, wrapping, and self-loop routing.
///
/// The property belongs to the runtime model rather than the component
/// processor because several independent processor families consume it.
pub let layered_components_direction : @graph.IProperty[@core.Direction] = @graph.new_property(
  "org.eclipse.elk.direction",
  Undefined,
)
