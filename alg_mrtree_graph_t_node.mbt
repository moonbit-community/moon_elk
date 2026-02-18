///|
pub type MrtreeNode = Int

///|
priv struct MrtreeNodeData {
  mut id : Int
  graph : MrtreeGraph
  label : String
  position : KVector
  size : KVector
  mut outgoing_edges : Array[MrtreeEdge]
  mut incoming_edges : Array[MrtreeEdge]
  mut origin : ElkNode?
  mut priority : Int
  mut tree_level : Int
  mut position_constraint : Int
  mut fan : Int
  mut descendants : Int
  mut internal_id : String
  mut position_in_level : Int
  mut level_height : Double
  mut left_neighbor : MrtreeNode?
  mut right_neighbor : MrtreeNode?
  mut left_sibling : MrtreeNode?
  mut right_sibling : MrtreeNode?
  mut xcoor : Int
  mut ycoor : Int
  mut level_min : Double
  mut level_max : Double
  mut compact_level_ascension : Bool
  mut compact_constraints : Array[MrtreeNode]
  mut prelim : Double
  mut modifier : Double
  mut root : Bool
  mut dummy : Bool
}
