///|
/// Re-export the supported layered entry point from the runtime package. The
/// facade owns composition; the runtime owns the strongly connected algorithm
/// implementation below it.
pub using @pipeline {type LayeredLayoutProvider, new_layered_layout_provider}

///|
/// Referencing the engine link makes concrete phase and processor registration
/// an explicit responsibility of the public facade.
let _layered_engine_linked : Bool = @engine.layered_engine_linked
