///|
pub(all) struct CoreMetaMetaDataFactory {
  create_md_model_fn : () -> CoreMetaMdModel
  create_md_bundle_fn : () -> CoreMetaMdBundle
  create_md_group_fn : () -> CoreMetaMdGroup
  create_md_option_fn : () -> CoreMetaMdOption
  create_md_option_dependency_fn : () -> CoreMetaMdOptionDependency
  create_md_algorithm_fn : () -> CoreMetaMdAlgorithm
  create_md_category_fn : () -> CoreMetaMdCategory
  create_md_option_support_fn : () -> CoreMetaMdOptionSupport
}

///|
pub fn new_core_meta_meta_data_factory() -> CoreMetaMetaDataFactory {
  {
    create_md_model_fn: core_meta_create_md_model,
    create_md_bundle_fn: core_meta_create_md_bundle,
    create_md_group_fn: core_meta_create_md_group,
    create_md_option_fn: core_meta_create_md_option,
    create_md_option_dependency_fn: core_meta_create_md_option_dependency,
    create_md_algorithm_fn: core_meta_create_md_algorithm,
    create_md_category_fn: core_meta_create_md_category,
    create_md_option_support_fn: core_meta_create_md_option_support,
  }
}

///|
pub let core_meta_meta_data_factory_instance : CoreMetaMetaDataFactory = new_core_meta_meta_data_factory()

///|
pub fn CoreMetaMetaDataFactory::create_md_model(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdModel {
  (self.create_md_model_fn)()
}

///|
pub fn CoreMetaMetaDataFactory::create_md_bundle(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdBundle {
  (self.create_md_bundle_fn)()
}

///|
pub fn CoreMetaMetaDataFactory::create_md_group(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdGroup {
  (self.create_md_group_fn)()
}

///|
pub fn CoreMetaMetaDataFactory::create_md_option(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdOption {
  (self.create_md_option_fn)()
}

///|
pub fn CoreMetaMetaDataFactory::create_md_option_dependency(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdOptionDependency {
  (self.create_md_option_dependency_fn)()
}

///|
pub fn CoreMetaMetaDataFactory::create_md_algorithm(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdAlgorithm {
  (self.create_md_algorithm_fn)()
}

///|
pub fn CoreMetaMetaDataFactory::create_md_category(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdCategory {
  (self.create_md_category_fn)()
}

///|
pub fn CoreMetaMetaDataFactory::create_md_option_support(
  self : CoreMetaMetaDataFactory,
) -> CoreMetaMdOptionSupport {
  (self.create_md_option_support_fn)()
}
