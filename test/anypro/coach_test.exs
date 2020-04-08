defmodule AnyproWeb.CoachModelTest do
  use AnyproWeb.ConnCase

  alias Anypro.Coach

  test "should slugify coach name" do
      title = "Adam Brown Jr."
      assert Coach.slugified_name(title) == "adam-brown-jr"
  end
end
