///|
fn capture_layout_error(action : () -> Unit raise) -> String? {
  let session = new_layout_session()
  try action() catch {
    error => session.record_error(error)
  } noraise {
    _ => ()
  }
  session.take_error_message()
}
