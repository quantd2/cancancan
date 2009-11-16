require File.dirname(__FILE__) + '/../spec_helper'

describe CanCan::Ability do
  before(:each) do
    @ability_class = Class.new
    @ability_class.send(:include, CanCan::Ability)
    @ability = @ability_class.new
  end
  
  it "should be able to :read anything" do
    @ability_class.can :read, :all
    @ability.can?(:read, String).should be_true
    @ability.can?(:read, 123).should be_true
  end
  
  it "should not have permission to do something it doesn't know about" do
    @ability.can?(:foodfight, String).should be_false
  end
  
  it "should return what block returns on a can call" do
    @ability_class.can :read, :all
    @ability_class.can :read, Symbol do |sym|
      sym
    end
    @ability.can?(:read, Symbol).should be_nil
    @ability.can?(:read, :some_symbol).should == :some_symbol
  end
  
  it "should pass class with object if :all objects are accepted" do
    @ability_class.can :preview, :all do |object_class, object|
      [object_class, object]
    end
    @ability.can?(:preview, 123).should == [Fixnum, 123]
  end
  
  it "should pass class with no object if :all objects are accepted and class is passed directly" do
    @ability_class.can :preview, :all do |object_class, object|
      [object_class, object]
    end
    @ability.can?(:preview, Hash).should == [Hash, nil]
  end
  
  it "should pass action and object for global manage actions" do
    @ability_class.can :manage, Array do |action, object|
      [action, object]
    end
    @ability.can?(:stuff, [1, 2]).should == [:stuff, [1, 2]]
    @ability.can?(:stuff, Array).should == [:stuff, nil]
  end
  
  it "should alias update or destroy actions to modify action" do
    @ability_class.alias_action :update, :destroy, :to => :modify
    @ability_class.can :modify, :all do |object_class, object|
      :modify_called
    end
    @ability.can?(:update, 123).should == :modify_called
    @ability.can?(:destroy, 123).should == :modify_called
  end
  
  it "should return block result for action, object_class, and object for any action" do
    @ability_class.can :manage, :all do |action, object_class, object|
      [action, object_class, object]
    end
    @ability.can?(:foo, 123).should == [:foo, Fixnum, 123]
    @ability.can?(:bar, Fixnum).should == [:bar, Fixnum, nil]
  end
  
  it "should automatically alias index and show into read calls" do
    @ability_class.can :read, :all
    @ability.can?(:index, 123).should be_true
    @ability.can?(:show, 123).should be_true
  end
  
  it "should automatically alias new and edit into create and update respectively" do
    @ability_class.can(:create, :all) { :create_called }
    @ability_class.can(:update, :all) { :update_called }
    @ability.can?(:new, 123).should == :create_called
    @ability.can?(:edit, 123).should == :update_called
  end
end
