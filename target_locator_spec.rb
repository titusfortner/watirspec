require File.expand_path("../spec_helper", __FILE__)

describe "Selenium::WebDriver::TargetLocator" do
  let(:wait) { Selenium::WebDriver::Wait.new }

  it "should find the active element" do
    browser.driver.navigate.to WatirSpec.url_for("se_xhtmlTest.html")
    browser.driver.switch_to.active_element.should be_an_instance_of(Selenium::WebDriver::Element)
  end

  it "should switch to a frame" do
    browser.driver.navigate.to WatirSpec.url_for("se_iframes.html")
    browser.driver.switch_to.frame("iframe1")

    browser.driver.find_element(:name, 'login').should be_kind_of(Selenium::WebDriver::Element)
  end

  it "should switch to a frame by Element" do
    browser.driver.navigate.to WatirSpec.url_for("se_iframes.html")

    iframe = browser.driver.find_element(:tag_name => "iframe")
    browser.driver.switch_to.frame(iframe)

    browser.driver.find_element(:name, 'login').should be_kind_of(Selenium::WebDriver::Element)
  end

  it "should switch to parent frame" do
    browser.driver.navigate.to WatirSpec.url_for("se_iframes.html")

    iframe = browser.driver.find_element(:tag_name => "iframe")
    browser.driver.switch_to.frame(iframe)

    browser.driver.find_element(:name, 'login').should be_kind_of(Selenium::WebDriver::Element)

    browser.driver.switch_to.parent_frame
    browser.driver.find_element(:id, 'iframe_page_heading').should be_kind_of(Selenium::WebDriver::Element)
  end

  it "should switch to a window and back when given a block" do
    browser.driver.navigate.to WatirSpec.url_for("se_xhtmlTest.html")

    browser.driver.find_element(:link, "Open new window").click
    browser.driver.title.should == "XHTML Test Page"

    browser.driver.switch_to.window("result") do
      wait.until { browser.driver.title == "We Arrive Here" }
    end

    wait.until { browser.driver.title == "XHTML Test Page" }

    #reset_driver!
  end

  it "should handle exceptions inside the block" do
    browser.driver.navigate.to WatirSpec.url_for("se_xhtmlTest.html")

    browser.driver.find_element(:link, "Open new window").click
    browser.driver.title.should == "XHTML Test Page"

    lambda {
      browser.driver.switch_to.window("result") { raise "foo" }
    }.should raise_error(RuntimeError, "foo")

    browser.driver.title.should == "XHTML Test Page"

    #reset_driver!
  end

  it "should switch to a window" do
    browser.driver.navigate.to WatirSpec.url_for("se_xhtmlTest.html")

    browser.driver.find_element(:link, "Open new window").click
    wait.until { browser.driver.title == "XHTML Test Page" }

    browser.driver.switch_to.window("result")
    wait.until { browser.driver.title == "We Arrive Here" }
    browser.driver.switch_to.window(browser.driver.window_handles.first)
    #reset_driver!
  end

  it "should use the original window if the block closes the popup" do
    browser.driver.navigate.to WatirSpec.url_for("se_xhtmlTest.html")

    browser.driver.find_element(:link, "Open new window").click
    browser.driver.title.should == "XHTML Test Page"

    browser.driver.switch_to.window("result") do
      wait.until { browser.driver.title == "We Arrive Here" }
      browser.driver.close
    end

    browser.driver.current_url.should include("se_xhtmlTest.html")
    browser.driver.title.should == "XHTML Test Page"
    #reset_driver!
  end

  it "should switch to default content" do
    browser.driver.navigate.to WatirSpec.url_for("se_iframes.html")

    browser.driver.switch_to.frame 0
    browser.driver.switch_to.default_content

    browser.driver.find_element(:id => "iframe_page_heading")
  end

  context "with current window closed" do


    it "should switch to another window when current window is closed" do
      browser.driver.navigate.to WatirSpec.url_for("se_xhtmlTest.html")
      browser.driver.find_element(:link, "Open new window").click

      browser.driver.switch_to.window("result")
      Watir::Wait.until { browser.driver.title == "We Arrive Here" }

      browser.driver.close

      browser.driver.switch_to.window(browser.driver.window_handles.first) do
        Watir::Wait.until { browser.driver.title == "XHTML Test Page" }
      end

      browser.driver.title.should == "XHTML Test Page"
    end

    it "should switch to another window when current window is closed and multiple windows exist" do
      browser.driver.navigate.to WatirSpec.url_for("se_xhtmlTest.html")
      browser.driver.find_element(:link, "Create a new anonymous window").click
      browser.driver.find_element(:link, "Open new window").click

      browser.driver.switch_to.window("result")
      wait.until { browser.driver.title == "We Arrive Here" }

      browser.driver.close

      browser.driver.switch_to.window(browser.driver.window_handles.last) do
        wait.until { browser.driver.title == "Iframes" }
      end

      browser.driver.title.should == "Iframes"
    end

  end

  describe "alerts" do
    it "allows the user to accept an alert" do
      browser.driver.navigate.to WatirSpec.url_for("se_alerts.html")
      browser.driver.find_element(:id => "alert").click

      browser.driver.switch_to.alert.accept

      browser.driver.title.should == "Testing Alerts"
    end

    it "allows the user to dismiss an alert" do
      browser.driver.navigate.to WatirSpec.url_for("se_alerts.html")
      browser.driver.find_element(:id => "alert").click

      alert = wait_for_alert
      alert.dismiss

      browser.driver.title.should == "Testing Alerts"
    end

    it "allows the user to set the value of a prompt" do
      browser.driver.navigate.to WatirSpec.url_for("se_alerts.html")
      browser.driver.find_element(:id => "prompt").click

      alert = wait_for_alert
      alert.send_keys "cheese"
      alert.accept

      text = browser.driver.find_element(:id => "text").text
      text.should == "cheese"
    end

    it "allows the user to get the text of an alert" do
      browser.driver.navigate.to WatirSpec.url_for("se_alerts.html")
      browser.driver.find_element(:id => "alert").click

      alert = wait_for_alert
      text = alert.text
      alert.accept

      text.should == "cheese"
    end

    it "raises when calling #text on a closed alert" do
      browser.driver.navigate.to WatirSpec.url_for("se_alerts.html")
      browser.driver.find_element(:id => "alert").click

      alert = wait_for_alert
      alert.accept

      expect { alert.text }.to raise_error(Selenium::WebDriver::Error::NoAlertPresentError)
    end

    it "raises NoAlertOpenError if no alert is present" do
      lambda { browser.driver.switch_to.alert }.should raise_error(
                                                           Selenium::WebDriver::Error::NoAlertPresentError, /alert|modal dialog/i)
    end

    it "raises an UnhandledAlertError if an alert has not been dealt with" do
      browser.driver.navigate.to WatirSpec.url_for("se_alerts.html")
      browser.driver.find_element(:id => "alert").click
      wait_for_alert

      lambda { browser.driver.title }.should raise_error(Selenium::WebDriver::Error::UnhandledAlertError)

      browser.driver.title.should == "Testing Alerts" # :chrome does not auto-dismiss the alert
    end

  end
end

def wait_for_alert
  Watir::Wait.until { browser.driver.switch_to.alert }
end

