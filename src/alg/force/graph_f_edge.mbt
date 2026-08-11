///|
pub struct FEdge {
  priv mut data : FEdgeData
}

///|
pub impl Eq for FEdge with fn equal(self, other) {
  physical_equal(self, other)
}

///|
fn[T] force_edge_abort(message : String) -> T {
  abort(message)
}

///|
priv struct FEdgeData {
  mut source : FNode?
  mut target : FNode?
  labels : Array[FLabel]
  bendpoints : Array[FBendpoint]
  int_properties : Map[String, Int]
  double_properties : Map[String, Double]
  bool_properties : Map[String, Bool]
  mut origin : @graph.ElkEdge?
}

///|
fn set_fedge_data(edge : FEdge, data : FEdgeData) -> Unit {
  edge.data = data
}

///|
pub fn new_fedge() -> FEdge {
  {
    data: {
      source: None,
      target: None,
      labels: [],
      bendpoints: [],
      int_properties: Map([]),
      double_properties: Map([]),
      bool_properties: Map([]),
      origin: None,
    },
  }
}

///|
pub fn fedge_set_source(edge : FEdge, source : FNode) -> Unit {
  let data = edge.data
  data.source = Some(source)
  set_fedge_data(edge, data)
}

///|
pub fn fedge_set_target(edge : FEdge, target : FNode) -> Unit {
  let data = edge.data
  data.target = Some(target)
  set_fedge_data(edge, data)
}

///|
pub fn fedge_source(edge : FEdge) -> FNode? {
  edge.data.source
}

///|
pub fn fedge_target(edge : FEdge) -> FNode? {
  edge.data.target
}

///|
pub fn fedge_labels(edge : FEdge) -> Array[FLabel] {
  edge.data.labels
}

///|
pub fn fedge_bendpoints(edge : FEdge) -> Array[FBendpoint] {
  edge.data.bendpoints
}

///|
pub fn fedge_set_int_property(
  edge : FEdge,
  property : ForceIntOption,
  value : Int,
) -> Unit {
  let data = edge.data
  data.int_properties[property.get_id()] = value
  set_fedge_data(edge, data)
}

///|
pub fn fedge_get_int_property(edge : FEdge, property : ForceIntOption) -> Int {
  let data = edge.data
  match data.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fedge_set_double_property(
  edge : FEdge,
  property : ForceDoubleOption,
  value : Double,
) -> Unit {
  let data = edge.data
  data.double_properties[property.get_id()] = value
  set_fedge_data(edge, data)
}

///|
pub fn fedge_get_double_property(
  edge : FEdge,
  property : ForceDoubleOption,
) -> Double {
  let data = edge.data
  match data.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fedge_has_double_property(
  edge : FEdge,
  property : ForceDoubleOption,
) -> Bool {
  edge.data.double_properties.contains(property.get_id())
}

///|
pub fn fedge_set_bool_property(
  edge : FEdge,
  property : ForceBoolOption,
  value : Bool,
) -> Unit {
  let data = edge.data
  data.bool_properties[property.get_id()] = value
  set_fedge_data(edge, data)
}

///|
pub fn fedge_get_bool_property(
  edge : FEdge,
  property : ForceBoolOption,
) -> Bool {
  let data = edge.data
  match data.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fedge_set_origin(edge : FEdge, origin : @graph.ElkEdge) -> Unit {
  let data = edge.data
  data.origin = Some(origin)
  set_fedge_data(edge, data)
}

///|
pub fn fedge_origin(edge : FEdge) -> @graph.ElkEdge? {
  edge.data.origin
}

///|
pub fn fedge_source_point(edge : FEdge) -> @core.KVector {
  let source = match fedge_source(edge) {
    Some(source) => source
    None => force_edge_abort("edge source is missing")
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => force_edge_abort("edge target is missing")
  }
  let vector = fnode_position(target).clone().sub(fnode_position(source))
  let source_size = fnode_size(source)
  ignore(@core.clip_vector(vector, source_size.x, source_size.y))
  vector.add(fnode_position(source))
}

///|
pub fn fedge_target_point(edge : FEdge) -> @core.KVector {
  let source = match fedge_source(edge) {
    Some(source) => source
    None => force_edge_abort("edge source is missing")
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => force_edge_abort("edge target is missing")
  }
  let vector = fnode_position(source).clone().sub(fnode_position(target))
  let target_size = fnode_size(target)
  ignore(@core.clip_vector(vector, target_size.x, target_size.y))
  vector.add(fnode_position(target))
}

///|
pub fn fedge_to_vector_chain(edge : FEdge) -> @core.KVectorChain {
  let chain = @core.new_kvector_chain()
  chain.add_vector(fedge_source_point(edge))
  for bendpoint in fedge_bendpoints(edge) {
    chain.add_vector(fbendpoint_position(bendpoint))
  }
  chain.add_vector(fedge_target_point(edge))
  chain
}

///|
pub fn fedge_distribute_bendpoints(edge : FEdge) -> Unit {
  let bendpoints = fedge_bendpoints(edge)
  let count = bendpoints.length()
  if count <= 0 {
    return
  }
  let source = match fedge_source(edge) {
    Some(source) => source
    None => force_edge_abort("edge source is missing")
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => force_edge_abort("edge target is missing")
  }
  let source_position = fnode_position(source)
  let target_position = fnode_position(target)
  let increment = target_position
    .clone()
    .sub(source_position)
    .scale(1.0 / (count + 1).to_double())
  let position = source_position.clone()
  for bendpoint in bendpoints {
    let bendpoint_position = fbendpoint_position(bendpoint)
    bendpoint_position.x = position.x + increment.x
    bendpoint_position.y = position.y + increment.y
    ignore(position.add(increment))
  }
}
