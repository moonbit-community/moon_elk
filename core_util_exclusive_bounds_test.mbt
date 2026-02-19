///|
test "ExclusiveBounds lower bound comparison and rendering" {
  let lower = greater_than(0.0)
  inspect(lower.compare_to(-1.0), content="1")
  inspect(lower.compare_to(0.0), content="1")
  inspect(lower.compare_to(0.0001), content="-1")
  inspect(lower.to_string(), content="0 (exclusive)")
}

///|
test "ExclusiveBounds upper bound comparison and rendering" {
  let upper = less_than(5.0)
  inspect(upper.compare_to(6.0), content="-1")
  inspect(upper.compare_to(5.0), content="-1")
  inspect(upper.compare_to(4.9), content="1")
  inspect(upper.to_string(), content="5 (exclusive)")
}
