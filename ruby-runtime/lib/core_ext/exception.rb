# From utilrb's full_message.rb, http://utilrb.rubyforge.org/
# http://gitorious.org/+rock-core-maintainers/orocos-toolchain/rock-utilrb
#
# Copyright (c) 2006-2008
# Sylvain Joyeux <sylvain.joyeux@m4x.org>
# LAAS/CNRS <openrobots@laas.fr>
#
# Released under the BSD license,
# http://gitorious.org/+rock-core-maintainers/orocos-toolchain/rock-utilrb/blobs/master/License.txt

class Exception
  def full_message(options = {}, &block)
    since_matches, until_matches = options[:since], options[:until]

    trace = backtrace
    if since_matches || until_matches
      found_beginning, found_end = !since_matches, false
      trace = trace.find_all do |line|
        found_beginning ||= (line =~ since_matches)
        found_end     ||= (line =~ until_matches) if until_matches
        found_beginning && !found_end
      end
    end

    first, *remaining = if block_given? then trace.find_all(&block)
                        else trace
                        end

    msg = "#{first}: #{message} (#{self.class})"
    unless remaining.empty?
      msg << "\n\tfrom " + remaining.join("\n\tfrom ")
    end

    msg
  end
end
