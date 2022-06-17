class PacketWrapper
  
  attr_accessor :command, :message

  def initialize(command: :general, message: '')
    @command = command
    @message = message
  end

  def dump
    Marshal.dump(self)
  end

  def ==(other)
    other.command == command && other.message == message
  end

end