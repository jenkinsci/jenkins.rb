require 'rack/handler/servlet'

module Jenkins
  # By including this module into your model class and defining the Rack-compatible call method,
  # you can handle requests within your model object through a Rack application, effectively making
  # Jenkins a rack server.
  module RackSupport
    include Java.jenkins.ruby.DoDynamic

    def doDynamic(request, response)
      Plugin.instance.peer.rack(Rack::Handler::Servlet.new(self))
    end
  end
end