#设置编译器,绝对路径
#CROSS_COMPILE := /home/shaco/buildroot/host/bin/arm-linux-gnueabi-
#SYSROOT ?= /home/shaco/buildroot/host/arm-buildroot-linux-gnueabi/sysroot/
#修改下面的参数加上sysroot即可
CC = $(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)
CPP = $(CROSS_COMPILE)g++ --sysroot=$(SYSROOT)
AR = $(CROSS_COMPILE)ar
#debug文件夹里的makefile文件需要最后执行，所以这里需要执行的子目录要排除debug文件夹，这里使用awk排除了debug文件夹，读取剩下的文件夹
#SUBDIRS=$(shell ls -l | grep ^d | awk '{if($$9 != "debug" && $$9 != "include") print $$9}')
SUBDIRS := $(filter-out debug include,$(patsubst %/,%,$(wildcard */)))
#无需下一行的注释代码，因为我们已经知道debug里的makefile是最后执行的，所以最后直接去debug目录下执行指定的makefile文件就行，具体下面有注释
#DEBUG=$(shell ls -l | grep ^d | awk '{if($$9 == "debug") print $$9}')
MKDIR = mkdir -p
#记住当前工程的根目录路径
ROOT_DIR=$(shell pwd)
#最终bin文件的名字，可以更改为自己需要的
BIN=test_few_files
TARGET_DIR=$(ROOT_DIR)/debug
#bin文件所在的目录
BIN_DIR=$(TARGET_DIR)/bin
#最终bin文件的路径
TARGET = $(BIN_DIR)/$(BIN)
#目标文件所在的目录
OBJS_DIR=$(TARGET_DIR)/obj
#所有的include文件夹
INC_DIR=$(ROOT_DIR)/include
INC_DIR+=$(ROOT_DIR)/a/include
INC_DIR+=$(ROOT_DIR)/b/include
INC_DIR+=$(ROOT_DIR)/c/include
#获取当前目录下的c文件集，放在变量CUR_C_SOURCE中
CUR_C_SOURCE=${wildcard *.c}
CUR_CPP_SOURCE=${wildcard *.cpp}
CUR_CXX_SOURCE=${wildcard *.cxx}
# 对应的目标文件（位于 OBJS_DIR）
CUR_C_OBJS   = $(addprefix $(OBJS_DIR)/, $(patsubst %.c, %.o, $(CUR_C_SOURCE)))
CUR_CPP_OBJS = $(addprefix $(OBJS_DIR)/, $(patsubst %.cpp, %.o, $(CUR_CPP_SOURCE)))
CUR_CXX_OBJS = $(addprefix $(OBJS_DIR)/, $(patsubst %.cxx, %.o, $(CUR_CXX_SOURCE)))

# 所有当前目录生成的 .o 文件
CUR_ALL_OBJS = $(CUR_C_OBJS) $(CUR_CPP_OBJS) $(CUR_CXX_OBJS)

# 对应的依赖文件（位于 OBJS_DIR）
CUR_ALL_DEPS = $(CUR_ALL_OBJS:.o=.d)

#表示用于 C++ 编译器的选项
CFLAGS=-Wall -g -O2
CFLAGS+= $(addprefix -I, $(INC_DIR))
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
export CC CPP AR
export OBJS_DIR BIN_DIR ROOT_DIR MKDIR
export CPPFLAGS LDFLAGS LIBS CFLAGS
#生成需要的文件夹
#$(foreach dirname,$(sort $(OBJS_DIR) $(BIN_DIR)),$(shell $(MKDIR) $(dirname)))
#注意这里的顺序，需要先执行SUBDIRS最后才能是DEBUG
#如果是cpp用下面的,c用上面的
#all:$(SUBDIRS) $(CUR_C_OBJS) DEBUG
#all:$(SUBDIRS) $(CUR_C_OBJS) $(CUR_CPP_OBJS) $(CUR_CXX_OBJS) DEBUG
#all:$(SUBDIRS) $(CUR_CPP_OBJS) DEBUG
# ----------------- 顶级目标 -----------------
.PHONY: all clean info $(SUBDIRS) #deps $(SUBDIRS)
all: info $(SUBDIRS) $(TARGET)
	@echo "==== Build finished ===="

# ----------------- 目录创建 -----------------
$(OBJS_DIR) $(BIN_DIR):
	$(MKDIR) $@
	@echo "==== makedir finished ===="


# 确保子目录一定被编译
$(SUBDIRS): #info
	@echo "==== Entering subdirectory $@ ===="
	$(MAKE) -C $@

# ----------------- 手动生成依赖文件（提前完成，不影响 .o 编译） -----------------
deps: $(CUR_ALL_DEPS)

# 将 deps 作为 .o 编译的前置步骤，但 .o 本身不直接依赖 .d 文件
# 这样 .d 的生成不会因为 .o 的更新而触发，反之亦然
$(CUR_ALL_OBJS): | deps $(OBJS_DIR)

# ----------------- 手动生成 .d 文件规则 -----------------

# 为 .c 文件生成依赖文件
$(OBJS_DIR)/%.d: %.c | $(OBJS_DIR)
	@echo "Generating dependency for $<"
	@$(CC) -MM $(CFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(OBJS_DIR)/\1.o $@ : ,g' > $@

# 为 .cpp 文件生成依赖文件
$(OBJS_DIR)/%.d: %.cpp | $(OBJS_DIR)
	@echo "Generating dependency for $<"
	@$(CPP) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(OBJS_DIR)/\1.o $@ : ,g' > $@

# 为 .cxx 文件生成依赖文件
$(OBJS_DIR)/%.d: %.cxx | $(OBJS_DIR)
	@echo "Generating dependency for $<"
	@$(CPP) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(OBJS_DIR)/\1.o $@ : ,g' > $@

# ----------------- 编译规则 -----------------

# 编译 .c 文件为 .o
$(OBJS_DIR)/%.o: %.c $(OBJS_DIR)/%.d
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -c $< -o $@

# 编译 .cpp 文件为 .o
$(OBJS_DIR)/%.o: %.cpp $(OBJS_DIR)/%.d
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $< -o $@

# 编译 .cxx 文件为 .o
$(OBJS_DIR)/%.o: %.cxx $(OBJS_DIR)/%.d
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $< -o $@

# ----------------- 包含依赖文件 -----------------

# 如果 .d 文件存在就包含，不存在也不报错
-include $(CUR_ALL_DEPS)

# ----------------- 最终链接 -----------------
# 收集所有 .o 文件（递归查找）
ALL_OBJS = $(shell find $(OBJS_DIR) -name "*.o" 2>/dev/null)

$(TARGET): $(SUBDIRS) $(CUR_ALL_OBJS) | $(BIN_DIR)
	@echo "==== Linking $@ ===="
	@echo "Objects found: $(ALL_OBJS)"
	$(CPP) -o $@ $(ALL_OBJS) $(LDFLAGS) $(LIBS)

# ----------------- 清理 -----------------
clean:
	@rm -rf $(TARGET_DIR)

# 调试信息
info:
	@echo "SUBDIRS:        $(SUBDIRS)"
	@echo "CUR_C_SOURCE:   $(CUR_C_SOURCE)"
	@echo "CUR_CPP_SOURCE: $(CUR_CPP_SOURCE)"
	@echo "CUR_CXX_SOURCE: $(CUR_CXX_SOURCE)"
	@echo "CUR_ALL_OBJS:   $(CUR_ALL_OBJS)"
	@echo "CUR_ALL_DEPS:   $(CUR_ALL_DEPS)"

