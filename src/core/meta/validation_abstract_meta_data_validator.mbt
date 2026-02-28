///|
pub(all) struct AbstractMetaDataValidator {
  epackages : Array[String]
}

///|
pub fn new_abstract_meta_data_validator() -> AbstractMetaDataValidator {
  {
    epackages: [
      core_meta_meta_data_ens_uri, "http://www.eclipse.org/xtext/xbase/Xbase", "http://www.eclipse.org/xtext/common/JavaVMTypes",
      "http://www.eclipse.org/xtext/xbase/Xtype",
    ],
  }
}

///|
pub fn AbstractMetaDataValidator::get_epackages(
  self : AbstractMetaDataValidator,
) -> Array[String] {
  self.epackages
}
