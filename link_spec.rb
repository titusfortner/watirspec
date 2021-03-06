# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Link" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the link exists" do
      expect(browser.link(id: 'link_2')).to exist
      expect(browser.link(id: /link_2/)).to exist
      expect(browser.link(title: "link_title_2")).to exist
      expect(browser.link(title: /link_title_2/)).to exist
      expect(browser.link(text: "Link 2")).to exist
      expect(browser.link(text: /Link 2/i)).to exist
      not_compliant_on :internet_explorer do
        expect(browser.link(href: 'non_control_elements.html')).to exist
      end
      expect(browser.link(href: /non_control_elements.html/)).to exist
      expect(browser.link(index: 1)).to exist
      expect(browser.link(xpath: "//a[@id='link_2']")).to exist
    end

    it "returns the first link if given no args" do
      expect(browser.link).to exist
    end

    it "strips spaces from href attribute when locating elements" do
      expect(browser.link(href: /strip_space$/)).to exist
    end

    it "returns false if the link doesn't exist" do
      expect(browser.link(id: 'no_such_id')).to_not exist
      expect(browser.link(id: /no_such_id/)).to_not exist
      expect(browser.link(title: "no_such_title")).to_not exist
      expect(browser.link(title: /no_such_title/)).to_not exist
      expect(browser.link(text: "no_such_text")).to_not exist
      expect(browser.link(text: /no_such_text/i)).to_not exist
      expect(browser.link(href: 'no_such_href')).to_not exist
      expect(browser.link(href: /no_such_href/)).to_not exist
      expect(browser.link(index: 1337)).to_not exist
      expect(browser.link(xpath: "//a[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.link(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.link(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the type attribute if the link exists" do
      expect(browser.link(index: 1).class_name).to eq "external"
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      expect(browser.link(index: 0).class_name).to eq ''
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      expect { browser.link(index: 1337).class_name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#href" do
    it "returns the href attribute if the link exists" do
      expect(browser.link(index: 1).href).to match(/non_control_elements/)
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      expect(browser.link(index: 0).href).to eq ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      expect { browser.link(index: 1337).href }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#href" do
    it "returns the href attribute" do
      expect(browser.link(index: 1).href).to match(/non_control_elements/)
    end
  end

  describe "#id" do
    it "returns the id attribute if the link exists" do
      expect(browser.link(index: 1).id).to eq "link_2"
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      expect(browser.link(index: 0).id).to eq ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      expect { browser.link(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the link text" do
      expect(browser.link(index: 1).text).to eq "Link 2"
    end

    it "returns an empty string if the link exists and contains no text" do
      expect(browser.link(index: 0).text).to eq ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      expect { browser.link(index: 1337).text }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the type attribute if the link exists" do
      expect(browser.link(index: 1).title).to eq "link_title_2"
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      expect(browser.link(index: 0).title).to eq ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      expect { browser.link(index: 1337).title }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.link(index: 0)).to respond_to(:class_name)
      expect(browser.link(index: 0)).to respond_to(:href)
      expect(browser.link(index: 0)).to respond_to(:id)
      expect(browser.link(index: 0)).to respond_to(:style)
      expect(browser.link(index: 0)).to respond_to(:text)
      expect(browser.link(index: 0)).to respond_to(:title)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "finds an existing link by (text: String) and clicks it" do
      browser.link(text: "Link 3").click
      expect(browser.text.include?("User administration")).to be true
    end

    it "finds an existing link by (text: Regexp) and clicks it" do
      browser.link(href: /forms_with_input_elements/).click
      expect(browser.text.include?("User administration")).to be true
    end

    it "finds an existing link by (index: Integer) and clicks it" do
      browser.link(index: 2).click
      expect(browser.text.include?("User administration")).to be true
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      expect { browser.link(index: 1337).click }.to raise_error(Watir::Exception::UnknownObjectException)
    end

    it "clicks a link with no text content but an img child" do
      browser.goto WatirSpec.url_for("images.html")
      browser.link(href: /definition_lists.html/).click
      expect(browser.title).to eq 'definition_lists'
    end

  end

end
