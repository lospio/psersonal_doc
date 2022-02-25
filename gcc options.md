- `-O` 优化参数
	- `-O0` 不进行优化处理 
		Reduce compilation time and make debugging produce the expected results. This is the default.
	![[Pasted image 20220224153254.png]]
	- `-O2`  优化编译和生成代码效率
	Optimize even more. GCC performs nearly all supported optimizations that do not involve a space-speed tradeoff. As compared to -O, this option increases both compilation time and the performance of the generated code.
		![[Pasted image 20220224153551.png]]
	- `-O3`  
		Optimize yet more.
		```shell
		-fgcse-after-reload 
		-fipa-cp-clone 
		-floop-interchange 
		-floop-unroll-and-jam 
		-fpeel-loops 
		-fpredictive-commoning 
		-fsplit-loops 
		-fsplit-paths 
		-ftree-loop-distribution 
		-ftree-partial-pre 
		-funswitch-loops 
		-fvect-cost-model=dynamic 
		-fversion-loops-for-strides
		```
	- `-Os` 
		Optimize for size. -Os enables all -O2 optimizations except those that often increase code size:
		```shell
		-falign-functions -falign-jumps 
		-falign-labels -falign-loops 
		-fprefetch-loop-arrays -freorder-blocks-algorithm=stc
		```
	- `-Ofast` 
		Disregard strict standards compliance. -Ofast enables all -O3 optimizations. It also enables optimizations that are not valid for all standard-compliant programs. It turns on -ffast-math, -fallow-store-data-races and the Fortran-specific -fstack-arrays, unless -fmax-stack-var-size is specified, and -fno-protect-parens. It turns off -fsemantic-interposition.
	- `-Og`
		Optimize debugging experience. -Og should be the optimization level of choice for the standard edit-compile-debug cycle, offering a reasonable level of optimization while maintaining fast compilation and a good debugging experience. It is a better choice than -O0 for producing debuggable code because some compiler passes that collect debug information are disabled at -O0.

		Like -O0, -Og completely disables a number of optimization passes so that individual options controlling them have no effect. Otherwise -Og enables all -O1 optimization flags except for those that may interfere with debugging:
		```shell
		-fbranch-count-reg -fdelayed-branch 
		-fdse -fif-conversion -fif-conversion2 
		-finline-functions-called-once 
		-fmove-loop-invariants -fmove-loop-stores -fssa-phiopt 
		-ftree-bit-ccp -ftree-dse -ftree-pta -ftree-sra
		```
	- `-Oz`
		Optimize aggressively for size rather than speed. This may increase the number of instructions executed if those instructions require fewer bytes to encode. -Oz behaves similarly to -Os including enabling most -O2 optimizations.
	---
- `-pipe` 利用管道在编译各个阶段通信，而非临时文件
	Use pipes rather than temporary files for communication between the various stages of compilation. This fails to work on some systems where the assembler is unable to read from a pipe; but the GNU assembler has no trouble.
---
- `-Wp, option`
	You can use -Wp,option to bypass the compiler driver and pass option directly through to the preprocessor. If option contains commas, it is split into multiple options at the commas. However, many options are modified, translated or interpreted by the compiler driver before being passed to the preprocessor, and -Wp forcibly bypasses this phase. The preprocessor’s direct interface is undocumented and subject to change, so whenever possible you should avoid using -Wp and let the driver handle the options instead.
---
- `-fexceptions`
	Enable exception handling. Generates extra code needed to propagate exceptions. For some targets, this implies GCC generates frame unwind information for all functions, which can produce significant data size overhead, although it does not affect execution. If you do not specify this option, GCC enables it by default for languages like C++ that normally require exception handling, and disables it for languages like C that do not normally require it. However, you may need to enable this option when compiling C code that needs to interoperate properly with exception handlers written in C++. You may also wish to disable this option if you are compiling older C++ programs that don’t use exception handling.
---
- `-fstack-protector`
	Emit extra code to check for buffer overflows, such as stack smashing attacks. This is done by adding a guard variable to functions with vulnerable objects. This includes functions that call `alloca`, and functions with buffers larger than or equal to 8 bytes. The guards are initialized when a function is entered and then checked when the function exits. If a guard check fails, an error message is printed and the program exits. Only variables that are actually allocated on the stack are considered, optimized away variables or variables allocated in registers don’t count.
	- `-fstack-protector-strong
		Like `-fstack-protector` but includes additional functions to be protected — those that have local array definitions, or have references to local frame addresses. Only variables that are actually allocated on the stack are considered, optimized away variables or variables allocated in registers don’t count.
	- `-fstack-protector-all`
		Like -fstack-protector except that all functions are protected.
---
- `--param [name]=[value]` 设置参数
	In each case, the value is an integer. The following choices of name are recognized for all targets:
	- `predictable-branch-outcome`
		When branch is predicted to be taken with probability lower than this threshold (in percent), then it is considered well predictable.
	- `max-rtl-if-conversion-insns`
		RTL if-conversion tries to remove conditional branches around a block and replace them with conditionally executed instructions. This parameter gives the maximum number of instructions in a block which should be considered for if-conversion. The compiler will also use other heuristics to decide whether if-conversion is likely to be profitable.
	- `ssp-buffer-size`
		he minimum size of buffers (i.e. arrays) that receive stack smashing protection when 
		`-fstack-protector` is used.
---
- `-grecord-gcc-switches` 或者 `-gno-record-gcc-switches`
	This switch causes the command-line options used to invoke the compiler that may affect code generation to be appended to the DW_AT_producer attribute in DWARF debugging information. The options are concatenated with spaces separating them from each other and from the compiler version.
---
- `-m64` 64位
---
- `-mtune=[cpu-type]`指定cpu类型
---
- `-rdynamic` 
	Pass the flag `-export-dynamic` to the ELF linker, on targets that support it. This instructs the linker to add all symbols, not only used ones, to the dynamic symbol table. This option is needed for some uses of `dlopen` or to allow obtaining backtraces from within a program


	
		