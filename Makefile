CC = /usr/bin/gcc
FLEX = /usr/bin/flex

CFLAGS = -lfl

# .l文件路径
FLEX_FILE ?= C--lexical.l

# Working Directory
DIR = $(shell dirname $(FLEX_FILE))

# 输出的可执行程序名
OUT = $(shell basename $(FLEX_FILE) .l)


define echo_info
    @echo "\033[34m$(1)\033[0m"
endef

define echo_success
    @echo "\033[32m$(1)\033[0m"
endef


# 将.l文件单独编译为可执行文件
flex-build:
	$(call echo_info,"Compiling $(OUT).l to $(OUT).yy.c ...")
	$(FLEX) -o $(DIR)/$(OUT).yy.c $(FLEX_FILE)
	$(call echo_success,"Done.")
	@echo

	$(call echo_info,"Compiling $(OUT).yy.c to $(OUT) ...")
	$(CC) $(CFLAGS) $(DIR)/$(OUT).yy.c -o $(DIR)/$(OUT)
	$(call echo_success,"Done.")
