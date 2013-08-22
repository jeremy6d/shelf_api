require 'moped'

class QueryMongo
  attr_writer :db_name, :collection, :selectors
  attr_reader :result

  def initialize config_file
    @nodes = nodes
  end

  def perform!
    %w(db_name collection selectors).each do |field|
      raise "no #{field} specified" unless instance_variable_get("@#{field}}")
    end

    @result = session[@collection].find(@query)
  end

protected
  def session
    @session ||= Moped::Session.new(@nodes)
  end
end