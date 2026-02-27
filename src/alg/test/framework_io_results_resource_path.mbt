///|
pub let results_resource_path_property : String = "RESULTS_PATH"

///|
pub type ResultsResourcePath = AbstractPropertyDependentResourcePath

///|
pub suberror ResultsResourcePathException {
  ResultsResourcePathException(String)
} derive(Show, ToJson)

///|
fn results_resource_path_raise_unit(
  message : String,
) -> Unit raise ResultsResourcePathException {
  raise ResultsResourcePathException(message)
}

///|
pub fn new_results_resource_path(relative_path : String) -> ResultsResourcePath {
  let effective_relative_path = if relative_path.is_empty() {
    try
      results_resource_path_raise_unit("The file path cannot be empty.")
    catch {
      ResultsResourcePathException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.test.framework.io.ResultsResourcePath: " +
          message,
        )
    } noraise {
      _ => ()
    }
    "."
  } else {
    relative_path
  }
  new_abstract_resource_path(
    Some(
      base_path_for_property(results_resource_path_property) catch {
        AbstractPropertyDependentResourcePathException::IllegalStateException(
          message
        ) => {
          @core.layout_runtime_report_unsupported_configuration(message)
          "."
        }
      },
    ),
    effective_relative_path,
  )
}

///|
pub fn ensure_results_path_exists() -> Unit {
  let path = base_path_for_property(results_resource_path_property) catch {
    AbstractPropertyDependentResourcePathException::IllegalStateException(
      message
    ) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      "."
    }
  }
  if !core_debug_is_directory(path) {
    core_debug_register_directory_for_test(path, [])
  }
}
