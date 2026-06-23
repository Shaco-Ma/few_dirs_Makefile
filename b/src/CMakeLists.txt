# ===== b/src/CMakeLists.txt =====
# 对应原 b/src/makefile

file(GLOB CUR_C_SOURCES   "${CMAKE_CURRENT_SOURCE_DIR}/*.c")
file(GLOB CUR_CPP_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB CUR_CXX_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cxx")

add_library(b_src_objs OBJECT
    ${CUR_C_SOURCES}
    ${CUR_CPP_SOURCES}
    ${CUR_CXX_SOURCES}
)
