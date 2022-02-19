defmodule ConnectWeb.GameLive do
  use Phoenix.LiveView

  alias Connect.Grid

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok,
       assign(socket,
         grid: Grid.make_grid(),
         player: "red"
       )}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  def render(%{page: "loading"} = assigns) do
    ~H"""
    <h1>Loading...</h1>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="game-container" id="game-container" phx-hook="Game">
      <p>Turn: <%= @player %></p>
      <div class="content">
        <%= for {row, _} <- Enum.with_index(@grid) do %>
          <div class="flex">
	   <%= for {column, index} <- Enum.with_index(row) do %>
	     <div phx-click="play" phx-value-column={index} class="flex">
               <%= if is_nil(column) do %>
                 <div class="place empty"></div>
               <% else %>
                 <div class={"place #{column}"}></div>
               <% end %>
            </div>
	  <% end %>
         </div>
       <% end %>
      </div>
    </div>
    """
  end

  def handle_event("play", %{"column" => column}, socket) do
    play(String.to_integer(column), socket)
  end

  def play(column, socket) do
    grid = socket.assigns.grid
    player = socket.assigns.player

    socket =
      case Grid.play(grid, player, column) do
        {:full_column, _current_grid} ->
          socket

        {:continue, new_grid} ->
          socket
          |> update(:grid, fn _ -> new_grid end)
          |> update(:player, fn _ -> next_player(player) end)

        {:end_game, new_grid} ->
          socket
          |> update(:grid, fn _ -> new_grid end)
          |> push_event("end-game", %{player: player})

        {:tie, new_grid} ->
          socket
          |> update(:grid, fn _ -> new_grid end)
          |> push_event("tie", %{})
      end

    {:noreply, socket}
  end

  def next_player("red"), do: "yellow"

  def next_player("yellow"), do: "red"
end
