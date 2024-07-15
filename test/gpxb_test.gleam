import birdie
import gleam/option.{None, Some}
import gleam/string
import gleam/string_builder
import gleeunit
import gpxb.{
  type Gpx, Coordinate, Gpx, Link, Metadata, Person, Route, Time, Track,
  TrackSegment, Waypoint,
}

pub fn main() {
  gleeunit.main()
}

fn snapshot(gpx: Gpx) -> String {
  let input = string.inspect(gpx)
  let output =
    gpx
    |> gpxb.render
    |> string_builder.to_string
    |> string.replace("><", ">\n<")
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

pub fn waypoints_test() {
  Gpx(
    metadata: None,
    waypoints: [
      Waypoint(
        coordinate: Coordinate(latitude: 0.5, longitude: -4.5),
        name: Some("wp-name"),
        description: Some("wp-desc"),
        time: Some(Time(
          year: 2024,
          month: 1,
          day: 5,
          hour: 12,
          minute: 14,
          second: 55,
          millisecond: 455,
        )),
      ),
      Waypoint(
        coordinate: Coordinate(latitude: 50.5, longitude: -34.55),
        name: None,
        description: None,
        time: None,
      ),
    ],
    routes: [],
    tracks: [],
  )
  |> snapshot
  |> birdie.snap("waypoints")
}

pub fn routes_test() {
  Gpx(
    metadata: None,
    waypoints: [],
    routes: [
      Route(name: None, description: None, source: None, links: [], waypoints: [
        Waypoint(
          coordinate: Coordinate(latitude: 1.5, longitude: -1.55),
          name: None,
          description: None,
          time: None,
        ),
      ]),
      Route(
        name: Some("route1-name"),
        description: Some("route1-desc"),
        source: Some("i made it up"),
        links: [
          Link(
            href: "https://example.com/1",
            text: Some("route1 link text"),
            type_: Some("route1 link type"),
          ),
          Link(
            href: "https://example.com/2",
            text: Some("route1 link text 2"),
            type_: Some("route1 link type 2"),
          ),
        ],
        waypoints: [
          Waypoint(
            coordinate: Coordinate(latitude: 0.5, longitude: -4.5),
            name: Some("wp-name"),
            description: Some("wp-desc"),
            time: Some(Time(
              year: 2024,
              month: 1,
              day: 5,
              hour: 12,
              minute: 14,
              second: 55,
              millisecond: 1,
            )),
          ),
          Waypoint(
            coordinate: Coordinate(latitude: 50.5, longitude: -34.55),
            name: None,
            description: None,
            time: None,
          ),
        ],
      ),
    ],
    tracks: [],
  )
  |> snapshot
  |> birdie.snap("routes")
}

pub fn tracks_test() {
  Gpx(metadata: None, waypoints: [], routes: [], tracks: [
    Track(
      name: Some("track1-name"),
      description: Some("track1-desc"),
      source: Some("i made it up"),
      links: [
        Link(
          href: "https://example.com/1",
          text: Some("link text"),
          type_: Some("link type"),
        ),
        Link(
          href: "https://example.com/2",
          text: Some("link text 2"),
          type_: Some("link type 2"),
        ),
      ],
      segments: [
        TrackSegment([
          Waypoint(
            coordinate: Coordinate(latitude: 0.5, longitude: -4.5),
            name: Some("wp-name"),
            description: Some("wp-desc"),
            time: Some(Time(
              year: 2024,
              month: 1,
              day: 5,
              hour: 12,
              minute: 14,
              second: 55,
              millisecond: 1,
            )),
          ),
          Waypoint(
            coordinate: Coordinate(latitude: 50.5, longitude: -34.55),
            name: None,
            description: None,
            time: None,
          ),
        ]),
        TrackSegment([
          Waypoint(
            coordinate: Coordinate(latitude: 1.5, longitude: -4.5),
            name: None,
            description: None,
            time: None,
          ),
          Waypoint(
            coordinate: Coordinate(latitude: 2.5, longitude: -34.55),
            name: None,
            description: None,
            time: None,
          ),
        ]),
      ],
    ),
  ])
  |> snapshot
  |> birdie.snap("tracks")
}
