defmodule Kino.VizJS.SmartCell do
  @moduledoc false

  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "VizJS Render DOT"

  @impl true
  def init(attrs, ctx) do
    dot_string = attrs["dot_string"] || "digraph G {\n  Hello -> World\n}"
    engine = attrs["engine"] || "dot"
    height = attrs["height"] || "300px"
    width = attrs["width"] || "100%"

    ctx =
      assign(ctx,
        dot_string: dot_string,
        engine: engine,
        height: height,
        width: width
      )

    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    payload = %{
      dot_string: ctx.assigns.dot_string,
      engine: ctx.assigns.engine,
      height: ctx.assigns.height,
      width: ctx.assigns.width
    }

    {:ok, payload, ctx}
  end

  @impl true
  def handle_event(
        "update",
        %{"dot_string" => dot_string, "engine" => engine, "height" => height, "width" => width},
        ctx
      ) do
    ctx = assign(ctx, dot_string: dot_string, engine: engine, height: height, width: width)

    broadcast_event(ctx, "update", %{
      dot_string: dot_string,
      engine: engine,
      height: height,
      width: width
    })

    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "dot_string" => ctx.assigns.dot_string,
      "engine" => ctx.assigns.engine,
      "height" => ctx.assigns.height,
      "width" => ctx.assigns.width
    }
  end

  @defaults %{"engine" => "dot", "height" => "300px", "width" => "100%"}

  @impl true
  def to_source(attrs) do
    dot_string = attrs["dot_string"] |> String.trim()

    options =
      [{"engine", :engine}, {"height", :height}, {"width", :width}]
      |> Enum.reject(fn {key, _atom} -> attrs[key] == @defaults[key] end)
      |> Enum.map(fn {key, atom} -> {atom, attrs[key]} end)

    case options do
      [] ->
        "Kino.VizJS.render(#{inspect(dot_string)})"

      opts ->
        "Kino.VizJS.render(#{inspect(dot_string)}, #{inspect(opts) |> String.slice(1..-2//1)})"
    end
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
      root.className = "flex flex-col rounded-2xl border border-indigo-100 bg-white shadow-xl overflow-hidden font-sans";
      
      const engineIcon = `<svg class="h-4 w-4 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>`;
      const heightIcon = `<svg class="h-4 w-4 text-pink-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"></path></svg>`;
      const widthIcon = `<svg class="h-4 w-4 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4-4m-4 4l4 4"></path></svg>`;
      const codeIcon = `<svg class="h-4 w-4 text-sky-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path></svg>`;

      root.innerHTML = `
        <!-- Dashboard Header -->
        <div class="flex flex-wrap items-center gap-6 p-4 bg-gradient-to-r from-indigo-50 to-white border-b border-indigo-100">
          <div class="flex flex-col space-y-1">
            <label class="flex items-center space-x-1.5 text-[9px] font-black text-indigo-400 uppercase tracking-widest">
              ${engineIcon}
              <span>Layout Engine</span>
            </label>
            <select id="engine-select" class="block w-36 h-8 pl-2 pr-8 text-xs font-semibold border-indigo-200 outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 rounded-lg shadow-sm transition-all duration-200 bg-white">
              ${["dot", "circo", "neato", "fdp", "twopi", "osage"].map(e => 
                `<option value="${e}" ${e === payload.engine ? "selected" : ""}>${e}</option>`
              ).join('')}
            </select>
          </div>
          
          <div class="flex items-center space-x-4">
            <div class="flex flex-col space-y-1">
              <label class="flex items-center space-x-1.5 text-[9px] font-black text-pink-400 uppercase tracking-widest">
                ${heightIcon}
                <span>Height</span>
              </label>
              <input id="height-input" type="text" value="${payload.height}" class="block w-24 h-8 px-2 text-xs font-semibold border-pink-200 outline-none focus:ring-1 focus:ring-pink-500 focus:border-pink-500 rounded-lg shadow-sm transition-all duration-200 bg-white" />
            </div>
            
            <div class="flex flex-col space-y-1">
              <label class="flex items-center space-x-1.5 text-[9px] font-black text-emerald-400 uppercase tracking-widest">
                ${widthIcon}
                <span>Width</span>
              </label>
              <input id="width-input" type="text" value="${payload.width}" class="block w-24 h-8 px-2 text-xs font-semibold border-emerald-200 outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 rounded-lg shadow-sm transition-all duration-200 bg-white" />
            </div>
          </div>
        </div>

        <!-- Editor Surface -->
        <div class="flex flex-col flex-1 relative" style="background-color: #0b0e14;">
          <textarea id="dot-textarea" spellcheck="false" class="block w-full min-h-[450px] p-8 text-[13px] font-mono focus:outline-none resize-y shadow-inner transition-colors duration-200 selection:bg-indigo-500/30" style="tab-size: 2; line-height: 1.6; background-color: #0b0e14; color: #e0e7ff; border: none;">${payload.dot_string}</textarea>
          
          <div class="absolute bottom-4 right-6 pointer-events-none opacity-20">
             <div class="text-[40px] font-black text-indigo-500/20 tracking-tighter select-none">Viz.js</div>
          </div>
        </div>
      `;

      ctx.root.appendChild(root);

      const textarea = document.getElementById("dot-textarea");
      const select = document.getElementById("engine-select");
      const heightInput = document.getElementById("height-input");
      const widthInput = document.getElementById("width-input");

      const handleUpdate = () => {
        ctx.pushEvent("update", {
          dot_string: textarea.value,
          engine: select.value,
          height: heightInput.value,
          width: widthInput.value
        });
      };

      textarea.addEventListener("input", debounce(handleUpdate, 300));
      select.addEventListener("change", handleUpdate);
      heightInput.addEventListener("input", debounce(handleUpdate, 300));
      widthInput.addEventListener("input", debounce(handleUpdate, 300));

      // Handle Tab key in textarea
      textarea.addEventListener("keydown", (e) => {
        if (e.key === "Tab") {
          e.preventDefault();
          const start = textarea.selectionStart;
          const end = textarea.selectionEnd;
          textarea.value = textarea.value.substring(0, start) + "  " + textarea.value.substring(end);
          textarea.selectionStart = textarea.selectionEnd = start + 2;
          handleUpdate();
        }
      });

      ctx.handleEvent("update", ({ dot_string, engine, height, width }) => {
        if (dot_string !== textarea.value) textarea.value = dot_string;
        select.value = engine;
        heightInput.value = height;
        widthInput.value = width;
      });

      ctx.handleSync(() => {
        handleUpdate();
      });
    }
    """
  end
end
