require_relative 'client'

puts 'Please enter the server IP address:'
address = STDIN.gets.chomp
address = 'localhost' if address.empty?
client = FishClient.new(address: address)
client.start