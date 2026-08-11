///|
pub(all) struct AlgorithmFactory {
  session : LayoutSession
  create_algorithm_fn : () -> AbstractLayoutProvider
  parameter : String?
}

///|
pub fn new_algorithm_factory(
  session : LayoutSession,
  create_algorithm_fn : () -> AbstractLayoutProvider,
  parameter? : String? = None,
) -> AlgorithmFactory {
  { session, create_algorithm_fn, parameter }
}

///|
pub fn AlgorithmFactory::create(
  self : AlgorithmFactory,
) -> AbstractLayoutProvider {
  let algorithm = (self.create_algorithm_fn)()
  try algorithm.initialize(self.parameter) catch {
    error => self.session.record_error(error)
  } noraise {
    _ => ()
  }
  algorithm
}

///|
pub fn AlgorithmFactory::destroy(
  self : AlgorithmFactory,
  obj : AbstractLayoutProvider,
) -> Unit {
  ignore(self)
  try obj.dispose() catch {
    error => self.session.record_error(error)
  } noraise {
    _ => ()
  }
}

///|
pub fn AlgorithmFactory::as_factory(
  self : AlgorithmFactory,
) -> IFactory[AbstractLayoutProvider] {
  new_factory(() => self.create(), destroy_fn=obj => self.destroy(obj))
}
