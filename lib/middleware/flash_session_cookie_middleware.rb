require 'rack/utils'

# Middleware pozwalajcy na utrzymanie sesji przy wykonywaniu zapytać do strony
# za pomocą Flasha (w szczególności Uploadify)
class FlashSessionCookieMiddleware

  def initialize(app, session_key = '_session_id') #:nodoc:
    @app = app
    @session_key = session_key
  end

  def call(env) # :nodoc:
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      req = Rack::Request.new(env)
      env['HTTP_COOKIE'] = [ @session_key,
        req.params[@session_key] ].join('=').freeze unless req.params[@session_key].nil?
      env['HTTP_ACCEPT'] = "#{req.params['_http_accept']}".freeze unless req.params['_http_accept'].nil?
    end

    @app.call(env)
  end
end
