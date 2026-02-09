///|
fn _is_delim_char(c : Char, delims : String) -> Bool {
  delims.contains_char(c)
}

///|
fn _trim_delim_bounds(
  text : String,
  start_delims : String,
  end_delims : String,
) -> (Int, Int) {
  let chars = text.to_array()
  let mut start = 0
  while start < chars.length() && _is_delim_char(chars[start], start_delims) {
    start = start + 1
  }
  let mut end = chars.length()
  while end > 0 && _is_delim_char(chars[end - 1], end_delims) {
    end = end - 1
  }
  (start, end)
}

///|
fn _substring_chars(text : String, start : Int, end : Int) -> String {
  if start >= end {
    return ""
  }
  let chars = text.to_array()
  let builder = @buffer.new()
  let mut i = start
  while i < end {
    builder.write_char(chars[i])
    i = i + 1
  }
  builder.to_string()
}

///|
fn _split_by_any_delims_keep_empty(
  text : String,
  delims : String,
) -> Array[String] {
  let tokens = []
  let current = @buffer.new()
  for ch in text {
    if _is_delim_char(ch, delims) {
      tokens.push(current.to_string())
      current.reset()
    } else {
      current.write_char(ch)
    }
  }
  tokens.push(current.to_string())
  tokens
}

///|
fn _split_by_any_delims_drop_trailing_empty(
  text : String,
  delims : String,
) -> Array[String] {
  let tokens = _split_by_any_delims_keep_empty(text, delims)
  while tokens.length() > 0 {
    match tokens.last() {
      Some(last) =>
        if last.length() == 0 {
          ignore(tokens.pop())
        } else {
          return tokens
        }
      None => return tokens
    }
  }
  tokens
}

///|
fn _parse_double_or_abort(raw : String, message : String) -> Double {
  let text = raw.trim().to_string()
  if text.length() == 0 {
    abort(message)
  }
  try @strconv.parse_double(text) catch {
    _ => abort(message)
  } noraise {
    value => value
  }
}

///|
fn _fuzzy_equals(a : Double, b : Double, epsilon : Double) -> Bool {
  (a - b).abs() <= epsilon
}

///|
fn _fuzzy_compare(a : Double, b : Double, epsilon : Double) -> Int {
  if _fuzzy_equals(a, b, epsilon) {
    0
  } else if a < b {
    -1
  } else {
    1
  }
}
