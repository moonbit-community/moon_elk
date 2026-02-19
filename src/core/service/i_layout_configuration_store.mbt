///|
pub(all) struct ILayoutConfigurationStore {
  get_editing_domain_fn : () -> Int?
  get_option_value_fn : (String) -> String?
  set_option_value_fn : (String, String?) -> Unit
  get_affected_options_fn : () -> Array[String]
  get_option_targets_fn : () -> Array[@core.LayoutOptionTarget]
  get_parent_fn : () -> ILayoutConfigurationStore?
}

///|
pub fn new_layout_configuration_store(
  get_editing_domain_fn? : () -> Int? = () => None,
  get_option_value_fn? : (String) -> String? = _ => None,
  set_option_value_fn? : (String, String?) -> Unit = (_, _) => (),
  get_affected_options_fn? : () -> Array[String] = () => [],
  get_option_targets_fn? : () -> Array[@core.LayoutOptionTarget] = () => [],
  get_parent_fn? : () -> ILayoutConfigurationStore? = () => None,
) -> ILayoutConfigurationStore {
  {
    get_editing_domain_fn,
    get_option_value_fn,
    set_option_value_fn,
    get_affected_options_fn,
    get_option_targets_fn,
    get_parent_fn,
  }
}

///|
pub fn ILayoutConfigurationStore::get_editing_domain(
  self : ILayoutConfigurationStore,
) -> Int? {
  (self.get_editing_domain_fn)()
}

///|
pub fn ILayoutConfigurationStore::get_option_value(
  self : ILayoutConfigurationStore,
  option_id : String,
) -> String? {
  (self.get_option_value_fn)(option_id)
}

///|
pub fn ILayoutConfigurationStore::set_option_value(
  self : ILayoutConfigurationStore,
  option_id : String,
  value : String?,
) -> Unit {
  (self.set_option_value_fn)(option_id, value)
}

///|
pub fn ILayoutConfigurationStore::get_affected_options(
  self : ILayoutConfigurationStore,
) -> Array[String] {
  (self.get_affected_options_fn)()
}

///|
pub fn ILayoutConfigurationStore::get_option_targets(
  self : ILayoutConfigurationStore,
) -> Array[@core.LayoutOptionTarget] {
  (self.get_option_targets_fn)()
}

///|
pub fn ILayoutConfigurationStore::get_parent(
  self : ILayoutConfigurationStore,
) -> ILayoutConfigurationStore? {
  (self.get_parent_fn)()
}

///|
pub(all) struct LayoutConfigurationStoreProvider {
  get_fn : (ServiceWorkbenchPart?, ServiceDiagramElement?) -> ILayoutConfigurationStore?
}

///|
pub fn new_layout_configuration_store_provider(
  get_fn : (ServiceWorkbenchPart?, ServiceDiagramElement?) -> ILayoutConfigurationStore?,
) -> LayoutConfigurationStoreProvider {
  { get_fn, }
}

///|
pub fn LayoutConfigurationStoreProvider::get(
  self : LayoutConfigurationStoreProvider,
  workbench_part : ServiceWorkbenchPart?,
  context : ServiceDiagramElement?,
) -> ILayoutConfigurationStore? {
  (self.get_fn)(workbench_part, context)
}

///|
pub fn new_simple_layout_configuration_store(
  options? : Map[String, String] = {},
  option_targets? : Array[@core.LayoutOptionTarget] = [ParentsTarget],
  parent? : ILayoutConfigurationStore? = None,
  editing_domain? : Int? = None,
) -> ILayoutConfigurationStore {
  let stored_options = options.copy()
  new_layout_configuration_store(
    get_editing_domain_fn=() => editing_domain,
    get_option_value_fn=option_id => stored_options.get(option_id),
    set_option_value_fn=(option_id, value) => {
      match value {
        Some(actual_value) => stored_options[option_id] = actual_value
        None => ignore(stored_options.remove(option_id))
      }
    },
    get_affected_options_fn=() => {
      let result : Array[String] = []
      for entry in stored_options.to_array() {
        result.push(entry.0)
      }
      result
    },
    get_option_targets_fn=() => option_targets,
    get_parent_fn=() => parent,
  )
}
