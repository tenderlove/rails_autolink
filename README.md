## Proposal

Thank you for providing this fantastic gem.

To make it easier for programming beginners to understand the benefits of this gem, I would like to enhance the [Synopsis](https://github.com/tenderlove/rails_autolink#synopsis).

Currently, it only includes code and execution results. In addition to that, I would like to add a simple explanation that allows users to grasp the functionality of rails_autolink quickly.

## Current Synopsis

```ruby
require 'rails_autolink'

auto_link("Go to http://www.rubyonrails.org and say hello to david@loudthinking.com")
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> and
#     say hello to <a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>"

auto_link("Visit http://www.loudthinking.com/ or e-mail david@loudthinking.com", :link => :urls)
# => "Visit <a href=\"http://www.loudthinking.com/\">http://www.loudthinking.com/</a>
#     or e-mail david@loudthinking.com"

auto_link("Visit http://www.loudthinking.com/ or e-mail david@loudthinking.com", :link => :email_addresses)
# => "Visit http://www.loudthinking.com/ or e-mail <a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>"

auto_link("Go to http://www.rubyonrails.org <script>Malicious code!</script>")
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> "

auto_link("Go to http://www.rubyonrails.org <script>alert('Script!')</script>", :sanitize => false)
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> <script>alert('Script!')</script>"

post_body = "Welcome to my new blog at http://www.myblog.com/.  Please e-mail me at me@email.com."
auto_link(post_body, :html => { :target => '_blank' }) do |text|
  truncate(text, :length => 15)
end
# => "Welcome to my new blog at <a href=\"http://www.myblog.com/\" target=\"_blank\">http://www.m...</a>.
```

## Proposed Synopsis

### Basic Usage

```ruby
require 'rails_autolink'

auto_link("Go to http://www.rubyonrails.org and say hello to david@loudthinking.com")
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> and
#     say hello to <a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>"
```

### Convert Only URLs  to Links

```ruby
auto_link("Visit http://www.loudthinking.com/ or e-mail david@loudthinking.com", :link => :urls)
# => "Visit <a href=\"http://www.loudthinking.com/\">http://www.loudthinking.com/</a>
#     or e-mail david@loudthinking.com"
```

### Convert Only Email Addresses to Links

```ruby
auto_link("Visit http://www.loudthinking.com/ or e-mail david@loudthinking.com", :link => :email_addresses)
# => "Visit http://www.loudthinking.com/ or e-mail <a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>"
```

### Generate Links Without Sanitizing HTML Tags

```ruby
## By default, HTML tags are sanitized to protect from malicious code
auto_link("Go to http://www.rubyonrails.org <script>Malicious code!</script>")
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> "

## Use the :sanitize => false option to prevent sanitization
auto_link("Go to http://www.rubyonrails.org <script>alert('Script!')</script>", :sanitize => false)
# => "Go to <a href=\"http://www.rubyonrails.org\">http://www.rubyonrails.org</a> <script>alert('Script!')</script>"
```

### Customize Links and Shorten Text

```ruby
post_body = "Welcome to my new blog at http://www.myblog.com/.  Please e-mail me at me@email.com."
auto_link(post_body, :html => { :target => '_blank' }) do |text|
  truncate(text, :length => 15)
end
# => "Welcome to my new blog at <a href=\"http://www.myblog.com/\" target=\"_blank\">http://www.m...</a>.
```


## Requirements

- `rails` > `3.1`
