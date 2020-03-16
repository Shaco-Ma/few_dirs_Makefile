#次级目录,比如当前的model文件夹,其下包含了src和include文件夹,需要再进一层到src进行编译
#子目录的Makefile直接读取其子目录就行
#SUBDIRS=$(shell ls -l | grep ^d | awk '{print $$9}')
#直接指定为src
SUBDIRS=src
#以下同根目录下的makefile的相同代码的解释
CUR_C_SOURCE=${wildcard *.c}
CUR_CPP_SOURCE=${wildcard *.cpp}
CUR_CXX_SOURCE=${wildcard *.cxx}
CUR_C_OBJS=${patsubst %.c, %.o, $(CUR_C_SOURCE)}
CUR_CPP_OBJS=${patsubst %.cpp, %.o, $(CUR_CPP_SOURCE)}
CUR_CXX_OBJS=${patsubst %.cxx, %.o, $(CUR_CXX_SOURCE)}
#all:$(SUBDIRS) $(CUR_C_OBJS)
all:$(SUBDIRS) $(CUR_CPP_OBJS) $(CUR_CXX_SOURCE)
$(SUBDIRS):ECHO
	make -C $@
$(CUR_C_OBJS):%.o:%.c
	$(CC) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $^ -o $(ROOT_DIR)/$(OBJS_DIR)/$@
$(CUR_CPP_OBJS):%.o:%.cpp
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $^ -o $(ROOT_DIR)/$(OBJS_DIR)/$@
$(CUR_CXX_OBJS):%.o:%.cxx
	$(CPP) $(CPPFLAGS) $(LDFLAGS) $(LIBS) -c $^ -o $(ROOT_DIR)/$(OBJS_DIR)/$@
ECHO:
	@echo $(SUBDIRS)
