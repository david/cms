defmodule CMSWeb.LiturgyLive.Form do
  use CMSWeb, :live_view

  alias CMS.Bibles
  alias CMS.Liturgies
  alias CMS.Liturgies.Liturgy

  alias CMSWeb.LiturgyComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage liturgy records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="liturgy-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:service_on]} type="date" label="Service on" />

        <datalist id="liturgy-song-blocks">
          <%= for block <- @song_blocks do %>
            <option value={block.title} />
          <% end %>
        </datalist>

        <.add_block_button />

        <.inputs_for :let={block} field={@form[:liturgy_blocks]}>
          <input type="hidden" name="liturgy[liturgy_blocks_sort][]" value={block.index} />

          <div class="flex flex-col">
            <fieldset class="flex flex-col">
              <input name={block[:block_id].name} type="hidden" value={block[:block_id].value} />
              <input name={block[:type].name} type="hidden" value={block[:type].value} />

              <%= case to_string(block[:type].value) do %>
                <% "text" -> %>
                  <.block_bar index={block.index} title="Text" />

                  <.input type="text" field={block[:title]} placeholder="title" />
                  <.input type="text" field={block[:subtitle]} placeholder="subtitle" />
                  <.input type="textarea" field={block[:body]} placeholder="body" rows={10} />
                <% "song" -> %>
                  <.block_bar index={block.index} title="Song" />

                  <.input
                    type="text"
                    field={block[:title]}
                    placeholder="title"
                    list="liturgy-song-blocks"
                  />

                  <.input type="textarea" field={block[:body]} placeholder="body" rows={15} />
                <% "passage" -> %>
                  <.block_bar index={block.index} title="Bible passage" />

                  <.input type="text" field={block[:subtitle]} placeholder="subtitle" />
                  <.input type="text" field={block[:title]} placeholder="verses" />

                  <LiturgyComponents.verse_list verses={block[:body].value} />
              <% end %>
            </fieldset>

            <.add_block_button />
          </div>
        </.inputs_for>

        <input type="hidden" name={"#{@form[:liturgy_blocks_drop].name}[]"} />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Liturgy</.button>
          <.button navigate={return_path(@current_scope, @return_to, @liturgy)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
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
        name="liturgy[liturgy_blocks_drop][]"
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
      <button
        type="button"
        class="btn btn-outline btn-primary join-item"
        name="liturgy[liturgy_blocks_sort][]"
        value="new-text"
        phx-click={JS.dispatch("change")}
      >
        + text
      </button>
      <button
        type="button"
        class="btn btn-outline btn-primary join-item"
        name="liturgy[liturgy_blocks_sort][]"
        value="new-song"
        phx-click={JS.dispatch("change")}
      >
        + song
      </button>
      <button
        type="button"
        class="btn btn-outline btn-primary join-item"
        name="liturgy[liturgy_blocks_sort][]"
        value="new-passage"
        phx-click={JS.dispatch("change")}
      >
        + passage
      </button>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:song_blocks, Liturgies.list_songs(socket.assigns.current_scope))
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
    |> assign(:page_title, "Edit Liturgy")
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
    |> assign(:page_title, "New Liturgy")
    |> assign(:liturgy, liturgy)
    |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"liturgy" => liturgy_params}, socket) do
    changeset =
      Liturgies.change_liturgy(
        socket.assigns.current_scope,
        socket.assigns.liturgy,
        normalize_params(liturgy_params, %{blocks: socket.assigns.song_blocks})
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
         |> put_flash(:info, "Liturgy updated successfully")
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
         |> put_flash(:info, "Liturgy created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, liturgy)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _liturgy), do: ~p"/liturgies"
  defp return_path(_scope, "show", liturgy), do: ~p"/liturgies/#{liturgy}"

  defp normalize_params(%{"liturgy_blocks" => _liturgy_blocks} = params, %{blocks: blocks}),
    do: update_in(params, ["liturgy_blocks"], &normalize_blocks(&1, blocks))

  defp normalize_params(params, _cache), do: params

  defp normalize_blocks(blocks_attrs, blocks) do
    blocks_attrs
    |> Enum.map(&(&1 |> match_block(blocks) |> normalize_block()))
    |> Enum.into(%{})
  end

  defp match_block({key, %{"title" => title} = block}, cached_blocks),
    do: {key, block, Enum.find(cached_blocks, &(&1.title == title))}

  defp normalize_block({key, %{"type" => type} = block_attrs, nil})
       when type in ["passage", :passage] do
    {key, Map.put(block_attrs, "body", Bibles.get_verses(block_attrs["title"]))}
  end

  defp normalize_block({key, block_attrs, nil}), do: {key, block_attrs}

  defp normalize_block({key, block_attrs, block}),
    do: {key, Map.merge(block_attrs, %{"block_id" => block.id, "body" => block.body})}
end
