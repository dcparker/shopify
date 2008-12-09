module Shopify
  class Sale < Payment
  end

  class Authorization < Payment
  end

  class Payment < ActiveResource::Base
    self.prefix = "/admin/orders/:order_id/"
  end
end
