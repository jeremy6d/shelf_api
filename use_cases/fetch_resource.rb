# Title: Fetch resource
# Primary Actor: Use case "Serve Get"
# Level: Core Application

# Goal: retrieve a document from the MongoDB resources collection
# Normal Flow:
#   1. external system invokes use case with a db, a collection, and a query
#   2. system passes query, db and collection to mongo
#   3. mongo returns documents matching
#   4. system returns first matching document
# Document not found:
#   3. mongo returns empty array
#   4. system returns nil

require_relative './query_mongo'

class FetchResource
  def initialize uri, options = {}
    process_options! options
    site, key, type = process_uri! uri

    @query = case @db_config[:driver]
    when :moped
      QueryMongo.new @db_config[:nodes]
    else
      raise "unrecognized database driver!"
    end
    
    @query.db_name = sanitize_db_name site
    @query.collection = 'resources'
    selector_hash = { key: key,
                      type: type }
    selector_hash.merge(tags: @tags) unless @tags.nil? || 
                                            @tags.empty?
    @query.selectors = selector_hash
    true
  end

  def perform!
    @query.perform!.tap do |result|
      raise "Resource not found" unless result
    end
  end

protected
  def sanitize_db_name name
    name.split(/\//).
         find { |e| /\./.match e }.
         gsub(/\./, "-dot-")
  end

  def process_options! options
    @db_config = { driver: :moped, 
                   nodes: %w(127.0.0.1),
                   collection: "resources" }
    @db_config.merge! options[:db] if options[:db]
    @tags = options[:tags] || []
  end

  def process_uri! uri
    #TODO: would be cool to use tilt here to process templating langs
    host, path = uri.gsub(/https?\:\/\//, "").split("/")
    path ||= "index"
    path = [path].flatten.join("/")
    key, type = path.split(".")
    type ||= "html"
    [host, key, type]
  end
end