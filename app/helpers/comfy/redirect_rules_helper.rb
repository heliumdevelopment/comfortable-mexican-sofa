module Comfy
  module RedirectRulesHelper
    def new_or_edit_redirect_rule_path(redirect)
      if RedirectRule.exists?(redirect.id)
        comfy_redirect_rule_path(redirect)
      else
        comfy_redirect_rules_path
      end
    end
  end
end
