///|
pub(all) enum SplineSideToProcess {
  Left
  Right
}

///|
pub fn spline_side_to_process_values() -> Array[SplineSideToProcess] {
  [Left, Right]
}

///|
pub fn spline_side_to_process_to_string(side : SplineSideToProcess) -> String {
  match side {
    Left => "LEFT"
    Right => "RIGHT"
  }
}

///|
pub(all) struct SplineDependency {
  mut source : SplineSegment?
  mut target : SplineSegment?
  weight : Int
}

///|
pub fn new_spline_dependency(
  source : SplineSegment,
  target : SplineSegment,
  weight : Int,
) -> SplineDependency {
  let dependency = { source: Some(source), target: Some(target), weight }
  source.outgoing.push(dependency)
  target.incoming.push(dependency)
  dependency
}

///|
pub fn SplineDependency::to_string(self : SplineDependency) -> String {
  let source_mark = match self.source {
    Some(segment) => segment.mark.to_string()
    None => "null"
  }
  let target_mark = match self.target {
    Some(segment) => segment.mark.to_string()
    None => "null"
  }
  source_mark + " ->(" + self.weight.to_string() + ") " + target_mark
}
