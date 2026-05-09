///|
test "TestController targets algorithm id and installs on whitebox provider" {
  reset_layout_execution_listener_ids_for_test()
  let installed_target : Ref[String?] = Ref(None)
  let provider = new_white_box_testable((controller : TestController[Int]?) => {
    installed_target.val = match controller {
      Some(value) => Some(value.get_target_algorithm_id())
      None => None
    }
  })
  let controller : TestController[Int] = new_test_controller(
    "org.eclipse.elk.test",
  )
  let data = new_layout_algorithm_data("org.eclipse.elk.test")
  assert_true(controller.targets(data))
  controller.install(provider)
  assert_eq(installed_target.val, Some("org.eclipse.elk.test"))
  controller.uninstall()
  assert_eq(installed_target.val, None)
}

///|
test "TestController notifies listeners and keeps Java remove bug semantics" {
  reset_layout_execution_listener_ids_for_test()
  let ready_count : Ref[Int] = Ref(0)
  let listener = new_layout_execution_listener(
    (_processor_id, _graph : Int, _is_root) => {
      ready_count.val = ready_count.val + 1
    },
    (_processor_id, _graph : Int, _is_root) => (),
  )
  let controller : TestController[Int] = new_test_controller(
    "org.eclipse.elk.test",
  )
  controller.add_layout_execution_listener(listener)
  let processor : ILayoutProcessor[Unit, Int] = new_layout_processor((
    _graph : Int,
    _monitor,
  ) => ())
  controller.notify_processor_ready(7, processor)
  assert_eq(ready_count.val, 1)
  controller.remove_layout_execution_listener(listener)
  controller.notify_processor_ready(8, processor)
  assert_eq(ready_count.val, 3)
}
