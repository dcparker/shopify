module Shopify
  class Page < ActiveResource::Base
  end

  class Blog < ActiveResource::Base
    def articles
      Article.get
    end
  end

  class Article < ActiveResource::Base
    self.prefix = "/admin/blogs/:blog_id/"
  end
end
