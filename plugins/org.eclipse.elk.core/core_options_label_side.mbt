///|
pub enum LabelSide {
  Unknown
  Above
  Below
  Inline
}

///|
pub fn label_side_to_string(side : LabelSide) -> String {
  match side {
    Unknown => "UNKNOWN"
    Above => "ABOVE"
    Below => "BELOW"
    Inline => "INLINE"
  }
}

///|
pub fn LabelSide::opposite(self : LabelSide) -> LabelSide {
  match self {
    Above => Below
    Below => Above
    Inline => Inline
    Unknown => Unknown
  }
}
