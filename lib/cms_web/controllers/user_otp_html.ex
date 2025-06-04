defmodule CMSWeb.UserOTPHTML do
  use CMSWeb, :html
  # Added to make <.flash_group ... /> available
  import CMSWeb.Layouts

  embed_templates "user_otp_controller/*"
end
