defmodule Kino.VizJS.SmartCell do
  @moduledoc false

  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "VizJS Render DOT"

  @impl true
  def init(attrs, ctx) do
    dot_string = attrs["dot_string"] || "digraph G {\n  Hello -> World\n}"
    engine = attrs["engine"] || "dot"

    ctx =
      assign(ctx,
        dot_string: dot_string,
        engine: engine
      )

    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{dot_string: ctx.assigns.dot_string, engine: ctx.assigns.engine}, ctx}
  end

  @impl true
  def handle_event("update", %{"dot_string" => dot_string, "engine" => engine}, ctx) do
    ctx = assign(ctx, dot_string: dot_string, engine: engine)
    broadcast_event(ctx, "update", %{dot_string: dot_string, engine: engine})
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "dot_string" => ctx.assigns.dot_string,
      "engine" => ctx.assigns.engine
    }
  end

  @impl true
  def to_source(attrs) do
    dot_string = attrs["dot_string"] |> String.trim()
    engine = attrs["engine"]

    "Kino.VizJS.render(#{inspect(dot_string)}, engine: #{inspect(engine)})"
  end

  asset "main.js" do
    """
    function debounce(fn, ms) {
      let timeout;
      return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), ms);
      };
    }

    export function init(ctx, payload) {
      ctx.importCSS("https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css");

      const root = document.createElement("div");
      root.className = "p-4 space-y-4 rounded-lg border bg-white shadow-sm";
      root.innerHTML = `
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Layout Engine</label>
          <select id="engine-select" class="block w-full max-w-xs border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
            ${["dot", "circo", "neato", "fdp", "sfdp", "twopi", "osage", "patchwork"].map(e => 
              `<option value="${e}" ${e === payload.engine ? "selected" : ""}>${e}</option>`
            ).join('')}
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">DOT String</label>
          <textarea id="dot-textarea" rows="8" class="block w-full font-mono text-sm border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">${payload.dot_string}</textarea>
        </div>
      `;

      ctx.root.appendChild(root);

      const textarea = document.getElementById("dot-textarea");
      const select = document.getElementById("engine-select");

      const handleUpdate = () => {
        ctx.pushEvent("update", {
          dot_string: textarea.value,
          engine: select.value
        });
      };

      textarea.addEventListener("input", debounce(handleUpdate, 300));
      select.addEventListener("change", handleUpdate);

      ctx.handleEvent("update", ({ dot_string, engine }) => {
        textarea.value = dot_string;
        select.value = engine;
      });

      ctx.handleSync(() => {
        // Sync before save
        ctx.pushEvent("update", {
          dot_string: textarea.value,
          engine: select.value
        });
      });
    }
    """
  end
end
