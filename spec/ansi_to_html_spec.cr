require "./spec_helper"

describe BcatAnsi do
  it "should not modify input string" do
    text = "some text"
    AnsiToHtml.new.to_html(text)
    text.should eq("some text")
  end

  it "passing through text with no escapes" do
    text = "hello\nthis is bcat\n"
    ansi = AnsiToHtml.new.to_html(text)
    text.should eq(ansi)
  end

  it "removing backspace characters" do
    text = "like this"
    ansi = AnsiToHtml.new.to_html(text)
    ansi.should eq("like this")
  end

  it "foreground colors" do
    text = "colors: \x1b[30mblack\x1b[37mwhite"
    expect = "colors: " +
             "<span style=\"color:#000\">black" +
             "<span style=\"color:#AAA\">white" +
             "</span></span>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "light foreground colors" do
    text = "colors: \x1b[90mblack\x1b[97mwhite"
    expect = "colors: " +
             "<span style=\"color:#555\">black" +
             "<span style=\"color:#FFF\">white" +
             "</span></span>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "background colors" do
    text = "colors: \x1b[40mblack\x1b[47mwhite"
    expect = "colors: " +
             "<span style=\"background-color:#000\">black" +
             "<span style=\"background-color:#AAA\">white" +
             "</span></span>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "light background colors" do
    text = "colors: \x1b[100mblack\x1b[107mwhite"
    expect = "colors: " +
             "<span style=\"background-color:#555\">black" +
             "<span style=\"background-color:#FFF\">white" +
             "</span></span>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "strikethrough" do
    text = "strike: \x1b[9mthat"
    expect = "strike: <strike>that</strike>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "blink!" do
    text = "blink: \x1b[5mwhat"
    expect = "blink: <blink>what</blink>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "underline" do
    text = "underline: \x1b[3mstuff"
    expect = "underline: <u>stuff</u>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "bold" do
    text = "bold: \x1b[1mstuff"
    expect = "bold: <b>stuff</b>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "resetting a single sequence" do
    text = "\x1b[1mthis is bold\x1b[0m, but this isn\"t"
    expect = "<b>this is bold</b>, but this isn\"t"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "resetting a single sequence" do
    text = "Text before\x1b[1mthis is bold\x1b[0m, but this isn\"t"
    expect = "Text before<b>this is bold</b>, but this isn\"t"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "resetting many sequences" do
    text = "normal, \x1b[1mbold, \x1b[3munderline, \x1b[31mred\x1b[0m, normal"
    expect = "normal, <b>bold, <u>underline, " +
             "<span style=\"color:#A00\">red</span></u></b>, normal"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "resetting without an implicit 0 argument" do
    text = "\x1b[1mthis is bold\x1b[m, but this isn\"t"
    expect = "<b>this is bold</b>, but this isn\"t"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "multi-attribute sequences" do
    text = "normal, \x1b[1;3;31mbold, underline, and red\x1b[0m, normal"
    expect = "normal, <b><u><span style=\"color:#A00\">" + "bold, underline, and red</span></u></b>, normal"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "multi-attribute sequences with a trailing semi-colon" do
    text = "normal, \x1b[1;3;31;mbold, underline, and red\x1b[0m, normal"
    expect = "normal, <b><u><span style=\"color:#A00\">" +
             "bold, underline, and red</span></u></b>, normal"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "eating malformed sequences" do
    text = "\x1b[25oops forgot the \"m\""
    expect = "oops forgot the \"m\""
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "xterm-256" do
    text = "\x1b[38;5;196mhello"
    expect = "<span style=\"color:#ff0000\">hello</span>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "xterm-256" do
    text = "Bleebo\x1b[38;5;196mhello"
    expect = "Bleebo<span style=\"color:#ff0000\">hello</span>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "xterm-256 with multiple" do
    text = "\x1b[38;5;196mhello for something else \x1b[38;5;196mand and"
    expect = "<span style=\"color:#ff0000\">hello for something else <span style=\"color:#ff0000\">and and</span></span>"
    expect.should eq(AnsiToHtml.new.to_html(text))
  end

  it "should handle complex ansi" do
    text = "[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[40m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[41m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[41m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[42m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[42m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[43m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[43m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[44m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[44m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[45m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[45m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[46m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[46m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[47m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m
[1m[47m[30m black [31m red [32m green [33m yellow [34m blue [35m magenta[36m cyan [37m white [0m"
    expect = %{<span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span>
<b><span style="background-color:#000"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>
<span style="background-color:#A00"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span>
<b><span style="background-color:#A00"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>
<span style="background-color:#0A0"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span>
<b><span style="background-color:#0A0"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>
<span style="background-color:#A50"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span>
<b><span style="background-color:#A50"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>
<span style="background-color:#00A"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span>
<b><span style="background-color:#00A"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>
<span style="background-color:#A0A"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span>
<b><span style="background-color:#A0A"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>
<span style="background-color:#0AA"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span>
<b><span style="background-color:#0AA"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>
<span style="background-color:#AAA"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span>
<b><span style="background-color:#AAA"><span style="color:#000"> black <span style="color:#A00"> red <span style="color:#0A0"> green <span style="color:#A50"> yellow <span style="color:#00A"> blue <span style="color:#A0A"> magenta<span style="color:#0AA"> cyan <span style="color:#AAA"> white </span></span></span></span></span></span></span></span></span></b>}
    expect.should eq(AnsiToHtml.new.to_html(text))
  end
end
