///|
pub let instance_pool_infinite = -1

///|
pub struct InstancePool[T] {
  factory : IFactory[T]
  instances : Array[T]
  limit : Int
}

///|
pub fn[T] new_instance_pool(
  factory : IFactory[T],
  limit? : Int = instance_pool_infinite,
) -> InstancePool[T] {
  { factory, instances: [], limit }
}

///|
pub fn[T] InstancePool::fetch(self : InstancePool[T]) -> T {
  if self.instances.is_empty() {
    self.factory.create()
  } else {
    let first = self.instances[0]
    ignore(self.instances.remove(0))
    first
  }
}

///|
pub fn[T] InstancePool::release(self : InstancePool[T], obj : T) -> Unit {
  if self.limit < 0 || self.instances.length() < self.limit {
    self.instances.push(obj)
  } else {
    self.factory.destroy(obj)
  }
}

///|
pub fn[T] InstancePool::clear(self : InstancePool[T]) -> Unit {
  for obj in self.instances {
    self.factory.destroy(obj)
  }
  self.instances.clear()
}
