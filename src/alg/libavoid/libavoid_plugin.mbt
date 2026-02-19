///|
pub let libavoid_plugin_id : String = "org.adaptagrams.cola.libavoid"

///|
pub struct LibavoidBundle {
  symbolic_name : String
}

///|
pub fn new_libavoid_bundle(
  symbolic_name? : String = libavoid_plugin_id,
) -> LibavoidBundle {
  { symbolic_name, }
}

///|
pub fn LibavoidBundle::get_symbolic_name(self : LibavoidBundle) -> String {
  self.symbolic_name
}

///|
pub struct LibavoidPlugin {
  bundle : LibavoidBundle
}

///|
let libavoid_plugin_ref : Ref[LibavoidPlugin?] = Ref::new(None)

///|
pub fn new_libavoid_plugin(
  bundle? : LibavoidBundle = new_libavoid_bundle(),
) -> LibavoidPlugin {
  { bundle, }
}

///|
pub fn LibavoidPlugin::start(
  self : LibavoidPlugin,
  _context? : String = "",
) -> Unit {
  libavoid_plugin_ref.val = Some(self)
}

///|
pub fn LibavoidPlugin::stop(
  self : LibavoidPlugin,
  _context? : String = "",
) -> Unit {
  ignore(self)
  libavoid_plugin_ref.val = None
  libavoid_server_pool_instance().dispose()
}

///|
pub fn LibavoidPlugin::get_bundle(self : LibavoidPlugin) -> LibavoidBundle {
  self.bundle
}

///|
pub fn libavoid_plugin_get_default() -> LibavoidPlugin? {
  libavoid_plugin_ref.val
}

///|
pub fn libavoid_plugin_reset_for_test() -> Unit {
  libavoid_plugin_ref.val = None
}
