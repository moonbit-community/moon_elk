///|
pub enum EdgeLabelSideSelection {
  AlwaysUp
  AlwaysDown
  DirectionUp
  DirectionDown
  SmartUp
  SmartDown
}

///|
pub fn EdgeLabelSideSelection::transpose(
  self : EdgeLabelSideSelection,
) -> EdgeLabelSideSelection {
  match self {
    AlwaysUp => AlwaysDown
    AlwaysDown => AlwaysUp
    DirectionUp => DirectionDown
    DirectionDown => DirectionUp
    SmartUp => SmartDown
    SmartDown => SmartUp
  }
}

///|
pub fn edge_label_side_selection_to_string(
  value : EdgeLabelSideSelection,
) -> String {
  match value {
    AlwaysUp => "ALWAYS_UP"
    AlwaysDown => "ALWAYS_DOWN"
    DirectionUp => "DIRECTION_UP"
    DirectionDown => "DIRECTION_DOWN"
    SmartUp => "SMART_UP"
    SmartDown => "SMART_DOWN"
  }
}

///|
pub fn edge_label_side_selection_transpose_values() -> Array[String] {
  [
    edge_label_side_selection_to_string(
      EdgeLabelSideSelection::transpose(AlwaysUp),
    ),
    edge_label_side_selection_to_string(
      EdgeLabelSideSelection::transpose(AlwaysDown),
    ),
    edge_label_side_selection_to_string(
      EdgeLabelSideSelection::transpose(DirectionUp),
    ),
    edge_label_side_selection_to_string(
      EdgeLabelSideSelection::transpose(DirectionDown),
    ),
    edge_label_side_selection_to_string(
      EdgeLabelSideSelection::transpose(SmartUp),
    ),
    edge_label_side_selection_to_string(
      EdgeLabelSideSelection::transpose(SmartDown),
    ),
  ]
}
