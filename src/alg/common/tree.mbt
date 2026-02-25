///|
pub struct Tree[T] {
  uid : Int
  node : T
  children : Array[Tree[T]]
}

///|
let tree_uid_counter : Ref[Int] = Ref::new(0)

///|
fn next_tree_uid() -> Int {
  let uid = tree_uid_counter.val
  tree_uid_counter.val = uid + 1
  uid
}

///|
pub fn[T] new_tree(node : T) -> Tree[T] {
  { uid: next_tree_uid(), node, children: [] }
}
