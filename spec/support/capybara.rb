require "capybara/cuprite"
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite

# Capybara.register_driver(:cuprite) do |app|
# Capybara::Cuprite::Driver.new(
#   app,
#   window_size: [ 1400, 1400 ],
#   browser_options: {
#     "disable-gpu" => nil,
#     "no-sandbox" => nil
#   }
# )
# end
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [ 1400, 1400 ],
    process_timeout: 10, # lower = faster failure, prevents long hangs
    timeout: 5,          # lower default wait time
    inspector: false,    # disable inspector overhead
    headless: true,      # ensure headless mode
    browser_options: {
      "disable-gpu" => nil,
      "no-sandbox" => nil,
      "disable-dev-shm-usage" => nil,
      "disable-setuid-sandbox" => nil,
      "disable-extensions" => nil,
      "disable-background-networking" => nil,
      "disable-sync" => nil,
      "metrics-recording-only" => nil,
      "mute-audio" => nil,
      "no-first-run" => nil,
      "no-default-browser-check" => nil
    }
  )
end

 # Capybara.javascript_driver = :selenium_chrome
 # Capybara.javascript_driver = :selenium_chrome_headless

 Capybara.register_driver :selenium_chrome_headless_sandboxless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
 end

 Capybara.server = :puma, { Silent: true }
