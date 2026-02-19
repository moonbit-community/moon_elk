///|
pub(all) struct ILayoutMetaData {
  get_id_fn : () -> String
  get_name_fn : () -> String
  get_description_fn : () -> String
}

///|
pub fn new_layout_meta_data(
  get_id_fn : () -> String,
  get_name_fn : () -> String,
  get_description_fn : () -> String,
) -> ILayoutMetaData {
  { get_id_fn, get_name_fn, get_description_fn }
}

///|
pub fn ILayoutMetaData::get_id(self : ILayoutMetaData) -> String {
  (self.get_id_fn)()
}

///|
pub fn ILayoutMetaData::get_name(self : ILayoutMetaData) -> String {
  (self.get_name_fn)()
}

///|
pub fn ILayoutMetaData::get_description(self : ILayoutMetaData) -> String {
  (self.get_description_fn)()
}

///|
pub fn layout_meta_data_for_algorithm(
  data : LayoutAlgorithmData,
) -> ILayoutMetaData {
  new_layout_meta_data(() => data.get_id(), () => data.get_name(), () => {
    data.get_description()
  })
}

///|
pub fn layout_meta_data_for_option(data : LayoutOptionData) -> ILayoutMetaData {
  new_layout_meta_data(() => data.get_id(), () => data.get_name(), () => {
    data.get_description()
  })
}

///|
pub fn layout_meta_data_for_category(
  data : LayoutCategoryData,
) -> ILayoutMetaData {
  new_layout_meta_data(() => data.get_id(), () => data.get_name(), () => {
    data.get_description()
  })
}
