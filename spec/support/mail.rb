Mail.defaults do
  delivery_method :test
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:each) do
    Mail::TestMailer.deliveries.clear
  end
end

