-module (stomp).
-export ([connect/4]).
-export ([disconnect/1]).
-export ([subscribe/2]).
-export ([subscribe/3]).
-export ([unsubscribe/2]).
-export ([get_messages/1]).




%% Example:	Conn = stomp:connect("localhost", 61613, "", "").

connect (Host, PortNo, Login, Passcode)  ->
	Message=lists:append(["CONNECT", "\nlogin: ", Login, "\npasscode: ", Passcode, "\n\n", [0]]),
	{ok,Sock}=gen_tcp:connect(Host,PortNo,[{active, false}]),
	gen_tcp:send(Sock,Message),
	{ok, Response}=gen_tcp:recv(Sock, 0),
	Sock.


%% Example: stomp:subscribe("/queue/foobar", Conn).

subscribe (Destination, Connection) ->
	subscribe (Destination, Connection, [{"ack","auto"}]),
	ok.

%%  Example: stomp:subscribe("/queue/foobar", Conn, [{"ack", "client"}]).

subscribe (Destination, Connection, Options) ->
	Message=lists:append(["SUBSCRIBE", "\ndestination: ", Destination, concatenate_options(Options),"\n\n", [0]]),
	gen_tcp:send(Connection,Message),
	ok.
	

%% Example: stomp:unsubscribe("/queue/foobar", Conn).
	
unsubscribe (Destination, Connection) ->
	Message=lists:append(["UNSUBSCRIBE", "\ndestination: ", Destination, "\n\n", [0]]),
	gen_tcp:send(Connection,Message),
	ok.	
	
%% Example: stomp:disconnect(Conn).
	
disconnect (Connection) ->
	Message=lists:append(["DISCONNECT", "\n\n", [0]]),
	gen_tcp:send(Connection,Message),
	gen_tcp:close(Connection),
	ok.	

%% Example: stomp:get_messages(Conn).

get_messages (Connection) ->
	{ok, Response}=gen_tcp:recv(Connection, 0),
	io:format("~s", [Response]),
	[{type, Type}, {headers, Headers}, {body, MessageBody}]=get_message(Response),
	io:fwrite("Type: ~s", [Type]),
	io:fwrite("~nHeaders:~n~s", [Headers]),
	io:fwrite("~nMessageBody:~n~s", [MessageBody]),
	header_clob_to_tuple_list(Headers),
	
	
		[].

%% PRIVATE METHODS . . .	
concatenate_options ([]) ->
	[];
concatenate_options ([H|T]) ->
	{Name, Value}=H,
	lists:append(["\n", Name, ": ", Value, concatenate_options(T)]).


% MESSAGE PARSING  . . . get's a little ugly in here . . . would help if I truly grokked Erlang, I suspect.
get_message(Message) ->
 	[Type, {Headers, MessageBody}]=get_type(Message), %% Ugly . . .
	[{type, Type}, {headers, Headers}, {body, MessageBody}].



%% extract type ("MESSAGE", "CONNECT", etc.) from message string . . .	

get_type(Message) ->
	get_type (Message, []).
	
get_type ([], Type) ->
		Type;
get_type ([H|T], Type) ->	
		case (H) of
			10 -> [Type, get_headers(T)];
			_ -> get_type(T, lists:append([Type, [H]]))	
		end.
		
%% extract headers as a blob of chars, after having iterated over . . .

get_headers (Message) ->
	get_headers (Message, []).
	
get_headers (Message, Headers) ->
	get_headers (Message, Headers, -1).
		
get_headers ([H|T], Headers, LastChar) ->
	case ({H, LastChar}) of
		{10, 10} -> {Headers, get_message_body(T)};
		{_, _} -> get_headers(T, lists:append([Headers, [H]]), H)
	end.
	
%% extract message body
get_message_body ([H|T]) ->
	get_message_body ([H|T], []).
	
get_message_body ([H|T], MessageBody) ->
	case(H) of
		0 -> MessageBody;
		_ -> lists:append([MessageBody, [H], get_message_body(T, MessageBody)])
	end.	


%% parse header clob into list of tuples . . .
header_clob_to_tuple_list ([]) ->
	[];
header_clob_to_tuple_list ([H|T]) ->
	

	
	Header=get_header_name(lists:append([H],T)),
	Rev=lists:reverse([Header]),
	io:fwrite("Header: ~w", lists:reverse(Rev)).
	
get_header_name ([H|T]) ->
	io:fwrite("In get_header_name: ~c~n", [H]),
		case (H) of 
			58 ->  {header_value, get_header_value(T)};
			_ -> lists:append([[H], get_header_name(T)])
		end.
	
get_header_value ([H|T]) ->
		io:fwrite("In get_header_value: ~c~n", [H]),
		
		case (H) of 
			10 -> {remaining_headers, T};
			_ -> lists:append([[H], get_header_value(T)])
			end.	
		
