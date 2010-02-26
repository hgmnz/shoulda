require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class DelegateToMatcherTest < ActiveSupport::TestCase # :nodoc:

  context "delegating to an associated model" do
    should "accept a target that responds to the delegated method" do
      define_model :parent, :name => :string do
        has_many :children
      end
      define_model :child, :parent_id => :integer do
        belongs_to :parent
        delegate :name, :to => :parent
      end
      @child = Child.create(:parent => Parent.create)
      assert_accepts delegate(:name).to(:parent), @child
    end

    should "not accept a target that responds to the delegated method" do
      define_model :parent do
        has_many :children
      end
      define_model :child, :parent_id => :integer do
        belongs_to :parent
        delegate :name, :to => :parent
      end
      @child = Child.create(:parent => Parent.create)
      assert_rejects delegate(:name).to(:parent), @child
    end
  end

  context "delegating to an instance variable" do
    should "accept an instance var that responds to the message" do
      define_model :example do
        def initialize
          @instance_array = [0, 1, 2]
        end
        delegate :min, :to => :@instance_array
      end
      assert_accepts delegate(:min).to(:@instance_array), Example.new
    end

    should "not accept an instance var that doesn't respond to the message" do
      define_model :example do
        def initialize
          @instance_array = [0, 1, 2]
        end
        delegate :foo, :to => :@instance_array
      end
      assert_rejects delegate(:foo).to(:@instance_array), Example.new
    end
  end

end
