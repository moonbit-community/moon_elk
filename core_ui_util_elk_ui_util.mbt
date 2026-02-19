///|
let core_ui_model_change_log_ref : Ref[Map[Int, Array[String]]] = Ref::new({})

///|
pub fn core_ui_elk_ui_util_reset_for_test() -> Unit {
  core_ui_model_change_log_ref.val.clear()
}

///|
pub fn core_ui_elk_ui_util_model_change_labels_for_domain(
  editing_domain : Int,
) -> Array[String] {
  match core_ui_model_change_log_ref.val.get(editing_domain) {
    Some(labels) => labels
    None => []
  }
}

///|
pub fn core_ui_elk_ui_util_run_model_change(
  runnable : () -> Unit,
  editing_domain? : Int? = None,
  label? : String = "",
) -> Unit {
  match editing_domain {
    Some(domain) => {
      let labels = match core_ui_model_change_log_ref.val.get(domain) {
        Some(existing) => existing
        None => []
      }
      labels.push(label)
      core_ui_model_change_log_ref.val[domain] = labels
      runnable()
    }
    None => runnable()
  }
}

///|
pub fn core_ui_elk_ui_util_get_option_data(
  provider_data : LayoutAlgorithmData,
  option_name : String,
) -> LayoutOptionData? {
  for option_data in layout_meta_data_service_option_data_values() {
    if option_data.get_name() == option_name &&
      provider_data.knows_option(option_data.get_id()) {
      return Some(option_data)
    }
  }
  None
}

///|
pub fn core_ui_elk_ui_util_get_option_data_from_providers(
  provider_data_array : Array[LayoutAlgorithmData],
  display_name : String,
) -> LayoutOptionData? {
  for provider_data in provider_data_array {
    match core_ui_elk_ui_util_get_option_data(provider_data, display_name) {
      Some(option_data) => return Some(option_data)
      None => ()
    }
  }
  layout_meta_data_service_get_option_data_opt(algorithm.get_id())
}
