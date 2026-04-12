defmodule KinoVizjsTest do
  use ExUnit.Case

  alias Kino.VizJS.SmartCell

  describe "Kino.VizJS.render/2" do
    test "returns a Kino.JS struct with default options" do
      dot_string = "digraph { A -> B }"
      kino = Kino.VizJS.render(dot_string)

      assert %Kino.JS{module: Kino.VizJS} = kino
    end

    test "accepts and passes options explicitly" do
      dot_string = "digraph { A -> B }"
      kino = Kino.VizJS.render(dot_string, engine: "fdp")

      assert %Kino.JS{module: Kino.VizJS} = kino
    end
  end

  describe "SmartCell.to_source/1" do
    test "generates valid source for simple DOT string" do
      attrs = %{"dot_string" => "digraph { A -> B }", "engine" => "dot"}

      assert SmartCell.to_source(attrs) ==
               ~s|Kino.VizJS.render("digraph { A -> B }", engine: "dot")|
    end

    test "trims DOT string before generating source" do
      attrs = %{"dot_string" => "  digraph { A -> B }  ", "engine" => "neato"}

      assert SmartCell.to_source(attrs) ==
               ~s|Kino.VizJS.render("digraph { A -> B }", engine: "neato")|
    end

    test "escapes triple quotes safely via inspect" do
      attrs = %{"dot_string" => ~s|label = """test"""|, "engine" => "dot"}

      source = SmartCell.to_source(attrs)
      assert source =~ ~s|Kino.VizJS.render(|
      assert source =~ ~s|, engine: "dot")|
      # verify it's valid elixir by trying to parse it
      assert {:ok, _} = Code.string_to_quoted(source)
    end
  end
end
