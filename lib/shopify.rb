include_path = File.expand_path(File.dirname(__FILE__))
$:.unshift(include_path) unless $:.include?(include_path)
require 'shopify/support'

# Class: Shopify
# Usage:
#   shop = Shopify.new(host, [key, [secret, [token]]])
#   shop.orders
# TODO: Make the object remember the results of queries such as shop.orders when called without parameters,
#       and reload only when you call shop.orders(true)
class Shopify
  attr_reader :host

  def initialize(host, key=nil, secret=nil, token=nil)
    @default_options = {}
    extend HTTParty::ClassMethods

    host.gsub!(/https?:\/\//, '') # remove http(s)://
    @host = host.include?('.') ? host : "#{host}.myshopify.com" # extend url to myshopify.com if no host is given
    @key    = key
    @secret = secret
    @token  = token
    setup
  end

  def needs_authorization?
    ![@host, @key, @secret, @token].all?
  end

  def authorize!(token)
    @token = token
    setup
  end

  def authorization_url(mode='w')
    "http://#{@host}/admin/api/auth?api_key=#{@key}&mode=#{mode}"
  end

  def setup
    unless needs_authorization?
      base_uri "http://#{@host}/admin"
      basic_auth @key, Digest::MD5.hexdigest("#{@secret.chomp}#{@token.chomp}")
      format :xml
    end
  end
  private :setup

  ##############################
  ##  Shopify Object Classes  ##
  ##############################

  # /admin/blogs.xml
  class Blog < ShopifyModel
    top_level
    attr_accessor :commentable, :feedburner, :feedburner_locations, :handle, :id, :shop_id, :title, :updated_at
    
    # Get all articles in this blog.
    def articles
    end
  end

  # /admin/blogs/[blog_id]/articles.xml
  class Article < ShopifyModel
    children_of Blog
    attr_accessor :author, :blog_id, :body, :body_html, :created_at, :id, :published_at, :title, :updated_at
    def comments(query_params={})
      Shopify.comments(query_params.merge(:article_id => id, :blog_id => blog_id))
    end
  end

  # /admin/comments.xml?article_id=*&blog_id=*
  class Comment < ShopifyModel
    top_level
    attr_accessor :article_id, :author, :blog_id, :body, :body_html, :created_at, :email, :id, :ip, :published_at, :shop_id, :status, :updated_at, :user_agent
  end

  # /admin/collects.xml
  class Collect < ShopifyModel
    top_level
    attr_accessor :collection_id, :featured, :id, :position, :product_id
  end

  # /admin/countries.xml
  class Country < ShopifyModel
    top_level
    attr_accessor :code, :id, :name, :tax

    # Get all province divisions within this country.
    def provinces
    end
  end

  # /admin/custom_collections.xml
  class CustomCollection < ShopifyModel
    top_level
    attr_accessor :body, :body_html, :handle, :id, :published_at, :sort_order, :title, :updated_at
    def products(query_params={})
      Shopify.products(query_params.merge(:collection_id => id))
    end
  end

  # /admin/orders.xml
  class Order < ShopifyModel
    top_level
    attr_accessor :buyer_accepts_marketing, :closed_at, :created_at, :currency, :email, :financial_status, :fulfillment_status, :gateway, :id, :name, :note, :number, :subtotal_price, :taxes_included, :token, :total_discounts, :total_line_items_price, :total_price, :total_tax, :total_weight, :updated_at, :browser_ip, :billing_address, :shipping_address, :line_items, :shipping_line

    # Get all fulfillments related to this order.
    def fulfillments
    end

    # Get all transactions related to this order.
    def transactions
    end
  end

  class LineItem < ShopifyModel
    children_of Order
    attr_accessor :fulfillment_service, :grams, :id, :price, :quantity, :sku, :title, :variant_id, :vendor, :name, :product_title
  end

  # /admin/orders/[order_id]/fulfillments.xml
  class Fulfillment < ShopifyModel
    children_of Order
    attr_accessor :id, :order_id, :status, :tracking_number, :line_items, :receipt
  end

  # /admin/pages.xml
  class Page < ShopifyModel
    top_level
    attr_accessor :author, :body, :body_html, :created_at, :handle, :ip, :published_at, :shop_id, :title, :updated_at
  end

  # /admin/products.xml?collection_id=*
  class Product < ShopifyModel
    top_level
    attr_accessor :body, :body_html, :created_at, :handle, :id, :product_type, :published_at, :title, :updated_at, :vendor, :tags, :variants, :images

    # Get all images for this product.
    def images
    end

    # Get all variants of this product.
    def variant
    end
  end

  # /admin/products/[product_id]/images.xml
  class Image < ShopifyModel
    children_of Product
    attr_accessor :id, :position, :product_id, :src
  end

  # /admin/products/[product_id]/variants.xml
  class Variant < ShopifyModel
    children_of Product
    attr_accessor :compare_at_price, :fulfillment_service, :grams, :id, :inventory_management, :inventory_policy, :inventory_quantity, :position, :price, :product_id, :sku, :title
  end

  # /admin/countries/[country_id]/provinces.xml
  class Province < ShopifyModel
    children_of Country
    attr_accessor :code, :id, :name, :tax
  end

  # /admin/redirects.xml
  class Redirect < ShopifyModel
    top_level
    attr_accessor :id, :path, :shop_id, :target
  end

  # /admin/shop.xml
  class Shop < ShopifyModel
    top_level :singular
    attr_accessor :active_subscription_id, :address1, :city, :country, :created_at, :domain, :email, :id, :name, :phone, :province, :public, :source, :zip, :taxes_included, :currency, :timezone, :shop_owner
  end

  # /admin/orders/[order_id]/transactions.xml
  class Transaction < ShopifyModel
    children_of Order
    attr_accessor :amount, :authorization, :created_at, :kind, :order_id, :status, :receipt
  end
end
