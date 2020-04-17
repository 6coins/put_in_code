-module(put_in_code).

-export([start/0]).

%%%===================================================================
%%% Api functions
%%%==================================================================

%% @doc 启动
%% @spec start() -> ok
start() ->
    Conf = get_conf(),              % 得到配置
    ok = ping_remote_node(Conf),    % 尝试连接远程节点
    ok = put_in_modules(Conf),      % 在远程节点加载配置的模块
    ok = after_put_in_do(Conf).     % 在远程节点加载配置的模块后执行的函数


%% 得到配置
get_conf() ->
    {ok, [[Conf_file]]} = init:get_argument(config),
    {ok, [[{_, Conf}]]} = file:consult(Conf_file),
    Conf.


%% 尝试连接远程节点
ping_remote_node(Conf) ->
    Cookie = proplists:get_value(cookie, Conf),                         % 设置自己cookie,以便和远程节点连通 
    Remote_node = proplists:get_value(remote_node, Conf),
    true = erlang:set_cookie(node(), Cookie),
    case net_adm:ping(Remote_node) of                                   % 测试是否能连通远程节点
        pang -> error(lists:concat([Remote_node, " is node down !!"]));
        pong -> ok
    end,
    ok.


%% 在远程节点加载配置的模块
put_in_modules(Conf) ->
    Remote_node = proplists:get_value(remote_node, Conf),
    Modules = proplists:get_value(modules, Conf),
    Fun =                                               
        fun(Module, AccIn) ->
            {ok, Binary} = file:read_file(lists:concat(["ebin_put_in/", Module, ".beam"])), % 读取新的编译文件二进制数据
            Res = rpc:call(Remote_node, code, load_binary, [Module, Module, Binary]),           % 通过二进制数据加载模块
            [Res |AccIn]                                                                        % 记录加载结果
    end,
    Res_list = lists:foldl(Fun, [], Modules),                                               % 在远程节点加载本地的模块列表中的代码
    io:format("put in results is : ~p~n", [Res_list]),
    ok.


%% 在远程节点加载配置的模块后执行的函数
after_put_in_do(Conf) ->
    case proplists:get_value(after_put_in, Conf) of                                         % 注入后执行指定的函数
        {M, F, A} ->                                                                            % 如果有配置函数
            After_put_in_res = apply(M, F, [Conf ++ A]),                                        % 执行函数(注意参数中会添加配置项)
            io:format("after_put_in result is : ~p~n", [After_put_in_res]);                         % 打印函数结果
        _ ->                                                                                    % 如果没配置函数
            io:format("no after_put_in~n")                                                          % 打印提示
    end.


