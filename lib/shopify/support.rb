require 'extlib'
require 'bigdecimal'
require 'digest/md5'
require 'httparty'

class Shopify
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
          if self == ShopifyModel
            klass.send(:top_level, *mode)
          else
            klass.send(:children_of, self)
          end

          # Set up the properties
          klass.send(:attr_accessor, *api[klass_name].delete(:properties).split(', ').map {|s| s.to_sym})
          
          # If there are any children to be had, set them up
          klass.load_api_classes(api[klass_name])
        end
      end

      def top_level(*options)
        klass_name = self.name.gsub(/.*::/,'')
        if options.include?(:singular)
          # Define singular accessor in Shopify
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
          # Define plural accessor in Shopify
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
end
