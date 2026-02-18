///|
pub type FNode = Int

///|
priv struct FNodeData {
  mut id : Int
  label : String
  mut parent : FNode?
  children : Array[FNode]
  displacement : KVector
  position : KVector
  size : KVector
  int_properties : Map[String, Int]
  double_properties : Map[String, Double]
  bool_properties : Map[String, Bool]
  mut origin : ElkNode?
}
