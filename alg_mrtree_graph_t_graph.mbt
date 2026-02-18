///|
pub type MrtreeGraph = Int

///|
priv struct MrtreeGraphData {
  nodes : Array[MrtreeNode]
  edges : Array[MrtreeEdge]
  mut origin : ElkNode?
  mut separate_connected_components : Bool
  mut direction : String
  mut compaction : Bool
  mut edge_routing_mode : String
  mut weighting : String
  mut search_order : String
  mut removable_edges : Array[MrtreeEdge]
  mut spacing_node_node : Double
  mut spacing_edge_node : Double
  mut edge_end_texture_length : Double
  mut aspect_ratio : Double
  mut padding : ElkPadding
  mut priority : Int
  mut bb_up_left : KVector
  mut bb_low_right : KVector
  mut graph_xmin : Double
  mut graph_ymin : Double
  mut graph_xmax : Double
  mut graph_ymax : Double
}
