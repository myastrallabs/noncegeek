defmodule NoncegeekWeb.ProfileLive do
  @moduledoc false

  use NoncegeekWeb, :live_view

  alias Noncegeek.Explorer

  @impl true
  def mount(_, session, socket) do
    {:ok,
     socket
     |> assign_new(:entries, fn -> [] end)
     |> assign_new(:current_user, fn -> Map.get(session, "current_user") end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    %{assigns: %{current_user: %{address: address}}} = socket

    Explorer.refresh_account_events(address)

    with {:ok, entries} <- Explorer.list_account_tokens(address) do
      socket
      |> assign(entries: entries)
    else
      _ -> socket
    end
  end

  @impl true
  def handle_event("refresh", _, socket) do
    %{assigns: %{current_user: %{address: address}}} = socket
    {:ok, entries} = Explorer.refresh_account_events(address)
    {:noreply, socket |> assign(entries: entries)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="relative md:py-24 py-16">
      <div class="container">
        <button phx-click="refresh" class="py-2 px-5 inline-block tracking-wide border align-middle transition duration-500 ease-in-out text-base text-center; text-white font-bold rounded-lg p-2 bg-blue-500"> Refresh</button>
      </div>
      <div class="grid lg:grid-cols-6 grid-cols-1 gap-[30px] mt-2">
        <%= for entry <- @entries do %>
        <div
          class="group relative p-2 rounded-lg bg-white dark:bg-slate-900 border border-gray-100 dark:border-gray-800 hover:shadow-md dark:shadow-md hover:dark:shadow-gray-700 transition-all duration-500 h-fit">
          <div class="relative overflow-hidden">
            <div class="relative overflow-hidden rounded-lg">
              <img src={entry.token.uri}
                class="rounded-lg shadow-md dark:shadow-gray-700 group-hover:scale-110 transition-all duration-500"
                alt="">
            </div>
          </div>

            <div class="my-3">
              <span class="font-semibold hover:text-violet-600"><%= entry.token.name %></span>
            </div>
        </div>
        <% end %>
      </div>
    </section>
    """
  end
end
