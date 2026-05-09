///|
test "DefaultFactory creates values and exposes IFactory adapter" {
  let created = Ref(0)
  let default_factory = new_default_factory(() => {
    created.val = created.val + 1
    created.val
  })

  let first = default_factory.create()
  let second = default_factory.create()
  default_factory.destroy(first)
  default_factory.destroy(second)

  let adapter = default_factory.as_factory()
  let third = adapter.create()
  adapter.destroy(third)

  inspect(first.to_string(), content="1")
  inspect(second.to_string(), content="2")
  inspect(third.to_string(), content="3")
}

///|
test "AlgorithmFactory forwards initialize parameter and dispose" {
  let initialized = Ref("")
  let disposed = Ref(false)

  let algorithm_factory = new_algorithm_factory(
    () => {
      new_abstract_layout_provider(
        (_, _) => (),
        initialize_fn=parameter => {
          if parameter is Some(value) {
            initialized.val = value
          } else {
            initialized.val = ""
          }
        },
        dispose_fn=() => disposed.val = true,
      )
    },
    parameter=Some("layered"),
  )

  let provider = algorithm_factory.create()
  inspect(initialized.val, content="layered")

  algorithm_factory.destroy(provider)
  inspect(disposed.val, content="true")
}

///|
test "AlgorithmFactory defaults to None parameter" {
  let initialized_with_none = Ref(false)
  let algorithm_factory = new_algorithm_factory(() => {
    new_abstract_layout_provider((_, _) => (), initialize_fn=parameter => {
      if parameter is None {
        initialized_with_none.val = true
      }
    })
  })

  ignore(algorithm_factory.create())
  inspect(initialized_with_none.val, content="true")
}
