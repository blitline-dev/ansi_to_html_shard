class BcatAnsi
  # Converts ANSI color sequences to HTML.
  #
  # The ANSI module is based on code from the following libraries:
  #
  # ansi2html.sh:
  #   http://github.com/pixelb/scripts/blob/master/scripts/ansi2html.sh
  #
  # HTML::FromANSI:
  #   http://cpansearch.perl.org/src/NUFFIN/HTML-FromANSI-2.03/lib/HTML/FromANSI.pm
  class Ansi
    @input : Array(String)

    BAD_ESC       = /\x08+/
    MALFORMED     = /\x1b\[?[\d;]{0,3}/
    ESC_ONE       = "\x1b"
    ESC_TWO       = "\x08"
    DISPLAY_REGEX = /\x1b\[((?:\d{1,3};?)+|)m/
    XTERM_REGEX   = /\x1b\[38;5;(\d+)m/

    ESCAPE = "\x1b"

    # Linux console palette
    STYLES = {
      "ef0"  => "color:#000",
      "ef1"  => "color:#A00",
      "ef2"  => "color:#0A0",
      "ef3"  => "color:#A50",
      "ef4"  => "color:#00A",
      "ef5"  => "color:#A0A",
      "ef6"  => "color:#0AA",
      "ef7"  => "color:#AAA",
      "ef8"  => "color:#555",
      "ef9"  => "color:#F55",
      "ef10" => "color:#5F5",
      "ef11" => "color:#FF5",
      "ef12" => "color:#55F",
      "ef13" => "color:#F5F",
      "ef14" => "color:#5FF",
      "ef15" => "color:#FFF",
      "eb0"  => "background-color:#000",
      "eb1"  => "background-color:#A00",
      "eb2"  => "background-color:#0A0",
      "eb3"  => "background-color:#A50",
      "eb4"  => "background-color:#00A",
      "eb5"  => "background-color:#A0A",
      "eb6"  => "background-color:#0AA",
      "eb7"  => "background-color:#AAA",
      "eb8"  => "background-color:#555",
      "eb9"  => "background-color:#F55",
      "eb10" => "background-color:#5F5",
      "eb11" => "background-color:#FF5",
      "eb12" => "background-color:#55F",
      "eb13" => "background-color:#F5F",
      "eb14" => "background-color:#5FF",
      "eb15" => "background-color:#FFF",
    }

    ##
    # The default xterm 256 colour palette

    (0..5).each do |red|
      (0..5).each do |green|
        (0..5).each do |blue|
          c = 16 + (red * 36) + (green * 6) + blue
          r = red > 0 ? red * 40 + 55 : 0
          g = green > 0 ? green * 40 + 55 : 0
          b = blue > 0 ? blue * 40 + 55 : 0
          STYLES["ef#{c}"] = "color:#%02x%02x%02x" % [r, g, b]
          STYLES["eb#{c}"] = "background-color:#%02x%02x%02x" % [r, g, b]
        end
      end
    end

    (0..23).each do |gray|
      c = gray + 232
      l = gray*10 + 8
      STYLES["ef#{c}"] = "color:#%02x%02x%02x" % [l, l, l]
      STYLES["eb#{c}"] = "background-color:#%02x%02x%02x" % [l, l, l]
    end

    def initialize
      @input = Array(String).new
      @stack = Array(TagItem).new
    end

    def to_html(input : String)
      @input = [input]
      @stack = Array(TagItem).new

      b = String.build do |io|
        @input.each do |chunk|
          chunk = chunk.gsub(BAD_ESC, "")
          tkn = tokenize(chunk, io)
          io << stringify_stack if @stack.any?
        end
      end

      b.to_s
    end

    def push_text(text)
      @stack << TagItem.new(nil, text)
    end

    def push_style(style)
      push_tag "span", style
    end

    def push_tag(tag, style : String | Nil = nil)
      style = STYLES[style] if style && !style.includes?(":")
      t = "<#{tag}#{style ? " style=\"#{style}\"" : ""}>"
      @stack << TagItem.new(tag, t)
    end

    def stringify_stack
      output = String.build do |io|
        @stack.each do |tag_item|
          clean_text = tag_item.text.gsub(MALFORMED, "")
          io << clean_text
        end

        @stack.reverse.map do |tag_item|
          io << "</#{tag_item.tag}>" if !tag_item.tag.nil?
        end
        @stack.clear
      end
      output.to_s
    end

    def xtermy(m) : String | Nil
      # Clean because we don't have capture
      m = m.gsub("38;5;", "")
      push_style("ef#{m}")
      nil
    end

    def escapey(m) : String | Nil
      m = "0" if m.strip.empty?
      x = nil
      m.chomp(";").split(";").each do |code|
        x = display_code_handler(code.to_i)
      end
      x
    end

    def is_raw?(text)
      !(text.includes?(ESC_ONE) || text.includes?(ESC_TWO))
    end

    def handle_xterm(text, string_array)
      c = 0
      text.split(DISPLAY_REGEX) do |s|
        c += 1
        next if s.empty?
        if c.even?
          output = xtermy(s)
        end
        push_text(s) if c.odd?
      end
    end

    def handle_display(text, string_array)
      c = 0
      text.split(DISPLAY_REGEX) do |s|
        c += 1
        if c.even?
          output = escapey(s)
          string_array << output unless output.nil?
        end
        push_text(s) if c.odd?
      end
    end

    def tokenize(text, string_array) : String | Nil
      if is_raw?(text)
        push_text(text)
        return
      end

      if text.match(XTERM_REGEX)
        handle_xterm(text, string_array)
        return
      elsif text.match(DISPLAY_REGEX)
        handle_display(text, string_array)
        return
      end

      push_text(text)
      nil
      return
    end

    def display_code_handler(data) : String | Nil
      case code = data
      when 0
        return stringify_stack if @stack.any?
      when 1
        push_tag("b") # bright
      when 2
      when 3, 4
        push_tag("u")
      when 5, 6
        push_tag("blink")
      when 7
      when 8
        push_style("display:none")
      when 9
        push_tag("strike")
      when 30..37
        push_style("ef#{code - 30}")
      when 40..47
        push_style("eb#{code - 40}")
      when 90..97
        push_style("ef#{8 + code - 90}")
      when 100..107
        push_style("eb#{8 + code - 100}")
      end
      nil
    end

    struct TagItem
      property tag, text

      def initialize(@tag : String | Nil, @text : String)
      end
    end
  end
end
