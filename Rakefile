
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

depend_on 'dripdrop', '0.7.1'
depend_on 'json'
depend_on 'hashie'

Bones {
  name     'socket-motor'
  authors  'FIXME (who is writing this software)'
  email    'FIXME (your e-mail)'
  url      'FIXME (project homepage)'
}

