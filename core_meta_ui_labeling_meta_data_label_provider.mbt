///|
fn core_meta_ui_label_or_empty(value : String?) -> String {
  match value {
    Some(text) => text
    None => ""
  }
}

///|
pub struct MetaDataLabelProvider {
  unit : Unit
}

///|
pub fn new_meta_data_label_provider() -> MetaDataLabelProvider {
  { unit: () }
}

///|
pub fn MetaDataLabelProvider::text_md_algorithm(
  self : MetaDataLabelProvider,
  algorithm : CoreMetaMdAlgorithm,
) -> String {
  ignore(self)
  "Algorithm: " + core_meta_ui_label_or_empty(algorithm.get_name())
}

///|
pub fn MetaDataLabelProvider::text_md_category(
  self : MetaDataLabelProvider,
  category : CoreMetaMdCategory,
) -> String {
  ignore(self)
  "Category: " + core_meta_ui_label_or_empty(category.get_name())
}

///|
pub fn MetaDataLabelProvider::text_md_group(
  self : MetaDataLabelProvider,
  group : CoreMetaMdGroup,
) -> String {
  ignore(self)
  "Group: " + core_meta_ui_label_or_empty(group.get_name())
}

///|
pub fn MetaDataLabelProvider::text_md_option(
  self : MetaDataLabelProvider,
  option : CoreMetaMdOption,
) -> String {
  ignore(self)
  "Option: " + core_meta_ui_label_or_empty(option.get_name())
}
