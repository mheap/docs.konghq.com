#Generates a named anchor and wrapping tag from a string.

module Jekyll
  class VersionIs < Liquid::Block
    def initialize(tag_name, markup, tokens)
      @tag = markup

      @params = {}
      markup.scan(Liquid::TagAttributes) do |key, value| 
        @params[key.to_sym] = value
      end
      super
    end

    def render(context)
      contents = super

      current_version = to_version(context.environments.first["page"]["kong_version"])

      # If there's an exact match, check only that
      if @params.key?(:eq)
        version = to_version(@params[:eq])
        return "" unless current_version == version
      end

      # If there's a greater than check, fail if it's lower
      if @params.key?(:gt)
        version = to_version(@params[:gt])
        return "" unless current_version >= version
      end

      # If there's a less than check, fail if it's lower
      if @params.key?(:lt)
        version = to_version(@params[:lt])
        return "" unless current_version <= version
      end

      # Remove the leading and trailing whitespace and return
      # We can't use .strip as that removes all leading whitespace,
      # including indentation
      contents.gsub(/^\n/,"").gsub(/\n$/,"")
    end

    def to_version(input)
      Gem::Version.new(input.gsub(/\.x$/, ".0"))
    end
  end
end

Liquid::Template.register_tag("if_version", Jekyll::VersionIs)