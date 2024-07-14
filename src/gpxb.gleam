import gleam/option.{type Option, None, Some}
import gleam/string_builder.{type StringBuilder}
import xmb.{type Xml, text, x}

pub type Gpx {
  Gpx(
    metadata: Option(Metadata),
    waypoints: List(Nil),
    routes: List(Nil),
    tracks: List(Nil),
  )
}

pub type Metadata {
  Metadata(
    name: Option(String),
    description: Option(String),
    author: Option(Person),
  )
}

pub type Person {
  Person(name: Option(String), email: Option(String), link: Option(Link))
}

pub type Link {
  Link(href: String, text: Option(String), type_: Option(String))
}

pub fn render(gpx: Gpx) -> StringBuilder {
  let children =
    []
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
