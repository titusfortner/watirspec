require File.expand_path("../spec_helper", __FILE__)

describe "Browser#timeouts" do

  context "implicit waits" do
    before do
      browser.timeouts.implicit_wait = 0
      browser.goto WatirSpec.url_for 'dynamic.html'
    end

    after { browser.timeouts.implicit_wait = 0 }

    it "should implicitly wait for a single element" do
      browser.timeouts.implicit_wait = 6

      browser.input(:id, 'adder').click
      expect(browser.div(:id, 'box0')).to exist
    end

    it "should still fail to find an element with implicit waits enabled" do
      browser.timeouts.implicit_wait = 0.5
      browser.input(:id, 'adder').click
      expect(browser.div(:id, 'box0')).to_not exist
    end

    it "should return after first attempt to find one after disabling implicit waits" do
      browser.timeouts.implicit_wait = 6
      browser.timeouts.implicit_wait = 0
      browser.input(:id, 'adder').click
      expect(browser.div(:id, 'box0')).to_not exist
    end

    it "should implicitly wait until at least one element is found when searching for many" do
      add = browser.div(:id, 'box0')

      browser.timeouts.implicit_wait = 6
      add.click
      add.click
      expect(browser.divs(:class_name, 'redbox')).to_not be_empty
    end

    it "should still fail to find elements when implicit waits are enabled" do
      browser.timeouts.implicit_wait = 0.5
      expect(browser.divs(:class_name, 'redbox')).to be_empty
    end

    it "should return after first attempt to find many after disabling implicit waits" do
      add = browser.div(:id, 'box0')

      browser.timeouts.implicit_wait = 6
      browser.timeouts.implicit_wait = 0
      add.click

      expect(browser.divs(:class_name, 'redbox')).to be_empty
    end
  end

  describe "execute async script" do
    before {
      browser.timeouts.script_timeout = 0
      browser.goto WatirSpec.url_for("ajaxy_page.html")
    }

    it "should be able to return arrays of primitives from async scripts" do
      result = browser.execute_async_script "arguments[arguments.length - 1]([null, 123, 'abc', true, false]);"
      result.should == [nil, 123, 'abc', true, false]
    end

    it "should be able to pass multiple arguments to async scripts" do
      result = browser.execute_async_script "arguments[arguments.length - 1](arguments[0] + arguments[1]);", 1, 2
      result.should == 3
    end

    it "times out if the callback is not invoked" do
      # Script is expected to be async and explicitly callback, so this should timeout.
      expect { browser.execute_async_script "return 1 + 2;" }.to raise_error(Watir::Wait::TimeoutError)
    end
  end
end
