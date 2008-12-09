require 'digest/md5'

module Shopify
  # Shopify Session
  #
  # Example:
  #   class LoginController < ApplicationController
  #     layout 'empty'
  # 
  #     before { Shopify.sessions << Shopify::Session.new(session[:store_name] || params[:store_name], session[:shopify_token], SHOPIFY_APP_SECRET) if Shopify.sessions.empty? && (session[:store_name] || params[:store_name]) }
  #     
  #     def signin
  #        # ask user for his myshopify.com address.
  #     end
  #   
  #     # POST to this with the store name
  #     def login
  #       # Set the store_name into the session for future requests.
  #       session[:store_name] = params[:store_name]
  #       # This will redirect the user to their Shopify store to authorize your application.
  #       # Shopify will redirect the user back to your :finalize action when finished.
  #       redirect Shopify.current_session.permission_url
  #     end
  #   
  #     def finalize
  #       Shopify.current_session.token = params[:t]
  #       Shopify.apply_current_session!
  #       if Shopify.current_session.signed_in?
  #         redirect # logged in area
  #       else
  #         flash[:notice] = "Couldn't sign in to your shopify store."
  #         redirect url(:signin)
  #       end
  #     end
  #   end
  #    
  class Session
    cattr_accessor :protocol
    self.protocol = 'http'

    attr_accessor :host, :key, :secret, :token

    def initialize(host, key=nil, secret=nil, token=nil)
      host.gsub!(/https?:\/\//, '') # remove http://
      host = "#{host}.myshopify.com" unless host.include?('.') # extend url to myshopify.com if no host is given

      self.host   = host
      self.key    = key
      self.secret = secret
      self.token  = token
    end

    # mode can be either r to request read rights or w to request read/write rights.
    def permission_url(mode='w')
      "http://#{host}/admin/api/auth?api_key=#{key}&mode=#{mode}"
    end

    def apply!
      ActiveResource::Base.site = site if signed_in?
    end

    # use this to initialize ActiveResource:
    # 
    #  ActiveResource::Base.site = Shopify.current_session.site
    #
    def site
      "#{protocol}://#{key}:#{password}@#{host}/admin"
    end

    def signed_in?
      [host, key, secret, token].all?
    end

    private

    # The secret is computed by taking the shared_secret which we got when 
    # registring this third party application and concating the request_to it, 
    # and then calculating a MD5 hexdigest. 
    def password
      Digest::MD5.hexdigest("#{secret.chomp}#{token.chomp}")
    end
  end
end
