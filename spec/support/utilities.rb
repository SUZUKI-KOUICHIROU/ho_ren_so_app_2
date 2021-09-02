# タイトルを返す
def full_title(page_name = '')
  base_title = 'Ho_Ren_So_App'
  if page_name.empty?
    base_title
  else
    "#{page_name} | #{base_title}"
  end
end
