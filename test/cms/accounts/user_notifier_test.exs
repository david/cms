defmodule CMS.Accounts.UserNotifierTest do
  use CMSWeb.ConnCase, async: true

  import CMS.AccountsFixtures
  import Swoosh.TestAssertions

  alias CMS.Accounts.UserNotifier

  test "deliver_invitation_instructions/3 sends the correct email" do
    unconfirmed_user = unconfirmed_user_fixture(%{}, organization_fixture())
    url = "http://localhost:4002/users/lobby"
    otp = "123456"

    UserNotifier.deliver_invitation_instructions(unconfirmed_user, otp, url)

    assert_email_sent(fn email ->
      assert email.to == [{unconfirmed_user.name, unconfirmed_user.email}]
      assert email.subject == "Seu convite de acesso"
      assert email.text_body =~ "Olá #{unconfirmed_user.email}"
      assert email.text_body =~ url
      assert email.text_body =~ otp
    end)
  end
end
