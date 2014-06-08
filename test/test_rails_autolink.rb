# encoding: utf-8

require "minitest/autorun"
require "rails"
require 'erb'
require 'cgi'
require 'active_support'
require 'active_support/core_ext'
require 'action_pack'
require 'action_view'
require 'action_view/helpers'
require 'action_dispatch/testing/assertions'
require 'timeout'
require "rails_autolink/helpers"

class TestRailsAutolink < MiniTest::Unit::TestCase
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::OutputSafetyHelper
  include ActionDispatch::Assertions::DomAssertions

  def test_auto_link_within_tags
    link_raw    = 'http://www.rubyonrails.org/images/rails.png'
    link_result = %Q(<img src="#{link_raw}" />)
    assert_equal link_result, auto_link(link_result)
  end

  def test_auto_link_with_brackets
    link1_raw = 'http://en.wikipedia.org/wiki/Sprite_(computer_graphics)'
    link1_result = generate_result(link1_raw)
    assert_equal link1_result, auto_link(link1_raw)
    assert_equal "(link: #{link1_result})", auto_link("(link: #{link1_raw})")

    link2_raw = 'http://en.wikipedia.org/wiki/Sprite_[computer_graphics]'
    link2_result = generate_result(link2_raw)
    assert_equal link2_result, auto_link(link2_raw)
    assert_equal "[link: #{link2_result}]", auto_link("[link: #{link2_raw}]")

    link3_raw = 'http://en.wikipedia.org/wiki/Sprite_{computer_graphics}'
    link3_result = generate_result(link3_raw)
    assert_equal link3_result, auto_link(link3_raw)
    assert_equal "{link: #{link3_result}}", auto_link("{link: #{link3_raw}}")
  end

  def test_auto_link_with_options_hash
    assert_dom_equal 'Welcome to my new blog at <a href="http://www.myblog.com/" class="menu" target="_blank">http://www.myblog.com/</a>. Please e-mail me at <a href="mailto:me@email.com" class="menu" target="_blank">me@email.com</a>.',
      auto_link("Welcome to my new blog at http://www.myblog.com/. Please e-mail me at me@email.com.",
                :link => :all, :html => { :class => "menu", :target => "_blank" })
  end

  def test_auto_link_with_multiple_trailing_punctuations
    url = "http://youtube.com"
    url_result = generate_result(url)
    assert_equal url_result, auto_link(url)
    assert_equal "(link: #{url_result}).", auto_link("(link: #{url}).")
  end

  def test_auto_link_with_block
    url = "http://api.rubyonrails.com/Foo.html"
    email = "fantabulous@shiznadel.ic"

    assert_equal %(<p><a href="#{url}">#{url[0...7]}...</a><br /><a href="mailto:#{email}">#{email[0...7]}...</a><br /></p>), auto_link("<p>#{url}<br />#{email}<br /></p>") { |_url| truncate(_url, :length => 10) }
  end

  def test_auto_link_with_block_with_html
    pic = "http://example.com/pic.png"
    url = "http://example.com/album?a&b=c"

    assert_equal %(My pic: <a href="#{pic}"><img src="#{pic}" width="160px"></a> -- full album here #{generate_result(url)}), auto_link("My pic: #{pic} -- full album here #{url}") { |link|
      if link =~ /\.(jpg|gif|png|bmp|tif)$/i
        raw %(<img src="#{link}" width="160px">)
      else
        link
      end
    }
  end

  def test_auto_link_should_sanitize_input_when_sanitize_option_is_not_false
    link_raw     = %{http://www.rubyonrails.com?id=1&num=2}
    malicious_script  = '<script>alert("malicious!")</script>'
    assert_equal %{<a href="http://www.rubyonrails.com?id=1&num=2">http://www.rubyonrails.com?id=1&num=2</a>}, auto_link("#{link_raw}#{malicious_script}")
    assert auto_link("#{link_raw}#{malicious_script}").html_safe?
  end

  def test_auto_link_should_sanitize_input_with_sanitize_options
    link_raw     = %{http://www.rubyonrails.com?id=1&num=2}
    malicious_script  = '<script>alert("malicious!")</script>'
    text_with_attributes = %{<a href="http://ruby-lang-org" target="_blank" data-malicious="inject">Ruby</a>}

    text_result = %{<a class="big" href="http://www.rubyonrails.com?id=1&num=2">http://www.rubyonrails.com?id=1&num=2</a><a href="http://ruby-lang-org" target="_blank">Ruby</a>}
    assert_equal text_result, auto_link("#{link_raw}#{malicious_script}#{text_with_attributes}",
                                        :sanitize_options => {:attributes => ["target", "href"]},
                                        :html => {:class => 'big'})

    assert auto_link("#{link_raw}#{malicious_script}#{text_with_attributes}",
                     :sanitize_options => {:attributes => ["target", "href"]},
                     :html => {:class => 'big'}).html_safe?
  end

  def test_auto_link_should_not_sanitize_input_when_sanitize_option_is_false
    link_raw     = %{http://www.rubyonrails.com?id=1&num=2}
    malicious_script  = '<script>alert("malicious!")</script>'

    assert_equal %{<a href="http://www.rubyonrails.com?id=1&num=2">http://www.rubyonrails.com?id=1&num=2</a><script>alert("malicious!")</script>}, auto_link("#{link_raw}#{malicious_script}", :sanitize => false)
    assert !auto_link("#{link_raw}#{malicious_script}", :sanitize => false).html_safe?
  end

  def test_auto_link_other_protocols
    ftp_raw = 'ftp://example.com/file.txt'
    assert_equal %(Download #{generate_result(ftp_raw)}), auto_link("Download #{ftp_raw}")

    file_scheme = 'file:///home/username/RomeoAndJuliet.pdf'
    assert_equal generate_result(file_scheme), auto_link(file_scheme)
  end

  def test_auto_link_already_linked
    linked1 = generate_result('Ruby On Rails', 'http://www.rubyonrails.com')
    linked2 = %('<a href="http://www.example.com">www.example.com</a>')
    linked3 = %('<a href="http://www.example.com" rel="nofollow">www.example.com</a>')
    linked4 = %('<a href="http://www.example.com"><b>www.example.com</b></a>')
    linked5 = %('<a href="#close">close</a> <a href="http://www.example.com"><b>www.example.com</b></a>')
    linked6 = %('<a href="#close">close</a> <a href="http://www.example.com" target="_blank" data-ruby="ror"><b>www.example.com</b></a>')
    assert_equal linked1, auto_link(linked1)
    assert_equal linked2, auto_link(linked2)
    assert_equal linked3, auto_link(linked3, :sanitize => false)
    assert_equal linked4, auto_link(linked4)
    assert_equal linked5, auto_link(linked5)
    assert_equal linked6, auto_link(linked6, :sanitize_options => {:attributes => ["href", "target", "data-ruby"]})

    linked_email = %Q(<a href="mailto:david@loudthinking.com">Mail me</a>)
    assert_equal linked_email, auto_link(linked_email)
  end

  def test_auto_link_with_malicious_attr
    url1 = "http://api.rubyonrails.com/Foo.html"
    malicious = "\"onmousemove=\"prompt()"
    combination = "#{url1}#{malicious}"

    assert_equal %(<p><a href="#{url1}">#{url1}</a>#{malicious}</p>), auto_link("<p>#{combination}</p>")
  end

  def test_auto_link_at_eol
    url1 = "http://api.rubyonrails.com/Foo.html"
    url2 = "http://www.ruby-doc.org/core/Bar.html"

    assert_equal %(<p><a href="#{url1}">#{url1}</a><br /><a href="#{url2}">#{url2}</a><br /></p>), auto_link("<p>#{url1}<br />#{url2}<br /></p>")
  end

  def test_auto_link_should_be_html_safe
    email_raw         = 'santiago@wyeworks.com'
    link_raw          = 'http://www.rubyonrails.org'
    malicious_script  = '<script>alert("malicious!")</script>'

    assert auto_link(nil).html_safe?, 'should be html safe'
    assert auto_link('').html_safe?, 'should be html safe'
    assert auto_link("#{link_raw} #{link_raw} #{link_raw}").html_safe?, 'should be html safe'
    assert auto_link("hello #{email_raw}").html_safe?, 'should be html safe'
    assert auto_link("hello #{email_raw} #{malicious_script}").html_safe?, 'should be html safe'
  end

  def test_auto_link_should_not_be_html_safe_when_sanitize_option_false
    email_raw         = 'santiago@wyeworks.com'
    link_raw          = 'http://www.rubyonrails.org'

    assert !auto_link("hello", :sanitize => false).html_safe?, 'should not be html safe'
    assert !auto_link("#{link_raw} #{link_raw} #{link_raw}", :sanitize => false).html_safe?, 'should not be html safe'
    assert !auto_link("hello #{email_raw}", :sanitize => false).html_safe?, 'should not be html safe'
  end

  def test_auto_link_email_address
    email_raw    = 'aaron@tenderlovemaking.com'
    email_result = %{<a href="mailto:#{email_raw}">#{email_raw}</a>}
    assert !auto_link_email_addresses(email_result).html_safe?, 'should not be html safe'
  end

  def test_auto_link_email_addres_with_especial_chars
    email_raw    = "and&re$la*+r-a.o'rea=l~ly@tenderlovemaking.com"
    email_sanitized = if Rails.version =~ /^3/
      # mail_to changed the number base it rendered HTML encoded characters at some point
      "and&amp;re$la*+r-a.o&#x27;rea=l~ly@tenderlovemaking.com"
    else
      "and&amp;re$la*+r-a.o&#39;rea=l~ly@tenderlovemaking.com"
    end
    email_result = %{<a href="mailto:#{email_raw}">#{email_sanitized}</a>}
    assert_equal email_result, auto_link(email_raw)
    assert !auto_link_email_addresses(email_result).html_safe?, 'should not be html safe'
  end

  def test_auto_link
    email_raw    = 'david@loudthinking.com'
    email_result = %{<a href="mailto:#{email_raw}">#{email_raw}</a>}
    link_raw     = 'http://www.rubyonrails.com'
    link_result  = generate_result(link_raw)
    link_result_with_options = %{<a href="#{link_raw}" target="_blank">#{link_raw}</a>}

    assert_equal '', auto_link(nil)
    assert_equal '', auto_link('')
    assert_equal "#{link_result} #{link_result} #{link_result}", auto_link("#{link_raw} #{link_raw} #{link_raw}")

    assert_equal %(hello #{email_result}), auto_link("hello #{email_raw}", :email_addresses)
    assert_equal %(Go to #{link_result}), auto_link("Go to #{link_raw}", :urls)
    assert_equal %(Go to #{link_raw}), auto_link("Go to #{link_raw}", :email_addresses)
    assert_equal %(Go to #{link_result} and say hello to #{email_result}), auto_link("Go to #{link_raw} and say hello to #{email_raw}")
    assert_equal %(<p>Link #{link_result}</p>), auto_link("<p>Link #{link_raw}</p>")
    assert_equal %(<p>#{link_result} Link</p>), auto_link("<p>#{link_raw} Link</p>")
    assert_equal %(<p>Link #{link_result_with_options}</p>), auto_link("<p>Link #{link_raw}</p>", :all, {:target => "_blank"})
    assert_equal %(Go to #{link_result}.), auto_link(%(Go to #{link_raw}.))
    assert_equal %(<p>Go to #{link_result}, then say hello to #{email_result}.</p>), auto_link(%(<p>Go to #{link_raw}, then say hello to #{email_raw}.</p>))
    assert_equal %(#{link_result} #{link_result}), auto_link(%(#{link_result} #{link_raw}))

    email2_raw    = '+david@loudthinking.com'
    email2_result = %{<a href="mailto:#{email2_raw}">#{email2_raw}</a>}
    assert_equal email2_result, auto_link(email2_raw)
    assert_equal email2_result, auto_link(email2_raw, :all)
    assert_equal email2_result, auto_link(email2_raw, :email_addresses)

    link2_raw    = 'www.rubyonrails.com'
    link2_result = generate_result(link2_raw, "http://#{link2_raw}")
    assert_equal %(Go to #{link2_result}), auto_link("Go to #{link2_raw}", :urls)
    assert_equal %(Go to #{link2_raw}), auto_link("Go to #{link2_raw}", :email_addresses)
    assert_equal %(<p>Link #{link2_result}</p>), auto_link("<p>Link #{link2_raw}</p>")
    assert_equal %(<p>#{link2_result} Link</p>), auto_link("<p>#{link2_raw} Link</p>")
    assert_equal %(Go to #{link2_result}.), auto_link(%(Go to #{link2_raw}.))
    assert_equal %(<p>Say hello to #{email_result}, then go to #{link2_result}.</p>), auto_link(%(<p>Say hello to #{email_raw}, then go to #{link2_raw}.</p>))

    link3_raw    = 'http://manuals.ruby-on-rails.com/read/chapter.need_a-period/103#page281'
    link3_result = generate_result(link3_raw)
    assert_equal %(Go to #{link3_result}), auto_link("Go to #{link3_raw}", :urls)
    assert_equal %(Go to #{link3_raw}), auto_link("Go to #{link3_raw}", :email_addresses)
    assert_equal %(<p>Link #{link3_result}</p>), auto_link("<p>Link #{link3_raw}</p>")
    assert_equal %(<p>#{link3_result} Link</p>), auto_link("<p>#{link3_raw} Link</p>")
    assert_equal %(Go to #{link3_result}.), auto_link(%(Go to #{link3_raw}.))
    assert_equal %(<p>Go to #{link3_result}. Seriously, #{link3_result}? I think I'll say hello to #{email_result}. Instead.</p>),
       auto_link(%(<p>Go to #{link3_raw}. Seriously, #{link3_raw}? I think I'll say hello to #{email_raw}. Instead.</p>))

    link4_raw    = 'http://foo.example.com/controller/action?parm=value&p2=v2#anchor123'
    link4_result = generate_result(link4_raw)
    assert_equal %(<p>Link #{link4_result}</p>), auto_link("<p>Link #{link4_raw}</p>")
    assert_equal %(<p>#{link4_result} Link</p>), auto_link("<p>#{link4_raw} Link</p>")

    link5_raw    = 'http://foo.example.com:3000/controller/action'
    link5_result = generate_result(link5_raw)
    assert_equal %(<p>#{link5_result} Link</p>), auto_link("<p>#{link5_raw} Link</p>")

    link6_raw    = 'http://foo.example.com:3000/controller/action+pack'
    link6_result = generate_result(link6_raw)
    assert_equal %(<p>#{link6_result} Link</p>), auto_link("<p>#{link6_raw} Link</p>")

    link7_raw    = 'http://foo.example.com/controller/action?parm=value&p2=v2#anchor-123'
    link7_result = generate_result(link7_raw)
    assert_equal %(<p>#{link7_result} Link</p>), auto_link("<p>#{link7_raw} Link</p>")

    link8_raw    = 'http://foo.example.com:3000/controller/action.html'
    link8_result = generate_result(link8_raw)
    assert_equal %(Go to #{link8_result}), auto_link("Go to #{link8_raw}", :urls)
    assert_equal %(Go to #{link8_raw}), auto_link("Go to #{link8_raw}", :email_addresses)
    assert_equal %(<p>Link #{link8_result}</p>), auto_link("<p>Link #{link8_raw}</p>")
    assert_equal %(<p>#{link8_result} Link</p>), auto_link("<p>#{link8_raw} Link</p>")
    assert_equal %(Go to #{link8_result}.), auto_link(%(Go to #{link8_raw}.))
    assert_equal %(<p>Go to #{link8_result}. Seriously, #{link8_result}? I think I'll say hello to #{email_result}. Instead.</p>),
       auto_link(%(<p>Go to #{link8_raw}. Seriously, #{link8_raw}? I think I'll say hello to #{email_raw}. Instead.</p>))

    link9_raw    = 'http://business.timesonline.co.uk/article/0,,9065-2473189,00.html'
    link9_result = generate_result(link9_raw)
    assert_equal %(Go to #{link9_result}), auto_link("Go to #{link9_raw}", :urls)
    assert_equal %(Go to #{link9_raw}), auto_link("Go to #{link9_raw}", :email_addresses)
    assert_equal %(<p>Link #{link9_result}</p>), auto_link("<p>Link #{link9_raw}</p>")
    assert_equal %(<p>#{link9_result} Link</p>), auto_link("<p>#{link9_raw} Link</p>")
    assert_equal %(Go to #{link9_result}.), auto_link(%(Go to #{link9_raw}.))
    assert_equal %(<p>Go to #{link9_result}. Seriously, #{link9_result}? I think I'll say hello to #{email_result}. Instead.</p>),
       auto_link(%(<p>Go to #{link9_raw}. Seriously, #{link9_raw}? I think I'll say hello to #{email_raw}. Instead.</p>))

    link10_raw    = 'http://www.mail-archive.com/ruby-talk@ruby-lang.org/'
    link10_result = generate_result(link10_raw)
    assert_equal %(<p>#{link10_result} Link</p>), auto_link("<p>#{link10_raw} Link</p>")

    link11_raw    = 'http://asakusa.rubyist.net/'
    link11_result = generate_result(link11_raw)
    with_kcode 'u' do
      assert_equal %(浅草.rbの公式サイトはこちら#{link11_result}), auto_link("浅草.rbの公式サイトはこちら#{link11_raw}")
    end

    link12_raw    = 'http://tools.ietf.org/html/rfc3986'
    link12_result = generate_result(link12_raw)
    assert_equal %(<p>#{link12_result} text-after-nonbreaking-space</p>), auto_link("<p>#{link12_raw} text-after-nonbreaking-space</p>")

    link13_raw    = 'HTtP://www.rubyonrails.com'
    assert_equal generate_result(link13_raw), auto_link(link13_raw)
  end

  def test_auto_link_parsing
    urls = %w(
      http://www.rubyonrails.com
      http://www.rubyonrails.com:80
      http://www.rubyonrails.com/~minam
      https://www.rubyonrails.com/~minam
      http://www.rubyonrails.com/~minam/url%20with%20spaces
      http://www.rubyonrails.com/foo.cgi?something=here
      http://www.rubyonrails.com/foo.cgi?something=here&and=here
      http://www.rubyonrails.com/contact;new
      http://www.rubyonrails.com/contact;new%20with%20spaces
      http://www.rubyonrails.com/contact;new?with=query&string=params
      http://www.rubyonrails.com/~minam/contact;new?with=query&string=params
      http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_picture_%28animation%29/January_20%2C_2007
      http://www.mail-archive.com/rails@lists.rubyonrails.org/
      http://www.amazon.com/Testing-Equal-Sign-In-Path/ref=pd_bbs_sr_1?ie=UTF8&s=books&qid=1198861734&sr=8-1
      http://en.wikipedia.org/wiki/Texas_hold'em
      https://www.google.com/doku.php?id=gps:resource:scs:start
      http://connect.oraclecorp.com/search?search[q]=green+france&search[type]=Group
      http://of.openfoundry.org/projects/492/download#4th.Release.3
      http://maps.google.co.uk/maps?f=q&q=the+london+eye&ie=UTF8&ll=51.503373,-0.11939&spn=0.007052,0.012767&z=16&iwloc=A
      http://около.кола/колокола
    )

    urls.each do |url|
      assert_equal generate_result(url), auto_link(url)
    end
  end

  def test_autolink_with_trailing_equals_on_link
    url = "http://www.rubyonrails.com/foo.cgi?trailing_equals="
    assert_equal generate_result(url), auto_link(url)
  end

  def test_autolink_with_trailing_amp_on_link
    url = "http://www.rubyonrails.com/foo.cgi?trailing_ampersand=value&"
    assert_equal generate_result(url), auto_link(url)
  end

  def test_auto_link_does_not_timeout_when_parsing_odd_email_input
    inputs = %w(
      foo@...................................
      foo@........................................
      foo@.............................................
    )

    inputs.each do |input|
      Timeout.timeout(0.2) do
        assert_equal input, auto_link(input)
      end
    end
  end

  private
  def generate_result(link_text, href = nil, escape = false)
    href ||= link_text
    if escape
      %{<a href="#{CGI::escapeHTML href}">#{CGI::escapeHTML link_text}</a>}
    else
      %{<a href="#{href}">#{link_text}</a>}
    end
  end

  # from ruby core
  def build_message(head, template=nil, *arguments)
    template &&= template.chomp
    template.gsub(/\?/) { mu_pp(arguments.shift) }
  end

  # Temporarily replaces KCODE for the block
  def with_kcode(kcode)
    if RUBY_VERSION < '1.9'
      old_kcode, $KCODE = $KCODE, kcode
      begin
        yield
      ensure
        $KCODE = old_kcode
      end
    else
      yield
    end
  end
end
