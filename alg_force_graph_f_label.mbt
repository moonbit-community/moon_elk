///|
pub type FLabel = Int

///|
priv struct FLabelData {
  edge : FEdge
  text : String
  displacement : KVector
  position : KVector
  size : KVector
  bool_properties : Map[String, Bool]
  double_properties : Map[String, Double]
  mut origin : ElkLabel?
}
