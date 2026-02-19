///|
pub type GmfRunnable = () -> Unit

///|
pub struct ElkLayoutProvider {
  unit : Unit
}

///|
pub fn new_elk_layout_provider() -> ElkLayoutProvider {
  { unit: () }
}

///|
pub fn ElkLayoutProvider::provides(
  _self : ElkLayoutProvider,
  operation : GmfOperation,
) -> Bool {
  operation == LayoutNodeOperation
}

///|
fn elk_layout_provider_is_layoutable_shape(edit_part : GmfEditPart?) -> Bool {
  match edit_part {
    Some(value) => {
      let kind = gmf_edit_part_kind(value)
      kind == ShapeNodeEditPart &&
      kind != AbstractBorderItemEditPart &&
      kind != AbstractImageEditPart
    }
    None => false
  }
}

///|
fn elk_layout_provider_find_edit_part(
  parent : GmfEditPart,
  notation_node : String,
) -> GmfEditPart? {
  gmf_find_edit_part_by_notation_node(parent, notation_node)
}

///|
pub fn ElkLayoutProvider::can_layout_nodes(
  _self : ElkLayoutProvider,
  layout_nodes : Array[GmfLayoutNode],
  _should_offset_from_bounding_box : Bool,
  layout_hint : GmfLayoutHint,
) -> Bool {
  let parent = layout_hint.get_graphical_edit_part()
  match parent {
    None => false
    Some(parent_edit_part) =>
      if layout_nodes.is_empty() {
        for child in gmf_edit_part_children(parent_edit_part) {
          let child_kind = gmf_edit_part_kind(child)
          if child_kind == ShapeNodeEditPart &&
            child_kind != AbstractBorderItemEditPart &&
            child_kind != AbstractImageEditPart {
            return true
          }
        }
        false
      } else {
        for layout_node in layout_nodes {
          let edit_part = elk_layout_provider_find_edit_part(
            parent_edit_part,
            layout_node.get_node(),
          )
          if elk_layout_provider_is_layoutable_shape(edit_part) {
            return true
          }
        }
        false
      }
  }
}

///|
pub fn ElkLayoutProvider::layout_layout_nodes(
  _self : ElkLayoutProvider,
  layout_nodes : Array[GmfLayoutNode],
  _offset_from_bounding_box : Bool,
  layout_hint : GmfLayoutHint,
) -> GmfRunnable {
  let zoom_to_fit = gmf_get_boolean_preference(
    "org.eclipse.elk.core.ui", "org.eclipse.elk.zoomToFit", false,
  )
  let progress_dialog = gmf_get_boolean_preference(
    "org.eclipse.elk.core.ui", "org.eclipse.elk.progressDialog", false,
  )

  let diagram_part : GmfDiagramPart = if layout_nodes.is_empty() {
    match layout_hint.get_graphical_edit_part() {
      Some(edit_part) => Single(edit_part)
      None => NoPart
    }
  } else {
    let part_list : Array[GmfEditPart] = []
    match layout_hint.get_graphical_edit_part() {
      Some(parent) =>
        for layout_node in layout_nodes {
          match
            elk_layout_provider_find_edit_part(parent, layout_node.get_node()) {
            Some(edit_part) => part_list.push(edit_part)
            None => ()
          }
        }
      None => ()
    }
    Multiple(part_list)
  }

  () => {
    gmf_diagram_layout_engine_invoke_layout(
      diagram_part, progress_dialog, zoom_to_fit,
    )
  }
}
