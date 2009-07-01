-module (stomp).
-export ([connect/4]).


%% stomp:connect("localhost", 61613, "", "").

connect (Host, PortNo, Login, Passcode)  ->
	io:format("HOST:~w~nLOGIN:~w~nPASSCODE:~w~n", [Host, Login, Passcode]),
	Connect="CONNECT",
	Message=lists:append([Connect, "\nlogin: ", Login, "\npasscode: ", Passcode, "\n\n", [0]]),
	{ok,Sock}=gen_tcp:connect(Host,PortNo,[{active, false}]),
	io:format("Socket=~p~n",[Sock]),
	gen_tcp:send(Sock,Message),
	A=gen_tcp:recv(Sock, 0),
	io:format("~w",[A]),
	gen_tcp:close(Sock).


	do_recv(Sock, Bs) ->
	    case gen_tcp:recv(Sock, 0) of
	        {ok, B} ->
	            do_recv(Sock, [Bs, B]);
	        {error, closed} ->
	            {ok, list_to_binary(Bs)}
	    end.

wait_reply(X) ->
	receive
		Reply ->
			{value, Reply}
			after 1000 ->
				timeout
			end.