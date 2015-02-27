require_relative 'setup'

some_number_of = ARGV.pop.to_i
some_number_of = 5 if some_number_of <= 0
puts "firing up #{some_number_of} forks"
some_number_of.times do |n|
  fork do 
    here = File.dirname(__FILE__)
    path = File.join(here, '..', 'test', 'fixtures', 'uncharter.pdf')
    extract(path, n)
  end
end

=begin
Questions:
* What can/should trigger Ruby's GC?
* What's the stack size look like?
* Is Ruby accurately reporting the amount of memory allocated? (how do we compare?) no!
* Can we notify Ruby about memory allocated in C/C++? No! \weep
=end
