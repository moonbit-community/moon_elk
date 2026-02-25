///|
let java_t_triangle_set_default_capacity = 16

///|
let java_t_triangle_set_load_factor_numerator = 3

///|
let java_t_triangle_set_load_factor_denominator = 4

///|
fn java_t_triangle_set_bucket_index(triangle : TTriangle, capacity : Int) -> Int {
  let hash = Int64::from_int(triangle.hash_code()) & 4294967295L
  let spread = hash ^ (hash >> 16)
  let mask = Int64::from_int(capacity - 1)
  (spread & mask).to_int()
}

///|
fn java_t_triangle_set_new_buckets(capacity : Int) -> Array[Array[TTriangle]] {
  Array::makei(capacity, _ => [])
}

///|
pub struct JavaTTriangleSet {
  mut buckets : Array[Array[TTriangle]]
  mut size : Int
  mut threshold : Int
}

///|
fn java_t_triangle_set_resize(set : JavaTTriangleSet) -> Unit {
  let old_buckets = set.buckets
  let new_capacity = old_buckets.length() * 2
  set.buckets = java_t_triangle_set_new_buckets(new_capacity)
  set.size = 0
  set.threshold = (new_capacity * java_t_triangle_set_load_factor_numerator) /
  java_t_triangle_set_load_factor_denominator
  for bucket in old_buckets {
    for triangle in bucket {
      ignore(set.add(triangle))
    }
  }
}

///|
pub fn new_java_ttriangle_set() -> JavaTTriangleSet {
  let capacity = java_t_triangle_set_default_capacity
  {
    buckets: java_t_triangle_set_new_buckets(capacity),
    size: 0,
    threshold: (capacity * java_t_triangle_set_load_factor_numerator) /
    java_t_triangle_set_load_factor_denominator,
  }
}

///|
pub fn JavaTTriangleSet::add(self : JavaTTriangleSet, triangle : TTriangle) -> Bool {
  let bucket_index = java_t_triangle_set_bucket_index(
    triangle,
    self.buckets.length(),
  )
  let bucket = self.buckets[bucket_index]
  for existing in bucket {
    if existing.equals(triangle) {
      return false
    }
  }
  bucket.push(triangle)
  self.buckets[bucket_index] = bucket
  self.size = self.size + 1
  if self.size > self.threshold {
    java_t_triangle_set_resize(self)
  }
  true
}

///|
pub fn JavaTTriangleSet::remove(
  self : JavaTTriangleSet,
  triangle : TTriangle,
) -> Bool {
  let bucket_index = java_t_triangle_set_bucket_index(
    triangle,
    self.buckets.length(),
  )
  let bucket = self.buckets[bucket_index]
  for i in 0..<bucket.length() {
    if bucket[i].equals(triangle) {
      ignore(bucket.remove(i))
      self.buckets[bucket_index] = bucket
      self.size = self.size - 1
      return true
    }
  }
  false
}

///|
pub fn JavaTTriangleSet::to_array(self : JavaTTriangleSet) -> Array[TTriangle] {
  let result : Array[TTriangle] = []
  for bucket in self.buckets {
    for triangle in bucket {
      result.push(triangle)
    }
  }
  result
}
