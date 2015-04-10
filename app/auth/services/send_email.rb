Mail.defaults do
  delivery_method :smtp, {
    address: Auth::Config.config['mail_smtp_server'],
    port: Auth::Config.config['mail_smtp_port'],
    domain: 'cappitycappitycapstone.com',
    user_name: Auth::Config.config['mail_smtp_username'],
    password: Auth::Config.config['mail_smtp_password'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
end

module Auth
  module Services
    module SendEmail
      include Base
      FROM = 'Alert <alert@cappitycappitycapstone.com>'

      module_function

      def send(send_to, send_subject, send_body)
        Mail.deliver do
          to send_to
          from FROM
          subject send_subject
          body send_body
        end
      end
    end
  end
end
