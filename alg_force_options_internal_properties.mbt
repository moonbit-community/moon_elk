///|
pub struct ForceInternalNodeProperty {
  id : String
}

///|
pub fn new_force_internal_node_property(
  id : String,
) -> ForceInternalNodeProperty {
  { id, }
}

///|
pub fn ForceInternalNodeProperty::get_id(
  self : ForceInternalNodeProperty,
) -> String {
  self.id
}

///|
pub struct ForceInternalRandomProperty {
  id : String
}

///|
pub fn new_force_internal_random_property(
  id : String,
) -> ForceInternalRandomProperty {
  { id, }
}

///|
pub fn ForceInternalRandomProperty::get_id(
  self : ForceInternalRandomProperty,
) -> String {
  self.id
}

///|
pub struct ForceInternalVectorProperty {
  id : String
}

///|
pub fn new_force_internal_vector_property(
  id : String,
) -> ForceInternalVectorProperty {
  { id, }
}

///|
pub fn ForceInternalVectorProperty::get_id(
  self : ForceInternalVectorProperty,
) -> String {
  self.id
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
