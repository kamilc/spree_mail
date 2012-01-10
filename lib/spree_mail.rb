require 'spree_core'
require 'spree_auth' 

require 'mail'
require 'mustache'
require 'meta_search'
#require 'spree_mail/custom_hooks'
require 'spree_mail/has_token'

module SpreeMail
  
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)
    
    initializer "static assets" do |app|
      app.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, "#{config.root}/public"
    end

    def self.activate
      
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      Deface::Override.new(:virtual_path => "users/show",
                    :name => "mail_account_summary_mailer",
                    :insert_after => "[data-hook='account_summary'] > div.right",
                    :partial => "hooks/account_summary",
                    :disabled => false)

      Deface::Override.new(:virtual_path => "user_registrations/new",
                     :name => "add_mailers_to_login_extras",
                     :insert_after => "[data-hook='login_extras']",
                     :partial => "hooks/signup_checkbox",
                     :disabled => false)

      Deface::Override.new(:virtual_path => "layouts/admin",
                     :name => "converted_admin_tabs_mailers_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :partial => "admin/hooks/subscribers_tab",
                     :disabled => false)
      
    end

    config.to_prepare &method(:activate).to_proc
    
  end
  
end