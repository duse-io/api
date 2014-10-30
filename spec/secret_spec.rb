describe Secret do
  it '' do
    User.create({username: 'server'})
    User.create({username: 'adracus'})
    User.create({username: 'flower-pot'})

    p User.all
  end
end
