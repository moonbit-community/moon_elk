///|
pub struct AbstractMetaDataScopeProvider {
  marker : Unit
}

///|
pub fn new_abstract_meta_data_scope_provider() -> AbstractMetaDataScopeProvider {
  { marker: () }
}

///|
pub fn AbstractMetaDataScopeProvider::get_scope(
  self : AbstractMetaDataScopeProvider,
  _context : String,
  _reference : String,
) -> String {
  ignore(self)
  "xbase_scope"
}
