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

%%%-------------------------------------------------------------------
%%% File: ct_system_error_SUITE
%%%
%%% Description:
%%%
%%% Test that severe system errors (such as failure to write logs) are
%%% noticed and handled.
%%%-------------------------------------------------------------------
-module(ct_system_error_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("common_test/include/ct_event.hrl").

-define(eh, ct_test_support_eh).

%%--------------------------------------------------------------------
%% TEST SERVER CALLBACK FUNCTIONS
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% Description: Since Common Test starts another Test Server
%% instance, the tests need to be performed on a separate node (or
%% there will be clashes with logging processes etc).
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    Config1 = ct_test_support:init_per_suite(Config),
    Config1.

end_per_suite(Config) ->
    ct_test_support:end_per_suite(Config).

init_per_testcase(TestCase, Config) ->
    ct_test_support:init_per_testcase(TestCase, Config).

end_per_testcase(TestCase, Config) ->
    ct_test_support:end_per_testcase(TestCase, Config).

suite() -> [{ct_hooks,[ts_install_cth]}].

all() ->
    [
     test_server_failing_logs
    ].

%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

%%%-----------------------------------------------------------------
%%%
test_server_failing_logs(Config) ->
    TC = test_server_failing_logs,
    DataDir = ?config(data_dir, Config),
    Suite = filename:join(DataDir, "a_SUITE"),
    {Opts,ERPid} = setup([{suite,Suite},{label,TC}], Config),
    crash_test_server(Config),
    {error,{cannot_create_log_dir,__}} = ct_test_support:run(Opts, Config),
    Events = ct_test_support:get_events(ERPid, Config),
    ct_test_support:log_events(TC,
			       reformat(Events, ?eh),
			       ?config(priv_dir, Config),
			       Opts),

    TestEvents = events_to_check(TC),
    ok = ct_test_support:verify_events(TestEvents, Events, Config).

crash_test_server(Config) ->
    DataDir = ?config(data_dir, Config),
    Root = ?config(priv_dir, Config),
    [$@|Host] = lists:dropwhile(fun(C) ->
					C =/= $@
				end, atom_to_list(node())),
    Format = filename:join(Root,
			   "ct_run.ct@" ++ Host ++
			       ".~4..0w-~2..0w-~2..0w_"
			   "~2..0w.~2..0w.~2..0w"),
    [C2,C1|_] = lists:reverse(filename:split(DataDir)),
    LogDir = C1 ++ "." ++ C2 ++ ".a_SUITE.logs",
    T = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    [begin
	 {{Y,Mon,D},{H,Min,S}} =
	     calendar:gregorian_seconds_to_datetime(T+Offset),
	 Dir0 = io_lib:format(Format, [Y,Mon,D,H,Min,S]),
	 Dir = lists:flatten(Dir0),
	 file:make_dir(Dir),
	 File = filename:join(Dir, LogDir),
	 file:write_file(File, "anything goes\n")
     end || Offset <- lists:seq(0, 20)],
    ok.

%%%-----------------------------------------------------------------
%%% HELP FUNCTIONS
%%%-----------------------------------------------------------------

setup(Test, Config) ->
    Opts0 = ct_test_support:get_opts(Config),
    Level = ?config(trace_level, Config),
    EvHArgs = [{cbm,ct_test_support},{trace_level,Level}],
    Opts = Opts0 ++ [{event_handler,{?eh,EvHArgs}}|Test],
    ERPid = ct_test_support:start_event_receiver(Config),
    {Opts,ERPid}.

reformat(Events, EH) ->
    ct_test_support:reformat(Events, EH).

%%%-----------------------------------------------------------------
%%% TEST EVENTS
%%%-----------------------------------------------------------------

events_to_check(_Test) ->
    [{?eh,severe_error,{cannot_create_log_dir,{'_','_'}}}].
