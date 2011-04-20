# Copyright 2010 Sean Cribbs  and Basho Technologies, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe "Siblings" do
  before :all do
    $expect_verbose = true
    if $test_server
      @web_port = 9000
      $test_server.start
    end
  end

  before do
    @web_port ||= 8098
    @client = Riak::Client.new(:http_port => @web_port)
  end

  after do
    $test_server.recycle if $test_server.started?
  end

  it 'should not save store an object in conflict' do
    @client['test'].props # Well *this* should work...
    c1 = Riak::Client.new(:http_port => @web_port)
    c2 = Riak::Client.new(:http_port => @web_port)

    # Create a conflicting object
    [c1, c2].each_with_index do |client, i|
      o = client['test'].new('conflicting')
      o.content_type = "application/json"
      o.data = "#{i}"
      o.store
    end

    conflicted = @client['test']['conflicting']
    conflicted.conflict?.should == true
    conflicted.siblings.size.should == 2
    p conflicted.store
  end
end
