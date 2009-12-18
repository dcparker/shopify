require 'extlib'
require 'bigdecimal'
require 'digest/md5'
require 'httparty'


# Class: Shopify
# Usage:
#   shop = Shopify.new(host, [key, [secret, [token]]])
#   shop.orders
class Shopify
  attr_reader :host
  include HTTParty

  def initialize(host, key=nil, secret=nil, token=nil)
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
      @base_uri = "http://#{@host}/admin"
      @basic_auth = {:username => @key, :password => Digest::MD5.hexdigest("#{@secret.chomp}#{@token.chomp}")}
      @format = :xml
    end
  end
  private :setup

  def options(opts={})
    {:base_uri => @base_uri, :basic_auth => @basic_auth, :format => @format}.merge(opts)
  end


  class ShopifyModel
    class << self
      def load_api_classes(api)
        api.each_key do |klass_name|
          next unless klass_name.is_a?(String)
          mode = []
          singular = klass_name.singular
          mode = [:singular] if singular == klass_name
          klass = Shopify.const_set(singular, Class.new(ShopifyModel))

          # Set up the top_level or children_of setting
          self == ShopifyModel ?
            klass.send(:top_level, *mode) :
            klass.send(:children_of, self)

          # Set up the properties
          klass.send(:attr_accessor, *api[klass_name].delete(:properties).split(', ').map {|s| s.to_sym})
          
          # If there are any children to be had, set them up
          klass.load_api_classes(api[klass_name])
        end
      end

      def top_level(*options)
        klass_name = self.name.gsub(/.*::/,'')
        if options.include?(:singular)
          # Defines the singular accessor in the Shopify object
          # TODO: Make the object cache the results of queries, per set of parameters,
          #       and reload only when you include true as the first argument.
          Shopify.class_eval "
            def #{klass_name.snake_case}(query_params={})
              json = Shopify.get(\"/#{klass_name.snake_case}.xml\", options(:query => query_params))
              begin
                #{klass_name}.instantiate(self, json['#{klass_name.snake_case}'])
              rescue => e
                warn \"Error: \#{e.inspect}\"
                json
              end
            end
          "
        else
          # Defines the plural accessor in the Shopify object
          # TODO: Make the object cache the results of queries, per set of parameters,
          #       and reload only when you include true as the first argument.
          Shopify.class_eval "
            def #{klass_name.snake_case.pluralize}(query_params={})
              json = Shopify.get(\"/#{klass_name.snake_case.pluralize}.xml\", options(:query => query_params))
              if json['#{klass_name.snake_case.pluralize}']
                json['#{klass_name.snake_case.pluralize}'].collect {|i| #{klass_name}.instantiate(self, i)}
              else
                json
              end
            end
            def #{klass_name.snake_case}(id)
              json = Shopify.get(\"/#{klass_name.snake_case.pluralize}/\#{id}.xml\", options)
              if json['#{klass_name.snake_case}']
                #{klass_name}.instantiate(self, json['#{klass_name.snake_case}'])
              else
                json
              end
            end
          "
        end
      end
      def children_of(parent_klass)
        @parent = parent_klass
        parent_klass_name = parent_klass.name.gsub(/.*::/,'')
        klass_name = self.name.gsub(/.*::/,'')
        # Defines the getter method in the parent class
        # TODO: Make the object cache the results of queries, per set of parameters,
        #       and reload only when you include true as the first argument.
        parent_klass.class_eval "
          def #{klass_name.snake_case.pluralize}(query_params={})
            @#{klass_name.snake_case.pluralize} ||= begin
              json = Shopify.get(\"/#{parent_klass_name.snake_case.pluralize}/\#{id}/#{klass_name.snake_case.pluralize}.xml\", shop.options(:query => query_params))
              case 
              when json['#{parent_klass_name.snake_case}_#{klass_name.snake_case.pluralize}']
                json['#{parent_klass_name.snake_case}_#{klass_name.snake_case.pluralize}']
              when json['#{klass_name.snake_case.pluralize}']
                json['#{klass_name.snake_case.pluralize}']
              else
                json
              end
            end
            @#{klass_name.snake_case.pluralize} = (@#{klass_name.snake_case.pluralize}.is_a?(Array) ? @#{klass_name.snake_case.pluralize}.collect {|i| #{klass_name}.instantiate(shop, i)} : [#{klass_name}.instantiate(shop, @#{klass_name.snake_case.pluralize})]) unless @#{klass_name.snake_case.pluralize}.is_a?(#{klass_name}) || @#{klass_name.snake_case.pluralize}.is_a?(Array) && @#{klass_name.snake_case.pluralize}[0].is_a?(#{klass_name})
            @#{klass_name.snake_case.pluralize}
          end
        "
      end
      def is_child?
        (@parent ||= nil)
      end
    end

    def self.instantiate(shop, attrs={})
      new(shop, attrs.merge('new_record' => false))
    end
    def initialize(shop, attrs={})
      @new_record = true
      attrs.each { |k,v| instance_variable_set("@#{k}", v) }
      @shop = shop
    end
    attr_accessor :shop

    def inspect
      "<#{self.class.name} shop=#{@shop.host} #{instance_variables.reject {|i| i=='@shop' || instance_variable_get(i).to_s==''}.map {|i| "#{i}=#{instance_variable_get(i).inspect}"}.join(' ')}>"
    end
  end


  ########################################
  ##  Load the Shopify Object Classes!  ##
  ########################################
  ShopifyModel.load_api_classes YAML.load_file(File.dirname(__FILE__)+'/shopify_api.yml')


  # Add some extra touches to a couple of the models
  class Article < ShopifyModel
    def comments(query_params={})
      shop.comments(query_params.merge(:article_id => id, :blog_id => blog_id))
    end
  end
  class CustomCollection < ShopifyModel
    def products(query_params={})
      shop.products(query_params.merge(:collection_id => id))
    end
  end
end
