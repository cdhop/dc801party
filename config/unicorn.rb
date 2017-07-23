worker_processes 4

working_directory File.expand_path('../../', __FILE__) # available in 0.94.0+

listen 9000, :tcp_nopush => true

timeout 90

pid File.expand_path('tmp/unicorn.pid')

stderr_path File.expand_path('log/unicorn_stderr.log')
stdout_path File.expand_path('log/unicorn_stdout.log')

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

end
