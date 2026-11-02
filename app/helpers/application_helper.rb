module ApplicationHelper
  def sidebar_link(label, path, icon_path)
    active = current_page?(path)
    css = if active
            "group flex items-center px-3 py-2 text-sm font-medium rounded-md bg-slate-900 text-white"
    else
            "group flex items-center px-3 py-2 text-sm font-medium rounded-md text-slate-300 hover:bg-slate-700 hover:text-white transition-colors"
    end

    link_to path, class: css do
      content_tag(:svg, content_tag(:path, "", 'stroke-linecap': "round", 'stroke-linejoin': "round", 'stroke-width': "2", d: icon_path),
        class: "mr-3 h-5 w-5 flex-shrink-0 #{active ? 'text-white' : 'text-slate-400 group-hover:text-slate-300'}",
        fill: "none", viewBox: "0 0 24 24", stroke: "currentColor", xmlns: "http://www.w3.org/2000/svg") +
      content_tag(:span, label)
    end
  end

  def status_badge(status, type = :default)
    colors = case status.to_s
    when "draft", "open" then "bg-gray-100 text-gray-800"
    when "completed", "sent" then "bg-blue-100 text-blue-800"
    when "filed" then "bg-indigo-100 text-indigo-800"
    when "approved", "active" then "bg-green-100 text-green-800"
    when "overdue", "closed" then "bg-red-100 text-red-800"
    when "suspended" then "bg-yellow-100 text-yellow-800"
    when "received" then "bg-purple-100 text-purple-800"
    else "bg-gray-100 text-gray-800"
    end

    # Try to find translation in various enum paths with fallback
    label = I18n.t("activerecord.enums.beneficiary.status.#{status}",
                   default: I18n.t("activerecord.enums.report.status.#{status}",
                   default: I18n.t("activerecord.enums.deadline.status.#{status}",
                   default: I18n.t("activerecord.enums.communication.status.#{status}",
                   default: status.to_s.humanize))))

    content_tag(:span, label, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{colors}")
  end

  def priority_badge(priority)
    colors = case priority.to_s
    when "high" then "bg-red-100 text-red-800"
    when "medium" then "bg-orange-100 text-orange-800"
    when "low" then "bg-green-100 text-green-800"
    else "bg-gray-100 text-gray-800"
    end

    label = I18n.t("activerecord.enums.deadline.priority.#{priority}", default: priority.to_s.humanize)

    content_tag(:span, label, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{colors}")
  end

  def format_currency(amount)
    return "-" if amount.nil?
    number_to_currency(amount, unit: "\u20AC", separator: ",", delimiter: ".", format: "%n %u")
  end

  def format_percentage(value, precision: 1)
    return "-" if value.nil?
    number_to_percentage(value, precision: precision)
  end

  def page_header(title, &block)
    content_tag(:div, class: "sm:flex sm:items-center sm:justify-between mb-8") do
      content_tag(:h1, title, class: "text-2xl font-bold text-slate-900") +
      (block ? content_tag(:div, capture(&block), class: "mt-4 sm:mt-0 flex space-x-3") : "".html_safe)
    end
  end
end
