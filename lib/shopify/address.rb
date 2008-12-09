module Shopify
  class ShippingAddress < ActiveResource::Base
  end

  class BillingAddress < ActiveResource::Base
    def name
      "#{first_name} #{last_name}"
    end
  end

  class Country < ActiveResource::Base
  end

  class Province < ActiveResource::Base
    self.prefix = "/admin/countries/:country_id/"
  end
end
