module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      def delegate(message)
        DelegateToMatcher.new(message)
      end

      class DelegateToMatcher

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
