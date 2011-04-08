
module Matchers
  RSpec::Matchers.define :contain do |expected_text|
    match do |text|
      text.index expected_text
    end
  end
end

World(Matchers)
