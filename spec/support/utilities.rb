# タイトルを返す
def full_title(page_name = "")
  base_title = "報連相システム"
  if page_name.empty?
    base_title
  else
    page_name + " | " + base_title
  end
end