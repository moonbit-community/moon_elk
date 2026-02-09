///|
test "NullElkProgressMonitor behaves as no-op monitor" {
  let monitor = new_null_elk_progress_monitor()
  inspect(monitor.begin("ignored", 1.0), content="false")
  inspect(monitor.is_running(), content="false")
  inspect(monitor.get_task_name(), content="")
  inspect(
    match monitor.sub_task(1.0) {
      Some(_) => true
      None => false
    },
    content="true",
  )
  monitor.log("x")
  monitor.log_graph("g")
  inspect(monitor.get_logs().length(), content="0")
  inspect(monitor.get_logged_graphs().length(), content="0")
}

///|
test "Regular progress monitor keeps existing behavior" {
  let monitor = new_elk_progress_monitor()
  inspect(monitor.begin("task", 1.0), content="true")
  inspect(monitor.is_running(), content="true")
  monitor.log("first")
  inspect(monitor.get_logs().length(), content="1")
  monitor.done()
  inspect(monitor.is_running(), content="false")
}
