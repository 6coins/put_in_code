#!/bin/sh

################################################################################ 
## 编译
################################################################################ 
echo '---------------------------- make start ----------------------------'                
make
echo '---------------------------- make end   ----------------------------'                

## 启动本地节点;检测远程节点是否连通;远程调用;其余的命令(目前执行的是在远程节点加载同一台机器的代码,再执行远程调用)
#erl -pz ebin -sname $LocalNode -setcookie $Cookie <<EOF
#    net_adm:ping($RemoteNode).
#    {ok, Dir} = file:get_cwd(), rpc:call($RemoteNode, code, add_pathsz, [[Dir++"/ebin"]]), rpc:call($RemoteNode, put_in_code, start, [Dir]).
#EOF
erl -pz ebin -sname put_in_code -config config/example.config -s put_in_code -noshell -s init stop



