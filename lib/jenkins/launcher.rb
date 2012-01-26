module Jenkins

  # Launch processes on build slaves. No functionality is currently exposed
  class Launcher
    include Jenkins::Plugin::Wrapper
    wrapper_for Java.hudson.Launcher

    class Proc
      include Jenkins::Plugin::Wrapper

      def alive?
        @native.isAlive()
      end

      def join
        @native.join()
      end

      def kill
        @native.kill()
        nil
      end

      def stdin
        @native.getStdin().to_io
      end

      def stdout
        @native.getStdout().to_io
      end

      def stderr
        @native.getStderr().to_io
      end
    end

    # execute([env,] command... [,options]) -> fixnum
    def execute(*args)
      spawn(*args).join
    end

    # spawn([env,] command... [,options]) -> proc
    def spawn(*args)
      env, cmd, options = scan_args(args)

      starter = @native.launch()
      starter.envs(env)
      if opt_chdir = options[:chdir]
        starter.pwd(opt_chdir.to_s)
      end
      if opt_in = options[:in]
        starter.stdin(opt_in.to_inputstream)
      end
      if opt_out = options[:out]
        if opt_out.is_a?(Jenkins::Model::Listener)
          starter.stdout(Jenkins::Plugin.instance.export(opt_out))
        else
          starter.stdout(opt_out.to_outputstream)
        end
      end
      if opt_err = options[:err]
        starter.stderr(opt_err.to_outputstream)
      end
      case cmd
      when Array
        starter.cmds(cmd)
      else
        begin
          # when we are on 1.432, we can use cmdAsSingleString
          starter.cmdAsSingleString(cmd.to_s)
        rescue NoMethodError
          # http://d.hatena.ne.jp/sikakura/20110324/1300977208 is doing
          # Arrays.asList(str.split(" ")) which should be wrong.
          require 'shellwords'
          starter.cmds(*Shellwords.split(cmd.to_s))
        end
      end
      Proc.new(starter.start())
    end

  private

    def scan_args(args)
      if args.last
        if Hash === args.last
          opt = args.pop
        elsif args.last.respond_to?(:to_hash)
          opt = args.pop.to_hash
        end
      end
      if args.first
        if Hash === args.first
          env = args.shift
        elsif args.first.respond_to?(:to_hash)
          env = args.shift.to_hash
        end
        if env
          env = env.inject({}) { |r, (key, value)| r[key.to_s] = value.to_s; r }
        end
      end
      if args.length == 1
        cmd = args.first
      else
        cmd = args
      end
      [env || {}, cmd, opt || {}]
    end
  end
end
