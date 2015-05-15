describe Duse::Models::User do
  it 'should not be valid if a user with the same username already exists' do
    first_user = create(:user)
    user = build(:user, username: first_user.username)

    expect(user.valid?).to be false
  end
end

