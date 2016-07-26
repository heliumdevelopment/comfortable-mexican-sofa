module PhrasingHelper
  def can_edit_phrases?
    current_comfy_user?
  end
end
