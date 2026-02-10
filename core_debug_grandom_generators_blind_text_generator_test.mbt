///|
fn core_debug_grandom_blind_text_test_random(seed : Int64) -> @random.Rand {
  let seed_buffer = @buffer.new()
  seed_buffer.write_int64_le(seed)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  @random.Rand::chacha8(seed=seed_buffer.to_bytes())
}

///|
test "grandom blind text generated length and trim" {
  let random = core_debug_grandom_blind_text_test_random(3)
  let text = core_debug_grandom_blind_text_generate_with_random(random)
  assert_true(
    text.length() >= core_debug_grandom_blind_text_character_min_length,
  )
  assert_true(
    text.length() <
    core_debug_grandom_blind_text_character_min_length +
    core_debug_grandom_blind_text_character_range,
  )
  assert_eq(text, text.trim().to_string())
}

///|
test "grandom blind text public generate non empty" {
  let text = core_debug_grandom_blind_text_generate()
  assert_true(!text.is_empty())
}
