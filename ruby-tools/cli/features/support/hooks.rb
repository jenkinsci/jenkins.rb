require 'socket'

Before do
  @jenkins_cleanup = []
end

After do
  for port in @jenkins_cleanup do
    begin
      TCPSocket.open("localhost", port) do |sock|
        sock.write("0")
      end
    rescue
    end
  end
end