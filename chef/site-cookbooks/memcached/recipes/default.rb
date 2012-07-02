package "memcached"

service "memcached" do
  action [:stop, :disable]
end

memcached_instance "main"
