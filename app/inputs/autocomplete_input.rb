# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AutocompleteInput < SimpleForm::Inputs::Base
  def input
    klass = @builder.object.send(:"#{ attribute_name.to_s.gsub(/_id$/, "") }")
    if klass
      input_html_options['data-type'] = klass.class.to_s
      input_html_options['data-val']  = klass.to_s
    end
    @builder.text_field(attribute_name, input_html_options)
  end
end
