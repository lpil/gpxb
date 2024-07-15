# gpxb

A tiny GPX builder for Gleam.

[![Package Version](https://img.shields.io/hexpm/v/gpxb)](https://hex.pm/packages/gpxb)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gpxb/)

```sh
gleam add gpxb@1
```
```gleam
import gpxb.{Gpx, Waypoint, Coordinate}
import gleam/option.{Some, None}
import gleam/string_builder

pub fn main() {
  Gpx(
    metadata: None,
    waypoints: [
      Waypoint(
        coordinate: Coordinate(latitude: 51.53845, longitude: 0.14236),
        name: Some("Mother Black Cap"),
        description: None,
        time: None,
      ),
    ],
    routes: [],
    tracks: [],
  )
  |> gpxb.render 
  |> string_builder.to_string
  |> io.println
}
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="gleam-gpxb" xmlns="http://www.topografix.com/GPX/1/1">
  <wpt latitude="51.53845" longitude="0.14236">
    <name>Mother Black Cap</name>
  </wpt>
</gpx>
```

Further documentation can be found at <https://hexdocs.pm/gpxb>.
