require 'rubygems'
require 'extlib'
gem 'jnunemaker-httparty', '>=0.3.1'
require 'httparty'
require 'bigdecimal'
require 'digest/md5'

module Shopify
  def self.get(*args)
    puts "getting #{args.map {|i| i.inspect}.join(', ')}"
    super
  end

  def self.def_collections(*klasses)
    klasses.each do |klass|
      kn = klass.name.gsub(/.*::/,'')
      class_eval "
        def self.#{kn.snake_case.pluralize}(query_params={})
          json = get(\"#{klass.site_prefix}/#{kn.snake_case.pluralize}.xml\", :query => query_params)
          if json['#{kn.snake_case.pluralize}']
            json['#{kn.snake_case.pluralize}'].collect {|i| #{kn}.instantiate(i)}
          else
            json
          end
        end
        def self.#{kn.snake_case}(id)
          get(\"/#{kn.snake_case.pluralize}/\#{id}.xml\")
        end
      "
    end
  end

  class ShopifyModel
    class << self
      def top_level(*options)
        klass_name = self.name.gsub(/.*::/,'')
        if options.include?(:singular)
          # Define singular accessor in Shopify
          eval "
            def Shopify.#{klass_name.snake_case}(query_params={})
              json = Shopify.get(\"/#{klass_name.snake_case}.xml\", :query => query_params)
              begin
                #{klass_name}.instantiate json['#{klass_name.snake_case}']
              rescue => e
                warn \"Error: \#{e.inspect}\"
                json
              end
            end
          "
        else
          # Define plural accessor in Shopify
          eval "
            def Shopify.#{klass_name.snake_case.pluralize}(query_params={})
              json = Shopify.get(\"/#{klass_name.snake_case.pluralize}.xml\", :query => query_params)
              if json['#{klass_name.snake_case.pluralize}']
                json['#{klass_name.snake_case.pluralize}'].collect {|i| #{klass_name}.instantiate(i)}
              else
                json
              end
            end
            def Shopify.#{klass_name.snake_case}(id)
              json = Shopify.get(\"/#{klass_name.snake_case.pluralize}/\#{id}.xml\")
              if json['#{klass_name.snake_case}']
                #{klass_name}.instantiate json['#{klass_name.snake_case}']
              else
                json
              end
            end
          "
        end
      end
      def child_of(parent_klass)
        @parent = parent_klass
        parent_klass_name = parent_klass.name.gsub(/.*::/,'')
        klass_name = self.name.gsub(/.*::/,'')
        parent_klass.class_eval "
          def #{klass_name.snake_case.pluralize}(query_params={})
            @#{klass_name.snake_case.pluralize} ||= begin
              json = Shopify.get(\"/#{parent_klass_name.snake_case.pluralize}/\#{id}/#{klass_name.snake_case.pluralize}.xml\", :query => query_params)
              if json['#{parent_klass_name.snake_case}_#{klass_name.snake_case.pluralize}']
                json['#{parent_klass_name.snake_case}_#{klass_name.snake_case.pluralize}'].collect {|i| #{klass_name}.instantiate(i)}
              else
                json
              end
            end
            @#{klass_name.snake_case.pluralize} =  unless @#{klass_name.snake_case.pluralize}.is_a?(#{klass_name})
            @#{klass_name.snake_case.pluralize}
          end
        "
      end
      def is_child?
        (@parent ||= nil)
      end
    end

    def self.instantiate(attrs={})
      new(attrs.merge('new_record' => false))
    end
    def initialize(attrs={})
      @new_record = true
      attrs.each { |k,v| instance_variable_set("@#{k}", v) }
    end
  end
end
