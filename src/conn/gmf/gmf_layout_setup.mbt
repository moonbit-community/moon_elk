///|
pub(all) enum GmfLayoutSetupObject {
  DiagramEditor
  GraphicalEditPart(GmfEditPart)
  AdaptableWithDiagramEditor
  Collection(Array[GmfLayoutSetupObject])
  Other
} derive(Debug)

///|
pub struct GmfInjector {
  bindings : Map[String, String]
}

///|
pub fn new_gmf_injector(bindings? : Map[String, String] = {}) -> GmfInjector {
  { bindings, }
}

///|
pub fn GmfInjector::binding_of(self : GmfInjector, key : String) -> String? {
  self.bindings.get(key)
}

///|
pub struct GmfLayoutSetup {
  unit : Unit
}

///|
pub fn new_gmf_layout_setup() -> GmfLayoutSetup {
  { unit: () }
}

///|
pub fn GmfLayoutSetup::supports(
  _self : GmfLayoutSetup,
  obj : GmfLayoutSetupObject,
) -> Bool {
  match obj {
    Collection(values) => {
      for value in values {
        if value is GraphicalEditPart(_) {
          return true
        }
      }
      false
    }
    DiagramEditor => true
    GraphicalEditPart(_) => true
    AdaptableWithDiagramEditor => true
    Other => false
  }
}

///|
pub fn GmfLayoutSetup::create_injector(
  _self : GmfLayoutSetup,
  default_module : GmfInjector,
) -> GmfInjector {
  let merged_bindings = default_module.bindings.copy()
  merged_bindings["IDiagramLayoutConnector"] = "GmfDiagramLayoutConnector"
  merged_bindings["ILayoutConfigurationStore.Provider"] = "GmfLayoutConfigurationStore.Provider"
  new_gmf_injector(bindings=merged_bindings)
}
