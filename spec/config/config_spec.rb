describe Duse::API::Config do
  it 'should not be valid if empty' do
    config = Duse::API::Config.new
    expect(config.valid?).to be false
    expect(config.errors.full_messages).to eq [
      "Secret key can't be blank",
      "Host can't be blank",
      "Email can't be blank"
    ]
  end

  it 'should return false if no sentry dsn is set' do
    expect(Duse::API::Config.new.use_sentry?).to be false
  end

  it 'should return true if a sentry dsn is set' do
    expect(Duse::API::Config.new(sentry_dsn: 'test').use_sentry?).to be true
  end

  it 'should return http by default since ssl is false' do
    config = Duse::API::Config.new
    expect(config.ssl?).to be false
    expect(config.protocol).to eq 'http'
  end

  it 'should return https when ssl is true' do
    config = Duse::API::Config.new(ssl: 'true')
    expect(config.ssl?).to be true
    expect(config.protocol).to eq 'https'
  end
end

