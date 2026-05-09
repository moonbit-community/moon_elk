///|
pub let core_ui_layout_view_id : String = "org.eclipse.elk.core.views.layout"

///|
pub let core_ui_layout_view_pref_categories : String = "view.categories"

///|
pub let core_ui_layout_view_pref_advanced : String = "view.advanced"

///|
pub(all) struct LayoutViewPart {
  mut current_prop_source_provider : LayoutPropertySourceProvider?
  mut categories_checked : Bool
  mut advanced_checked : Bool
  mut refresh_count : Int
  mut selection_entries : Array[ValidatingPropertySheetEntry]
  mut focused : Bool
}

///|
let core_ui_layout_view_instance_ref : Ref[LayoutViewPart?] = Ref(None)

///|
pub fn new_layout_view_part() -> LayoutViewPart {
  {
    current_prop_source_provider: None,
    categories_checked: true,
    advanced_checked: false,
    refresh_count: 0,
    selection_entries: [],
    focused: false,
  }
}

///|
pub fn layout_view_part_open() -> LayoutViewPart {
  match core_ui_layout_view_instance_ref.val {
    Some(view) => view
    None => {
      let view = new_layout_view_part()
      view.create_part_control()
      core_ui_layout_view_instance_ref.val = Some(view)
      view
    }
  }
}

///|
pub fn layout_view_part_find_view() -> LayoutViewPart? {
  core_ui_layout_view_instance_ref.val
}

///|
pub fn LayoutViewPart::create_part_control(self : LayoutViewPart) -> Unit {
  let preference_store = elk_ui_plugin_get_instance().get_preference_store()
  self.categories_checked = preference_store.get_boolean(
    core_ui_layout_view_pref_categories,
  )
  self.advanced_checked = preference_store.get_boolean(
    core_ui_layout_view_pref_advanced,
  )
}

///|
pub fn LayoutViewPart::set_focus(self : LayoutViewPart) -> Unit {
  self.focused = true
}

///|
pub fn LayoutViewPart::is_focused(self : LayoutViewPart) -> Bool {
  self.focused
}

///|
pub fn LayoutViewPart::set_property_source_provider(
  self : LayoutViewPart,
  provider : LayoutPropertySourceProvider?,
) -> Unit {
  self.current_prop_source_provider = provider
}

///|
pub fn LayoutViewPart::get_property_source_provider(
  self : LayoutViewPart,
) -> LayoutPropertySourceProvider? {
  self.current_prop_source_provider
}

///|
pub fn LayoutViewPart::refresh(self : LayoutViewPart) -> Unit {
  self.refresh_count = self.refresh_count + 1
}

///|
pub fn LayoutViewPart::get_refresh_count(self : LayoutViewPart) -> Int {
  self.refresh_count
}

///|
pub fn LayoutViewPart::set_selection(
  self : LayoutViewPart,
  entries : Array[ValidatingPropertySheetEntry],
) -> Unit {
  self.selection_entries = entries
}

///|
pub fn LayoutViewPart::get_selection(
  self : LayoutViewPart,
) -> Array[ValidatingPropertySheetEntry] {
  self.selection_entries
}

///|
pub fn LayoutViewPart::set_categories_checked(
  self : LayoutViewPart,
  checked : Bool,
) -> Unit {
  self.categories_checked = checked
}

///|
pub fn LayoutViewPart::set_advanced_checked(
  self : LayoutViewPart,
  checked : Bool,
) -> Unit {
  self.advanced_checked = checked
}

///|
pub fn LayoutViewPart::get_toolbar_state(self : LayoutViewPart) -> (Bool, Bool) {
  (self.categories_checked, self.advanced_checked)
}

///|
pub fn LayoutViewPart::dispose(self : LayoutViewPart) -> Unit {
  let preference_store = elk_ui_plugin_get_instance().get_preference_store()
  preference_store.set_boolean(
    core_ui_layout_view_pref_categories,
    self.categories_checked,
  )
  preference_store.set_boolean(
    core_ui_layout_view_pref_advanced,
    self.advanced_checked,
  )
  self.current_prop_source_provider = None
  self.selection_entries = []
  core_ui_layout_view_instance_ref.val = None
}

///|
pub fn core_ui_layout_view_part_reset_for_test() -> Unit {
  core_ui_layout_view_instance_ref.val = None
}
