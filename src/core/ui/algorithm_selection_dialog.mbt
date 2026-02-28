///|
pub(all) struct CoreUiAlgorithmSelectionListener {
  id : Int
  on_selection_fn : (CoreUiLayoutMetaData) -> Unit
}

///|
let core_ui_algorithm_selection_listener_id_ref : Ref[Int] = Ref::new(1)

///|
pub fn new_core_ui_algorithm_selection_listener(
  on_selection_fn : (CoreUiLayoutMetaData) -> Unit,
) -> CoreUiAlgorithmSelectionListener {
  let id = core_ui_algorithm_selection_listener_id_ref.val
  core_ui_algorithm_selection_listener_id_ref.val = id + 1
  { id, on_selection_fn }
}

///|
pub(all) struct AlgorithmSelectionDialog {
  mut layouter_hint : String
  mut display_name : String
  mut description : String
  mut image : CoreUiImageDescriptor?
  content_provider : AlgorithmContentProvider
  image_cache : Map[String, CoreUiImageDescriptor]
  mut selection_listeners : Array[CoreUiAlgorithmSelectionListener]
  mut selected_data : CoreUiLayoutMetaData?
  mut ok_enabled : Bool
  mut filter_text : String
  mut shell_text : String
}

///|
pub fn new_algorithm_selection_dialog(
  current_hint : String,
) -> AlgorithmSelectionDialog {
  {
    layouter_hint: current_hint,
    display_name: "",
    description: "",
    image: None,
    content_provider: new_algorithm_content_provider(),
    image_cache: {},
    selection_listeners: [],
    selected_data: None,
    ok_enabled: false,
    filter_text: "",
    shell_text: core_ui_messages_get_string("elk.ui.58"),
  }
}

///|
pub fn AlgorithmSelectionDialog::configure_shell(
  self : AlgorithmSelectionDialog,
) -> Unit {
  self.shell_text = core_ui_messages_get_string("elk.ui.58")
}

///|
pub fn AlgorithmSelectionDialog::get_shell_text(
  self : AlgorithmSelectionDialog,
) -> String {
  self.shell_text
}

///|
pub fn AlgorithmSelectionDialog::add_algorithm_selection_listener(
  self : AlgorithmSelectionDialog,
  listener : CoreUiAlgorithmSelectionListener,
) -> Unit {
  self.selection_listeners.push(listener)
}

///|
pub fn AlgorithmSelectionDialog::remove_algorithm_selection_listener(
  self : AlgorithmSelectionDialog,
  listener : CoreUiAlgorithmSelectionListener,
) -> Unit {
  let kept : Array[CoreUiAlgorithmSelectionListener] = []
  for current in self.selection_listeners {
    if current.id != listener.id {
      kept.push(current)
    }
  }
  self.selection_listeners = kept
}

///|
fn algorithm_selection_dialog_notify(
  dialog : AlgorithmSelectionDialog,
  selected : CoreUiLayoutMetaData,
) -> Unit {
  for listener in dialog.selection_listeners {
    (listener.on_selection_fn)(selected)
  }
}

///|
fn algorithm_selection_dialog_create_image_descriptor(
  bundle_id : String,
  path : String,
) -> CoreUiImageDescriptor {
  { plugin_id: bundle_id, path: "scaled:" + path }
}

///|
pub fn AlgorithmSelectionDialog::update_value(
  self : AlgorithmSelectionDialog,
  layout_data : CoreUiLayoutMetaData,
) -> Unit {
  self.selected_data = Some(layout_data)
  self.layouter_hint = core_ui_layout_meta_data_get_id(layout_data)

  let raw_name = core_ui_layout_meta_data_get_name(layout_data)
  self.display_name = if raw_name.is_empty() {
    match layout_data {
      CoreUiLayoutAlgorithmMeta(_) => core_ui_messages_get_string("elk.ui.61")
      CoreUiLayoutCategoryMeta(_) => core_ui_messages_get_string("elk.ui.8")
    }
  } else {
    raw_name
  }

  let raw_description = core_ui_layout_meta_data_get_description(layout_data)
  self.description = if raw_description.is_empty() {
    core_ui_messages_get_string("elk.ui.60")
  } else {
    raw_description
  }

  match layout_data {
    CoreUiLayoutAlgorithmMeta(algorithm_data) => {
      let key = algorithm_data.get_id()
      match self.image_cache.get(key) {
        Some(cached) => self.image = Some(cached)
        None => {
          let preview_path = algorithm_data.get_preview_image_path()
          let bundle_id = algorithm_data.get_defining_bundle_id()
          if !preview_path.is_empty() && !bundle_id.is_empty() {
            let descriptor = algorithm_selection_dialog_create_image_descriptor(
              bundle_id, preview_path,
            )
            self.image_cache[key] = descriptor
            self.image = Some(descriptor)
          } else {
            self.image = None
          }
        }
      }
      self.ok_enabled = true
    }
    CoreUiLayoutCategoryMeta(_) => {
      self.image = None
      self.ok_enabled = false
    }
  }

  algorithm_selection_dialog_notify(self, layout_data)
}

///|
fn algorithm_selection_dialog_find_by_hint(
  hint : String,
) -> CoreUiLayoutMetaData? {
  match @core.layout_meta_data_service_get_algorithm_data_by_suffix(hint) {
    Some(algorithm_data) => Some(CoreUiLayoutAlgorithmMeta(algorithm_data))
    None =>
      match @core.layout_meta_data_service_get_category_data(hint) {
        Some(category_data) => Some(CoreUiLayoutCategoryMeta(category_data))
        None => None
      }
  }
}

///|
pub fn AlgorithmSelectionDialog::create_dialog_area(
  self : AlgorithmSelectionDialog,
) -> Unit {
  self.content_provider.update_filter(None)
  self.filter_text = ""
  if !self.layouter_hint.is_empty() {
    match algorithm_selection_dialog_find_by_hint(self.layouter_hint) {
      Some(layout_data) => self.update_value(layout_data)
      None => ()
    }
  }
}

///|
pub fn AlgorithmSelectionDialog::update_filter_text(
  self : AlgorithmSelectionDialog,
  text : String,
) -> Unit {
  self.filter_text = text
  self.content_provider.update_filter(Some(text))
  for element in self.content_provider.get_elements() {
    ignore(self.content_provider.apply_filter(element))
    for child in self.content_provider.get_children(element) {
      ignore(self.content_provider.apply_filter(child))
    }
  }
  match self.content_provider.get_best_filter_match() {
    Some(best) => self.update_value(best)
    None => ()
  }
}

///|
pub fn AlgorithmSelectionDialog::select(
  self : AlgorithmSelectionDialog,
  layout_data : CoreUiLayoutMetaData,
) -> Unit {
  self.update_value(layout_data)
}

///|
pub fn AlgorithmSelectionDialog::get_selected_hint(
  self : AlgorithmSelectionDialog,
) -> String {
  self.layouter_hint
}

///|
pub fn AlgorithmSelectionDialog::get_display_name(
  self : AlgorithmSelectionDialog,
) -> String {
  self.display_name
}

///|
pub fn AlgorithmSelectionDialog::get_description(
  self : AlgorithmSelectionDialog,
) -> String {
  self.description
}

///|
pub fn AlgorithmSelectionDialog::get_image(
  self : AlgorithmSelectionDialog,
) -> CoreUiImageDescriptor? {
  self.image
}

///|
pub fn AlgorithmSelectionDialog::is_ok_enabled(
  self : AlgorithmSelectionDialog,
) -> Bool {
  self.ok_enabled
}

///|
pub fn AlgorithmSelectionDialog::get_filter_text(
  self : AlgorithmSelectionDialog,
) -> String {
  self.filter_text
}

///|
pub fn AlgorithmSelectionDialog::close(self : AlgorithmSelectionDialog) -> Bool {
  self.image = None
  self.image_cache.clear()
  true
}
