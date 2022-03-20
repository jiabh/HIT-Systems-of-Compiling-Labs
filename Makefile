CC = /usr/bin/gcc

FLEX_BIN = /usr/bin/flex

# .l文件路径
FLEX_FILE ?= examples/count.l

# Working Directory
DIR = $(shell dirname $(FLEX_FILE))

# 输出的可执行程序名
OUT = $(shell basename $(FLEX_FILE) .l)

build:
	$(FLEX_BIN) -o $(DIR)/$(OUT).yy.c $(FLEX_FILE)
	$(CC) $(DIR)/$(OUT).yy.c -o $(DIR)/$(OUT)
