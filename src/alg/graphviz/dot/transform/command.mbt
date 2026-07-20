///|
pub enum Command {
  Invalid
  Dot
  Neato
  Twopi
  Fdp
  Circo
}

///|
pub fn command_parse(string : String) -> Command {
  let normalized = string.to_upper()
  if normalized == "INVALID" {
    Invalid
  } else if normalized == "DOT" {
    Dot
  } else if normalized == "NEATO" {
    Neato
  } else if normalized == "TWOPI" {
    Twopi
  } else if normalized == "FDP" {
    Fdp
  } else if normalized == "CIRCO" {
    Circo
  } else {
    Invalid
  }
}

///|
pub fn command_to_string(command : Command) -> String {
  match command {
    Invalid => "invalid"
    Dot => "dot"
    Neato => "neato"
    Twopi => "twopi"
    Fdp => "fdp"
    Circo => "circo"
  }
}
