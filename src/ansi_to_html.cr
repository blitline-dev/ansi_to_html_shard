require "bcat_ansi"

# AnsiToHtml will convert color coded ANSI text to HTML
class AnsiToHtml
  VERSION = "0.1.0"

  def self.to_html(text)
    ansi = BcatAnsi::Ansi.new(text)
    ansi.to_html
  end
end
