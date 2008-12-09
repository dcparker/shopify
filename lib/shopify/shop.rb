module Shopify
  class Shop
    # Retrieves information from Shopify about your signed-in shop.
    def self.current
      ActiveResource::Base.find(:one, :from => "/admin/shop.xml")
    end
  end               
end
