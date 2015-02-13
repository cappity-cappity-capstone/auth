module Auth
  module Controllers
    # This controller handles session lifecycle.
    class Sessions < Base
      helpers { include Services::Sessions }

      post '/sessions/?' do
        status 201
        hash = parse_json(req_body)
        expires = Time.now + 30.days
        session = create(*hash.values_at('email', 'password'), expires)
        response.set_cookie(:session_key, value: session['key'], expires: expires)
        session.to_json
      end

      delete '/sessions/?' do
        status 204
        key = request.cookies['session_key']
        response.delete_cookie('session_key')
        expire(key)
      end
    end
  end
end
