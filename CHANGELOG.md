# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **Interactive Rendering**: Integrated `svg-pan-zoom` to provide a professional pan-and-zoom experience for all rendered graphs.
- **Dimension Customization**: Added `:height` and `:width` options to `Kino.VizJS.render/2` with support for both numeric and string values (e.g., `500`, `"100%"`).
- **Midnight Editor Theme**: Completely redesigned the Smart Cell UI with a high-contrast, professional "Midnight" dark theme and a dedicated layout settings dashboard.
- **Reactive Smart Cell**: The rendered graph now dynamically updates as you change dimensions in the Smart Cell form without requiring a full evaluation.
- **Download/Copy Toolbar**: Added a premium glassmorphism toolbar to rendered graphs with options to Download DOT, Download SVG, and Copy DOT to clipboard.

### Fixed
- **Unsupported Engines**: Fixed a bug where choosing `sfdp` or `patchwork` engines would cause render errors. These unsupported layout engines have been removed.

## [0.5.0] - 2026-04-12

### Added
- Initial Hex release.
- `Kino.VizJS` component for rendering GraphViz DOT strings via Viz.js.
- `Kino.VizJS.SmartCell` interactive smart cell for Livebook.
- Theme-aware rendering (adapts to Livebook light/dark mode).
