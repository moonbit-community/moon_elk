///|
pub type ElkEngineLayoutDelegate = (
  LayoutRuntime,
  LayoutSession,
  Map[String, Json],
  Map[String, Json],
) -> Unit raise

///|
priv struct ProviderRegistry {
  mut elk_engine_layout_delegate : ElkEngineLayoutDelegate?
}

///|
fn new_provider_registry() -> ProviderRegistry {
  { elk_engine_layout_delegate: None }
}

///|
pub fn LayoutRuntime::register_elk_engine_layout_delegate(
  self : LayoutRuntime,
  delegate : ElkEngineLayoutDelegate,
) -> Unit {
  self.provider_registry().elk_engine_layout_delegate = Some(delegate)
}

///|
fn LayoutRuntime::elk_engine_layout_delegate(
  self : LayoutRuntime,
) -> ElkEngineLayoutDelegate? {
  self.provider_registry().elk_engine_layout_delegate
}
