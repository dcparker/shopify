module Shopify
  class Order < ActiveResource::Base  
    def fulfilled?
      !!fulfillment_status
    end

    def closed?
      closed_at < Time.now
    end

    def close
      load_attributes_from_response(post(:close))
    end

    def open
      load_attributes_from_response(post(:open))
    end

    def payments
      Payment.get
    end
    
    def capture(amount=nil)
      load_attributes_from_response(post(:capture, :amount => amount))
    end
  end

  class LineItem < ActiveResource::Base
  end

  class ShippingLine < ActiveResource::Base
  end

  class CustomCollection < ActiveResource::Base
  end
end
