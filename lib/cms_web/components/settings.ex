defmodule CMSWeb.Settings do
  use Phoenix.Component
  import CMSWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :show, :boolean, default: false

  def drawer(assigns) do
    ~H"""
    <div
      id="settings-drawer"
      class={"print:hidden fixed bottom-0 left-0 right-0 bg-base-200 p-4 pb-20 transform transition-transform duration-300 ease-in-out z-30" <> if(@show, do: " translate-y-0", else: " translate-y-full")}
    >
      <div class="flex justify-between items-center">
        <p>Definições</p>
        <button id="close-settings-drawer" class="btn btn-ghost btn-square">
          <.icon name="hero-x-mark" class="w-6 h-6" />
        </button>
      </div>
      <div class="flex flex-row items-center my-6 gap-2">
        <div class="flex flex-row flex-grow join join-horizontal items-center gap-2">
          <.button
            id="liturgy-decrease-font-size"
            aria-label="Decrease font size"
            class="join-item flex-1"
            variant="secondary"
          >
            <.icon name="hero-magnifying-glass-minus" class="size-5" />
          </.button>
          <.button
            id="liturgy-increase-font-size"
            aria-label="Increase font size"
            class="join-item flex-1"
            variant="secondary"
          >
            <.icon name="hero-magnifying-glass-plus" class="size-5" />
          </.button>
        </div>
        <div class="relative flex-0 flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full p-0 w-full gap-0 mx-2">
          <div class="absolute w-[33%] h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-[33%] [[data-theme=dark]_&]:left-[66%] transition-[left]" />
          <button
            phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
            class="flex p-2"
          >
            <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
          </button>
          <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})} class="flex p-2">
            <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
          </button>
          <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})} class="flex p-2">
            <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
          </button>
        </div>
      </div>
    </div>
    """
  end
end
