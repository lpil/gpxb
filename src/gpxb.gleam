import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string_builder.{type StringBuilder}
import xmb.{type Xml, text, x}

pub type Gpx {
  Gpx(
    metadata: Option(Metadata),
    waypoints: List(Waypoint),
    routes: List(Nil),
    tracks: List(Nil),
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
    [list.map(gpx.waypoints, waypoint)]
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

fn waypoint(waypoint: Waypoint) -> Xml {
  x(
    "wpt",
    [
      #("latitude", float.to_string(waypoint.coordinate.latitude)),
      #("longitude", float.to_string(waypoint.coordinate.longitude)),
    ],
    []
      |> map_push(waypoint.description, text_elem("desc", _))
      |> map_push(waypoint.name, text_elem("name", _)),
  )
}
