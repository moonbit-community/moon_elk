///|
/// Keep every externally meaningful option variant reachable inside its owner
/// package. Some option enums are intentionally data-only and have no local
/// conversion routine, so the compiler would otherwise report their public
/// constructors as unused even though callers select them through the facade.
fn _layered_option_constructor_coverage() -> Unit {
  let _ : Array[CuttingStrategy] = [Ard, Msd, Manual]
  let _ : Array[DirectionCongruency] = [ReadingDirection, Rotation]
  let _ : Array[GraphCompactionStrategy] = [
    NoneType,
    Left,
    Right,
    LeftRightConstraintLocking,
    LeftRightConnectionLocking,
    EdgeLength,
  ]
  let _ : Array[InLayerConstraint] = [NoneType, Top, Bottom]
  let _ : Array[NodePromotionStrategy] = [
    NoneType,
    Nikolov,
    NikolovPixel,
    NikolovImproved,
    NikolovImprovedPixel,
    DummyNodePercentage,
    NodeCountPercentage,
    NoBoundary,
    ModelOrderLeftToRight,
    ModelOrderRightToLeft,
  ]
  let _ : Array[OrderingStrategy] = [
    NoneType,
    NodesAndEdges,
    PreferEdges,
    PreferNodes,
  ]
  let _ : Array[PortSortingStrategy] = [InputOrder, PortDegree]
  let _ : Array[SelfLoopDistributionStrategy] = [Equally, North, NorthSouth]
  let _ : Array[SelfLoopOrderingStrategy] = [Stacked, ReverseStacked, Sequenced]
  let _ : Array[ValidifyStrategy] = [No, Greedy, LookBack]
}
