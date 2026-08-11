///|
/// Builds the full in-process algorithm set shipped by this module.
pub fn new_engine_builder() -> @engine.EngineBuilder {
  let builder = @layered_engine.new_engine_builder()
  builder
  .runtime()
  .option_metadata()
  .register_providers(@force.force_layout_meta_data_providers())
  builder
  .add_layout_algorithm(
    "force", @force.force_algorithm_id, @force.register_force_layout_algorithm,
  )
  .add_layout_algorithm(
    "stress", @force.stress_algorithm_id, @force.register_stress_layout_algorithm,
  )
  .add_layout_algorithm(
    "radial", @radial_options.radial_algorithm_id, @radial.register_radial_layout_algorithm,
  )
  .add_layout_algorithm(
    "mrtree", @mrtree_options.mrtree_algorithm_id, @mrtree.register_mrtree_layout_algorithm,
  )
  .add_layout_algorithm(
    "rectpacking", @rectpacking_options.rectpacking_algorithm_id, @rectpacking.register_rectpacking_layout_algorithm,
  )
  .add_layout_algorithm(
    "sporeOverlap", @spore.spore_overlap_removal_algorithm_id, @spore.register_spore_overlap_layout_algorithm,
  )
  .add_layout_algorithm(
    "sporeCompaction", @spore.spore_compaction_algorithm_id, @spore.register_spore_compaction_layout_algorithm,
  )
  .add_layout_algorithm(
    "vertiflex", @vertiflex.vertiflex_algorithm_id, @vertiflex.register_vertiflex_layout_algorithm,
  )
  .add_layout_algorithm(
    "disco", @disco.disco_algorithm_id, @disco.register_disco_layout_algorithm,
  )
}

///|
pub fn new_layout_runtime() -> @core.LayoutRuntime {
  new_engine_builder().build_runtime()
}

///|
pub fn new_elk_engine() -> @core.ElkEngine {
  new_engine_builder().build()
}
