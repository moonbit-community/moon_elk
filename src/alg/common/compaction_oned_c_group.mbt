///|
pub struct CGroup {
  handle : Int
} derive(Eq)

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
  cgroup_store.val[self.handle].id
}

///|
pub fn CGroup::set_id(self : CGroup, id : Int) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].id = id
}

///|
pub fn CGroup::set_master(self : CGroup, master : CNode) -> Unit {
  checked_cgroup(self)
  checked_cnode(master)
  cgroup_store.val[self.handle].master = Some(master)
}

///|
pub fn CGroup::master(self : CGroup) -> CNode? {
  checked_cgroup(self)
  cgroup_store.val[self.handle].master
}

///|
pub fn CGroup::c_nodes(self : CGroup) -> Array[CNode] {
  checked_cgroup(self)
  cgroup_store.val[self.handle].c_nodes
}

///|
pub fn CGroup::add_cnode(self : CGroup, node : CNode) -> Unit {
  checked_cgroup(self)
  checked_cnode(node)

  match node.group() {
    Some(_) => {
      try c_group_raise_unit("CNode belongs to another CGroup.") catch {
        CGroupException(message) =>
          @core.layout_runtime_report_unsupported_configuration(
            "org.eclipse.elk.alg.common.compaction.oned.CGroup: " + message,
          )
      } noraise {
        _ => ()
      }
      return
    }
    None => ()
  }

  cgroup_store.val[self.handle].c_nodes.push(node)
  node.set_group(Some(self))

  match cgroup_store.val[self.handle].reference {
    Some(_) => ()
    None => cgroup_store.val[self.handle].reference = Some(node)
  }
}

///|
pub fn CGroup::remove_cnode(self : CGroup, node : CNode) -> Bool {
  checked_cgroup(self)
  checked_cnode(node)

  let removed = array_remove_first(cgroup_store.val[self.handle].c_nodes, node)
  if removed {
    node.set_group(None)
  }
  removed
}

///|
pub fn CGroup::reference(self : CGroup) -> CNode? {
  checked_cgroup(self)
  cgroup_store.val[self.handle].reference
}

///|
pub fn CGroup::set_reference(self : CGroup, reference : CNode?) -> Unit {
  checked_cgroup(self)
  match reference {
    Some(node) => {
      checked_cnode(node)
      cgroup_store.val[self.handle].reference = Some(node)
    }
    None => cgroup_store.val[self.handle].reference = None
  }
}

///|
pub fn CGroup::start_pos(self : CGroup) -> Double {
  checked_cgroup(self)
  cgroup_store.val[self.handle].start_pos
}

///|
pub fn CGroup::set_start_pos(self : CGroup, start_pos : Double) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].start_pos = start_pos
}

///|
pub fn CGroup::incoming_constraints(self : CGroup) -> Array[CNode] {
  checked_cgroup(self)
  cgroup_store.val[self.handle].incoming_constraints
}

///|
pub fn CGroup::clear_incoming_constraints(self : CGroup) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].incoming_constraints.clear()
}

///|
pub fn CGroup::add_incoming_constraint(self : CGroup, node : CNode) -> Bool {
  checked_cgroup(self)
  checked_cnode(node)
  array_add_unique(cgroup_store.val[self.handle].incoming_constraints, node)
}

///|
pub fn CGroup::out_degree(self : CGroup) -> Int {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree
}

///|
pub fn CGroup::set_out_degree(self : CGroup, out_degree : Int) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree = out_degree
}

///|
pub fn CGroup::out_degree_real(self : CGroup) -> Int {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree_real
}

///|
pub fn CGroup::set_out_degree_real(
  self : CGroup,
  out_degree_real : Int,
) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree_real = out_degree_real
}

///|
pub fn CGroup::delta(self : CGroup) -> Double {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta
}

///|
pub fn CGroup::add_delta(self : CGroup, delta : Double) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta = cgroup_store.val[self.handle].delta +
    delta
}

///|
pub fn CGroup::delta_normalized(self : CGroup) -> Double {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta_normalized
}

///|
pub fn CGroup::add_delta_normalized(self : CGroup, delta : Double) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta_normalized = cgroup_store.val[self.handle].delta_normalized +
    delta
}
