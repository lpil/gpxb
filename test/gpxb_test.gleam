import birdie
import gleam/option.{None, Some}
import gleam/string
import gleam/string_builder
import gleeunit
import gpxb.{type Gpx, Gpx, Link, Metadata, Person}

pub fn main() {
  gleeunit.main()
}

fn snapshot(gpx: Gpx) -> String {
  let input = string.inspect(gpx)
  let output = gpx |> gpxb.render |> string_builder.to_string
  input <> "\n\n" <> output
}

pub fn empty_test() {
  Gpx(metadata: None, waypoints: [], routes: [], tracks: [])
  |> snapshot
  |> birdie.snap("empty")
}

pub fn some_metadata_test() {
  Gpx(
    metadata: Some(Metadata(
      name: Some("the name"),
      description: Some("really cool"),
      author: None,
    )),
    waypoints: [],
    routes: [],
    tracks: [],
  )
  |> snapshot
  |> birdie.snap("some_metadata")
}

pub fn author_test() {
  Gpx(
    metadata: Some(Metadata(
      name: Some("the name"),
      description: Some("really cool"),
      author: Some(Person(
        name: Some("Lucy"),
        email: Some("lucy@example.com"),
        link: Some(Link(
          href: "https://example.com",
          text: Some("link text"),
          type_: Some("link type"),
        )),
      )),
    )),
    waypoints: [],
    routes: [],
    tracks: [],
  )
  |> snapshot
  |> birdie.snap("author")
}
