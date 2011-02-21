# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{socket-motor}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["FIXME (who is writing this software)"]
  s.date = %q{2011-02-18}
  s.default_executable = %q{socket-motor}
  s.description = %q{An async bridge between web sockets and HTTP}
  s.email = %q{FIXME (your e-mail)}
  s.executables = ["socket-motor"]
  s.extra_rdoc_files = ["History.txt", "bin/socket-motor"]
  s.files = [".bnsignore", ".swp", "History.txt", "README.md", "Rakefile", "bin/socket-motor", "example/README", "example/chat_responder.rb", "example/config.ru", "example/example_rack_app.rb", "example/public/js/FABridge.js", "example/public/js/dripdrop.js", "example/public/js/swfobject.js", "example/public/js/web_socket.js", "example/public/swf/WebSocketMain.swf", "example/run.sh", "example/views/index.haml", "lib/socket-motor.rb", "lib/socket-motor/channel_agent.rb", "lib/socket-motor/channel_master.rb", "lib/socket-motor/dripdrop_app.rb", "lib/socket-motor/log_broadcaster.rb", "lib/socket-motor/log_receiver.rb", "lib/socket-motor/messages.rb", "lib/socket-motor/messages/channel_message.rb", "lib/socket-motor/messages/req_rep_message.rb", "lib/socket-motor/proxy_master.rb", "lib/socket-motor/rack_app.rb", "lib/socket-motor/request_agent.rb", "lib/socket-motor/spectra_uuid.rb", "lib/socket-motor/ws_listener.rb", "lib/socket-motor/ws_listener/ws_channel.rb", "lib/socket-motor/ws_listener/ws_connection.rb", "misc/load_test.rb", "misc/web_socket.rb", "spec/channel_agent_spec.rb", "spec/messages/channel_message_spec.rb", "spec/nodelets/ws_listener_spec.rb", "spec/socket-motor_spec.rb", "spec/spec_helper.rb", "test/test_socket-motor.rb", "version.txt"]
  s.homepage = %q{FIXME (project homepage)}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{socket-motor}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{An async bridge between web sockets and HTTP}
  s.test_files = ["test/test_socket-motor.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dripdrop>, [">= 0.9.4"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_runtime_dependency(%q<hashie>, [">= 0.4.0"])
      s.add_development_dependency(%q<bones>, [">= 3.6.5"])
    else
      s.add_dependency(%q<dripdrop>, [">= 0.9.4"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<hashie>, [">= 0.4.0"])
      s.add_dependency(%q<bones>, [">= 3.6.5"])
    end
  else
    s.add_dependency(%q<dripdrop>, [">= 0.9.4"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<hashie>, [">= 0.4.0"])
    s.add_dependency(%q<bones>, [">= 3.6.5"])
  end
end
