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

    test "raises FunctionClauseError for non-binary input" do
      assert_raise FunctionClauseError, fn ->
        Kino.VizJS.render(nil)
      end

      assert_raise FunctionClauseError, fn ->
        Kino.VizJS.render(42)
      end

      assert_raise FunctionClauseError, fn ->
        Kino.VizJS.render([:not, :a, :string])
      end
    end

    test "raises ArgumentError for invalid engine" do
      assert_raise ArgumentError, ~r/invalid engine/, fn ->
        Kino.VizJS.render("digraph { A -> B }", engine: "potato")
      end
    end

    test "raises ArgumentError for unknown option keys" do
      assert_raise ArgumentError, fn ->
        Kino.VizJS.render("digraph { A -> B }", bogus: true)
      end
    end

    test "accepts all valid engines" do
      for engine <- ~w(dot circo neato fdp twopi osage) do
        kino = Kino.VizJS.render("digraph { A -> B }", engine: engine)
        assert %Kino.JS{module: Kino.VizJS} = kino
      end
    end

    test "accepts integer dimensions" do
      kino = Kino.VizJS.render("digraph { A -> B }", height: 500, width: 800)
      assert %Kino.JS{module: Kino.VizJS} = kino
    end
  end

  describe "SmartCell.to_source/1" do
    test "generates source with only engine when height and width are defaults" do
      attrs = %{
        "dot_string" => "digraph { A -> B }",
        "engine" => "neato",
        "height" => "300px",
        "width" => "100%"
      }

      assert SmartCell.to_source(attrs) ==
               ~s|Kino.VizJS.render("digraph { A -> B }", engine: "neato")|
    end

    test "omits all options when everything is default" do
      attrs = %{
        "dot_string" => "digraph { A -> B }",
        "engine" => "dot",
        "height" => "300px",
        "width" => "100%"
      }

      assert SmartCell.to_source(attrs) ==
               ~s|Kino.VizJS.render("digraph { A -> B }")|
    end

    test "includes non-default height and width" do
      attrs = %{
        "dot_string" => "digraph { A -> B }",
        "engine" => "dot",
        "height" => "600px",
        "width" => "50%"
      }

      source = SmartCell.to_source(attrs)
      assert source =~ ~s|height: "600px"|
      assert source =~ ~s|width: "50%"|
      refute source =~ ~s|engine:|
    end

    test "includes all non-default options" do
      attrs = %{
        "dot_string" => "digraph { A -> B }",
        "engine" => "circo",
        "height" => "500px",
        "width" => "80%"
      }

      source = SmartCell.to_source(attrs)
      assert source =~ ~s|engine: "circo"|
      assert source =~ ~s|height: "500px"|
      assert source =~ ~s|width: "80%"|
    end

    test "trims DOT string before generating source" do
      attrs = %{
        "dot_string" => "  digraph { A -> B }  ",
        "engine" => "neato",
        "height" => "300px",
        "width" => "100%"
      }

      assert SmartCell.to_source(attrs) ==
               ~s|Kino.VizJS.render("digraph { A -> B }", engine: "neato")|
    end

    test "escapes triple quotes safely via inspect" do
      attrs = %{
        "dot_string" => ~s|label = """test"""|,
        "engine" => "dot",
        "height" => "300px",
        "width" => "100%"
      }

      source = SmartCell.to_source(attrs)
      assert source =~ ~s|Kino.VizJS.render(|
      # verify it's valid elixir by trying to parse it
      assert {:ok, _} = Code.string_to_quoted(source)
    end

    test "handles multiline DOT strings" do
      dot = "digraph G {\n  A -> B\n  B -> C\n}"
      attrs = %{"dot_string" => dot, "engine" => "dot", "height" => "300px", "width" => "100%"}

      source = SmartCell.to_source(attrs)
      assert {:ok, _} = Code.string_to_quoted(source)
    end
  end
end
