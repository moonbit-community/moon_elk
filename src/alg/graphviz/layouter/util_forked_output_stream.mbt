///|
fn graphviz_output_stream_range_start(offset : Int) -> Int {
  if offset < 0 {
    0
  } else {
    offset
  }
}

///|
fn graphviz_output_stream_range_end(
  bytes : Array[Int],
  offset : Int,
  length : Int,
) -> Int {
  let start = graphviz_output_stream_range_start(offset)
  let requested_end = start + (if length < 0 { 0 } else { length })
  if requested_end > bytes.length() {
    bytes.length()
  } else {
    requested_end
  }
}

///|
pub struct GraphvizOutputStream {
  write_byte_fn : (Int) -> Unit
  write_bytes_fn : (Array[Int], Int, Int) -> Unit
  flush_fn : () -> Unit
  close_fn : () -> Unit
}

///|
pub fn new_graphviz_output_stream(
  write_byte_fn : (Int) -> Unit,
  write_bytes_fn : (Array[Int], Int, Int) -> Unit,
  flush_fn : () -> Unit,
  close_fn : () -> Unit,
) -> GraphvizOutputStream {
  { write_byte_fn, write_bytes_fn, flush_fn, close_fn }
}

///|
pub fn GraphvizOutputStream::write(
  self : GraphvizOutputStream,
  b : Int,
) -> Unit {
  (self.write_byte_fn)(b)
}

///|
pub fn GraphvizOutputStream::write_bytes(
  self : GraphvizOutputStream,
  bytes : Array[Int],
  off : Int,
  len : Int,
) -> Unit {
  (self.write_bytes_fn)(bytes, off, len)
}

///|
pub fn GraphvizOutputStream::flush(self : GraphvizOutputStream) -> Unit {
  (self.flush_fn)()
}

///|
pub fn GraphvizOutputStream::close(self : GraphvizOutputStream) -> Unit {
  (self.close_fn)()
}

///|
pub struct GraphvizByteArrayOutputStream {
  bytes_ref : Ref[Array[Int]]
  flush_count_ref : Ref[Int]
  closed_ref : Ref[Bool]
}

///|
pub fn new_graphviz_byte_array_output_stream() -> GraphvizByteArrayOutputStream {
  { bytes_ref: Ref([]), flush_count_ref: Ref(0), closed_ref: Ref(false) }
}

///|
pub fn GraphvizByteArrayOutputStream::as_output_stream(
  self : GraphvizByteArrayOutputStream,
) -> GraphvizOutputStream {
  let write_byte_fn = (b : Int) => {
    if !self.closed_ref.val {
      self.bytes_ref.val.push(b)
    }
  }
  let write_bytes_fn = (bytes : Array[Int], off : Int, len : Int) => {
    if self.closed_ref.val {
      return
    }
    let start = graphviz_output_stream_range_start(off)
    let end_ = graphviz_output_stream_range_end(bytes, off, len)
    let mut index = start
    while index < end_ {
      self.bytes_ref.val.push(bytes[index])
      index += 1
    }
  }
  let flush_fn = () => self.flush_count_ref.val = self.flush_count_ref.val + 1
  let close_fn = () => self.closed_ref.val = true
  new_graphviz_output_stream(write_byte_fn, write_bytes_fn, flush_fn, close_fn)
}

///|
pub fn GraphvizByteArrayOutputStream::get_bytes(
  self : GraphvizByteArrayOutputStream,
) -> Array[Int] {
  self.bytes_ref.val
}

///|
pub fn GraphvizByteArrayOutputStream::get_flush_count(
  self : GraphvizByteArrayOutputStream,
) -> Int {
  self.flush_count_ref.val
}

///|
pub fn GraphvizByteArrayOutputStream::is_closed(
  self : GraphvizByteArrayOutputStream,
) -> Bool {
  self.closed_ref.val
}

///|
pub struct ForkedOutputStream {
  output_streams : Array[GraphvizOutputStream]
}

///|
pub fn new_forked_output_stream(
  output_streams : Array[GraphvizOutputStream],
) -> ForkedOutputStream {
  { output_streams, }
}

///|
pub fn new_forked_output_stream2(
  stream0 : GraphvizOutputStream,
  stream1 : GraphvizOutputStream,
) -> ForkedOutputStream {
  { output_streams: [stream0, stream1] }
}

///|
pub fn ForkedOutputStream::write(self : ForkedOutputStream, b : Int) -> Unit {
  for stream in self.output_streams {
    stream.write(b)
  }
}

///|
pub fn ForkedOutputStream::flush(self : ForkedOutputStream) -> Unit {
  for stream in self.output_streams {
    stream.flush()
  }
}

///|
pub fn ForkedOutputStream::close(self : ForkedOutputStream) -> Unit {
  for stream in self.output_streams {
    stream.close()
  }
}
