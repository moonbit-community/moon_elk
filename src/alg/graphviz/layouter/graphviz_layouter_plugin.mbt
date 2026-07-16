///|
pub let graphviz_layouter_plugin_id : String = "org.eclipse.elk.alg.graphviz.layouter"

///|
pub struct GraphvizLayouterBundle {
  symbolic_name : String
}

///|
pub fn new_graphviz_layouter_bundle(
  symbolic_name? : String = graphviz_layouter_plugin_id,
) -> GraphvizLayouterBundle {
  { symbolic_name, }
}

///|
pub fn GraphvizLayouterBundle::get_symbolic_name(
  self : GraphvizLayouterBundle,
) -> String {
  self.symbolic_name
}

///|
pub struct GraphvizLayouterPlugin {
  bundle : GraphvizLayouterBundle
}

///|
let graphviz_layouter_plugin_ref : Ref[GraphvizLayouterPlugin?] = Ref(None)

///|
pub fn new_graphviz_layouter_plugin(
  bundle? : GraphvizLayouterBundle = new_graphviz_layouter_bundle(),
) -> GraphvizLayouterPlugin {
  { bundle, }
}

///|
pub fn GraphvizLayouterPlugin::start(
  self : GraphvizLayouterPlugin,
  _context? : String = "",
) -> Unit {
  graphviz_layouter_plugin_ref.val = Some(self)
}

///|
pub fn GraphvizLayouterPlugin::stop(
  self : GraphvizLayouterPlugin,
  _context? : String = "",
) -> Unit {
  ignore(self)
  graphviz_layouter_plugin_ref.val = None
}

///|
pub fn GraphvizLayouterPlugin::get_bundle(
  self : GraphvizLayouterPlugin,
) -> GraphvizLayouterBundle {
  self.bundle
}

///|
pub fn graphviz_layouter_plugin_get_default() -> GraphvizLayouterPlugin? {
  graphviz_layouter_plugin_ref.val
}

///|
pub fn graphviz_layouter_plugin_reset_for_test() -> Unit {
  graphviz_layouter_plugin_ref.val = None
}
