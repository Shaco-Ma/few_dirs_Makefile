#次级目录,比如当前的model文件夹,其下包含了src和include文件夹,需要再进一层到src进行编译
#子目录的Makefile直接读取其子目录就行
# 计算当前目录相对于根目录的路径
REL_PATH = $(shell realpath --relative-to=$(ROOT_DIR) $(shell pwd))
# 定义本模块的输出子目录（如 debug/obj/a/src）
MOD_OBJS_DIR = $(OBJS_DIR)/$(REL_PATH)
#需要指定头文件目录的类型等
SUBDIRS=$(shell ls -l | grep ^d | awk '{if($$9 != "inc" && $$9 != "include") print $$9}')
#直接指定为src
#SUBDIRS=src
#以下同根目录下的makefile的相同代码的解释
CUR_C_SOURCE=${wildcard *.c}
CUR_CPP_SOURCE=${wildcard *.cpp}
CUR_CXX_SOURCE=${wildcard *.cxx}
# 转换为 CUR_MOD_OBJS_DIR 下的目标文件路径（变量由顶层 export 传入）
CUR_C_OBJS   := $(addprefix $(MOD_OBJS_DIR)/, $(patsubst %.c, %.o, $(CUR_C_SOURCE)))
CUR_CPP_OBJS := $(addprefix $(MOD_OBJS_DIR)/, $(patsubst %.cpp, %.o, $(CUR_CPP_SOURCE)))
CUR_CXX_OBJS := $(addprefix $(MOD_OBJS_DIR)/, $(patsubst %.cxx, %.o, $(CUR_CXX_SOURCE)))
CUR_ALL_OBJS := $(CUR_C_OBJS) $(CUR_CPP_OBJS) $(CUR_CXX_OBJS)
CUR_ALL_DEPS := $(CUR_ALL_OBJS:.o=.d)

.PHONY: all info subdirs deps $(SUBDIRS)
# 默认目标：生成当前目录下的 .o 并递归进入子目录
all: subdirs $(CUR_ALL_OBJS)

# 确保输出目录存在（依赖顶层创建，但可加一条安全规则）
$(MOD_OBJS_DIR):
	$(MKDIR) $@

# 递归编译子目录
subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

# ----------------- 手动生成依赖文件 -----------------

$(MOD_OBJS_DIR)/%.d: %.c | $(MOD_OBJS_DIR)
	@echo "Generating dependency for $<"
	@$(CC) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(MOD_OBJS_DIR)/\1.o $@ : ,g' > $@

$(MOD_OBJS_DIR)/%.d: %.cpp | $(MOD_OBJS_DIR)
	@echo "Generating dependency for $<"
	@$(CPP) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(MOD_OBJS_DIR)/\1.o $@ : ,g' > $@

$(MOD_OBJS_DIR)/%.d: %.cxx | $(MOD_OBJS_DIR)
	@echo "Generating dependency for $<"
	@$(CPP) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(MOD_OBJS_DIR)/\1.o $@ : ,g' > $@

# ----------------- 编译规则 -----------------
# 注意：.o 规则依赖对应的 .d 文件，以实现头文件变更触发重新编译

$(MOD_OBJS_DIR)/%.o: %.c $(MOD_OBJS_DIR)/%.d
	$(CC) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $< -o $@

$(MOD_OBJS_DIR)/%.o: %.cpp $(MOD_OBJS_DIR)/%.d
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $< -o $@

$(MOD_OBJS_DIR)/%.o: %.cxx $(MOD_OBJS_DIR)/%.d
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $< -o $@

# ----------------- 包含依赖文件 -----------------
-include $(CUR_ALL_DEPS)

# 可选调试输出
info:
	@echo "SUBDIRS:        $(SUBDIRS)"
	@echo "CUR_C_SOURCE:   $(CUR_C_SOURCE)"
	@echo "CUR_CPP_SOURCE: $(CUR_CPP_SOURCE)"
	@echo "CUR_CXX_SOURCE: $(CUR_CXX_SOURCE)"
	@echo "CUR_ALL_OBJS:   $(CUR_ALL_OBJS)"
