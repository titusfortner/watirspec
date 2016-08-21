require File.expand_path("../spec_helper", __FILE__)

describe "Browser::AfterHooks" do
  describe "#add" do
    it "raises ArgumentError when not given any arguments" do
      expect { browser.error_checks.add }.to raise_error(ArgumentError)
    end

    it "runs the given proc on each page load" do
      output = ''
      proc = Proc.new { |browser| output << browser.text }

      begin
        browser.error_checks.add(proc)
        browser.goto(WatirSpec.url_for("non_control_elements.html"))

        expect(output).to include('Dubito, ergo cogito, ergo sum')
      ensure
        browser.error_checks.delete(proc)
      end
    end
  end

  describe "#delete" do
    it "removes a previously added error_check" do
      output = ''
      error_check = lambda{ |browser| output << browser.text }

      browser.error_checks.add(error_check)
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      expect(output).to include('Dubito, ergo cogito, ergo sum')

      browser.error_checks.delete(error_check)
      browser.goto(WatirSpec.url_for("definition_lists.html"))
      expect(output).to_not include('definition_lists')
    end
  end

  describe "#run" do
    after(:each) do
      browser.window(index: 0).use
      browser.error_checks.delete @page_error_check
    end

    it "runs error_checks after Browser#goto" do
      @page_error_check = Proc.new { @yield = browser.title == "The font element" }
      browser.error_checks.add @page_error_check
      browser.goto WatirSpec.url_for("font.html")
      expect(@yield).to be true
    end

    it "runs error_checks after Browser#refresh" do
      browser.goto WatirSpec.url_for("font.html")
      @page_error_check = Proc.new { @yield = browser.title == "The font element" }
      browser.error_checks.add @page_error_check
      browser.refresh
      expect(@yield).to be true
    end

    it "runs error_checks after Element#click" do
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      @page_error_check = Proc.new do
        Watir::Wait.while { browser.title.empty? }
        @yield = browser.title == "Non-control elements"
      end
      browser.error_checks.add @page_error_check
      browser.link(index: 1).click
      expect(@yield).to be true
    end

    bug "AutomatedTester: 'known bug with execute script'", :firefox do
      it "runs error_checks after Element#submit" do
        browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
        @page_error_check = Proc.new { @yield = browser.div(id: 'messages').text == 'submit' }
        browser.error_checks.add @page_error_check
        browser.form(id: "new_user").submit
        expect(@yield).to be true
      end
    end

    not_compliant_on :safari do
      bug "Actions Endpoint Not Yet Implemented", :firefox do
        it "runs error_checks after Element#double_click" do
          browser.goto(WatirSpec.url_for("non_control_elements.html"))
          @page_error_check = Proc.new { @yield = browser.title == "Non-control elements" }
          browser.error_checks.add @page_error_check
          browser.div(id: 'html_test').double_click
          expect(@yield).to be true
        end
      end
    end

    not_compliant_on :safari do
      bug "Actions Endpoint Not Yet Implemented", :firefox do
        it "runs error_checks after Element#right_click" do
          browser.goto(WatirSpec.url_for("right_click.html"))
          @page_error_check = Proc.new { @yield = browser.title == "Right Click Test" }
          browser.error_checks.add @page_error_check
          browser.div(id: "click").right_click
          expect(@yield).to be true
        end
      end
    end

    bug "https://github.com/detro/ghostdriver/issues/20", :phantomjs do
      not_compliant_on :safari do
        it "runs error_checks after Alert#ok" do
          browser.goto(WatirSpec.url_for("alerts.html"))
          @page_error_check = Proc.new { @yield = browser.title == "Alerts" }
          browser.error_checks.add @page_error_check
          browser.error_checks.without { browser.button(id: 'alert').click }
          browser.alert.ok
          expect(@yield).to be true
        end

        bug "https://code.google.com/p/chromedriver/issues/detail?id=26", [:chrome, :macosx] do
          it "runs error_checks after Alert#close" do
            browser.goto(WatirSpec.url_for("alerts.html"))
            @page_error_check = Proc.new { @yield = browser.title == "Alerts" }
            browser.error_checks.add @page_error_check
            browser.error_checks.without { browser.button(id: 'alert').click }
            browser.alert.close
            expect(@yield).to be true
          end
        end

        bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1279211", :firefox do
          it "raises UnhandledAlertError error when running error checks with alert present" do
            url = WatirSpec.url_for("alerts.html")
            @page_error_check = Proc.new { browser.url }
            browser.error_checks.add @page_error_check
            browser.goto url
            expect { browser.button(id: "alert").click }.to raise_error(Selenium::WebDriver::Error::UnhandledAlertError)

            not_compliant_on :ff_legacy do
              browser.alert.ok
            end
          end
        end

        it "does not raise error when running error checks using #error_checks#without with alert present" do
          url = WatirSpec.url_for("alerts.html")
          @page_error_check = Proc.new { browser.url }
          browser.error_checks.add @page_error_check
          browser.goto url
          expect { browser.error_checks.without {browser.button(id: "alert").click} }.to_not raise_error
          browser.alert.ok
        end

        it "does not raise error if no error checks are defined with alert present" do
          url = WatirSpec.url_for("alerts.html")
          @page_error_check = Proc.new { browser.url }
          browser.error_checks.add @page_error_check
          browser.goto url
          browser.error_checks.delete @page_error_check
          expect { browser.button(id: "alert").click }.to_not raise_error
          browser.alert.ok
        end
      end
    end

    bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1223277", :firefox do
      it "does not raise error when running error checks on closed window" do
        url = WatirSpec.url_for("window_switching.html")
        @page_error_check = Proc.new { browser.url }
        browser.error_checks.add @page_error_check
        browser.goto url
        browser.a(id: "open").click

        window = browser.window(title: "closeable window")
        window.use
        expect { browser.a(id: "close").click }.to_not raise_error
        browser.window(index: 0).use
      end
    end
  end
end
