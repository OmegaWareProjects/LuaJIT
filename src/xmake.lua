add_rules("mode.debug", "mode.release")

target("minilua")
    set_kind("binary")
    add_files("host/minilua.c")
    add_defines("_CRT_SECURE_NO_DEPRECATE", "_CRT_STDIO_INLINE=__declspec(dllexport)__inline")
    if is_mode("debug") then
        add_cxflags("/Zi", "/MDd")
        add_ldflags("/DEBUG")
    else
        add_cxflags("/O2", "/MD")
        add_ldflags("/DEBUG", "/RELEASE", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
    end

    after_build(function (target)
        os.cd("src")
        os.exec("minilua.exe ../dynasm/dynasm.lua -LN -D WIN -D JIT -D FFI -D ENDIAN_LE -D FPU -D P64 -o host/buildvm_arch.h vm_x86.dasc")
        
        local result = os.iorun("git show -s --format=%ct")
        
        local file = io.open("luajit_relver.txt", "w")
        file:write(result)
        file:close()

        os.exec("minilua.exe host/genversion.lua")
        os.cd("..")
    end)

target("buildvm")
    set_kind("binary")
    add_deps("minilua")
    add_files("host/buildvm*.c")
    add_includedirs(".", "../dynasm")
    if is_mode("debug") then
        add_cxflags("/Zi", "/MDd")
        add_ldflags("/DEBUG")
    else
        add_cxflags("/O2", "/MD")
        add_ldflags("/DEBUG", "/RELEASE", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
    end

    after_build(function (target)
        os.cd("src")
        local all_lib = "lib_base.c lib_math.c lib_bit.c lib_string.c lib_table.c lib_io.c lib_os.c lib_package.c lib_debug.c lib_jit.c lib_ffi.c lib_buffer.c"

        os.exec("buildvm -m peobj -o lj_vm.obj")
        os.exec("buildvm -m bcdef -o lj_bcdef.h " .. all_lib)
        os.exec("buildvm -m ffdef -o lj_ffdef.h " .. all_lib)
        os.exec("buildvm -m libdef -o lj_libdef.h " .. all_lib)
        os.exec("buildvm -m recdef -o lj_recdef.h " .. all_lib)
        os.exec("buildvm -m vmdef -o jit/vmdef.lua " .. all_lib)
        os.exec("buildvm -m folddef -o lj_folddef.h lj_opt_fold.c")
        os.cd("..")
    end)

target("luajit")
    set_kind("binary")
    add_files("luajit.c")
    add_deps("buildvm")
    if is_mode("debug") then
        add_cxflags("/Zi", "/MDd")
        add_ldflags("/DEBUG")
    else
        add_cxflags("/O2", "/MD")
        add_ldflags("/DEBUG", "/RELEASE", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
    end
    add_links("lua51")

target("lua51")
    set_kind("shared")
    add_files("lj_*.c", "lib_*.c", "lj_vm.obj")
    add_deps("buildvm")
    if is_mode("debug") then
        add_cxflags("/Zi", "/MDd")
        add_ldflags("/DEBUG")
    else
        add_cxflags("/O2", "/MD")
        add_ldflags("/DEBUG", "/RELEASE", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
    end

target("lua51_static")
    set_kind("static")
    add_files("lj_*.c", "lib_*.c", "lj_vm.obj")
    add_deps("buildvm")
    if is_mode("debug") then
        add_cxflags("/Zi", "/MDd")
        add_ldflags("/DEBUG")
    else
        add_cxflags("/O2", "/MD")
        add_ldflags("/DEBUG", "/RELEASE", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
    end

target("ljamalg")
    set_kind("shared")
    add_files("ljamalg.c", "lj_vm.obj")
    add_deps("buildvm")
    if is_mode("debug") then
        add_cxflags("/Zi", "/MDd")
        add_ldflags("/DEBUG")
    else
        add_cxflags("/O2", "/MD")
        add_ldflags("/DEBUG", "/RELEASE", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
    end

target("ljamalg_static")
    set_kind("static")
    add_files("ljamalg.c")
    add_deps("buildvm")
    if is_mode("debug") then
        add_cxflags("/Zi", "/MDd")
        add_ldflags("/DEBUG")
    else
        add_cxflags("/O2", "/MD")
        add_ldflags("/DEBUG", "/RELEASE", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
    end