require 'sass'

module Sass::Script::Functions

  def inline_svg_image(path)
    real_path = "#{Rails.root}/app/assets/images/#{path.value}"
    svg = data(real_path)
    encoded_svg = URI::encode(svg)
    data_url = "url('data:image/svg+xml;utf8," + encoded_svg + "')"
    Sass::Script::String.new(data_url)
  end

private

  def data(real_path)
    if File.readable?(real_path)
      File.open(real_path, "rb") {|io| io.read}
    else
      raise "File not found or cannot be read: #{real_path}"
    end
  end

end
