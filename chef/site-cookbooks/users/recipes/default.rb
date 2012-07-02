users = data_bag('users')

users.each do |name|
  u = data_bag_item('users', name)

  user(name) do
    gid u['gid'] if u['gid']
    shell u['shell']
    comment u['comment']
    if u['home']
      home u['home']
      supports :manage_home => true
    else
      supports :manage_home => false
    end
  end

  if u['home']
    directory "#{u['home']}/.ssh" do
      owner u['id']
      group u['gid'] || u['id']
      mode '0700'
    end

    if u['ssh_keys']
      template "#{u['home']}/.ssh/authorized_keys" do
        source 'authorized_keys.erb'
        owner u['id']
        group u['gid'] || u['id']
        mode '0600'
        variables :ssh_keys => u['ssh_keys']
      end
    end
  end

  u['groups'].each do |g|
    group g do
      members name
      append true
    end
  end
end
