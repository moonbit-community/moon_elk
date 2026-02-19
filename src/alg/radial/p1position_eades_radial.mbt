///|
let radial_circle_degrees = 360

///|
let radial_degree_to_rad : Double = @math.PI / 180.0

///|
pub fn new_radial_eades_layout_phase() -> @core.ILayoutProcessor[
  RadialLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(
    (graph, progress_monitor) => {
      match progress_monitor {
        Some(monitor) => {
          ignore(monitor.begin("Eades radial", 1.0))
          monitor.log_graph("After")
        }
        None => ()
      }
      let root = match radial_internal_root(graph) {
        Some(value) => value
        None => abort("radial root node is missing")
      }
      let radius = @graph.node_get_double_property(graph, radial_radius)
      let sorter = radial_sorting_strategy_create(
        radial_graph_sorting_strategy(graph),
      )
      let wedge_criteria = radial_annulus_wedge_criteria_create(
        radial_graph_wedge_criteria(graph),
      )
      let optimizer = radial_translation_strategy_create(
        radial_graph_translation_strategy(graph),
      )
      radial_translate(graph, root, radius, sorter, wedge_criteria, optimizer)
      match progress_monitor {
        Some(monitor) => monitor.log_graph("After")
        None => ()
      }
    },
    _ => None,
  )
}

///|
fn radial_translate(
  graph : @graph.ElkNode,
  root : @graph.ElkNode,
  radius : Double,
  sorter : IRadialSorter?,
  wedge_criteria : IAnnulusWedgeCriteria,
  optimizer : IEvaluation?,
) -> Unit {
  ignore(graph)
  let mut optimal_offset = 0.0
  let mut optimal_value = @double.max_value
  if optimizer is Some(evaluation) {
    let mut i = 0
    while i < radial_circle_degrees {
      let offset = i.to_double() * radial_degree_to_rad
      radial_position_nodes(
        root,
        root,
        radius,
        sorter,
        wedge_criteria,
        0.0,
        0.0,
        2.0 * @math.PI,
        offset,
      )
      let translated_value = evaluation.evaluate(root)
      if translated_value < optimal_value {
        optimal_offset = offset
        optimal_value = translated_value
      }
      i += 1
    }
  }
  radial_position_nodes(
    root,
    root,
    radius,
    sorter,
    wedge_criteria,
    0.0,
    0.0,
    2.0 * @math.PI,
    optimal_offset,
  )
}

///|
fn radial_position_nodes(
  root : @graph.ElkNode,
  node : @graph.ElkNode,
  radius : Double,
  sorter : IRadialSorter?,
  wedge_criteria : IAnnulusWedgeCriteria,
  current_radius : Double,
  min_alpha : Double,
  max_alpha : Double,
  optimal_offset : Double,
) -> Unit {
  let radial_offset = optimal_offset
  let alpha_point = (min_alpha + max_alpha) / 2.0 + radial_offset
  let x_pos = current_radius * @math.cos(alpha_point)
  let y_pos = current_radius * @math.sin(alpha_point)
  radial_center_nodes_on_radi(node, x_pos, y_pos)

  let number_of_leafs = wedge_criteria.calculate_wedge_space(node)
  let tau = 2.0 * @math.acos(current_radius / current_radius + radius)
  let mut s = 0.0
  let mut alpha = 0.0
  if tau < max_alpha - min_alpha {
    s = tau / number_of_leafs
    alpha = (min_alpha + max_alpha - tau) / 2.0
  } else {
    s = (max_alpha - min_alpha) / number_of_leafs
    alpha = min_alpha
  }
  let successors = radial_get_successors(node)
  if sorter is Some(sorter_impl) {
    sorter_impl.initialize(root)
    sorter_impl.sort(successors)
  }
  for child in successors {
    let number_of_child_leafs = wedge_criteria.calculate_wedge_space(child)
    radial_position_nodes(
      root,
      child,
      radius,
      sorter,
      wedge_criteria,
      current_radius + radius,
      alpha,
      alpha + s * number_of_child_leafs,
      optimal_offset,
    )
    alpha += s * number_of_child_leafs
  }
}
