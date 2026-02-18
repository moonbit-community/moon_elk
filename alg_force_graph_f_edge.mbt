///|
pub type FEdge = Int

///|
priv struct FEdgeData {
  mut source : FNode?
  mut target : FNode?
  labels : Array[FLabel]
  bendpoints : Array[FBendpoint]
  int_properties : Map[String, Int]
  double_properties : Map[String, Double]
  bool_properties : Map[String, Bool]
  mut origin : ElkEdge?
}
