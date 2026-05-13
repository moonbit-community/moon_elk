///|
let algorithm_plugin_content_wizard_plugin_dependencies : Array[String] = [
  "org.eclipse.elk.core", "org.eclipse.elk.graph", "org.eclipse.elk.alg.common",
  "com.google.guava",
]

///|
let algorithm_plugin_content_wizard_xtext_nature : String = "org.eclipse.xtext.ui.shared.xtextNature"

///|
pub(all) struct CoreDebugWizardProject {
  id : String
  folders : Array[String]
  files : Map[String, String]
  natures : Array[String]
}

///|
pub fn new_core_debug_wizard_project(
  id : String,
  natures? : Array[String] = [],
) -> CoreDebugWizardProject {
  { id, folders: [], files: {}, natures: natures.copy() }
}

///|
pub fn CoreDebugWizardProject::add_folder(
  self : CoreDebugWizardProject,
  folder : String,
) -> Unit {
  for existing in self.folders {
    if existing == folder {
      return
    }
  }
  self.folders.push(folder)
}

///|
pub fn CoreDebugWizardProject::put_file(
  self : CoreDebugWizardProject,
  path : String,
  content : String,
) -> Unit {
  self.files[path] = content
}

///|
pub fn CoreDebugWizardProject::get_file(
  self : CoreDebugWizardProject,
  path : String,
) -> String? {
  self.files.get(path)
}

///|
pub fn CoreDebugWizardProject::has_folder(
  self : CoreDebugWizardProject,
  path : String,
) -> Bool {
  for folder in self.folders {
    if folder == path {
      return true
    }
  }
  false
}

///|
pub fn CoreDebugWizardProject::has_nature(
  self : CoreDebugWizardProject,
  nature : String,
) -> Bool {
  for current in self.natures {
    if current == nature {
      return true
    }
  }
  false
}

///|
pub fn CoreDebugWizardProject::add_nature(
  self : CoreDebugWizardProject,
  nature : String,
) -> Unit {
  if !self.has_nature(nature) {
    self.natures.push(nature)
  }
}

///|
pub(all) struct AlgorithmPluginContentWizard {
  mut id : String
  mut plug_in_name : String
  mut algorithm_name : String
  mut page : AlgorithmProjectCreationPage?
}

///|
pub fn new_algorithm_plugin_content_wizard(
  id : String,
  plug_in_name : String,
) -> AlgorithmPluginContentWizard {
  { id, plug_in_name, algorithm_name: "", page: None }
}

///|
pub fn AlgorithmPluginContentWizard::init(
  self : AlgorithmPluginContentWizard,
  id : String,
  plug_in_name : String,
) -> Unit {
  self.id = id
  self.plug_in_name = plug_in_name
}

///|
pub fn AlgorithmPluginContentWizard::add_pages(
  self : AlgorithmPluginContentWizard,
) -> Unit {
  self.page = Some(new_algorithm_project_creation_page(self.plug_in_name))
}

///|
pub fn AlgorithmPluginContentWizard::get_page_for_test(
  self : AlgorithmPluginContentWizard,
) -> AlgorithmProjectCreationPage? {
  self.page
}

///|
pub fn AlgorithmPluginContentWizard::get_dependencies(
  _self : AlgorithmPluginContentWizard,
) -> Array[String] {
  algorithm_plugin_content_wizard_plugin_dependencies.copy()
}

///|
pub fn AlgorithmPluginContentWizard::get_new_files(
  _self : AlgorithmPluginContentWizard,
) -> Array[String] {
  []
}

///|
pub fn AlgorithmPluginContentWizard::perform_finish(
  self : AlgorithmPluginContentWizard,
) -> Bool {
  match self.page {
    Some(page) => !page.get_algorithm_name().trim().is_empty()
    None => false
  }
}

///|
fn algorithm_plugin_content_wizard_capitalize(name : String) -> String {
  if name.is_empty() {
    ""
  } else {
    name.unsafe_substring(start=0, end=1).to_upper() +
    name.unsafe_substring(start=1, end=name.length())
  }
}

///|
fn AlgorithmPluginContentWizard::create_base_package(
  self : AlgorithmPluginContentWizard,
  project : CoreDebugWizardProject,
) -> Unit {
  let mut path = "src/"
  for part in self.id.split(".") {
    let as_string = part.to_owned()
    project.add_folder(path + as_string)
    path = path + as_string + "/"
  }
}

///|
fn AlgorithmPluginContentWizard::create_layout_provider(
  self : AlgorithmPluginContentWizard,
  project : CoreDebugWizardProject,
) -> Unit {
  let content = layout_provider_template_build_file_content(
    self.id,
    self.algorithm_name,
  )
  let path = "/src/" +
    self.id.replace_all(old=".", new="/") +
    "/" +
    self.algorithm_name +
    "LayoutProvider.java"
  project.put_file(path, content)
}

///|
fn AlgorithmPluginContentWizard::create_melk_file(
  self : AlgorithmPluginContentWizard,
  project : CoreDebugWizardProject,
) -> Unit {
  let content = melk_template_build_file_content(
    self.id,
    self.id,
    self.algorithm_name + "LayoutProvider",
    self.id,
    self.algorithm_name,
    self.algorithm_name,
  )
  let path = "/src/" +
    self.id.replace_all(old=".", new="/") +
    "/" +
    self.plug_in_name +
    ".melk"
  project.put_file(path, content)
}

///|
fn AlgorithmPluginContentWizard::create_service_file(
  self : AlgorithmPluginContentWizard,
  project : CoreDebugWizardProject,
) -> Unit {
  project.add_folder("/src/META-INF")
  project.add_folder("/src/META-INF/services")
  let path = "/src/META-INF/services/org.eclipse.elk.core.data.ILayoutMetaDataProvider"
  project.put_file(
    path,
    self.id + "." + self.algorithm_name + "MetadataProvider",
  )
}

///|
fn algorithm_plugin_content_wizard_add_xtext_nature(
  project : CoreDebugWizardProject,
) -> Unit {
  project.add_nature(algorithm_plugin_content_wizard_xtext_nature)
}

///|
pub fn AlgorithmPluginContentWizard::perform_finish_with_project(
  self : AlgorithmPluginContentWizard,
  project : CoreDebugWizardProject,
) -> Bool {
  let candidate_name = match self.page {
    Some(page) => page.get_algorithm_name().trim().to_owned()
    None => ""
  }
  if !candidate_name.is_empty() {
    self.algorithm_name = algorithm_plugin_content_wizard_capitalize(
      candidate_name,
    )
  } else {
    self.algorithm_name = algorithm_plugin_content_wizard_capitalize(
      self.plug_in_name,
    )
  }

  self.create_base_package(project)
  self.create_layout_provider(project)
  self.create_melk_file(project)
  self.create_service_file(project)
  algorithm_plugin_content_wizard_add_xtext_nature(project)
  true
}
