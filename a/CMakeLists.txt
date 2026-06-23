# ===== a/CMakeLists.txt =====
# 对应原 a/makefile：include $(ROOT_DIR)/common.mk
# 该目录下没有源文件，仅递归进入 src/
# （如将来直接在 a/ 下添加 .c/.cpp，可在此处补充 OBJECT 库）

# 跳过 include 目录，只进入 src（对应 common.mk 中的 SUBDIRS 过滤）
add_subdirectory(src)
