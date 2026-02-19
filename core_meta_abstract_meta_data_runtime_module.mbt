///|
pub let core_meta_default_file_extension : String = "melk"

///|
pub let core_meta_default_language_name : String = "org.eclipse.elk.core.meta.MetaData"

///|
pub let core_meta_default_serializer_class_name : String = "org.eclipse.xtext.serializer.impl.Serializer"

///|
pub struct AbstractMetaDataRuntimeModule {
  mut properties : Map[String, String]
}

///|
pub fn new_abstract_meta_data_runtime_module(
  properties? : Map[String, String] = {},
) -> AbstractMetaDataRuntimeModule {
  { properties, }
}

///|
pub fn AbstractMetaDataRuntimeModule::configure(
  self : AbstractMetaDataRuntimeModule,
  properties : Map[String, String],
) -> Unit {
  self.properties = properties
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_language_name(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  core_meta_default_language_name
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_file_extensions(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  match self.properties.get("fileExtensions") {
    Some(value) => value
    None => core_meta_default_file_extension
  }
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_class_loader_to_instance(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_igrammar_access(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.services.MetaDataGrammarAccess"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_isemantic_sequencer(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.serializer.MetaDataSemanticSequencer"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_isyntactic_sequencer(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.serializer.MetaDataSyntacticSequencer"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_iserializer(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  core_meta_default_serializer_class_name
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_iparser(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.parser.antlr.MetaDataParser"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_itoken_to_string_converter(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenToStringConverter"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_iantlr_token_file_provider(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.parser.antlr.MetaDataAntlrTokenFileProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_lexer(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.parser.antlr.internal.InternalMetaDataLexer"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_itoken_def_provider(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::provide_internal_meta_data_lexer(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.parser.antlr.internal.InternalMetaDataLexer"
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_runtime_lexer(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.parser.antlr.internal.InternalMetaDataLexer"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_iunordered_group_helper(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.UnorderedGroupHelper"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_meta_data_validator(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.validation.MetaDataValidator"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_batch_scope_provider(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.scoping.MetaDataScopeProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_i_scope_provider_delegate(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.scoping.XImportSectionNamespaceScopeProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_ignore_case_linking(
  self : AbstractMetaDataRuntimeModule,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_container_manager(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.containers.StateBasedContainerManager"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_all_containers_state_provider(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.containers.ResourceSetBasedAllContainersStateProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_i_resource_descriptions(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions"
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_i_resource_descriptions_persisted(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_iformatter2(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.formatting2.MetaDataFormatter"
}

///|
pub fn AbstractMetaDataRuntimeModule::configure_formatter_preferences(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.formatting2.FormatterPreferenceValuesProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_qualified_name_provider(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.scoping.XbaseQualifiedNameProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_location_in_file_provider(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.jvmmodel.JvmLocationInFileProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_global_scope_provider(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.common.types.xtext.TypesAwareDefaultGlobalScopeProvider"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_feature_name_validator(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.validation.LogicalContainerAwareFeatureNameValidator"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_default_batch_type_resolver(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.typesystem.internal.LogicalContainerAwareBatchTypeResolver"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_default_reentrant_type_resolver(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.typesystem.internal.LogicalContainerAwareReentrantTypeResolver"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_resource_validator(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.annotations.validation.DerivedStateAwareResourceValidator"
}

///|
pub fn AbstractMetaDataRuntimeModule::bind_i_jvm_model_inferrer(
  self : AbstractMetaDataRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.jvmmodel.MetaDataJvmModelInferrer"
}
