///|
/// Shared debug representation for the linear-segments node placer.
///
/// The placement phase owns the algorithm, while the layered facade owns the
/// debug exporters that expose this type. Keeping the data record here avoids
/// making the shared package depend on the concrete placement phase.
pub(all) struct LinearSegment {
  nodes : Array[LNode]
  mut id : Int
  mut index_in_last_layer : Int
  mut last_layer : Int
  mut deflection : Double
  mut weight : Int
  mut ref_segment_id : Int
  mut _node_type : NodeType
}
