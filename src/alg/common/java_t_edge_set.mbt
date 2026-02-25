///|
let java_t_edge_set_default_capacity = 16

///|
let java_t_edge_set_load_factor_numerator = 3

///|
let java_t_edge_set_load_factor_denominator = 4

///|
fn java_t_edge_set_bucket_index(edge : TEdge, capacity : Int) -> Int {
  let hash = Int64::from_int(edge.hash_code()) & 4294967295L
  let spread = hash ^ (hash >> 16)
  let mask = Int64::from_int(capacity - 1)
  (spread & mask).to_int()
}

///|
fn java_t_edge_set_new_buckets(capacity : Int) -> Array[Array[TEdge]] {
  Array::makei(capacity, _ => [])
}

///|
pub struct JavaTEdgeSet {
  mut buckets : Array[Array[TEdge]]
  mut size : Int
  mut threshold : Int
}

///|
fn java_t_edge_set_resize(set : JavaTEdgeSet) -> Unit {
  let old_buckets = set.buckets
  let new_capacity = old_buckets.length() * 2
  set.buckets = java_t_edge_set_new_buckets(new_capacity)
  set.size = 0
  set.threshold = (new_capacity * java_t_edge_set_load_factor_numerator) /
  java_t_edge_set_load_factor_denominator
  for bucket in old_buckets {
    for edge in bucket {
      ignore(set.add(edge))
    }
  }
}

///|
pub fn new_java_tedge_set() -> JavaTEdgeSet {
  let capacity = java_t_edge_set_default_capacity
  {
    buckets: java_t_edge_set_new_buckets(capacity),
    size: 0,
    threshold: (capacity * java_t_edge_set_load_factor_numerator) /
    java_t_edge_set_load_factor_denominator,
  }
}

///|
pub fn JavaTEdgeSet::contains(self : JavaTEdgeSet, edge : TEdge) -> Bool {
  let bucket_index = java_t_edge_set_bucket_index(edge, self.buckets.length())
  let bucket = self.buckets[bucket_index]
  for existing in bucket {
    if existing.equals(edge) {
      return true
    }
  }
  false
}

///|
pub fn JavaTEdgeSet::add(self : JavaTEdgeSet, edge : TEdge) -> Bool {
  let bucket_index = java_t_edge_set_bucket_index(edge, self.buckets.length())
  let bucket = self.buckets[bucket_index]
  for existing in bucket {
    if existing.equals(edge) {
      return false
    }
  }
  bucket.push(edge)
  self.buckets[bucket_index] = bucket
  self.size = self.size + 1
  if self.size > self.threshold {
    java_t_edge_set_resize(self)
  }
  true
}

///|
pub fn JavaTEdgeSet::remove(self : JavaTEdgeSet, edge : TEdge) -> Bool {
  let bucket_index = java_t_edge_set_bucket_index(edge, self.buckets.length())
  let bucket = self.buckets[bucket_index]
  for i in 0..<bucket.length() {
    if bucket[i].equals(edge) {
      ignore(bucket.remove(i))
      self.buckets[bucket_index] = bucket
      self.size = self.size - 1
      return true
    }
  }
  false
}

///|
pub fn JavaTEdgeSet::clear(self : JavaTEdgeSet) -> Unit {
  let capacity = self.buckets.length()
  self.buckets = java_t_edge_set_new_buckets(capacity)
  self.size = 0
}

///|
pub fn JavaTEdgeSet::is_empty(self : JavaTEdgeSet) -> Bool {
  self.size == 0
}

///|
pub fn JavaTEdgeSet::to_array(self : JavaTEdgeSet) -> Array[TEdge] {
  let result : Array[TEdge] = []
  for bucket in self.buckets {
    for edge in bucket {
      result.push(edge)
    }
  }
  result
}
