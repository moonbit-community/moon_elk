///|
pub enum HierarchyHandling {
  Inherit
  IncludeChildren
  SeparateChildren
}

///|
pub fn hierarchy_handling_to_string(value : HierarchyHandling) -> String {
  match value {
    Inherit => "INHERIT"
    IncludeChildren => "INCLUDE_CHILDREN"
    SeparateChildren => "SEPARATE_CHILDREN"
  }
}
