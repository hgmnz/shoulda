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

  context "delegating to a class variable" do
    should "accept a class var that responds to the message" do
      define_model :example do
        delegate :min, :to => :@@class_array
      end
      #TODO: clean up definition of class var
      class ::Example
        @@class_array = [0, 1, 2]
      end
      assert_accepts delegate(:min).to(:@@class_array), Example.new
    end

    should "reject a class var that doesn't respond to the message" do
      define_model :example do
        delegate :min, :to => :@@class_array
      end
      #TODO: clean up definition of class var
      class ::Example
        @@class_array = [0, 1, 2]
      end
      assert_rejects delegate(:foo).to(:@@class_array), Example.new
    end
  end

  context "delegating to a constant" do
    should "accept a constant that responds to the message" do
      define_model :example do
        delegate :min, :to => :CONSTANT_ARRAY
      end
      #TODO: clean up definition of constant
      class ::Example
        CONSTANT_ARRAY = [0, 1, 2]
      end
      assert_accepts delegate(:min).to(:CONSTANT_ARRAY), Example.new
    end

    should "reject a constant that does not respond to the message" do
      define_model :example do
        delegate :foo, :to => :CONSTANT_ARRAY
      end
      #TODO: clean up definition of constant
      class ::Example
        CONSTANT_ARRAY = [0, 1, 2]
      end
      assert_rejects delegate(:foo).to(:CONSTANT_ARRAY), Example.new
    end
  end

  context "using prefix" do
    should "accept the prefix option set to true" do
      define_model :parent, :name => :string do
        has_many :children
      end
      define_model :child, :parent_id => :integer do
        belongs_to :parent
        delegate :name, :to => :parent, :prefix => true
      end
      @child = Child.create(:parent => Parent.create)
      assert_accepts delegate(:name).to(:parent).with_prefix(true), @child
    end

    should "accept a Symbol prefix" do
      define_model :parent, :name => :string do
        has_many :children
      end
      define_model :child, :parent_id => :integer do
        belongs_to :parent
        delegate :name, :to => :parent, :prefix => :dad
      end
      @child = Child.create(:parent => Parent.create)
      assert_accepts delegate(:name).to(:parent).with_prefix(:dad), @child
    end
  end

  context "using allow_nil" do
    should "accept a nil parent model" do
      define_model :parent, :name => :string do
        has_many :children
      end
      define_model :child, :parent_id => :integer do
        belongs_to :parent
        delegate :name, :to => :parent, :allow_nil => true
      end
      @child = Child.create(:parent => nil)
      assert_accepts delegate(:name).to(:parent).allow_nil(true), @child
    end

    should "accept a nil instance variable" do
      define_model :example do
        def initialize
          @instance_array = nil
        end
        delegate :min, :to => :@instance_array
      end
      assert_accepts delegate(:min).to(:@instance_array).allow_nil, Example.new
    end

    should "accept a nil class variable" do
      define_model :example do
        delegate :min, :to => :@@class_array
      end
      #TODO: clean up definition of class var
      class ::Example
        @@class_array = nil
      end
      assert_accepts delegate(:min).to(:@@class_array).allow_nil, Example.new
    end

    should "accept a nil constant" do
      define_model :example do
        delegate :min, :to => :CONSTANT_ARRAY
      end
      #TODO: clean up definition of constant
      class ::Example
        CONSTANT_ARRAY = nil
      end
      assert_accepts delegate(:min).to(:CONSTANT_ARRAY).allow_nil, Example.new
    end
  end

end
