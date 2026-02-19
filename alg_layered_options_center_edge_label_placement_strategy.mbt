///|
pub enum CenterEdgeLabelPlacementStrategy {
  MedianLayer
  TailLayer
  HeadLayer
  SpaceEfficientLayer
  WidestLayer
  CenterLayer
}

///|
pub fn CenterEdgeLabelPlacementStrategy::uses_label_size_information(
  self : CenterEdgeLabelPlacementStrategy,
) -> Bool {
  match self {
    WidestLayer => true
    CenterLayer => true
    SpaceEfficientLayer => true
    _ => false
  }
}

///|
pub fn center_edge_label_placement_strategy_uses_label_size_information_values() -> Array[
  Bool,
] {
  [
    CenterEdgeLabelPlacementStrategy::uses_label_size_information(MedianLayer),
    CenterEdgeLabelPlacementStrategy::uses_label_size_information(TailLayer),
    CenterEdgeLabelPlacementStrategy::uses_label_size_information(HeadLayer),
    CenterEdgeLabelPlacementStrategy::uses_label_size_information(
      SpaceEfficientLayer,
    ),
    CenterEdgeLabelPlacementStrategy::uses_label_size_information(WidestLayer),
    CenterEdgeLabelPlacementStrategy::uses_label_size_information(CenterLayer),
  ]
}
