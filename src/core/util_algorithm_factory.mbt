///|
pub(all) struct AlgorithmFactory {
  create_algorithm_fn : () -> AbstractLayoutProvider
  parameter : String?
}

///|
pub fn new_algorithm_factory(
  create_algorithm_fn : () -> AbstractLayoutProvider,
  parameter? : String? = None,
) -> AlgorithmFactory {
  { create_algorithm_fn, parameter }
}

///|
pub fn AlgorithmFactory::create(
  self : AlgorithmFactory,
) -> AbstractLayoutProvider {
  let algorithm = (self.create_algorithm_fn)()
  algorithm.initialize(self.parameter)
  algorithm
}

///|
pub fn AlgorithmFactory::destroy(
  self : AlgorithmFactory,
  obj : AbstractLayoutProvider,
) -> Unit {
  ignore(self)
  obj.dispose()
}

///|
pub fn AlgorithmFactory::as_factory(
  self : AlgorithmFactory,
) -> IFactory[AbstractLayoutProvider] {
  new_factory(() => self.create(), destroy_fn=obj => self.destroy(obj))
}
