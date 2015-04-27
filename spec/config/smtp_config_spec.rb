describe Duse::API::Config::SMTP do
  it 'should be valid if empty' do
    config = Duse::API::Config::SMTP.new
    expect(config.valid?).to be true
  end

  it 'should not be valid if host is set but nothing else' do
    config = Duse::API::Config::SMTP.new host: 'smtp.example.org'
    expect(config.valid?).to be false
    expect(config.errors.full_messages).to eq [
      "Port can't be blank",
      "User can't be blank",
      "Password can't be blank",
      "Domain can't be blank"
    ]
  end

  it 'takes the domain from the email' do
    ClimateControl.modify EMAIL: 'noreply@duse.io' do
      expect(Duse::API::Config.new.smtp.domain).to eq 'duse.io'
    end
  end

  it 'should be enabled if smtp host is set' do
    config = Duse::API::Config::SMTP.new host: 'smtp.example.org'
    expect(config.enabled?).to be true
  end
end

