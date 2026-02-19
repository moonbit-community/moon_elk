///|
struct ComponentsCompactionComponentOffset {
  component_id : Int
  old_position : @core.KVector
  offset_node : @common.CNode
}

///|
struct ComponentsCompactionExternalExtensionEntry[E] {
  extension : IExternalExtension[E]
  group : @common.CGroup
  node : @common.CNode
}

///|
struct ComponentsCompactionPlaceholderEntry {
  direction : @core.Direction
  parent_group : @common.CGroup
  node : @common.CNode
}

///|
struct ComponentsCompactionNodeInfo {
  node : @common.CNode
  mut rect : @core.ElkRectangle
  mut individual_spacing : Double?
  lock : LayeredQuadruplet
}

///|
pub struct ComponentsToCGraphTransformer[N, E] {
  mut c_graph : @common.CGraph
  spacing : Double
  component_offsets : Array[ComponentsCompactionComponentOffset]
  external_extensions : Array[ComponentsCompactionExternalExtensionEntry[E]]
  external_placeholders : Array[ComponentsCompactionPlaceholderEntry]
  node_infos : Array[ComponentsCompactionNodeInfo]
  mut global_offset : @core.KVector
  mut graph_size : @core.KVector
  _phantom : N?
}

///|
fn components_compaction_double_min(left : Double, right : Double) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn components_compaction_double_max(left : Double, right : Double) -> Double {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn[T : Eq] components_compaction_transformer_array_remove_first(
  array : Array[T],
  value : T,
) -> Bool {
  for i in 0..<array.length() {
    if array[i] == value {
      ignore(array.remove(i))
      return true
    }
  }
  false
}

///|
fn components_compaction_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  @core.port_side_to_string(left) == @core.port_side_to_string(right)
}

///|
fn components_compaction_port_side_contains(
  sides : Array[@core.PortSide],
  side : @core.PortSide,
) -> Bool {
  for candidate in sides {
    if components_compaction_port_side_equals(candidate, side) {
      return true
    }
  }
  false
}

///|
fn components_compaction_port_side_set_equals(
  left : Array[@core.PortSide],
  right : Array[@core.PortSide],
) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for side in left {
    if !components_compaction_port_side_contains(right, side) {
      return false
    }
  }
  true
}

///|
fn components_compaction_find_node_info(
  infos : Array[ComponentsCompactionNodeInfo],
  node : @common.CNode,
) -> ComponentsCompactionNodeInfo? {
  for info in infos {
    if info.node == node {
      return Some(info)
    }
  }
  None
}

///|
fn[N, E] components_compaction_node_spacing(
  transformer : ComponentsToCGraphTransformer[N, E],
  node : @common.CNode,
) -> Double {
  match components_compaction_find_node_info(transformer.node_infos, node) {
    Some(info) =>
      match info.individual_spacing {
        Some(value) => value
        None => transformer.spacing
      }
    None => transformer.spacing
  }
}

///|
fn[N, E] components_compaction_set_lock(
  transformer : ComponentsToCGraphTransformer[N, E],
  node : @common.CNode,
  port_sides : Array[@core.PortSide],
) -> Unit {
  let lock = new_layered_quadruplet()
  lock.set_values(false, false, false, false)

  if port_sides.length() == 0 {
    lock.set_values(true, true, true, true)
  }

  if components_compaction_port_side_set_equals(port_sides, @core.sides_north) {
    lock.set_values(true, true, true, false)
  }
  if components_compaction_port_side_set_equals(port_sides, @core.sides_east) {
    lock.set_values(false, true, true, true)
  }
  if components_compaction_port_side_set_equals(port_sides, @core.sides_south) {
    lock.set_values(true, true, false, true)
  }
  if components_compaction_port_side_set_equals(port_sides, @core.sides_west) {
    lock.set_values(true, false, true, true)
  }

  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_north_east,
    ) {
    lock.set_values(false, true, true, false)
  }
  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_east_south,
    ) {
    lock.set_values(false, true, false, true)
  }
  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_south_west,
    ) {
    lock.set_values(true, false, false, true)
  }
  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_north_west,
    ) {
    lock.set_values(true, false, true, false)
  }

  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_north_south,
    ) {
    lock.set_values(true, true, true, true)
  }
  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_east_west,
    ) {
    lock.set_values(true, true, true, true)
  }

  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_north_south,
    ) {
    lock.set_values(true, true, true, true)
  }
  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_east_south_west,
    ) {
    lock.set_values(true, true, true, true)
  }
  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_north_south_west,
    ) {
    lock.set_values(true, true, true, true)
  }
  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_north_east_west,
    ) {
    lock.set_values(true, true, true, true)
  }

  if components_compaction_port_side_set_equals(
      port_sides, @core.sides_north_east_south_west,
    ) {
    lock.set_values(true, true, true, true)
  }

  transformer.node_infos.push({
    node,
    rect: node.hitbox(),
    individual_spacing: None,
    lock,
  })
}

///|
fn[N, E] components_compaction_assign_spacing(
  transformer : ComponentsToCGraphTransformer[N, E],
  node : @common.CNode,
  spacing : Double?,
) -> Unit {
  for i in 0..<transformer.node_infos.length() {
    if transformer.node_infos[i].node == node {
      transformer.node_infos[i].individual_spacing = spacing
      return
    }
  }
}

///|
fn[N, E] components_compaction_create_rect_node(
  transformer : ComponentsToCGraphTransformer[N, E],
  rect : @core.ElkRectangle,
  in_graph : Bool,
) -> @common.CNode {
  let node = @common.cnode_of()
    .hitbox(@core.new_elk_rectangle_copy(rect))
    .create(transformer.c_graph)
  if !in_graph {
    ignore(
      components_compaction_transformer_array_remove_first(
        transformer.c_graph.c_nodes,
        node,
      ),
    )
  }
  node
}

///|
fn[N, E] components_compaction_add_placeholder_group(
  transformer : ComponentsToCGraphTransformer[N, E],
  placeholder : @common.CNode,
) -> Unit {
  let dummy_group = @common.cgroup_of()
    .nodes([placeholder])
    .create(transformer.c_graph)
  ignore(
    components_compaction_transformer_array_remove_first(
      transformer.c_graph.c_groups,
      dummy_group,
    ),
  )
}

///|
pub fn[N, E] new_components_to_cgraph_transformer(
  spacing : Double,
) -> ComponentsToCGraphTransformer[N, E] {
  {
    c_graph: @common.new_cgraph(@core.direction_values()),
    spacing,
    component_offsets: [],
    external_extensions: [],
    external_placeholders: [],
    node_infos: [],
    global_offset: @core.new_kvector(),
    graph_size: @core.new_kvector(),
    _phantom: None,
  }
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::transform(
  self : ComponentsToCGraphTransformer[N, E],
  ccs : IConnectedComponents[N, E],
) -> @common.CGraph {
  self.c_graph = @common.new_cgraph(@core.direction_values())
  self.component_offsets.clear()
  self.external_extensions.clear()
  self.external_placeholders.clear()
  self.node_infos.clear()
  self.global_offset = @core.new_kvector()
  self.graph_size = @core.new_kvector()

  for component in ccs.get_components() {
    let group = @common.cgroup_of().create(self.c_graph)
    let sides = component.get_external_extension_sides()
    let hull = component.get_hull()

    let mut first_rect_node : @common.CNode? = None
    let mut first_old_position = @core.new_kvector()

    for rect in hull {
      let rect_node = components_compaction_create_rect_node(self, rect, true)
      components_compaction_set_lock(self, rect_node, sides)
      for i in 0..<self.node_infos.length() {
        if self.node_infos[i].node == rect_node {
          self.node_infos[i].rect = rect
          break
        }
      }

      if first_rect_node is None {
        first_rect_node = Some(rect_node)
        first_old_position = @core.new_kvector_xy(rect.x, rect.y)
      }

      group.add_cnode(rect_node)
    }

    match first_rect_node {
      Some(offset_node) =>
        self.component_offsets.push({
          component_id: component._instance_id,
          old_position: first_old_position,
          offset_node,
        })
      None => ()
    }

    for external_extension in component.get_external_extensions() {
      let representor = external_extension.get_representor()
      let representor_node = components_compaction_create_rect_node(
        self, representor, false,
      )
      components_compaction_set_lock(self, representor_node, sides)
      for i in 0..<self.node_infos.length() {
        if self.node_infos[i].node == representor_node {
          self.node_infos[i].rect = representor
          break
        }
      }

      self.external_extensions.push({
        extension: external_extension,
        group,
        node: representor_node,
      })

      match external_extension.get_placeholder() {
        Some(placeholder_rect) => {
          let placeholder_node = components_compaction_create_rect_node(
            self, placeholder_rect, false,
          )
          components_compaction_set_lock(self, placeholder_node, sides)
          components_compaction_assign_spacing(
            self,
            placeholder_node,
            Some(1.0),
          )
          for i in 0..<self.node_infos.length() {
            if self.node_infos[i].node == placeholder_node {
              self.node_infos[i].rect = placeholder_rect
              break
            }
          }
          components_compaction_add_placeholder_group(self, placeholder_node)
          self.external_placeholders.push({
            direction: external_extension.get_direction(),
            parent_group: group,
            node: placeholder_node,
          })
        }
        None => ()
      }
    }
  }

  self.c_graph
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::get_offset(
  self : ComponentsToCGraphTransformer[N, E],
  component : IComponent[N, E],
) -> @core.KVector {
  for entry in self.component_offsets {
    if entry.component_id == component._instance_id {
      return entry.old_position
        .clone()
        .sub(entry.offset_node.hitbox().get_position())
    }
  }
  @core.new_kvector()
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::get_global_offset(
  self : ComponentsToCGraphTransformer[N, E],
) -> @core.KVector {
  self.global_offset
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::get_graph_size(
  self : ComponentsToCGraphTransformer[N, E],
) -> @core.KVector {
  self.graph_size
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::get_external_extensions(
  self : ComponentsToCGraphTransformer[N, E],
) -> Array[(IExternalExtension[E], (@common.CGroup, @common.CNode))] {
  let entries : Array[(IExternalExtension[E], (@common.CGroup, @common.CNode))] = []
  for entry in self.external_extensions {
    entries.push((entry.extension, (entry.group, entry.node)))
  }
  entries
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::get_external_placeholders(
  self : ComponentsToCGraphTransformer[N, E],
) -> Array[(@core.Direction, (@common.CGroup, @common.CNode))] {
  let entries : Array[(@core.Direction, (@common.CGroup, @common.CNode))] = []
  for entry in self.external_placeholders {
    entries.push((entry.direction, (entry.parent_group, entry.node)))
  }
  entries
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::is_locked(
  self : ComponentsToCGraphTransformer[N, E],
  node : @common.CNode,
  direction : @core.Direction,
) -> Bool {
  match components_compaction_find_node_info(self.node_infos, node) {
    Some(info) => info.lock.get(direction)
    None => false
  }
}

///|
pub fn[N, E] components_to_cgraph_spacing_handler(
  transformer : ComponentsToCGraphTransformer[N, E],
) -> @common.ISpacingsHandler {
  @common.new_spacings_handler(
    (node1, node2) => {
      let spacing1 = components_compaction_node_spacing(transformer, node1)
      let spacing2 = components_compaction_node_spacing(transformer, node2)
      if spacing1 < spacing2 {
        spacing1
      } else {
        spacing2
      }
    },
    (node1, node2) => {
      let spacing1 = components_compaction_node_spacing(transformer, node1)
      let spacing2 = components_compaction_node_spacing(transformer, node2)
      if spacing1 < spacing2 {
        spacing1
      } else {
        spacing2
      }
    },
  )
}

///|
pub fn[N, E] ComponentsToCGraphTransformer::apply_layout(
  self : ComponentsToCGraphTransformer[N, E],
) -> Unit {
  for node_info in self.node_infos {
    let hitbox = node_info.node.hitbox()
    node_info.rect.x = hitbox.x
    node_info.rect.y = hitbox.y
  }

  let top_left = @core.new_kvector_xy(@double.infinity, @double.infinity)
  let bottom_right = @core.new_kvector_xy(-@double.infinity, -@double.infinity)

  for node in self.c_graph.c_nodes {
    let hitbox = node.hitbox()
    top_left.x = components_compaction_double_min(top_left.x, hitbox.x)
    top_left.y = components_compaction_double_min(top_left.y, hitbox.y)
    bottom_right.x = components_compaction_double_max(
      bottom_right.x,
      hitbox.x + hitbox.width,
    )
    bottom_right.y = components_compaction_double_max(
      bottom_right.y,
      hitbox.y + hitbox.height,
    )
  }

  for placeholder in self.external_placeholders {
    let hitbox = placeholder.node.hitbox()
    top_left.x = components_compaction_double_min(top_left.x, hitbox.x)
    top_left.y = components_compaction_double_min(top_left.y, hitbox.y)
    bottom_right.x = components_compaction_double_max(
      bottom_right.x,
      hitbox.x + hitbox.width,
    )
    bottom_right.y = components_compaction_double_max(
      bottom_right.y,
      hitbox.y + hitbox.height,
    )
  }

  if top_left.x == @double.infinity || top_left.y == @double.infinity {
    self.global_offset = @core.new_kvector()
    self.graph_size = @core.new_kvector()
  } else {
    self.global_offset = top_left.clone().negate()
    self.graph_size = bottom_right.clone().sub(top_left)
  }

  self.c_graph.c_groups.clear()
  self.c_graph.c_nodes.clear()
}
