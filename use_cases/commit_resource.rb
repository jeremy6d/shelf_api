# a resource has:
# - a uri
# - a hash of resource-specific pure content inside
#   e.g. { "title" => { "type" => "text", "content" => "this is the title!" },
#          "body" => { "type" => "text", "content" => "this is the body!" }
# - a hash of format types
#   e.g. { "html" => { "layout_uri" => "/uri/to/html/layout" },
#          "xml" => { "content" => "<xml><title><pre:title  q /></title></xml>" } }
# - tags
# - affiliated_uris
# - ttl (cache time to live)
# - etag
# - content_code
# - creation time
# - affiliated_resources (hash of resources saved alongside this resource)
#   e.g. { 
#          "/uri/to/first/affiliate" => { "title" => "blah", "body" => "this" },
#          "/uri/to/second/affiliate" => { "something" => "something else" } 
#        } 

require_relative '../../lib/mongo_transaction'
require 'time'
require 'ruby-debug'

module CoreApplication
  class CommitResource < MongoTransaction
    def initialize db, hash = {}
      super(db)
      puts hash.fetch "uri", "no uri provided"
      raise "Invalid resource" unless hash.is_a? Hash
      @uri = hash.fetch("uri")
      raise "no uri provided" if @uri.nil? || @uri == ""
      @content = hash.fetch "content", {}
      @formats = hash.fetch "formats", {}
      @tags = hash.fetch "tags", []
      @ttl = hash.fetch("ttl", 3600).to_i
      @affiliate_uris = hash.fetch("affiliate_uris", [@uri])

      set_affiliates! affiliates if affiliates = hash.fetch('affiliates', false)
    end

    # commit several related entities at once
    def perform!
      resource.merge  etag: resource.hash,
                      updated_at: Time.now.httpdate

      @result = session.with(safe: true)[:resources].
                       find(uri: @uri).
                       upsert({ "$set" => resource,
                                "$addToSet" => { 
                                  "affiliate_uris" => { 
                                    "$each" => @affiliate_uris 
                                  } 
                                }
                              })


      #may do this in background
      persist_affiliates!

      @result["err"].nil?
    end

    def newly_created?
      @result.try(:fetch, "updatedExisting", "false") == "true"
    end

  protected
    def persist_affiliates!
      return if @commits.nil? || @commits.empty?
      @commits.each { |c| c.perform! }
    end

    def resource
      { uri: @uri, 
        content: @content,
        formats: @formats,
        tags: @tags,
        ttl: @ttl }
    end

    def set_affiliates! affiliate_hash
      @affilaliate_uris = [@uri]
      @commits = []
      affiliate_hash.each do |uri, content|
        @affiliate_uris << uri
        @commits << CommitResource.new(@current_db, {
                                          uri: uri,
                                          content: content,
                                          affiliate_uris: [uri, @uri]
                                        })
end
    end

    def content_code_for doc
      doc_clone = doc.dup
      doc_clone.delete "content_code"
      doc_clone.content.hash
    end
  end
end