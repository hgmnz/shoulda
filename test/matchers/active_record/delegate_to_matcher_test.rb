require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class DelegateToMatcherTest < ActiveSupport::TestCase # :nodoc:

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
