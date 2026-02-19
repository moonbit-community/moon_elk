///|
pub(all) struct MetaDataDescriptionLabelProvider {
  unit : Unit
}

///|
pub fn new_meta_data_description_label_provider() -> MetaDataDescriptionLabelProvider {
  { unit: () }
}

///|
pub fn MetaDataDescriptionLabelProvider::get_base_class_name(
  self : MetaDataDescriptionLabelProvider,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.labeling.XbaseDescriptionLabelProvider"
}
