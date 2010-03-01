module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensure that the message is delegated to an associated model,
      # constant, instance variable or class variable.
      #
      # it { should delegate(:name).to(:parent) }
      # it { should delegate(:name).to(:parent).with_prefix(:foo) }
      # it { should delegate(:name).to(:parent).allow_nil }
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
        # * The result of the message call to the subject and
        #   the target are the same.
        #
        # Options:
        # * <tt>to</tt> - association target name
        # * <tt>with_prefix</tt> - tests that the :prefix option is
        #   used by the delegate call.
        # * <tt>allow_nil</tt> - tests pass with nil targets.

        def initialize(message)
          @message = message
          @prefix  = ''
        end

        def to(target)
          @target = target
          self
        end

        def with_prefix(prefix = true)
          if prefix == true
            _prefix = "#{@target}_"
          elsif [String, Symbol].include?(prefix.class)
            _prefix = "#{prefix.to_s}_"
          else
            _prefix = ""
          end
          @prefix = _prefix
          self
        end

        def allow_nil(allowed = true)
          @allow_nil = allowed
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
          if !@subject.__send__(@target).nil?
            association_responds_to_message? &&
              subject_and_associated_model_match_message_result?
          else
            @allow_nil
          end
        end

        def match_for_instance_variable?
          if !@subject.instance_variable_get(@target.to_s).nil?
            instance_variable_responds_to_message? &&
              subject_and_instance_variable_match_message_result?
          else
            @allow_nil
          end
        end

        def match_for_class_variable?
          if !@subject.class.__send__(:class_variable_get, @target).nil?
            class_variable_responds_to_message? &&
              subject_and_class_variable_match_message_result?
          else
            @allow_nil
          end
        end

        def match_for_constant?
          if !@subject.class.const_get(@target).nil?
            constant_responds_to_message? &&
              subject_and_constant_match_message_result?
          else
            @allow_nil
          end
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
          @subject.class.const_get(@target).
            respond_to?(@message)
        end

        def subject_and_associated_model_match_message_result?
            @subject.__send__("#{@prefix}#{@message}") ==
              @subject.__send__(@target).__send__(@message)
        end

        def subject_and_instance_variable_match_message_result?
          @subject.__send__("#{@prefix}#{@message}") ==
            @subject.instance_variable_get(@target.to_s).__send__(@message)
        end

        def subject_and_class_variable_match_message_result?
          @subject.__send__("#{@prefix}#{@message}") ==
            @subject.class.
            __send__(:class_variable_get, @target.to_s).
            __send__(@message)
        end

        def subject_and_constant_match_message_result?
          @subject.__send__("#{@prefix}#{@message}") ==
          @subject.class.const_get(@target).
            __send__(@message)
        end

      end

    end
  end
end
