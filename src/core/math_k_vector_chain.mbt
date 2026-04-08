///|
priv suberror KVectorChainException {
  KVectorChainException(String)
} derive(Debug, ToJson)

///|
fn[T] kvector_chain_raise(message : String) -> T raise KVectorChainException {
  raise KVectorChainException(message)
}

///|
fn kvector_chain_raise_unit(
  message : String,
) -> Unit raise KVectorChainException {
  kvector_chain_raise(message)
}

///|
fn kvector_chain_exception_message(err : KVectorChainException) -> String {
  match err {
    KVectorChainException(message) => message
  }
}

///|
pub(all) struct KVectorChain {
  vectors : Array[KVector]
}

///|
pub fn new_kvector_chain() -> KVectorChain {
  { vectors: [] }
}

///|
pub fn new_kvector_chain_from_array(vectors : Array[KVector]) -> KVectorChain {
  { vectors: vectors.copy() }
}

///|
pub fn new_kvector_chain_copy(chain : KVectorChain) -> KVectorChain {
  { vectors: chain.vectors.copy() }
}

///|
pub fn KVectorChain::size(self : KVectorChain) -> Int {
  self.vectors.length()
}

///|
pub fn KVectorChain::is_empty(self : KVectorChain) -> Bool {
  self.vectors.is_empty()
}

///|
pub fn KVectorChain::clear(self : KVectorChain) -> Unit {
  self.vectors.clear()
}

///|
pub fn KVectorChain::get(self : KVectorChain, index : Int) -> KVector {
  self.vectors[index]
}

///|
pub fn KVectorChain::to_string(self : KVectorChain) -> String {
  let builder = @buffer.new()
  builder.write_char('(')
  let mut i = 0
  while i < self.vectors.length() {
    let vector = self.vectors[i]
    builder.write_string("\{vector.x},\{vector.y}")
    if i + 1 < self.vectors.length() {
      builder.write_string("; ")
    }
    i = i + 1
  }
  builder.write_char(')')
  builder.to_string()
}

///|
pub fn KVectorChain::to_array(self : KVectorChain) -> Array[KVector] {
  self.vectors.copy()
}

///|
pub fn KVectorChain::to_array_from(
  self : KVectorChain,
  begin_index : Int,
) -> Array[KVector] {
  if begin_index < 0 || begin_index > self.vectors.length() {
    try kvector_chain_raise_unit("IndexOutOfBoundsException") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          kvector_chain_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return []
  }
  let result = []
  let mut i = begin_index
  while i < self.vectors.length() {
    result.push(self.vectors[i])
    i = i + 1
  }
  result
}

///|
pub fn KVectorChain::parse(self : KVectorChain, string : String) -> Unit {
  let tokens = _split_by_any_delims_keep_empty(string, ",;()[]{} \t\n")
  self.vectors.clear()
  let mut i = 0
  let mut xy = 0
  let mut x = 0.0
  let mut y = 0.0
  while i < tokens.length() {
    let token = tokens[i].trim().to_string()
    if token.length() > 0 {
      if xy % 2 == 0 {
        x = _parse_double_or_abort(
          token, "The given string does not match the expected format for vectors.",
        )
      } else {
        y = _parse_double_or_abort(
          token, "The given string does not match the expected format for vectors.",
        )
      }
      if xy > 0 && xy % 2 != 0 {
        self.vectors.push(new_kvector_xy(x, y))
      }
      xy = xy + 1
    }
    i = i + 1
  }
}

///|
pub fn KVectorChain::add_zero(self : KVectorChain) -> Unit {
  self.vectors.push(new_kvector())
}

///|
pub fn KVectorChain::add_xy(
  self : KVectorChain,
  x : Double,
  y : Double,
) -> Unit {
  self.vectors.push(new_kvector_xy(x, y))
}

///|
pub fn KVectorChain::add_vector(self : KVectorChain, vector : KVector) -> Unit {
  self.vectors.push(vector)
}

///|
pub fn KVectorChain::add_first_zero(self : KVectorChain) -> Unit {
  self.vectors.insert(0, new_kvector())
}

///|
pub fn KVectorChain::add_first_xy(
  self : KVectorChain,
  x : Double,
  y : Double,
) -> Unit {
  self.vectors.insert(0, new_kvector_xy(x, y))
}

///|
pub fn KVectorChain::add_first_vector(
  self : KVectorChain,
  vector : KVector,
) -> Unit {
  self.vectors.insert(0, vector)
}

///|
pub fn KVectorChain::add_last_zero(self : KVectorChain) -> Unit {
  self.vectors.push(new_kvector())
}

///|
pub fn KVectorChain::add_last_xy(
  self : KVectorChain,
  x : Double,
  y : Double,
) -> Unit {
  self.vectors.push(new_kvector_xy(x, y))
}

///|
pub fn KVectorChain::add_last_vector(
  self : KVectorChain,
  vector : KVector,
) -> Unit {
  self.vectors.push(vector)
}

///|
pub fn KVectorChain::add_all(
  self : KVectorChain,
  vectors : Array[KVector],
) -> Unit {
  for vector in vectors {
    self.vectors.push(vector)
  }
}

///|
pub fn KVectorChain::add_all_as_copies(
  self : KVectorChain,
  index : Int,
  chain : KVectorChain,
) -> Unit {
  if index < 0 || index > self.vectors.length() {
    try kvector_chain_raise_unit("IndexOutOfBoundsException") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          kvector_chain_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return
  }
  let copies = []
  for v in chain.vectors {
    copies.push(new_kvector_copy(v))
  }
  let mut i = 0
  while i < copies.length() {
    self.vectors.insert(index + i, copies[i])
    i = i + 1
  }
}

///|
pub fn KVectorChain::scale(self : KVectorChain, scale : Double) -> KVectorChain {
  let mut i = 0
  while i < self.vectors.length() {
    let vector = self.vectors[i]
    ignore(vector.scale(scale))
    self.vectors[i] = vector
    i = i + 1
  }
  self
}

///|
pub fn KVectorChain::scale_xy(
  self : KVectorChain,
  scalex : Double,
  scaley : Double,
) -> KVectorChain {
  let mut i = 0
  while i < self.vectors.length() {
    let vector = self.vectors[i]
    ignore(vector.scale_xy(scalex, scaley))
    self.vectors[i] = vector
    i = i + 1
  }
  self
}

///|
pub fn KVectorChain::offset(
  self : KVectorChain,
  offset : KVector,
) -> KVectorChain {
  let mut i = 0
  while i < self.vectors.length() {
    let vector = self.vectors[i]
    ignore(vector.add(offset))
    self.vectors[i] = vector
    i = i + 1
  }
  self
}

///|
pub fn KVectorChain::offset_non_mutating(
  self : KVectorChain,
  offset : KVector,
) -> KVectorChain {
  let result = new_kvector_chain()
  for vector in self.vectors {
    result.add_vector(kvector_sum([vector, offset]))
  }
  result
}

///|
pub fn KVectorChain::offset_xy(
  self : KVectorChain,
  dx : Double,
  dy : Double,
) -> KVectorChain {
  let mut i = 0
  while i < self.vectors.length() {
    let vector = self.vectors[i]
    ignore(vector.add_xy(dx, dy))
    self.vectors[i] = vector
    i = i + 1
  }
  self
}

///|
pub fn KVectorChain::total_length(self : KVectorChain) -> Double {
  let mut length = 0.0
  if self.vectors.length() >= 2 {
    let mut point1 = self.vectors[0]
    let mut i = 1
    while i < self.vectors.length() {
      let point2 = self.vectors[i]
      length = length + point1.distance(point2)
      point1 = point2
      i = i + 1
    }
  }
  length
}

///|
pub fn KVectorChain::has_nan(self : KVectorChain) -> Bool {
  for v in self.vectors {
    if v.is_nan() {
      return true
    }
  }
  false
}

///|
pub fn KVectorChain::has_infinite(self : KVectorChain) -> Bool {
  for v in self.vectors {
    if v.is_infinite() {
      return true
    }
  }
  false
}

///|
pub fn KVectorChain::point_on_line(
  self : KVectorChain,
  dist : Double,
) -> KVector {
  let size = self.vectors.length()
  if size >= 2 {
    let abs_distance = dist.abs()
    let mut distance_sum = 0.0
    if dist >= 0.0 {
      let mut current_point = self.vectors[0]
      let mut i = 1
      while i < size {
        let old_distance_sum = distance_sum
        let next_point = self.vectors[i]
        let additional_distance_to_next = current_point.distance(next_point)
        if additional_distance_to_next > 0.0 {
          distance_sum = distance_sum + additional_distance_to_next
          if distance_sum >= abs_distance {
            let result = next_point.clone().sub(current_point)
            ignore(
              result.scale(
                (abs_distance - old_distance_sum) / additional_distance_to_next,
              ),
            )
            ignore(result.add(current_point))
            return result
          }
        }
        current_point = next_point
        i = i + 1
      }
      return self.vectors[size - 1]
    }

    // Keep Java behavior: listIterator(size - 1) starts one element before the end segment.
    if size < 3 {
      try kvector_chain_raise_unit("NoSuchElementException") catch {
        err =>
          layout_runtime_report_unsupported_configuration(
            kvector_chain_exception_message(err),
          )
      } noraise {
        _ => ()
      }
      return self.vectors[0]
    }
    let mut current_point = self.vectors[size - 2]
    let mut i = size - 3
    while true {
      let old_distance_sum = distance_sum
      let next_point = self.vectors[i]
      let additional_distance_to_next = current_point.distance(next_point)
      if additional_distance_to_next > 0.0 {
        distance_sum = distance_sum + additional_distance_to_next
        if distance_sum >= abs_distance {
          let result = next_point.clone().sub(current_point)
          ignore(
            result.scale(
              (abs_distance - old_distance_sum) / additional_distance_to_next,
            ),
          )
          ignore(result.add(current_point))
          return result
        }
      }
      current_point = next_point
      if i == 0 {
        break
      }
      i = i - 1
    }
    return self.vectors[0]
  }
  if size == 1 {
    return self.vectors[0]
  }
  try
    kvector_chain_raise_unit(
      "Cannot determine a point on an empty vector chain.",
    )
  catch {
    err =>
      layout_runtime_report_unsupported_configuration(
        kvector_chain_exception_message(err),
      )
  } noraise {
    _ => ()
  }
  new_kvector()
}

///|
pub fn KVectorChain::angle_on_line(
  self : KVectorChain,
  dist : Double,
) -> Double {
  let size = self.vectors.length()
  if size < 2 {
    try
      kvector_chain_raise_unit(
        "Need at least two points to determine an angle.",
      )
    catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          kvector_chain_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return 0.0
  }
  let abs_distance = dist.abs()
  let mut distance_sum = 0.0
  if dist >= 0.0 {
    let mut next_point = self.vectors[0]
    let mut current_point = self.vectors[0]
    let mut i = 1
    while i < size {
      current_point = next_point
      next_point = self.vectors[i]
      let additional_distance_to_next = current_point.distance(next_point)
      if additional_distance_to_next > 0.0 {
        distance_sum = distance_sum + additional_distance_to_next
        if distance_sum >= abs_distance {
          break
        }
      }
      i = i + 1
    }
    return next_point.clone().sub(current_point).to_radians()
  }

  // Keep Java behavior: listIterator(size - 1) starts one element before the end segment.
  if size < 3 {
    try kvector_chain_raise_unit("NoSuchElementException") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          kvector_chain_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return 0.0
  }
  let mut next_point = self.vectors[size - 2]
  let mut current_point = self.vectors[size - 2]
  let mut i = size - 3
  while true {
    current_point = next_point
    next_point = self.vectors[i]
    let additional_distance_to_next = current_point.distance(next_point)
    if additional_distance_to_next > 0.0 {
      distance_sum = distance_sum + additional_distance_to_next
      if distance_sum >= abs_distance {
        break
      }
    }
    if i == 0 {
      break
    }
    i = i - 1
  }
  next_point.clone().sub(current_point).to_radians()
}

///|
pub fn kvector_chain_reverse(chain : KVectorChain) -> KVectorChain {
  let result = new_kvector_chain()
  for vector in chain.vectors {
    result.vectors.insert(0, new_kvector_copy(vector))
  }
  result
}
