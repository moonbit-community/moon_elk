///|
pub struct FBendpoint {
  priv data : FBendpointData
}

///|
pub impl Eq for FBendpoint with fn equal(self, other) {
  physical_equal(self, other)
}

///|
priv struct FBendpointData {
  edge : FEdge
  displacement : @core.KVector
  position : @core.KVector
  size : @core.KVector
}

///|
pub fn new_fbendpoint(edge : FEdge) -> FBendpoint {
  let bendpoint : FBendpoint = {
    data: {
      edge,
      displacement: @core.new_kvector(),
      position: @core.new_kvector(),
      size: @core.new_kvector(),
    },
  }
  let edge_data = edge.data
  edge_data.bendpoints.push(bendpoint)
  set_fedge_data(edge, edge_data)
  bendpoint
}

///|
pub fn fbendpoint_edge(bendpoint : FBendpoint) -> FEdge {
  bendpoint.data.edge
}

///|
pub fn fbendpoint_displacement(bendpoint : FBendpoint) -> @core.KVector {
  bendpoint.data.displacement
}

///|
pub fn fbendpoint_position(bendpoint : FBendpoint) -> @core.KVector {
  bendpoint.data.position
}

///|
pub fn fbendpoint_size(bendpoint : FBendpoint) -> @core.KVector {
  bendpoint.data.size
}

///|
pub fn fbendpoint_radius(bendpoint : FBendpoint) -> Double {
  fbendpoint_size(bendpoint).length() / 2.0
}
