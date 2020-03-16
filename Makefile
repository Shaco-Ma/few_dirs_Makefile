#设置编译器
ROSS_COMPILE :=
CC = $(CROSS_COMPILE)gcc
CPP = $(CROSS_COMPILE)g++
AR = $(CROSS_COMPILE)ar
#debug文件夹里的makefile文件需要最后执行，所以这里需要执行的子目录要排除debug文件夹，这里使用awk排除了debug文件夹，读取剩下的文件夹
SUBDIRS=$(shell ls -l | grep ^d | awk '{if($$9 != "debug" && $$9 != "include") print $$9}')
#无需下一行的注释代码，因为我们已经知道debug里的makefile是最后执行的，所以最后直接去debug目录下执行指定的makefile文件就行，具体下面有注释
#DEBUG=$(shell ls -l | grep ^d | awk '{if($$9 == "debug") print $$9}')
MKDIR = mkdir -p
#记住当前工程的根目录路径
ROOT_DIR=$(shell pwd)
#最终bin文件的名字，可以更改为自己需要的
BIN=test_few_files
#目标文件所在的目录
OBJS_DIR=debug/obj
#目标文件
OBJS=*.o
#bin文件所在的目录
BIN_DIR=debug/bin
#所有的include文件夹
INC_DIR=$(ROOT_DIR)/include
INC_DIR+=$(ROOT_DIR)/a/include
INC_DIR+=$(ROOT_DIR)/b/include
INC_DIR+=$(ROOT_DIR)/c/include
#获取当前目录下的c文件集，放在变量CUR_C_SOURCE中
CUR_C_SOURCE=${wildcard *.c}
CUR_CPP_SOURCE=${wildcard *.cpp}
CUR_CXX_SOURCE=${wildcard *.cxx}
#将对应的c文件名转为o文件后放在下面的CUR_OBJS变量中
CUR_C_OBJS=${patsubst %.c, %.o, $(CUR_C_SOURCE)}
CUR_CPP_OBJS=${patsubst %.cpp, %.o, $(CUR_CPP_SOURCE)}
CUR_CXX_OBJS+=${patsubst %.cxx, %.o, $(CUR_CXX_SOURCE)}
#表示用于 C++ 编译器的选项
CPPFLAGS=-Wall -std=c++11 -g -O2
CPPFLAGS+= $(addprefix -I, $(INC_DIR))
#失败的错误的
#CPPFLAGS+= $(addprefix -I, $(ROOT_DIR)/$(SUBDIRS))
#CPPFLAGS+= $(addsuffix /include, $(ROOT_DIR)/$(SUBDIRS))
#LIBS告诉链接器要链接哪些库文件
LIBS=
#LDFLAGS告诉链接器从哪里寻找库文件
LDFLAGS=
#将以下变量导出到子shell中，本次相当于导出到子目录下的makefile中
export CC BIN OBJS_DIR BIN_DIR ROOT_DIR CPP LIBS LDFLAGS CPPFLAGS
#生成需要的文件夹
$(foreach dirname,$(sort $(OBJS_DIR) $(BIN_DIR)),$(shell $(MKDIR) $(dirname)))
#注意这里的顺序，需要先执行SUBDIRS最后才能是DEBUG
#如果是cpp用下面的,c用上面的
#all:$(SUBDIRS) $(CUR_C_OBJS) DEBUG
all:$(SUBDIRS) $(CUR_CPP_OBJS) $(CUR_CXX_OBJS) DEBUG
#all:$(SUBDIRS) $(CUR_CPP_OBJS) DEBUG
#递归执行子目录下的makefile文件，这是递归执行的关键
$(SUBDIRS):ECHO
	make -C $@
DEBUG:ECHO
	#直接去debug目录下执行makefile文件
	#修改为在顶层目录到debug目录进行生成
	#$(ROOT_DIR)/$(BIN_DIR)/$(BIN):$(ROOT_DIR)/$(OBJS_DIR)/$(OBJS)
	$(CPP) -o $(ROOT_DIR)/$(BIN_DIR)/$(BIN) $(ROOT_DIR)/$(OBJS_DIR)/$(OBJS) $(CPPFLAGS) $(LDFLAGS) $(LIBS)
	#make -C debug
ECHO:
	@echo "SUBDIRS:" $(SUBDIRS)
	@echo "CUR_CPP_OBJS:" $(CUR_CPP_OBJS)
	@echo "CUR_CPP_SOURCE:" $(CUR_CPP_SOURCE)
	@echo "CUR_CXX_SOURCE:" $(CUR_CXX_SOURCE)
	@echo "CPPFLAGS :" $(CPPFLAGS)
#将c文件编译为o文件，并放在指定放置目标文件的目录中即OBJS_DIR
$(CUR_C_OBJS):%.o:%.c
	$(CC) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $^ -o $(ROOT_DIR)/$(OBJS_DIR)/$@
$(CUR_CPP_OBJS):%.o:%.cpp
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $^ -o $(ROOT_DIR)/$(OBJS_DIR)/$@
$(CUR_CXX_OBJS):%.o:%.cxx
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $^ -o $(ROOT_DIR)/$(OBJS_DIR)/$@

PHONY : clean
clean:
	@rm -rf $(OBJS_DIR)
	#@rm -rf $(BIN_DIR)
