module ApplicationHelper
  def active_tab_class(path)
    current_page?(path) ? 'tab_active' : ''
  end
end
