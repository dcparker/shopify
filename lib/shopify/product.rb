module Shopify
  class Product < ActiveResource::Base
    class << self
      # Share all items of this store with the shopify marketplace
      def share_all
        post :share
      end
      # Stop sharing all items of this store with the shopify marketplace
      def unshare_all
        delete :share
      end
    end

    # Auto-compute the price range
    def price_range
      prices = variants.collect(&:price)
      format =  "%0.2f"
      if prices.min != prices.max
        "#{format % prices.min} - #{format % prices.max}"
      else
        format % prices.min
      end
    end
  end
  
  class Variant < ActiveResource::Base
    self.prefix = "/admin/products/:product_id/"
  end

  class Image < ActiveResource::Base
    self.prefix = "/admin/products/:product_id/"
    
    # generate a method for each possible image variant
    [:pico, :icon, :thumb, :small, :medium, :large, :original].each do |m|
      reg_exp_match = "/\\1_#{m}.\\2"
      define_method(m) { src.gsub(/\/(.*)\.(\w{2,4})/, reg_exp_match) }
    end
    
    # Attach an image to a product.
    def attach_image(data, filename = nil)
      attributes[:attachment] = Base64.encode64(data)
      attributes[:filename] = filename unless filename.nil?
    end
  end
end
