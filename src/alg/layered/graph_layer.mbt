///|
let layer_next_handle_ref : Ref[Int] = Ref::new(0)

///|
fn layer_next_handle() -> Int {
  let handle = layer_next_handle_ref.val
  layer_next_handle_ref.val = handle + 1
  handle
}

///|
fn layer_internal_handle(layer : Layer) -> Int {
  layer.layer_handle
}

///|
pub struct Layer {
  graph_element : LGraphElement
  layer_handle : Int
  graph : LGraph
  size : @core.KVector
  nodes : Array[LNode]
}

///|
pub fn new_layer(graph : LGraph) -> Layer {
  {
    graph_element: new_l_graph_element(),
    layer_handle: layer_next_handle(),
    graph,
    size: @core.new_kvector(),
    nodes: [],
  }
}

///|
pub fn Layer::get_id(self : Layer) -> Int {
  self.graph_element.get_id()
}

///|
pub fn Layer::set_id(self : Layer, id : Int) -> Unit {
  self.graph_element.set_id(id)
}

///|
pub fn Layer::get_size(self : Layer) -> @core.KVector {
  self.size
}

///|
pub fn Layer::get_nodes(self : Layer) -> Array[LNode] {
  self.nodes
}

///|
pub fn Layer::get_graph(self : Layer) -> LGraph {
  self.graph
}

///|
pub fn Layer::get_index(self : Layer) -> Int {
  let layers = self.graph.get_layers()
  for i in 0..<layers.length() {
    if layer_internal_handle(layers[i]) == layer_internal_handle(self) {
      return i
    }
  }
  -1
}

///|
pub fn Layer::to_string(self : Layer) -> String {
  "L_" + self.get_index().to_string()
}
