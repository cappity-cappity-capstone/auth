# Cappy Auth

This web app handles authentication and user/control server coordination for our capstone project.
It does so by providing a REST API that uses JSON to communicate with the control sevrers and frontend.

## API

The API implements limited CRUD functionality for Users, Sessions, and Control Servers.
All error responses (>= `400`) return the failing error class and message to the client.
This should help when debugging requests.

### Users

This resource implements the create, update, and destroy actions for a user.
Also, this resource contains an action to associate a user with a control server and to get the currently logged in user.
All paths are namespaced under `/auth/users`.

#### Get the currently logged in user

* Method: `GET`
* Path: `/auth/users/logged_in`
* Response Codes:
  * 200 - User was found
  * 404 - No user logged in

```
$ curl --verbose \
       --request GET \
       --header 'Cookie: session_key=nYiaeeea7dvsr14RL1qC%2Fg%3D%3D;' \
       http://localhost:4567/auth/users/logged_in

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> GET /auth/users/logged_in HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Cookie: session_key=nYiaeeea7dvsr14RL1qC%2Fg%3D%3D;
>
< HTTP/1.1 200 OK
< Date: Mon, 16 Feb 2015 14:08:40 GMT
< Status: 200 OK
< Connection: close
< Content-Type: application/json
< Content-Length: 49
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"name":"Jonny","email":"jonny@gmail.com"}
```

session_key=nYiaeeea7dvsr14RL1qC%2Fg%3D%3D;

#### Create a new user

* Method: `POST`
* Path: `/auth/users/`
* Response Codes:
  * 201 - A new user was created
  * 400 - Invalid data JSON sent as the post body
  * 409 - There is already a user with the given email

Example:

```shell
$ curl --verbose \
       --request POST \
       --data @- \
       http://localhost:4567/auth/users/ <<EOF
{
  "name": "Jonny",
  "email": "jonny@gmail.com",
  "password": "trustno1"
}
EOF

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> POST /auth/users/ HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Content-Length: 64
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 64 out of 64 bytes
< HTTP/1.1 201 Created
< Date: Sun, 15 Feb 2015 16:26:37 GMT
< Status: 201 Created
< Connection: close
< Content-Type: application/json
< Content-Length: 49
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"name":"Jonny","email":"jonny@gmail.com"}
```

### Update a User

* Method: `PUT`
* Path: `/auth/users/:user_id/`
* Response Codes:
  * 200 - User data was updated
  * 400 - Invalid data JSON sent as the post body
  * 403 - Please log in (see the Sessions API for information about this)
  * 404 - No such user exists
  * 409 - There is already a user with the given email

Example:

```shell
$ curl --verbose \
       --request PUT \
       --header 'Cookie: session_key=z03ksA2ARNsCUUof378LkA%3D%3D;' \
       --data @- \
       http://localhost:4567/auth/users/1 <<EOF
{
  "name": "Jon"
}
EOF

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> PUT /auth/users/1 HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Cookie: session_key=z03ksA2ARNsCUUof378LkA%3D%3D;
> Content-Length: 17
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 17 out of 17 bytes
< HTTP/1.1 200 OK
< Date: Mon, 16 Feb 2015 14:22:28 GMT
< Status: 200 OK
< Connection: close
< Content-Type: application/json
< Content-Length: 47
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"name":"Jon","email":"jonny@gmail.com"}
```

### Destroy a User

* Method: `DELETE`
* Path: `/auth/users/:user_id/`
* Response Codes:
  * 204 - User was deleted
  * 403 - Please log in (see the Sessions API for information about this)
  * 404 - No such user exists

Example:

```shell
$ curl --verbose \
       --header 'Cookie: session_key=1WHTgv9hdYmwpl16PZ3t0A%3D%3D;' \
       --request DELETE \
       http://localhost:4567/auth/users/1

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> DELETE /auth/users/1 HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Cookie: session_key=1WHTgv9hdYmwpl16PZ3t0A%3D%3D;
>
< HTTP/1.1 204 No Content
< Date: Sun, 15 Feb 2015 22:30:39 GMT
< Status: 204 No Content
< Connection: close
< X-Content-Type-Options: nosniff
<
* Closing connection 0
```

### Associate a User with a Control Server

* Method: `POST`
* Path: `/auth/users/:user_id/associate/`
* Response Codes:
  * 201 - Association created
  * 403 - Please log in
  * 404 - No control server found

Example:

```shell
$ curl --verbose \
       --request POST \
       --header 'Cookie: session_key=z03ksA2ARNsCUUof378LkA%3D%3D;' \
       http://localhost:4567/auth/users/1/associate

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> POST /auth/users/1/associate HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Cookie: session_key=z03ksA2ARNsCUUof378LkA%3D%3D;
>
< HTTP/1.1 201 Created
< Date: Mon, 16 Feb 2015 14:24:11 GMT
< Status: 201 Created
< Connection: close
< Content-Type: application/json
< Content-Length: 202
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"name":"Jon","email":"jonny@gmail.com","control_server":{"id":1,"uuid":"SOME-UUID","ip":"127.0.0.1","port":23456,"created_at":"2015-02-16T14:23:14.342Z","updated_at":"2015-02-16T14:23:23.543Z"}}
```

## Sessions

This resource implements the create and destroy actions for a session.
All paths are namespaced under `/auth/sessions`.

### Create a Session

* Method: `POST`
* Path: `/auth/sessions/`
* Response Codes:
  * 201 - Session was created
  * 401 - Invalid password
  * 404 - No user found for the given email

Example:

```shell
$ curl --verbose \
       --request POST \
       --data @- \
       http://localhost:4567/auth/sessions <<EOF
{
  "email": "jonny@gmail.com",
  "password": "trustno1"
}
EOF

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> POST /auth/sessions HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Content-Length: 55
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 55 out of 55 bytes
< HTTP/1.1 201 Created
< Date: Sun, 15 Feb 2015 22:16:48 GMT
< Status: 201 Created
< Connection: close
< Content-Type: application/json
< Set-Cookie: session_key=fvaAiddxIe%2F7yxxQ2DlMaQ%3D%3D; expires=Tue, 17 Mar 2015 21:16:48 -0000
< Content-Length: 98
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"key":"fvaAiddxIe/7yxxQ2DlMaQ==","expires_on":"2015-03-17T17:16:48.583-04:00","user_id":1}
```

### Destroy a Session

* Method: `DELETE`
* Path: `/auth/sessions/`
* Response Codes:
  * 204 - Session was destroyed
  * 404 - No session found or cookie header was not set

Example:

```shell
$ curl --verbose \
       --header 'Cookie: session_key=fvaAiddxIe%2F7yxxQ2DlMaQ%3D%3D;' \
       --request DELETE \
       http://localhost:4567/auth/sessions

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> DELETE /auth/sessions HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Cookie: session_key=fvaAiddxIe%2F7yxxQ2DlMaQ%3D%3D;
>
< HTTP/1.1 204 No Content
< Date: Sun, 15 Feb 2015 22:20:36 GMT
< Status: 204 No Content
< Connection: close
< Set-Cookie: session_key=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000
< X-Content-Type-Options: nosniff
<
* Closing connection 0
```

## Control Servers

This resource implements the create and destroy actions for a Control Servers.
All paths are namespaced under `/auth/control_servers`.

### Create a Control Server

* Method: `POST`
* Path: `/auth/control_servers/`
* Response Codes:
  * 201 - Control server updated
  * 400 - Invalid/malformed options
  * 409 - Control server with UUID already exists

```shell
$ curl --verbose \
       --request POST \
       --data @- \
       http://localhost:4567/auth/control_servers <<EOF
{
  "port": 12345,
  "uuid": "SOME-UUID"
}
EOF
* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> POST /auth/control_servers HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Content-Length: 39
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 39 out of 39 bytes
< HTTP/1.1 201 Created
< Date: Sun, 15 Feb 2015 22:44:14 GMT
< Status: 201 Created
< Connection: close
< Content-Type: application/json
< Content-Length: 57
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"uuid":"SOME-UUID","ip":"127.0.0.1","port":12345}
```

### Update a Control Server

* Method: `PUT`
* Path: `/auth/control_servers/:uuid/`
* Response Codes:
  * 200 - Control server updated
  * 400 - Invalid/malformed control server options
  * 404 - No control server found

```shell
$ curl --verbose \
       --request PUT \
       --data @- \
       http://localhost:4567/auth/control_servers/SOME-UUID <<EOF
{
  "port": 23456
}
EOF

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> PUT /auth/control_servers/SOME-UUID HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
> Content-Length: 17
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 17 out of 17 bytes
< HTTP/1.1 200 OK
< Date: Mon, 16 Feb 2015 14:23:23 GMT
< Status: 200 OK
< Connection: close
< Content-Type: application/json
< Content-Length: 57
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"uuid":"SOME-UUID","ip":"127.0.0.1","port":23456}
```

### Check if a control server exists

* Method: `GET`
* Path: `/auth/control_servers/exists/`
* Response Codes:
  * 200 - Control server exists at current ip (returned in body)
  * 404 - Control server does not exist

```
$ curl --verbose \
       --request GET \
       http://localhost:4567/auth/control_servers/exists

* Hostname was NOT found in DNS cache
*   Trying ::1...
* connect to ::1 port 4567 failed: Connection refused
*   Trying fe80::1...
* connect to fe80::1 port 4567 failed: Connection refused
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 4567 (#0)
> GET /auth/control_servers/exists HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:4567
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Fri, 06 Mar 2015 01:32:56 GMT
< Status: 200 OK
< Connection: close
< Content-Type: application/json
< Content-Length: 59
< X-Content-Type-Options: nosniff
<
* Closing connection 0
{"id":1,"uuid":"todds_laptop","ip":"127.0.0.1","port":4567}%
```

