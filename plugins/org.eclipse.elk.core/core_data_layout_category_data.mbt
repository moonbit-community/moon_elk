///|
pub struct LayoutCategoryData {
  id : String
  name : String
  description : String
  layouters : Array[LayoutAlgorithmData]
}

///|
pub fn new_layout_category_data(
  id : String,
  name? : String = "",
  description? : String = "",
) -> LayoutCategoryData {
  { id, name, description, layouters: [] }
}

///|
pub fn LayoutCategoryData::get_id(self : LayoutCategoryData) -> String {
  self.id
}

///|
pub fn LayoutCategoryData::get_name(self : LayoutCategoryData) -> String {
  self.name
}

///|
pub fn LayoutCategoryData::get_description(self : LayoutCategoryData) -> String {
  self.description
}

///|
pub fn LayoutCategoryData::get_layouters(
  self : LayoutCategoryData,
) -> Array[LayoutAlgorithmData] {
  self.layouters
}

///|
pub fn LayoutCategoryData::add_layouter(
  self : LayoutCategoryData,
  layouter : LayoutAlgorithmData,
) -> Unit {
  self.layouters.push(layouter)
}
