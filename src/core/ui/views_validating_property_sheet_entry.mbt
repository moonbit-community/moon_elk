///|
pub(all) struct ValidatingPropertySheetEntry {
  mut parent : ValidatingPropertySheetEntry?
  mut source : LayoutPropertySource?
  mut descriptor : LayoutPropertyDescriptor?
  mut values : Array[CoreUiValue]
  mut image : CoreUiImageDescriptor?
  mut description : String
}

///|
pub fn new_validating_property_sheet_entry() -> ValidatingPropertySheetEntry {
  {
    parent: None,
    source: None,
    descriptor: None,
    values: [],
    image: None,
    description: "",
  }
}

///|
pub fn ValidatingPropertySheetEntry::create_child_entry(
  self : ValidatingPropertySheetEntry,
) -> ValidatingPropertySheetEntry {
  let child = new_validating_property_sheet_entry()
  child.parent = Some(self)
  child
}

///|
pub fn ValidatingPropertySheetEntry::set_source(
  self : ValidatingPropertySheetEntry,
  source : LayoutPropertySource?,
) -> Unit {
  self.source = source
}

///|
pub fn ValidatingPropertySheetEntry::set_descriptor(
  self : ValidatingPropertySheetEntry,
  descriptor : LayoutPropertyDescriptor?,
) -> Unit {
  self.descriptor = descriptor
}

///|
pub fn ValidatingPropertySheetEntry::set_values(
  self : ValidatingPropertySheetEntry,
  values : Array[CoreUiValue],
) -> Unit {
  self.values = values
}

///|
pub fn ValidatingPropertySheetEntry::set_image(
  self : ValidatingPropertySheetEntry,
  image : CoreUiImageDescriptor?,
) -> Unit {
  self.image = image
}

///|
pub fn ValidatingPropertySheetEntry::set_description(
  self : ValidatingPropertySheetEntry,
  description : String,
) -> Unit {
  self.description = description
}

///|
pub fn ValidatingPropertySheetEntry::set_parent(
  self : ValidatingPropertySheetEntry,
  parent : ValidatingPropertySheetEntry?,
) -> Unit {
  self.parent = parent
}

///|
pub fn ValidatingPropertySheetEntry::get_parent(
  self : ValidatingPropertySheetEntry,
) -> ValidatingPropertySheetEntry? {
  self.parent
}

///|
pub fn ValidatingPropertySheetEntry::get_source(
  self : ValidatingPropertySheetEntry,
) -> LayoutPropertySource? {
  match self.source {
    Some(value) => Some(value)
    None =>
      match self.parent {
        Some(parent) => parent.get_source()
        None => None
      }
  }
}

///|
pub fn ValidatingPropertySheetEntry::validate(
  self : ValidatingPropertySheetEntry,
) -> Array[@core.GraphIssue] {
  match (self.get_source(), self.descriptor, self.values.length() > 0) {
    (Some(source), Some(descriptor), true) => {
      let option_data = descriptor.get_option_data()
      let option_value = source.translate_from_ui(self.values[0], option_data)
      match source.validate_property_value(option_data, option_value) {
        Some(issues) => issues
        None => []
      }
    }
    _ => []
  }
}

///|
fn validating_entry_overlay_key(base_image : CoreUiImageDescriptor) -> String {
  "error_overlay/" + base_image.to_string()
}

///|
pub fn ValidatingPropertySheetEntry::get_image(
  self : ValidatingPropertySheetEntry,
) -> CoreUiImageDescriptor? {
  let issues = self.validate()
  if issues.is_empty() {
    return self.image
  }
  match self.image {
    Some(base_image) => {
      let overlay_key = validating_entry_overlay_key(base_image)
      let registry = elk_ui_plugin_get_instance().get_image_registry()
      match registry.get(overlay_key) {
        Some(image) => Some(image)
        None => {
          let image = {
            plugin_id: elk_ui_plugin_id,
            path: "overlay:error_overlay.png|" + base_image.path,
          }
          registry.put(overlay_key, image)
          Some(image)
        }
      }
    }
    None => None
  }
}

///|
pub fn ValidatingPropertySheetEntry::get_description(
  self : ValidatingPropertySheetEntry,
) -> String {
  let issues = self.validate()
  if issues.is_empty() {
    self.description
  } else {
    let first_issue = issues[0]
    let mut text = @core.graph_issue_severity_get_user_string(
        first_issue.get_severity(),
      ) +
      ": " +
      first_issue.get_message()
    if issues.length() > 1 {
      text += " (" + (issues.length() - 1).to_string() + " more issues)"
    }
    text
  }
}
