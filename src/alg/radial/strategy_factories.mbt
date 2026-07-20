///|
pub fn radial_annulus_wedge_criteria_create(
  criteria : RadialAnnulusWedgeCriteria,
) -> IAnnulusWedgeCriteria {
  match criteria {
    LEAF_NUMBER => new_annulus_wedge_by_leafs().as_i_annulus_wedge_criteria()
    NODE_SIZE => new_annulus_wedge_by_node_space().as_i_annulus_wedge_criteria()
  }
}

///|
pub(all) suberror RadialCompactionStrategyException {
  IllegalArgumentException(String)
} derive(Debug, ToJson)

///|
fn[T] radial_compaction_strategy_raise_illegal_argument(
  message : String,
) -> T raise RadialCompactionStrategyException {
  raise IllegalArgumentException(message)
}

///|
pub fn radial_compaction_strategy_create(
  strategy : RadialCompactionStrategy,
) -> IRadialCompactor raise RadialCompactionStrategyException {
  match strategy {
    RADIAL_COMPACTION =>
      new_i_radial_compactor(graph => new_radial_compaction().compact(graph))
    WEDGE_COMPACTION =>
      new_i_radial_compactor(graph => {
        new_annulus_wedge_compaction().compact(graph)
      })
    NONE =>
      radial_compaction_strategy_raise_illegal_argument(
        "No implementation is available for the layout option NONE",
      )
  }
}

///|
pub fn radial_overlap_removal_strategy_create(
  strategy : RadialOverlapRemovalStrategy,
) -> IOverlapRemoval {
  match strategy {
    EXTENT_RADII =>
      new_radius_extension_overlap_removal().as_i_overlap_removal()
  }
}

///|
pub fn radial_translation_strategy_create(
  strategy : RadialTranslationStrategy,
) -> IEvaluation? {
  match strategy {
    NONE => None
    EDGE_LENGTH => Some(new_edge_length_optimization().as_i_evaluation())
    EDGE_LENGTH_BY_POSITION =>
      Some(new_edge_length_position_optimization().as_i_evaluation())
    CROSSING_MINIMIZATION_BY_POSITION =>
      Some(new_crossing_minimization_position().as_i_evaluation())
  }
}

///|
pub fn radial_sorting_strategy_create(
  strategy : RadialSortingStrategy,
) -> IRadialSorter? {
  match strategy {
    NONE => None
    POLAR_COORDINATE => Some(new_polar_coordinate_sorter().as_i_radial_sorter())
    ID => Some(new_id_sorter().as_i_radial_sorter())
  }
}
