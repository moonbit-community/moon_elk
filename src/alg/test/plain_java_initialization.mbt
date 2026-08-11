///|
fn plain_java_initialization_register_algorithm_if_missing(
  metadata : @core.OptionMetadata,
  algorithm_id : String,
) -> Unit {
  match metadata.algorithm_data(algorithm_id) {
    Some(_) => ()
    None => metadata.register_algorithm(new_layout_algorithm_data(algorithm_id))
  }
}

///|
fn plain_java_initialization_register_additional_algorithms(
  metadata : @core.OptionMetadata,
) -> Unit {
  let additional_algorithm_ids = [
    "org.eclipse.elk.disco", "org.eclipse.elk.force", "org.eclipse.elk.stress", "org.eclipse.elk.radial",
    rectpacking_algorithm_id, spore_compaction_algorithm_id, spore_overlap_removal_algorithm_id,
    vertiflex_algorithm_id,
  ]
  for algorithm_id in additional_algorithm_ids {
    plain_java_initialization_register_algorithm_if_missing(
      metadata, algorithm_id,
    )
  }
}

///|
fn plain_java_initialization_enable_layered_features(
  metadata : @core.OptionMetadata,
) -> Unit {
  match metadata.algorithm_data("org.eclipse.elk.layered") {
    Some(algorithm_data) =>
      for
        feature in [
          @graph.GraphFeature::SelfLoops,
          InsideSelfLoops,
          MultiEdges,
          EdgeLabels,
          Ports,
          Compound,
          Clusters,
          Disconnected,
        ] {
        algorithm_data.add_supported_feature(feature)
      }
    None => ()
  }
}

///|
pub fn plain_java_initialization_initialize_plain_java_layout(
  metadata : @core.OptionMetadata,
) -> Unit {
  metadata.register_default_options()
  metadata.register_default_algorithms()
  metadata.register_providers(force_layout_meta_data_providers())
  plain_java_initialization_register_additional_algorithms(metadata)
  plain_java_initialization_enable_layered_features(metadata)
}
