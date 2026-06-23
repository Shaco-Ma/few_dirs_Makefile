# ===== a/src/CMakeLists.txt =====
# 对应原 a/src/makefile（include common.mk）
# 编译 aa.c, a.cpp → OBJECT 库（只编译不归档，对应 Makefile 中仅生成 .o）

file(GLOB CUR_C_SOURCES   "${CMAKE_CURRENT_SOURCE_DIR}/*.c")
file(GLOB CUR_CPP_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB CUR_CXX_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cxx")

add_library(a_src_objs OBJECT
    ${CUR_C_SOURCES}
    ${CUR_CPP_SOURCES}
    ${CUR_CXX_SOURCES}
)

# 本目录无子目录需要递归（src/ 下没有更深的结构）
