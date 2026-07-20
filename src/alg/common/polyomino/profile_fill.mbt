///|
pub fn fill_polyomino(poly : Polyomino) -> Unit {
  let width = poly.width()
  let north_profile = Array::make(width, 0)
  let south_profile = Array::make(width, 0)

  let height = poly.height()
  let east_profile = Array::make(height, 0)
  let west_profile = Array::make(height, 0)

  for xi = 0; xi < width; xi = xi + 1 {
    let mut y = 0
    while y < height && !poly.is_blocked(xi, y) {
      y = y + 1
    }
    north_profile[xi] = y
  }

  for xi = 0; xi < width; xi = xi + 1 {
    let mut y = height - 1
    while y >= 0 && !poly.is_blocked(xi, y) {
      y = y - 1
    }
    south_profile[xi] = y
  }

  for yi = 0; yi < height; yi = yi + 1 {
    let mut x = 0
    while x < width && !poly.is_blocked(x, yi) {
      x = x + 1
    }
    east_profile[yi] = x
  }

  for yi = 0; yi < height; yi = yi + 1 {
    let mut x = width - 1
    while x >= 0 && !poly.is_blocked(x, yi) {
      x = x - 1
    }
    west_profile[yi] = x
  }

  for xi = 0; xi < width; xi = xi + 1 {
    for yi = 0; yi < height; yi = yi + 1 {
      if xi < west_profile[yi] &&
        xi > east_profile[yi] &&
        yi < south_profile[xi] &&
        yi > north_profile[xi] {
        poly.set_blocked(xi, yi)
      }
    }
  }
}
