# KinoVizjs

[![Hex.pm](https://img.shields.io/hexpm/v/kino_vizjs.svg)](https://hex.pm/packages/kino_vizjs)
[![Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/kino_vizjs)
[![CI](https://github.com/code-shoily/kino_vizjs/actions/workflows/ci.yml/badge.svg)](https://github.com/code-shoily/kino_vizjs/actions/workflows/ci.yml)
[![License](https://img.shields.io/hexpm/l/kino_vizjs.svg)](LICENSE)

A [Livebook](https://livebook.dev) smart cell and component for rendering GraphViz (DOT) graphs in the browser using [Viz.js](https://github.com/mdaines/viz-js).

Viz.js compiles Graphviz to WebAssembly, so no local Graphviz installation is needed. Unlike [kino_yog](https://github.com/code-shoily/kino_yog), which is tied to [Yog](https://github.com/code-shoily/yog), this package works with any source that produces DOT strings.

## Installation

Add `kino_vizjs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kino_vizjs, "~> 0.8"}
  ]
end
```

Or in a Livebook setup cell:

```elixir
Mix.install([
  {:kino_vizjs, "~> 0.8"}
])
```

## Usage

### Smart Cell

Click **+ Smart** and select **"VizJS Render DOT"**.

The Smart Cell provides:
- A DOT editor with a dark theme.
- A layout engine selector (`dot`, `circo`, `neato`, `fdp`, `twopi`, `osage`).
- Configurable height and width that update the output reactively.
- Pan & Zoom support for large graphs.

### `Kino.VizJS.render/2`

For programmatic use, pass a DOT string to `Kino.VizJS.render/2`:

```elixir
dot_graph = """
digraph G {
  node [shape=box style=filled fillcolor=lightblue];
  A -> B -> C -> D -> A;
  B -> D;
}
"""

Kino.VizJS.render(dot_graph, engine: "dot")
```

### With Yog

```elixir
graph =
  Yog.from_edges(
    :directed,
    [
      {1, 2, 10},
      {2, 3, 20},
      {3, 8, 3},
      {4, 7, 9},
      {5, 6, 2},
      {1, 3, 7},
      {2, 7, 9},
      {1, 5, 1},
      {6, 8, 2}
    ]
  )

{:ok, path} = Yog.Pathfinding.Dijkstra.shortest_path(graph, 1, 8)

graph
|> Yog.Render.DOT.to_dot(
  Yog.Render.DOT.path_to_options(path)
)
|> Kino.VizJS.render()
```

```elixir
Yog.Generator.Classic.petersen()
|> Yog.Render.DOT.to_dot()
|> Kino.VizJS.render()
```

See the [Yog](https://github.com/code-shoily/yog) repository for more examples.

### With Libgraph

```elixir
graph =
  Graph.new()
  |> Graph.add_vertices([3, 5, 7])
  |> Graph.add_edge(1, 3)
  |> Graph.add_edge(3, 4)
  |> Graph.add_edge(3, 5)
  |> Graph.add_edge(5, 6)
  |> Graph.add_edge(5, 7)

{:ok, dot} = Graph.to_dot(graph)

Kino.VizJS.render(dot)
```

## Theme Support

The component replaces default black (`#000000` / `black`) fills and strokes from GraphViz output with `currentColor`, so text and edges follow Livebook's light/dark theme. Explicit colors in your DOT source are preserved.
