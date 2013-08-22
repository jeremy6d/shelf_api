# shelf_api

It is often the case that software projects require a layer of content management alongside the business application.  While content is usually consumed in a straightforward manner (HTML pages, images, etc.), the rules for organizing the content are often unique to the domain, rendering turnkey content management system cumbersome.

Shelf is an open-ended content storage and retrieval system designed to help you roll your own CMS with the least amount of coding possible.  This piece of the shelf system sits as a thin layer over the database and handles the retrieval and storage of "resources".  You would then write the server(s) that process GETs, POSTs, etc.  

Resources are documents that have the following features:

* a unique _key_ for looking up a single resource (e.g. "index", "something/something-else/your-mom")
* one or more _associated keys_ for retrieving groups of content needed for a particular resource.  For example, a resource  with a key of "index" might require resources with keys of "header", "body", and "footer" in order to render itself to HTML.  This would require all of these resources to include "index" within their collection of associated keys, so when "index" is looked up it can either pull everything it needs or ONLY get "index", as needed
* one or more _types_ (e.g. "html", "xml", "png")
* zero or more _tags_ that provide custom details about the resource to be interpreted by the shelf-integrated server (e.g. "requires-authentication", "gallery-image")

Resources live in a database whose name corresponds typically corresponds to the host, i.e. "shelf-dot-api-dot-org".  Resources are stored in the "resources" collection of the host-named database.

__This is not ready for primetime.__
