# shopify

## Links

* Gem: [http://gemcutter.org/gems/shopify](http://gemcutter.org/gems/shopify)
* Source: [http://github.com/dcparker/shopify](http://github.com/dcparker/shopify)
* Author: [Daniel Parker](http://github.com/dcparker) from [BehindLogic](http://behindlogic.com)
* Shopify API Documentation: [http://api.shopify.com/](http://api.shopify.com/)

## Features

* Read any kind of data from Shopify, but no support built-in yet to save data back to Shopify.
* Thread-safe: You can connect to multiple shops in the same application.

## Example Usage:

    shop = Shopify.new('store_name', 'api-key', 'api-secret', 'auth-token')
    order = shop.orders(:limit => 1)[0] # => gets first order
    order.line_items                    # => the line items within that order
    order.fulfillments                  # => gets all fulfillments related to this order
    blogs = shop.blogs                  # => gets all blogs for this shop
    articles = blogs[0].articles        # => gets all the articles in this blog
    articles[0].comments                # => gets the comments for that article
    shop.products                       # => get all products in this shop
    ... and much more ... :)

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009 BehindLogic. See LICENSE for details.
