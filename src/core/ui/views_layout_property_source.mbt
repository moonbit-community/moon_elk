///|
pub(all) struct LayoutPropertySource {
  layout_config : @service.ILayoutConfigurationStore
  mut property_descriptors : Array[LayoutPropertyDescriptor]?
  dependency_options : Map[String, Unit]
  config_manager : @service.LayoutConfigurationManager
  mut layout_option_validator : @core.LayoutOptionValidator?
}

///|
pub fn new_layout_property_source(
  config : @service.ILayoutConfigurationStore,
  manager : @service.LayoutConfigurationManager,
) -> LayoutPropertySource {
  {
    layout_config: config,
    property_descriptors: None,
    dependency_options: {},
    config_manager: manager,
    layout_option_validator: None,
  }
}

///|
pub fn LayoutPropertySource::set_validator(
  self : LayoutPropertySource,
  validator : @core.LayoutOptionValidator,
) -> Unit {
  self.layout_option_validator = Some(validator)
}

///|
pub fn LayoutPropertySource::get_layout_config(
  self : LayoutPropertySource,
) -> @service.ILayoutConfigurationStore {
  self.layout_config
}

///|
fn layout_property_source_contains_option(
  values : Array[@core.LayoutOptionData],
  option_id : String,
) -> Bool {
  for value in values {
    if value.get_id() == option_id {
      return true
    }
  }
  false
}

///|
fn layout_property_source_matches_dependency(
  source : LayoutPropertySource,
  dependency : @core.LayoutOptionDependency,
) -> Bool {
  match
    @core.layout_meta_data_service_get_option_data_opt(dependency.get_option_id()) {
    Some(target_option) =>
      match
        source.config_manager.get_option_value(
          target_option,
          source.layout_config,
        ) {
        Some(actual_value) =>
          match dependency.get_expected_value() {
            Some(expected_value) => actual_value == expected_value
            None => true
          }
        None => false
      }
    None => false
  }
}

///|
fn layout_property_source_is_hidden(
  visibility : @core.LayoutOptionVisibility,
) -> Bool {
  match visibility {
    @core.HiddenOption => true
    _ => false
  }
}

///|
fn layout_property_source_filter_options(
  source : LayoutPropertySource,
  option_data : Array[@core.LayoutOptionData],
) -> Array[@core.LayoutOptionData] {
  source.dependency_options[@core.algorithm.get_id()] = ()
  let visible_options : Array[@core.LayoutOptionData] = []
  for option in option_data {
    let mut visible = !layout_property_source_is_hidden(option.get_visibility())
    if visible {
      let dependencies = option.get_dependencies()
      visible = dependencies.is_empty()
      for dependency in dependencies {
        source.dependency_options[dependency.get_option_id()] = ()
        if layout_property_source_matches_dependency(source, dependency) {
          visible = true
          break
        }
      }
    }
    if visible &&
      !layout_property_source_contains_option(visible_options, option.get_id()) {
      visible_options.push(option)
    }
  }
  visible_options
}

///|
pub fn LayoutPropertySource::get_property_descriptors(
  self : LayoutPropertySource,
) -> Array[LayoutPropertyDescriptor] {
  match self.property_descriptors {
    Some(descriptors) => descriptors
    None => {
      let supported_options = self.config_manager.get_supported_options(
        self.layout_config,
      )
      let filtered_options = layout_property_source_filter_options(
        self, supported_options,
      )
      let descriptors : Array[LayoutPropertyDescriptor] = []
      for option_data in filtered_options {
        descriptors.push(
          new_layout_property_descriptor(
            self,
            option_data,
            Some(self.layout_config.get_option_targets()),
          ),
        )
      }
      self.property_descriptors = Some(descriptors)
      descriptors
    }
  }
}

///|
fn layout_property_source_parse_bool(value : String) -> Bool {
  let normalized = value.trim().to_lower()
  normalized == "true" || normalized == "1" || normalized == "yes"
}

///|
fn layout_property_source_split_values(value : String) -> Array[String] {
  let normalized = value.replace(old=",", new=" ")
  let result : Array[String] = []
  for part in normalized.split(" ") {
    let trimmed = part.trim()
    if !trimmed.is_empty() {
      result.push(trimmed.to_string())
    }
  }
  result
}

///|
pub fn LayoutPropertySource::translate_to_ui(
  self : LayoutPropertySource,
  value : String?,
  option_data : @core.LayoutOptionData,
) -> CoreUiValue {
  ignore(self)
  let option_value = match value {
    Some(actual_value) => actual_value
    None => return CoreUiStringValue("")
  }
  match option_data.get_type() {
    @core.IntType => CoreUiStringValue(option_value)
    @core.DoubleType => CoreUiStringValue(option_value)
    @core.BoolType =>
      if layout_property_source_parse_bool(option_value) {
        CoreUiIntValue(1)
      } else {
        CoreUiIntValue(0)
      }
    @core.StringType => {
      if !option_data.get_choices().is_empty() {
        let choices = option_data.get_choices()
        for index = 0; index < choices.length(); index = index + 1 {
          if choices[index] == option_value {
            return CoreUiIntValue(index)
          }
        }
      }
      CoreUiStringValue(option_value)
    }
    @core.EnumSetType =>
      CoreUiStringsValue(layout_property_source_split_values(option_value))
    @core.ObjectType => CoreUiStringValue(option_value)
  }
}

///|
pub fn LayoutPropertySource::get_property_value(
  self : LayoutPropertySource,
  id : String,
) -> CoreUiValue {
  match @core.layout_meta_data_service_get_option_data_opt(id) {
    Some(option_data) =>
      self.translate_to_ui(
        self.config_manager.get_option_value(option_data, self.layout_config),
        option_data,
      )
    None => CoreUiNoValue
  }
}

///|
pub fn LayoutPropertySource::translate_from_ui(
  self : LayoutPropertySource,
  value : CoreUiValue,
  option_data : @core.LayoutOptionData,
) -> String {
  ignore(self)
  match option_data.get_type() {
    @core.StringType =>
      if !option_data.get_choices().is_empty() {
        match value {
          CoreUiIntValue(index) =>
            if index >= 0 && index < option_data.get_choices().length() {
              option_data.get_choices()[index]
            } else {
              ""
            }
          _ => core_ui_value_to_string(value)
        }
      } else {
        core_ui_value_to_string(value)
      }
    @core.BoolType =>
      match value {
        CoreUiIntValue(number) => if number == 1 { "true" } else { "false" }
        CoreUiBoolValue(flag) => if flag { "true" } else { "false" }
        _ => option_data.parse_value(core_ui_value_to_string(value))
      }
    @core.EnumSetType =>
      match value {
        CoreUiStringsValue(values) => option_data.parse_value(values.join(" "))
        CoreUiStringValue(text) => option_data.parse_value(text)
        _ => option_data.parse_value(core_ui_value_to_string(value))
      }
    _ => option_data.parse_value(core_ui_value_to_string(value))
  }
}

///|
pub fn LayoutPropertySource::set_property_value(
  self : LayoutPropertySource,
  id : String,
  value : CoreUiValue,
) -> Unit {
  match @core.layout_meta_data_service_get_option_data_opt(id) {
    Some(option_data) => {
      core_ui_elk_ui_util_run_model_change(
        () => {
          let translated = self.translate_from_ui(value, option_data)
          self.layout_config.set_option_value(
            option_data.get_id(),
            Some(translated),
          )
        },
        editing_domain=self.layout_config.get_editing_domain(),
        label=core_ui_messages_get_string("elk.ui.11"),
      )
      if self.dependency_options.contains(id) {
        match layout_view_part_find_view() {
          Some(layout_view) => layout_view.refresh()
          None => ()
        }
      }
    }
    None => ()
  }
}

///|
pub fn LayoutPropertySource::validate_property_value(
  self : LayoutPropertySource,
  option_data : @core.LayoutOptionData,
  value : String,
) -> Array[@core.GraphIssue]? {
  match self.layout_option_validator {
    Some(validator) => Some(validator.check_property(option_data, value))
    None => None
  }
}

///|
pub fn LayoutPropertySource::get_editable_value(
  self : LayoutPropertySource,
) -> CoreUiValue {
  ignore(self)
  CoreUiNoValue
}

///|
pub fn LayoutPropertySource::is_property_set(
  self : LayoutPropertySource,
  id : String,
) -> Bool {
  self.layout_config.get_option_value(id) is Some(_)
}

///|
pub fn LayoutPropertySource::reset_property_value(
  self : LayoutPropertySource,
  id : String,
) -> Unit {
  core_ui_elk_ui_util_run_model_change(
    () => self.layout_config.set_option_value(id, None),
    editing_domain=self.layout_config.get_editing_domain(),
    label=core_ui_messages_get_string("elk.ui.12"),
  )
  if self.dependency_options.contains(id) {
    match layout_view_part_find_view() {
      Some(layout_view) => layout_view.refresh()
      None => ()
    }
  }
}

///|
pub fn core_ui_layout_property_source_get_layout_hint(
  displayed_name : String,
) -> String? {
  let mut best_hint : String? = None
  let mut best_length = 0
  for layouter_data in @core.layout_meta_data_service_algorithm_data_values() {
    let name = layouter_data.get_name()
    if displayed_name.has_prefix(name) && name.length() > best_length {
      best_hint = Some(layouter_data.get_id())
      best_length = name.length()
    }
  }
  best_hint
}
