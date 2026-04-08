///|
pub(all) enum LayoutSetupObject {
  WorkbenchPartObject(ServiceWorkbenchPart)
  DiagramPartObject(ServiceDiagramElement)
  SelectionObject(Array[ServiceDiagramElement])
  OtherObject
} derive(Debug)

///|
pub(all) struct ILayoutSetup {
  supports_fn : (LayoutSetupObject) -> Bool
  create_injector_fn : (CoreServiceInjector) -> CoreServiceInjector
}

///|
pub fn new_layout_setup(
  supports_fn : (LayoutSetupObject) -> Bool,
  create_injector_fn : (CoreServiceInjector) -> CoreServiceInjector,
) -> ILayoutSetup {
  { supports_fn, create_injector_fn }
}

///|
pub fn new_layout_setup_default_impl() -> ILayoutSetup {
  new_layout_setup(_ => false, default_module => default_module)
}

///|
pub fn ILayoutSetup::supports(
  self : ILayoutSetup,
  obj : LayoutSetupObject,
) -> Bool {
  (self.supports_fn)(obj)
}

///|
pub fn ILayoutSetup::create_injector(
  self : ILayoutSetup,
  default_module : CoreServiceInjector,
) -> CoreServiceInjector {
  (self.create_injector_fn)(default_module)
}
