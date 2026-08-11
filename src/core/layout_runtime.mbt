///|
/// Long-lived layout configuration shared by independent layout sessions.
///
/// A runtime owns registration state only. Per-layout mutable state belongs to
/// `LayoutSession`, which keeps one runtime reusable across concurrent calls.
pub struct LayoutRuntime {
  priv option_metadata : OptionMetadata
  priv algorithm_registry : AlgorithmRegistry
  priv provider_registry : ProviderRegistry
}

///|
/// Per-layout mutable state shared by the engine and every selected provider.
/// A session records only the first reported error so later cleanup failures
/// cannot hide the original layout failure. Algorithms that need typed scratch
/// data create a child session at their provider boundary (for example,
/// `LayeredTransformSession`, `RectPackingSession`, and `VertiFlexSession`)
/// instead of placing untyped values or dependency-specific types in core.
pub struct LayoutSession {
  priv mut error : Error?
}

///|
pub fn new_layout_session() -> LayoutSession {
  { error: None }
}

///|
pub fn new_layout_runtime() -> LayoutRuntime {
  {
    option_metadata: new_option_metadata(),
    algorithm_registry: new_algorithm_registry(),
    provider_registry: new_provider_registry(),
  }
}

///|
pub fn LayoutRuntime::option_metadata(self : LayoutRuntime) -> OptionMetadata {
  self.option_metadata
}

///|
fn LayoutRuntime::algorithm_registry(self : LayoutRuntime) -> AlgorithmRegistry {
  self.algorithm_registry
}

///|
fn LayoutRuntime::provider_registry(self : LayoutRuntime) -> ProviderRegistry {
  self.provider_registry
}
