///|
pub let core_ui_layout_property_descriptor_disco_layout_alg_id : String = core_ui_disco_layout_alg_id

///|
pub let core_ui_property_sheet_entry_filter_expert : String = "expert"

///|
pub(all) enum CoreUiPropertyEditorKind {
  CoreUiPropertyEditorText
  CoreUiPropertyEditorAlgorithm(String)
  CoreUiPropertyEditorCombo(Array[String])
  CoreUiPropertyEditorMultiple(Array[String], Bool)
}

///|
pub(all) struct CoreUiPropertyEditor {
  kind : CoreUiPropertyEditorKind
  validator : (CoreUiValue) -> String?
}

///|
pub fn new_core_ui_property_editor(
  kind : CoreUiPropertyEditorKind,
  validator? : (CoreUiValue) -> String? = _ => None,
) -> CoreUiPropertyEditor {
  { kind, validator }
}

///|
pub fn CoreUiPropertyEditor::validate(
  self : CoreUiPropertyEditor,
  value : CoreUiValue,
) -> String? {
  (self.validator)(value)
}

///|
pub(all) struct LayoutPropertyDescriptor {
  source : LayoutPropertySource
  option_data : @core.LayoutOptionData
  element_targets : Array[@core.LayoutOptionTarget]?
  mut label_provider : LayoutOptionLabelProvider?
}

///|
pub fn new_layout_property_descriptor(
  source : LayoutPropertySource,
  option_data : @core.LayoutOptionData,
  element_targets : Array[@core.LayoutOptionTarget]?,
) -> LayoutPropertyDescriptor {
  { source, option_data, element_targets, label_provider: None }
}

///|
fn layout_property_descriptor_is_algorithm_option(
  option_data : @core.LayoutOptionData,
) -> Bool {
  let option_id = option_data.get_id()
  option_id == @core.algorithm.get_id() ||
  option_id == core_ui_layout_property_descriptor_disco_layout_alg_id
}

///|
fn layout_property_descriptor_contains_target(
  values : Array[@core.LayoutOptionTarget],
  target : @core.LayoutOptionTarget,
) -> Bool {
  for value in values {
    if layout_property_descriptor_target_equals(value, target) {
      return true
    }
  }
  false
}

///|
fn layout_property_descriptor_target_equals(
  lhs : @core.LayoutOptionTarget,
  rhs : @core.LayoutOptionTarget,
) -> Bool {
  match lhs {
    ParentsTarget => rhs is ParentsTarget
    NodesTarget => rhs is NodesTarget
    EdgesTarget => rhs is EdgesTarget
    PortsTarget => rhs is PortsTarget
    LabelsTarget => rhs is LabelsTarget
  }
}

///|
fn layout_property_descriptor_get_enumeration_choices(
  data : @core.LayoutOptionData,
) -> Array[String] {
  let choices = data.get_choices()
  let result : Array[String] = []
  for choice in choices {
    let is_advanced = data.is_advanced_choice(choice)
    let is_experimental = data.is_experimental_choice(choice)
    if is_advanced && is_experimental {
      result.push(choice + " (advanced and experimental)")
    } else if is_advanced {
      result.push(choice + " (advanced)")
    } else if is_experimental {
      result.push(choice + " (experimental)")
    } else {
      result.push(choice)
    }
  }
  result
}

///|
fn layout_property_descriptor_get_choice_text(
  option_data : @core.LayoutOptionData,
) -> Array[String] {
  let choices = if option_data.get_choices().is_empty() {
    match option_data.get_type() {
      BoolType => ["false", "true"]
      _ => []
    }
  } else {
    option_data.get_choices()
  }
  choices
}

///|
pub fn LayoutPropertyDescriptor::create_property_editor(
  self : LayoutPropertyDescriptor,
) -> CoreUiPropertyEditor? {
  match self.option_data.get_type() {
    StringType =>
      if layout_property_descriptor_is_algorithm_option(self.option_data) {
        Some(
          new_core_ui_property_editor(
            CoreUiPropertyEditorAlgorithm(self.option_data.get_id()),
          ),
        )
      } else if !self.option_data.get_choices().is_empty() {
        Some(
          new_core_ui_property_editor(
            CoreUiPropertyEditorCombo(
              layout_property_descriptor_get_enumeration_choices(
                self.option_data,
              ),
            ),
          ),
        )
      } else {
        Some(new_core_ui_property_editor(CoreUiPropertyEditorText))
      }
    IntType =>
      Some(
        new_core_ui_property_editor(CoreUiPropertyEditorText, validator=value => {
          match value {
            CoreUiStringValue(text) =>
              match
                (
                  try? @strconv.parse_int(text) :
                  Result[Int, @strconv.StrConvError]) {
                Ok(parsed) =>
                  match
                    self.source.validate_property_value(
                      self.option_data,
                      parsed.to_string(),
                    ) {
                    Some(issues) =>
                      if issues.is_empty() {
                        None
                      } else {
                        Some(issues[0].get_message())
                      }
                    None => None
                  }
                Err(_) => Some(core_ui_messages_get_string("elk.ui.6"))
              }
            _ => Some(core_ui_messages_get_string("elk.ui.6"))
          }
        }),
      )
    DoubleType =>
      Some(
        new_core_ui_property_editor(CoreUiPropertyEditorText, validator=value => {
          match value {
            CoreUiStringValue(text) =>
              match
                (
                  try? @strconv.parse_double(text) :
                  Result[Double, @strconv.StrConvError]) {
                Ok(parsed) =>
                  match
                    self.source.validate_property_value(
                      self.option_data,
                      parsed.to_string(),
                    ) {
                    Some(issues) =>
                      if issues.is_empty() {
                        None
                      } else {
                        Some(issues[0].get_message())
                      }
                    None => None
                  }
                Err(_) => Some(core_ui_messages_get_string("elk.ui.7"))
              }
            _ => Some(core_ui_messages_get_string("elk.ui.7"))
          }
        }),
      )
    BoolType =>
      Some(
        new_core_ui_property_editor(
          CoreUiPropertyEditorCombo(
            layout_property_descriptor_get_choice_text(self.option_data),
          ),
        ),
      )
    EnumSetType =>
      Some(
        new_core_ui_property_editor(
          CoreUiPropertyEditorMultiple(
            layout_property_descriptor_get_enumeration_choices(self.option_data),
            true,
          ),
        ),
      )
    ObjectType => Some(new_core_ui_property_editor(CoreUiPropertyEditorText))
  }
}

///|
pub fn LayoutPropertyDescriptor::get_category(
  self : LayoutPropertyDescriptor,
) -> String? {
  let option_targets = self.option_data.get_targets()
  let targets = match self.element_targets {
    Some(values) => {
      let intersection : Array[@core.LayoutOptionTarget] = []
      for target in option_targets {
        if layout_property_descriptor_contains_target(values, target) {
          intersection.push(target)
        }
      }
      intersection
    }
    None => option_targets
  }
  if targets.length() == 1 {
    match targets[0] {
      ParentsTarget =>
        match self.element_targets {
          Some(values) =>
            if layout_property_descriptor_contains_target(values, NodesTarget) {
              Some(core_ui_messages_get_string("elk.ui.74"))
            } else {
              Some(core_ui_messages_get_string("elk.ui.73"))
            }
          None => Some(core_ui_messages_get_string("elk.ui.73"))
        }
      NodesTarget => Some(core_ui_messages_get_string("elk.ui.75"))
      EdgesTarget => Some(core_ui_messages_get_string("elk.ui.76"))
      PortsTarget => Some(core_ui_messages_get_string("elk.ui.77"))
      LabelsTarget => Some(core_ui_messages_get_string("elk.ui.78"))
    }
  } else {
    None
  }
}

///|
pub fn LayoutPropertyDescriptor::get_description(
  self : LayoutPropertyDescriptor,
) -> String {
  let description = self.option_data.get_description()
  let parts = Array::from_iter(description.split("."))
  if parts.length() > 1 && !parts[0].is_empty() {
    parts[0].to_string() + "."
  } else {
    description
  }
}

///|
pub fn LayoutPropertyDescriptor::get_long_description(
  self : LayoutPropertyDescriptor,
) -> String {
  self.option_data.get_description()
}

///|
pub fn LayoutPropertyDescriptor::get_display_name(
  self : LayoutPropertyDescriptor,
) -> String {
  self.option_data.get_name()
}

///|
pub fn LayoutPropertyDescriptor::get_filter_flags(
  self : LayoutPropertyDescriptor,
) -> Array[String]? {
  match self.option_data.get_visibility() {
    AdvancedOption => Some([core_ui_property_sheet_entry_filter_expert])
    _ => None
  }
}

///|
pub fn LayoutPropertyDescriptor::get_id(
  self : LayoutPropertyDescriptor,
) -> String {
  self.option_data.get_id()
}

///|
pub fn LayoutPropertyDescriptor::get_label_provider(
  self : LayoutPropertyDescriptor,
) -> LayoutOptionLabelProvider {
  match self.label_provider {
    Some(provider) => provider
    None => {
      let provider = new_layout_option_label_provider(self.option_data)
      self.label_provider = Some(provider)
      provider
    }
  }
}

///|
pub fn LayoutPropertyDescriptor::get_option_data(
  self : LayoutPropertyDescriptor,
) -> @core.LayoutOptionData {
  self.option_data
}

///|
pub fn LayoutPropertyDescriptor::is_compatible_with(
  self : LayoutPropertyDescriptor,
  another_property : LayoutPropertyDescriptor,
) -> Bool {
  self.option_data.get_id() == another_property.get_id()
}
