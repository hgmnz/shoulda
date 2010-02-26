module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensure that the message is delegated to an associated model,
      # constant, instance variable or class variable.
      #
      # it { should delegate(:name).to(:parent) }
      # it { should delegate(:name).to(:parent).with_prefix(:parent) }
      # it { should delegate(:name).to(:parent).with_allowed_nil }
      # it { should delegate(:name).to(:@ivar) }
      # it { should delegate(:name).to(:@@class_var) }
      # it { should delegate(:name).to(:CONSTANT) }
      #

      def delegate(message)
        DelegateToMatcher.new(message)
      end

      class DelegateToMatcher

        # Ensures that the message is delegated to the
        # associated model by testing that:
        # * The target responds to the message
        # * The message is sent to the target
        # * The result of the call to the subject and
        # the target are the same.
        #
        # Options:
        # * <tt>to</tt> - association target name
        # * <tt>with_prefix</tt> - tests that the :prefix option is
        #   used by the delegate call.
        # * <tt>with_allowed_nil</tt> - tests that the :allow_nil 
        #   option is used by the delegate call.
        #

        def initialize(message)
          @message = message
        end

        def to(target)
          @target = target
          self
        end

        def with_prefix(prefix)
          @prefix = prefix
          self
        end

        def with_allowed_nil
          @allow_nil = true
          self
        end

        def description
          "delegates #{@message} to #{@target}"
        end

        def expectation
          "#{@subject.inspect} to delegate #{@message} to #{@target}"
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def matches?(subject)
          @subject = subject
          target_responds_to_message? &&
          target_receives_message? &&
          subject_and_target_match_message_result?
        end

        private

        def target_responds_to_message?
          @subject.send(@target).respond_to?(@message)
        end

        def target_receives_message?
          expectation = @subject.__send__(@target).expects(@message).at_least_once
          @subject.__send__(@message)
          expectation.verified?
        end

        def subject_and_target_match_message_result?
          @subject.__send__(@message) ==
            @subject.__send__(@target).__send__(@message)
        end

      end

    end
  end
end
