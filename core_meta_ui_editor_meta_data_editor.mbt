///|
pub struct MetaDataEditor {
  unit : Unit
}

///|
pub fn new_meta_data_editor() -> MetaDataEditor {
  { unit: () }
}

///|
pub fn MetaDataEditor::get_base_class_name(self : MetaDataEditor) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.editor.XbaseEditor"
}
