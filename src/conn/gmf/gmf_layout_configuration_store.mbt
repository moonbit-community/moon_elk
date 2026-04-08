///|
pub let gmf_layout_configuration_prefix : String = "layout:"

///|
pub let gmf_core_option_comment_box_id : String = "org.eclipse.elk.commentBox"

///|
pub enum GmfLayoutOptionTarget {
  Ports
  Nodes
  Parents
  Edges
  Labels
} derive(Eq, Debug)

///|
pub impl Show for GmfLayoutOptionTarget with output(self, logger) {
  logger.write_string(to_repr(self).to_string())
}

///|
pub struct GmfLayoutConfigurationStoreProvider {
  edit_part_filter : IEditPartFilter
}

///|
pub fn new_gmf_layout_configuration_store_provider(
  edit_part_filter : IEditPartFilter,
) -> GmfLayoutConfigurationStoreProvider {
  { edit_part_filter, }
}

///|
pub fn GmfLayoutConfigurationStoreProvider::get(
  self : GmfLayoutConfigurationStoreProvider,
  context : GmfEditPart?,
) -> GmfLayoutConfigurationStore? {
  match context {
    Some(edit_part) =>
      Some(new_gmf_layout_configuration_store(edit_part, self.edit_part_filter))
    None => None
  }
}

///|
pub struct GmfLayoutConfigurationStore {
  edit_part : GmfEditPart
  edit_part_filter : IEditPartFilter
}

///|
fn gmf_layout_configuration_store_resolve_context_edit_part(
  edit_part : GmfEditPart,
) -> GmfEditPart {
  let kind = gmf_edit_part_kind(edit_part)
  if kind == CompartmentEditPart || kind == ResizableCompartmentEditPart {
    match gmf_edit_part_parent(edit_part) {
      Some(parent) => parent
      None => edit_part
    }
  } else if kind == DiagramRootEditPart {
    let children = gmf_edit_part_children(edit_part)
    if children.is_empty() {
      edit_part
    } else {
      children[0]
    }
  } else {
    edit_part
  }
}

///|
pub fn new_gmf_layout_configuration_store(
  edit_part : GmfEditPart,
  edit_part_filter : IEditPartFilter,
) -> GmfLayoutConfigurationStore {
  {
    edit_part: gmf_layout_configuration_store_resolve_context_edit_part(
      edit_part,
    ),
    edit_part_filter,
  }
}

///|
fn gmf_layout_configuration_store_get_default_options(
  store : GmfLayoutConfigurationStore,
) -> Map[String, String]? {
  if gmf_edit_part_kind(store.edit_part) == NoteEditPart {
    let defaults : Map[String, String] = {}
    defaults[gmf_core_option_comment_box_id] = "true"
    Some(defaults)
  } else {
    None
  }
}

///|
pub fn GmfLayoutConfigurationStore::get_option_value(
  self : GmfLayoutConfigurationStore,
  option_id : String,
) -> String? {
  match gmf_edit_part_notation_view(self.edit_part) {
    Some(view) => {
      let key = gmf_layout_configuration_prefix + option_id
      match gmf_view_get_style(view, key) {
        Some(value) => Some(value)
        None =>
          match gmf_layout_configuration_store_get_default_options(self) {
            Some(default_options) => default_options.get(option_id)
            None => None
          }
      }
    }
    None =>
      match gmf_layout_configuration_store_get_default_options(self) {
        Some(default_options) => default_options.get(option_id)
        None => None
      }
  }
}

///|
pub fn GmfLayoutConfigurationStore::set_option_value(
  self : GmfLayoutConfigurationStore,
  option_id : String,
  value : String?,
) -> Unit {
  match gmf_edit_part_notation_view(self.edit_part) {
    Some(view) => {
      let key = gmf_layout_configuration_prefix + option_id
      match value {
        Some(actual_value) => gmf_view_set_style(view, key, actual_value)
        None => gmf_view_remove_style(view, key)
      }
    }
    None => ()
  }
}

///|
pub fn GmfLayoutConfigurationStore::get_affected_options(
  self : GmfLayoutConfigurationStore,
) -> Array[String] {
  let options_map : Map[String, Bool] = {}
  match gmf_edit_part_notation_view(self.edit_part) {
    Some(view) =>
      for entry in gmf_view_style_entries(view) {
        if entry.0.has_prefix(gmf_layout_configuration_prefix) {
          match entry.0.strip_prefix(gmf_layout_configuration_prefix) {
            Some(option_id) => options_map[option_id.to_string()] = true
            None => ()
          }
        }
      }
    None => ()
  }
  match gmf_layout_configuration_store_get_default_options(self) {
    Some(default_options) =>
      for default_entry in default_options.to_array() {
        options_map[default_entry.0] = true
      }
    None => ()
  }
  let options : Array[String] = []
  for entry in options_map.to_array() {
    options.push(entry.0)
  }
  options
}

///|
pub fn GmfLayoutConfigurationStore::get_option_targets(
  self : GmfLayoutConfigurationStore,
) -> Array[GmfLayoutOptionTarget] {
  let kind = gmf_edit_part_kind(self.edit_part)
  if kind == AbstractBorderItemEditPart {
    [Ports]
  } else if kind == ShapeNodeEditPart {
    let targets : Array[GmfLayoutOptionTarget] = [Nodes]
    match
      gmf_layout_configuration_store_find_containing_edit_part(
        self,
        self.edit_part,
      ) {
      Some(_) => targets.push(Parents)
      None => ()
    }
    targets
  } else if kind == ConnectionEditPart {
    [Edges]
  } else if kind == LabelEditPart {
    [Labels]
  } else if kind == DiagramEditPart {
    [Parents]
  } else {
    []
  }
}

///|
fn gmf_layout_configuration_store_grand_parent(
  edit_part : GmfEditPart,
) -> GmfEditPart? {
  match gmf_edit_part_parent(edit_part) {
    Some(parent) => gmf_edit_part_parent(parent)
    None => None
  }
}

///|
fn gmf_layout_configuration_store_find_containing_edit_part(
  store : GmfLayoutConfigurationStore,
  node_edit_part : GmfEditPart,
) -> GmfEditPart? {
  for child in gmf_edit_part_children(node_edit_part) {
    if store.edit_part_filter.filter(child) {
      let child_kind = gmf_edit_part_kind(child)
      if child_kind == ShapeNodeEditPart {
        return Some(node_edit_part)
      } else if child_kind == CompartmentEditPart ||
        child_kind == ResizableCompartmentEditPart {
        for grand_child in gmf_edit_part_children(child) {
          if gmf_edit_part_kind(grand_child) == ShapeNodeEditPart &&
            store.edit_part_filter.filter(grand_child) {
            return Some(child)
          }
        }
      }
    }
  }
  None
}

///|
fn gmf_layout_configuration_store_get_container(
  store : GmfLayoutConfigurationStore,
) -> GmfEditPart? {
  let kind = gmf_edit_part_kind(store.edit_part)
  if kind == AbstractBorderItemEditPart {
    gmf_layout_configuration_store_grand_parent(store.edit_part)
  } else if kind == ShapeNodeEditPart {
    gmf_edit_part_parent(store.edit_part)
  } else if kind == ConnectionEditPart {
    match gmf_edit_part_source(store.edit_part) {
      Some(source_part) =>
        if gmf_edit_part_kind(source_part) == AbstractBorderItemEditPart {
          gmf_layout_configuration_store_grand_parent(source_part)
        } else {
          gmf_edit_part_parent(source_part)
        }
      None => None
    }
  } else if kind == LabelEditPart {
    match gmf_edit_part_parent(store.edit_part) {
      Some(container_edit_part) => {
        let container_kind = gmf_edit_part_kind(container_edit_part)
        if container_kind == ConnectionEditPart {
          match gmf_edit_part_source(container_edit_part) {
            Some(source_part) =>
              if gmf_edit_part_kind(source_part) == AbstractBorderItemEditPart {
                gmf_layout_configuration_store_grand_parent(source_part)
              } else {
                gmf_edit_part_parent(source_part)
              }
            None => None
          }
        } else if container_kind == AbstractBorderItemEditPart {
          gmf_layout_configuration_store_grand_parent(container_edit_part)
        } else if container_kind == ShapeNodeEditPart {
          gmf_edit_part_parent(container_edit_part)
        } else {
          Some(container_edit_part)
        }
      }
      None => None
    }
  } else {
    None
  }
}

///|
pub fn GmfLayoutConfigurationStore::get_parent(
  self : GmfLayoutConfigurationStore,
) -> GmfLayoutConfigurationStore? {
  match gmf_layout_configuration_store_get_container(self) {
    Some(container) =>
      Some(new_gmf_layout_configuration_store(container, self.edit_part_filter))
    None => None
  }
}

///|
pub fn GmfLayoutConfigurationStore::get_editing_domain(
  self : GmfLayoutConfigurationStore,
) -> GmfEditPart {
  self.edit_part
}
