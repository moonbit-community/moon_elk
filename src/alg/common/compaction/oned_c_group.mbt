///|
pub struct CGroup {
  handle : Int
  priv data : CGroupData
}

///|
pub impl Eq for CGroup with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub suberror CGroupException {
  CGroupException(String)
} derive(Debug, ToJson)

///|
fn c_group_raise_unit(message : String) -> Unit raise CGroupException {
  raise CGroupException(message)
}

///|
pub fn CGroup::id(self : CGroup) -> Int {
  checked_cgroup(self)
  self.data.id
}

///|
pub fn CGroup::set_id(self : CGroup, id : Int) -> Unit {
  checked_cgroup(self)
  self.data.id = id
}

///|
pub fn CGroup::set_master(self : CGroup, master : CNode) -> Unit {
  checked_cgroup(self)
  checked_cnode(master)
  self.data.master = Some(master)
}

///|
pub fn CGroup::master(self : CGroup) -> CNode? {
  checked_cgroup(self)
  self.data.master
}

///|
pub fn CGroup::c_nodes(self : CGroup) -> Array[CNode] {
  checked_cgroup(self)
  self.data.c_nodes
}

///|
pub fn CGroup::add_cnode(self : CGroup, node : CNode) -> Unit raise {
  checked_cgroup(self)
  checked_cnode(node)

  match node.group() {
    Some(_) => {
      try c_group_raise_unit("CNode belongs to another CGroup.") catch {
        CGroupException(message) =>
          @core.layout_runtime_raise_unsupported_configuration(
            "org.eclipse.elk.alg.common.compaction.oned.CGroup: " + message,
          )
      } noraise {
        _ => ()
      }
      return
    }
    None => ()
  }

  self.data.c_nodes.push(node)
  node.set_group(Some(self))

  match self.data.reference {
    Some(_) => ()
    None => self.data.reference = Some(node)
  }
}

///|
pub fn CGroup::remove_cnode(self : CGroup, node : CNode) -> Bool {
  checked_cgroup(self)
  checked_cnode(node)

  let removed = array_remove_first(self.data.c_nodes, node)
  if removed {
    node.set_group(None)
  }
  removed
}

///|
pub fn CGroup::reference(self : CGroup) -> CNode? {
  checked_cgroup(self)
  self.data.reference
}

///|
pub fn CGroup::set_reference(self : CGroup, reference : CNode?) -> Unit {
  checked_cgroup(self)
  match reference {
    Some(node) => {
      checked_cnode(node)
      self.data.reference = Some(node)
    }
    None => self.data.reference = None
  }
}

///|
pub fn CGroup::start_pos(self : CGroup) -> Double {
  checked_cgroup(self)
  self.data.start_pos
}

///|
pub fn CGroup::set_start_pos(self : CGroup, start_pos : Double) -> Unit {
  checked_cgroup(self)
  self.data.start_pos = start_pos
}

///|
pub fn CGroup::incoming_constraints(self : CGroup) -> Array[CNode] {
  checked_cgroup(self)
  self.data.incoming_constraints
}

///|
pub fn CGroup::clear_incoming_constraints(self : CGroup) -> Unit {
  checked_cgroup(self)
  self.data.incoming_constraints.clear()
}

///|
pub fn CGroup::add_incoming_constraint(self : CGroup, node : CNode) -> Bool {
  checked_cgroup(self)
  checked_cnode(node)
  array_add_unique(self.data.incoming_constraints, node)
}

///|
pub fn CGroup::out_degree(self : CGroup) -> Int {
  checked_cgroup(self)
  self.data.out_degree
}

///|
pub fn CGroup::set_out_degree(self : CGroup, out_degree : Int) -> Unit {
  checked_cgroup(self)
  self.data.out_degree = out_degree
}

///|
pub fn CGroup::out_degree_real(self : CGroup) -> Int {
  checked_cgroup(self)
  self.data.out_degree_real
}

///|
pub fn CGroup::set_out_degree_real(
  self : CGroup,
  out_degree_real : Int,
) -> Unit {
  checked_cgroup(self)
  self.data.out_degree_real = out_degree_real
}

///|
pub fn CGroup::delta(self : CGroup) -> Double {
  checked_cgroup(self)
  self.data.delta
}

///|
pub fn CGroup::add_delta(self : CGroup, delta : Double) -> Unit {
  checked_cgroup(self)
  self.data.delta = self.data.delta + delta
}

///|
pub fn CGroup::delta_normalized(self : CGroup) -> Double {
  checked_cgroup(self)
  self.data.delta_normalized
}

///|
pub fn CGroup::add_delta_normalized(self : CGroup, delta : Double) -> Unit {
  checked_cgroup(self)
  self.data.delta_normalized = self.data.delta_normalized + delta
}
