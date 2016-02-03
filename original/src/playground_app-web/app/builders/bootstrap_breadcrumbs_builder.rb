class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  
  # This is for making the output of the Breadcrumbs on Rails builder compatible
  # with Bootstrap.
  #
  # Code is from here: https://gist.github.com/2400302
  #
  
  def render
    @context.content_tag(:ul, :class => 'breadcrumb') do
      @elements.collect do |element|
        render_element(element)
      end.join.html_safe
    end
  end

  def render_element(element)
    current = @context.current_page?(compute_path(element))

    @context.content_tag(:li, :class => ('active' if current)) do
      link_or_text = @context.link_to_unless_current(compute_name(element), compute_path(element), element.options)
      divider = @context.content_tag(:span, (@options[:separator]  || '/').html_safe, :class => 'divider') unless current

      link_or_text + (divider || '')
    end
  end
end