-module (stomp).
-export ([connect/3]).


connect (HOST, LOGIN, PASSCODE)  ->
	io:format("HOST:~w~nLOGIN:~w~nPASSCODE:~w~n", [HOST, LOGIN, PASSCODE]),
	MESSAGE="CONNECT",
	io:format("~w", [MESSAGE]).
