require_relative 'test_helper'
require_relative "../use_cases/fetch_resource"

class TestFetchResource < MiniTest::Unit::TestCase
  def setup
    @db_mock = Minitest::Mock.new  
    @db_mock.expect :perform!, :the_resource
    @db_mock.expect :db_name=, "site-dot-com", ["site-dot-com"]
    @db_mock.expect :collection=, "resources", ["resources"]
    @db_mock.expect :selectors=, { key: "index", 
                                   type: "text/html" },
                                 [ { key: "index", 
                                     type: "html" } ]
    @db_mock.expect :perform!, :the_resource

    @perform_use_case = ->(uri) {
      QueryMongo.stub :new, @db_mock, %w(127.0.0.1) do
        assert_equal :the_resource, 
                     FetchResource.new(uri).
                                   perform!
      end
    } 
  end

  def test_basic_fetch
    @perform_use_case.call "site.com/index.html"
  end

  def test_fetch_without_type                  
    @perform_use_case.call "site.com/index"
  end

  def test_fetch_without_specific_path
    @perform_use_case.call "site.com"
  end
end