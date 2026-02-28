///|
pub fn topdown_size_approximator_util_get_size_category_multiplier(
  original_graph : @graph.ElkNode,
) -> Double {
  let this_graphs_size = topdown_size_approximator_util_get_graph_size(
    original_graph,
  )
  let categories = @graph.node_get_int_property(
    original_graph, topdown_size_categories,
  )

  if @graph.node_parent(original_graph) is Some(parent) {
    let mut size_min_found = @int.max_value
    let mut size_max_found = @int.min_value

    for child in @graph.node_children(parent) {
      let size = topdown_size_approximator_util_get_graph_size(child)
      if size > size_max_found {
        size_max_found = size
      }
      if size < size_min_found {
        size_min_found = size
      }
    }

    let size_min = 1.0
    let mut size_max = @math.pow(4.0, categories.to_double())
    if size_max_found.to_double() > size_max {
      size_max = size_max_found.to_double()
    }

    let x = (@math.ln(size_max) - @math.ln(size_min)) / categories.to_double()
    let factor = @math.exp(x)

    let mut cutoff = size_min * factor
    for i = 0; i < categories; i = i + 1 {
      if this_graphs_size.to_double() < cutoff {
        return @math.pow(2.0, i.to_double())
      } else {
        cutoff = cutoff * factor
      }
    }
    @math.pow(2.0, (categories - 1).to_double())
  } else {
    1.0
  }
}

///|
pub fn topdown_size_approximator_util_get_graph_size(
  original_graph : @graph.ElkNode,
) -> Int {
  let mut sum = 0
  let hierarchical_node_weight = @graph.node_get_int_property(
    original_graph, topdown_size_categories_hierarchical_node_weight,
  )
  for child in @graph.node_children(original_graph) {
    if @graph.node_children(child).length() > 0 {
      sum = sum + hierarchical_node_weight
    } else {
      sum = sum + 1
    }
  }
  sum
}
