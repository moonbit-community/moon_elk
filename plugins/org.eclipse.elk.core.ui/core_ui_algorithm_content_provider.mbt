///|
pub enum CoreUiLayoutMetaData {
  CoreUiLayoutAlgorithmMeta(LayoutAlgorithmData)
  CoreUiLayoutCategoryMeta(LayoutCategoryData)
}

///|
pub fn core_ui_layout_meta_data_get_id(data : CoreUiLayoutMetaData) -> String {
  match data {
    CoreUiLayoutAlgorithmMeta(algorithm_data) => algorithm_data.get_id()
    CoreUiLayoutCategoryMeta(category_data) => category_data.get_id()
  }
}

///|
pub fn core_ui_layout_meta_data_get_name(data : CoreUiLayoutMetaData) -> String {
  match data {
    CoreUiLayoutAlgorithmMeta(algorithm_data) => algorithm_data.get_name()
    CoreUiLayoutCategoryMeta(category_data) => category_data.get_name()
  }
}

///|
pub fn core_ui_layout_meta_data_get_description(
  data : CoreUiLayoutMetaData,
) -> String {
  match data {
    CoreUiLayoutAlgorithmMeta(algorithm_data) =>
      algorithm_data.get_description()
    CoreUiLayoutCategoryMeta(category_data) => category_data.get_description()
  }
}

///|
fn core_ui_algorithm_content_key(element : CoreUiLayoutMetaData) -> String {
  match element {
    CoreUiLayoutAlgorithmMeta(algorithm_data) => "a:" + algorithm_data.get_id()
    CoreUiLayoutCategoryMeta(category_data) => "c:" + category_data.get_id()
  }
}

///|
pub struct AlgorithmContentProvider {
  filter_map : Map[String, Bool]
  mut filter_value : String
  mut best_filter_match : CoreUiLayoutMetaData?
}

///|
pub fn new_algorithm_content_provider() -> AlgorithmContentProvider {
  { filter_map: {}, filter_value: "", best_filter_match: None }
}

///|
pub fn AlgorithmContentProvider::input_changed(
  self : AlgorithmContentProvider,
  _old_input? : String? = None,
  _new_input? : String? = None,
) -> Unit {
  ignore(self)
}

///|
pub fn AlgorithmContentProvider::get_elements(
  self : AlgorithmContentProvider,
) -> Array[CoreUiLayoutMetaData] {
  ignore(self)
  let result : Array[CoreUiLayoutMetaData] = []
  for category_data in layout_meta_data_service_category_data_values() {
    result.push(CoreUiLayoutCategoryMeta(category_data))
  }
  result
}

///|
pub fn AlgorithmContentProvider::get_children(
  self : AlgorithmContentProvider,
  parent_element : CoreUiLayoutMetaData,
) -> Array[CoreUiLayoutMetaData] {
  ignore(self)
  match parent_element {
    CoreUiLayoutCategoryMeta(category_data) => {
      let children : Array[CoreUiLayoutMetaData] = []
      for layouter_data in category_data.get_layouters() {
        children.push(CoreUiLayoutAlgorithmMeta(layouter_data))
      }
      children
    }
    CoreUiLayoutAlgorithmMeta(_) => []
  }
}

///|
pub fn AlgorithmContentProvider::get_parent(
  self : AlgorithmContentProvider,
  element : CoreUiLayoutMetaData,
) -> CoreUiLayoutMetaData? {
  ignore(self)
  match element {
    CoreUiLayoutAlgorithmMeta(layouter_data) =>
      match
        layout_meta_data_service_get_category_data(
          layouter_data.get_category_id(),
        ) {
        Some(category_data) => Some(CoreUiLayoutCategoryMeta(category_data))
        None => None
      }
    CoreUiLayoutCategoryMeta(_) => None
  }
}

///|
pub fn AlgorithmContentProvider::has_children(
  self : AlgorithmContentProvider,
  element : CoreUiLayoutMetaData,
) -> Bool {
  ignore(self)
  match element {
    CoreUiLayoutCategoryMeta(category_data) =>
      !category_data.get_layouters().is_empty()
    CoreUiLayoutAlgorithmMeta(_) => false
  }
}

///|
pub fn AlgorithmContentProvider::dispose(
  self : AlgorithmContentProvider,
) -> Unit {
  self.filter_map.clear()
  self.filter_value = ""
  self.best_filter_match = None
}

///|
pub fn AlgorithmContentProvider::update_filter(
  self : AlgorithmContentProvider,
  filter : String?,
) -> Unit {
  self.filter_value = match filter {
    Some(value) => value.to_lower()
    None => ""
  }
  self.filter_map.clear()
  self.best_filter_match = None
}

///|
fn algorithm_content_provider_is_better_match(
  current_best : CoreUiLayoutMetaData?,
  candidate_name : String,
  filter_value : String,
) -> Bool {
  match current_best {
    None => true
    Some(best) => {
      let best_name = core_ui_layout_meta_data_get_name(best).to_lower()
      candidate_name.starts_with(filter_value) &&
      !best_name.starts_with(filter_value)
    }
  }
}

///|
pub fn AlgorithmContentProvider::apply_filter(
  self : AlgorithmContentProvider,
  element : CoreUiLayoutMetaData,
) -> Bool {
  let key = core_ui_algorithm_content_key(element)
  match self.filter_map.get(key) {
    Some(result) => result
    None => {
      let result = if self.filter_value.is_empty() {
        match element {
          CoreUiLayoutCategoryMeta(category_data) =>
            !category_data.get_layouters().is_empty()
          CoreUiLayoutAlgorithmMeta(_) => true
        }
      } else {
        match element {
          CoreUiLayoutCategoryMeta(category_data) =>
            if category_data.get_layouters().is_empty() {
              false
            } else {
              let category_name = category_data.get_name().to_lower()
              if category_name.contains(self.filter_value) {
                for layouter_data in category_data.get_layouters() {
                  self.filter_map[core_ui_algorithm_content_key(
                    CoreUiLayoutAlgorithmMeta(layouter_data),
                  )] = true
                }
                if algorithm_content_provider_is_better_match(
                    self.best_filter_match,
                    category_name,
                    self.filter_value,
                  ) {
                  self.best_filter_match = Some(element)
                }
                true
              } else {
                let mut has_filtered_child = false
                for layouter_data in category_data.get_layouters() {
                  has_filtered_child = has_filtered_child ||
                    self.apply_filter(CoreUiLayoutAlgorithmMeta(layouter_data))
                }
                has_filtered_child
              }
            }
          CoreUiLayoutAlgorithmMeta(layouter_data) => {
            let layouter_name = layouter_data.get_name().to_lower()
            if layouter_name.contains(self.filter_value) {
              if algorithm_content_provider_is_better_match(
                  self.best_filter_match,
                  layouter_name,
                  self.filter_value,
                ) {
                self.best_filter_match = Some(element)
              }
              true
            } else {
              layouter_data
              .get_bundle_name()
              .to_lower()
              .contains(self.filter_value)
            }
          }
        }
      }
      self.filter_map[key] = result
      result
    }
  }
}

///|
pub fn AlgorithmContentProvider::get_best_filter_match(
  self : AlgorithmContentProvider,
) -> CoreUiLayoutMetaData? {
  self.best_filter_match
}
