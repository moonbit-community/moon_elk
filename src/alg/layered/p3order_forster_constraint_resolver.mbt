///|
let forster_constraint_group_next_handle_ref : Ref[Int] = Ref::new(0)

///|
fn forster_constraint_group_next_handle() -> Int {
  let handle = forster_constraint_group_next_handle_ref.val
  forster_constraint_group_next_handle_ref.val = handle + 1
  handle
}

///|
fn forster_node_is_normal(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn forster_group_is(left : ConstraintGroup, right : ConstraintGroup) -> Bool {
  left.group_handle == right.group_handle
}

///|
fn forster_group_list_contains(
  groups : Array[ConstraintGroup],
  target : ConstraintGroup,
) -> Bool {
  for group in groups {
    if forster_group_is(group, target) {
      return true
    }
  }
  false
}

///|
fn forster_group_list_index_of(
  groups : Array[ConstraintGroup],
  target : ConstraintGroup,
) -> Int {
  for i in 0..<groups.length() {
    if forster_group_is(groups[i], target) {
      return i
    }
  }
  -1
}

///|
fn forster_group_list_remove_first_by_handle(
  groups : Array[ConstraintGroup],
  target : ConstraintGroup,
) -> Bool {
  for i in 0..<groups.length() {
    if forster_group_is(groups[i], target) {
      ignore(groups.remove(i))
      return true
    }
  }
  false
}

///|
fn forster_group_barycenter_value(group : ConstraintGroup) -> Double {
  match group.get_barycenter() {
    Some(value) => value
    None => abort("constraint group barycenter is undefined")
  }
}

///|
pub struct BarycenterState {
  node : LNode
  mut summed_weight : Double
  mut degree : Int
  mut barycenter : Double?
  mut visited : Bool
}

///|
pub fn new_barycenter_state(node : LNode) -> BarycenterState {
  { node, summed_weight: 0.0, degree: 0, barycenter: None, visited: false }
}

///|
pub fn BarycenterState::to_string(self : BarycenterState) -> String {
  "BarycenterState[node=" +
  self.node.to_string() +
  ", summedWeight=" +
  self.summed_weight.to_string() +
  ", degree=" +
  self.degree.to_string() +
  ", barycenter=" +
  self.barycenter.to_string() +
  ", visited=" +
  self.visited.to_string() +
  "]"
}

///|
struct ConstraintGroup {
  group_handle : Int
  summed_weight : Double
  degree : Int
  nodes : Array[LNode]
  mut barycenter : Double?
  mut outgoing_constraints : Array[ConstraintGroup]?
  mut incoming_constraints : Array[ConstraintGroup]?
  mut incoming_constraints_count : Int
}

///|
fn new_constraint_group(node : LNode) -> ConstraintGroup {
  {
    group_handle: forster_constraint_group_next_handle(),
    summed_weight: 0.0,
    degree: 0,
    nodes: [node],
    barycenter: None,
    outgoing_constraints: None,
    incoming_constraints: None,
    incoming_constraints_count: 0,
  }
}

///|
fn new_constraint_group_merged(
  first : ConstraintGroup,
  second : ConstraintGroup,
) -> ConstraintGroup {
  let nodes = first.nodes.copy()
  for node in second.nodes {
    nodes.push(node)
  }

  let mut outgoing_constraints : Array[ConstraintGroup]? = None
  match first.outgoing_constraints {
    Some(first_outgoing) => {
      let outgoing = []
      for candidate in first_outgoing {
        if !forster_group_is(candidate, second) {
          outgoing.push(candidate)
        }
      }

      match second.outgoing_constraints {
        Some(second_outgoing) =>
          for candidate in second_outgoing {
            if forster_group_is(candidate, first) {
              continue
            } else if forster_group_list_contains(outgoing, candidate) {
              candidate.incoming_constraints_count = candidate.incoming_constraints_count -
                1
            } else {
              outgoing.push(candidate)
            }
          }
        None => ()
      }

      outgoing_constraints = Some(outgoing)
    }
    None =>
      match second.outgoing_constraints {
        Some(second_outgoing) => {
          let outgoing = []
          for candidate in second_outgoing {
            if !forster_group_is(candidate, first) {
              outgoing.push(candidate)
            }
          }
          outgoing_constraints = Some(outgoing)
        }
        None => ()
      }
  }

  let result : ConstraintGroup = {
    group_handle: forster_constraint_group_next_handle(),
    summed_weight: first.summed_weight + second.summed_weight,
    degree: first.degree + second.degree,
    nodes,
    barycenter: None,
    outgoing_constraints,
    incoming_constraints: None,
    incoming_constraints_count: 0,
  }

  if result.degree > 0 {
    result.barycenter = Some(result.summed_weight / result.degree.to_double())
  } else {
    match (first.get_barycenter(), second.get_barycenter()) {
      (Some(first_barycenter), Some(second_barycenter)) =>
        result.barycenter = Some((first_barycenter + second_barycenter) / 2.0)
      (Some(first_barycenter), None) =>
        result.barycenter = Some(first_barycenter)
      (None, Some(second_barycenter)) =>
        result.barycenter = Some(second_barycenter)
      (None, None) => ()
    }
  }

  result
}

///|
fn ConstraintGroup::set_barycenter(
  self : ConstraintGroup,
  barycenter : Double?,
) -> Unit {
  self.barycenter = barycenter
}

///|
fn ConstraintGroup::get_barycenter(self : ConstraintGroup) -> Double? {
  self.barycenter
}

///|
fn ConstraintGroup::get_outgoing_constraints(
  self : ConstraintGroup,
) -> Array[ConstraintGroup] {
  match self.outgoing_constraints {
    Some(constraints) => constraints
    None => {
      self.outgoing_constraints = Some([])
      match self.outgoing_constraints {
        Some(constraints) => constraints
        None =>
          abort("constraint group outgoing constraints are not initialized")
      }
    }
  }
}

///|
fn ConstraintGroup::reset_outgoing_constraints(self : ConstraintGroup) -> Unit {
  self.outgoing_constraints = None
}

///|
fn ConstraintGroup::has_outgoing_constraints(self : ConstraintGroup) -> Bool {
  match self.outgoing_constraints {
    Some(constraints) => constraints.length() > 0
    None => false
  }
}

///|
fn ConstraintGroup::get_incoming_constraints(
  self : ConstraintGroup,
) -> Array[ConstraintGroup] {
  match self.incoming_constraints {
    Some(constraints) => constraints
    None => {
      self.incoming_constraints = Some([])
      match self.incoming_constraints {
        Some(constraints) => constraints
        None =>
          abort("constraint group incoming constraints are not initialized")
      }
    }
  }
}

///|
fn ConstraintGroup::reset_incoming_constraints(self : ConstraintGroup) -> Unit {
  self.incoming_constraints = None
}

///|
fn ConstraintGroup::has_incoming_constraints(self : ConstraintGroup) -> Bool {
  match self.incoming_constraints {
    Some(constraints) => constraints.length() > 0
    None => false
  }
}

///|
fn ConstraintGroup::get_nodes(self : ConstraintGroup) -> Array[LNode] {
  self.nodes
}

///|
fn ConstraintGroup::get_node(self : ConstraintGroup) -> LNode {
  if self.nodes.length() != 1 {
    abort("constraint group must contain exactly one node")
  }
  self.nodes[0]
}

///|
pub struct ForsterConstraintResolver {
  constraints_between_non_dummies : Bool
  layout_units : Map[Int, Array[LNode]]
  barycenter_states : Array[Array[BarycenterState?]]
  constraint_groups : Array[Array[ConstraintGroup?]]
}

///|
pub fn new_forster_constraint_resolver(
  current_node_order : Array[Array[LNode]],
) -> ForsterConstraintResolver {
  let mut constraints_between_non_dummies = false
  if current_node_order.length() > 0 && current_node_order[0].length() > 0 {
    constraints_between_non_dummies = current_node_order[0][0]
      .get_graph()
      .get_property_bool(
        internal_properties_in_layer_successor_constraints_between_non_dummies,
      )
  }

  {
    constraints_between_non_dummies,
    layout_units: {},
    barycenter_states: Array::make(current_node_order.length(), []),
    constraint_groups: Array::make(current_node_order.length(), []),
  }
}

///|
fn ForsterConstraintResolver::state_of(
  self : ForsterConstraintResolver,
  node : LNode,
) -> BarycenterState {
  let layer_index = match node.get_layer() {
    Some(layer) => layer.get_id()
    None => abort("node has no layer")
  }
  let node_index = node.get_id()
  match self.barycenter_states[layer_index][node_index] {
    Some(state) => state
    None => abort("barycenter state is not initialized")
  }
}

///|
fn ForsterConstraintResolver::group_of(
  self : ForsterConstraintResolver,
  node : LNode,
) -> ConstraintGroup {
  let layer_index = match node.get_layer() {
    Some(layer) => layer.get_id()
    None => abort("node has no layer")
  }
  let node_index = node.get_id()
  match self.constraint_groups[layer_index][node_index] {
    Some(group) => group
    None => abort("constraint group is not initialized")
  }
}

///|
fn ForsterConstraintResolver::layout_unit_nodes(
  self : ForsterConstraintResolver,
  layout_unit : LNode,
) -> Array[LNode] {
  match self.layout_units.get(lnode_internal_handle(layout_unit)) {
    Some(nodes) => nodes
    None => []
  }
}

///|
fn ForsterConstraintResolver::init_at_node_level_internal(
  self : ForsterConstraintResolver,
  node : LNode,
  full_init : Bool,
) -> Unit {
  let layer_index = match node.get_layer() {
    Some(layer) => layer.get_id()
    None => abort("node has no layer")
  }
  let node_index = node.get_id()

  if full_init {
    self.barycenter_states[layer_index][node_index] = Some(
      new_barycenter_state(node),
    )
  }

  let group = new_constraint_group(node)
  group.set_barycenter(self.state_of(node).barycenter)
  self.constraint_groups[layer_index][node_index] = Some(group)

  if full_init {
    match node.get_property_l_node(internal_properties_in_layer_layout_unit) {
      Some(layout_unit) => {
        let key = lnode_internal_handle(layout_unit)
        match self.layout_units.get(key) {
          Some(nodes) => nodes.push(node)
          None => self.layout_units[key] = [node]
        }
      }
      None => ()
    }
  }
}

///|
pub fn ForsterConstraintResolver::init_at_layer_level(
  self : ForsterConstraintResolver,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.barycenter_states[l] = Array::make(node_order[l].length(), None)
  self.constraint_groups[l] = Array::make(node_order[l].length(), None)

  if node_order[l].length() > 0 {
    match node_order[l][0].get_layer() {
      Some(layer) => layer.set_id(l)
      None => ()
    }
  }
}

///|
pub fn ForsterConstraintResolver::init_at_node_level(
  self : ForsterConstraintResolver,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  ignore(l)
  self.init_at_node_level_internal(node_order[l][n], true)
}

///|
pub fn ForsterConstraintResolver::get_barycenter_states(
  self : ForsterConstraintResolver,
) -> Array[Array[BarycenterState?]] {
  self.barycenter_states
}

///|
pub fn ForsterConstraintResolver::as_initializable(
  self : ForsterConstraintResolver,
) -> IInitializable {
  new_i_initializable(
    init_at_layer_level=(l, node_order) => {
      self.init_at_layer_level(l, node_order)
    },
    init_at_node_level=(l, n, node_order) => {
      self.init_at_node_level(l, n, node_order)
    },
  )
}

///|
pub fn ForsterConstraintResolver::set_barycenter(
  self : ForsterConstraintResolver,
  node : LNode,
  barycenter : Double?,
) -> Unit {
  self.state_of(node).barycenter = barycenter
}

///|
pub fn ForsterConstraintResolver::process_constraints(
  self : ForsterConstraintResolver,
  nodes : Array[LNode],
) -> Unit {
  if self.constraints_between_non_dummies {
    self.process_constraints_stage(nodes, true)
    for node in nodes {
      self.init_at_node_level_internal(node, false)
    }
  }

  self.process_constraints_stage(nodes, false)
}

///|
fn ForsterConstraintResolver::process_constraints_stage(
  self : ForsterConstraintResolver,
  nodes : Array[LNode],
  only_between_normal_nodes : Bool,
) -> Unit {
  let groups = []
  for node in nodes {
    let group = self.group_of(node)
    group.set_barycenter(self.state_of(node).barycenter)
    groups.push(group)
  }

  self.build_constraints_graph(groups, only_between_normal_nodes)

  while true {
    match self.find_violated_constraint(groups) {
      Some((first_group, second_group)) =>
        self.handle_violated_constraint(first_group, second_group, groups)
      None => break
    }
  }

  nodes.clear()
  for group in groups {
    for node in group.get_nodes() {
      nodes.push(node)
      self.state_of(node).barycenter = group.get_barycenter()
    }
  }
}

///|
fn ForsterConstraintResolver::build_constraints_graph(
  self : ForsterConstraintResolver,
  groups : Array[ConstraintGroup],
  only_between_normal_nodes : Bool,
) -> Unit {
  for group in groups {
    group.reset_outgoing_constraints()
    group.incoming_constraints_count = 0
  }

  let mut last_non_dummy_node : LNode? = None
  for group in groups {
    let node = group.get_node()
    if only_between_normal_nodes && !forster_node_is_normal(node) {
      continue
    }

    for
      successor in node.get_property_l_node_array(
        internal_properties_in_layer_successor_constraints,
      ) {
      if !only_between_normal_nodes || forster_node_is_normal(successor) {
        group.get_outgoing_constraints().push(self.group_of(successor))
        self.group_of(successor).incoming_constraints_count = self.group_of(
            successor,
          ).incoming_constraints_count +
          1
      }
    }

    if !only_between_normal_nodes && forster_node_is_normal(node) {
      match last_non_dummy_node {
        Some(last_non_dummy) =>
          for last_unit_node in self.layout_unit_nodes(last_non_dummy) {
            for current_unit_node in self.layout_unit_nodes(node) {
              self
              .group_of(last_unit_node)
              .get_outgoing_constraints()
              .push(self.group_of(current_unit_node))
              self.group_of(current_unit_node).incoming_constraints_count = self.group_of(
                  current_unit_node,
                ).incoming_constraints_count +
                1
            }
          }
        None => ()
      }

      last_non_dummy_node = Some(node)
    }
  }
}

///|
fn ForsterConstraintResolver::find_violated_constraint(
  _self : ForsterConstraintResolver,
  groups : Array[ConstraintGroup],
) -> (ConstraintGroup, ConstraintGroup)? {
  let active_groups = []

  let mut last_value = -32768.0
  for group in groups {
    let barycenter = forster_group_barycenter_value(group)
    if barycenter < last_value {
      abort("constraint groups must be sorted by barycenter")
    }
    last_value = barycenter
    group.reset_incoming_constraints()

    if group.has_outgoing_constraints() && group.incoming_constraints_count == 0 {
      active_groups.push(group)
    }
  }

  while !active_groups.is_empty() {
    let group = active_groups.remove(0)

    if group.has_incoming_constraints() {
      for predecessor in group.get_incoming_constraints() {
        let predecessor_barycenter = forster_group_barycenter_value(predecessor)
        let group_barycenter = forster_group_barycenter_value(group)

        if Float::from_double(predecessor_barycenter) ==
          Float::from_double(group_barycenter) {
          if forster_group_list_index_of(groups, predecessor) >
            forster_group_list_index_of(groups, group) {
            return Some((predecessor, group))
          }
        } else if predecessor_barycenter > group_barycenter {
          return Some((predecessor, group))
        }
      }
    }

    for successor in group.get_outgoing_constraints() {
      let successor_incoming = successor.get_incoming_constraints()
      ignore(successor_incoming.insert(0, group))

      if successor.incoming_constraints_count == successor_incoming.length() {
        active_groups.push(successor)
      }
    }
  }

  None
}

///|
let forster_barycenter_equality_delta : Double = 0.0001

///|
fn ForsterConstraintResolver::handle_violated_constraint(
  _self : ForsterConstraintResolver,
  first_group : ConstraintGroup,
  second_group : ConstraintGroup,
  node_groups : Array[ConstraintGroup],
) -> Unit {
  let new_group = new_constraint_group_merged(first_group, second_group)
  let new_barycenter = forster_group_barycenter_value(new_group)
  if new_barycenter + forster_barycenter_equality_delta <
    forster_group_barycenter_value(second_group) {
    abort("merged barycenter is below second group barycenter")
  }
  if new_barycenter - forster_barycenter_equality_delta >
    forster_group_barycenter_value(first_group) {
    abort("merged barycenter is above first group barycenter")
  }

  let remaining = []
  for node_group in node_groups {
    if !forster_group_is(node_group, first_group) &&
      !forster_group_is(node_group, second_group) {
      remaining.push(node_group)
    }
  }

  for node_group in remaining {
    if node_group.has_outgoing_constraints() {
      let outgoing = node_group.get_outgoing_constraints()
      let mut had_constraint = false

      if forster_group_list_remove_first_by_handle(outgoing, first_group) {
        had_constraint = true
      }
      if forster_group_list_remove_first_by_handle(outgoing, second_group) {
        had_constraint = true
      }

      if had_constraint {
        outgoing.push(new_group)
        new_group.incoming_constraints_count = new_group.incoming_constraints_count +
          1
      }
    }
  }

  let mut insertion_index = remaining.length()
  for i in 0..<remaining.length() {
    if forster_group_barycenter_value(remaining[i]) > new_barycenter {
      insertion_index = i
      break
    }
  }
  ignore(remaining.insert(insertion_index, new_group))

  node_groups.clear()
  for node_group in remaining {
    node_groups.push(node_group)
  }
}
