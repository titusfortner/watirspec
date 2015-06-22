# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Text Locator" do

  before :each do
    browser.goto(WatirSpec.url_for("text_matching.html"))
  end

  context "With Strings" do

    context 'using Generic Element' do
      it "clicking on element in the top level of nested elements executes its onclick action" do
        before = "Top Level Nested Element Before Child Element"
        element = browser.element(text: before)
        expect(element).to exist

        element.click

        after = "Div onclick action"
        element = browser.element(text: after)
        expect(element).to exist
      end

      it "finds an element in the middle level of nested element" do
        before = "Mid Level Nested Element Before Child Element"
        element = browser.element(text: before)
        expect(element).to exist
      end

      it "clicks link at the bottom of nested elements" do
        expect(browser.div(text: /April 23, 2015/)).to exist
        expect(browser.div(text: "April 2015")).to exist



        before = "Onclick Element"
        link = browser.div(text: before)
        expect(link).to exist

        link.click

        expect(browser.div(text: /Onclick works!/)).to exist
      end

    end

    context 'using Specific Tag' do
      it "clicking on element in the top level of nested elements executes its onclick action" do
        before = "Top Level Nested Element Before Child Element"
        element = browser.div(text: before)
        expect(element).to exist

        element.click

        after = "Div onclick action"
        element = browser.div(text: after)
        expect(element).to exist
      end

      it "finds an element in the middle level of nested element" do
        before = "Mid Level Nested Element Before Child Element"
        element = browser.p(text: before)
        expect(element).to exist
      end

    end
  end

end
