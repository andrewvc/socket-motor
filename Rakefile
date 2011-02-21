
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'


Bones {
  name     'socket-motor'
  authors  'FIXME (who is writing this software)'
  email    'FIXME (your e-mail)'
  url      'FIXME (project homepage)'

  depend_on 'dripdrop', '>= 0.9.4'
  depend_on 'json'
  depend_on 'hashie'
}

