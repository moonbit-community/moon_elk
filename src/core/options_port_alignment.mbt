///|
pub(all) enum PortAlignment {
  Distributed
  Justified
  Begin
  Center
  End
}

///|
pub fn port_alignment_to_string(alignment : PortAlignment) -> String {
  match alignment {
    Distributed => "DISTRIBUTED"
    Justified => "JUSTIFIED"
    Begin => "BEGIN"
    Center => "CENTER"
    End => "END"
  }
}
