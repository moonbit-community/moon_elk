///|
pub(all) struct CoreMetaInferredType {
  qualified_name : String
  members : Array[String]
}

///|
pub fn new_core_meta_inferred_type(
  qualified_name : String,
  members : Array[String],
) -> CoreMetaInferredType {
  { qualified_name, members }
}

///|
pub(all) struct MetaDataJvmModelInferrer {
  marker : Unit
}

///|
pub fn new_meta_data_jvm_model_inferrer() -> MetaDataJvmModelInferrer {
  { marker: () }
}

///|
fn core_meta_jvm_model_bundle_target_class(model : CoreMetaMdModel) -> String {
  match model.get_bundle() {
    Some(bundle) =>
      match bundle.get_target_class() {
        Some(name) => name
        None => "org.eclipse.elk.core.meta.GeneratedMetaDataProvider"
      }
    None => "org.eclipse.elk.core.meta.GeneratedMetaDataProvider"
  }
}

///|
pub fn MetaDataJvmModelInferrer::infer(
  self : MetaDataJvmModelInferrer,
  model : CoreMetaMdModel,
) -> Array[CoreMetaInferredType] {
  ignore(self)
  let inferred : Array[CoreMetaInferredType] = []

  let provider_name = core_meta_jvm_model_bundle_target_class(model)
  let members : Array[String] = []

  match model.get_bundle() {
    Some(bundle) =>
      for bundle_member in bundle.get_members() {
        let tag = core_meta_md_bundle_member_tag(bundle_member)
        let name = match core_meta_md_bundle_member_name(bundle_member) {
          Some(value) => value
          None => "unnamed"
        }
        members.push(tag + ":" + name)
      }
    None => ()
  }

  inferred.push(new_core_meta_inferred_type(provider_name, members))
  inferred
}
