///|
pub enum SporeStructureExtractionStrategy {
  DELAUNAY_TRIANGULATION
}

///|
pub fn spore_structure_extraction_strategy_from_string(
  value : String,
) -> SporeStructureExtractionStrategy {
  if value == "DELAUNAY_TRIANGULATION" {
    SporeStructureExtractionStrategy::DELAUNAY_TRIANGULATION
  } else {
    SporeStructureExtractionStrategy::DELAUNAY_TRIANGULATION
  }
}

///|
pub fn spore_structure_extraction_strategy_phase_factory(
  strategy : SporeStructureExtractionStrategy,
) -> @core.ILayoutPhaseFactory[SPOrEPhases, SporeGraph] {
  match strategy {
    DELAUNAY_TRIANGULATION =>
      @core.new_layout_processor_factory(82000, 0, () => {
        new_spore_delaunay_triangulation_layout_phase()
      })
  }
}
