module Hudson
  class Remote
    def self.add_server(name, options)
      "#{options[:host]}:#{options[:port]}"
    end
  end
end