///|
fn bw_min_double(left : Double, right : Double) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn bw_max_double(left : Double, right : Double) -> Double {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn contains_triangle(triangles : Array[TTriangle], target : TTriangle) -> Bool {
  for triangle in triangles {
    if triangle.equals(target) {
      return true
    }
  }
  false
}

///|
fn contains_edge(edges : Array[TEdge], target : TEdge) -> Bool {
  for edge in edges {
    if edge.equals(target) {
      return true
    }
  }
  false
}

///|
fn add_triangle_unique(
  triangles : Array[TTriangle],
  triangle : TTriangle,
) -> Unit {
  if !contains_triangle(triangles, triangle) {
    triangles.push(triangle)
  }
}

///|
fn add_edge_unique(edges : Array[TEdge], edge : TEdge) -> Unit {
  if !contains_edge(edges, edge) {
    edges.push(edge)
  }
}

///|
fn remove_triangles(
  triangulation : Array[TTriangle],
  invalid_triangles : Array[TTriangle],
) -> Unit {
  let mut index = 0
  while index < triangulation.length() {
    if contains_triangle(invalid_triangles, triangulation[index]) {
      ignore(triangulation.remove(index))
    } else {
      index = index + 1
    }
  }
}

///|
pub fn bowyer_watson_triangulate(
  vertices : Array[KVector],
  debug_output_file? : String? = None,
) -> Array[TEdge] {
  if vertices.length() == 0 {
    return []
  }
  let svg = new_svg_image(debug_output_file)
  svg.add_groups(["invalid", "tri", "bndry", "done", "new", "bb"])
  let topleft = new_kvector_xy(@double.infinity, @double.infinity)
  let bottomright = new_kvector_xy(-@double.infinity, -@double.infinity)
  for vertex in vertices {
    topleft.x = bw_min_double(topleft.x, vertex.x)
    topleft.y = bw_min_double(topleft.y, vertex.y)
    bottomright.x = bw_max_double(bottomright.x, vertex.x)
    bottomright.y = bw_max_double(bottomright.y, vertex.y)
    svg
    .g("bb")
    .add_circle(
      vertex.x,
      vertex.y,
      r=18.0,
      attributes="stroke=\"black\" stroke-width=\"1\" fill=\"lightgray\"",
    )
  }
  let size = new_kvector_xy(
    bottomright.x - topleft.x,
    bottomright.y - topleft.y,
  )
  svg
  .g("bb")
  .add_rect(
    topleft.x,
    topleft.y,
    size.x,
    size.y,
    "stroke=\"blue\" stroke-width=\"4\" fill=\"none\"",
  )
  let wiggleroom = 50.0
  let sa = new_kvector_xy(
    topleft.x - wiggleroom,
    topleft.y - size.x - wiggleroom,
  )
  let sb = new_kvector_xy(
    topleft.x - wiggleroom,
    bottomright.y + size.x + wiggleroom,
  )
  let sc = new_kvector_xy(
    bottomright.x + size.y / 2.0 + wiggleroom,
    topleft.y + size.y / 2.0,
  )
  svg
  .g("bb")
  .add_poly(
    "stroke=\"gray\" stroke-width=\"4\" fill=\"none\" stroke-dasharray=\"20,20\"",
    [sa, sb, sc, sa],
  )
  let super_triangle = new_ttriangle(sa, sb, sc)
  svg.set_view_box(sa.x, sa.y, sc.x - sa.x, sb.y - sa.y)
  svg.isave()
  svg.remove_group("bb")
  let triangulation : Array[TTriangle] = []
  let invalid_triangles : Array[TTriangle] = []
  let boundary : Array[TEdge] = []
  add_triangle_unique(triangulation, super_triangle)
  for vertex in vertices {
    svg
    .g("done")
    .add_circle(
      vertex.x,
      vertex.y,
      r=18.0,
      attributes="stroke=\"black\" stroke-width=\"1\" fill=\"lightgray\"",
    )
    svg
    .g("new")
    .add_circle(
      vertex.x,
      vertex.y,
      r=18.0,
      attributes="stroke=\"black\" stroke-width=\"1\" fill=\"black\"",
    )
    invalid_triangles.clear()
    for triangle in triangulation {
      svg
      .g("tri")
      .add_poly("stroke=\"black\" fill=\"none\" stroke-width=\"4\"", [
        triangle.a,
        triangle.b,
        triangle.c,
        triangle.a,
      ])
      let center = triangle.get_circumcenter()
      svg
      .g("invalid")
      .add_circle(
        center.x,
        center.y,
        r=center.distance(triangle.a),
        attributes="stroke=\"orange\" stroke-width=\"4\" fill=\"none\"",
      )
      if triangle.in_circumcircle(vertex) {
        invalid_triangles.push(triangle)
        svg
        .g("invalid")
        .add_poly("stroke=\"none\" fill=\"red\" opacity=\"0.18\"", [
          triangle.a,
          triangle.b,
          triangle.c,
          triangle.a,
        ])
      }
    }
    svg.isave()
    svg.clear_group("invalid")
    boundary.clear()
    for triangle in invalid_triangles {
      for edge in triangle.t_edges {
        let mut on_boundary = true
        for other in invalid_triangles {
          if !other.equals(triangle) && other.contains_edge(edge) {
            on_boundary = false
          }
        }
        if on_boundary {
          boundary.push(edge)
          svg
          .g("bndry")
          .add_line(
            edge.u.x,
            edge.u.y,
            edge.v.x,
            edge.v.y,
            attributes="stroke=\"purple\" stroke-width=\"18\" stroke-dasharray=\"20,20\"",
          )
        }
      }
    }
    svg.isave()
    remove_triangles(triangulation, invalid_triangles)
    svg.clear_group("tri")
    for triangle in triangulation {
      svg
      .g("tri")
      .add_poly("stroke=\"black\" fill=\"none\" stroke-width=\"4\"", [
        triangle.a,
        triangle.b,
        triangle.c,
        triangle.a,
      ])
    }
    svg.isave()
    for edge in boundary {
      let new_triangle = new_ttriangle(vertex, edge.u, edge.v)
      add_triangle_unique(triangulation, new_triangle)
      svg
      .g("tri")
      .add_poly("stroke=\"black\" fill=\"none\" stroke-width=\"4\"", [
        vertex,
        edge.u,
        edge.v,
        vertex,
      ])
    }
    svg.isave()
    svg.clear_group("new")
    svg.clear_group("bndry")
    svg.clear_group("tri")
  }
  let t_edges : Array[TEdge] = []
  for triangle in triangulation {
    for edge in triangle.t_edges {
      add_edge_unique(t_edges, edge)
    }
  }
  let mut index = 0
  while index < t_edges.length() {
    let edge = t_edges[index]
    if super_triangle.contains_vertex(edge.u) ||
      super_triangle.contains_vertex(edge.v) {
      ignore(t_edges.remove(index))
    } else {
      index = index + 1
    }
  }
  for edge in t_edges {
    svg.add_line(
      edge.u.x,
      edge.u.y,
      edge.v.x,
      edge.v.y,
      attributes="stroke=\"black\" stroke-width=\"4\"",
    )
  }
  svg.isave()
  t_edges
}
