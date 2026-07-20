///|
pub fn layered_test_update_containment(edge : @graph.ElkEdge?) -> Unit {
  try @graph.update_containment(edge) catch {
    err => abort(err.to_string())
  } noraise {
    _ => ()
  }
}
