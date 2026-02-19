///|
pub type FBendpoint = Int

///|
priv struct FBendpointData {
  edge : FEdge
  displacement : KVector
  position : KVector
  size : KVector
}

///|
let fbendpoint_store : Ref[Array[FBendpointData]] = Ref::new([])

///|
fn checked_fbendpoint(bendpoint : FBendpoint) -> Unit {
  if bendpoint < 0 || bendpoint >= fbendpoint_store.val.length() {
    abort("invalid force bendpoint id")
  }
}

///|
pub fn new_fbendpoint(edge : FEdge) -> FBendpoint {
  checked_fedge(edge)
  let bendpoint = fbendpoint_store.val.length()
  fbendpoint_store.val.push({
    edge,
    displacement: new_kvector(),
    position: new_kvector(),
    size: new_kvector(),
  })
  let edge_data = fedge_store.val[edge]
  edge_data.bendpoints.push(bendpoint)
  set_fedge_data(edge, edge_data)
  bendpoint
}

///|
pub fn fbendpoint_edge(bendpoint : FBendpoint) -> FEdge {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].edge
}

///|
pub fn fbendpoint_displacement(bendpoint : FBendpoint) -> KVector {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].displacement
}

///|
pub fn fbendpoint_position(bendpoint : FBendpoint) -> KVector {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].position
}

///|
pub fn fbendpoint_size(bendpoint : FBendpoint) -> KVector {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].size
}

///|
pub fn fbendpoint_radius(bendpoint : FBendpoint) -> Double {
  fbendpoint_size(bendpoint).length() / 2.0
}
