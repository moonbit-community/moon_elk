///|
pub(all) struct MetaDataScopeProvider {
  base : AbstractMetaDataScopeProvider
  delegate_scope_name : String
}

///|
pub fn new_meta_data_scope_provider(
  base? : AbstractMetaDataScopeProvider = new_abstract_meta_data_scope_provider(),
) -> MetaDataScopeProvider {
  { base, delegate_scope_name: "imported_namespace_scope" }
}

///|
pub fn MetaDataScopeProvider::get_scope(
  self : MetaDataScopeProvider,
  context : String,
  reference : String,
) -> String {
  if reference == core_meta_reference_md_option_dependency_target ||
    reference == core_meta_reference_md_option_support_option {
    self.delegate_scope_name
  } else {
    self.base.get_scope(context, reference)
  }
}
