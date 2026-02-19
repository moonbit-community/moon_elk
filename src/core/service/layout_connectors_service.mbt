///|
pub let extp_id_layout_connectors : String = "org.eclipse.elk.core.service.layoutConnectors"

///|
pub let layout_connectors_element_setup : String = "setup"

///|
pub let layout_connectors_attribute_class : String = "class"

///|
pub let layout_connectors_attribute_priority : String = "priority"

///|
struct LayoutSetupEntry {
  priority : Int
  setup : ILayoutSetup
  mut injector : CoreServiceInjector?
}

///|
pub(all) struct LayoutConnectorsService {
  mut entries : Array[LayoutSetupEntry]
  mut layout_listeners : Array[ILayoutListener]
}

///|
let layout_connectors_service_instance_ref : Ref[LayoutConnectorsService?] = Ref::new(
  None,
)

///|
pub fn new_layout_connectors_service() -> LayoutConnectorsService {
  { entries: [], layout_listeners: [] }
}

///|
pub fn layout_connectors_service_get_instance() -> LayoutConnectorsService {
  match layout_connectors_service_instance_ref.val {
    Some(instance) => instance
    None => {
      let instance = new_layout_connectors_service()
      layout_connectors_service_instance_ref.val = Some(instance)
      instance
    }
  }
}

///|
pub fn layout_connectors_service_unload() -> Unit {
  layout_connectors_service_instance_ref.val = None
}

///|
fn layout_connectors_service_insert_sorted(
  service : LayoutConnectorsService,
  entry : LayoutSetupEntry,
) -> Unit {
  let result : Array[LayoutSetupEntry] = []
  let mut inserted = false
  for current in service.entries {
    if !inserted && current.priority <= entry.priority {
      result.push(entry)
      inserted = true
    }
    result.push(current)
  }
  if !inserted {
    result.push(entry)
  }
  service.entries = result
}

///|
pub fn LayoutConnectorsService::register_setup(
  self : LayoutConnectorsService,
  setup : ILayoutSetup,
  priority? : Int = 0,
) -> Unit {
  layout_connectors_service_insert_sorted(self, {
    priority,
    setup,
    injector: None,
  })
}

///|
pub fn LayoutConnectorsService::clear_setups_for_test(
  self : LayoutConnectorsService,
) -> Unit {
  self.entries = []
}

///|
pub fn LayoutConnectorsService::clear_listeners_for_test(
  self : LayoutConnectorsService,
) -> Unit {
  self.layout_listeners = []
}

///|
fn layout_connectors_service_supports_target(
  setup : ILayoutSetup,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
) -> Bool {
  match workbench_part {
    Some(workbench) =>
      if !setup.supports(WorkbenchPartObject(workbench)) {
        false
      } else {
        match diagram_part {
          Some(diagram) => setup.supports(DiagramPartObject(diagram))
          None => true
        }
      }
    None =>
      match diagram_part {
        Some(diagram) => setup.supports(DiagramPartObject(diagram))
        None => false
      }
  }
}

///|
fn layout_connectors_service_get_injector_for_entry(
  service : LayoutConnectorsService,
  index : Int,
) -> CoreServiceInjector? {
  match service.entries[index].injector {
    Some(injector) => Some(injector)
    None => {
      let injector = service.entries[index].setup.create_injector(
        new_default_module(),
      )
      service.entries[index].injector = Some(injector)
      service.entries[index].injector
    }
  }
}

///|
pub fn LayoutConnectorsService::get_injector(
  self : LayoutConnectorsService,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
) -> CoreServiceInjector? {
  for index = 0; index < self.entries.length(); index = index + 1 {
    let entry = self.entries[index]
    if layout_connectors_service_supports_target(
        entry.setup,
        workbench_part,
        diagram_part,
      ) {
      return layout_connectors_service_get_injector_for_entry(self, index)
    }
  }
  None
}

///|
pub fn LayoutConnectorsService::get_connector(
  self : LayoutConnectorsService,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
) -> IDiagramLayoutConnector? {
  match self.get_injector(workbench_part, diagram_part) {
    Some(injector) => injector.get_connector()
    None => None
  }
}

///|
pub fn LayoutConnectorsService::add_layout_listener(
  self : LayoutConnectorsService,
  listener : ILayoutListener,
) -> Unit {
  self.layout_listeners.push(listener)
}

///|
pub fn LayoutConnectorsService::remove_layout_listener(
  self : LayoutConnectorsService,
  listener : ILayoutListener,
) -> Unit {
  let kept : Array[ILayoutListener] = []
  for current in self.layout_listeners {
    if current.id != listener.id {
      kept.push(current)
    }
  }
  self.layout_listeners = kept
}

///|
pub fn LayoutConnectorsService::fire_layout_about_to_start(
  self : LayoutConnectorsService,
  mapping : LayoutMapping,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  for listener in self.layout_listeners {
    listener.layout_about_to_start(mapping, progress_monitor)
  }
}

///|
pub fn LayoutConnectorsService::fire_layout_done(
  self : LayoutConnectorsService,
  mapping : LayoutMapping,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  for listener in self.layout_listeners {
    listener.layout_done(mapping, progress_monitor)
  }
}

///|
pub fn LayoutConnectorsService::registered_priorities_for_test(
  self : LayoutConnectorsService,
) -> Array[Int] {
  let priorities : Array[Int] = []
  for entry in self.entries {
    priorities.push(entry.priority)
  }
  priorities
}
