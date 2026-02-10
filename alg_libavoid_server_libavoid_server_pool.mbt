///|
pub struct LibavoidServerPool {
  servers : Array[LibavoidServer]
}

///|
let libavoid_server_pool_instance_ref : Ref[LibavoidServerPool?] = Ref::new(
  None,
)

///|
pub fn new_libavoid_server_pool() -> LibavoidServerPool {
  { servers: [] }
}

///|
pub fn libavoid_server_pool_instance() -> LibavoidServerPool {
  match libavoid_server_pool_instance_ref.val {
    Some(pool) => pool
    None => {
      let pool = new_libavoid_server_pool()
      libavoid_server_pool_instance_ref.val = Some(pool)
      pool
    }
  }
}

///|
pub fn LibavoidServerPool::fetch(self : LibavoidServerPool) -> LibavoidServer {
  if self.servers.is_empty() {
    new_libavoid_server()
  } else {
    self.servers.remove(0)
  }
}

///|
pub fn LibavoidServerPool::release(
  self : LibavoidServerPool,
  server : LibavoidServer,
) -> Unit {
  self.servers.push(server)
}

///|
pub fn LibavoidServerPool::dispose(self : LibavoidServerPool) -> Unit {
  for server in self.servers {
    server.cleanup(libavoid_server_cleanup_stop())
  }
  self.servers.clear()
}

///|
pub fn LibavoidServerPool::size(self : LibavoidServerPool) -> Int {
  self.servers.length()
}

///|
pub fn libavoid_server_pool_reset_for_test() -> Unit {
  libavoid_server_pool_instance_ref.val = None
}
