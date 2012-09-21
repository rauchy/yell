# encoding: utf-8

module Yell #:nodoc:

  # The +Yell::Logger+ is your entrypoint. Anything onwards is derived from here.
  #
  # A +Yell::Logger+ instance holds all your adapters and sends the log events 
  # to them if applicable. There are multiple ways of how to create a new logger.
  class Logger
    include Yell::Level::Helpers

    # The name of the logger instance
    attr_reader :name

    # Initialize a new Logger
    #
    # @example A standard file logger
    #   Yell::Logger.new 'development.log'
    #
    # @example A standard datefile logger
    #   Yell::Logger.new :datefile
    #   Yell::Logger.new :datefile, 'development.log'
    #
    # @example Setting the log level
    #   Yell::Logger.new :level => :warn
    #
    #   Yell::Logger.new do |l|
    #     l.level = :warn
    #   end
    #
    # @example Combined settings
    #   Yell::Logger.new 'development.log', :level => :warn
    #
    #   Yell::Logger.new :datefile, 'development.log' do |l|
    #     l.level = :info
    #   end
    def initialize( *args, &block )
      @adapters = []

      # extract options
      @options = args.last.is_a?(Hash) ? args.pop : {}

      # adapters may be passed in the options
      _extract_adapters!( @options )

      # check if filename was given as argument and put it into the @options
      if args.last.is_a?( String )
        @options[:filename] = args.pop unless @options[:filename]
      end

      # set the log level when given
      self.level = @options[:level]

      # include this logger to any object if 'everywhere' is defined
      if !!@options[:everywhere]
        include_everywhere!
      elsif @options[:name]
        # set the logger's name
        self.name = @options[:name]
      end

      # extract adapter
      self.adapter args.pop if args.any?

      # eval the given block
      _call( &block ) if block

      # default adapter when none defined
      self.adapter :file if @adapters.empty?
    end

    # Define an adapter to be used for logging.
    #
    # @example Standard adapter
    #   adapter :file
    #
    # @example Standard adapter with filename
    #   adapter :file, 'development.log'
    #
    #   # Alternative notation for filename in options
    #   adapter :file, :filename => 'developent.log'
    #
    # @example Standard adapter with filename and additional options
    #   adapter :file, 'development.log', :level => :warn
    #
    # @example Set the adapter directly from an adapter instance
    #   adapter( Yell::Adapter::File.new )
    #
    # @param [Symbol] type The type of the adapter, may be `:file` or `:datefile` (default `:file`)
    # @return [Yell::Adapter] The instance
    #
    #
    # @raise [Yell::NoSuchAdapter] Will be thrown when the adapter is not defined
    def adapter( type = :file, *args, &block )
      options = [@options, *args].inject( Hash.new ) do |h, c|
        h.merge( c.is_a?(String) ? {:filename => c} : c  )
      end

      @adapters << Yell::Adapters.new( type, options, &block )
    end

    def name=( val )
      Yell::Repository[val] = self
    end

    # Deprecated: Use attr_reader in future
    def level( val = nil )
      if val.nil?
        @level
      else
        # deprecated, but should still work
        Yell._deprecate( "0.5.0", "Use :level= for setting the log level",
          :before => "Yell::Logger.new { level :info }",
          :after  => "Yell::Logger.new { |l| l.level = :info }"
        )

        @level = Yell::Level.new( val )
      end

    end
    # Convenience method for resetting all adapters of the Logger.
    def close
      @adapters.each(&:close)
    end

    # Creates instance methods for every log level:
    #   `debug` and `debug?`
    #   `info` and `info?`
    #   `warn` and `warn?`
    #   `error` and `error?`
    #   `unknown` and `unknown?`
    Yell::Severities.each_with_index do |s, index|
      name = s.downcase

      class_eval <<-EOS, __FILE__, __LINE__
        def #{name}?; @level.at?(#{index}); end     # def info?; @level.at?(1); end
                                                    #
        def #{name}( m = nil, o = {}, &b )          # def info( m = nil, o = {}, &b )
          return false unless #{name}?              #   return false unless info?
          write Yell::Event.new(#{index}, m, o, &b) #   write Yell::Event.new(1, m, o, &b)
                                                    #
          true                                      #   true
        end                                         # end
      EOS
    end


    private

    def _call( &block )
      if block.arity == 0
        Yell._deprecate( "0.5.0", "Yell::Logger.new with block expects argument now",
          :before => "Yell::Logger.new { adapter STDOUT }",
          :after  => "Yell::Logger.new { |l| l.adapter STDOUT }"
        )

        # deprecated, but should still work
        instance_eval( &block )
      else
        block.call(self)
      end
    end

    # The :adapters key may be passed to the options hash. It may appear in 
    # multiple variations:
    #
    # @example
    #   options = { :adapters => [:stdout, :stderr] }
    #
    # @example
    #   options = { :adapters => [:stdout => {:level => :info}, :stderr => {:level => :error}]
    def _extract_adapters!( opts )
      ( opts.delete( :adapters ) || [] ).each do |a|
        case a
          when String, Symbol then adapter( a )
          else a.each { |n, o| adapter( n, o || {} ) }
        end
      end
    end

    # Cycles all the adapters and writes the message
    def write( event )
      @adapters.each { |a| a.write(event) }
    end

    def include_everywhere!
      self.name = 'General'

      Kernel.module_eval do
        def logger
          Yell['General']
        end
      end
    end
  end
end

