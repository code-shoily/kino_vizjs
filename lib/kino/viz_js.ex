defmodule Kino.VizJS do
  @moduledoc """
  A Kino component for rendering GraphViz variables (DOT strings) via Viz.js.
  """

  use Kino.JS

  @doc """
  Creates a new Kino component to render the given DOT string using Viz.js.

  ## Options

    * `:engine` - The GraphViz engine to use (e.g. "dot", "circo", "neato", "fdp", "sfdp", "twopi", "osage", "patchwork"). Defaults to `"dot"`.
  """
  def render(dot_string, options \\ []) do
    Kino.JS.new(__MODULE__, %{
      dot_string: dot_string,
      options: Enum.into(options, %{})
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

      const dotContainer = document.createElement("div");
      dotContainer.className = "flex items-center justify-center min-h-[150px] rounded shadow p-4";
      dotContainer.innerHTML = `<div class="text-gray-500 animate-pulse">Rendering graph...</div>`;
      ctx.root.appendChild(dotContainer);

      try {
        await loadVizJS();
        const viz = new window.Viz();

        viz.renderSVGElement(payload.dot_string, payload.options)
          .then((element) => {
            // Theme awareness: Replace default black with currentColor
            element.querySelectorAll("[stroke='black'], [stroke='#000000']").forEach(node => node.setAttribute("stroke", "currentColor"));
            element.querySelectorAll("[fill='black'], [fill='#000000']").forEach(node => node.setAttribute("fill", "currentColor"));

            element.style.maxWidth = "100%";
            element.style.height = "auto";

            // Adjust label text
            element.querySelectorAll("text").forEach(text => {
              text.style.fontFamily = "inherit";
              text.style.fill = "currentColor";
            });

            dotContainer.innerHTML = "";
            dotContainer.appendChild(element);
          })
          .catch((error) => {
            dotContainer.innerHTML = `
              <div class="p-4 bg-red-50 text-red-800 rounded w-full">
                <p class="font-bold">GraphViz rendered with error:</p>
                <pre class="mt-2 text-xs overflow-auto bg-red-100 p-2 rounded">${error}</pre>
              </div>
            `;
          });
      } catch (e) {
        dotContainer.innerHTML = `
          <div class="p-4 bg-red-50 text-red-800 rounded w-full">
            <p class="font-bold">Failed to load Viz.js:</p>
            <pre class="mt-2 text-xs overflow-auto bg-red-100 p-2 rounded">${e}</pre>
          </div>
        `;
      }
    }
    """
  end
end
