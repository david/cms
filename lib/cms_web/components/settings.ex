defmodule CMSWeb.Settings do
  use Phoenix.Component
  import CMSWeb.CoreComponents

  attr :show, :boolean, default: false

  def drawer(assigns) do
    ~H"""
    <div
      id="settings-drawer"
      class={"fixed bottom-0 left-0 right-0 bg-base-200 p-4 pb-20 transform transition-transform duration-300 ease-in-out z-30" <> if(@show, do: " translate-y-0", else: " translate-y-full")}
    >
      <div class="flex justify-between items-center">
        <p>Definições</p>
        <button id="close-settings-drawer" class="btn btn-ghost btn-square">
          <.icon name="hero-x-mark" class="w-6 h-6" />
        </button>
      </div>
    </div>
    """
  end
end
