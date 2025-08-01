defmodule CMSWeb.LiturgyLive.Admin.Form do
  use CMSWeb, :live_view

  alias CMS.Liturgies
  alias CMS.Liturgies.Liturgy
  alias CMS.Songs

  alias CMSWeb.LiturgyComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.form for={@form} id="liturgy-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:service_on]} type="date" label={gettext("Data do culto")} />

        <datalist id="liturgy-song-blocks">
          <%= for block <- @song_blocks do %>
            <option value={block.title} />
          <% end %>
        </datalist>

        <.add_block_button />

        <.inputs_for :let={block} field={@form[:blocks]}>
          <input type="hidden" name="liturgy[blocks_sort][]" value={block.index} />

          <div class="flex flex-col">
            <fieldset class="flex flex-col">
              <input name={block[:song_id].name} type="hidden" value={block[:song_id].value} />
              <input name={block[:type].name} type="hidden" value={block[:type].value} />

              <%= case to_string(block[:type].value) do %>
                <% "text" -> %>
                  <.block_bar index={block.index} title={gettext("Texto")} />

                  <.input type="text" field={block[:title]} placeholder={gettext("título")} />
                  <.input type="text" field={block[:subtitle]} placeholder={gettext("subtítulo")} />
                  <.input
                    type="textarea"
                    field={block[:body]}
                    placeholder={gettext("corpo")}
                    rows={10}
                  />
                <% "song" -> %>
                  <.block_bar index={block.index} title={gettext("Música")} />

                  <.input
                    type="text"
                    field={block[:title]}
                    placeholder={gettext("título")}
                    list="liturgy-song-blocks"
                  />

                  <.input
                    type="textarea"
                    field={block[:body]}
                    placeholder={gettext("corpo")}
                    rows={15}
                  />
                <% "passage" -> %>
                  <.block_bar index={block.index} title={gettext("Passagem bíblica")} />

                  <.input type="text" field={block[:title]} placeholder={gettext("versículos")} />
                  <.input type="text" field={block[:subtitle]} placeholder={gettext("subtítulo")} />

                  <LiturgyComponents.verse_list verses={block[:resolved_body].value} />
              <% end %>
            </fieldset>

            <.add_block_button />
          </div>
        </.inputs_for>

        <input type="hidden" name={"#{@form[:blocks_drop].name}[]"} />

        <footer>
          <.button phx-disable-with={gettext("A guardar...")} variant="primary">
            {gettext("Guardar liturgia")}
          </.button>
          <.button navigate={return_path(@current_scope, @return_to, @liturgy)} variant="secondary">
            {gettext("Cancelar")}
          </.button>
        </footer>
      </.form>
    </.main_layout>
    """
  end

  attr :index, :string, doc: "Block index"
  attr :title, :string, doc: "Block title"

  defp block_bar(assigns) do
    ~H"""
    <div class="flex justify-between items-center">
      <span>{@title}</span>
      <button
        type="button"
        name="liturgy[blocks_drop][]"
        value={@index}
        phx-click={JS.dispatch("change")}
      >
        <.icon name="hero-x-mark" class="w-6 h-6" />
      </button>
    </div>
    """
  end

  defp add_block_button(assigns) do
    ~H"""
    <div class="flex justify-center join">
      <.button
        type="button"
        class="join-item"
        name="liturgy[blocks_sort][]"
        value="new-text"
        phx-click={JS.dispatch("change")}
        variant="secondary"
      >
        {gettext("+ texto")}
      </.button>
      <.button
        type="button"
        class="join-item"
        name="liturgy[blocks_sort][]"
        value="new-song"
        phx-click={JS.dispatch("change")}
        variant="secondary"
      >
        {gettext("+ música")}
      </.button>
      <.button
        type="button"
        class="join-item"
        name="liturgy[blocks_sort][]"
        value="new-passage"
        phx-click={JS.dispatch("change")}
        variant="secondary"
      >
        {gettext("+ passagem")}
      </.button>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(
       :song_blocks,
       Songs.list_songs(socket.assigns.current_scope)
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    liturgy = Liturgies.get_liturgy!(socket.assigns.current_scope, id)

    form =
      socket.assigns.current_scope
      |> Liturgies.change_liturgy(liturgy)
      |> to_form()

    socket
    |> assign(:page_title, "Editar ordem de culto")
    |> assign(:liturgy, liturgy)
    |> assign(:form, form)
  end

  defp apply_action(socket, :new, %{"tid" => template_id}) when not is_nil(template_id) do
    liturgy = Liturgies.get_copy!(socket.assigns.current_scope, template_id)

    form =
      socket.assigns.current_scope
      |> Liturgies.change_liturgy(liturgy)
      |> to_form()

    socket
    |> assign(:page_title, gettext("Nova liturgia"))
    |> assign(:liturgy, liturgy)
    |> assign(:form, form)
  end

  defp apply_action(socket, :new, _params) do
    liturgy = Liturgy.new()

    form =
      socket.assigns.current_scope
      |> Liturgies.change_liturgy(liturgy)
      |> to_form()

    socket
    |> assign(:page_title, gettext("Nova liturgia"))
    |> assign(:liturgy, liturgy)
    |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"liturgy" => liturgy_params}, socket) do
    changeset =
      Liturgies.change_liturgy(
        socket.assigns.current_scope,
        socket.assigns.liturgy,
        liturgy_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"liturgy" => liturgy_params}, socket) do
    save_liturgy(socket, socket.assigns.live_action, liturgy_params)
  end

  defp save_liturgy(socket, :edit, liturgy_params) do
    case Liturgies.update_liturgy(
           socket.assigns.current_scope,
           socket.assigns.liturgy,
           liturgy_params
         ) do
      {:ok, liturgy} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Liturgia atualizada com sucesso."))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, liturgy)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_liturgy(socket, :new, liturgy_params) do
    case Liturgies.create_liturgy(socket.assigns.current_scope, liturgy_params) do
      {:ok, liturgy} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Liturgia criada com sucesso."))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, liturgy)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _liturgy), do: ~p"/admin/liturgies"
  defp return_path(_scope, "show", liturgy), do: ~p"/liturgies/#{liturgy}"
end
