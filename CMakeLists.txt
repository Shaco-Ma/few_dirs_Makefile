# ===== 顶层 CMakeLists.txt =====
# 对应原项目顶层 Makefile 的逻辑
cmake_minimum_required(VERSION 3.13)
project(test_few_files LANGUAGES C CXX)

# ============================================================
# 1. 交叉编译支持（对应 CROSS_COMPILE / SYSROOT）
#    用法: cmake -DCROSS_COMPILE=/path/to/arm-linux-gnueabi- -DSYSROOT=/path/to/sysroot ..
#    或者使用工具链文件（更推荐的 CMake 方式）
# ============================================================
if(DEFINED CROSS_COMPILE)
    set(CMAKE_C_COMPILER   "${CROSS_COMPILE}gcc")
    set(CMAKE_CXX_COMPILER "${CROSS_COMPILE}g++")
    set(CMAKE_AR           "${CROSS_COMPILE}ar")
endif()

if(DEFINED SYSROOT)
    set(CMAKE_SYSROOT "${SYSROOT}")
endif()

# ============================================================
# 2. 编译选项（对应 CFLAGS / CPPFLAGS）
# ============================================================
set(CMAKE_C_FLAGS     "-Wall -g -O2")
set(CMAKE_CXX_FLAGS   "-Wall -std=c++11 -g -O2")
# LDFLAGS / LIBS 目前为空，如需添加:
# set(CMAKE_EXE_LINKER_FLAGS "...")
# target_link_libraries(${PROJECT_NAME} ...)

# ============================================================
# 3. 头文件路径（对应 INC_DIR）
# ============================================================
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/a/include
    ${CMAKE_SOURCE_DIR}/b/include
    ${CMAKE_SOURCE_DIR}/c/include
)

# ============================================================
# 4. 输出目录（对应 BIN_DIR = debug/bin）
#    CMake 的 .o 文件在 build/ 树中，不强制放到 debug/obj
# ============================================================
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/debug/bin)

# ============================================================
# 5. 根目录源文件（对应 CUR_C_SOURCE / CUR_CPP_SOURCE / CUR_CXX_SOURCE）
#    排除 debug/ 下的文件
# ============================================================
file(GLOB ROOT_C_SOURCES   "${CMAKE_SOURCE_DIR}/*.c")
file(GLOB ROOT_CPP_SOURCES "${CMAKE_SOURCE_DIR}/*.cpp")
file(GLOB ROOT_CXX_SOURCES "${CMAKE_SOURCE_DIR}/*.cxx")

# ============================================================
# 6. 递归编译子目录
#    对应 SUBDIRS = $(filter-out debug include,$(wildcard */))
#    此处固定为 a b c（不动态扫描，避免误入 build/ 等）
# ============================================================
add_subdirectory(a)
add_subdirectory(b)
add_subdirectory(c)

# ============================================================
# 7. 最终链接（对应 $(TARGET): $(SUBDIRS) $(CUR_ALL_OBJS) | $(BIN_DIR)）
#    $(CPP) -o $@ $(ALL_OBJS) ...
# ============================================================
add_executable(${PROJECT_NAME}
    ${ROOT_C_SOURCES}
    ${ROOT_CPP_SOURCES}
    ${ROOT_CXX_SOURCES}
)
target_link_libraries(${PROJECT_NAME}
    a_src_objs
    b_src_objs
    c_src_objs
)

# ===== 调试信息（对应 info 目标） =====
message(STATUS "ROOT_C_SOURCES:   ${ROOT_C_SOURCES}")
message(STATUS "ROOT_CPP_SOURCES: ${ROOT_CPP_SOURCES}")
message(STATUS "ROOT_CXX_SOURCES: ${ROOT_CXX_SOURCES}")
