///|
pub let bundle_resource_path_property : String = "ELK_REPO"

///|
pub type BundleResourcePath = AbstractPropertyDependentResourcePath

///|
pub suberror BundleResourcePathException {
  BundleResourcePathException(String)
} derive(Debug, ToJson)

///|
fn bundle_resource_path_raise_unit(
  message : String,
) -> Unit raise BundleResourcePathException {
  raise BundleResourcePathException(message)
}

///|
fn bundle_resource_path_bundle_id_to_path(bundle_id : String) -> String {
  let mut path = base_path_for_property(bundle_resource_path_property) catch {
    AbstractPropertyDependentResourcePathException::IllegalStateException(
      message
    ) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      "."
    }
  }
  if !path.has_suffix("/") {
    path = path + "/"
  }
  if bundle_id.has_suffix("test") {
    path = path + "test/"
  } else {
    path = path + "plugins/"
  }
  path + bundle_id
}

///|
pub fn new_bundle_resource_path(
  bundle_id : String,
  file_path : String,
) -> BundleResourcePath {
  let effective_bundle_id = if bundle_id.is_empty() {
    try
      bundle_resource_path_raise_unit("The bundle ID cannot be empty.")
    catch {
      BundleResourcePathException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.test.framework.io.BundleResourcePath: " + message,
        )
    } noraise {
      _ => ()
    }
    "org.eclipse.elk"
  } else {
    bundle_id
  }
  let effective_file_path = if file_path.is_empty() {
    try
      bundle_resource_path_raise_unit("The file path cannot be empty.")
    catch {
      BundleResourcePathException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.test.framework.io.BundleResourcePath: " + message,
        )
    } noraise {
      _ => ()
    }
    "."
  } else {
    file_path
  }
  new_abstract_resource_path(
    Some(bundle_resource_path_bundle_id_to_path(effective_bundle_id)),
    effective_file_path,
  )
}
