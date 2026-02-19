///|
let core_debug_grandom_blind_text_lorem_ipsum : String = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."

///|
pub let core_debug_grandom_blind_text_character_min_length : Int = 40

///|
pub let core_debug_grandom_blind_text_character_range : Int = 10

///|
pub fn core_debug_grandom_blind_text_generate() -> String {
  core_debug_grandom_blind_text_generate_with_random(@random.Rand::new())
}

///|
pub fn core_debug_grandom_blind_text_generate_with_random(
  random_generator : @random.Rand,
) -> String {
  let num_of_characters = random_generator.int(
      limit=core_debug_grandom_blind_text_character_range,
    ) +
    core_debug_grandom_blind_text_character_min_length
  let offset = random_generator.int(
    limit=core_debug_grandom_blind_text_lorem_ipsum.length() -
      (
        core_debug_grandom_blind_text_character_range +
        core_debug_grandom_blind_text_character_min_length
      ),
  )
  core_debug_grandom_blind_text_lorem_ipsum
  .unsafe_substring(start=offset, end=offset + num_of_characters)
  .trim()
  .to_string()
}
