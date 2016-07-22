module Comfy
  module UsersHelper
    def gravatar(user, size="small")
      default_path = "assets/user.svg"
      image_tag(user.gravatar_url(default: "mm"), class: "gravatar #{size}")
    end

    def user_type_select(user)
      select("user", "account_type", User::TYPES,
                     :selected => user.account_type)
    end
  end
end
