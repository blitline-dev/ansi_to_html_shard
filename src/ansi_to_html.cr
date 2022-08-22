require "./bcat_ansi"

# AnsiToHtml will convert color coded ANSI text to HTML
class AnsiToHtml
  VERSION = "0.1.0"

  def initialize
    @ansi = BcatAnsi::Ansi.new
  end

  def to_html(text)
    @ansi.to_html(text)
  end
end
