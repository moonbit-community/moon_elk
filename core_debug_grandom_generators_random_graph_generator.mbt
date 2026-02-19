///|
pub let core_debug_grandom_port_separation : Double = 7.0

///|
let core_debug_grandom_max_iter : Int = 12

///|
let core_debug_grandom_hypernode_property : IProperty[Bool] = new_property(
  "org.eclipse.elk.core.debug.hypernode", false,
)

///|
pub struct CoreDebugGRandomRandomGraphGenerator {
  mut options : CoreDebugGRandomGeneratorOptions
  mut random : @random.Rand
  mut node_label_counter : Int
  mut port_label_counter : Int
  mut max_hierarchy_level : Int
}

///|
pub fn new_core_debug_grandom_random_graph_generator(
  random_generator : @random.Rand?,
) -> CoreDebugGRandomRandomGraphGenerator {
  {
    options: new_core_debug_grandom_generator_options(),
    random: match random_generator {
      Some(value) => value
      None => @random.Rand::new()
    },
    node_label_counter: 0,
    port_label_counter: 0,
    max_hierarchy_level: 0,
  }
}

///|
pub fn core_debug_grandom_random_graph_generator_generate(
  generator : CoreDebugGRandomRandomGraphGenerator,
  options : CoreDebugGRandomGeneratorOptions,
) -> ElkNode {
  generator.node_label_counter = 0
  generator.port_label_counter = 0
  generator.options = options
  let parent = create_graph()
  generator.max_hierarchy_level = core_debug_grandom_generator_get_rand(
    generator, core_debug_grandom_max_hierarchy_level,
  ).int_val(generator.random)
  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_small_hierarchy,
    ) {
    let atomic_nodes_on_levels = core_debug_grandom_generator_add_hierarchical_nodes(
      generator, parent,
    )
    core_debug_grandom_generator_connect_atomic_nodes_on_different_levels(
      generator, atomic_nodes_on_levels,
    )
    parent
  } else {
    core_debug_grandom_generator_make_graph(generator, parent)
  }
}

///|
pub fn core_debug_grandom_random_graph_generator_generate_from_configuration(
  generator : CoreDebugGRandomRandomGraphGenerator,
  configuration : CoreDebugGRandomConfiguration,
) -> Array[ElkNode] {
  generator.random = core_debug_grandom_random_from_configuration(configuration)
  let options = core_debug_grandom_configuration_parser_parse(
    configuration,
    generator.random,
  )
  let generated = []
  let graph_count = if configuration.samples > 0 {
    configuration.samples
  } else {
    1
  }
  for _ in 0..<graph_count {
    generated.push(
      core_debug_grandom_random_graph_generator_generate(generator, options),
    )
  }
  generated
}

///|
fn core_debug_grandom_random_from_configuration(
  configuration : CoreDebugGRandomConfiguration,
) -> @random.Rand {
  match configuration.seed {
    Some(seed) => {
      let seed_buffer = @buffer.new()
      seed_buffer.write_int64_le(seed.to_int64())
      seed_buffer.write_int64_le(0)
      seed_buffer.write_int64_le(0)
      seed_buffer.write_int64_le(0)
      @random.Rand::chacha8(seed=seed_buffer.to_bytes())
    }
    None => @random.Rand::new()
  }
}

///|
fn core_debug_grandom_generator_add_hierarchical_nodes(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
) -> Array[Array[ElkNode]] {
  let atomic_nodes = []
  let all_graphs = [parent]
  for i in 0..<generator.max_hierarchy_level {
    let hierarchical_nodes = []
    while !all_graphs.is_empty() {
      let next_index = all_graphs.length() - 1
      let current_parent = all_graphs[next_index]
      ignore(all_graphs.remove(next_index))
      ignore(core_debug_grandom_generator_make_graph(generator, current_parent))
      let children = node_children(current_parent)
      if !children.is_empty() {
        atomic_nodes.push(children.copy())
      }
      if i < generator.max_hierarchy_level - 1 {
        let num_hierarch = core_debug_grandom_generator_get_rand(
          generator, core_debug_grandom_number_hierarchical_nodes,
        ).int_val(generator.random)
        let created = core_debug_grandom_generator_create_independent_set(
          generator, current_parent, num_hierarch,
        )
        for node in created {
          hierarchical_nodes.push(node)
        }
      }
    }
    for node in hierarchical_nodes {
      all_graphs.push(node)
    }
  }
  atomic_nodes
}

///|
fn core_debug_grandom_generator_connect_atomic_nodes_on_different_levels(
  generator : CoreDebugGRandomRandomGraphGenerator,
  atomic_nodes : Array[Array[ElkNode]],
) -> Unit {
  let num_cross_hier = if core_debug_grandom_generator_get_optional_rand(
      generator, core_debug_grandom_exact_relative_hier,
    )
    is Some(relative_hier) {
    let seen_edges : Map[Int, Bool] = {}
    for level in atomic_nodes {
      for node in level {
        for edge in node_incoming_edges(node) {
          seen_edges[edge] = true
        }
        for edge in node_outgoing_edges(node) {
          seen_edges[edge] = true
        }
      }
    }
    (seen_edges.length().to_double() * relative_hier.val(generator.random)).to_int()
  } else {
    core_debug_grandom_generator_get_rand(
      generator, core_debug_grandom_cross_hier,
    ).int_val(generator.random)
  }
  if atomic_nodes.length() < 2 {
    return
  }
  for _ in 0..<num_cross_hier {
    if atomic_nodes.length() > 1 {
      let levels = core_debug_grandom_generator_sample(
        generator, atomic_nodes, 2,
      )
      if levels.length() == 2 {
        let left = core_debug_grandom_generator_sample(generator, levels[0], 1)
        let right = core_debug_grandom_generator_sample(generator, levels[1], 1)
        if !left.is_empty() && !right.is_empty() {
          ignore(
            core_debug_grandom_generator_connect(
              generator,
              make_node_shape(left[0]),
              make_node_shape(right[0]),
            ),
          )
        }
      }
    }
  }
}

///|
fn[T] core_debug_grandom_generator_shuffle(
  generator : CoreDebugGRandomRandomGraphGenerator,
  list : Array[T],
) -> Array[T] {
  let shuffled = list.copy()
  let mut index = shuffled.length() - 1
  while index > 0 {
    let swap_index = generator.random.int(limit=index + 1)
    let tmp = shuffled[index]
    shuffled[index] = shuffled[swap_index]
    shuffled[swap_index] = tmp
    index = index - 1
  }
  shuffled
}

///|
fn[T] core_debug_grandom_generator_sample(
  generator : CoreDebugGRandomRandomGraphGenerator,
  list : Array[T],
  number : Int,
) -> Array[T] {
  let shuffled = core_debug_grandom_generator_shuffle(generator, list)
  if number >= list.length() {
    shuffled
  } else {
    let sampled = []
    for i in 0..<number {
      sampled.push(shuffled[i])
    }
    sampled
  }
}

///|
fn core_debug_grandom_generator_make_graph(
  generator : CoreDebugGRandomRandomGraphGenerator,
  graph : ElkNode,
) -> ElkNode {
  if !core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_enable_hierarchy,
    ) {
    core_debug_grandom_generator_set_double(
      generator, core_debug_grandom_hierarchy_chance, 0.0,
    )
    core_debug_grandom_generator_set_bool(
      generator, core_debug_grandom_cross_hierarchy_edges, false,
    )
  }

  let n = core_debug_grandom_generator_get_rand(
    generator, core_debug_grandom_number_of_nodes,
  ).int_val(generator.random)

  let m = match
    core_debug_grandom_generator_get_edge_determination(
      generator, core_debug_grandom_edge_determination,
    ) {
    EdgeAbsolute =>
      core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_edges_absolute,
      ).int_val(generator.random)
    EdgeRelative =>
      (n.to_double() *
      core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_relative_edges,
      ).val(generator.random)).to_int()
    EdgeDensity => {
      let density = core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_density,
      ).val(generator.random)
      (density * n.to_double() * (n - 1).to_double() / 2.0).round().to_int()
    }
    EdgeOutgoing => {
      let edges_per_node = core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_outgoing_edges,
      ).val(generator.random)
      (n.to_double() * edges_per_node).round().to_int()
    }
  }

  match
    core_debug_grandom_generator_get_graph_type(
      generator, core_debug_grandom_graph_type,
    ) {
    GraphCustom =>
      ignore(
        core_debug_grandom_generator_generate_custom_graph(
          generator, n, m, graph,
        ),
      )
    GraphBipartite =>
      core_debug_grandom_generator_generate_bipartite(generator, graph, n, m, 0)
    GraphTree => {
      let max_degree = core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_max_degree,
      )
      let max_width = core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_max_width,
      )
      core_debug_grandom_generator_generate_tree(
        generator, graph, n, max_degree, max_width, 0,
      )
    }
    GraphBiconnected =>
      core_debug_grandom_generator_generate_biconnected_graph(
        generator, graph, n, m, 0,
      )
    GraphTriconnected => {
      let p1 = generator.random.double()
      core_debug_grandom_generator_generate_triconnected_graph(
        generator,
        graph,
        n,
        p1,
        1.0 - p1,
        0,
      )
    }
    GraphAcyclicNoTransitiveEdges =>
      core_debug_grandom_generator_generate_ante_graph(
        generator,
        graph,
        n,
        m,
        core_debug_grandom_generator_get_bool(
          generator, core_debug_grandom_planar,
        ),
        false,
        0,
      )
  }

  if !core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_isolated_nodes,
    ) {
    core_debug_grandom_generator_remove_isolated_nodes(graph)
  }

  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_enable_ports,
    ) &&
    core_debug_grandom_generator_get_port_constraints(
      generator, core_debug_grandom_port_constraints,
    ).is_pos_fixed() {
    let node_queue = [graph]
    while !node_queue.is_empty() {
      let node = node_queue[0]
      ignore(node_queue.remove(0))
      core_debug_grandom_generator_distribute_ports(generator, node)
      for child in node_children(node) {
        node_queue.push(child)
      }
    }
  }

  graph
}

///|
fn core_debug_grandom_generator_generate_custom_graph(
  generator : CoreDebugGRandomRandomGraphGenerator,
  n : Int,
  m : Int,
  graph : ElkNode,
) -> Array[ElkNode] {
  let generated_nodes = match
    core_debug_grandom_generator_get_edge_determination(
      generator, core_debug_grandom_edge_determination,
    ) {
    EdgeOutgoing =>
      core_debug_grandom_generator_generate_any_graph_outgoing(
        generator, graph, n, 0,
      )
    _ =>
      core_debug_grandom_generator_generate_any_graph(generator, graph, n, m, 0)
  }

  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_cross_hierarchy_edges,
    ) {
    match
      core_debug_grandom_generator_get_edge_determination(
        generator, core_debug_grandom_edge_determination,
      ) {
      EdgeOutgoing => {
        let outgoing_edges = core_debug_grandom_generator_determine_outgoing_edges_rand(
          generator,
          generated_nodes,
          core_debug_grandom_generator_get_rand(
            generator, core_debug_grandom_outgoing_edges,
          ),
        )
        ignore(
          core_debug_grandom_generator_connect_randomly_and_conditional_all(
            generator, generated_nodes, outgoing_edges,
          ),
        )
      }
      _ => {
        let mut created_edges = 0
        let mut iterations = 0
        while created_edges < m && iterations < core_debug_grandom_max_iter {
          let outgoing_edges = core_debug_grandom_generator_determine_outgoing_edges_total(
            generator,
            generated_nodes,
            m - created_edges,
          )
          created_edges = created_edges +
            core_debug_grandom_generator_connect_randomly_and_conditional_all(
              generator, generated_nodes, outgoing_edges,
            )
          iterations = iterations + 1
        }
      }
    }
  }

  generated_nodes
}

///|
fn core_debug_grandom_generator_basic_condition(
  generator : CoreDebugGRandomRandomGraphGenerator,
  node1 : ElkNode,
  node2 : ElkNode,
) -> Bool {
  if !core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_self_loops,
    ) &&
    node1 == node2 {
    return false
  }
  if !core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_multi_edges,
    ) &&
    core_debug_grandom_generator_connected(node1, node2) {
    return false
  }
  if !core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_cycles,
    ) &&
    core_debug_grandom_generator_find_node_with_dfs(node2, node1) {
    return false
  }
  true
}

///|
fn core_debug_grandom_generator_generate_any_graph(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
  m : Int,
  hierarchy_level : Int,
) -> Array[ElkNode] {
  let nodes = core_debug_grandom_generator_create_independent_set(
    generator, parent, n,
  )
  if !core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_cross_hierarchy_edges,
    ) {
    let mut created_edges = 0
    let mut iterations = 0
    while created_edges < m && iterations < core_debug_grandom_max_iter {
      let outgoing_edges = core_debug_grandom_generator_determine_outgoing_edges_total(
        generator,
        nodes,
        m - created_edges,
      )
      created_edges = created_edges +
        core_debug_grandom_generator_connect_randomly_and_conditional_all(
          generator, nodes, outgoing_edges,
        )
      iterations = iterations + 1
    }
  }

  let hierarchy_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hierarchy_chance,
  )
  if hierarchy_chance > 0.0 && hierarchy_level < generator.max_hierarchy_level {
    let current_nodes = nodes.copy()
    for node in current_nodes {
      if !core_debug_grandom_generator_is_hypernode(node) &&
        generator.random.double() < hierarchy_chance {
        let size_factor = generator.random.double() *
          core_debug_grandom_generator_get_double(
            generator, core_debug_grandom_hierarchy_nodes_factor,
          )
        let mut child_node_count = (size_factor * n.to_double())
          .round()
          .to_int()
        if child_node_count == 0 {
          child_node_count = 1
        }
        let child_edge_count = (size_factor * m.to_double()).round().to_int()
        let child_nodes = core_debug_grandom_generator_generate_any_graph(
          generator,
          node,
          child_node_count,
          child_edge_count,
          hierarchy_level + 1,
        )
        for child in child_nodes {
          nodes.push(child)
        }
      }
    }
  }

  nodes
}

///|
fn core_debug_grandom_generator_generate_any_graph_outgoing(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
  hierarchy_level : Int,
) -> Array[ElkNode] {
  let nodes = core_debug_grandom_generator_create_independent_set(
    generator, parent, n,
  )
  if !core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_cross_hierarchy_edges,
    ) {
    let outgoing_edges = core_debug_grandom_generator_determine_outgoing_edges_rand(
      generator,
      nodes,
      core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_outgoing_edges,
      ),
    )
    ignore(
      core_debug_grandom_generator_connect_randomly_and_conditional_all(
        generator, nodes, outgoing_edges,
      ),
    )
  }

  let hierarchy_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hierarchy_chance,
  )
  if hierarchy_chance > 0.0 && hierarchy_level < generator.max_hierarchy_level {
    let current_nodes = nodes.copy()
    for node in current_nodes {
      if !core_debug_grandom_generator_is_hypernode(node) &&
        generator.random.double() < hierarchy_chance {
        let size_factor = generator.random.double() *
          core_debug_grandom_generator_get_double(
            generator, core_debug_grandom_hierarchy_nodes_factor,
          )
        let mut child_node_count = (size_factor * n.to_double())
          .round()
          .to_int()
        if child_node_count == 0 {
          child_node_count = 1
        }
        let child_nodes = core_debug_grandom_generator_generate_any_graph_outgoing(
          generator,
          node,
          child_node_count,
          hierarchy_level + 1,
        )
        for child in child_nodes {
          nodes.push(child)
        }
      }
    }
  }

  nodes
}

///|
fn core_debug_grandom_generator_generate_bipartite(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
  m : Int,
  hierarchy_level : Int,
) -> Unit {
  let partition = core_debug_grandom_generator_get_rand(
    generator, core_debug_grandom_partition_frac,
  ).val(generator.random)
  let second_set = core_debug_grandom_generator_bound_int(
    (n.to_double() * partition).round().to_int(),
    1,
    n - 1,
  )
  let first_set = n - second_set

  let left = []
  for _ in 0..<first_set {
    left.push(core_debug_grandom_generator_create_node(generator, parent))
  }
  let right = []
  for _ in 0..<second_set {
    right.push(core_debug_grandom_generator_create_node(generator, parent))
  }

  let allow_cycles = core_debug_grandom_generator_get_bool(
    generator, core_debug_grandom_cycles,
  )
  for _ in 0..<m {
    let source = if allow_cycles {
      core_debug_grandom_generator_random_int(generator, 0, n - 1)
    } else {
      core_debug_grandom_generator_random_int(generator, 0, first_set - 1)
    }
    if source < first_set {
      let target = core_debug_grandom_generator_random_int(
        generator,
        0,
        second_set - 1,
      )
      ignore(
        core_debug_grandom_generator_connect_conditional(
          generator,
          left[source],
          right[target],
        ),
      )
    } else {
      let target = core_debug_grandom_generator_random_int(
        generator,
        0,
        first_set - 1,
      )
      ignore(
        core_debug_grandom_generator_connect_conditional(
          generator,
          right[source - first_set],
          left[target],
        ),
      )
    }
  }

  let hierarchy_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hierarchy_chance,
  )
  if hierarchy_chance > 0.0 && hierarchy_level < generator.max_hierarchy_level {
    for node in node_children(parent) {
      if !core_debug_grandom_generator_is_hypernode(node) &&
        generator.random.double() < hierarchy_chance {
        let hierarchy_nodes_factor = core_debug_grandom_generator_get_double(
          generator, core_debug_grandom_hierarchy_nodes_factor,
        )
        let child_nodes = core_debug_grandom_generator_random_int(
          generator,
          1,
          (hierarchy_nodes_factor * n.to_double()).to_int(),
        )
        let child_edges = (child_nodes.to_double() /
          n.to_double() *
          m.to_double())
          .round()
          .to_int()
        core_debug_grandom_generator_generate_bipartite(
          generator,
          node,
          child_nodes,
          child_edges,
          hierarchy_level + 1,
        )
      }
    }
  }
}

///|
fn core_debug_grandom_generator_generate_tree(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
  max_degree : Int,
  max_width : Int,
  hierarchy_level : Int,
) -> Unit {
  let mut max_index = 0
  let mut node_id_counter = 0
  let possible_nodes = []
  let possible_ids = []
  let width = []
  for _ in 0..<(n + 1) {
    width.push(0)
  }
  let level = []
  for _ in 0..<n {
    level.push(0)
  }

  let root_node = core_debug_grandom_generator_create_node(generator, parent)
  let root_id = node_id_counter
  node_id_counter = node_id_counter + 1
  possible_nodes.push(root_node)
  possible_ids.push(root_id)
  level[root_id] = 0

  let mut created = 1
  while created < n {
    let random_index = core_debug_grandom_generator_random_int(
      generator, 0, max_index,
    )
    let node = possible_nodes[random_index]
    let node_id = possible_ids[random_index]

    if max_width != 0 && width[level[node_id] + 1] == max_width {
      possible_nodes[random_index] = possible_nodes[max_index]
      possible_ids[random_index] = possible_ids[max_index]
      ignore(possible_nodes.remove(max_index))
      ignore(possible_ids.remove(max_index))
      max_index = max_index - 1
      continue
    }

    if max_degree != 0 && node_outgoing_edges(node).length() + 1 == max_degree {
      possible_nodes[random_index] = possible_nodes[max_index]
      possible_ids[random_index] = possible_ids[max_index]
      ignore(possible_nodes.remove(max_index))
      ignore(possible_ids.remove(max_index))
      max_index = max_index - 1
    }

    let new_node = core_debug_grandom_generator_create_node(generator, parent)
    let new_node_id = node_id_counter
    node_id_counter = node_id_counter + 1
    possible_nodes.push(new_node)
    possible_ids.push(new_node_id)
    max_index = max_index + 1
    ignore(
      core_debug_grandom_generator_connect(
        generator,
        make_node_shape(node),
        make_node_shape(new_node),
      ),
    )
    level[new_node_id] = level[node_id] + 1
    width[level[new_node_id]] = width[level[new_node_id]] + 1
    created = created + 1
  }

  let hierarchy_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hierarchy_chance,
  )
  if hierarchy_chance > 0.0 && hierarchy_level < generator.max_hierarchy_level {
    for node in node_children(parent) {
      if !core_debug_grandom_generator_is_hypernode(node) &&
        generator.random.double() < hierarchy_chance {
        let hierarchy_nodes_factor = core_debug_grandom_generator_get_double(
          generator, core_debug_grandom_hierarchy_nodes_factor,
        )
        let child_nodes = core_debug_grandom_generator_random_int(
          generator,
          1,
          (hierarchy_nodes_factor * n.to_double()).to_int(),
        )
        core_debug_grandom_generator_generate_tree(
          generator,
          node,
          child_nodes,
          max_degree,
          max_width,
          hierarchy_level + 1,
        )
      }
    }
  }
}

///|
fn core_debug_grandom_generator_generate_biconnected_graph(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
  m : Int,
  hierarchy_level : Int,
) -> Unit {
  let real_n = if n > 3 { n } else { 3 }
  let real_m = if m > real_n { m } else { real_n }
  let mut split_edge_ops = real_n - 3
  let mut add_edge_ops = real_m - real_n
  let nodes = []
  let edges = []

  nodes.push(core_debug_grandom_generator_create_node(generator, parent))
  nodes.push(core_debug_grandom_generator_create_node(generator, parent))
  nodes.push(core_debug_grandom_generator_create_node(generator, parent))
  edges.push(
    core_debug_grandom_generator_connect(
      generator,
      make_node_shape(nodes[0]),
      make_node_shape(nodes[1]),
    ),
  )
  edges.push(
    core_debug_grandom_generator_connect(
      generator,
      make_node_shape(nodes[1]),
      make_node_shape(nodes[2]),
    ),
  )
  edges.push(
    core_debug_grandom_generator_connect(
      generator,
      make_node_shape(nodes[2]),
      make_node_shape(nodes[0]),
    ),
  )

  while split_edge_ops + add_edge_ops > 0 {
    let p = core_debug_grandom_generator_random_int(
      generator,
      1,
      split_edge_ops + add_edge_ops,
    )
    if p <= split_edge_ops {
      let edge = edges[core_debug_grandom_generator_random_int(
          generator,
          0,
          edges.length() - 1,
        )]
      let split_info = core_debug_grandom_generator_split(generator, edge)
      nodes.push(split_info.0)
      edges.push(split_info.1)
      split_edge_ops = split_edge_ops - 1
    } else {
      let i = core_debug_grandom_generator_random_int(
        generator,
        0,
        nodes.length() - 1,
      )
      let j = (
          i +
          core_debug_grandom_generator_random_int(
            generator,
            1,
            nodes.length() - 1,
          )
        ) %
        nodes.length()
      edges.push(
        core_debug_grandom_generator_connect(
          generator,
          make_node_shape(nodes[i]),
          make_node_shape(nodes[j]),
        ),
      )
      add_edge_ops = add_edge_ops - 1
    }
  }

  let hierarchy_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hierarchy_chance,
  )
  if hierarchy_chance > 0.0 && hierarchy_level < generator.max_hierarchy_level {
    for node in nodes {
      if !core_debug_grandom_generator_is_hypernode(node) &&
        generator.random.double() < hierarchy_chance {
        let hierarchy_nodes_factor = core_debug_grandom_generator_get_double(
          generator, core_debug_grandom_hierarchy_nodes_factor,
        )
        let child_nodes = core_debug_grandom_generator_random_int(
          generator,
          1,
          (hierarchy_nodes_factor * n.to_double()).to_int(),
        )
        let density = m.to_double() / (n * n).to_double()
        let child_edges = density.to_int() * child_nodes * child_nodes
        core_debug_grandom_generator_generate_biconnected_graph(
          generator,
          node,
          child_nodes,
          child_edges,
          hierarchy_level + 1,
        )
      }
    }
  }
}

///|
fn core_debug_grandom_generator_generate_triconnected_graph(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
  p1 : Double,
  p2 : Double,
  hierarchy_level : Int,
) -> Unit {
  let real_n = if n > 4 { n } else { 4 }
  let nodes = core_debug_grandom_generator_create_clique(generator, parent, 4)
  for _ in 4..<real_n {
    nodes.push(nodes[0])
  }
  let neighbors : Array[ElkEdge] = []
  let marks = []
  for _ in 0..<n {
    marks.push(0)
  }

  let mut i = 4
  while i < n {
    let node = nodes[core_debug_grandom_generator_random_int(
        generator,
        0,
        i - 1,
      )]
    let new_node = core_debug_grandom_generator_create_node(generator, parent)
    nodes[i] = new_node
    neighbors.clear()
    for edge in node_outgoing_edges(node) {
      neighbors.push(edge)
    }
    for edge in node_incoming_edges(node) {
      neighbors.push(edge)
    }
    let degree = neighbors.length()

    let mut left_marks = 2
    while left_marks > 0 {
      let r = core_debug_grandom_generator_random_int(generator, 0, degree - 1)
      if (marks[r] & 1) == 0 {
        marks[r] = marks[r] | 1
        left_marks = left_marks - 1
      }
    }

    let mut right_marks = 2
    while right_marks > 0 {
      let r = core_debug_grandom_generator_random_int(generator, 0, degree - 1)
      if (marks[r] & 2) == 0 {
        marks[r] = marks[r] | 2
        right_marks = right_marks - 1
      }
    }

    let mut j = 0
    while j < degree {
      let mut mark = marks[j]
      marks[j] = 0
      let x = generator.random.double()
      match mark {
        0 =>
          if x < p1 {
            mark = 1
          } else if x < p1 + p2 {
            mark = 2
          } else {
            mark = 3
          }
        1 => if x >= p1 + p2 { mark = 3 }
        2 => if x >= p1 + p2 { mark = 3 }
        _ => ()
      }

      let edge = neighbors[j]
      match mark {
        2 =>
          if core_debug_grandom_generator_edge_has_source_node(edge, node) {
            core_debug_grandom_generator_move_source(
              generator,
              edge,
              make_node_shape(node),
              make_node_shape(new_node),
            )
          } else {
            core_debug_grandom_generator_move_target(
              generator,
              edge,
              make_node_shape(node),
              make_node_shape(new_node),
            )
          }
        3 =>
          if core_debug_grandom_generator_edge_has_source_node(edge, node) {
            let targets = edge_targets(edge)
            if !targets.is_empty() {
              ignore(
                core_debug_grandom_generator_connect(
                  generator,
                  make_node_shape(new_node),
                  targets[0],
                ),
              )
            }
          } else {
            let sources = edge_sources(edge)
            if !sources.is_empty() {
              ignore(
                core_debug_grandom_generator_connect(
                  generator,
                  make_node_shape(new_node),
                  sources[0],
                ),
              )
            }
          }
        _ => ()
      }
      j = j + 1
    }
    ignore(
      core_debug_grandom_generator_connect(
        generator,
        make_node_shape(node),
        make_node_shape(new_node),
      ),
    )
    i = i + 1
  }

  let hierarchy_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hierarchy_chance,
  )
  if hierarchy_chance > 0.0 && hierarchy_level < generator.max_hierarchy_level {
    for node in node_children(parent) {
      if !core_debug_grandom_generator_is_hypernode(node) &&
        generator.random.double() < hierarchy_chance {
        let hierarchy_nodes_factor = core_debug_grandom_generator_get_double(
          generator, core_debug_grandom_hierarchy_nodes_factor,
        )
        let child_nodes = core_debug_grandom_generator_random_int(
          generator,
          1,
          (hierarchy_nodes_factor * n.to_double()).to_int(),
        )
        core_debug_grandom_generator_generate_triconnected_graph(
          generator,
          node,
          child_nodes,
          p1,
          p2,
          hierarchy_level + 1,
        )
      }
    }
  }
}

///|
fn core_debug_grandom_generator_generate_ante_graph(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
  m : Int,
  planar : Bool,
  single_source : Bool,
  hierarchy_level : Int,
) -> Unit {
  let nnr : Array[ElkNode] = []
  let vrt = []
  let fst = []
  for _ in 0..<(n + 1) {
    fst.push(0)
  }
  let start_edges = []
  let mut id_counter = 0

  for _ in 0..<n {
    ignore(core_debug_grandom_generator_create_node(generator, parent))
  }

  let mut number_of_layers = 0
  let mut total_number = 0
  let mut real_count = 0
  fst[0] = 0
  for node in node_children(parent) {
    nnr.push(node)
    vrt.push(0)
    total_number = total_number + 1
    real_count = real_count + 1
    let r = generator.random.double()
    if (total_number == 1 && single_source) ||
      real_count == n ||
      r * r * n.to_double() < 1.0 {
      number_of_layers = number_of_layers + 1
      fst[number_of_layers] = total_number
    }
  }

  let left_n = []
  let right_n = []
  for _ in 0..<total_number {
    left_n.push(0)
    right_n.push(0)
  }
  for layer in 1..<number_of_layers {
    if planar {
      let mut n1 = fst[layer - 1]
      let mut n2 = fst[layer]
      left_n[n2] = n1
      while n1 < fst[layer] && n2 < fst[layer + 1] {
        let r = generator.random.double()
        if n1 != fst[layer] - 1 &&
          (
            n2 == fst[layer + 1] - 1 ||
            r <
            (fst[layer] - fst[layer - 1]).to_double() /
            (fst[layer + 1] - fst[layer - 1]).to_double()
          ) {
          n1 = n1 + 1
        } else {
          right_n[n2] = n1
          n2 = n2 + 1
          if n2 < fst[layer + 1] {
            left_n[n2] = n1
          }
        }
      }
    } else {
      let mut n2 = fst[layer]
      while n2 < fst[layer + 1] {
        left_n[n2] = fst[layer - 1]
        right_n[n2] = fst[layer] - 1
        n2 = n2 + 1
      }
    }
  }

  let edge_in : Array[Array[Int]] = []
  let edge_out : Array[Array[Int]] = []
  for _ in 0..<total_number {
    edge_in.push([])
    edge_out.push([])
  }
  let hierarchy_edge_heads = []
  let hierarchy_edge_tails = []
  let hierarchy_edge_ids = []
  let hierarchy_edge_next = []

  if number_of_layers != 0 {
    let mut x1 = m.to_double()
    let mut x2 = 0.0
    for n2 in fst[1]..<total_number {
      if vrt[n2] == 0 {
        x2 = x2 + (right_n[n2] - left_n[n2] + 1).to_double()
      }
    }
    for n2 in fst[1]..<total_number {
      if vrt[n2] == 0 {
        let mut connected = !single_source
        let mut n1 = left_n[n2]
        while n1 <= right_n[n2] || !connected {
          let r = generator.random.double()
          if r < x1 / x2 || n1 > right_n[n2] {
            let mut next = if n1 <= right_n[n2] {
              n1
            } else {
              core_debug_grandom_generator_random_int(
                generator,
                left_n[n2],
                right_n[n2],
              )
            }
            let mut act = n2
            let mut next_edge = core_debug_grandom_generator_create_hierarchy_edge(
              hierarchy_edge_heads, hierarchy_edge_tails, hierarchy_edge_ids, hierarchy_edge_next,
              next, act, id_counter,
            )
            id_counter = id_counter + 1
            while vrt[next] != 0 {
              act = next
              next = core_debug_grandom_generator_random_int(
                generator,
                left_n[act],
                right_n[act],
              )
              edge_out[act].push(next_edge)
              next_edge = core_debug_grandom_generator_create_hierarchy_edge(
                hierarchy_edge_heads, hierarchy_edge_tails, hierarchy_edge_ids, hierarchy_edge_next,
                next, act, id_counter,
              )
              id_counter = id_counter + 1
              edge_in[act].push(next_edge)
            }
            start_edges.push(next_edge)
            connected = true
            x1 = x1 - 1.0
          }
          if n1 <= right_n[n2] {
            x2 = x2 - 1.0
          }
          n1 = n1 + 1
        }
      }
    }
  }

  if planar {
    for act in 0..<total_number {
      core_debug_grandom_generator_sort_hierarchy_edges(edge_in[act], (
        edge1,
        edge2,
      ) => {
        core_debug_grandom_generator_compare_hierarchy_edge_tail(
          edge1, edge2, hierarchy_edge_tails, hierarchy_edge_ids,
        )
      })
      core_debug_grandom_generator_sort_hierarchy_edges(edge_out[act], (
        edge1,
        edge2,
      ) => {
        core_debug_grandom_generator_compare_hierarchy_edge_head(
          edge1, edge2, hierarchy_edge_heads, hierarchy_edge_ids,
        )
      })
    }
  }

  for act in 0..<total_number {
    for hedge in edge_in[act] {
      if edge_out[act].is_empty() {
        break
      }
      let next_edge = edge_out[act][0]
      ignore(edge_out[act].remove(0))
      hierarchy_edge_next[hedge] = next_edge
    }
  }

  for hedge in start_edges {
    let act_edge = hedge
    let mut next_edge = act_edge
    while hierarchy_edge_next[next_edge] >= 0 &&
          vrt[hierarchy_edge_heads[next_edge]] != 0 {
      next_edge = hierarchy_edge_next[next_edge]
    }
    ignore(
      core_debug_grandom_generator_connect(
        generator,
        make_node_shape(nnr[hierarchy_edge_tails[act_edge]]),
        make_node_shape(nnr[hierarchy_edge_heads[next_edge]]),
      ),
    )
  }

  let hierarchy_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hierarchy_chance,
  )
  if hierarchy_chance > 0.0 && hierarchy_level < generator.max_hierarchy_level {
    for node in node_children(parent) {
      if !core_debug_grandom_generator_is_hypernode(node) &&
        generator.random.double() < hierarchy_chance {
        let hierarchy_nodes_factor = core_debug_grandom_generator_get_double(
          generator, core_debug_grandom_hierarchy_nodes_factor,
        )
        let child_nodes = core_debug_grandom_generator_random_int(
          generator,
          1,
          (hierarchy_nodes_factor * n.to_double()).to_int(),
        )
        let density = m.to_double() / (n * n).to_double()
        let child_edges = density.to_int() * child_nodes * child_nodes
        core_debug_grandom_generator_generate_ante_graph(
          generator,
          node,
          child_nodes,
          child_edges,
          planar,
          single_source,
          hierarchy_level + 1,
        )
      }
    }
  }
}

///|
fn core_debug_grandom_generator_create_clique(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
) -> Array[ElkNode] {
  let nodes = core_debug_grandom_generator_create_independent_set(
    generator, parent, n,
  )
  for i in 0..<(n - 1) {
    for j in (i + 1)..<n {
      ignore(
        core_debug_grandom_generator_connect(
          generator,
          make_node_shape(nodes[i]),
          make_node_shape(nodes[j]),
        ),
      )
    }
  }
  nodes
}

///|
fn core_debug_grandom_generator_create_independent_set(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
  n : Int,
) -> Array[ElkNode] {
  let nodes = []
  for _ in 0..<n {
    nodes.push(core_debug_grandom_generator_create_node(generator, parent))
  }
  nodes
}

///|
fn core_debug_grandom_generator_create_node(
  generator : CoreDebugGRandomRandomGraphGenerator,
  parent : ElkNode,
) -> ElkNode {
  let node = create_node(Some(parent))

  let hypernode_chance = core_debug_grandom_generator_get_double(
    generator, core_debug_grandom_hypernode_chance,
  )
  if hypernode_chance > 0.0 && generator.random.double() < hypernode_chance {
    node_set_bool_property(node, core_debug_grandom_hypernode_property, true)
  }

  let node_id = generator.node_label_counter.to_string()
  generator.node_label_counter = generator.node_label_counter + 1
  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_create_node_labels,
    ) {
    let label = create_label(Some(make_node_label_parent(node)))
    label_set_text(label, "N" + node_id)
  }
  node_set_identifier(node, "n" + node_id)

  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_set_node_size,
    ) {
    node_set_dimensions(
      node,
      core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_node_width,
      ).float_val(generator.random),
      core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_node_height,
      ).float_val(generator.random),
    )
  }

  let port_constraints_value = core_debug_grandom_generator_get_port_constraints(
    generator, core_debug_grandom_port_constraints,
  )
  if port_constraints_to_string(port_constraints_value) != "UNDEFINED" {
    node_set_layout_option_string_by_id(
      node,
      port_constraints.get_id(),
      port_constraints_to_string(port_constraints_value),
    )
  }

  node
}

///|
fn core_debug_grandom_generator_create_port(
  generator : CoreDebugGRandomRandomGraphGenerator,
  node : ElkNode,
  source : Bool,
) -> ElkPort {
  let port = create_port(Some(node))

  let port_id = generator.port_label_counter.to_string()
  generator.port_label_counter = generator.port_label_counter + 1
  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_create_port_labels,
    ) {
    let label = create_label(Some(make_port_label_parent(port)))
    label_set_text(label, "P" + port_id)
  }
  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_set_port_size,
    ) {
    port_set_dimensions(
      port,
      core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_port_width,
      ).float_val(generator.random),
      core_debug_grandom_generator_get_rand(
        generator, core_debug_grandom_port_height,
      ).float_val(generator.random),
    )
  }

  let constraints = core_debug_grandom_generator_get_port_constraints(
    generator, core_debug_grandom_port_constraints,
  )
  if constraints.is_side_fixed() {
    let north_prob = if source {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_outgoing_north_side,
      )
    } else {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_incoming_north_side,
      )
    }
    let east_prob = if source {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_outgoing_east_side,
      )
    } else {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_incoming_east_side,
      )
    }
    let south_prob = if source {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_outgoing_south_side,
      )
    } else {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_incoming_south_side,
      )
    }
    let west_prob = if source {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_outgoing_west_side,
      )
    } else {
      core_debug_grandom_generator_get_int(
        generator, core_debug_grandom_incoming_west_side,
      )
    }
    let total = north_prob + east_prob + south_prob + west_prob
    let p = if total > 0 { generator.random.int(limit=total) } else { 0 }
    let side = if p < north_prob {
      PortSide::North
    } else if p < north_prob + east_prob {
      PortSide::East
    } else if p < north_prob + east_prob + south_prob {
      PortSide::South
    } else {
      PortSide::West
    }
    port_set_layout_option_string_by_id(
      port,
      port_side.get_id(),
      port_side_to_string(side),
    )
  }

  port
}

///|
fn core_debug_grandom_generator_connect(
  generator : CoreDebugGRandomRandomGraphGenerator,
  source : ElkConnectableShape,
  target : ElkConnectableShape,
) -> ElkEdge {
  let source_node = core_debug_grandom_generator_shape_to_node(source)
  let target_node = core_debug_grandom_generator_shape_to_node(target)
  let mut source_port = core_debug_grandom_generator_shape_to_port(source)
  let mut target_port = core_debug_grandom_generator_shape_to_port(target)

  let edge = create_edge(None)

  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_enable_ports,
    ) {
    match source {
      NodeShape(node) =>
        source_port = Some(
          core_debug_grandom_generator_retrieve_port(generator, node, true),
        )
      PortShape(_) => ()
    }
    if !core_debug_grandom_generator_is_hypernode(source_node) {
      match source_port {
        Some(port) => edge_add_source(edge, make_port_shape(port))
        None => ()
      }
    }

    if !core_debug_grandom_generator_is_hypernode(target_node) {
      if target_port is None {
        target_port = Some(
          core_debug_grandom_generator_retrieve_port(
            generator, target_node, false,
          ),
        )
      }
      match target_port {
        Some(port) => edge_add_target(edge, make_port_shape(port))
        None => ()
      }
    }
  } else {
    edge_add_source(edge, make_node_shape(source_node))
    edge_add_target(edge, make_node_shape(target_node))
  }

  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_edge_labels,
    ) {
    core_debug_grandom_generator_add_edge_label(generator, edge)
  }

  update_containment(Some(edge))
  edge
}

///|
fn core_debug_grandom_generator_add_edge_label(
  generator : CoreDebugGRandomRandomGraphGenerator,
  edge : ElkEdge,
) -> Unit {
  let label = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(
    label,
    core_debug_grandom_blind_text_generate_with_random(generator.random),
  )
}

///|
fn core_debug_grandom_generator_retrieve_port(
  generator : CoreDebugGRandomRandomGraphGenerator,
  node : ElkNode,
  source : Bool,
) -> ElkPort {
  let reuse_ports_chance = core_debug_grandom_generator_get_rand(
    generator, core_debug_grandom_use_existing_ports_chance,
  ).float_val(generator.random)
  if reuse_ports_chance > 0.0 && generator.random.double() < reuse_ports_chance {
    let reuse_candidates = []
    for port in node_ports(node) {
      let connected_to_desired = (
          !port_incoming_edges(port).is_empty() && !source
        ) ||
        (!port_outgoing_edges(port).is_empty() && source)
      let connected_to_bad = (!port_incoming_edges(port).is_empty() && source) ||
        (!port_outgoing_edges(port).is_empty() && !source)
      if connected_to_desired && !connected_to_bad {
        reuse_candidates.push(port)
      }
    }
    if !reuse_candidates.is_empty() {
      return reuse_candidates[core_debug_grandom_generator_random_int(
          generator,
          0,
          reuse_candidates.length() - 1,
        )]
    }
  }
  core_debug_grandom_generator_create_port(generator, node, source)
}

///|
fn core_debug_grandom_generator_connect_conditional(
  generator : CoreDebugGRandomRandomGraphGenerator,
  source : ElkNode,
  target : ElkNode,
) -> Bool {
  if core_debug_grandom_generator_basic_condition(generator, source, target) {
    ignore(
      core_debug_grandom_generator_connect(
        generator,
        make_node_shape(source),
        make_node_shape(target),
      ),
    )
    true
  } else {
    false
  }
}

///|
fn[T : Eq] core_debug_grandom_generator_remove_first(
  array : Array[T],
  value : T,
) -> Bool {
  let mut index = 0
  while index < array.length() {
    if array[index] == value {
      ignore(array.remove(index))
      return true
    }
    index = index + 1
  }
  false
}

///|
fn core_debug_grandom_generator_connectable_shape_equals(
  left : ElkConnectableShape,
  right : ElkConnectableShape,
) -> Bool {
  match (left, right) {
    (NodeShape(left_node), NodeShape(right_node)) => left_node == right_node
    (PortShape(left_port), PortShape(right_port)) => left_port == right_port
    _ => false
  }
}

///|
fn core_debug_grandom_generator_remove_first_connectable_shape(
  array : Array[ElkConnectableShape],
  value : ElkConnectableShape,
) -> Bool {
  let mut index = 0
  while index < array.length() {
    if core_debug_grandom_generator_connectable_shape_equals(
        array[index],
        value,
      ) {
      ignore(array.remove(index))
      return true
    }
    index = index + 1
  }
  false
}

///|
fn core_debug_grandom_generator_edge_has_source_node(
  edge : ElkEdge,
  node : ElkNode,
) -> Bool {
  for source in edge_sources(edge) {
    match source {
      NodeShape(source_node) => if source_node == node { return true }
      PortShape(_) => ()
    }
  }
  false
}

///|
fn core_debug_grandom_generator_remove_unused_port(port : ElkPort) -> Unit {
  if port_outgoing_edges(port).length() == 0 &&
    port_incoming_edges(port).length() == 1 {
    match port_parent(port) {
      Some(parent_node) =>
        ignore(
          core_debug_grandom_generator_remove_first(
            node_ports(parent_node),
            port,
          ),
        )
      None => ()
    }
  }
}

///|
fn core_debug_grandom_generator_move_source(
  generator : CoreDebugGRandomRandomGraphGenerator,
  edge : ElkEdge,
  old_connect_shape : ElkConnectableShape,
  new_connect_shape : ElkConnectableShape,
) -> Unit {
  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_enable_ports,
    ) {
    if !edge_sources(edge).is_empty() {
      match old_connect_shape {
        NodeShape(old_node) => {
          let sources = edge_sources(edge)
          let mut index = 0
          while index < sources.length() {
            match sources[index] {
              PortShape(port) =>
                match port_parent(port) {
                  Some(parent_node) =>
                    if parent_node == old_node {
                      ignore(sources.remove(index))
                      core_debug_grandom_generator_remove_unused_port(port)
                    } else {
                      index = index + 1
                    }
                  None => index = index + 1
                }
              NodeShape(_) => index = index + 1
            }
          }
        }
        PortShape(old_port) => {
          ignore(
            core_debug_grandom_generator_remove_first_connectable_shape(
              edge_sources(edge),
              make_port_shape(old_port),
            ),
          )
          core_debug_grandom_generator_remove_unused_port(old_port)
        }
      }
    }

    let mut new_node_opt : ElkNode? = None
    let mut new_port_opt : ElkPort? = None
    match new_connect_shape {
      NodeShape(_) => {
        let new_node = core_debug_grandom_generator_shape_to_node(
          old_connect_shape,
        )
        new_node_opt = Some(new_node)
        new_port_opt = Some(
          core_debug_grandom_generator_retrieve_port(generator, new_node, true),
        )
      }
      PortShape(_) => {
        new_port_opt = core_debug_grandom_generator_shape_to_port(
          old_connect_shape,
        )
        match new_port_opt {
          Some(port) => new_node_opt = port_parent(port)
          None => ()
        }
      }
    }

    match new_node_opt {
      Some(new_node) =>
        if !core_debug_grandom_generator_is_hypernode(new_node) {
          match new_port_opt {
            Some(new_port) => edge_sources(edge).push(make_port_shape(new_port))
            None => ()
          }
        }
      None => ()
    }
  } else {
    let old_node = core_debug_grandom_generator_shape_to_node(old_connect_shape)
    ignore(
      core_debug_grandom_generator_remove_first_connectable_shape(
        edge_sources(edge),
        make_node_shape(old_node),
      ),
    )
    let new_node = core_debug_grandom_generator_shape_to_node(new_connect_shape)
    edge_sources(edge).push(make_node_shape(new_node))
  }
  update_containment(Some(edge))
}

///|
fn core_debug_grandom_generator_move_target(
  generator : CoreDebugGRandomRandomGraphGenerator,
  edge : ElkEdge,
  old_connect_shape : ElkConnectableShape,
  new_connect_shape : ElkConnectableShape,
) -> Unit {
  if core_debug_grandom_generator_get_bool(
      generator, core_debug_grandom_enable_ports,
    ) {
    if !edge_targets(edge).is_empty() {
      match old_connect_shape {
        NodeShape(old_node) => {
          let targets = edge_targets(edge)
          let mut index = 0
          while index < targets.length() {
            match targets[index] {
              PortShape(port) =>
                match port_parent(port) {
                  Some(parent_node) =>
                    if parent_node == old_node {
                      ignore(targets.remove(index))
                      core_debug_grandom_generator_remove_unused_port(port)
                    } else {
                      index = index + 1
                    }
                  None => index = index + 1
                }
              NodeShape(_) => index = index + 1
            }
          }
        }
        PortShape(old_port) => {
          ignore(
            core_debug_grandom_generator_remove_first_connectable_shape(
              edge_targets(edge),
              make_port_shape(old_port),
            ),
          )
          core_debug_grandom_generator_remove_unused_port(old_port)
        }
      }
    }

    let mut new_node_opt : ElkNode? = None
    let mut new_port_opt : ElkPort? = None
    match new_connect_shape {
      NodeShape(_) => {
        let new_node = core_debug_grandom_generator_shape_to_node(
          old_connect_shape,
        )
        new_node_opt = Some(new_node)
        new_port_opt = Some(
          core_debug_grandom_generator_retrieve_port(generator, new_node, true),
        )
      }
      PortShape(_) => {
        new_port_opt = core_debug_grandom_generator_shape_to_port(
          old_connect_shape,
        )
        match new_port_opt {
          Some(port) => new_node_opt = port_parent(port)
          None => ()
        }
      }
    }

    match new_node_opt {
      Some(new_node) =>
        if !core_debug_grandom_generator_is_hypernode(new_node) {
          match new_port_opt {
            Some(new_port) => edge_targets(edge).push(make_port_shape(new_port))
            None => ()
          }
        }
      None => ()
    }
  } else {
    let old_node = core_debug_grandom_generator_shape_to_node(old_connect_shape)
    ignore(
      core_debug_grandom_generator_remove_first_connectable_shape(
        edge_targets(edge),
        make_node_shape(old_node),
      ),
    )
    let new_node = core_debug_grandom_generator_shape_to_node(new_connect_shape)
    edge_targets(edge).push(make_node_shape(new_node))
  }
  update_containment(Some(edge))
}

///|
fn core_debug_grandom_generator_split(
  generator : CoreDebugGRandomRandomGraphGenerator,
  edge : ElkEdge,
) -> (ElkNode, ElkEdge) {
  let parent = match edge_containing_node(edge) {
    Some(node) => node
    None => abort("split requires edge containment")
  }
  let new_node = core_debug_grandom_generator_create_node(generator, parent)
  let targets = edge_targets(edge)
  if targets.is_empty() {
    abort("split requires edge target")
  }
  let old_target = targets[0]
  let new_edge = core_debug_grandom_generator_connect(
    generator,
    make_node_shape(new_node),
    old_target,
  )
  ignore(targets.remove(0))
  let new_edge_targets = edge_targets(new_edge)
  for target in targets {
    new_edge_targets.push(target)
  }
  targets.clear()
  targets.push(old_target)
  core_debug_grandom_generator_move_target(
    generator,
    edge,
    edge_targets(edge)[0],
    make_node_shape(new_node),
  )
  update_containment(Some(new_edge))
  (new_node, new_edge)
}

///|
fn core_debug_grandom_generator_create_hierarchy_edge(
  heads : Array[Int],
  tails : Array[Int],
  ids : Array[Int],
  nexts : Array[Int],
  head : Int,
  tail : Int,
  id : Int,
) -> Int {
  heads.push(head)
  tails.push(tail)
  ids.push(id)
  nexts.push(-1)
  heads.length() - 1
}

///|
fn core_debug_grandom_generator_compare_hierarchy_edge_id(
  edge1 : Int,
  edge2 : Int,
  ids : Array[Int],
) -> Int {
  if ids[edge1] < ids[edge2] {
    -1
  } else if ids[edge1] > ids[edge2] {
    1
  } else {
    0
  }
}

///|
fn core_debug_grandom_generator_compare_hierarchy_edge_head(
  edge1 : Int,
  edge2 : Int,
  heads : Array[Int],
  ids : Array[Int],
) -> Int {
  if heads[edge1] < heads[edge2] {
    -1
  } else if heads[edge1] > heads[edge2] {
    1
  } else {
    core_debug_grandom_generator_compare_hierarchy_edge_id(edge1, edge2, ids)
  }
}

///|
fn core_debug_grandom_generator_compare_hierarchy_edge_tail(
  edge1 : Int,
  edge2 : Int,
  tails : Array[Int],
  ids : Array[Int],
) -> Int {
  if tails[edge1] < tails[edge2] {
    -1
  } else if tails[edge1] > tails[edge2] {
    1
  } else {
    core_debug_grandom_generator_compare_hierarchy_edge_id(edge1, edge2, ids)
  }
}

///|
fn core_debug_grandom_generator_sort_hierarchy_edges(
  edges : Array[Int],
  compare : (Int, Int) -> Int,
) -> Unit {
  let mut index = 1
  while index < edges.length() {
    let value = edges[index]
    let mut cursor = index
    while cursor > 0 && compare(edges[cursor - 1], value) > 0 {
      edges[cursor] = edges[cursor - 1]
      cursor = cursor - 1
    }
    edges[cursor] = value
    index = index + 1
  }
}

///|
fn core_debug_grandom_generator_connect_randomly_and_conditional(
  generator : CoreDebugGRandomRandomGraphGenerator,
  source : ElkNode,
  targets : Array[ElkNode],
  number : Int,
) -> Int {
  let target_buffer = targets.copy()
  let mut edges = 0
  let mut buffer_end = target_buffer.length() - 1
  while edges < number && buffer_end >= 0 {
    let index = core_debug_grandom_generator_random_int(
      generator, 0, buffer_end,
    )
    let target = target_buffer[index]
    if core_debug_grandom_generator_connect_conditional(
        generator, source, target,
      ) {
      edges = edges + 1
    } else {
      target_buffer[index] = target_buffer[buffer_end]
      buffer_end = buffer_end - 1
    }
  }
  edges
}

///|
fn core_debug_grandom_generator_connect_randomly_and_conditional_all(
  generator : CoreDebugGRandomRandomGraphGenerator,
  nodes : Array[ElkNode],
  outgoing_edges : Array[Int],
) -> Int {
  let mut edges = 0
  for i in 0..<nodes.length() {
    edges = edges +
      core_debug_grandom_generator_connect_randomly_and_conditional(
        generator,
        nodes[i],
        nodes,
        outgoing_edges[i],
      )
  }
  edges
}

///|
fn core_debug_grandom_generator_determine_outgoing_edges_rand(
  generator : CoreDebugGRandomRandomGraphGenerator,
  nodes : Array[ElkNode],
  value : CoreDebugGRandomRandVal,
) -> Array[Int] {
  let number_of_edges = []
  for _ in 0..<nodes.length() {
    number_of_edges.push(value.int_val(generator.random))
  }
  number_of_edges
}

///|
fn core_debug_grandom_generator_determine_outgoing_edges_total(
  generator : CoreDebugGRandomRandomGraphGenerator,
  nodes : Array[ElkNode],
  edges_total : Int,
) -> Array[Int] {
  let outgoing_edges = []
  for _ in 0..<nodes.length() {
    outgoing_edges.push(0)
  }
  for _ in 0..<edges_total {
    let index = core_debug_grandom_generator_random_int(
      generator,
      0,
      nodes.length() - 1,
    )
    outgoing_edges[index] = outgoing_edges[index] + 1
  }
  outgoing_edges
}

///|
fn core_debug_grandom_generator_remove_isolated_nodes(parent : ElkNode) -> Unit {
  let children = node_children(parent)
  let mut index = 0
  while index < children.length() {
    let node = children[index]
    core_debug_grandom_generator_remove_isolated_nodes(node)
    if node_incoming_edges(node).is_empty() &&
      node_outgoing_edges(node).is_empty() &&
      node_children(node).is_empty() {
      ignore(children.remove(index))
    } else {
      index = index + 1
    }
  }
}

///|
fn core_debug_grandom_generator_find_node_with_dfs(
  start : ElkNode,
  end_node : ElkNode,
) -> Bool {
  let nodes = [start]
  while !nodes.is_empty() {
    let node = nodes[0]
    ignore(nodes.remove(0))
    if node == end_node {
      return true
    }
    for edge in node_outgoing_edges(node) {
      for target in edge_targets(edge) {
        match target {
          NodeShape(target_node) => nodes.push(target_node)
          PortShape(port) =>
            match port_parent(port) {
              Some(parent_node) => nodes.push(parent_node)
              None => ()
            }
        }
      }
    }
  }
  false
}

///|
fn core_debug_grandom_generator_connected(
  node1 : ElkNode,
  node2 : ElkNode,
) -> Bool {
  for edge in node_outgoing_edges(node1) {
    for target in edge_targets(edge) {
      match target {
        NodeShape(node) => if node == node2 { return true }
        PortShape(_) => ()
      }
    }
  }
  for edge in node_outgoing_edges(node2) {
    for target in edge_targets(edge) {
      match target {
        NodeShape(node) => if node == node1 { return true }
        PortShape(_) => ()
      }
    }
  }
  false
}

///|
fn core_debug_grandom_generator_distribute_ports(
  generator : CoreDebugGRandomRandomGraphGenerator,
  node : ElkNode,
) -> Unit {
  let mut north_count = 0
  let mut east_count = 0
  let mut south_count = 0
  let mut west_count = 0

  for port in node_ports(node) {
    match core_debug_grandom_generator_port_side_or_undefined(port) {
      North => north_count = north_count + 1
      East => east_count = east_count + 1
      South => south_count = south_count + 1
      West => west_count = west_count + 1
      PortSide::SideUndefined => ()
    }
  }

  let port_width_value = core_debug_grandom_generator_get_rand(
    generator, core_debug_grandom_port_width,
  ).float_val(generator.random)
  let port_height_value = core_debug_grandom_generator_get_rand(
    generator, core_debug_grandom_port_height,
  ).float_val(generator.random)
  if node_width(node) <
    (north_count + 1).to_double() *
    (port_width_value + core_debug_grandom_port_separation) {
    node_set_dimensions(
      node,
      (north_count + 1).to_double() *
      (port_width_value + core_debug_grandom_port_separation),
      node_height(node),
    )
  }
  if node_width(node) <
    (south_count + 1).to_double() *
    (port_width_value + core_debug_grandom_port_separation) {
    node_set_dimensions(
      node,
      (south_count + 1).to_double() *
      (port_width_value + core_debug_grandom_port_separation),
      node_height(node),
    )
  }
  if node_height(node) <
    (east_count + 1).to_double() *
    (port_height_value + core_debug_grandom_port_separation) {
    node_set_dimensions(
      node,
      node_width(node),
      (east_count + 1).to_double() *
      (port_height_value + core_debug_grandom_port_separation),
    )
  }
  if node_height(node) <
    (west_count + 1).to_double() *
    (port_height_value + core_debug_grandom_port_separation) {
    node_set_dimensions(
      node,
      node_width(node),
      (west_count + 1).to_double() *
      (port_height_value + core_debug_grandom_port_separation),
    )
  }

  let north_delta = node_width(node) / (north_count + 1).to_double()
  let east_delta = node_height(node) / (east_count + 1).to_double()
  let south_delta = node_width(node) / (south_count + 1).to_double()
  let west_delta = node_height(node) / (west_count + 1).to_double()

  let mut north_pos = 0.0
  let mut east_pos = 0.0
  let mut south_pos = 0.0
  let mut west_pos = 0.0

  for port in node_ports(node) {
    match core_debug_grandom_generator_port_side_or_undefined(port) {
      North => {
        north_pos = north_pos + north_delta
        port_set_location(
          port,
          north_pos - port_width(port) / 2.0,
          -port_height(port),
        )
      }
      East => {
        east_pos = east_pos + east_delta
        port_set_location(
          port,
          node_width(node),
          east_pos - port_height(port) / 2.0,
        )
      }
      South => {
        south_pos = south_pos + south_delta
        port_set_location(
          port,
          south_pos - port_width(port) / 2.0,
          node_height(node),
        )
      }
      West => {
        west_pos = west_pos + west_delta
        port_set_location(
          port,
          -port_width(port),
          west_pos - port_height(port) / 2.0,
        )
      }
      PortSide::SideUndefined => ()
    }
  }
}

///|
fn core_debug_grandom_generator_random_int(
  generator : CoreDebugGRandomRandomGraphGenerator,
  from : Int,
  to : Int,
) -> Int {
  from + generator.random.int(limit=to - from + 1)
}

///|
fn core_debug_grandom_generator_is_hypernode(node : ElkNode) -> Bool {
  node_get_bool_property(node, core_debug_grandom_hypernode_property)
}

///|
fn core_debug_grandom_generator_bound_int(
  value : Int,
  min : Int,
  max : Int,
) -> Int {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}

///|
fn core_debug_grandom_generator_shape_to_node(
  shape : ElkConnectableShape,
) -> ElkNode {
  match shape {
    NodeShape(node) => node
    PortShape(port) =>
      match port_parent(port) {
        Some(parent_node) => parent_node
        None => abort("port parent cannot be null")
      }
  }
}

///|
fn core_debug_grandom_generator_shape_to_port(
  shape : ElkConnectableShape,
) -> ElkPort? {
  match shape {
    NodeShape(_) => None
    PortShape(port) => Some(port)
  }
}

///|
fn core_debug_grandom_generator_port_side_or_undefined(
  port : ElkPort,
) -> PortSide {
  match port_layout_option_string_value(port, port_side.get_id()) {
    Some(side_name) => {
      for value in port_side_values() {
        if port_side_to_string(value) == side_name {
          return value
        }
      }
      PortSide::SideUndefined
    }
    None => PortSide::SideUndefined
  }
}

///|
fn core_debug_grandom_generator_get_bool(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[Bool],
) -> Bool {
  generator.options.get_bool_property(property)
}

///|
fn core_debug_grandom_generator_set_bool(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  generator.options.set_bool_property(property, value)
}

///|
fn core_debug_grandom_generator_get_int(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[Int],
) -> Int {
  generator.options.get_int_property(property)
}

///|
fn core_debug_grandom_generator_get_double(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[Double],
) -> Double {
  generator.options.get_double_property(property)
}

///|
fn core_debug_grandom_generator_set_double(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  generator.options.set_double_property(property, value)
}

///|
fn core_debug_grandom_generator_get_rand(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[CoreDebugGRandomRandVal],
) -> CoreDebugGRandomRandVal {
  generator.options.get_rand_property(property)
}

///|
fn core_debug_grandom_generator_get_optional_rand(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[CoreDebugGRandomRandVal?],
) -> CoreDebugGRandomRandVal? {
  generator.options.get_optional_rand_property(property)
}

///|
fn core_debug_grandom_generator_get_port_constraints(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[PortConstraints],
) -> PortConstraints {
  generator.options.get_port_constraints_property(property)
}

///|
fn core_debug_grandom_generator_get_graph_type(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[CoreDebugGRandomGraphType],
) -> CoreDebugGRandomGraphType {
  generator.options.get_graph_type_property(property)
}

///|
fn core_debug_grandom_generator_get_edge_determination(
  generator : CoreDebugGRandomRandomGraphGenerator,
  property : IProperty[CoreDebugGRandomEdgeDetermination],
) -> CoreDebugGRandomEdgeDetermination {
  generator.options.get_edge_determination_property(property)
}
