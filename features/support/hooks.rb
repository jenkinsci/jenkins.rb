require 'socket'

Before do
  @hudson_cleanup = []
end

After do
  for port in @hudson_cleanup do
    begin
      TCPSocket.open("localhost", port) do |sock|
        sock.write("0")
      end
    rescue
    end
  end
end