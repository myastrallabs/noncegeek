defmodule NoncegeekWeb.PageLive do
  @moduledoc false

  use NoncegeekWeb, :live_view

  @impl true
  def mount(_, session, socket) do
    {:ok,
     socket
     |> assign_new(:current_user, fn -> Map.get(session, "current_user") end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    socket
  end

  @impl true
  def handle_event("mint", _, socket) do
    {:noreply, push_event(socket, "mint", %{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section id="page" class="relative md:pt-48 pt-36 overflow-hidden" phx-hook="Wallet">
      <div class="container">
        <div class="grid grid-cols-1 justify-center text-center mt-10">
          <div class="relative">
            <div class="relative mb-5">
              <h1 class="font-bold lg:leading-snug leading-snug text-4xl lg:text-6xl">NonceGeek NFT Published</h1>
            </div>
            <p class="text-slate-400 dark:text-white/70 text-lg max-w-xl mx-auto">我爱北京天安门，我爱北京天安门， 我爱北京天安门， 我爱北京天安门，我爱北京天安门， 我爱北京天安门， 我爱北京天安门。</p>

            <div class="mt-8">
              <%= if @current_user do %>
              <button phx-click="mint" class="py-2 px-5 inline-block tracking-wide border align-middle transition duration-500 ease-in-out text-base text-center; text-white font-bold rounded-lg p-2 bg-blue-500">
                Mint NFT
              </button>
              <% else %>
              <button
                class="text-white bg-blue-600 font-bold hover:bg-blue-700 rounded-lg p-2 dark:text-white"
                phx-click={show_wallet_modal()}
              >
                + Connect Wallet
              </button>
            <% end %>
            </div>
          </div>
        </div>

      </div>
    </section>
    """
  end
end
