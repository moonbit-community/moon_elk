///|
pub struct TextLayoutSetup {
  unit : Unit
}

///|
pub fn new_text_layout_setup() -> TextLayoutSetup {
  { unit: () }
}

///|
pub fn TextLayoutSetup::supports(
  self : TextLayoutSetup,
  language_name : String,
) -> Bool {
  ignore(self)
  language_name == graph_text_ui_language_name
}

///|
pub fn TextLayoutSetup::create_injector(
  self : TextLayoutSetup,
  default_module : String,
) -> String {
  ignore(self)
  default_module + "+TextLayoutModule"
}

///|
pub struct TextLayoutModule {
  unit : Unit
}

///|
pub fn new_text_layout_module() -> TextLayoutModule {
  { unit: () }
}

///|
pub fn TextLayoutModule::configure_connector_class(
  self : TextLayoutModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ui.layout.TextLayoutConnector"
}
