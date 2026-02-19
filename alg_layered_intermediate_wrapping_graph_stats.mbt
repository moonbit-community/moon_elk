///|
fn graph_stats_max_double(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn graph_stats_sum_double(a : Double, b : Double) -> Double {
  a + b
}

///|
fn graph_stats_determine_layer_width(
  graph_stats : GraphStats,
  layer : Layer,
) -> Double {
  let mut max_width = 0.0
  for node in layer.get_nodes() {
    let size = node.get_size()
    let margin = node.get_margin()
    let node_width = size.x + margin.right + margin.left + graph_stats.spacing
    if node_width > max_width {
      max_width = node_width
    }
  }
  max_width
}

///|
fn graph_stats_determine_layer_height(
  graph_stats : GraphStats,
  layer : Layer,
) -> Double {
  let mut layer_height = 0.0
  for node in layer.get_nodes() {
    let size = node.get_size()
    let margin = node.get_margin()
    layer_height = layer_height +
      size.y +
      margin.bottom +
      margin.top +
      graph_stats.in_layer_spacing

    for incoming in node.get_incoming_edges() {
      match incoming.get_source() {
        Some(source_port) =>
          match source_port.get_node() {
            Some(source_node) =>
              match source_node.get_type() {
                NodeType::NorthSouthPort =>
                  match
                    source_node.get_property_l_node(
                      internal_properties_origin_l_node,
                    ) {
                    Some(origin) => {
                      let origin_size = origin.get_size()
                      let origin_margin = origin.get_margin()
                      layer_height = layer_height +
                        origin_size.y +
                        origin_margin.bottom +
                        origin_margin.top
                    }
                    None => ()
                  }
                _ => ()
              }
            None => ()
          }
        None => ()
      }
    }
  }
  layer_height
}

///|
fn graph_stats_determine_width(
  graph_stats : GraphStats,
  reducer : (Double, Double) -> Double,
) -> Double {
  let layers = graph_stats.graph.get_layers()
  if layers.is_empty() {
    abort("GraphStats.determineWidth() requires at least one layer")
  }

  let mut value = graph_stats_determine_layer_width(graph_stats, layers[0])
  for i in 1..<layers.length() {
    value = reducer(
      value,
      graph_stats_determine_layer_width(graph_stats, layers[i]),
    )
  }
  value
}

///|
fn graph_stats_determine_height(
  graph_stats : GraphStats,
  reducer : (Double, Double) -> Double,
) -> Double {
  let layers = graph_stats.graph.get_layers()
  if layers.is_empty() {
    abort("GraphStats.determineHeight() requires at least one layer")
  }

  let mut value = graph_stats_determine_layer_height(graph_stats, layers[0])
  for i in 1..<layers.length() {
    value = reducer(
      value,
      graph_stats_determine_layer_height(graph_stats, layers[i]),
    )
  }
  value
}

///|
fn graph_stats_determine_chunk_width(
  graph_stats : GraphStats,
  low_idx : Int,
  high_idx : Int,
) -> Double {
  let layers = graph_stats.graph.get_layers()
  let mut width = 0.0
  for i in low_idx..<high_idx {
    width = width + graph_stats_determine_layer_width(graph_stats, layers[i])
  }
  width
}

///|
fn graph_stats_determine_chunk_height(
  graph_stats : GraphStats,
  low_idx : Int,
  high_idx : Int,
) -> Double {
  let layers = graph_stats.graph.get_layers()
  let mut height = 0.0
  for i in low_idx..<high_idx {
    let current = graph_stats_determine_layer_height(graph_stats, layers[i])
    if current > height {
      height = current
    }
  }
  height
}

///|
fn graph_stats_init_widths_and_heights(graph_stats : GraphStats) -> Unit {
  let widths = []
  let heights = []
  for layer in graph_stats.graph.get_layers() {
    widths.push(graph_stats_determine_layer_width(graph_stats, layer))
    heights.push(graph_stats_determine_layer_height(graph_stats, layer))
  }
  graph_stats.widths = Some(widths)
  graph_stats.heights = Some(heights)
}

///|
fn graph_stats_require_widths(graph_stats : GraphStats) -> Array[Double] {
  match graph_stats.widths {
    Some(values) => values
    None => {
      graph_stats_init_widths_and_heights(graph_stats)
      match graph_stats.widths {
        Some(values) => values
        None => abort("widths should be initialized")
      }
    }
  }
}

///|
fn graph_stats_require_heights(graph_stats : GraphStats) -> Array[Double] {
  match graph_stats.heights {
    Some(values) => values
    None => {
      graph_stats_init_widths_and_heights(graph_stats)
      match graph_stats.heights {
        Some(values) => values
        None => abort("heights should be initialized")
      }
    }
  }
}

///|
fn graph_stats_is_cut_allowed_before_layer(layer : Layer) -> Bool {
  let mut n1 : LNode? = None
  let mut n2 : LNode? = None

  for target in layer.get_nodes() {
    for edge in target.get_incoming_edges() {
      match n1 {
        Some(existing) =>
          if existing.get_handle() != target.get_handle() {
            return false
          }
        None => ()
      }
      n1 = Some(target)

      let source = match edge.get_source() {
        Some(source_port) =>
          match source_port.get_node() {
            Some(source_node) => source_node
            None => continue
          }
        None => continue
      }

      match n2 {
        Some(existing) =>
          if existing.get_handle() != source.get_handle() {
            return false
          }
        None => ()
      }
      n2 = Some(source)
    }
  }

  true
}

///|
fn graph_stats_init_cut_allowed(graph_stats : GraphStats) -> Unit {
  if graph_stats.cuts_allowed is Some(_) {
    return
  }

  let layer_count = graph_stats.graph.get_layers().length()
  let cuts_allowed = []
  for _ in 0..<layer_count {
    cuts_allowed.push(false)
  }

  if layer_count == 0 {
    graph_stats.cuts_allowed = Some(cuts_allowed)
    return
  }

  cuts_allowed[0] = false

  if graph_stats.graph.has_property_string(
      layered_options_wrapping_validify_forbidden_indices,
    ) {
    let forbidden = layered_options_parse_int_list(
      graph_stats.graph.get_property_string(
        layered_options_wrapping_validify_forbidden_indices,
      ),
    )
    for f in forbidden {
      if f > 0 && f < cuts_allowed.length() {
        cuts_allowed[f] = false
      }
    }
  } else {
    let layers = graph_stats.graph.get_layers()
    let mut i = 1
    while i < layers.length() {
      cuts_allowed[i] = graph_stats_is_cut_allowed_before_layer(layers[i])
      i = i + 1
    }
  }

  graph_stats.cuts_allowed = Some(cuts_allowed)
}

///|
pub struct GraphStats {
  graph : LGraph
  spacing : Double
  in_layer_spacing : Double
  dar : Double
  longest_path : Int
  mut max_width : Double?
  mut max_height : Double?
  mut sum_width : Double?
  mut widths : Array[Double]?
  mut heights : Array[Double]?
  mut cuts_allowed : Array[Bool]?
}

///|
pub fn new_graph_stats(graph : LGraph) -> GraphStats {
  let direction = graph.get_property_direction(layered_components_direction)
  let graph_aspect_ratio = graph.get_property_double(aspect_ratio)
  let correction = graph.get_property_double(
    layered_options_wrapping_correction_factor,
  )
  let dar = match direction {
    Direction::Leftward => graph_aspect_ratio * correction
    Direction::Rightward => graph_aspect_ratio * correction
    Direction::Undefined => graph_aspect_ratio * correction
    _ => 1.0 / (graph_aspect_ratio * correction)
  }

  {
    graph,
    spacing: graph.get_property_double(
      layered_options_spacing_node_node_between_layers,
    ),
    in_layer_spacing: graph.get_property_double(spacing_node_node),
    dar,
    longest_path: graph.get_layers().length(),
    max_width: None,
    max_height: None,
    sum_width: None,
    widths: None,
    heights: None,
    cuts_allowed: None,
  }
}

///|
pub fn GraphStats::get_approximate_layer_width(
  self : GraphStats,
  layer : Layer,
) -> Double {
  graph_stats_determine_layer_width(self, layer)
}

///|
pub fn GraphStats::get_approximate_layering_width(self : GraphStats) -> Double {
  self.get_sum_width()
}

///|
pub fn GraphStats::get_approximate_chunk_based_layering_width(
  self : GraphStats,
  cuts : Array[Int],
) -> Double {
  if cuts.is_empty() {
    return self.get_approximate_layering_width()
  }

  let mut width = 0.0
  let mut low_idx = 0
  for high_idx in cuts {
    let current = graph_stats_determine_chunk_width(self, low_idx, high_idx)
    if current > width {
      width = current
    }
    low_idx = high_idx
  }

  let final_chunk = graph_stats_determine_chunk_width(
    self,
    low_idx,
    self.graph.get_layers().length(),
  )
  if final_chunk > width {
    width = final_chunk
  }

  width
}

///|
pub fn GraphStats::get_approximate_layer_height(
  self : GraphStats,
  layer : Layer,
) -> Double {
  graph_stats_determine_layer_height(self, layer)
}

///|
pub fn GraphStats::get_approximate_layering_height(self : GraphStats) -> Double {
  self.get_max_height()
}

///|
pub fn GraphStats::get_approximate_chunk_based_layering_height(
  self : GraphStats,
  cuts : Array[Int],
) -> Double {
  if cuts.is_empty() {
    return 0.0
  }

  let mut height = 0.0
  let mut low_idx = 0
  for high_idx in cuts {
    height = height +
      graph_stats_determine_chunk_height(self, low_idx, high_idx)
    low_idx = high_idx
  }
  height = height +
    graph_stats_determine_chunk_height(
      self,
      low_idx,
      self.graph.get_layers().length(),
    )
  height
}

///|
pub fn GraphStats::get_max_width(self : GraphStats) -> Double {
  match self.max_width {
    Some(value) => value
    None => {
      let value = graph_stats_determine_width(self, graph_stats_max_double)
      self.max_width = Some(value)
      value
    }
  }
}

///|
pub fn GraphStats::get_sum_width(self : GraphStats) -> Double {
  match self.sum_width {
    Some(value) => value
    None => {
      let value = graph_stats_determine_width(self, graph_stats_sum_double)
      self.sum_width = Some(value)
      value
    }
  }
}

///|
pub fn GraphStats::get_widths(self : GraphStats) -> Array[Double] {
  graph_stats_require_widths(self)
}

///|
pub fn GraphStats::get_max_height(self : GraphStats) -> Double {
  match self.max_height {
    Some(value) => value
    None => {
      let value = graph_stats_determine_height(self, graph_stats_max_double)
      self.max_height = Some(value)
      value
    }
  }
}

///|
pub fn GraphStats::get_heights(self : GraphStats) -> Array[Double] {
  graph_stats_require_heights(self)
}

///|
pub fn GraphStats::is_cut_allowed(self : GraphStats, layer_index : Int) -> Bool {
  if self.cuts_allowed is None {
    graph_stats_init_cut_allowed(self)
  }
  match self.cuts_allowed {
    Some(values) => values[layer_index]
    None => false
  }
}

///|
pub fn GraphStats::get_cuts_allowed(self : GraphStats) -> Array[Bool] {
  if self.cuts_allowed is None {
    graph_stats_init_cut_allowed(self)
  }
  match self.cuts_allowed {
    Some(values) => values
    None => []
  }
}
