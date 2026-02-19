///|
test "DotResourceSetProvider delegates provider calls" {
  let counter = Ref::new(0)
  let provider = new_dot_resource_set_provider(() => {
    counter.val = counter.val + 1
    counter.val
  })

  inspect(provider.create_resource_set(), content="1")
  inspect(provider.create_resource_set(), content="2")
}
