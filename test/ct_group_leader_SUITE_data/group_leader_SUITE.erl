%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2012. All Rights Reserved.
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
-module(group_leader_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").

%%--------------------------------------------------------------------
%% @spec suite() -> Info
%% Info = [tuple()]
%% @end
%%--------------------------------------------------------------------
suite() ->
    [{timetrap,{seconds,10}}].

%%--------------------------------------------------------------------
%% @spec init_per_suite(Config0) ->
%%     Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%% @end
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    start_my_io_server(),
    Config.

%%--------------------------------------------------------------------
%% @spec end_per_suite(Config0) -> void() | {save_config,Config1}
%% Config0 = Config1 = [tuple()]
%% @end
%%--------------------------------------------------------------------
end_per_suite(_Config) ->
    my_io_server ! die,
    ok.

%%--------------------------------------------------------------------
%% @spec init_per_group(GroupName, Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% GroupName = atom()
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%% @end
%%--------------------------------------------------------------------
init_per_group(_GroupName, Config) ->
    Config.

%%--------------------------------------------------------------------
%% @spec end_per_group(GroupName, Config0) ->
%%               void() | {save_config,Config1}
%% GroupName = atom()
%% Config0 = Config1 = [tuple()]
%% @end
%%--------------------------------------------------------------------
end_per_group(_GroupName, _Config) ->
    ok.

%%--------------------------------------------------------------------
%% @spec init_per_testcase(TestCase, Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% TestCase = atom()
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%% @end
%%--------------------------------------------------------------------
init_per_testcase(_TestCase, Config) ->
    Config.

%%--------------------------------------------------------------------
%% @spec end_per_testcase(TestCase, Config0) ->
%%               void() | {save_config,Config1} | {fail,Reason}
%% TestCase = atom()
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%% @end
%%--------------------------------------------------------------------
end_per_testcase(_TestCase, _Config) ->
    ok.

%%--------------------------------------------------------------------
%% @spec groups() -> [Group]
%% Group = {GroupName,Properties,GroupsAndTestCases}
%% GroupName = atom()
%% Properties = [parallel | sequence | Shuffle | {RepeatType,N}]
%% GroupsAndTestCases = [Group | {group,GroupName} | TestCase]
%% TestCase = atom()
%% Shuffle = shuffle | {shuffle,{integer(),integer(),integer()}}
%% RepeatType = repeat | repeat_until_all_ok | repeat_until_all_fail |
%%              repeat_until_any_ok | repeat_until_any_fail
%% N = integer() | forever
%% @end
%%--------------------------------------------------------------------
groups() ->
    [{p,[parallel],[p1,p2]},
     {p_restart,[parallel],[p_restart_my_io_server]},
     {seq,[],[s1,s2,s3]},
     {seq2,[],[s4,s5]},
     {seq_in_par,[parallel],[p10,p11,{group,seq},p12,{group,seq2},p13]}].

%%--------------------------------------------------------------------
%% @spec all() -> GroupsAndTestCases | {skip,Reason}
%% GroupsAndTestCases = [{group,GroupName} | TestCase]
%% GroupName = atom()
%% TestCase = atom()
%% Reason = term()
%% @end
%%--------------------------------------------------------------------
all() ->
    [tc1,{group,p},{group,p_restart},p3,
     {group,seq_in_par}].

tc1(_C) ->
    ok.

p1(_) ->
    %% OTP-10101:
    %%
    %% External apps/processes started by init_per_suite (common operation),
    %% will inherit the group leader of the init_per_suite process, i.e. the
    %% test_server test case control process (executing run_test_case_msgloop/7).
    %% If, later, a parallel test case triggers the external app to print with
    %% e.g. io:format() (also common operation), the calling process will hang!
    %% The reason for this is that a parallel test case has a dedicated IO
    %% server process, other than the central test case control process. The
    %% latter process is not executing run_test_case_msgloop/7 and will not
    %% respond to IO messages. The process is still group leader for the
    %% external app, however, which is wrong. It's the IO process for the
    %% parallel test case that should be group leader - but only for the
    %% particular invokation, since other parallel test cases could be
    %% invoking the external app too.
    print("hej\n").

p2(_) ->
    print("hopp\n").

p_restart_my_io_server(_) ->
    %% Restart the IO server and change its group leader. This used
    %% to set to the group leader to a process that would soon die.
    Ref = erlang:monitor(process, my_io_server),
    my_io_server ! die,
    receive
	{'DOWN',Ref,_,_,_} ->
	    start_my_io_server()
    end.

p3(_) ->
    %% OTP-10125. This would crash since the group leader process
    %% for the my_io_server had died.
    print("hoppsan\n").

print(String) ->
    my_io_server ! {print,self(),String},
    receive
	{printed,String} ->
	    ok
    end.

start_my_io_server() ->
    Parent = self(),
    Pid = spawn(fun() -> my_io_server(Parent) end),
    receive
	{Pid,started} ->
	    io:format("~p\n", [process_info(Pid)]),
	    ok
    end.

my_io_server(Parent) ->
    register(my_io_server, self()),
    Parent ! {self(),started},
    my_io_server_loop().

my_io_server_loop() ->
    receive
	{print,From,String} ->
	    io:put_chars(String),
	    From ! {printed,String},
	    my_io_server_loop();
	die ->
	    ok
    end.

p10(_) ->
    receive after 1 -> ok end.

p11(_) ->
    ok.

p12(_) ->
    ok.

p13(_) ->
    ok.

s1(_) ->
    ok.

s2(_) ->
    ok.

s3(_) ->
    ok.

s4(_) ->
    ok.

s5(_) ->
    ok.
