%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2009-2011. All Rights Reserved.
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
-module(config_info_1_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").

%%%-----------------------------------------------------------------

suite() ->
    [{timetrap,500}].

%%%-----------------------------------------------------------------

group(_) ->
    [{timetrap,250}].

%%%-----------------------------------------------------------------

init_per_suite() ->
    [{timetrap,1000},
     {require,suite_data},
     {default_config,suite_data,suite_data_val}].

init_per_suite(Config) ->
    suite_data_val = ct:get_config(suite_data),
    ct:sleep(750),
    Config.

%%%-----------------------------------------------------------------

end_per_suite() ->
    [{timetrap,300},
     {require,suite_data2},
     {default_config,suite_data2,suite_data2_val}].

end_per_suite(_Config) ->
    suite_data2_val = ct:get_config(suite_data2),
    ct:sleep(500),
    ok.

%%%-----------------------------------------------------------------

init_per_group() ->
    [{timetrap,400}].

init_per_group(g1, Config) ->
    ct:sleep(1000);
init_per_group(g4, Config) ->
    ct:sleep(1000);
init_per_group(G, Config) ->
    GrProps = proplists:get_value(tc_group_properties, Config),
    GrProps1 = proplists:delete(name, GrProps),
    ct:comment(io_lib:format("init( ~w ): ~p", [G, GrProps1])),
    ct:pal("init( ~w ): ~p", [G, GrProps1]),
    Config.

%%%-----------------------------------------------------------------

end_per_group() ->
    [{timetrap,350}].

end_per_group(g2, Config) ->
    ct:sleep(1000);
end_per_group(g5, Config) ->
    ct:sleep(1000);
end_per_group(G, Config) ->
    GrProps = proplists:get_value(tc_group_properties, Config),
    GrProps1 = proplists:delete(name, GrProps),
    ct:comment(io_lib:format("end( ~w ): ~p", [G, GrProps1])),
    ct:pal("end( ~w ): ~p", [G, GrProps1]),
    ok.

%%%-----------------------------------------------------------------
init_per_testcase() ->
    [{timetrap,750}].

init_per_testcase(t1, Config) ->
    ct:sleep(1000);
init_per_testcase(t31, Config) ->
    ct:sleep(1000);
init_per_testcase(_TestCase, Config) ->
    Config.

%%%-----------------------------------------------------------------

end_per_testcase() ->
    [{timetrap,600}].

end_per_testcase(t2, Config) ->
    ct:sleep(1000);
end_per_testcase(t32, Config) ->
    ct:sleep(1000);
end_per_testcase(_TestCase, _Config) ->
    ok.

%%--------------------------------------------------------------------
%% TEST DECLARATIONS
%%--------------------------------------------------------------------

groups() ->
    [
     {g1,[],[t11]},
     {g2,[],[t21]},
     {g3,[],[{g4,[],[t41]}, t31, t32, {g5,[],[t51]}]}
    ].

all() -> 
    [
     {group,g1},
     {group,g2},
     {group,g3}
    ].

%%-----------------------------------------------------------------
%% TEST CASES
%%-----------------------------------------------------------------

t1(_) ->
    exit(should_not_execute).

t2(_) ->
    ok.

t11(_) ->
    exit(should_not_execute).

t21(_) ->
    ok.

t31(_) ->
    exit(should_not_execute).

t32(_) ->
    ok.

t41(_) ->
    exit(should_not_execute).

t51(_) ->
    ok.
