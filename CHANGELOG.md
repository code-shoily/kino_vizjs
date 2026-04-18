# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Integrated `svg-pan-zoom` for pan-and-zoom support on rendered graphs.
- Added `:height` and `:width` options to `Kino.VizJS.render/2`. Accepts integers (pixels) or strings (e.g., `"100%"`).
- Redesigned the Smart Cell editor with a dark theme and layout settings for height/width.
- Smart Cell dimensions now update the rendered graph reactively without requiring re-evaluation.
- Added a toolbar overlay on rendered graphs with Download DOT, Download SVG, and Copy DOT buttons.
- Added `@spec` to `Kino.VizJS.render/2`.
- `render/2` now validates the engine name at the Elixir level, raising `ArgumentError` for unrecognized engines.
- `render/2` now enforces `is_binary(dot_string)` via a guard clause.
- Smart Cell `to_source/1` omits options that match their defaults.
- CI now runs `mix compile --warnings-as-errors` and `mix dialyzer`. Added `_build` caching.

### Fixed
- Removed `sfdp` and `patchwork` engines, which are not supported by Viz.js 2.x.
- Error messages from Viz.js are now rendered via `textContent` instead of `innerHTML` to prevent XSS.

## [0.5.0] - 2026-04-12

### Added
- Initial Hex release.
- `Kino.VizJS` component for rendering GraphViz DOT strings via Viz.js.
- `Kino.VizJS.SmartCell` for Livebook.
- Theme-aware rendering (adapts to Livebook light/dark mode).
