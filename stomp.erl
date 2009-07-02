-module (stomp).
-export ([connect/4]).
-export ([disconnect/1]).
-export ([subscribe/2]).
-export ([subscribe/3]).
-export ([unsubscribe/2]).
-export ([get_message/1]).




%% stomp:connect("localhost", 61613, "", "").

connect (Host, PortNo, Login, Passcode)  ->
	Message=lists:append(["CONNECT", "\nlogin: ", Login, "\npasscode: ", Passcode, "\n\n", [0]]),
	{ok,Sock}=gen_tcp:connect(Host,PortNo,[{active, false}]),
	gen_tcp:send(Sock,Message),
	{ok, Response}=gen_tcp:recv(Sock, 0),
	Sock.

subscribe (Destination, Connection) ->
	subscribe (Destination, Connection, "auto"),
	ok.

subscribe (Destination, Connection, Ack) ->
	Message=lists:append(["SUBSCRIBE", "\ndestination: ", Destination, "\nack: ", Ack,"\n\n", [0]]),
	gen_tcp:send(Connection,Message),
	ok.
	
	
unsubscribe (Destination, Connection) ->
	Message=lists:append(["UNSUBSCRIBE", "\ndestination: ", Destination, "\n\n", [0]]),
	gen_tcp:send(Connection,Message),
	ok.	
	
	
disconnect (Connection) ->
	Message=lists:append(["DISCONNECT", "\n\n", [0]]),
	gen_tcp:send(Connection,Message),
	gen_tcp:close(Connection),
	ok.	

get_message (Connection) ->
	{ok, Response}=gen_tcp:recv(Connection, 0),
	io:format("~s", [Response]),
	Response.