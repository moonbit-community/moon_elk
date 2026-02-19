///|
pub struct Tree[T] {
  node : T
  children : Array[Tree[T]]
}

///|
pub fn[T] new_tree(node : T) -> Tree[T] {
  { node, children: [] }
}
