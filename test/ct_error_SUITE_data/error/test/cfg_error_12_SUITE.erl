%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2009-2010. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%
-module(cfg_error_12_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").

end_per_testcase(tc2, _Config) ->
    timer:sleep(2000),
    exit(this_should_not_be_printed);
end_per_testcase(_, _) ->
    ok.

all() ->
    [tc1, tc2, tc3].

%%%-----------------------------------------------------------------
tc1() ->
    put('$test_server_framework_test',
	fun(init_tc, _Default) ->
		ct:pal("init_tc(~p): Night time...",[self()]),
		timer:sleep(2000),
		ct:pal("init_tc(~p): Day time!",[self()]),
		exit(this_should_not_be_printed);
	   (_, Default) -> Default
	end),
    [{timetrap,500}].

tc1(_) ->
    exit(this_should_not_be_printed).

%%%-----------------------------------------------------------------
tc2() ->
    [{timetrap,500}].

tc2(_) ->
    ok.

%%%-----------------------------------------------------------------
tc3() ->
    [{timetrap,500}].

tc3(_) ->
    put('$test_server_framework_test',
	fun(end_tc, _Default) ->
		ct:pal("end_tc(~p): Night time...",[self()]),
		timer:sleep(1000),
		ct:pal("end_tc(~p): Day time!",[self()]);
	   (_, Default) -> Default
	end),
    {comment,"should succeed since ct_fw cancels timetrap in end_tc"}.