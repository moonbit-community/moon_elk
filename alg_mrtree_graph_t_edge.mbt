///|
pub type MrtreeEdge = Int

///|
priv struct MrtreeEdgeData {
  source : MrtreeNode
  target : MrtreeNode
  bend_points : KVectorChain
  mut origin : ElkEdge?
}
