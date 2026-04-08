///|
pub(all) enum GmfSelectionItem {
  DiagramFile(String)
  OtherSelectionItem
} derive(Debug)

///|
pub struct LayoutDiagramFileHandler {
  unit : Unit
}

///|
pub suberror LayoutDiagramFileHandlerException {
  LayoutDiagramFileHandlerException(String)
} derive(Debug, ToJson)

///|
fn[T] layout_diagram_file_handler_raise(
  message : String,
) -> T raise LayoutDiagramFileHandlerException {
  raise LayoutDiagramFileHandlerException(message)
}

///|
pub fn new_layout_diagram_file_handler() -> LayoutDiagramFileHandler {
  { unit: () }
}

///|
let gmf_layout_file_diagram_store_ref : Ref[Map[String, GmfEditPart]] = Ref::new({},
)

///|
let gmf_layout_file_processed_store_ref : Ref[Map[String, Bool]] = Ref::new({})

///|
pub fn gmf_register_layout_diagram_file_for_test(
  file_path : String,
  diagram_edit_part : GmfEditPart,
) -> Unit {
  gmf_layout_file_diagram_store_ref.val[file_path] = diagram_edit_part
}

///|
pub fn gmf_layout_diagram_file_handler_reset_for_test() -> Unit {
  gmf_layout_file_diagram_store_ref.val.clear()
  gmf_layout_file_processed_store_ref.val.clear()
}

///|
pub fn gmf_layout_diagram_file_handler_was_processed_for_test(
  file_path : String,
) -> Bool {
  match gmf_layout_file_processed_store_ref.val.get(file_path) {
    Some(value) => value
    None => false
  }
}

///|
fn gmf_layout_diagram_file_handler_layout_diagram(
  file_path : String,
) -> Unit raise LayoutDiagramFileHandlerException {
  let diagram_edit_part = match
    gmf_layout_file_diagram_store_ref.val.get(file_path) {
    Some(diagram) => diagram
    None =>
      layout_diagram_file_handler_raise(
        "The selected file does not contain a diagram.",
      )
  }
  gmf_diagram_layout_engine_invoke_layout(
    Single(diagram_edit_part),
    false,
    false,
  )
  gmf_layout_file_processed_store_ref.val[file_path] = true
}

///|
pub fn LayoutDiagramFileHandler::execute(
  _self : LayoutDiagramFileHandler,
  selection : Array[GmfSelectionItem],
) -> Int raise LayoutDiagramFileHandlerException {
  let mut processed = 0
  for item in selection {
    match item {
      DiagramFile(path) => {
        gmf_layout_diagram_file_handler_layout_diagram(path)
        processed = processed + 1
      }
      OtherSelectionItem => ()
    }
  }
  processed
}
