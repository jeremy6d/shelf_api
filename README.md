# shelf_api

It is often the case that software projects require a layer of content management alongside the business application.  While content is usually consumed in a straightforward manner (HTML pages, images, etc.), the rules for organizing the content are often unique to the domain. So you either spend far, far too long hacking the typical turnkey CMS to get that last 10% of domain-specific behavior or you have to deal with the nightmare of the ueber-configurable CMS that does everything unintelligibly.

Instead of spending a ton of time forcing a square peg into a round hole on that last 10%, what you need is a 90% CMS solution that gets out of your way.  Then just write code for the last 10% that is exactly what you need.  After all, we're not the normal Wordpress user; we're comfortable putting gems together with connector Ruby to build something unique to the problem domain.

Shelf is an open-ended content storage and retrieval system designed to help you roll your own CMS with the least amount of coding possible.  This piece of the shelf system sits as a thin layer over the database and handles the retrieval and storage of "resources".  You would then write the server(s) that process GETs, POSTs, etc.  

Resources are documents that have the following features:

* a unique _key_ for looking up a single resource (e.g. "index", "something/something-else/your-mom")
* one or more _associated keys_ for retrieving groups of content needed for a particular resource.  For example, a resource  with a key of "index" might require resources with keys of "header", "body", and "footer" in order to render itself to HTML.  This would require all of these resources to include "index" within their collection of associated keys, so when "index" is looked up it can either pull everything it needs or ONLY get "index", as needed
* a hash that associates content with particular MIME types. So "index" might be accessible as HTML, or as a JPG, or as a piece of JSON for AJAX requests, etc. It's up to the content creator to set these as desired according to domain-specific rules.
* zero or more _tags_ that provide custom details about the resource to be interpreted by the shelf-integrated server (e.g. "requires-authentication", "gallery-image")
* a _cache duration_ working with any number of cache layers

Resources live in a database whose name corresponds typically corresponds to the host, i.e. "shelf-dot-api-dot-org".  Resources are stored in the "resources" collection of the host-named database.

__This is not ready for primetime.__
