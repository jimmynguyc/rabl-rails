require 'rabl-rails/renderers/base'
require 'rabl-rails/renderers/json'

module RablRails
  module Renderer
    mattr_reader :view_path
    @@view_path = 'app/views'
  
    class Context
      def initialize
        @_assigns = {}
      end

      def assigns
        @_assigns
      end
    end
  
    def render(object, template, options = {})
      format = options.delete(:format) || 'json'
      source = find_template(template, format, options.delete(:view_path))
      compiled_template = Compiler.new.compile_source(source)
    
      c = Context.new
      c.assigns[compiled_template.data.to_s[1..-1]] = object if compiled_template.data

      Renderers.const_get(format.upcase!).new(c).render(compiled_template)
    end
  
    private
  
    def find_template(name, format, view_path = nil)
      view_path ||= self.view_path
      path = File.join(view_path, "#{name}.#{format}.rabl")
      File.exists?(path) ? File.read(path) : nil
    end
  end
end