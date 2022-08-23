# ansi_to_html

Converts ANSI text to HTML output.

Very similar to ruby gem with same name and bcat ANSI code. Much faster (x10)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     ansi_to_html:
       github: blitline-dev/ansi_to_html_shard
   ```

2. Run `shards install`

## Usage

```crystal
require "ansi_to_html"
```

To use in your code simply:

```crystal
ansi_converter = AnsiToHtml.new

html = ansi_converter.to_html("colors: \x1b[30mblack\x1b[37mwhite")
```

## Notes

Basic support for old terminals.
Xterm support
256 Colors Support


## Contributing

1. Fork it (<https://github.com/blitline-dev/ansi_to_html_shard/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Blitline Developers](https://github.com/blitline-dev) - creator and maintainer
