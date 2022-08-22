require "./spec_helper"

describe BcatAnsi do
  it "should not modify input string" do
    text = "some text"
    BcatAnsi::Ansi.new(text).to_html
    text.should eq("some text")
  end

  it "passing through text with no escapes" do
    text = "hello\nthis is bcat\n"
    ansi = BcatAnsi::Ansi.new(text)
    text.should eq(ansi.to_html)
  end

  it "removing backspace characters" do
    text = "like this"
    ansi = BcatAnsi::Ansi.new(text)
    ansi.to_html.should eq("like this")
  end

  it "foreground colors" do
    text = "colors: \x1b[30mblack\x1b[37mwhite"
    expect = "colors: " +
             "<span style=\"color:#000\">black" +
             "<span style=\"color:#AAA\">white" +
             "</span></span>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "light foreground colors" do
    text = "colors: \x1b[90mblack\x1b[97mwhite"
    expect = "colors: " +
             "<span style=\"color:#555\">black" +
             "<span style=\"color:#FFF\">white" +
             "</span></span>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "background colors" do
    text = "colors: \x1b[40mblack\x1b[47mwhite"
    expect = "colors: " +
             "<span style=\"background-color:#000\">black" +
             "<span style=\"background-color:#AAA\">white" +
             "</span></span>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "light background colors" do
    text = "colors: \x1b[100mblack\x1b[107mwhite"
    expect = "colors: " +
             "<span style=\"background-color:#555\">black" +
             "<span style=\"background-color:#FFF\">white" +
             "</span></span>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "strikethrough" do
    text = "strike: \x1b[9mthat"
    expect = "strike: <strike>that</strike>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "blink!" do
    text = "blink: \x1b[5mwhat"
    expect = "blink: <blink>what</blink>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "underline" do
    text = "underline: \x1b[3mstuff"
    expect = "underline: <u>stuff</u>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "bold" do
    text = "bold: \x1b[1mstuff"
    expect = "bold: <b>stuff</b>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "resetting a single sequence" do
    text = "\x1b[1mthis is bold\x1b[0m, but this isn\"t"
    expect = "<b>this is bold</b>, but this isn\"t"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "resetting many sequences" do
    text = "normal, \x1b[1mbold, \x1b[3munderline, \x1b[31mred\x1b[0m, normal"
    expect = "normal, <b>bold, <u>underline, " +
             "<span style=\"color:#A00\">red</span></u></b>, normal"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "resetting without an implicit 0 argument" do
    text = "\x1b[1mthis is bold\x1b[m, but this isn\"t"
    expect = "<b>this is bold</b>, but this isn\"t"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "multi-attribute sequences" do
    text = "normal, \x1b[1;3;31mbold, underline, and red\x1b[0m, normal"
    expect = "normal, <b><u><span style=\"color:#A00\">" + "bold, underline, and red</span></u></b>, normal"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "multi-attribute sequences with a trailing semi-colon" do
    text = "normal, \x1b[1;3;31;mbold, underline, and red\x1b[0m, normal"
    expect = "normal, <b><u><span style=\"color:#A00\">" +
             "bold, underline, and red</span></u></b>, normal"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "eating malformed sequences" do
    text = "\x1b[25oops forgot the \"m\""
    expect = "oops forgot the \"m\""
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "xterm-256" do
    text = "\x1b[38;5;196mhello"
    expect = "<span style=\"color:#ff0000\">hello</span>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end

  it "xterm-256 with multiple" do
    text = "\x1b[38;5;196mhello for something else \x1b[38;5;196mand and"
    expect = "<span style=\"color:#ff0000\">hello for something else <span style=\"color:#ff0000\">and and</span></span>"
    expect.should eq(BcatAnsi::Ansi.new(text).to_html)
  end
end
