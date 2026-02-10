///|
fn expect_some_string(value : String?) -> String {
  match value {
    Some(text) => text
    None => abort("Expected Some(String)")
  }
}

///|
test "AlgorithmProjectCreationPage tracks completion and algorithm name" {
  let page = new_algorithm_project_creation_page("sample")
  inspect(page.get_algorithm_name(), content="sample")
  inspect(page.is_page_complete(), content="true")

  page.set_algorithm_name("")
  inspect(page.is_page_complete(), content="false")

  page.set_algorithm_name("myAlgorithm")
  inspect(page.get_algorithm_name(), content="myAlgorithm")
}

///|
test "Wizard templates include key generated snippets" {
  let layout_provider = layout_provider_template_build_file_content(
    "org.example", "Demo",
  )
  inspect(layout_provider.contains("class DemoLayoutProvider"), content="true")
  inspect(
    layout_provider.contains("progressMonitor.begin(\"Demo\""),
    content="true",
  )

  let melk = melk_template_build_file_content(
    "org.example", "org.example", "DemoLayoutProvider", "org.example", "Demo", "Demo",
  )
  inspect(melk.contains("algorithm Demo(DemoLayoutProvider)"), content="true")
  inspect(
    melk.contains("supports org.eclipse.elk.spacing.nodeNode = 10"),
    content="true",
  )
}

///|
test "AlgorithmPluginContentWizard generates project files and nature" {
  let wizard = new_algorithm_plugin_content_wizard("org.example.demo", "demo")
  wizard.add_pages()
  inspect(wizard.perform_finish(), content="true")
  inspect(
    wizard.get_dependencies(),
    content="[\"org.eclipse.elk.core\", \"org.eclipse.elk.graph\", \"org.eclipse.elk.alg.common\", \"com.google.guava\"]",
  )

  let project = new_core_debug_wizard_project("org.example.demo", natures=["n0"])
  inspect(wizard.perform_finish_with_project(project), content="true")
  inspect(project.has_folder("src/org"), content="true")
  inspect(project.has_folder("src/org/example"), content="true")
  inspect(project.has_folder("src/org/example/demo"), content="true")

  let layout_provider_path = "/src/org/example/demo/DemoLayoutProvider.java"
  let melk_path = "/src/org/example/demo/demo.melk"
  let service_path = "/src/META-INF/services/org.eclipse.elk.core.data.ILayoutMetaDataProvider"
  inspect(project.get_file(layout_provider_path) is Some(_), content="true")
  inspect(project.get_file(melk_path) is Some(_), content="true")
  inspect(project.get_file(service_path) is Some(_), content="true")
  inspect(
    expect_some_string(project.get_file(service_path)),
    content="org.example.demo.DemoMetadataProvider",
  )
  inspect(
    project.has_nature("org.eclipse.xtext.ui.shared.xtextNature"),
    content="true",
  )
}
