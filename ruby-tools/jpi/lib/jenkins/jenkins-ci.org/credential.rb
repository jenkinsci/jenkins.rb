module Jenkins
  class CiOrg
    # credential to access jenkins-ci.org
    # TODO: move it elsewhere
    class Credential
      CREDENTIAL = File.expand_path("~/.jenkins-ci.org")

      def initialize
        @props = {}

        if File.exists?(CREDENTIAL) then
          File.open(CREDENTIAL,'r') do |f|
            f.each_line do |l|
              if l[0]=='#' then
                return  # comment
              end

              k,v = l.split("=",2)
              @props[k]=v.strip
            end
          end
        end
      end

      # do we already have the credential?
      def has_credential?
        @props["userName"] && @props["password"]
      end

      def user_name
        @props["userName"]
      end

      def password
        @props["password"]
      end
    end
  end
end