# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # This class provides the basic interface for all allowed 
    # operations on any adapter implementation.
    #
    # Other adapters should inherit from it for the methods used 
    # by the {Yell::Logger}.
    class Base
      include Yell::Level::Helpers

      def initialize( options = {}, &block )
        self.level = options[:level]

        block.call(self) if block
      end

      # The main method for calling the adapter.
      #
      # The method receives the log `event` and determines whether to 
      # actually write or not.
      def write( event )
        write!( event ) if write?( event )
      end

      # Close the adapter (stream, connection, etc).
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def close
        raise 'Not implemented'
      end


      private

      # The perform the actual write.
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def write!( event )
        raise 'Not implemented'
      end

      # Determine whether to write at the given severity.
      #
      # @example
      #   write? Yell::Event.new( 'INFO', 'Hwllo Wold!' )
      #
      # @param [Yell::Event] event The log event
      #
      # @return [Boolean] true or false
      def write?( event )
        @level.nil? || @level.at?( event.level )
      end

    end

  end
end

