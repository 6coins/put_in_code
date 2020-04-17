# 默认
all: compile

# 编译
compile:
	@rm -rf ebin/
	@mkdir ebin/
	@erl -make -smp disable 

# 清理
clean:
	@rm -rf ebin/*
	@rm -rf ebin_put_in/*
	@rm -rf tags
	@rm -rf TAGS
	@rm -rf erl_crash.dump

