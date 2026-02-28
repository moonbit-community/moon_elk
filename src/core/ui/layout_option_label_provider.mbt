///|
pub let core_ui_disco_layout_alg_id : String = "org.eclipse.elk.disco.componentCompaction.componentLayoutAlgorithm"

///|
pub(all) struct LayoutOptionLabelProvider {
  option_data : @core.LayoutOptionData
}

///|
pub fn new_layout_option_label_provider(
  option_data : @core.LayoutOptionData,
) -> LayoutOptionLabelProvider {
  { option_data, }
}

///|
fn layout_option_label_provider_is_true(value : CoreUiValue) -> Bool {
  match value {
    CoreUiBoolValue(flag) => flag
    CoreUiIntValue(number) => number == 1
    CoreUiStringValue(text) => text.to_lower() == "true" || text == "1"
    _ => true
  }
}

///|
fn layout_option_label_provider_algorithm_name(
  algorithm_id : String,
) -> String? {
  match
    @core.layout_meta_data_service_get_algorithm_data_by_suffix(algorithm_id) {
    Some(algorithm_data) => {
      let bundle_name = algorithm_data.get_bundle_name()
      if bundle_name.is_empty() {
        Some(algorithm_data.get_name())
      } else {
        Some(algorithm_data.get_name() + " (" + bundle_name + ")")
      }
    }
    None => None
  }
}

///|
fn layout_option_label_provider_is_algorithm_option(
  option_data : @core.LayoutOptionData,
) -> Bool {
  let option_id = option_data.get_id()
  option_id == @core.algorithm.get_id() ||
  option_id == core_ui_disco_layout_alg_id
}

///|
fn layout_option_label_provider_choice_at(
  option_data : @core.LayoutOptionData,
  index : Int,
) -> String? {
  let choices = option_data.get_choices()
  if index >= 0 && index < choices.length() {
    Some(choices[index])
  } else {
    None
  }
}

///|
pub fn LayoutOptionLabelProvider::get_image(
  self : LayoutOptionLabelProvider,
  element : CoreUiValue,
) -> CoreUiImageDescriptor? {
  let registry = elk_ui_plugin_get_instance().get_image_registry()
  match self.option_data.get_type() {
    @core.ObjectType => registry.get(elk_ui_img_text)
    @core.StringType =>
      if self.option_data.get_choices().is_empty() {
        registry.get(elk_ui_img_text)
      } else {
        registry.get(elk_ui_img_choice)
      }
    @core.BoolType =>
      if layout_option_label_provider_is_true(element) {
        registry.get(elk_ui_img_true)
      } else {
        registry.get(elk_ui_img_false)
      }
    @core.EnumSetType => registry.get(elk_ui_img_choice)
    @core.IntType => registry.get(elk_ui_img_int)
    @core.DoubleType => registry.get(elk_ui_img_double)
  }
}

///|
pub fn LayoutOptionLabelProvider::get_text(
  self : LayoutOptionLabelProvider,
  element : CoreUiValue,
) -> String {
  match self.option_data.get_type() {
    @core.StringType =>
      if layout_option_label_provider_is_algorithm_option(self.option_data) {
        match core_ui_value_as_string(element) {
          Some(algorithm_id) =>
            match layout_option_label_provider_algorithm_name(algorithm_id) {
              Some(name) => name
              None => core_ui_messages_get_string("elk.ui.8")
            }
          None => core_ui_value_to_string(element)
        }
      } else if !self.option_data.get_choices().is_empty() {
        match core_ui_value_as_int(element) {
          Some(index) =>
            match
              layout_option_label_provider_choice_at(self.option_data, index) {
              Some(choice) => choice
              None => core_ui_value_to_string(element)
            }
          None => core_ui_value_to_string(element)
        }
      } else {
        core_ui_value_to_string(element)
      }
    @core.BoolType =>
      match core_ui_value_as_bool(element) {
        Some(flag) => if flag { "true" } else { "false" }
        None => core_ui_value_to_string(element)
      }
    @core.EnumSetType =>
      match element {
        CoreUiStringValue(text) => text
        CoreUiStringsValue(values) =>
          if values.is_empty() {
            ""
          } else {
            values.join(", ")
          }
        _ => core_ui_value_to_string(element)
      }
    _ => core_ui_value_to_string(element)
  }
}
