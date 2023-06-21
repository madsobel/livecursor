defmodule CursorWeb.ErrorJSONTest do
  use CursorWeb.ConnCase, async: true

  test "renders 404" do
    assert CursorWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert CursorWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
