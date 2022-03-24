# 实验一 词法分析与语法分析

2022春哈尔滨工业大学编译系统课程实验一的代码。


## 目录

- [实验简介](#实验简介)
- [主要工作](#主要工作)
- [使用指南](#使用指南)
  - [编译](#编译)
  - [运行](#运行)
- [开发指南](#开发指南)
  - [文件目录说明](#文件目录说明)
  - [开发环境搭建（可选）](#开发环境搭建（可选）)
  - [Debug模式编译](#Debug模式编译)
  - [单元测试](#单元测试)
  - [运行示例代码](#运行示例代码)
- [已知问题](#已知问题)

## 实验简介

编写一个程序对使用C--语言书写的源代码进行词法和语法分析（C--语言的文法参见[《编译原理实践与指导教程》附录A](https://cs.nju.edu.cn/changxu/2_compiler/projects/Appendix_A.pdf)），并打印分析结果。实验要求使用词法分析工具[GNU Flex](https://ftp.gnu.org/old-gnu/Manuals/flex-2.5.4/html_mono/flex.html)和语法分析工具[GNU Bison](https://www.gnu.org/software/bison/)，并使用C语言来完成。

程序要能够查出C--源代码中可能包含的下述几类错误：
1. 词法错误（错误类型A）：出现C--词法中未定义的字符以及任何不符合C--词法单元定义的字符；
2. 语法错误（错误类型B）。

## 主要工作

1. 基于Flex和GNU Bison实现了一个C--语言词法、语法分析器。对于正确的输入，程序将输出对应的语法树；对于错误的输入，程序将输出其中的词法错误和语法错误。

2. 基于[VS Code](https://code.visualstudio.com/)搭建了一个良好的Flex-Bison开发环境，只需少量配置即可拥有代码高亮、编译错误显示等功能。

## 使用指南

### 编译

```sh
# Clone this repository
$ git clone https://github.com/jiabh/HIT-Systems-of-Compiling-Labs.git

# Go into the repository
$ cd HIT-Systems-of-Compiling-Labs/

# Compile
$ make parser
```

执行`make parser`后将在项目根目录生成可执行文件`C--parser`。

### 运行

若相对路径`test-res/1.1.c`文件中是一段待分析的C--源代码，执行命令`./C--parser test-res/1.1.c`，将在stdout输出分析结果：

```sh
$ ./C--parser test-res/1.1.c
Error type A at Line 4: Mysterious character '~'
$ 
```

若不提供输入文件，则默认从stdin读取输入。

## 开发指南

### 文件目录说明

```
filetree 
├── /.vscode/      VS Code配置文件
├── /examples/     示例代码
│  ├── count.l     示例：文本信息统计
│  ├── calc.l      示例：四则运算的词法定义
│  └── calc.y      示例：四则运算的语法定义
├── /lib/          依赖库
├── /test/         单元测试代码
├── /test-res/     测试样例
├── C--lexical.l   词法定义
├── C--syntax.y    语法定义
├── syntax_tree.h  语法树数据结构声明
├── syntax_tree.c  语法树数据结构实现
├── main.c         主程序
├── Makefile       
├── README.md      本文件
├── LICENSE        授权协议
└── .gitignore
```

### 开发环境搭建（可选）

本节选用VS Code，在Windows下通过[Windows 子系统](https://docs.microsoft.com/zh-cn/windows/wsl/)搭建开发环境。Linux下环境搭建应该几乎相同,只是不需要使用WSL。

#### 1. [安装 WSL](https://docs.microsoft.com/zh-cn/windows/wsl/install)

#### 2. [打开适用于WSL的VS Code](https://docs.microsoft.com/zh-cn/windows/wsl/tutorials/wsl-vscode)

其中不建议阅读“[从命令行中](https://docs.microsoft.com/zh-cn/windows/wsl/tutorials/wsl-vscode#from-the-command-line)”
一节而是选择“[从 VS Code 中](https://docs.microsoft.com/zh-cn/windows/wsl/tutorials/wsl-vscode#from-vs-code)”启动，前者我没有成功。

#### 3. 从适用于WSL的VS Code中打开本项目

如果打开正确，左下角应出现形如“WSL: XXX”的蓝底白字。

#### 4. 安装VS Code插件：[Yash](https://marketplace.visualstudio.com/items?itemName=daohong-emilio.yash)

该插件可以为Flex和Bison源代码提供一定程度的代码高亮和提示功能。

#### 5. 使用

在菜单栏打开“终端-运行任务...”，可以看到四个生成任务：

| 任务名                 | 对应命令           |
| ---------------------- | ----------------- |
| Build C--parser        | make parser       |
| Build C--parser(debug) | make parser-debug |
| Test                   | make test         |
| Clean                  | make clean        |

在侧边栏打开“运行和调试”，有两项：`(gdb) C--parser`、`(gdb) Debug C--parser`，分别对应以普通和调试模式编译运行。

如果需要在其它项目中复现环境，只需要将`.vscode/`文件夹复制到项目根目录即可。如果命令有变，请修改相应的json配置文件。

### Debug模式编译

在Debug模式下，程序将输出Flex和Bison的运行信息，便于调试。编译命令如下：

```sh
$ make parser-debug
```

执行完成后，项目根目录下将生成可执行文件`C--parser-debug`，使用方式与C--parser相同。

### 单元测试

项目使用[CuTest](http://cutest.sourceforge.net/) 1.5进行单元测试，相关代码在`test/`文件夹下。执行如下命令进行单元测试：

```sh
# 编译全部示例代码
$ make test
```

### 运行示例代码

执行如下命令编译示例代码：

```sh
# 编译全部示例代码
$ make examples
```

执行完毕，将在`examples/`目录下产生两个可执行程序：

- `count` 文字统计工具，详见实验教材P16页；
- `calc` 整数四则运算，详见实验教材P26页。

它们的输入、输出方法均与C--parser相同。

## 已知问题

1. 当存在语法错误时，会出现内存泄漏。语法树的释放以树根节点为单位，当同步失败时，无法归约出树根节点。由于不考察这方面要求，就没有修复_(:3」∠)_。

2. 错误恢复的文法写得不好，大有改进空间。
