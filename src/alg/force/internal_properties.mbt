///|
pub type ForceInternalNodeProperty = @graph.IProperty[Unit]

///|
pub fn new_force_internal_node_property(
  id : String,
) -> ForceInternalNodeProperty {
  @graph.new_property(id, ())
}

///|
pub type ForceInternalRandomProperty = @graph.IProperty[Unit]

///|
pub fn new_force_internal_random_property(
  id : String,
) -> ForceInternalRandomProperty {
  @graph.new_property(id, ())
}

///|
pub type ForceInternalVectorProperty = @graph.IProperty[Unit]

///|
pub fn new_force_internal_vector_property(
  id : String,
) -> ForceInternalVectorProperty {
  @graph.new_property(id, ())
}

///|
pub let force_internal_origin : ForceInternalNodeProperty = new_force_internal_node_property(
  "origin",
)

///|
pub let force_internal_random : ForceInternalRandomProperty = new_force_internal_random_property(
  "random",
)

///|
pub let force_internal_bb_up_left : ForceInternalVectorProperty = new_force_internal_vector_property(
  "boundingBox.upLeft",
)

///|
pub let force_internal_bb_low_right : ForceInternalVectorProperty = new_force_internal_vector_property(
  "boundingBox.lowRight",
)
