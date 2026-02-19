///|
pub(all) struct MetaDataQuickfixProvider {
  unit : Unit
}

///|
pub fn new_meta_data_quickfix_provider() -> MetaDataQuickfixProvider {
  { unit: () }
}

///|
pub fn MetaDataQuickfixProvider::get_base_class_name(
  self : MetaDataQuickfixProvider,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.quickfix.XbaseQuickfixProvider"
}
