module Shopify
  autoload :Session,          'shopify/session'
  autoload :Shop,             'shopify/shop'
  autoload :Product,          'shopify/product'
  autoload :Variant,          'shopify/product'
  autoload :Image,            'shopify/product'
  autoload :Order,            'shopify/order'
  autoload :LineItem,         'shopify/order'
  autoload :ShippingLine,     'shopify/order'
  autoload :CustomCollection, 'shopify/order'
  autoload :ShippingAddress,  'shopify/address'
  autoload :BillingAddress,   'shopify/address'
  autoload :Country,          'shopify/address'
  autoload :Province,         'shopify/address'
  autoload :Sale,             'shopify/sale'
  autoload :Authorization,    'shopify/sale'
  autoload :Payment,          'shopify/sale'
  autoload :Page,             'shopify/site'
  autoload :Blog,             'shopify/site'
  autoload :Article,          'shopify/site'

  class << self
    attr_reader :key, :secret

    # Lists the session stack.
    def sessions
      @sessions ||= []
    end

    # Returns the last session on the sessions stack.
    def current_session
      sessions.last
    end

    # Injects the generated site (with basic auth params) into the ActiveResource::Base subclasses.
    def apply_current_session!
      current_session.apply!
    end

    # Perform a block within a specific session, and reset the current session to the previous after execution.
    def with_session(session,&block)
      sessions << session
        apply_current_session!
        result = yield
      sessions.pop
      apply_current_session!
      return result
    end
  end
end

# To fix a silly bug in ActiveResource loading... :(
module Enumerable # :nodoc: all
  def group_by
  end
end

# Load ActiveResource
require 'active_resource'
module ActiveResource # :nodoc: all
  class Base
    class << self
      def site
        # Not using superclass_delegating_reader because don't want subclasses to modify superclass instance
        #
        # With superclass_delegating_reader
        #
        #   Parent.site = 'http://anonymous@test.com'
        #   Subclass.site # => 'http://anonymous@test.com'
        #   Subclass.site.user = 'david'
        #   Parent.site # => 'http://david@test.com'
        #
        # Without superclass_delegating_reader (expected behaviour)
        #
        #   Parent.site = 'http://anonymous@test.com'
        #   Subclass.site # => 'http://anonymous@test.com'
        #   Subclass.site.user = 'david' # => TypeError: can't modify frozen object
        #
        if defined?(@site)
          @site
        elsif superclass != Object && superclass.site
          superclass.site.dup.freeze
        end
      end
    end
  end
end
