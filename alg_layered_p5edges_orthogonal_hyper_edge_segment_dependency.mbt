///|
let hyper_edge_segment_dependency_next_handle_ref : Ref[Int] = Ref::new(0)

///|
fn hyper_edge_segment_dependency_next_handle() -> Int {
  let handle = hyper_edge_segment_dependency_next_handle_ref.val
  hyper_edge_segment_dependency_next_handle_ref.val = handle + 1
  handle
}

///|
fn hyper_edge_segment_dependency_internal_handle(
  dependency : HyperEdgeSegmentDependency,
) -> Int {
  dependency.dependency_handle
}

///|
fn hyper_edge_segment_dependency_add_outgoing(
  source : HyperEdgeSegment,
  dependency : HyperEdgeSegmentDependency,
) -> Unit {
  let outgoing = source.get_outgoing_segment_dependencies()
  for existing in outgoing {
    if hyper_edge_segment_dependency_internal_handle(existing) ==
      hyper_edge_segment_dependency_internal_handle(dependency) {
      return
    }
  }
  outgoing.push(dependency)
}

///|
fn hyper_edge_segment_dependency_add_incoming(
  target : HyperEdgeSegment,
  dependency : HyperEdgeSegmentDependency,
) -> Unit {
  let incoming = target.get_incoming_segment_dependencies()
  for existing in incoming {
    if hyper_edge_segment_dependency_internal_handle(existing) ==
      hyper_edge_segment_dependency_internal_handle(dependency) {
      return
    }
  }
  incoming.push(dependency)
}

///|
fn hyper_edge_segment_dependency_remove_outgoing(
  source : HyperEdgeSegment,
  dependency : HyperEdgeSegmentDependency,
) -> Unit {
  let outgoing = source.get_outgoing_segment_dependencies()
  for i in 0..<outgoing.length() {
    if hyper_edge_segment_dependency_internal_handle(outgoing[i]) ==
      hyper_edge_segment_dependency_internal_handle(dependency) {
      ignore(outgoing.remove(i))
      return
    }
  }
}

///|
fn hyper_edge_segment_dependency_remove_incoming(
  target : HyperEdgeSegment,
  dependency : HyperEdgeSegmentDependency,
) -> Unit {
  let incoming = target.get_incoming_segment_dependencies()
  for i in 0..<incoming.length() {
    if hyper_edge_segment_dependency_internal_handle(incoming[i]) ==
      hyper_edge_segment_dependency_internal_handle(dependency) {
      ignore(incoming.remove(i))
      return
    }
  }
}

///|
pub enum DependencyType {
  Regular
  Critical
}

///|
pub let critical_dependency_weight : Int = 1

///|
fn dependency_type_to_string(dependency_type : DependencyType) -> String {
  match dependency_type {
    Regular => "REGULAR"
    Critical => "CRITICAL"
  }
}

///|
pub struct HyperEdgeSegmentDependency {
  dependency_handle : Int
  dependency_type : DependencyType
  mut source : HyperEdgeSegment?
  mut target : HyperEdgeSegment?
  weight : Int
}

///|
fn new_hyper_edge_segment_dependency(
  dependency_type : DependencyType,
  source : HyperEdgeSegment?,
  target : HyperEdgeSegment?,
  weight : Int,
) -> HyperEdgeSegmentDependency {
  let dependency = {
    dependency_handle: hyper_edge_segment_dependency_next_handle(),
    dependency_type,
    source: None,
    target: None,
    weight,
  }
  dependency.set_source(source)
  dependency.set_target(target)
  dependency
}

///|
pub fn hyper_edge_segment_dependency_create_and_add_regular(
  source : HyperEdgeSegment,
  target : HyperEdgeSegment,
  weight : Int,
) -> HyperEdgeSegmentDependency {
  new_hyper_edge_segment_dependency(
    DependencyType::Regular,
    Some(source),
    Some(target),
    weight,
  )
}

///|
pub fn hyper_edge_segment_dependency_create_and_add_critical(
  source : HyperEdgeSegment,
  target : HyperEdgeSegment,
) -> HyperEdgeSegmentDependency {
  new_hyper_edge_segment_dependency(
    DependencyType::Critical,
    Some(source),
    Some(target),
    critical_dependency_weight,
  )
}

///|
pub fn HyperEdgeSegmentDependency::remove(
  self : HyperEdgeSegmentDependency,
) -> Unit {
  self.set_source(None)
  self.set_target(None)
}

///|
pub fn HyperEdgeSegmentDependency::reverse(
  self : HyperEdgeSegmentDependency,
) -> Unit {
  let old_source = self.source
  let old_target = self.target
  self.set_source(old_target)
  self.set_target(old_source)
}

///|
pub fn HyperEdgeSegmentDependency::get_type(
  self : HyperEdgeSegmentDependency,
) -> DependencyType {
  self.dependency_type
}

///|
pub fn HyperEdgeSegmentDependency::get_source(
  self : HyperEdgeSegmentDependency,
) -> HyperEdgeSegment? {
  self.source
}

///|
pub fn HyperEdgeSegmentDependency::set_source(
  self : HyperEdgeSegmentDependency,
  new_source : HyperEdgeSegment?,
) -> Unit {
  match self.source {
    Some(old_source) =>
      hyper_edge_segment_dependency_remove_outgoing(old_source, self)
    None => ()
  }

  self.source = new_source

  match self.source {
    Some(source) => hyper_edge_segment_dependency_add_outgoing(source, self)
    None => ()
  }
}

///|
pub fn HyperEdgeSegmentDependency::get_target(
  self : HyperEdgeSegmentDependency,
) -> HyperEdgeSegment? {
  self.target
}

///|
pub fn HyperEdgeSegmentDependency::set_target(
  self : HyperEdgeSegmentDependency,
  new_target : HyperEdgeSegment?,
) -> Unit {
  match self.target {
    Some(old_target) =>
      hyper_edge_segment_dependency_remove_incoming(old_target, self)
    None => ()
  }

  self.target = new_target

  match self.target {
    Some(target) => hyper_edge_segment_dependency_add_incoming(target, self)
    None => ()
  }
}

///|
pub fn HyperEdgeSegmentDependency::get_weight(
  self : HyperEdgeSegmentDependency,
) -> Int {
  self.weight
}

///|
pub fn HyperEdgeSegmentDependency::to_string(
  self : HyperEdgeSegmentDependency,
) -> String {
  let source = match self.source {
    Some(source_segment) => source_segment.to_string()
    None => "null"
  }
  let target = match self.target {
    Some(target_segment) => target_segment.to_string()
    None => "null"
  }
  source +
  "->" +
  target +
  " (" +
  dependency_type_to_string(self.dependency_type) +
  ")"
}
