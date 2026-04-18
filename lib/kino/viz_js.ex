defmodule Kino.VizJS do
  @moduledoc """
  A Kino component for rendering GraphViz variables (DOT strings) via Viz.js.
  """

  use Kino.JS

  @valid_engines ~w(dot circo neato fdp twopi osage)

  @typep engine :: String.t()
  @typep dimension :: String.t() | non_neg_integer()
  @typep option :: {:engine, engine()} | {:height, dimension()} | {:width, dimension()}

  @doc """
  Creates a new Kino component to render the given DOT string using Viz.js.

  ## Options

    * `:engine` - The GraphViz engine to use. Must be one of `#{inspect(@valid_engines)}`. Defaults to `"dot"`.
    * `:height` - The height of the graph container. Can be an integer (pixels) or a string (e.g. "400px", "50vh"). If an integer is provided, "px" is assumed. Defaults to `"300px"`.
    * `:width` - The width of the graph container. Can be an integer (pixels) or a string (e.g. "100%", "500px"). If an integer is provided, "px" is assumed. Defaults to `"100%"`.
  """
  @spec render(String.t(), [option()]) :: Kino.JS.t()
  def render(dot_string, options \\ []) when is_binary(dot_string) do
    options = Keyword.validate!(options, engine: "dot", height: "300px", width: "100%")

    unless options[:engine] in @valid_engines do
      raise ArgumentError,
            "invalid engine #{inspect(options[:engine])}, expected one of #{inspect(@valid_engines)}"
    end

    {layout_options, render_options} = Keyword.split(options, [:height, :width])

    Kino.JS.new(__MODULE__, %{
      dot_string: dot_string,
      options: Enum.into(render_options, %{}),
      height: layout_options[:height],
      width: layout_options[:width]
    })
  end

  asset "main.js" do
    """
    export async function init(ctx, payload) {
      ctx.importCSS("https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css");

      const loadVizJS = async () => {
        if (!window.Viz) {
          await ctx.importJS("https://cdnjs.cloudflare.com/ajax/libs/viz.js/2.1.2/viz.js");
          await ctx.importJS("https://cdnjs.cloudflare.com/ajax/libs/viz.js/2.1.2/full.render.js");
        }
      };

      const loadSvgPanZoom = async () => {
        if (!window.svgPanZoom) {
          await ctx.importJS("https://cdn.jsdelivr.net/npm/svg-pan-zoom@3.6.1/dist/svg-pan-zoom.min.js");
        }
      };

      const container = document.createElement("div");
      container.className = "relative p-2 rounded-2xl border border-gray-100 bg-white shadow-xl group overflow-hidden transition-all duration-300 hover:shadow-2xl";
      
      const formatDimension = (dim) => {
        if (typeof dim === 'number') return `${dim}px`;
        if (typeof dim === 'string' && /^\d+$/.test(dim)) return `${dim}px`;
        return dim;
      };

      container.style.width = formatDimension(payload.width);
      
      const toolbar = document.createElement("div");
      toolbar.className = "absolute top-4 right-4 flex items-center p-1 space-x-1 opacity-0 group-hover:opacity-100 transition-all duration-300 z-50 backdrop-blur-md bg-white/70 rounded-full border border-white/50 shadow-sm translate-y-2 group-hover:translate-y-0";
      
      const createButton = (label, title, icon, colorClass, onClick) => {
        const btn = document.createElement("button");
        btn.className = `flex items-center space-x-1.5 px-3 py-1.5 text-[11px] font-semibold rounded-full transition-all duration-200 ${colorClass}`;
        btn.title = title;
        btn.innerHTML = `${icon}<span>${label}</span>`;
        btn.onclick = onClick;
        return btn;
      };

      const downloadFile = (content, filename, contentType) => {
        const blob = new Blob([content], { type: contentType });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = filename;
        a.click();
        URL.revokeObjectURL(url);
      };

      const resetIcon = `<svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>`;
      const dotIcon = `<svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>`;
      const imageIcon = `<svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>`;
      const copyIcon = `<svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2" /></svg>`;

      let panZoomInstance = null;

      const btnReset = createButton("Reset", "Reset Zoom & Pan", resetIcon, "text-orange-600 hover:bg-orange-50", () => {
        if (panZoomInstance) panZoomInstance.reset();
      });

      const btnCopy = createButton("Copy", "Copy DOT to clipboard", copyIcon, "text-purple-600 hover:bg-purple-50", () => {
        navigator.clipboard.writeText(payload.dot_string).then(() => {
          const span = btnCopy.querySelector("span");
          const oldText = span.textContent;
          span.textContent = "Copied!";
          setTimeout(() => span.textContent = oldText, 2000);
        });
      });

      const btnDot = createButton("DOT", "Download DOT source", dotIcon, "text-gray-600 hover:bg-gray-50", () => {
        downloadFile(payload.dot_string, "graph.dot", "text/vnd.graphviz");
      });

      const btnSvg = createButton("SVG", "Download SVG image", imageIcon, "text-blue-600 hover:bg-blue-50", () => {
        const svg = dotContainer.querySelector("svg");
        if (svg) {
          const serializer = new XMLSerializer();
          const source = '<?xml version="1.0" standalone="no"?>\\r\\n' + serializer.serializeToString(svg);
          downloadFile(source, "graph.svg", "image/svg+xml;charset=utf-8");
        }
      });

      toolbar.appendChild(btnReset);
      toolbar.appendChild(btnCopy);
      toolbar.appendChild(btnDot);
      toolbar.appendChild(btnSvg);
      container.appendChild(toolbar);

      const dotContainer = document.createElement("div");
      dotContainer.className = "flex items-center justify-center w-full bg-gray-50/50 rounded-xl cursor-move overflow-hidden relative";
      dotContainer.style.height = formatDimension(payload.height);
      dotContainer.style.minHeight = "0"; // Crucial for flexbox children to allow shrinking
      dotContainer.innerHTML = `
        <div class="flex flex-col items-center space-y-2">
          <div class="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <div class="text-gray-400 font-medium text-xs tracking-wider uppercase">Initializing...</div>
        </div>
      `;
      container.appendChild(dotContainer);
      
      ctx.root.appendChild(container);

      let currentPayload = payload;

      const renderGraph = async (p) => {
        currentPayload = p;
        
        // Update container dimensions
        container.style.width = formatDimension(p.width);
        dotContainer.style.height = formatDimension(p.height);

        dotContainer.innerHTML = `
          <div class="flex flex-col items-center space-y-2">
            <div class="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
            <div class="text-gray-400 font-medium text-xs tracking-wider uppercase">Loading...</div>
          </div>
        `;

        try {
          const viz = new window.Viz();
          
          // Ensure options contains the chosen engine
          const renderOptions = p.options || {};
          if (p.engine) {
            renderOptions.engine = p.engine;
          }

          const element = await viz.renderSVGElement(p.dot_string, renderOptions);
          
          // Theme awareness
          element.querySelectorAll("[stroke='black'], [stroke='#000000']").forEach(node => node.setAttribute("stroke", "currentColor"));
          element.querySelectorAll("[fill='black'], [fill='#000000']").forEach(node => node.setAttribute("fill", "currentColor"));

          element.style.display = "block";
          element.style.width = "100%";
          element.style.height = "100%";
          element.style.maxWidth = "100%";
          element.style.maxHeight = "100%";

          const w = element.getAttribute("width");
          const h = element.getAttribute("height");
          if (!element.getAttribute("viewBox") && w && h) {
            element.setAttribute("viewBox", `0 0 ${w.replace(/pt|px|in|cm|mm/, '')} ${h.replace(/pt|px|in|cm|mm/, '')}`);
          }
          
          element.removeAttribute("width");
          element.removeAttribute("height");
          element.setAttribute("preserveAspectRatio", "xMidYMid meet");

          element.querySelectorAll("text").forEach(text => {
            text.style.fontFamily = "inherit";
            text.style.fill = "currentColor";
            text.style.fontWeight = "500";
          });

          dotContainer.innerHTML = "";
          dotContainer.appendChild(element);

          if (panZoomInstance) {
            panZoomInstance.destroy();
          }

          requestAnimationFrame(() => {
            panZoomInstance = window.svgPanZoom(element, {
              zoomEnabled: true,
              controlIconsEnabled: false,
              fit: true,
              center: true,
              minZoom: 0.05,
              maxZoom: 20,
              zoomScaleSensitivity: 0.2,
              mouseWheelZoomEnabled: true
            });
            
            setTimeout(() => {
              if (panZoomInstance) {
                panZoomInstance.resize();
                panZoomInstance.fit();
                panZoomInstance.center();
              }
            }, 100);
          });
        } catch (error) {
          const errorWrapper = document.createElement("div");
          errorWrapper.className = "p-6 bg-red-50 text-red-800 rounded-xl w-full max-w-lg shadow-sm border border-red-100";

          const errorHeader = document.createElement("div");
          errorHeader.className = "flex items-center space-x-2 mb-2";
          errorHeader.innerHTML = `<svg class="h-5 w-5 text-red-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" /></svg><p class="font-bold text-sm uppercase tracking-tight">Render Error</p>`;

          const errorPre = document.createElement("pre");
          errorPre.className = "mt-2 text-xs overflow-auto bg-white/50 p-4 rounded-lg font-mono border border-red-200/50 max-h-40";
          errorPre.textContent = error;

          errorWrapper.appendChild(errorHeader);
          errorWrapper.appendChild(errorPre);
          dotContainer.innerHTML = "";
          dotContainer.appendChild(errorWrapper);
          dotContainer.classList.remove("cursor-move");
        }
      };

      try {
        await Promise.all([loadVizJS(), loadSvgPanZoom()]);
        
        ctx.handleEvent("update", (newPayload) => {
          renderGraph(newPayload);
        });

        renderGraph(payload);
      } catch (e) {
        const loadErrorWrapper = document.createElement("div");
        loadErrorWrapper.className = "p-6 bg-amber-50 text-amber-900 rounded-xl w-full max-w-lg shadow-sm border border-amber-100";

        const loadErrorTitle = document.createElement("p");
        loadErrorTitle.className = "font-bold text-sm mb-2 uppercase tracking-tight underline";
        loadErrorTitle.textContent = "Failed to load Engine";

        const loadErrorPre = document.createElement("pre");
        loadErrorPre.className = "mt-2 text-xs overflow-auto bg-white/50 p-4 rounded-lg font-mono border border-amber-200/50";
        loadErrorPre.textContent = e;

        loadErrorWrapper.appendChild(loadErrorTitle);
        loadErrorWrapper.appendChild(loadErrorPre);
        dotContainer.innerHTML = "";
        dotContainer.appendChild(loadErrorWrapper);
        dotContainer.classList.remove("cursor-move");
      }
    }
    """
  end
end
