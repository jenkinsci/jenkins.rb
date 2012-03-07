class Hash
  def with_clean_keys
    self.inject({}) do |mem, (key, value)|
      clean_key = key.to_s.gsub(/-/,"_").to_sym
      mem[clean_key] = value
      mem
    end
  end
end