require 'spec_helper'

class LoggerFactory
  attr_accessor :logger

  def foo
    logger.info :foo
  end

  def bar
    logger.info :bar
  end
end

describe Yell::Logger do

  context "a Logger instance" do
    let( :logger ) { Yell::Logger.new }

    context "log methods" do
      subject { logger }

      it { should respond_to :debug }
      it { should respond_to :debug? }

      it { should respond_to :info }
      it { should respond_to :info? }

      it { should respond_to :warn }
      it { should respond_to :warn? }

      it { should respond_to :error }
      it { should respond_to :error? }

      it { should respond_to :fatal }
      it { should respond_to :fatal? }

      it { should respond_to :unknown }
      it { should respond_to :unknown? }
    end

    context "default adapter" do
      let( :adapters ) { logger.instance_variable_get :@adapters }

      it { adapters.size.should == 1 }
      it { adapters.first.should be_kind_of Yell::Adapters::File }
    end
  end

  context "initialize with a :name" do
    let( :name ) { 'test' }

    it "should be added to the repository" do
      logger = Yell.new :name => name

      Yell::Repository[name].should == logger
    end
  end

  context "initialize with :everywhere" do
    let(:object) { Object.new }
    it "should be available from any object" do
      logger = Yell.new :everywhere => true

      object.should respond_to(:logger)
      object.logger.should == logger
    end
  end

  context "initialize with a :filename" do
    it "should call adapter with :file" do
      mock.proxy( Yell::Adapters::File ).new( :filename => 'test.log' )

      Yell::Logger.new 'test.log'
    end
  end

  context "initialize with a :stdout adapter" do
    before do
      mock.proxy( Yell::Adapters::Stdout ).new( anything )
    end

    it "should call adapter with STDOUT" do
      Yell::Logger.new STDOUT
    end

    it "should call adapter with :stdout" do
      Yell::Logger.new :stdout
    end
  end

  context "initialize with a :stderr adapter" do
    before do
      mock.proxy( Yell::Adapters::Stderr ).new( anything )
    end

    it "should call adapter with STDERR" do
      Yell::Logger.new STDERR
    end

    it "should call adapter with :stderr" do
      Yell::Logger.new :stderr
    end
  end

  context "initialize with a block" do
    let( :level ) { Yell::Level.new :error }
    let( :adapter ) { Yell::Adapters::Stdout.new }

    let( :logger ) do
      Yell::Logger.new do |l|
        l.level = level
        l.adapter adapter
      end
    end

    it "should set the level" do
      logger.level.should == level
    end

    it "should define adapter" do
      adapters = logger.instance_variable_get :@adapters

      adapters.size.should == 1
      adapters.first.should == adapter
    end
  end

  context "initialize with :adapters option" do
    let( :logger ) do
      Yell::Logger.new :adapters => [ :stdout, { :stderr => {:level => :error} } ]
    end

    let( :adapters ) { logger.instance_variable_get :@adapters }
    let( :stdout ) { adapters.first }
    let( :stderr ) { adapters.last }

    it "should define those adapters" do
      adapters.size.should == 2

      stdout.should be_kind_of Yell::Adapters::Stdout
      stderr.should be_kind_of Yell::Adapters::Stderr
    end

    it "should pass :level to :stderr adapter" do
      stderr.level.at?(:warn).should be_false
      stderr.level.at?(:error).should be_true
      stderr.level.at?(:fatal).should be_true
    end
  end

  context "caller's :file, :line and :method" do
    let( :adapter ) { Yell::Adapters::Stdout.new :format => "%F, %n: %M" }
    let( :logger ) { Yell::Logger.new { |l| l.adapter adapter } }

    it "should write correctly" do
      factory = LoggerFactory.new
      factory.logger = logger

      mock( adapter.send(:stream) ).write( "#{__FILE__}, 7: foo\n" )
      mock( adapter.send(:stream) ).write( "#{__FILE__}, 11: bar\n" )

      factory.foo
      factory.bar
    end
  end

end

