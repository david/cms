defmodule CMS.Liturgies.LiturgyTest do
  use CMS.DataCase, async: true

  alias CMS.Liturgies.Liturgy

  import CMS.AccountsFixtures
  import CMS.LiturgiesFixtures

  setup do
    %{scope: user_scope_fixture()}
  end

  describe "template creation" do
    test "creates a template from a liturgy", %{scope: scope} do
      liturgy = liturgy_fixture(scope)
      template = Liturgy.make_template(liturgy)

      assert %Liturgy{} = template
      assert template.service_on == liturgy.service_on
      assert template.organization_id == liturgy.organization_id
      assert is_nil(template.id)

      assert length(template.blocks) == length(liturgy.blocks)

      Enum.zip(template.blocks, liturgy.blocks)
      |> Enum.each(fn {template_block, liturgy_block} ->
        assert template_block.type == liturgy_block.type

        case template_block.type do
          :text ->
            assert template_block.title == liturgy_block.title
            assert not is_nil(template_block.title)

          _ ->
            assert is_nil(template_block.title)
        end

        assert template_block.subtitle == liturgy_block.subtitle
        assert is_nil(template_block.id)
      end)
    end
  end
end
