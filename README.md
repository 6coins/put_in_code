
################################################################################ 
## 介绍
################################################################################ 
    此程序用于:用于代码注入(以便测试)
        (大概步骤是:连接erlang远程节点,在上面,先注入代码,再执行代码)

################################################################################ 
## 测试
################################################################################ 

    启动远程节点
        建文件
            vim example.erl
            -module(example).
            -export([run/0]).
            run() -> old.
        启动节点
            erl -sname abc -setcooke 123
            1> c(example). 
            2> example:run().
            old

    注入代码
        添加要注入的代码
            put_in_code/src_put_in/example.erl
        添加要注入的代码要执行的模块和函数
            put_in_code/src/test/example_after.erl
        添加配置
            put_in_code/config/example.config
        注入
            cd put_in_code
            ./start.sh
         
    在远程节点验证注入代买成功 
        3> example:run().
        new

    
