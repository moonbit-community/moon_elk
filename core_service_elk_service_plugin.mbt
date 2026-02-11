///|
pub let elk_service_plugin_id : String = "org.eclipse.elk.core.service"

///|
pub struct ElkServicePlugin {
  mut started : Bool
  preference_store : Map[String, Bool]
  running_operations : Map[String, Array[MonitoredOperation]]
}

///|
let elk_service_plugin_ref : Ref[ElkServicePlugin?] = Ref::new(None)

///|
fn new_elk_service_plugin() -> ElkServicePlugin {
  { started: false, preference_store: {}, running_operations: {} }
}

///|
pub fn elk_service_plugin_get_instance() -> ElkServicePlugin {
  match elk_service_plugin_ref.val {
    Some(plugin) => plugin
    None => {
      let plugin = new_elk_service_plugin()
      elk_service_plugin_ref.val = Some(plugin)
      plugin
    }
  }
}

///|
pub fn elk_service_plugin_unload() -> Unit {
  elk_service_plugin_ref.val = None
}

///|
pub fn ElkServicePlugin::start(self : ElkServicePlugin) -> Unit {
  self.started = true
}

///|
pub fn ElkServicePlugin::stop(self : ElkServicePlugin) -> Unit {
  self.started = false
  self.preference_store.clear()
  self.running_operations.clear()
}

///|
pub fn ElkServicePlugin::is_started(self : ElkServicePlugin) -> Bool {
  self.started
}

///|
pub fn ElkServicePlugin::set_boolean_preference(
  self : ElkServicePlugin,
  key : String,
  value : Bool,
) -> Unit {
  self.preference_store[key] = value
}

///|
pub fn ElkServicePlugin::get_boolean_preference(
  self : ElkServicePlugin,
  key : String,
  default_value : Bool,
) -> Bool {
  match self.preference_store.get(key) {
    Some(value) => value
    None => default_value
  }
}

///|
pub fn elk_service_plugin_target_key(
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
) -> String {
  let workbench_key = match workbench_part {
    Some(value) => value.to_string()
    None => "null"
  }
  let diagram_key = match diagram_part {
    Some(value) => value.to_string()
    None => "null"
  }
  workbench_key + "#" + diagram_key
}

///|
pub fn ElkServicePlugin::add_running_operation(
  self : ElkServicePlugin,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
  operation : MonitoredOperation,
) -> Unit {
  let target = elk_service_plugin_target_key(workbench_part, diagram_part)
  let operations = match self.running_operations.get(target) {
    Some(values) => values
    None => []
  }
  operations.push(operation)
  self.running_operations[target] = operations
}

///|
pub fn ElkServicePlugin::remove_running_operation(
  self : ElkServicePlugin,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
  operation : MonitoredOperation,
) -> Unit {
  let target = elk_service_plugin_target_key(workbench_part, diagram_part)
  match self.running_operations.get(target) {
    Some(values) => {
      let kept : Array[MonitoredOperation] = []
      for current in values {
        if current.get_timestamp() != operation.get_timestamp() {
          kept.push(current)
        }
      }
      if kept.is_empty() {
        ignore(self.running_operations.remove(target))
      } else {
        self.running_operations[target] = kept
      }
    }
    None => ()
  }
}

///|
pub fn ElkServicePlugin::get_running_operations(
  self : ElkServicePlugin,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
) -> Array[MonitoredOperation] {
  let target = elk_service_plugin_target_key(workbench_part, diagram_part)
  match self.running_operations.get(target) {
    Some(values) => values
    None => []
  }
}
