///|
pub enum SporeStructureExtractionStrategy {
  DELAUNAY_TRIANGULATION
}

///|
pub fn spore_structure_extraction_strategy_from_string(
  value : String,
) -> SporeStructureExtractionStrategy {
  if value == "DELAUNAY_TRIANGULATION" {
    DELAUNAY_TRIANGULATION
  } else {
    DELAUNAY_TRIANGULATION
  }
}

///|
pub fn spore_structure_extraction_strategy_phase_factory(
  strategy : SporeStructureExtractionStrategy,
  graph : SporeGraph,
) -> @core.LayoutProcessorFactory {
  match strategy {
    DELAUNAY_TRIANGULATION =>
      @core.new_layout_processor_factory(82000, 0, graph, () => {
        new_spore_delaunay_triangulation_layout_phase()
      })
  }
}
