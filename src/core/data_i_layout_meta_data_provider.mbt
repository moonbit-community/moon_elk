///|
pub(all) struct LayoutMetaDataRegistry {
  register_algorithm_fn : (LayoutAlgorithmData) -> Unit
  register_option_fn : (LayoutOptionData) -> Unit
  register_category_fn : (LayoutCategoryData) -> Unit
  add_dependency_fn : (String, String, String?) -> Unit
  add_option_support_fn : (String, String, String?) -> Unit
}

///|
pub fn new_layout_meta_data_registry(
  register_algorithm_fn : (LayoutAlgorithmData) -> Unit,
  register_option_fn : (LayoutOptionData) -> Unit,
  register_category_fn : (LayoutCategoryData) -> Unit,
  add_dependency_fn : (String, String, String?) -> Unit,
  add_option_support_fn : (String, String, String?) -> Unit,
) -> LayoutMetaDataRegistry {
  {
    register_algorithm_fn,
    register_option_fn,
    register_category_fn,
    add_dependency_fn,
    add_option_support_fn,
  }
}

///|
pub fn LayoutMetaDataRegistry::register_algorithm(
  self : LayoutMetaDataRegistry,
  algorithm_data : LayoutAlgorithmData,
) -> Unit {
  (self.register_algorithm_fn)(algorithm_data)
}

///|
pub fn LayoutMetaDataRegistry::register_option(
  self : LayoutMetaDataRegistry,
  option_data : LayoutOptionData,
) -> Unit {
  (self.register_option_fn)(option_data)
}

///|
pub fn LayoutMetaDataRegistry::register_category(
  self : LayoutMetaDataRegistry,
  category_data : LayoutCategoryData,
) -> Unit {
  (self.register_category_fn)(category_data)
}

///|
pub fn LayoutMetaDataRegistry::add_dependency(
  self : LayoutMetaDataRegistry,
  source_option : String,
  target_option : String,
  required_value : String?,
) -> Unit {
  (self.add_dependency_fn)(source_option, target_option, required_value)
}

///|
pub fn LayoutMetaDataRegistry::add_option_support(
  self : LayoutMetaDataRegistry,
  algorithm_id : String,
  option_id : String,
  default_value : String?,
) -> Unit {
  (self.add_option_support_fn)(algorithm_id, option_id, default_value)
}

///|
pub(all) struct ILayoutMetaDataProvider {
  apply_fn : (LayoutMetaDataRegistry) -> Unit
}

///|
pub fn new_layout_meta_data_provider(
  apply_fn : (LayoutMetaDataRegistry) -> Unit,
) -> ILayoutMetaDataProvider {
  { apply_fn, }
}

///|
pub fn ILayoutMetaDataProvider::apply(
  self : ILayoutMetaDataProvider,
  registry : LayoutMetaDataRegistry,
) -> Unit {
  (self.apply_fn)(registry)
}
