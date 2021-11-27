# Makde by audin 2021/11
# (0) Specify cmake version
cmake_minimum_required(VERSION 3.13) # Use CMake version 3.13 or later
# 3.10: for Ubuntu 18.04 LTS (until 2023/04) https://postgresweb.com/ubuntu-support-deadline
# 3.13: for Debian buster    (until 2024/06) https://wiki.debian.org/LTS
# 3.16: for Ubuntu 20.04 LTS (until 2025/04)
# 3.18: for Debian bullseye  (until 2026/06)
# 3.22:  この時点で最新(Latest at this moment) 2021/11

set(nimcache_dir .nimcache)

# (1) プロジェクト名を指定
# Specify project name.
project(struct_test VERSION 1.0 LANGUAGES C)

# プロジェクト名は 長いのでselfに変更
# Just changes to more short name.
#set(self ${CMAKE_PROJECT_NAME})
set(self main)

# binutils用
# For binutils.
set(exe_abs_name ${CMAKE_BINARY_DIR}/${self})

# (2) 実行ファイル名を指定。プロジェクト名と同じにした。
# Specify executable. I'ts same as project name.
add_executable(${self})

# (3) C言語 コンパイルとリンクオプション
# Specify C language options. 'cflags' are defined in 'avr-toolchain.cmake' file.
target_compile_options(${self} PRIVATE ${cflags})
target_link_options(${self}
    PRIVATE
         ${cflags}
        -Wl,-Map=${exe_abs_name}_${DEVICE}.map,--cref
        -Wl,-o,${exe_abs_name}.elf
    )

# (4) インクルードディレクトリ指定
# Specify incude folders.
target_include_directories(${self}
    PRIVATE
        src/lib/xprintf/xprintf_int
        src
    )
# (5)a ソースファイルを収集
# Collect C langugage files in .nimcache folder.
file(GLOB nimcache_srcs ${nimcache_dir}/*.c)

# (5)b 全ソースファイルをここで指定
# Specify all source files here.
target_sources(${self}
    PRIVATE
        src/student.c
        src/xprintf_test.c
        src/lib/xprintf/xprintf_int/xprintf.c
        ${nimcache_srcs}
    )
# コンパイル後に実行するコマンド群
# Execute after build command.
add_custom_command(TARGET ${self}
    POST_BUILD
        COMMAND ${OBJSIZE} "${exe_abs_name}.elf" # サイズ表示
        #COMMAND "${exe_abs_name}"         # EXEファイルを実行する
        # アセンブラリストを出す
        COMMAND ${OBJDUMP} -hSC "${exe_abs_name}.elf" > "${exe_abs_name}_${DEVICE}.lst"
        # HEXファイルを出す
        COMMAND ${CMAKE_OBJCOPY} -O ihex -R .eeprom "${exe_abs_name}.elf" "${exe_abs_name}_${DEVICE}.hex"
        COMMAND ${CMAKE_OBJCOPY} -j .eeprom --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 --no-change-warnings -O  ihex "${exe_abs_name}.elf"  "${exe_abs_name}_${DEVICE}.eep"
    )

