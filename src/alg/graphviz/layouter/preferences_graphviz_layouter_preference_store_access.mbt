///|
let graphviz_layouter_preference_store_access_ui_available_ref : Ref[Bool] = Ref::new(
  true,
)

///|
pub fn graphviz_layouter_preference_store_access_get_ui_save_int(
  name : String,
) -> Int {
  if graphviz_layouter_preference_store_access_ui_available_ref.val {
    graphviz_layouter_preference_store_get_instance()
    .get_preference_store()
    .get_int(name)
  } else {
    0
  }
}

///|
pub fn graphviz_layouter_preference_store_access_get_ui_save_string(
  name : String,
) -> String {
  if graphviz_layouter_preference_store_access_ui_available_ref.val {
    graphviz_layouter_preference_store_get_instance()
    .get_preference_store()
    .get_string(name)
  } else {
    ""
  }
}

///|
pub fn graphviz_layouter_preference_store_access_get_ui_save_boolean(
  name : String,
  if_failed : Bool,
) -> Bool {
  if graphviz_layouter_preference_store_access_ui_available_ref.val {
    graphviz_layouter_preference_store_get_instance()
    .get_preference_store()
    .get_boolean(name)
  } else {
    if_failed
  }
}

///|
pub fn graphviz_layouter_preference_store_access_set_ui_available_for_test(
  value : Bool,
) -> Unit {
  graphviz_layouter_preference_store_access_ui_available_ref.val = value
}

///|
pub fn graphviz_layouter_preference_store_access_reset_for_test() -> Unit {
  graphviz_layouter_preference_store_access_ui_available_ref.val = true
}
