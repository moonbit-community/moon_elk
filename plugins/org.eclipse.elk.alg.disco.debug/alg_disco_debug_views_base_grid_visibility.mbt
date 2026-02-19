///|
pub enum BaseGridVisibility {
  Hidden
  Simple
  Traversal
}

///|
pub fn base_grid_visibility_values() -> Array[BaseGridVisibility] {
  [Hidden, Simple, Traversal]
}

///|
pub fn base_grid_visibility_at(index : Int) -> BaseGridVisibility {
  base_grid_visibility_values()[index]
}

///|
pub fn base_grid_visibility_to_string(value : BaseGridVisibility) -> String {
  match value {
    Hidden => "HIDDEN"
    Simple => "SIMPLE"
    Traversal => "TRAVERSAL"
  }
}
