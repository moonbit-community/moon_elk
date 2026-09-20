///|
fn graphviz_text_runner_bytes_to_string(bytes : Array[Int]) -> String {
  let encoded : Array[Byte] = []
  for byte in bytes {
    encoded.push(byte.to_byte())
  }
  @utf8.decode_lossy(Bytes::from_array(encoded))
}

///|
fn graphviz_text_runner_string_to_bytes(text : String) -> Array[Int] {
  let bytes = @utf8.encode(text)
  let result : Array[Int] = []
  for byte in bytes {
    result.push(byte.to_int())
  }
  result
}

///|
pub fn new_graphviz_process_from_text_runner(
  run_fn : (String) -> String?,
) -> GraphvizProcess {
  let input_sink = new_graphviz_byte_array_output_stream()
  let output_bytes_ref : Ref[Array[Int]] = Ref([])
  let loaded_ref : Ref[Bool] = Ref(false)
  let index_ref : Ref[Int] = Ref(0)
  let mark_ref : Ref[Int] = Ref(0)
  let closed_ref : Ref[Bool] = Ref(false)

  let ensure_loaded = () => {
    if loaded_ref.val || closed_ref.val {
      return
    }
    let input_text = graphviz_text_runner_bytes_to_string(
      input_sink.get_bytes(),
    )
    output_bytes_ref.val = match run_fn(input_text) {
      Some(output) => graphviz_text_runner_string_to_bytes(output)
      None => []
    }
    loaded_ref.val = true
  }

  let read_fn = () => {
    ensure_loaded()
    if closed_ref.val || index_ref.val >= output_bytes_ref.val.length() {
      -1
    } else {
      let value = output_bytes_ref.val[index_ref.val]
      index_ref.val = index_ref.val + 1
      value
    }
  }
  let read_bytes_with_offset_fn = (bytes : Array[Int], off : Int, len : Int) => {
    ensure_loaded()
    if closed_ref.val || index_ref.val >= output_bytes_ref.val.length() {
      -1
    } else {
      let start = if off < 0 { 0 } else { off }
      let requested = if len < 0 { 0 } else { len }
      let end = @cmp.minimum(start + requested, bytes.length())
      let count = @cmp.minimum(
        end - start,
        output_bytes_ref.val.length() - index_ref.val,
      )
      let mut i = 0
      while i < count {
        bytes[start + i] = output_bytes_ref.val[index_ref.val + i]
        i = i + 1
      }
      index_ref.val = index_ref.val + count
      count
    }
  }
  let read_bytes_fn = (bytes : Array[Int]) => {
    read_bytes_with_offset_fn(bytes, 0, bytes.length())
  }
  let skip_fn = (n : Int) => {
    ensure_loaded()
    if closed_ref.val || n <= 0 {
      0
    } else {
      let remaining = output_bytes_ref.val.length() - index_ref.val
      let count = @cmp.minimum(n, remaining)
      index_ref.val = index_ref.val + count
      count
    }
  }
  let available_fn = () => {
    ensure_loaded()
    if closed_ref.val {
      0
    } else {
      output_bytes_ref.val.length() - index_ref.val
    }
  }
  let close_fn = () => closed_ref.val = true
  let mark_fn = (_readlimit : Int) => {
    if !closed_ref.val {
      mark_ref.val = index_ref.val
    }
  }
  let reset_fn = () => if !closed_ref.val { index_ref.val = mark_ref.val }
  let mark_supported_fn = () => true

  let output_stream = new_graphviz_input_stream(
    read_fn, read_bytes_fn, read_bytes_with_offset_fn, skip_fn, available_fn, close_fn,
    mark_fn, reset_fn, mark_supported_fn,
  )
  new_graphviz_process(
    input_sink.as_output_stream(),
    output_stream,
    new_graphviz_byte_array_input_stream([]).as_input_stream(),
    exit_value_fn=() => {
      ensure_loaded()
      Some(0)
    },
  )
}
