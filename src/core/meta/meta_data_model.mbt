///|
pub(all) struct CoreMetaMdModel {
  mut name : String?
  mut import_section : String?
  mut bundle : CoreMetaMdBundle?
}

///|
pub(all) struct CoreMetaMdBundle {
  mut label : String?
  mut target_class : String?
  mut documentation_folder : String?
  mut id_prefix : String?
  members : Array[CoreMetaMdBundleMember]
}

///|
pub(all) struct CoreMetaMdGroup {
  mut name : String?
  mut documentation : String?
  children : Array[CoreMetaMdGroupOrOption]
}

///|
pub(all) struct CoreMetaMdOption {
  mut name : String?
  mut documentation : String?
  mut deprecated : Bool
  mut advanced : Bool
  mut programmatic : Bool
  mut output : Bool
  mut global : Bool
  mut type_ref : String?
  mut label : String?
  mut description : String?
  mut default_value : String?
  mut lower_bound : String?
  mut upper_bound : String?
  targets : Array[CoreMetaMdOptionTargetType]
  legacy_ids : Array[String]
  dependencies : Array[CoreMetaMdOptionDependency]
}

///|
pub(all) struct CoreMetaMdOptionDependency {
  mut target : CoreMetaMdOption?
  mut target_name : String?
  mut value : String?
}

///|
pub(all) struct CoreMetaMdAlgorithm {
  mut name : String?
  mut documentation : String?
  mut deprecated : Bool
  mut provider : String?
  mut parameter : String?
  mut label : String?
  mut target_class : String?
  mut description : String?
  mut category : CoreMetaMdCategory?
  mut category_name : String?
  mut preview_image : String?
  supported_features : Array[CoreMetaMdGraphFeature]
  mut validator : String?
  supported_options : Array[CoreMetaMdOptionSupport]
}

///|
pub(all) struct CoreMetaMdCategory {
  mut name : String?
  mut documentation : String?
  mut deprecated : Bool
  mut label : String?
  mut description : String?
}

///|
pub(all) struct CoreMetaMdOptionSupport {
  mut option : CoreMetaMdOption?
  mut option_name : String?
  mut value : String?
  mut documentation : String?
}

///|
pub fn core_meta_create_md_model() -> CoreMetaMdModel {
  { name: None, import_section: None, bundle: None }
}

///|
pub fn core_meta_create_md_bundle() -> CoreMetaMdBundle {
  {
    label: None,
    target_class: None,
    documentation_folder: None,
    id_prefix: None,
    members: [],
  }
}

///|
pub fn core_meta_create_md_group() -> CoreMetaMdGroup {
  { name: None, documentation: None, children: [] }
}

///|
pub fn core_meta_create_md_option() -> CoreMetaMdOption {
  {
    name: None,
    documentation: None,
    deprecated: false,
    advanced: false,
    programmatic: false,
    output: false,
    global: false,
    type_ref: None,
    label: None,
    description: None,
    default_value: None,
    lower_bound: None,
    upper_bound: None,
    targets: [],
    legacy_ids: [],
    dependencies: [],
  }
}

///|
pub fn core_meta_create_md_option_dependency() -> CoreMetaMdOptionDependency {
  { target: None, target_name: None, value: None }
}

///|
pub fn core_meta_create_md_algorithm() -> CoreMetaMdAlgorithm {
  {
    name: None,
    documentation: None,
    deprecated: false,
    provider: None,
    parameter: None,
    label: None,
    target_class: None,
    description: None,
    category: None,
    category_name: None,
    preview_image: None,
    supported_features: [],
    validator: None,
    supported_options: [],
  }
}

///|
pub fn core_meta_create_md_category() -> CoreMetaMdCategory {
  {
    name: None,
    documentation: None,
    deprecated: false,
    label: None,
    description: None,
  }
}

///|
pub fn core_meta_create_md_option_support() -> CoreMetaMdOptionSupport {
  { option: None, option_name: None, value: None, documentation: None }
}

///|
pub fn CoreMetaMdModel::get_name(self : CoreMetaMdModel) -> String? {
  self.name
}

///|
pub fn CoreMetaMdModel::set_name(
  self : CoreMetaMdModel,
  value : String?,
) -> Unit {
  self.name = value
}

///|
pub fn CoreMetaMdModel::get_import_section(self : CoreMetaMdModel) -> String? {
  self.import_section
}

///|
pub fn CoreMetaMdModel::set_import_section(
  self : CoreMetaMdModel,
  value : String?,
) -> Unit {
  self.import_section = value
}

///|
pub fn CoreMetaMdModel::get_bundle(self : CoreMetaMdModel) -> CoreMetaMdBundle? {
  self.bundle
}

///|
pub fn CoreMetaMdModel::set_bundle(
  self : CoreMetaMdModel,
  value : CoreMetaMdBundle?,
) -> Unit {
  self.bundle = value
}

///|
pub fn CoreMetaMdBundle::get_label(self : CoreMetaMdBundle) -> String? {
  self.label
}

///|
pub fn CoreMetaMdBundle::set_label(
  self : CoreMetaMdBundle,
  value : String?,
) -> Unit {
  self.label = value
}

///|
pub fn CoreMetaMdBundle::get_target_class(self : CoreMetaMdBundle) -> String? {
  self.target_class
}

///|
pub fn CoreMetaMdBundle::set_target_class(
  self : CoreMetaMdBundle,
  value : String?,
) -> Unit {
  self.target_class = value
}

///|
pub fn CoreMetaMdBundle::get_documentation_folder(
  self : CoreMetaMdBundle,
) -> String? {
  self.documentation_folder
}

///|
pub fn CoreMetaMdBundle::set_documentation_folder(
  self : CoreMetaMdBundle,
  value : String?,
) -> Unit {
  self.documentation_folder = value
}

///|
pub fn CoreMetaMdBundle::get_id_prefix(self : CoreMetaMdBundle) -> String? {
  self.id_prefix
}

///|
pub fn CoreMetaMdBundle::set_id_prefix(
  self : CoreMetaMdBundle,
  value : String?,
) -> Unit {
  self.id_prefix = value
}

///|
pub fn CoreMetaMdBundle::get_members(
  self : CoreMetaMdBundle,
) -> Array[CoreMetaMdBundleMember] {
  self.members
}

///|
pub fn CoreMetaMdGroup::get_name(self : CoreMetaMdGroup) -> String? {
  self.name
}

///|
pub fn CoreMetaMdGroup::set_name(
  self : CoreMetaMdGroup,
  value : String?,
) -> Unit {
  self.name = value
}

///|
pub fn CoreMetaMdGroup::get_documentation(self : CoreMetaMdGroup) -> String? {
  self.documentation
}

///|
pub fn CoreMetaMdGroup::set_documentation(
  self : CoreMetaMdGroup,
  value : String?,
) -> Unit {
  self.documentation = value
}

///|
pub fn CoreMetaMdGroup::get_children(
  self : CoreMetaMdGroup,
) -> Array[CoreMetaMdGroupOrOption] {
  self.children
}

///|
pub fn CoreMetaMdOption::get_name(self : CoreMetaMdOption) -> String? {
  self.name
}

///|
pub fn CoreMetaMdOption::set_name(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.name = value
}

///|
pub fn CoreMetaMdOption::get_documentation(self : CoreMetaMdOption) -> String? {
  self.documentation
}

///|
pub fn CoreMetaMdOption::set_documentation(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.documentation = value
}

///|
pub fn CoreMetaMdOption::is_deprecated(self : CoreMetaMdOption) -> Bool {
  self.deprecated
}

///|
pub fn CoreMetaMdOption::set_deprecated(
  self : CoreMetaMdOption,
  value : Bool,
) -> Unit {
  self.deprecated = value
}

///|
pub fn CoreMetaMdOption::is_advanced(self : CoreMetaMdOption) -> Bool {
  self.advanced
}

///|
pub fn CoreMetaMdOption::set_advanced(
  self : CoreMetaMdOption,
  value : Bool,
) -> Unit {
  self.advanced = value
}

///|
pub fn CoreMetaMdOption::is_programmatic(self : CoreMetaMdOption) -> Bool {
  self.programmatic
}

///|
pub fn CoreMetaMdOption::set_programmatic(
  self : CoreMetaMdOption,
  value : Bool,
) -> Unit {
  self.programmatic = value
}

///|
pub fn CoreMetaMdOption::is_output(self : CoreMetaMdOption) -> Bool {
  self.output
}

///|
pub fn CoreMetaMdOption::set_output(
  self : CoreMetaMdOption,
  value : Bool,
) -> Unit {
  self.output = value
}

///|
pub fn CoreMetaMdOption::is_global(self : CoreMetaMdOption) -> Bool {
  self.global
}

///|
pub fn CoreMetaMdOption::set_global(
  self : CoreMetaMdOption,
  value : Bool,
) -> Unit {
  self.global = value
}

///|
pub fn CoreMetaMdOption::get_type_ref(self : CoreMetaMdOption) -> String? {
  self.type_ref
}

///|
pub fn CoreMetaMdOption::set_type_ref(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.type_ref = value
}

///|
pub fn CoreMetaMdOption::get_label(self : CoreMetaMdOption) -> String? {
  self.label
}

///|
pub fn CoreMetaMdOption::set_label(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.label = value
}

///|
pub fn CoreMetaMdOption::get_description(self : CoreMetaMdOption) -> String? {
  self.description
}

///|
pub fn CoreMetaMdOption::set_description(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.description = value
}

///|
pub fn CoreMetaMdOption::get_default_value(self : CoreMetaMdOption) -> String? {
  self.default_value
}

///|
pub fn CoreMetaMdOption::set_default_value(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.default_value = value
}

///|
pub fn CoreMetaMdOption::get_lower_bound(self : CoreMetaMdOption) -> String? {
  self.lower_bound
}

///|
pub fn CoreMetaMdOption::set_lower_bound(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.lower_bound = value
}

///|
pub fn CoreMetaMdOption::get_upper_bound(self : CoreMetaMdOption) -> String? {
  self.upper_bound
}

///|
pub fn CoreMetaMdOption::set_upper_bound(
  self : CoreMetaMdOption,
  value : String?,
) -> Unit {
  self.upper_bound = value
}

///|
pub fn CoreMetaMdOption::get_targets(
  self : CoreMetaMdOption,
) -> Array[CoreMetaMdOptionTargetType] {
  self.targets
}

///|
pub fn CoreMetaMdOption::get_legacy_ids(
  self : CoreMetaMdOption,
) -> Array[String] {
  self.legacy_ids
}

///|
pub fn CoreMetaMdOption::get_dependencies(
  self : CoreMetaMdOption,
) -> Array[CoreMetaMdOptionDependency] {
  self.dependencies
}

///|
pub fn CoreMetaMdOptionDependency::get_target(
  self : CoreMetaMdOptionDependency,
) -> CoreMetaMdOption? {
  self.target
}

///|
pub fn CoreMetaMdOptionDependency::set_target(
  self : CoreMetaMdOptionDependency,
  value : CoreMetaMdOption?,
) -> Unit {
  self.target = value
}

///|
pub fn CoreMetaMdOptionDependency::get_target_name(
  self : CoreMetaMdOptionDependency,
) -> String? {
  self.target_name
}

///|
pub fn CoreMetaMdOptionDependency::set_target_name(
  self : CoreMetaMdOptionDependency,
  value : String?,
) -> Unit {
  self.target_name = value
}

///|
pub fn CoreMetaMdOptionDependency::get_value(
  self : CoreMetaMdOptionDependency,
) -> String? {
  self.value
}

///|
pub fn CoreMetaMdOptionDependency::set_value(
  self : CoreMetaMdOptionDependency,
  value : String?,
) -> Unit {
  self.value = value
}

///|
pub fn CoreMetaMdAlgorithm::get_name(self : CoreMetaMdAlgorithm) -> String? {
  self.name
}

///|
pub fn CoreMetaMdAlgorithm::set_name(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.name = value
}

///|
pub fn CoreMetaMdAlgorithm::get_documentation(
  self : CoreMetaMdAlgorithm,
) -> String? {
  self.documentation
}

///|
pub fn CoreMetaMdAlgorithm::set_documentation(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.documentation = value
}

///|
pub fn CoreMetaMdAlgorithm::is_deprecated(self : CoreMetaMdAlgorithm) -> Bool {
  self.deprecated
}

///|
pub fn CoreMetaMdAlgorithm::set_deprecated(
  self : CoreMetaMdAlgorithm,
  value : Bool,
) -> Unit {
  self.deprecated = value
}

///|
pub fn CoreMetaMdAlgorithm::get_provider(self : CoreMetaMdAlgorithm) -> String? {
  self.provider
}

///|
pub fn CoreMetaMdAlgorithm::set_provider(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.provider = value
}

///|
pub fn CoreMetaMdAlgorithm::get_parameter(
  self : CoreMetaMdAlgorithm,
) -> String? {
  self.parameter
}

///|
pub fn CoreMetaMdAlgorithm::set_parameter(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.parameter = value
}

///|
pub fn CoreMetaMdAlgorithm::get_label(self : CoreMetaMdAlgorithm) -> String? {
  self.label
}

///|
pub fn CoreMetaMdAlgorithm::set_label(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.label = value
}

///|
pub fn CoreMetaMdAlgorithm::get_target_class(
  self : CoreMetaMdAlgorithm,
) -> String? {
  self.target_class
}

///|
pub fn CoreMetaMdAlgorithm::set_target_class(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.target_class = value
}

///|
pub fn CoreMetaMdAlgorithm::get_description(
  self : CoreMetaMdAlgorithm,
) -> String? {
  self.description
}

///|
pub fn CoreMetaMdAlgorithm::set_description(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.description = value
}

///|
pub fn CoreMetaMdAlgorithm::get_category(
  self : CoreMetaMdAlgorithm,
) -> CoreMetaMdCategory? {
  self.category
}

///|
pub fn CoreMetaMdAlgorithm::set_category(
  self : CoreMetaMdAlgorithm,
  value : CoreMetaMdCategory?,
) -> Unit {
  self.category = value
}

///|
pub fn CoreMetaMdAlgorithm::get_category_name(
  self : CoreMetaMdAlgorithm,
) -> String? {
  self.category_name
}

///|
pub fn CoreMetaMdAlgorithm::set_category_name(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.category_name = value
}

///|
pub fn CoreMetaMdAlgorithm::get_preview_image(
  self : CoreMetaMdAlgorithm,
) -> String? {
  self.preview_image
}

///|
pub fn CoreMetaMdAlgorithm::set_preview_image(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.preview_image = value
}

///|
pub fn CoreMetaMdAlgorithm::get_supported_features(
  self : CoreMetaMdAlgorithm,
) -> Array[CoreMetaMdGraphFeature] {
  self.supported_features
}

///|
pub fn CoreMetaMdAlgorithm::get_validator(
  self : CoreMetaMdAlgorithm,
) -> String? {
  self.validator
}

///|
pub fn CoreMetaMdAlgorithm::set_validator(
  self : CoreMetaMdAlgorithm,
  value : String?,
) -> Unit {
  self.validator = value
}

///|
pub fn CoreMetaMdAlgorithm::get_supported_options(
  self : CoreMetaMdAlgorithm,
) -> Array[CoreMetaMdOptionSupport] {
  self.supported_options
}

///|
pub fn CoreMetaMdCategory::get_name(self : CoreMetaMdCategory) -> String? {
  self.name
}

///|
pub fn CoreMetaMdCategory::set_name(
  self : CoreMetaMdCategory,
  value : String?,
) -> Unit {
  self.name = value
}

///|
pub fn CoreMetaMdCategory::get_documentation(
  self : CoreMetaMdCategory,
) -> String? {
  self.documentation
}

///|
pub fn CoreMetaMdCategory::set_documentation(
  self : CoreMetaMdCategory,
  value : String?,
) -> Unit {
  self.documentation = value
}

///|
pub fn CoreMetaMdCategory::is_deprecated(self : CoreMetaMdCategory) -> Bool {
  self.deprecated
}

///|
pub fn CoreMetaMdCategory::set_deprecated(
  self : CoreMetaMdCategory,
  value : Bool,
) -> Unit {
  self.deprecated = value
}

///|
pub fn CoreMetaMdCategory::get_label(self : CoreMetaMdCategory) -> String? {
  self.label
}

///|
pub fn CoreMetaMdCategory::set_label(
  self : CoreMetaMdCategory,
  value : String?,
) -> Unit {
  self.label = value
}

///|
pub fn CoreMetaMdCategory::get_description(
  self : CoreMetaMdCategory,
) -> String? {
  self.description
}

///|
pub fn CoreMetaMdCategory::set_description(
  self : CoreMetaMdCategory,
  value : String?,
) -> Unit {
  self.description = value
}

///|
pub fn CoreMetaMdOptionSupport::get_option(
  self : CoreMetaMdOptionSupport,
) -> CoreMetaMdOption? {
  self.option
}

///|
pub fn CoreMetaMdOptionSupport::set_option(
  self : CoreMetaMdOptionSupport,
  value : CoreMetaMdOption?,
) -> Unit {
  self.option = value
}

///|
pub fn CoreMetaMdOptionSupport::get_option_name(
  self : CoreMetaMdOptionSupport,
) -> String? {
  self.option_name
}

///|
pub fn CoreMetaMdOptionSupport::set_option_name(
  self : CoreMetaMdOptionSupport,
  value : String?,
) -> Unit {
  self.option_name = value
}

///|
pub fn CoreMetaMdOptionSupport::get_value(
  self : CoreMetaMdOptionSupport,
) -> String? {
  self.value
}

///|
pub fn CoreMetaMdOptionSupport::set_value(
  self : CoreMetaMdOptionSupport,
  value : String?,
) -> Unit {
  self.value = value
}

///|
pub fn CoreMetaMdOptionSupport::get_documentation(
  self : CoreMetaMdOptionSupport,
) -> String? {
  self.documentation
}

///|
pub fn CoreMetaMdOptionSupport::set_documentation(
  self : CoreMetaMdOptionSupport,
  value : String?,
) -> Unit {
  self.documentation = value
}
