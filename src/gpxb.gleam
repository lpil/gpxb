import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/string_builder.{type StringBuilder}
import xmb.{type Xml, text, x}

pub type Gpx {
  Gpx(
    metadata: Option(Metadata),
    waypoints: List(Waypoint),
    routes: List(Route),
    tracks: List(Track),
  )
}

pub type Coordinate {
  Coordinate(
    /// The latitude of the point. Decimal degrees, WGS84 datum.
    ///
    /// -90.0 <= value <= 90.0
    latitude: Float,
    /// The longitude of the point. Decimal degrees, WGS84 datum.
    ///
    /// -180.0 <= value < 180.0
    longitude: Float,
  )
}

/// A waypoint, point of interest, or named feature on a map.
pub type Waypoint {
  Waypoint(
    coordinate: Coordinate,
    name: Option(String),
    description: Option(String),
    /// Creation/modification timestamp for element. 
    time: Option(Time),
  )
}

/// An ordered series of waypoints representing a suggested series of turn points
/// leading to a destination. 
pub type Route {
  Route(
    name: Option(String),
    description: Option(String),
    /// Source of data. Included to give user some idea of reliability and
    /// accuracy of data.
    source: Option(String),
    /// Links to external information about the route.
    links: List(Link),
    /// The points of the route
    waypoints: List(Waypoint),
  )
}

/// An ordered series of points describing a path that has been taken.
pub type Track {
  Track(
    name: Option(String),
    description: Option(String),
    /// Source of data. Included to give user some idea of reliability and
    /// accuracy of data.
    source: Option(String),
    /// Links to external information about the route.
    links: List(Link),
    segments: List(TrackSegment),
  )
}

/// A Track Segment holds a list of Track Points which are logically connected
/// in order. To represent a single GPS track where GPS reception was lost, or
/// the GPS receiver was turned off, start a new `TrackSegment` for each
/// continuous span of track data.
pub type TrackSegment {
  TrackSegment(waypoints: List(Waypoint))
}

/// Date and time in are in Univeral Coordinated Time (UTC), not local time!
///
/// Conforms to ISO 8601 specification for date/time representation. Fractional
/// seconds are allowed for millisecond timing in tracklogs.
///
pub type Time {
  Time(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
    second: Int,
    millisecond: Int,
  )
}

/// Information about the GPX file, author, and copyright restrictions goes in
/// the metadata section. Providing rich, meaningful information about your GPX
/// files allows others to search for and use your GPS data.
pub type Metadata {
  Metadata(
    name: Option(String),
    description: Option(String),
    author: Option(Person),
  )
}

/// A person or organization.
pub type Person {
  Person(name: Option(String), email: Option(String), link: Option(Link))
}

/// A link to an external resource (Web page, digital photo, video clip, etc)
/// with additional information.
pub type Link {
  Link(href: String, text: Option(String), type_: Option(String))
}

pub fn render(gpx: Gpx) -> StringBuilder {
  let children =
    [
      list.map(gpx.waypoints, waypoint("wpt", _)),
      list.map(gpx.routes, route),
      list.map(gpx.tracks, track),
    ]
    |> list.concat
    |> map_push(gpx.metadata, fn(metadata) {
      []
      |> map_push(metadata.author, person("author", _))
      |> map_push(metadata.description, text_elem("desc", _))
      |> map_push(metadata.name, text_elem("name", _))
      |> x("metadata", [], _)
    })

  let gpx =
    x(
      "gpx",
      [
        #("version", "1.1"),
        #("creator", "gleam-gpxb"),
        #("xmlns", "http://www.topografix.com/GPX/1/1"),
      ],
      children,
    )
  xmb.render([gpx])
}

fn text_elem(tag: String, child: String) -> Xml {
  x(tag, [], [text(child)])
}

fn map_push(items: List(b), item: Option(a), transform: fn(a) -> b) -> List(b) {
  case item {
    None -> items
    Some(item) -> [transform(item), ..items]
  }
}

fn person(tag: String, author: Person) -> Xml {
  x(
    tag,
    [],
    []
      |> map_push(author.link, link)
      |> map_push(author.email, text_elem("email", _))
      |> map_push(author.name, text_elem("name", _)),
  )
}

fn link(link: Link) -> Xml {
  x(
    "link",
    [#("href", link.href)],
    []
      |> map_push(link.type_, text_elem("type", _))
      |> map_push(link.text, text_elem("text", _)),
  )
}

fn waypoint(tag: String, waypoint: Waypoint) -> Xml {
  x(
    tag,
    [
      #("latitude", float.to_string(waypoint.coordinate.latitude)),
      #("longitude", float.to_string(waypoint.coordinate.longitude)),
    ],
    []
      |> map_push(waypoint.time, time)
      |> map_push(waypoint.description, text_elem("desc", _))
      |> map_push(waypoint.name, text_elem("name", _)),
  )
}

fn time(time: Time) -> Xml {
  let i = fn(i: Int) { i |> int.to_string |> string.pad_left(2, "0") }
  let timestamp =
    i(time.year)
    <> "-"
    <> i(time.month)
    <> "-"
    <> i(time.day)
    <> "T"
    <> i(time.hour)
    <> ":"
    <> i(time.minute)
    <> ":"
    <> i(time.second)
    <> "."
    <> string.pad_left(int.to_string(time.millisecond % 1000), 4, "0")
    <> "Z"
  x("time", [], [text(timestamp)])
}

fn route(route: Route) -> Xml {
  x(
    "rte",
    [],
    [
      list.map(route.links, link),
      list.map(route.waypoints, waypoint("rtept", _)),
    ]
      |> list.concat
      |> map_push(route.source, text_elem("src", _))
      |> map_push(route.description, text_elem("desc", _))
      |> map_push(route.name, text_elem("name", _)),
  )
}

fn track(track: Track) -> Xml {
  x(
    "trk",
    [],
    [list.map(track.links, link), list.map(track.segments, track_segment)]
      |> list.concat
      |> map_push(track.source, text_elem("src", _))
      |> map_push(track.description, text_elem("desc", _))
      |> map_push(track.name, text_elem("name", _)),
  )
}

fn track_segment(segment: TrackSegment) -> Xml {
  x("trkseg", [], list.map(segment.waypoints, waypoint("trkpt", _)))
}
