///|
pub let model_resource_path_property : String = "MODELS_REPO"

///|
pub type ModelResourcePath = AbstractPropertyDependentResourcePath

///|
pub suberror ModelResourcePathException {
  ModelResourcePathException(String)
} derive(Show, ToJson)

///|
fn model_resource_path_raise_unit(
  message : String,
) -> Unit raise ModelResourcePathException {
  raise ModelResourcePathException(message)
}

///|
pub fn new_model_resource_path(file_path : String) -> ModelResourcePath {
  let effective_file_path = if file_path.is_empty() {
    try model_resource_path_raise_unit("The file path cannot be empty.") catch {
      ModelResourcePathException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.test.framework.io.ModelResourcePath: " + message,
        )
    } noraise {
      _ => ()
    }
    "."
  } else {
    file_path
  }
  new_abstract_resource_path(
    Some(
      base_path_for_property(model_resource_path_property) catch {
        AbstractPropertyDependentResourcePathException::IllegalStateException(
          message
        ) => {
          @core.layout_runtime_report_unsupported_configuration(message)
          "."
        }
      },
    ),
    effective_file_path,
  )
}
