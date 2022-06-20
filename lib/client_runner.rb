require_relative 'client'

puts 'Please enter the server IP address:'
address = STDIN.gets.chomp
client = FishClient.new(address: address)
client.start