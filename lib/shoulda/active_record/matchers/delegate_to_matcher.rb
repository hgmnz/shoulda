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
        # associated model, constant, instance variable
        # or class variable by testing that:
        # * The target responds to the message
        # * The target receives the message
        # * The result of the message call to the subject and
        #   the target are the same.
        #
        # Options:
        # * <tt>to</tt> - association target name
        # * <tt>with_prefix</tt> - tests that the :prefix option is
        #   used by the delegate call.
        # * <tt>with_allowed_nil</tt> - tests that there is no failure
        #   when the target is nil.

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
          if @subject.class.reflect_on_association(@target)
            match_for_associated_model?
          elsif @subject.instance_variables.include?(@target.to_s)
            match_for_instance_variable?
          elsif @subject.class.class_variables.include?(@target.to_s)
            match_for_class_variable?
          elsif @subject.class.constants.include?(@target.to_s)
            match_for_constant?
          end
        end

        def match_for_associated_model?
          association_responds_to_message? &&
            subject_and_associated_model_match_message_result?
        end

        def match_for_instance_variable?
          instance_variable_responds_to_message? &&
            subject_and_instance_variable_match_message_result?
        end

        def match_for_class_variable?
          class_variable_responds_to_message? &&
            subject_and_class_variable_match_message_result?
        end

        def match_for_constant?
          constant_responds_to_message? &&
            subject_and_constant_match_message_result?
        end

        private

        def association_responds_to_message?
          @subject.__send__(@target).respond_to?(@message)
        end

        def instance_variable_responds_to_message?
          @subject.instance_variable_get(@target.to_s).respond_to?(@message)
        end

        def class_variable_responds_to_message?
          @subject.class.__send__(:class_variable_get, @target).
            respond_to?(@message)
        end

        def constant_responds_to_message?
          eval("#{@subject.class}::#{@target.to_s}").
            respond_to?(@message)
        end

        def subject_and_associated_model_match_message_result?
          @subject.__send__(@message) ==
            @subject.__send__(@target).__send__(@message)
        end

        def subject_and_instance_variable_match_message_result?
          @subject.__send__(@message) ==
            @subject.instance_variable_get(@target.to_s).__send__(@message)
        end

        def subject_and_class_variable_match_message_result?
          @subject.__send__(@message) ==
            @subject.class.
            __send__(:class_variable_get, @target.to_s).
            __send__(@message)
        end

        def subject_and_constant_match_message_result?
          @subject.__send__(@message) ==
          eval("#{@subject.class}::#{@target.to_s}").
            __send__(@message)
        end

      end

    end
  end
end
