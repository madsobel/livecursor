defmodule CursorWeb.Live.Cursor do
  use CursorWeb, :live_view

  alias Cursor.Presence
  alias Cursor.PubSub
  alias Phoenix.Socket.Broadcast

  @presence "cursor"
  @colors ["bg-red-500", "bg-green-500", "bg-blue-500", "bg-yellow-500", "bg-indigo-500", "bg-purple-500", "bg-pink-500", "bg-orange-500", "bg-teal-500", "bg-cyan-500", "bg-fuchsia-500", "bg-lime-500", "bg-gray-500", "bg-emerald-500", "bg-sky-500", "bg-black-500", "bg-amber-500"]

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-screen h-screen relative" id="cursor_wrapper" phx-hook="Cursor">
      <canvas id="cursor_canvas" class="w-full h-full"></canvas>
      <%= for {cursor, index} <- @cursors |> Map.values() |> Enum.with_index() do %>
        <%= render_cursor(cursor, index) %>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Presence.track(self(), @presence, inspect(self()), %{})
      Phoenix.PubSub.subscribe(PubSub, @presence)
    end

    {:ok,
      socket
      |> assign(:cursors, %{})
      |> handle_joins(Presence.list(@presence))
    }
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply,
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    }
  end

  @impl true
  def handle_info({"cursor_position", pid, cursor}, socket) do
    {:noreply,
      socket
      |> assign(:cursors, Map.put(socket.assigns.cursors, pid, cursor))
    }
  end

  @impl true
  def handle_event("cursor_position", %{"x" => x, "y" => y}, socket) do
    pid = inspect(self())
    cursor =
      socket.assigns.cursors
      |> Map.get(pid)
      |> Map.put(:x, x)
      |> Map.put(:y, y)

    Phoenix.PubSub.broadcast(PubSub, @presence, {"cursor_position", pid, cursor})

    {:noreply, socket}
  end

  defp handle_joins(socket, joins) do
    Enum.reduce joins, socket, fn {cursor, %{metas: [meta| _]}}, socket ->
      cursor_data =
        meta
        |> Map.put(:x, 0)
        |> Map.put(:y, 0)

      assign(socket, :cursors, Map.put(socket.assigns.cursors, cursor, cursor_data))
    end
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce leaves, socket, fn {cursor, _}, socket ->
      assign(socket, :cursors, Map.delete(socket.assigns.cursors, cursor))
    end
  end

  defp render_cursor(assigns, index) do
    background_color = Enum.at(@colors, index)

    ~H"""
    <span class={"block h-8 w-8 rounded-full #{background_color} absolute"} style={"left: #{@x}px; top: #{@y}px;"}></span>
    """
  end
end
