# Capybara.javascript_driver = :selenium_chrome
Capybara.javascript_driver = :selenium_chrome_headless

Capybara.register_driver :selenium_chrome_headless_sandboxless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
