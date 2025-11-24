module ApplicationHelper
  # Return a title on a per-page basis
  def full_title(page_title)
    base_title = "Football Pool Mania"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  # Set the alert levels for styling
  def flash_class(level)
    case level
    when "notice" then "alert alert-warning alert-dismissible"
    when "info" then "alert alert-info alert-dismissible"
    when "success" then "alert alert-success alert-dismissible"
    when "danger" then "alert alert-danger alert-dismissible"
    when "alert" then "alert alert-danger alert-dismissible"
    end
  end
end
