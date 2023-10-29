
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5cb030ef          	jal	ra,ffffffffc0203e18 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2a658593          	addi	a1,a1,678 # ffffffffc02042f8 <etext>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2be50513          	addi	a0,a0,702 # ffffffffc0204318 <etext+0x20>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	100000ef          	jal	ra,ffffffffc0200166 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	73b000ef          	jal	ra,ffffffffc0200fa4 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	609010ef          	jal	ra,ffffffffc0201e7a <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35e000ef          	jal	ra,ffffffffc02003d4 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	434020ef          	jal	ra,ffffffffc02024ae <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3ae000ef          	jal	ra,ffffffffc020042c <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3f6000ef          	jal	ra,ffffffffc0200482 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	5fd030ef          	jal	ra,ffffffffc0203eae <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	5c9030ef          	jal	ra,ffffffffc0203eae <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3900006f          	j	ffffffffc0200482 <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	3be000ef          	jal	ra,ffffffffc02004b8 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200106:	00011317          	auipc	t1,0x11
ffffffffc020010a:	33a30313          	addi	t1,t1,826 # ffffffffc0211440 <is_panic>
ffffffffc020010e:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200112:	715d                	addi	sp,sp,-80
ffffffffc0200114:	ec06                	sd	ra,24(sp)
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	f436                	sd	a3,40(sp)
ffffffffc020011a:	f83a                	sd	a4,48(sp)
ffffffffc020011c:	fc3e                	sd	a5,56(sp)
ffffffffc020011e:	e0c2                	sd	a6,64(sp)
ffffffffc0200120:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200122:	02031c63          	bnez	t1,ffffffffc020015a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200126:	4785                	li	a5,1
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	00011717          	auipc	a4,0x11
ffffffffc020012e:	30f72b23          	sw	a5,790(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200132:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200134:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200136:	85aa                	mv	a1,a0
ffffffffc0200138:	00004517          	auipc	a0,0x4
ffffffffc020013c:	1e850513          	addi	a0,a0,488 # ffffffffc0204320 <etext+0x28>
    va_start(ap, fmt);
ffffffffc0200140:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200142:	f7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200146:	65a2                	ld	a1,8(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	f55ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014e:	00005517          	auipc	a0,0x5
ffffffffc0200152:	fe250513          	addi	a0,a0,-30 # ffffffffc0205130 <commands+0xcf0>
ffffffffc0200156:	f69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020015a:	3a0000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015e:	4501                	li	a0,0
ffffffffc0200160:	132000ef          	jal	ra,ffffffffc0200292 <kmonitor>
ffffffffc0200164:	bfed                	j	ffffffffc020015e <__panic+0x58>

ffffffffc0200166 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200166:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200168:	00004517          	auipc	a0,0x4
ffffffffc020016c:	20850513          	addi	a0,a0,520 # ffffffffc0204370 <etext+0x78>
void print_kerninfo(void) {
ffffffffc0200170:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200172:	f4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200176:	00000597          	auipc	a1,0x0
ffffffffc020017a:	ec058593          	addi	a1,a1,-320 # ffffffffc0200036 <kern_init>
ffffffffc020017e:	00004517          	auipc	a0,0x4
ffffffffc0200182:	21250513          	addi	a0,a0,530 # ffffffffc0204390 <etext+0x98>
ffffffffc0200186:	f39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020018a:	00004597          	auipc	a1,0x4
ffffffffc020018e:	16e58593          	addi	a1,a1,366 # ffffffffc02042f8 <etext>
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	21e50513          	addi	a0,a0,542 # ffffffffc02043b0 <etext+0xb8>
ffffffffc020019a:	f25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019e:	0000a597          	auipc	a1,0xa
ffffffffc02001a2:	ea258593          	addi	a1,a1,-350 # ffffffffc020a040 <edata>
ffffffffc02001a6:	00004517          	auipc	a0,0x4
ffffffffc02001aa:	22a50513          	addi	a0,a0,554 # ffffffffc02043d0 <etext+0xd8>
ffffffffc02001ae:	f11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b2:	00011597          	auipc	a1,0x11
ffffffffc02001b6:	3ee58593          	addi	a1,a1,1006 # ffffffffc02115a0 <end>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	23650513          	addi	a0,a0,566 # ffffffffc02043f0 <etext+0xf8>
ffffffffc02001c2:	efdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c6:	00011597          	auipc	a1,0x11
ffffffffc02001ca:	7d958593          	addi	a1,a1,2009 # ffffffffc021199f <end+0x3ff>
ffffffffc02001ce:	00000797          	auipc	a5,0x0
ffffffffc02001d2:	e6878793          	addi	a5,a5,-408 # ffffffffc0200036 <kern_init>
ffffffffc02001d6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00004517          	auipc	a0,0x4
ffffffffc02001ec:	22850513          	addi	a0,a0,552 # ffffffffc0204410 <etext+0x118>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	ecdff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	14860613          	addi	a2,a2,328 # ffffffffc0204340 <etext+0x48>
ffffffffc0200200:	04e00593          	li	a1,78
ffffffffc0200204:	00004517          	auipc	a0,0x4
ffffffffc0200208:	15450513          	addi	a0,a0,340 # ffffffffc0204358 <etext+0x60>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	ef9ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00004617          	auipc	a2,0x4
ffffffffc0200218:	30460613          	addi	a2,a2,772 # ffffffffc0204518 <commands+0xd8>
ffffffffc020021c:	00004597          	auipc	a1,0x4
ffffffffc0200220:	31c58593          	addi	a1,a1,796 # ffffffffc0204538 <commands+0xf8>
ffffffffc0200224:	00004517          	auipc	a0,0x4
ffffffffc0200228:	31c50513          	addi	a0,a0,796 # ffffffffc0204540 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	e91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200232:	00004617          	auipc	a2,0x4
ffffffffc0200236:	31e60613          	addi	a2,a2,798 # ffffffffc0204550 <commands+0x110>
ffffffffc020023a:	00004597          	auipc	a1,0x4
ffffffffc020023e:	33e58593          	addi	a1,a1,830 # ffffffffc0204578 <commands+0x138>
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	2fe50513          	addi	a0,a0,766 # ffffffffc0204540 <commands+0x100>
ffffffffc020024a:	e75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024e:	00004617          	auipc	a2,0x4
ffffffffc0200252:	33a60613          	addi	a2,a2,826 # ffffffffc0204588 <commands+0x148>
ffffffffc0200256:	00004597          	auipc	a1,0x4
ffffffffc020025a:	35258593          	addi	a1,a1,850 # ffffffffc02045a8 <commands+0x168>
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	2e250513          	addi	a0,a0,738 # ffffffffc0204540 <commands+0x100>
ffffffffc0200266:	e59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef1ff0ef          	jal	ra,ffffffffc0200166 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	1f050513          	addi	a0,a0,496 # ffffffffc0204488 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	ed5e                	sd	s7,152(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	1f650513          	addi	a0,a0,502 # ffffffffc02044b0 <commands+0x70>
ffffffffc02002c2:	dfdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000c0563          	beqz	s8,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	8562                	mv	a0,s8
ffffffffc02002cc:	492000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc02002d0:	00004c97          	auipc	s9,0x4
ffffffffc02002d4:	170c8c93          	addi	s9,s9,368 # ffffffffc0204440 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d8:	00005997          	auipc	s3,0x5
ffffffffc02002dc:	67898993          	addi	s3,s3,1656 # ffffffffc0205950 <commands+0x1510>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00004917          	auipc	s2,0x4
ffffffffc02002e4:	1f890913          	addi	s2,s2,504 # ffffffffc02044d8 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00004b17          	auipc	s6,0x4
ffffffffc02002ee:	1f6b0b13          	addi	s6,s6,502 # ffffffffc02044e0 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002f2:	00004a97          	auipc	s5,0x4
ffffffffc02002f6:	246a8a93          	addi	s5,s5,582 # ffffffffc0204538 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002fc:	854e                	mv	a0,s3
ffffffffc02002fe:	73d030ef          	jal	ra,ffffffffc020423a <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	c999                	beqz	a1,ffffffffc0200322 <kmonitor+0x90>
ffffffffc020030e:	854a                	mv	a0,s2
ffffffffc0200310:	2eb030ef          	jal	ra,ffffffffc0203dfa <strchr>
ffffffffc0200314:	c925                	beqz	a0,ffffffffc0200384 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200316:	00144583          	lbu	a1,1(s0)
ffffffffc020031a:	00040023          	sb	zero,0(s0)
ffffffffc020031e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200320:	f5fd                	bnez	a1,ffffffffc020030e <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200322:	dce9                	beqz	s1,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	00004d17          	auipc	s10,0x4
ffffffffc020032a:	11ad0d13          	addi	s10,s10,282 # ffffffffc0204440 <commands>
    if (argc == 0) {
ffffffffc020032e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200332:	0d61                	addi	s10,s10,24
ffffffffc0200334:	29d030ef          	jal	ra,ffffffffc0203dd0 <strcmp>
ffffffffc0200338:	c919                	beqz	a0,ffffffffc020034e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020033a:	2405                	addiw	s0,s0,1
ffffffffc020033c:	09740463          	beq	s0,s7,ffffffffc02003c4 <kmonitor+0x132>
ffffffffc0200340:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200344:	6582                	ld	a1,0(sp)
ffffffffc0200346:	0d61                	addi	s10,s10,24
ffffffffc0200348:	289030ef          	jal	ra,ffffffffc0203dd0 <strcmp>
ffffffffc020034c:	f57d                	bnez	a0,ffffffffc020033a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034e:	00141793          	slli	a5,s0,0x1
ffffffffc0200352:	97a2                	add	a5,a5,s0
ffffffffc0200354:	078e                	slli	a5,a5,0x3
ffffffffc0200356:	97e6                	add	a5,a5,s9
ffffffffc0200358:	6b9c                	ld	a5,16(a5)
ffffffffc020035a:	8662                	mv	a2,s8
ffffffffc020035c:	002c                	addi	a1,sp,8
ffffffffc020035e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200362:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200364:	f8055ce3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200368:	60ee                	ld	ra,216(sp)
ffffffffc020036a:	644e                	ld	s0,208(sp)
ffffffffc020036c:	64ae                	ld	s1,200(sp)
ffffffffc020036e:	690e                	ld	s2,192(sp)
ffffffffc0200370:	79ea                	ld	s3,184(sp)
ffffffffc0200372:	7a4a                	ld	s4,176(sp)
ffffffffc0200374:	7aaa                	ld	s5,168(sp)
ffffffffc0200376:	7b0a                	ld	s6,160(sp)
ffffffffc0200378:	6bea                	ld	s7,152(sp)
ffffffffc020037a:	6c4a                	ld	s8,144(sp)
ffffffffc020037c:	6caa                	ld	s9,136(sp)
ffffffffc020037e:	6d0a                	ld	s10,128(sp)
ffffffffc0200380:	612d                	addi	sp,sp,224
ffffffffc0200382:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200384:	00044783          	lbu	a5,0(s0)
ffffffffc0200388:	dfc9                	beqz	a5,ffffffffc0200322 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	03448863          	beq	s1,s4,ffffffffc02003ba <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038e:	00349793          	slli	a5,s1,0x3
ffffffffc0200392:	0118                	addi	a4,sp,128
ffffffffc0200394:	97ba                	add	a5,a5,a4
ffffffffc0200396:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	e591                	bnez	a1,ffffffffc02003ac <kmonitor+0x11a>
ffffffffc02003a2:	b749                	j	ffffffffc0200324 <kmonitor+0x92>
            buf ++;
ffffffffc02003a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a6:	00044583          	lbu	a1,0(s0)
ffffffffc02003aa:	ddad                	beqz	a1,ffffffffc0200324 <kmonitor+0x92>
ffffffffc02003ac:	854a                	mv	a0,s2
ffffffffc02003ae:	24d030ef          	jal	ra,ffffffffc0203dfa <strchr>
ffffffffc02003b2:	d96d                	beqz	a0,ffffffffc02003a4 <kmonitor+0x112>
ffffffffc02003b4:	00044583          	lbu	a1,0(s0)
ffffffffc02003b8:	bf91                	j	ffffffffc020030c <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ba:	45c1                	li	a1,16
ffffffffc02003bc:	855a                	mv	a0,s6
ffffffffc02003be:	d01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003c2:	b7f1                	j	ffffffffc020038e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c4:	6582                	ld	a1,0(sp)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	13a50513          	addi	a0,a0,314 # ffffffffc0204500 <commands+0xc0>
ffffffffc02003ce:	cf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003d2:	b72d                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003d4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d4:	8082                	ret

ffffffffc02003d6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d6:	00253513          	sltiu	a0,a0,2
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003dc:	03800513          	li	a0,56
ffffffffc02003e0:	8082                	ret

ffffffffc02003e2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003e2:	0000a797          	auipc	a5,0xa
ffffffffc02003e6:	c5e78793          	addi	a5,a5,-930 # ffffffffc020a040 <edata>
ffffffffc02003ea:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ee:	1141                	addi	sp,sp,-16
ffffffffc02003f0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f2:	95be                	add	a1,a1,a5
ffffffffc02003f4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003fa:	231030ef          	jal	ra,ffffffffc0203e2a <memcpy>
    return 0;
}
ffffffffc02003fe:	60a2                	ld	ra,8(sp)
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	0141                	addi	sp,sp,16
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200406:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200408:	0095979b          	slliw	a5,a1,0x9
ffffffffc020040c:	0000a517          	auipc	a0,0xa
ffffffffc0200410:	c3450513          	addi	a0,a0,-972 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc0200414:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200416:	00969613          	slli	a2,a3,0x9
ffffffffc020041a:	85ba                	mv	a1,a4
ffffffffc020041c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020041e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200420:	20b030ef          	jal	ra,ffffffffc0203e2a <memcpy>
    return 0;
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	4501                	li	a0,0
ffffffffc0200428:	0141                	addi	sp,sp,16
ffffffffc020042a:	8082                	ret

ffffffffc020042c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	00011717          	auipc	a4,0x11
ffffffffc0200436:	00f73b23          	sd	a5,22(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4881                	li	a7,0
ffffffffc0200446:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020044a:	02000793          	li	a5,32
ffffffffc020044e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	16650513          	addi	a0,a0,358 # ffffffffc02045b8 <commands+0x178>
    ticks = 0;
ffffffffc020045a:	00011797          	auipc	a5,0x11
ffffffffc020045e:	0007bf23          	sd	zero,30(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200462:	c5dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200466 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200466:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020046a:	00011797          	auipc	a5,0x11
ffffffffc020046e:	fde78793          	addi	a5,a5,-34 # ffffffffc0211448 <timebase>
ffffffffc0200472:	639c                	ld	a5,0(a5)
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4881                	li	a7,0
ffffffffc020047c:	00000073          	ecall
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200482:	100027f3          	csrr	a5,sstatus
ffffffffc0200486:	8b89                	andi	a5,a5,2
ffffffffc0200488:	0ff57513          	andi	a0,a0,255
ffffffffc020048c:	e799                	bnez	a5,ffffffffc020049a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020048e:	4581                	li	a1,0
ffffffffc0200490:	4601                	li	a2,0
ffffffffc0200492:	4885                	li	a7,1
ffffffffc0200494:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200498:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020049a:	1101                	addi	sp,sp,-32
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004a0:	05a000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004a4:	6522                	ld	a0,8(sp)
ffffffffc02004a6:	4581                	li	a1,0
ffffffffc02004a8:	4601                	li	a2,0
ffffffffc02004aa:	4885                	li	a7,1
ffffffffc02004ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004b0:	60e2                	ld	ra,24(sp)
ffffffffc02004b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004b4:	0400006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc02004b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
ffffffffc02004be:	eb89                	bnez	a5,ffffffffc02004d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	4581                	li	a1,0
ffffffffc02004c4:	4601                	li	a2,0
ffffffffc02004c6:	4889                	li	a7,2
ffffffffc02004c8:	00000073          	ecall
ffffffffc02004cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004ce:	8082                	ret
int cons_getc(void) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004d4:	026000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	4889                	li	a7,2
ffffffffc02004e0:	00000073          	ecall
ffffffffc02004e4:	2501                	sext.w	a0,a0
ffffffffc02004e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e8:	00c000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6522                	ld	a0,8(sp)
ffffffffc02004f0:	6105                	addi	sp,sp,32
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	38050513          	addi	a0,a0,896 # ffffffffc02048b0 <commands+0x470>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	f6478793          	addi	a5,a5,-156 # ffffffffc02114a0 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	6630106f          	j	ffffffffc02023b8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	37660613          	addi	a2,a2,886 # ffffffffc02048d0 <commands+0x490>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	38250513          	addi	a0,a0,898 # ffffffffc02048e8 <commands+0x4a8>
ffffffffc020056e:	b99ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	49a78793          	addi	a5,a5,1178 # ffffffffc0200a10 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	36850513          	addi	a0,a0,872 # ffffffffc0204900 <commands+0x4c0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	37050513          	addi	a0,a0,880 # ffffffffc0204918 <commands+0x4d8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	37a50513          	addi	a0,a0,890 # ffffffffc0204930 <commands+0x4f0>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	38450513          	addi	a0,a0,900 # ffffffffc0204948 <commands+0x508>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	38e50513          	addi	a0,a0,910 # ffffffffc0204960 <commands+0x520>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	39850513          	addi	a0,a0,920 # ffffffffc0204978 <commands+0x538>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	3a250513          	addi	a0,a0,930 # ffffffffc0204990 <commands+0x550>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	3ac50513          	addi	a0,a0,940 # ffffffffc02049a8 <commands+0x568>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	3b650513          	addi	a0,a0,950 # ffffffffc02049c0 <commands+0x580>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	3c050513          	addi	a0,a0,960 # ffffffffc02049d8 <commands+0x598>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	3ca50513          	addi	a0,a0,970 # ffffffffc02049f0 <commands+0x5b0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	3d450513          	addi	a0,a0,980 # ffffffffc0204a08 <commands+0x5c8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	3de50513          	addi	a0,a0,990 # ffffffffc0204a20 <commands+0x5e0>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	3e850513          	addi	a0,a0,1000 # ffffffffc0204a38 <commands+0x5f8>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	3f250513          	addi	a0,a0,1010 # ffffffffc0204a50 <commands+0x610>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204a68 <commands+0x628>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	40650513          	addi	a0,a0,1030 # ffffffffc0204a80 <commands+0x640>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	41050513          	addi	a0,a0,1040 # ffffffffc0204a98 <commands+0x658>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	41a50513          	addi	a0,a0,1050 # ffffffffc0204ab0 <commands+0x670>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	42450513          	addi	a0,a0,1060 # ffffffffc0204ac8 <commands+0x688>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	42e50513          	addi	a0,a0,1070 # ffffffffc0204ae0 <commands+0x6a0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	43850513          	addi	a0,a0,1080 # ffffffffc0204af8 <commands+0x6b8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	44250513          	addi	a0,a0,1090 # ffffffffc0204b10 <commands+0x6d0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	44c50513          	addi	a0,a0,1100 # ffffffffc0204b28 <commands+0x6e8>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	45650513          	addi	a0,a0,1110 # ffffffffc0204b40 <commands+0x700>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	46050513          	addi	a0,a0,1120 # ffffffffc0204b58 <commands+0x718>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204b70 <commands+0x730>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	47450513          	addi	a0,a0,1140 # ffffffffc0204b88 <commands+0x748>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	47e50513          	addi	a0,a0,1150 # ffffffffc0204ba0 <commands+0x760>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	48850513          	addi	a0,a0,1160 # ffffffffc0204bb8 <commands+0x778>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	49250513          	addi	a0,a0,1170 # ffffffffc0204bd0 <commands+0x790>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	49850513          	addi	a0,a0,1176 # ffffffffc0204be8 <commands+0x7a8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	49a50513          	addi	a0,a0,1178 # ffffffffc0204c00 <commands+0x7c0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	49a50513          	addi	a0,a0,1178 # ffffffffc0204c18 <commands+0x7d8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	4a250513          	addi	a0,a0,1186 # ffffffffc0204c30 <commands+0x7f0>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204c48 <commands+0x808>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	4ae50513          	addi	a0,a0,1198 # ffffffffc0204c60 <commands+0x820>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e0470713          	addi	a4,a4,-508 # ffffffffc02045d4 <commands+0x194>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	07e50513          	addi	a0,a0,126 # ffffffffc0204860 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	05250513          	addi	a0,a0,82 # ffffffffc0204840 <commands+0x400>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	00650513          	addi	a0,a0,6 # ffffffffc0204800 <commands+0x3c0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	01a50513          	addi	a0,a0,26 # ffffffffc0204820 <commands+0x3e0>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	07e50513          	addi	a0,a0,126 # ffffffffc0204890 <commands+0x450>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	c45ff0ef          	jal	ra,ffffffffc0200466 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5278793          	addi	a5,a5,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bf23          	sd	a5,-962(a3) # ffffffffc0211478 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	02c50513          	addi	a0,a0,44 # ffffffffc0204880 <commands+0x440>
}
ffffffffc020085c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085e:	861ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200862 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	473d                	li	a4,15
ffffffffc0200868:	16f76563          	bltu	a4,a5,ffffffffc02009d2 <exception_handler+0x170>
ffffffffc020086c:	00004717          	auipc	a4,0x4
ffffffffc0200870:	d9870713          	addi	a4,a4,-616 # ffffffffc0204604 <commands+0x1c4>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020087a:	1101                	addi	sp,sp,-32
ffffffffc020087c:	e822                	sd	s0,16(sp)
ffffffffc020087e:	ec06                	sd	ra,24(sp)
ffffffffc0200880:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	842a                	mv	s0,a0
ffffffffc0200886:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200888:	00004517          	auipc	a0,0x4
ffffffffc020088c:	f6050513          	addi	a0,a0,-160 # ffffffffc02047e8 <commands+0x3a8>
ffffffffc0200890:	82fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200894:	8522                	mv	a0,s0
ffffffffc0200896:	c6bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020089a:	84aa                	mv	s1,a0
ffffffffc020089c:	12051d63          	bnez	a0,ffffffffc02009d6 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a0:	60e2                	ld	ra,24(sp)
ffffffffc02008a2:	6442                	ld	s0,16(sp)
ffffffffc02008a4:	64a2                	ld	s1,8(sp)
ffffffffc02008a6:	6105                	addi	sp,sp,32
ffffffffc02008a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	d9e50513          	addi	a0,a0,-610 # ffffffffc0204648 <commands+0x208>
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ba:	805ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	daa50513          	addi	a0,a0,-598 # ffffffffc0204668 <commands+0x228>
ffffffffc02008c6:	b7f5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	dc050513          	addi	a0,a0,-576 # ffffffffc0204688 <commands+0x248>
ffffffffc02008d0:	b7cd                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	dce50513          	addi	a0,a0,-562 # ffffffffc02046a0 <commands+0x260>
ffffffffc02008da:	bfe1                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	dd450513          	addi	a0,a0,-556 # ffffffffc02046b0 <commands+0x270>
ffffffffc02008e4:	b7f9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	dea50513          	addi	a0,a0,-534 # ffffffffc02046d0 <commands+0x290>
ffffffffc02008ee:	fd0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f2:	8522                	mv	a0,s0
ffffffffc02008f4:	c0dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008f8:	84aa                	mv	s1,a0
ffffffffc02008fa:	d15d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fc:	8522                	mv	a0,s0
ffffffffc02008fe:	e61ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200902:	86a6                	mv	a3,s1
ffffffffc0200904:	00004617          	auipc	a2,0x4
ffffffffc0200908:	de460613          	addi	a2,a2,-540 # ffffffffc02046e8 <commands+0x2a8>
ffffffffc020090c:	0ca00593          	li	a1,202
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	fd850513          	addi	a0,a0,-40 # ffffffffc02048e8 <commands+0x4a8>
ffffffffc0200918:	feeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020091c:	00004517          	auipc	a0,0x4
ffffffffc0200920:	dec50513          	addi	a0,a0,-532 # ffffffffc0204708 <commands+0x2c8>
ffffffffc0200924:	b779                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0204720 <commands+0x2e0>
ffffffffc020092e:	f90ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200932:	8522                	mv	a0,s0
ffffffffc0200934:	bcdff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200938:	84aa                	mv	s1,a0
ffffffffc020093a:	d13d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	e21ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200942:	86a6                	mv	a3,s1
ffffffffc0200944:	00004617          	auipc	a2,0x4
ffffffffc0200948:	da460613          	addi	a2,a2,-604 # ffffffffc02046e8 <commands+0x2a8>
ffffffffc020094c:	0d400593          	li	a1,212
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	f9850513          	addi	a0,a0,-104 # ffffffffc02048e8 <commands+0x4a8>
ffffffffc0200958:	faeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	ddc50513          	addi	a0,a0,-548 # ffffffffc0204738 <commands+0x2f8>
ffffffffc0200964:	b7b9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	df250513          	addi	a0,a0,-526 # ffffffffc0204758 <commands+0x318>
ffffffffc020096e:	b791                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	e0850513          	addi	a0,a0,-504 # ffffffffc0204778 <commands+0x338>
ffffffffc0200978:	bf2d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	e1e50513          	addi	a0,a0,-482 # ffffffffc0204798 <commands+0x358>
ffffffffc0200982:	bf05                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	e3450513          	addi	a0,a0,-460 # ffffffffc02047b8 <commands+0x378>
ffffffffc020098c:	b71d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	e4250513          	addi	a0,a0,-446 # ffffffffc02047d0 <commands+0x390>
ffffffffc0200996:	f28ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	b65ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009a0:	84aa                	mv	s1,a0
ffffffffc02009a2:	ee050fe3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	db7ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ac:	86a6                	mv	a3,s1
ffffffffc02009ae:	00004617          	auipc	a2,0x4
ffffffffc02009b2:	d3a60613          	addi	a2,a2,-710 # ffffffffc02046e8 <commands+0x2a8>
ffffffffc02009b6:	0ea00593          	li	a1,234
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	f2e50513          	addi	a0,a0,-210 # ffffffffc02048e8 <commands+0x4a8>
ffffffffc02009c2:	f44ff0ef          	jal	ra,ffffffffc0200106 <__panic>
}
ffffffffc02009c6:	6442                	ld	s0,16(sp)
ffffffffc02009c8:	60e2                	ld	ra,24(sp)
ffffffffc02009ca:	64a2                	ld	s1,8(sp)
ffffffffc02009cc:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009ce:	d91ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009d2:	d8dff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009d6:	8522                	mv	a0,s0
ffffffffc02009d8:	d87ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009dc:	86a6                	mv	a3,s1
ffffffffc02009de:	00004617          	auipc	a2,0x4
ffffffffc02009e2:	d0a60613          	addi	a2,a2,-758 # ffffffffc02046e8 <commands+0x2a8>
ffffffffc02009e6:	0f100593          	li	a1,241
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	efe50513          	addi	a0,a0,-258 # ffffffffc02048e8 <commands+0x4a8>
ffffffffc02009f2:	f14ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02009f6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009f6:	11853783          	ld	a5,280(a0)
ffffffffc02009fa:	0007c463          	bltz	a5,ffffffffc0200a02 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009fe:	e65ff06f          	j	ffffffffc0200862 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a02:	dbfff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f85ff0ef          	jal	ra,ffffffffc02009f6 <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <pa2page.part.4>:

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ad0:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200ad2:	00004617          	auipc	a2,0x4
ffffffffc0200ad6:	22660613          	addi	a2,a2,550 # ffffffffc0204cf8 <commands+0x8b8>
ffffffffc0200ada:	06500593          	li	a1,101
ffffffffc0200ade:	00004517          	auipc	a0,0x4
ffffffffc0200ae2:	23a50513          	addi	a0,a0,570 # ffffffffc0204d18 <commands+0x8d8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ae6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200ae8:	e1eff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200aec <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200aec:	715d                	addi	sp,sp,-80
ffffffffc0200aee:	e0a2                	sd	s0,64(sp)
ffffffffc0200af0:	fc26                	sd	s1,56(sp)
ffffffffc0200af2:	f84a                	sd	s2,48(sp)
ffffffffc0200af4:	f44e                	sd	s3,40(sp)
ffffffffc0200af6:	f052                	sd	s4,32(sp)
ffffffffc0200af8:	ec56                	sd	s5,24(sp)
ffffffffc0200afa:	e486                	sd	ra,72(sp)
ffffffffc0200afc:	842a                	mv	s0,a0
ffffffffc0200afe:	00011497          	auipc	s1,0x11
ffffffffc0200b02:	98248493          	addi	s1,s1,-1662 # ffffffffc0211480 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b06:	4985                	li	s3,1
ffffffffc0200b08:	00011a17          	auipc	s4,0x11
ffffffffc0200b0c:	968a0a13          	addi	s4,s4,-1688 # ffffffffc0211470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b10:	0005091b          	sext.w	s2,a0
ffffffffc0200b14:	00011a97          	auipc	s5,0x11
ffffffffc0200b18:	98ca8a93          	addi	s5,s5,-1652 # ffffffffc02114a0 <check_mm_struct>
ffffffffc0200b1c:	a00d                	j	ffffffffc0200b3e <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b1e:	609c                	ld	a5,0(s1)
ffffffffc0200b20:	6f9c                	ld	a5,24(a5)
ffffffffc0200b22:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b24:	4601                	li	a2,0
ffffffffc0200b26:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b28:	ed0d                	bnez	a0,ffffffffc0200b62 <alloc_pages+0x76>
ffffffffc0200b2a:	0289ec63          	bltu	s3,s0,ffffffffc0200b62 <alloc_pages+0x76>
ffffffffc0200b2e:	000a2783          	lw	a5,0(s4)
ffffffffc0200b32:	2781                	sext.w	a5,a5
ffffffffc0200b34:	c79d                	beqz	a5,ffffffffc0200b62 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b36:	000ab503          	ld	a0,0(s5)
ffffffffc0200b3a:	034020ef          	jal	ra,ffffffffc0202b6e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b3e:	100027f3          	csrr	a5,sstatus
ffffffffc0200b42:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b44:	8522                	mv	a0,s0
ffffffffc0200b46:	dfe1                	beqz	a5,ffffffffc0200b1e <alloc_pages+0x32>
        intr_disable();
ffffffffc0200b48:	9b3ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200b4c:	609c                	ld	a5,0(s1)
ffffffffc0200b4e:	8522                	mv	a0,s0
ffffffffc0200b50:	6f9c                	ld	a5,24(a5)
ffffffffc0200b52:	9782                	jalr	a5
ffffffffc0200b54:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200b56:	99fff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc0200b5a:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b5c:	4601                	li	a2,0
ffffffffc0200b5e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b60:	d569                	beqz	a0,ffffffffc0200b2a <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200b62:	60a6                	ld	ra,72(sp)
ffffffffc0200b64:	6406                	ld	s0,64(sp)
ffffffffc0200b66:	74e2                	ld	s1,56(sp)
ffffffffc0200b68:	7942                	ld	s2,48(sp)
ffffffffc0200b6a:	79a2                	ld	s3,40(sp)
ffffffffc0200b6c:	7a02                	ld	s4,32(sp)
ffffffffc0200b6e:	6ae2                	ld	s5,24(sp)
ffffffffc0200b70:	6161                	addi	sp,sp,80
ffffffffc0200b72:	8082                	ret

ffffffffc0200b74 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b74:	100027f3          	csrr	a5,sstatus
ffffffffc0200b78:	8b89                	andi	a5,a5,2
ffffffffc0200b7a:	eb89                	bnez	a5,ffffffffc0200b8c <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b7c:	00011797          	auipc	a5,0x11
ffffffffc0200b80:	90478793          	addi	a5,a5,-1788 # ffffffffc0211480 <pmm_manager>
ffffffffc0200b84:	639c                	ld	a5,0(a5)
ffffffffc0200b86:	0207b303          	ld	t1,32(a5)
ffffffffc0200b8a:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200b8c:	1101                	addi	sp,sp,-32
ffffffffc0200b8e:	ec06                	sd	ra,24(sp)
ffffffffc0200b90:	e822                	sd	s0,16(sp)
ffffffffc0200b92:	e426                	sd	s1,8(sp)
ffffffffc0200b94:	842a                	mv	s0,a0
ffffffffc0200b96:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200b98:	963ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b9c:	00011797          	auipc	a5,0x11
ffffffffc0200ba0:	8e478793          	addi	a5,a5,-1820 # ffffffffc0211480 <pmm_manager>
ffffffffc0200ba4:	639c                	ld	a5,0(a5)
ffffffffc0200ba6:	85a6                	mv	a1,s1
ffffffffc0200ba8:	8522                	mv	a0,s0
ffffffffc0200baa:	739c                	ld	a5,32(a5)
ffffffffc0200bac:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0200bae:	6442                	ld	s0,16(sp)
ffffffffc0200bb0:	60e2                	ld	ra,24(sp)
ffffffffc0200bb2:	64a2                	ld	s1,8(sp)
ffffffffc0200bb4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200bb6:	93fff06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200bba <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bba:	100027f3          	csrr	a5,sstatus
ffffffffc0200bbe:	8b89                	andi	a5,a5,2
ffffffffc0200bc0:	eb89                	bnez	a5,ffffffffc0200bd2 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200bc2:	00011797          	auipc	a5,0x11
ffffffffc0200bc6:	8be78793          	addi	a5,a5,-1858 # ffffffffc0211480 <pmm_manager>
ffffffffc0200bca:	639c                	ld	a5,0(a5)
ffffffffc0200bcc:	0287b303          	ld	t1,40(a5)
ffffffffc0200bd0:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200bd2:	1141                	addi	sp,sp,-16
ffffffffc0200bd4:	e406                	sd	ra,8(sp)
ffffffffc0200bd6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200bd8:	923ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200bdc:	00011797          	auipc	a5,0x11
ffffffffc0200be0:	8a478793          	addi	a5,a5,-1884 # ffffffffc0211480 <pmm_manager>
ffffffffc0200be4:	639c                	ld	a5,0(a5)
ffffffffc0200be6:	779c                	ld	a5,40(a5)
ffffffffc0200be8:	9782                	jalr	a5
ffffffffc0200bea:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200bec:	909ff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200bf0:	8522                	mv	a0,s0
ffffffffc0200bf2:	60a2                	ld	ra,8(sp)
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	0141                	addi	sp,sp,16
ffffffffc0200bf8:	8082                	ret

ffffffffc0200bfa <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bfa:	715d                	addi	sp,sp,-80
ffffffffc0200bfc:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bfe:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200c02:	1ff4f493          	andi	s1,s1,511
ffffffffc0200c06:	048e                	slli	s1,s1,0x3
ffffffffc0200c08:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c0a:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c0c:	f84a                	sd	s2,48(sp)
ffffffffc0200c0e:	f44e                	sd	s3,40(sp)
ffffffffc0200c10:	f052                	sd	s4,32(sp)
ffffffffc0200c12:	e486                	sd	ra,72(sp)
ffffffffc0200c14:	e0a2                	sd	s0,64(sp)
ffffffffc0200c16:	ec56                	sd	s5,24(sp)
ffffffffc0200c18:	e85a                	sd	s6,16(sp)
ffffffffc0200c1a:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c1c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c20:	892e                	mv	s2,a1
ffffffffc0200c22:	8a32                	mv	s4,a2
ffffffffc0200c24:	00011997          	auipc	s3,0x11
ffffffffc0200c28:	83498993          	addi	s3,s3,-1996 # ffffffffc0211458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c2c:	e3c9                	bnez	a5,ffffffffc0200cae <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200c2e:	16060163          	beqz	a2,ffffffffc0200d90 <get_pte+0x196>
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	eb9ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0200c38:	842a                	mv	s0,a0
ffffffffc0200c3a:	14050b63          	beqz	a0,ffffffffc0200d90 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c3e:	00011b97          	auipc	s7,0x11
ffffffffc0200c42:	85ab8b93          	addi	s7,s7,-1958 # ffffffffc0211498 <pages>
ffffffffc0200c46:	000bb503          	ld	a0,0(s7)
ffffffffc0200c4a:	00004797          	auipc	a5,0x4
ffffffffc0200c4e:	02e78793          	addi	a5,a5,46 # ffffffffc0204c78 <commands+0x838>
ffffffffc0200c52:	0007bb03          	ld	s6,0(a5)
ffffffffc0200c56:	40a40533          	sub	a0,s0,a0
ffffffffc0200c5a:	850d                	srai	a0,a0,0x3
ffffffffc0200c5c:	03650533          	mul	a0,a0,s6
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c60:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200c62:	00010997          	auipc	s3,0x10
ffffffffc0200c66:	7f698993          	addi	s3,s3,2038 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c6a:	00080ab7          	lui	s5,0x80
ffffffffc0200c6e:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c72:	c01c                	sw	a5,0(s0)
ffffffffc0200c74:	57fd                	li	a5,-1
ffffffffc0200c76:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c78:	9556                	add	a0,a0,s5
ffffffffc0200c7a:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c7c:	0532                	slli	a0,a0,0xc
ffffffffc0200c7e:	16e7f063          	bleu	a4,a5,ffffffffc0200dde <get_pte+0x1e4>
ffffffffc0200c82:	00011797          	auipc	a5,0x11
ffffffffc0200c86:	80678793          	addi	a5,a5,-2042 # ffffffffc0211488 <va_pa_offset>
ffffffffc0200c8a:	639c                	ld	a5,0(a5)
ffffffffc0200c8c:	6605                	lui	a2,0x1
ffffffffc0200c8e:	4581                	li	a1,0
ffffffffc0200c90:	953e                	add	a0,a0,a5
ffffffffc0200c92:	186030ef          	jal	ra,ffffffffc0203e18 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c96:	000bb683          	ld	a3,0(s7)
ffffffffc0200c9a:	40d406b3          	sub	a3,s0,a3
ffffffffc0200c9e:	868d                	srai	a3,a3,0x3
ffffffffc0200ca0:	036686b3          	mul	a3,a3,s6
ffffffffc0200ca4:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ca6:	06aa                	slli	a3,a3,0xa
ffffffffc0200ca8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200cac:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200cae:	77fd                	lui	a5,0xfffff
ffffffffc0200cb0:	068a                	slli	a3,a3,0x2
ffffffffc0200cb2:	0009b703          	ld	a4,0(s3)
ffffffffc0200cb6:	8efd                	and	a3,a3,a5
ffffffffc0200cb8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200cbc:	0ce7fc63          	bleu	a4,a5,ffffffffc0200d94 <get_pte+0x19a>
ffffffffc0200cc0:	00010a97          	auipc	s5,0x10
ffffffffc0200cc4:	7c8a8a93          	addi	s5,s5,1992 # ffffffffc0211488 <va_pa_offset>
ffffffffc0200cc8:	000ab403          	ld	s0,0(s5)
ffffffffc0200ccc:	01595793          	srli	a5,s2,0x15
ffffffffc0200cd0:	1ff7f793          	andi	a5,a5,511
ffffffffc0200cd4:	96a2                	add	a3,a3,s0
ffffffffc0200cd6:	00379413          	slli	s0,a5,0x3
ffffffffc0200cda:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200cdc:	6014                	ld	a3,0(s0)
ffffffffc0200cde:	0016f793          	andi	a5,a3,1
ffffffffc0200ce2:	ebbd                	bnez	a5,ffffffffc0200d58 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200ce4:	0a0a0663          	beqz	s4,ffffffffc0200d90 <get_pte+0x196>
ffffffffc0200ce8:	4505                	li	a0,1
ffffffffc0200cea:	e03ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0200cee:	84aa                	mv	s1,a0
ffffffffc0200cf0:	c145                	beqz	a0,ffffffffc0200d90 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cf2:	00010b97          	auipc	s7,0x10
ffffffffc0200cf6:	7a6b8b93          	addi	s7,s7,1958 # ffffffffc0211498 <pages>
ffffffffc0200cfa:	000bb503          	ld	a0,0(s7)
ffffffffc0200cfe:	00004797          	auipc	a5,0x4
ffffffffc0200d02:	f7a78793          	addi	a5,a5,-134 # ffffffffc0204c78 <commands+0x838>
ffffffffc0200d06:	0007bb03          	ld	s6,0(a5)
ffffffffc0200d0a:	40a48533          	sub	a0,s1,a0
ffffffffc0200d0e:	850d                	srai	a0,a0,0x3
ffffffffc0200d10:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d14:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d16:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d1a:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d1e:	c09c                	sw	a5,0(s1)
ffffffffc0200d20:	57fd                	li	a5,-1
ffffffffc0200d22:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d24:	9552                	add	a0,a0,s4
ffffffffc0200d26:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d28:	0532                	slli	a0,a0,0xc
ffffffffc0200d2a:	08e7fd63          	bleu	a4,a5,ffffffffc0200dc4 <get_pte+0x1ca>
ffffffffc0200d2e:	000ab783          	ld	a5,0(s5)
ffffffffc0200d32:	6605                	lui	a2,0x1
ffffffffc0200d34:	4581                	li	a1,0
ffffffffc0200d36:	953e                	add	a0,a0,a5
ffffffffc0200d38:	0e0030ef          	jal	ra,ffffffffc0203e18 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d3c:	000bb683          	ld	a3,0(s7)
ffffffffc0200d40:	40d486b3          	sub	a3,s1,a3
ffffffffc0200d44:	868d                	srai	a3,a3,0x3
ffffffffc0200d46:	036686b3          	mul	a3,a3,s6
ffffffffc0200d4a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d4c:	06aa                	slli	a3,a3,0xa
ffffffffc0200d4e:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d52:	e014                	sd	a3,0(s0)
ffffffffc0200d54:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d58:	068a                	slli	a3,a3,0x2
ffffffffc0200d5a:	757d                	lui	a0,0xfffff
ffffffffc0200d5c:	8ee9                	and	a3,a3,a0
ffffffffc0200d5e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d62:	04e7f563          	bleu	a4,a5,ffffffffc0200dac <get_pte+0x1b2>
ffffffffc0200d66:	000ab503          	ld	a0,0(s5)
ffffffffc0200d6a:	00c95793          	srli	a5,s2,0xc
ffffffffc0200d6e:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d72:	96aa                	add	a3,a3,a0
ffffffffc0200d74:	00379513          	slli	a0,a5,0x3
ffffffffc0200d78:	9536                	add	a0,a0,a3
}
ffffffffc0200d7a:	60a6                	ld	ra,72(sp)
ffffffffc0200d7c:	6406                	ld	s0,64(sp)
ffffffffc0200d7e:	74e2                	ld	s1,56(sp)
ffffffffc0200d80:	7942                	ld	s2,48(sp)
ffffffffc0200d82:	79a2                	ld	s3,40(sp)
ffffffffc0200d84:	7a02                	ld	s4,32(sp)
ffffffffc0200d86:	6ae2                	ld	s5,24(sp)
ffffffffc0200d88:	6b42                	ld	s6,16(sp)
ffffffffc0200d8a:	6ba2                	ld	s7,8(sp)
ffffffffc0200d8c:	6161                	addi	sp,sp,80
ffffffffc0200d8e:	8082                	ret
            return NULL;
ffffffffc0200d90:	4501                	li	a0,0
ffffffffc0200d92:	b7e5                	j	ffffffffc0200d7a <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d94:	00004617          	auipc	a2,0x4
ffffffffc0200d98:	eec60613          	addi	a2,a2,-276 # ffffffffc0204c80 <commands+0x840>
ffffffffc0200d9c:	10200593          	li	a1,258
ffffffffc0200da0:	00004517          	auipc	a0,0x4
ffffffffc0200da4:	f0850513          	addi	a0,a0,-248 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0200da8:	b5eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200dac:	00004617          	auipc	a2,0x4
ffffffffc0200db0:	ed460613          	addi	a2,a2,-300 # ffffffffc0204c80 <commands+0x840>
ffffffffc0200db4:	10f00593          	li	a1,271
ffffffffc0200db8:	00004517          	auipc	a0,0x4
ffffffffc0200dbc:	ef050513          	addi	a0,a0,-272 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0200dc0:	b46ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200dc4:	86aa                	mv	a3,a0
ffffffffc0200dc6:	00004617          	auipc	a2,0x4
ffffffffc0200dca:	eba60613          	addi	a2,a2,-326 # ffffffffc0204c80 <commands+0x840>
ffffffffc0200dce:	10b00593          	li	a1,267
ffffffffc0200dd2:	00004517          	auipc	a0,0x4
ffffffffc0200dd6:	ed650513          	addi	a0,a0,-298 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0200dda:	b2cff0ef          	jal	ra,ffffffffc0200106 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200dde:	86aa                	mv	a3,a0
ffffffffc0200de0:	00004617          	auipc	a2,0x4
ffffffffc0200de4:	ea060613          	addi	a2,a2,-352 # ffffffffc0204c80 <commands+0x840>
ffffffffc0200de8:	0ff00593          	li	a1,255
ffffffffc0200dec:	00004517          	auipc	a0,0x4
ffffffffc0200df0:	ebc50513          	addi	a0,a0,-324 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0200df4:	b12ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200df8 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200df8:	1141                	addi	sp,sp,-16
ffffffffc0200dfa:	e022                	sd	s0,0(sp)
ffffffffc0200dfc:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200dfe:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e00:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e02:	df9ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e06:	c011                	beqz	s0,ffffffffc0200e0a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e08:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e0a:	c521                	beqz	a0,ffffffffc0200e52 <get_page+0x5a>
ffffffffc0200e0c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e0e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e10:	0017f713          	andi	a4,a5,1
ffffffffc0200e14:	e709                	bnez	a4,ffffffffc0200e1e <get_page+0x26>
}
ffffffffc0200e16:	60a2                	ld	ra,8(sp)
ffffffffc0200e18:	6402                	ld	s0,0(sp)
ffffffffc0200e1a:	0141                	addi	sp,sp,16
ffffffffc0200e1c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200e1e:	00010717          	auipc	a4,0x10
ffffffffc0200e22:	63a70713          	addi	a4,a4,1594 # ffffffffc0211458 <npage>
ffffffffc0200e26:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e28:	078a                	slli	a5,a5,0x2
ffffffffc0200e2a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e2c:	02e7f863          	bleu	a4,a5,ffffffffc0200e5c <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e30:	fff80537          	lui	a0,0xfff80
ffffffffc0200e34:	97aa                	add	a5,a5,a0
ffffffffc0200e36:	00010697          	auipc	a3,0x10
ffffffffc0200e3a:	66268693          	addi	a3,a3,1634 # ffffffffc0211498 <pages>
ffffffffc0200e3e:	6288                	ld	a0,0(a3)
ffffffffc0200e40:	60a2                	ld	ra,8(sp)
ffffffffc0200e42:	6402                	ld	s0,0(sp)
ffffffffc0200e44:	00379713          	slli	a4,a5,0x3
ffffffffc0200e48:	97ba                	add	a5,a5,a4
ffffffffc0200e4a:	078e                	slli	a5,a5,0x3
ffffffffc0200e4c:	953e                	add	a0,a0,a5
ffffffffc0200e4e:	0141                	addi	sp,sp,16
ffffffffc0200e50:	8082                	ret
ffffffffc0200e52:	60a2                	ld	ra,8(sp)
ffffffffc0200e54:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0200e56:	4501                	li	a0,0
}
ffffffffc0200e58:	0141                	addi	sp,sp,16
ffffffffc0200e5a:	8082                	ret
ffffffffc0200e5c:	c75ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>

ffffffffc0200e60 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e60:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e62:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e64:	e406                	sd	ra,8(sp)
ffffffffc0200e66:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e68:	d93ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    if (ptep != NULL) {
ffffffffc0200e6c:	c511                	beqz	a0,ffffffffc0200e78 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200e6e:	611c                	ld	a5,0(a0)
ffffffffc0200e70:	842a                	mv	s0,a0
ffffffffc0200e72:	0017f713          	andi	a4,a5,1
ffffffffc0200e76:	e709                	bnez	a4,ffffffffc0200e80 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200e78:	60a2                	ld	ra,8(sp)
ffffffffc0200e7a:	6402                	ld	s0,0(sp)
ffffffffc0200e7c:	0141                	addi	sp,sp,16
ffffffffc0200e7e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200e80:	00010717          	auipc	a4,0x10
ffffffffc0200e84:	5d870713          	addi	a4,a4,1496 # ffffffffc0211458 <npage>
ffffffffc0200e88:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e8a:	078a                	slli	a5,a5,0x2
ffffffffc0200e8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e8e:	04e7f063          	bleu	a4,a5,ffffffffc0200ece <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e92:	fff80737          	lui	a4,0xfff80
ffffffffc0200e96:	97ba                	add	a5,a5,a4
ffffffffc0200e98:	00010717          	auipc	a4,0x10
ffffffffc0200e9c:	60070713          	addi	a4,a4,1536 # ffffffffc0211498 <pages>
ffffffffc0200ea0:	6308                	ld	a0,0(a4)
ffffffffc0200ea2:	00379713          	slli	a4,a5,0x3
ffffffffc0200ea6:	97ba                	add	a5,a5,a4
ffffffffc0200ea8:	078e                	slli	a5,a5,0x3
ffffffffc0200eaa:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200eac:	411c                	lw	a5,0(a0)
ffffffffc0200eae:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200eb2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200eb4:	cb09                	beqz	a4,ffffffffc0200ec6 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200eb6:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200eba:	12000073          	sfence.vma
}
ffffffffc0200ebe:	60a2                	ld	ra,8(sp)
ffffffffc0200ec0:	6402                	ld	s0,0(sp)
ffffffffc0200ec2:	0141                	addi	sp,sp,16
ffffffffc0200ec4:	8082                	ret
            free_page(page);
ffffffffc0200ec6:	4585                	li	a1,1
ffffffffc0200ec8:	cadff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
ffffffffc0200ecc:	b7ed                	j	ffffffffc0200eb6 <page_remove+0x56>
ffffffffc0200ece:	c03ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>

ffffffffc0200ed2 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200ed2:	7179                	addi	sp,sp,-48
ffffffffc0200ed4:	87b2                	mv	a5,a2
ffffffffc0200ed6:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ed8:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eda:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200edc:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200ede:	ec26                	sd	s1,24(sp)
ffffffffc0200ee0:	f406                	sd	ra,40(sp)
ffffffffc0200ee2:	e84a                	sd	s2,16(sp)
ffffffffc0200ee4:	e44e                	sd	s3,8(sp)
ffffffffc0200ee6:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ee8:	d13ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    if (ptep == NULL) {
ffffffffc0200eec:	c945                	beqz	a0,ffffffffc0200f9c <page_insert+0xca>
    page->ref += 1;
ffffffffc0200eee:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0200ef0:	611c                	ld	a5,0(a0)
ffffffffc0200ef2:	892a                	mv	s2,a0
ffffffffc0200ef4:	0016871b          	addiw	a4,a3,1
ffffffffc0200ef8:	c018                	sw	a4,0(s0)
ffffffffc0200efa:	0017f713          	andi	a4,a5,1
ffffffffc0200efe:	e339                	bnez	a4,ffffffffc0200f44 <page_insert+0x72>
ffffffffc0200f00:	00010797          	auipc	a5,0x10
ffffffffc0200f04:	59878793          	addi	a5,a5,1432 # ffffffffc0211498 <pages>
ffffffffc0200f08:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200f0a:	00004717          	auipc	a4,0x4
ffffffffc0200f0e:	d6e70713          	addi	a4,a4,-658 # ffffffffc0204c78 <commands+0x838>
ffffffffc0200f12:	40f407b3          	sub	a5,s0,a5
ffffffffc0200f16:	6300                	ld	s0,0(a4)
ffffffffc0200f18:	878d                	srai	a5,a5,0x3
ffffffffc0200f1a:	000806b7          	lui	a3,0x80
ffffffffc0200f1e:	028787b3          	mul	a5,a5,s0
ffffffffc0200f22:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f24:	07aa                	slli	a5,a5,0xa
ffffffffc0200f26:	8fc5                	or	a5,a5,s1
ffffffffc0200f28:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f2c:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f30:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0200f34:	4501                	li	a0,0
}
ffffffffc0200f36:	70a2                	ld	ra,40(sp)
ffffffffc0200f38:	7402                	ld	s0,32(sp)
ffffffffc0200f3a:	64e2                	ld	s1,24(sp)
ffffffffc0200f3c:	6942                	ld	s2,16(sp)
ffffffffc0200f3e:	69a2                	ld	s3,8(sp)
ffffffffc0200f40:	6145                	addi	sp,sp,48
ffffffffc0200f42:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200f44:	00010717          	auipc	a4,0x10
ffffffffc0200f48:	51470713          	addi	a4,a4,1300 # ffffffffc0211458 <npage>
ffffffffc0200f4c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f4e:	00279513          	slli	a0,a5,0x2
ffffffffc0200f52:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f54:	04e57663          	bleu	a4,a0,ffffffffc0200fa0 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f58:	fff807b7          	lui	a5,0xfff80
ffffffffc0200f5c:	953e                	add	a0,a0,a5
ffffffffc0200f5e:	00010997          	auipc	s3,0x10
ffffffffc0200f62:	53a98993          	addi	s3,s3,1338 # ffffffffc0211498 <pages>
ffffffffc0200f66:	0009b783          	ld	a5,0(s3)
ffffffffc0200f6a:	00351713          	slli	a4,a0,0x3
ffffffffc0200f6e:	953a                	add	a0,a0,a4
ffffffffc0200f70:	050e                	slli	a0,a0,0x3
ffffffffc0200f72:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0200f74:	00a40e63          	beq	s0,a0,ffffffffc0200f90 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0200f78:	411c                	lw	a5,0(a0)
ffffffffc0200f7a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f7e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f80:	cb11                	beqz	a4,ffffffffc0200f94 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f82:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f86:	12000073          	sfence.vma
ffffffffc0200f8a:	0009b783          	ld	a5,0(s3)
ffffffffc0200f8e:	bfb5                	j	ffffffffc0200f0a <page_insert+0x38>
    page->ref -= 1;
ffffffffc0200f90:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200f92:	bfa5                	j	ffffffffc0200f0a <page_insert+0x38>
            free_page(page);
ffffffffc0200f94:	4585                	li	a1,1
ffffffffc0200f96:	bdfff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
ffffffffc0200f9a:	b7e5                	j	ffffffffc0200f82 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0200f9c:	5571                	li	a0,-4
ffffffffc0200f9e:	bf61                	j	ffffffffc0200f36 <page_insert+0x64>
ffffffffc0200fa0:	b31ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>

ffffffffc0200fa4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200fa4:	00005797          	auipc	a5,0x5
ffffffffc0200fa8:	da478793          	addi	a5,a5,-604 # ffffffffc0205d48 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fac:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0200fae:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fb0:	00004517          	auipc	a0,0x4
ffffffffc0200fb4:	d9050513          	addi	a0,a0,-624 # ffffffffc0204d40 <commands+0x900>
void pmm_init(void) {
ffffffffc0200fb8:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200fba:	00010717          	auipc	a4,0x10
ffffffffc0200fbe:	4cf73323          	sd	a5,1222(a4) # ffffffffc0211480 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fc2:	e8a2                	sd	s0,80(sp)
ffffffffc0200fc4:	e4a6                	sd	s1,72(sp)
ffffffffc0200fc6:	e0ca                	sd	s2,64(sp)
ffffffffc0200fc8:	fc4e                	sd	s3,56(sp)
ffffffffc0200fca:	f852                	sd	s4,48(sp)
ffffffffc0200fcc:	f456                	sd	s5,40(sp)
ffffffffc0200fce:	f05a                	sd	s6,32(sp)
ffffffffc0200fd0:	ec5e                	sd	s7,24(sp)
ffffffffc0200fd2:	e862                	sd	s8,16(sp)
ffffffffc0200fd4:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200fd6:	00010417          	auipc	s0,0x10
ffffffffc0200fda:	4aa40413          	addi	s0,s0,1194 # ffffffffc0211480 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fde:	8e0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0200fe2:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0200fe4:	49c5                	li	s3,17
ffffffffc0200fe6:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0200fea:	679c                	ld	a5,8(a5)
ffffffffc0200fec:	00010497          	auipc	s1,0x10
ffffffffc0200ff0:	46c48493          	addi	s1,s1,1132 # ffffffffc0211458 <npage>
ffffffffc0200ff4:	00010917          	auipc	s2,0x10
ffffffffc0200ff8:	4a490913          	addi	s2,s2,1188 # ffffffffc0211498 <pages>
ffffffffc0200ffc:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200ffe:	57f5                	li	a5,-3
ffffffffc0201000:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201002:	07e006b7          	lui	a3,0x7e00
ffffffffc0201006:	01b99613          	slli	a2,s3,0x1b
ffffffffc020100a:	015a1593          	slli	a1,s4,0x15
ffffffffc020100e:	00004517          	auipc	a0,0x4
ffffffffc0201012:	d4a50513          	addi	a0,a0,-694 # ffffffffc0204d58 <commands+0x918>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201016:	00010717          	auipc	a4,0x10
ffffffffc020101a:	46f73923          	sd	a5,1138(a4) # ffffffffc0211488 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020101e:	8a0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201022:	00004517          	auipc	a0,0x4
ffffffffc0201026:	d6650513          	addi	a0,a0,-666 # ffffffffc0204d88 <commands+0x948>
ffffffffc020102a:	894ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020102e:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201032:	16fd                	addi	a3,a3,-1
ffffffffc0201034:	015a1613          	slli	a2,s4,0x15
ffffffffc0201038:	07e005b7          	lui	a1,0x7e00
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	d6450513          	addi	a0,a0,-668 # ffffffffc0204da0 <commands+0x960>
ffffffffc0201044:	87aff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201048:	777d                	lui	a4,0xfffff
ffffffffc020104a:	00011797          	auipc	a5,0x11
ffffffffc020104e:	55578793          	addi	a5,a5,1365 # ffffffffc021259f <end+0xfff>
ffffffffc0201052:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201054:	00088737          	lui	a4,0x88
ffffffffc0201058:	00010697          	auipc	a3,0x10
ffffffffc020105c:	40e6b023          	sd	a4,1024(a3) # ffffffffc0211458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201060:	00010717          	auipc	a4,0x10
ffffffffc0201064:	42f73c23          	sd	a5,1080(a4) # ffffffffc0211498 <pages>
ffffffffc0201068:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020106a:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020106c:	4585                	li	a1,1
ffffffffc020106e:	fff80637          	lui	a2,0xfff80
ffffffffc0201072:	a019                	j	ffffffffc0201078 <pmm_init+0xd4>
ffffffffc0201074:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201078:	97b6                	add	a5,a5,a3
ffffffffc020107a:	07a1                	addi	a5,a5,8
ffffffffc020107c:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201080:	609c                	ld	a5,0(s1)
ffffffffc0201082:	0705                	addi	a4,a4,1
ffffffffc0201084:	04868693          	addi	a3,a3,72
ffffffffc0201088:	00c78533          	add	a0,a5,a2
ffffffffc020108c:	fea764e3          	bltu	a4,a0,ffffffffc0201074 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201090:	00093503          	ld	a0,0(s2)
ffffffffc0201094:	00379693          	slli	a3,a5,0x3
ffffffffc0201098:	96be                	add	a3,a3,a5
ffffffffc020109a:	fdc00737          	lui	a4,0xfdc00
ffffffffc020109e:	972a                	add	a4,a4,a0
ffffffffc02010a0:	068e                	slli	a3,a3,0x3
ffffffffc02010a2:	96ba                	add	a3,a3,a4
ffffffffc02010a4:	c0200737          	lui	a4,0xc0200
ffffffffc02010a8:	58e6ea63          	bltu	a3,a4,ffffffffc020163c <pmm_init+0x698>
ffffffffc02010ac:	00010997          	auipc	s3,0x10
ffffffffc02010b0:	3dc98993          	addi	s3,s3,988 # ffffffffc0211488 <va_pa_offset>
ffffffffc02010b4:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc02010b8:	45c5                	li	a1,17
ffffffffc02010ba:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010bc:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02010be:	44b6ef63          	bltu	a3,a1,ffffffffc020151c <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02010c2:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010c4:	00010417          	auipc	s0,0x10
ffffffffc02010c8:	38c40413          	addi	s0,s0,908 # ffffffffc0211450 <boot_pgdir>
    pmm_manager->check();
ffffffffc02010cc:	7b9c                	ld	a5,48(a5)
ffffffffc02010ce:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02010d0:	00004517          	auipc	a0,0x4
ffffffffc02010d4:	d2050513          	addi	a0,a0,-736 # ffffffffc0204df0 <commands+0x9b0>
ffffffffc02010d8:	fe7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010dc:	00008697          	auipc	a3,0x8
ffffffffc02010e0:	f2468693          	addi	a3,a3,-220 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02010e4:	00010797          	auipc	a5,0x10
ffffffffc02010e8:	36d7b623          	sd	a3,876(a5) # ffffffffc0211450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02010ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02010f0:	0ef6ece3          	bltu	a3,a5,ffffffffc02019e8 <pmm_init+0xa44>
ffffffffc02010f4:	0009b783          	ld	a5,0(s3)
ffffffffc02010f8:	8e9d                	sub	a3,a3,a5
ffffffffc02010fa:	00010797          	auipc	a5,0x10
ffffffffc02010fe:	38d7bb23          	sd	a3,918(a5) # ffffffffc0211490 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201102:	ab9ff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201106:	6098                	ld	a4,0(s1)
ffffffffc0201108:	c80007b7          	lui	a5,0xc8000
ffffffffc020110c:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020110e:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201110:	0ae7ece3          	bltu	a5,a4,ffffffffc02019c8 <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201114:	6008                	ld	a0,0(s0)
ffffffffc0201116:	4c050363          	beqz	a0,ffffffffc02015dc <pmm_init+0x638>
ffffffffc020111a:	6785                	lui	a5,0x1
ffffffffc020111c:	17fd                	addi	a5,a5,-1
ffffffffc020111e:	8fe9                	and	a5,a5,a0
ffffffffc0201120:	2781                	sext.w	a5,a5
ffffffffc0201122:	4a079d63          	bnez	a5,ffffffffc02015dc <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201126:	4601                	li	a2,0
ffffffffc0201128:	4581                	li	a1,0
ffffffffc020112a:	ccfff0ef          	jal	ra,ffffffffc0200df8 <get_page>
ffffffffc020112e:	4c051763          	bnez	a0,ffffffffc02015fc <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201132:	4505                	li	a0,1
ffffffffc0201134:	9b9ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0201138:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020113a:	6008                	ld	a0,0(s0)
ffffffffc020113c:	4681                	li	a3,0
ffffffffc020113e:	4601                	li	a2,0
ffffffffc0201140:	85d6                	mv	a1,s5
ffffffffc0201142:	d91ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc0201146:	52051763          	bnez	a0,ffffffffc0201674 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020114a:	6008                	ld	a0,0(s0)
ffffffffc020114c:	4601                	li	a2,0
ffffffffc020114e:	4581                	li	a1,0
ffffffffc0201150:	aabff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc0201154:	50050063          	beqz	a0,ffffffffc0201654 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201158:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020115a:	0017f713          	andi	a4,a5,1
ffffffffc020115e:	46070363          	beqz	a4,ffffffffc02015c4 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201162:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201164:	078a                	slli	a5,a5,0x2
ffffffffc0201166:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201168:	44c7f063          	bleu	a2,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020116c:	fff80737          	lui	a4,0xfff80
ffffffffc0201170:	97ba                	add	a5,a5,a4
ffffffffc0201172:	00379713          	slli	a4,a5,0x3
ffffffffc0201176:	00093683          	ld	a3,0(s2)
ffffffffc020117a:	97ba                	add	a5,a5,a4
ffffffffc020117c:	078e                	slli	a5,a5,0x3
ffffffffc020117e:	97b6                	add	a5,a5,a3
ffffffffc0201180:	5efa9463          	bne	s5,a5,ffffffffc0201768 <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201184:	000aab83          	lw	s7,0(s5)
ffffffffc0201188:	4785                	li	a5,1
ffffffffc020118a:	5afb9f63          	bne	s7,a5,ffffffffc0201748 <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020118e:	6008                	ld	a0,0(s0)
ffffffffc0201190:	76fd                	lui	a3,0xfffff
ffffffffc0201192:	611c                	ld	a5,0(a0)
ffffffffc0201194:	078a                	slli	a5,a5,0x2
ffffffffc0201196:	8ff5                	and	a5,a5,a3
ffffffffc0201198:	00c7d713          	srli	a4,a5,0xc
ffffffffc020119c:	58c77963          	bleu	a2,a4,ffffffffc020172e <pmm_init+0x78a>
ffffffffc02011a0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011a4:	97e2                	add	a5,a5,s8
ffffffffc02011a6:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02011aa:	0b0a                	slli	s6,s6,0x2
ffffffffc02011ac:	00db7b33          	and	s6,s6,a3
ffffffffc02011b0:	00cb5793          	srli	a5,s6,0xc
ffffffffc02011b4:	56c7f063          	bleu	a2,a5,ffffffffc0201714 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011b8:	4601                	li	a2,0
ffffffffc02011ba:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011bc:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011be:	a3dff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011c2:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011c4:	53651863          	bne	a0,s6,ffffffffc02016f4 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc02011c8:	4505                	li	a0,1
ffffffffc02011ca:	923ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02011ce:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02011d0:	6008                	ld	a0,0(s0)
ffffffffc02011d2:	46d1                	li	a3,20
ffffffffc02011d4:	6605                	lui	a2,0x1
ffffffffc02011d6:	85da                	mv	a1,s6
ffffffffc02011d8:	cfbff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc02011dc:	4e051c63          	bnez	a0,ffffffffc02016d4 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02011e0:	6008                	ld	a0,0(s0)
ffffffffc02011e2:	4601                	li	a2,0
ffffffffc02011e4:	6585                	lui	a1,0x1
ffffffffc02011e6:	a15ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc02011ea:	4c050563          	beqz	a0,ffffffffc02016b4 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc02011ee:	611c                	ld	a5,0(a0)
ffffffffc02011f0:	0107f713          	andi	a4,a5,16
ffffffffc02011f4:	4a070063          	beqz	a4,ffffffffc0201694 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc02011f8:	8b91                	andi	a5,a5,4
ffffffffc02011fa:	66078763          	beqz	a5,ffffffffc0201868 <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02011fe:	6008                	ld	a0,0(s0)
ffffffffc0201200:	611c                	ld	a5,0(a0)
ffffffffc0201202:	8bc1                	andi	a5,a5,16
ffffffffc0201204:	64078263          	beqz	a5,ffffffffc0201848 <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201208:	000b2783          	lw	a5,0(s6)
ffffffffc020120c:	61779e63          	bne	a5,s7,ffffffffc0201828 <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201210:	4681                	li	a3,0
ffffffffc0201212:	6605                	lui	a2,0x1
ffffffffc0201214:	85d6                	mv	a1,s5
ffffffffc0201216:	cbdff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc020121a:	5e051763          	bnez	a0,ffffffffc0201808 <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc020121e:	000aa703          	lw	a4,0(s5)
ffffffffc0201222:	4789                	li	a5,2
ffffffffc0201224:	5cf71263          	bne	a4,a5,ffffffffc02017e8 <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201228:	000b2783          	lw	a5,0(s6)
ffffffffc020122c:	58079e63          	bnez	a5,ffffffffc02017c8 <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201230:	6008                	ld	a0,0(s0)
ffffffffc0201232:	4601                	li	a2,0
ffffffffc0201234:	6585                	lui	a1,0x1
ffffffffc0201236:	9c5ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc020123a:	56050763          	beqz	a0,ffffffffc02017a8 <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc020123e:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201240:	0016f793          	andi	a5,a3,1
ffffffffc0201244:	38078063          	beqz	a5,ffffffffc02015c4 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201248:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020124a:	00269793          	slli	a5,a3,0x2
ffffffffc020124e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201250:	34e7fc63          	bleu	a4,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201254:	fff80737          	lui	a4,0xfff80
ffffffffc0201258:	97ba                	add	a5,a5,a4
ffffffffc020125a:	00379713          	slli	a4,a5,0x3
ffffffffc020125e:	00093603          	ld	a2,0(s2)
ffffffffc0201262:	97ba                	add	a5,a5,a4
ffffffffc0201264:	078e                	slli	a5,a5,0x3
ffffffffc0201266:	97b2                	add	a5,a5,a2
ffffffffc0201268:	52fa9063          	bne	s5,a5,ffffffffc0201788 <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc020126c:	8ac1                	andi	a3,a3,16
ffffffffc020126e:	6e069d63          	bnez	a3,ffffffffc0201968 <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201272:	6008                	ld	a0,0(s0)
ffffffffc0201274:	4581                	li	a1,0
ffffffffc0201276:	bebff0ef          	jal	ra,ffffffffc0200e60 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020127a:	000aa703          	lw	a4,0(s5)
ffffffffc020127e:	4785                	li	a5,1
ffffffffc0201280:	6cf71463          	bne	a4,a5,ffffffffc0201948 <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201284:	000b2783          	lw	a5,0(s6)
ffffffffc0201288:	6a079063          	bnez	a5,ffffffffc0201928 <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020128c:	6008                	ld	a0,0(s0)
ffffffffc020128e:	6585                	lui	a1,0x1
ffffffffc0201290:	bd1ff0ef          	jal	ra,ffffffffc0200e60 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201294:	000aa783          	lw	a5,0(s5)
ffffffffc0201298:	66079863          	bnez	a5,ffffffffc0201908 <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc020129c:	000b2783          	lw	a5,0(s6)
ffffffffc02012a0:	70079463          	bnez	a5,ffffffffc02019a8 <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02012a4:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02012a8:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02012aa:	000b3783          	ld	a5,0(s6)
ffffffffc02012ae:	078a                	slli	a5,a5,0x2
ffffffffc02012b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012b2:	2eb7fb63          	bleu	a1,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02012b6:	fff80737          	lui	a4,0xfff80
ffffffffc02012ba:	973e                	add	a4,a4,a5
ffffffffc02012bc:	00371793          	slli	a5,a4,0x3
ffffffffc02012c0:	00093603          	ld	a2,0(s2)
ffffffffc02012c4:	97ba                	add	a5,a5,a4
ffffffffc02012c6:	078e                	slli	a5,a5,0x3
ffffffffc02012c8:	00f60733          	add	a4,a2,a5
ffffffffc02012cc:	4314                	lw	a3,0(a4)
ffffffffc02012ce:	4705                	li	a4,1
ffffffffc02012d0:	6ae69c63          	bne	a3,a4,ffffffffc0201988 <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012d4:	00004a97          	auipc	s5,0x4
ffffffffc02012d8:	9a4a8a93          	addi	s5,s5,-1628 # ffffffffc0204c78 <commands+0x838>
ffffffffc02012dc:	000ab703          	ld	a4,0(s5)
ffffffffc02012e0:	4037d693          	srai	a3,a5,0x3
ffffffffc02012e4:	00080bb7          	lui	s7,0x80
ffffffffc02012e8:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012ec:	577d                	li	a4,-1
ffffffffc02012ee:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012f0:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012f2:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02012f4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012f6:	2ab77b63          	bleu	a1,a4,ffffffffc02015ac <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02012fa:	0009b783          	ld	a5,0(s3)
ffffffffc02012fe:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201300:	629c                	ld	a5,0(a3)
ffffffffc0201302:	078a                	slli	a5,a5,0x2
ffffffffc0201304:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201306:	2ab7f163          	bleu	a1,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020130a:	417787b3          	sub	a5,a5,s7
ffffffffc020130e:	00379513          	slli	a0,a5,0x3
ffffffffc0201312:	97aa                	add	a5,a5,a0
ffffffffc0201314:	00379513          	slli	a0,a5,0x3
ffffffffc0201318:	9532                	add	a0,a0,a2
ffffffffc020131a:	4585                	li	a1,1
ffffffffc020131c:	859ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201320:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201324:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201326:	050a                	slli	a0,a0,0x2
ffffffffc0201328:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020132a:	26f57f63          	bleu	a5,a0,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020132e:	417507b3          	sub	a5,a0,s7
ffffffffc0201332:	00379513          	slli	a0,a5,0x3
ffffffffc0201336:	00093703          	ld	a4,0(s2)
ffffffffc020133a:	953e                	add	a0,a0,a5
ffffffffc020133c:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020133e:	4585                	li	a1,1
ffffffffc0201340:	953a                	add	a0,a0,a4
ffffffffc0201342:	833ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201346:	601c                	ld	a5,0(s0)
ffffffffc0201348:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc020134c:	86fff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0201350:	2caa1663          	bne	s4,a0,ffffffffc020161c <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201354:	00004517          	auipc	a0,0x4
ffffffffc0201358:	dc450513          	addi	a0,a0,-572 # ffffffffc0205118 <commands+0xcd8>
ffffffffc020135c:	d63fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201360:	85bff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201364:	6098                	ld	a4,0(s1)
ffffffffc0201366:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc020136a:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020136c:	00c71693          	slli	a3,a4,0xc
ffffffffc0201370:	1cd7fd63          	bleu	a3,a5,ffffffffc020154a <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201374:	83b1                	srli	a5,a5,0xc
ffffffffc0201376:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201378:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020137c:	1ce7f963          	bleu	a4,a5,ffffffffc020154e <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201380:	7c7d                	lui	s8,0xfffff
ffffffffc0201382:	6b85                	lui	s7,0x1
ffffffffc0201384:	a029                	j	ffffffffc020138e <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201386:	00ca5713          	srli	a4,s4,0xc
ffffffffc020138a:	1cf77263          	bleu	a5,a4,ffffffffc020154e <pmm_init+0x5aa>
ffffffffc020138e:	0009b583          	ld	a1,0(s3)
ffffffffc0201392:	4601                	li	a2,0
ffffffffc0201394:	95d2                	add	a1,a1,s4
ffffffffc0201396:	865ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc020139a:	1c050763          	beqz	a0,ffffffffc0201568 <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020139e:	611c                	ld	a5,0(a0)
ffffffffc02013a0:	078a                	slli	a5,a5,0x2
ffffffffc02013a2:	0187f7b3          	and	a5,a5,s8
ffffffffc02013a6:	1f479163          	bne	a5,s4,ffffffffc0201588 <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013aa:	609c                	ld	a5,0(s1)
ffffffffc02013ac:	9a5e                	add	s4,s4,s7
ffffffffc02013ae:	6008                	ld	a0,0(s0)
ffffffffc02013b0:	00c79713          	slli	a4,a5,0xc
ffffffffc02013b4:	fcea69e3          	bltu	s4,a4,ffffffffc0201386 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02013b8:	611c                	ld	a5,0(a0)
ffffffffc02013ba:	6a079363          	bnez	a5,ffffffffc0201a60 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc02013be:	4505                	li	a0,1
ffffffffc02013c0:	f2cff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02013c4:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02013c6:	6008                	ld	a0,0(s0)
ffffffffc02013c8:	4699                	li	a3,6
ffffffffc02013ca:	10000613          	li	a2,256
ffffffffc02013ce:	85d2                	mv	a1,s4
ffffffffc02013d0:	b03ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc02013d4:	66051663          	bnez	a0,ffffffffc0201a40 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc02013d8:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc02013dc:	4785                	li	a5,1
ffffffffc02013de:	64f71163          	bne	a4,a5,ffffffffc0201a20 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02013e2:	6008                	ld	a0,0(s0)
ffffffffc02013e4:	6b85                	lui	s7,0x1
ffffffffc02013e6:	4699                	li	a3,6
ffffffffc02013e8:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc02013ec:	85d2                	mv	a1,s4
ffffffffc02013ee:	ae5ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc02013f2:	60051763          	bnez	a0,ffffffffc0201a00 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc02013f6:	000a2703          	lw	a4,0(s4)
ffffffffc02013fa:	4789                	li	a5,2
ffffffffc02013fc:	4ef71663          	bne	a4,a5,ffffffffc02018e8 <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201400:	00004597          	auipc	a1,0x4
ffffffffc0201404:	e5058593          	addi	a1,a1,-432 # ffffffffc0205250 <commands+0xe10>
ffffffffc0201408:	10000513          	li	a0,256
ffffffffc020140c:	1b3020ef          	jal	ra,ffffffffc0203dbe <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201410:	100b8593          	addi	a1,s7,256
ffffffffc0201414:	10000513          	li	a0,256
ffffffffc0201418:	1b9020ef          	jal	ra,ffffffffc0203dd0 <strcmp>
ffffffffc020141c:	4a051663          	bnez	a0,ffffffffc02018c8 <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201420:	00093683          	ld	a3,0(s2)
ffffffffc0201424:	000abc83          	ld	s9,0(s5)
ffffffffc0201428:	00080c37          	lui	s8,0x80
ffffffffc020142c:	40da06b3          	sub	a3,s4,a3
ffffffffc0201430:	868d                	srai	a3,a3,0x3
ffffffffc0201432:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201436:	5afd                	li	s5,-1
ffffffffc0201438:	609c                	ld	a5,0(s1)
ffffffffc020143a:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020143e:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201440:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201444:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201446:	16f77363          	bleu	a5,a4,ffffffffc02015ac <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020144a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020144e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201452:	96be                	add	a3,a3,a5
ffffffffc0201454:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201458:	123020ef          	jal	ra,ffffffffc0203d7a <strlen>
ffffffffc020145c:	44051663          	bnez	a0,ffffffffc02018a8 <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201460:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201464:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201466:	000bb783          	ld	a5,0(s7)
ffffffffc020146a:	078a                	slli	a5,a5,0x2
ffffffffc020146c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020146e:	12e7fd63          	bleu	a4,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201472:	418787b3          	sub	a5,a5,s8
ffffffffc0201476:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020147a:	96be                	add	a3,a3,a5
ffffffffc020147c:	039686b3          	mul	a3,a3,s9
ffffffffc0201480:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201482:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201486:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201488:	12eaf263          	bleu	a4,s5,ffffffffc02015ac <pmm_init+0x608>
ffffffffc020148c:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201490:	4585                	li	a1,1
ffffffffc0201492:	8552                	mv	a0,s4
ffffffffc0201494:	99b6                	add	s3,s3,a3
ffffffffc0201496:	edeff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020149a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020149e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a0:	078a                	slli	a5,a5,0x2
ffffffffc02014a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014a4:	10e7f263          	bleu	a4,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02014a8:	fff809b7          	lui	s3,0xfff80
ffffffffc02014ac:	97ce                	add	a5,a5,s3
ffffffffc02014ae:	00379513          	slli	a0,a5,0x3
ffffffffc02014b2:	00093703          	ld	a4,0(s2)
ffffffffc02014b6:	97aa                	add	a5,a5,a0
ffffffffc02014b8:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc02014bc:	953a                	add	a0,a0,a4
ffffffffc02014be:	4585                	li	a1,1
ffffffffc02014c0:	eb4ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014c4:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02014c8:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ca:	050a                	slli	a0,a0,0x2
ffffffffc02014cc:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014ce:	0cf57d63          	bleu	a5,a0,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02014d2:	013507b3          	add	a5,a0,s3
ffffffffc02014d6:	00379513          	slli	a0,a5,0x3
ffffffffc02014da:	00093703          	ld	a4,0(s2)
ffffffffc02014de:	953e                	add	a0,a0,a5
ffffffffc02014e0:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02014e2:	4585                	li	a1,1
ffffffffc02014e4:	953a                	add	a0,a0,a4
ffffffffc02014e6:	e8eff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02014ea:	601c                	ld	a5,0(s0)
ffffffffc02014ec:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02014f0:	ecaff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc02014f4:	38ab1a63          	bne	s6,a0,ffffffffc0201888 <pmm_init+0x8e4>
}
ffffffffc02014f8:	6446                	ld	s0,80(sp)
ffffffffc02014fa:	60e6                	ld	ra,88(sp)
ffffffffc02014fc:	64a6                	ld	s1,72(sp)
ffffffffc02014fe:	6906                	ld	s2,64(sp)
ffffffffc0201500:	79e2                	ld	s3,56(sp)
ffffffffc0201502:	7a42                	ld	s4,48(sp)
ffffffffc0201504:	7aa2                	ld	s5,40(sp)
ffffffffc0201506:	7b02                	ld	s6,32(sp)
ffffffffc0201508:	6be2                	ld	s7,24(sp)
ffffffffc020150a:	6c42                	ld	s8,16(sp)
ffffffffc020150c:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020150e:	00004517          	auipc	a0,0x4
ffffffffc0201512:	dba50513          	addi	a0,a0,-582 # ffffffffc02052c8 <commands+0xe88>
}
ffffffffc0201516:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201518:	ba7fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020151c:	6705                	lui	a4,0x1
ffffffffc020151e:	177d                	addi	a4,a4,-1
ffffffffc0201520:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0201522:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201526:	08f77163          	bleu	a5,a4,ffffffffc02015a8 <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc020152a:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc020152e:	9732                	add	a4,a4,a2
ffffffffc0201530:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201534:	767d                	lui	a2,0xfffff
ffffffffc0201536:	8ef1                	and	a3,a3,a2
ffffffffc0201538:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020153a:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020153e:	8d95                	sub	a1,a1,a3
ffffffffc0201540:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201542:	81b1                	srli	a1,a1,0xc
ffffffffc0201544:	953e                	add	a0,a0,a5
ffffffffc0201546:	9702                	jalr	a4
ffffffffc0201548:	bead                	j	ffffffffc02010c2 <pmm_init+0x11e>
ffffffffc020154a:	6008                	ld	a0,0(s0)
ffffffffc020154c:	b5b5                	j	ffffffffc02013b8 <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020154e:	86d2                	mv	a3,s4
ffffffffc0201550:	00003617          	auipc	a2,0x3
ffffffffc0201554:	73060613          	addi	a2,a2,1840 # ffffffffc0204c80 <commands+0x840>
ffffffffc0201558:	1cd00593          	li	a1,461
ffffffffc020155c:	00003517          	auipc	a0,0x3
ffffffffc0201560:	74c50513          	addi	a0,a0,1868 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201564:	ba3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201568:	00004697          	auipc	a3,0x4
ffffffffc020156c:	bd068693          	addi	a3,a3,-1072 # ffffffffc0205138 <commands+0xcf8>
ffffffffc0201570:	00004617          	auipc	a2,0x4
ffffffffc0201574:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201578:	1cd00593          	li	a1,461
ffffffffc020157c:	00003517          	auipc	a0,0x3
ffffffffc0201580:	72c50513          	addi	a0,a0,1836 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201584:	b83fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201588:	00004697          	auipc	a3,0x4
ffffffffc020158c:	bf068693          	addi	a3,a3,-1040 # ffffffffc0205178 <commands+0xd38>
ffffffffc0201590:	00004617          	auipc	a2,0x4
ffffffffc0201594:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201598:	1ce00593          	li	a1,462
ffffffffc020159c:	00003517          	auipc	a0,0x3
ffffffffc02015a0:	70c50513          	addi	a0,a0,1804 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02015a4:	b63fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02015a8:	d28ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02015ac:	00003617          	auipc	a2,0x3
ffffffffc02015b0:	6d460613          	addi	a2,a2,1748 # ffffffffc0204c80 <commands+0x840>
ffffffffc02015b4:	06a00593          	li	a1,106
ffffffffc02015b8:	00003517          	auipc	a0,0x3
ffffffffc02015bc:	76050513          	addi	a0,a0,1888 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc02015c0:	b47fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02015c4:	00004617          	auipc	a2,0x4
ffffffffc02015c8:	94460613          	addi	a2,a2,-1724 # ffffffffc0204f08 <commands+0xac8>
ffffffffc02015cc:	07000593          	li	a1,112
ffffffffc02015d0:	00003517          	auipc	a0,0x3
ffffffffc02015d4:	74850513          	addi	a0,a0,1864 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc02015d8:	b2ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02015dc:	00004697          	auipc	a3,0x4
ffffffffc02015e0:	86c68693          	addi	a3,a3,-1940 # ffffffffc0204e48 <commands+0xa08>
ffffffffc02015e4:	00004617          	auipc	a2,0x4
ffffffffc02015e8:	84c60613          	addi	a2,a2,-1972 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02015ec:	19300593          	li	a1,403
ffffffffc02015f0:	00003517          	auipc	a0,0x3
ffffffffc02015f4:	6b850513          	addi	a0,a0,1720 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02015f8:	b0ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02015fc:	00004697          	auipc	a3,0x4
ffffffffc0201600:	88468693          	addi	a3,a3,-1916 # ffffffffc0204e80 <commands+0xa40>
ffffffffc0201604:	00004617          	auipc	a2,0x4
ffffffffc0201608:	82c60613          	addi	a2,a2,-2004 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020160c:	19400593          	li	a1,404
ffffffffc0201610:	00003517          	auipc	a0,0x3
ffffffffc0201614:	69850513          	addi	a0,a0,1688 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201618:	aeffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020161c:	00004697          	auipc	a3,0x4
ffffffffc0201620:	adc68693          	addi	a3,a3,-1316 # ffffffffc02050f8 <commands+0xcb8>
ffffffffc0201624:	00004617          	auipc	a2,0x4
ffffffffc0201628:	80c60613          	addi	a2,a2,-2036 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020162c:	1c000593          	li	a1,448
ffffffffc0201630:	00003517          	auipc	a0,0x3
ffffffffc0201634:	67850513          	addi	a0,a0,1656 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201638:	acffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020163c:	00003617          	auipc	a2,0x3
ffffffffc0201640:	78c60613          	addi	a2,a2,1932 # ffffffffc0204dc8 <commands+0x988>
ffffffffc0201644:	07700593          	li	a1,119
ffffffffc0201648:	00003517          	auipc	a0,0x3
ffffffffc020164c:	66050513          	addi	a0,a0,1632 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201650:	ab7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201654:	00004697          	auipc	a3,0x4
ffffffffc0201658:	88468693          	addi	a3,a3,-1916 # ffffffffc0204ed8 <commands+0xa98>
ffffffffc020165c:	00003617          	auipc	a2,0x3
ffffffffc0201660:	7d460613          	addi	a2,a2,2004 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201664:	19a00593          	li	a1,410
ffffffffc0201668:	00003517          	auipc	a0,0x3
ffffffffc020166c:	64050513          	addi	a0,a0,1600 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201670:	a97fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201674:	00004697          	auipc	a3,0x4
ffffffffc0201678:	83468693          	addi	a3,a3,-1996 # ffffffffc0204ea8 <commands+0xa68>
ffffffffc020167c:	00003617          	auipc	a2,0x3
ffffffffc0201680:	7b460613          	addi	a2,a2,1972 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201684:	19800593          	li	a1,408
ffffffffc0201688:	00003517          	auipc	a0,0x3
ffffffffc020168c:	62050513          	addi	a0,a0,1568 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201690:	a77fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201694:	00004697          	auipc	a3,0x4
ffffffffc0201698:	95c68693          	addi	a3,a3,-1700 # ffffffffc0204ff0 <commands+0xbb0>
ffffffffc020169c:	00003617          	auipc	a2,0x3
ffffffffc02016a0:	79460613          	addi	a2,a2,1940 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02016a4:	1a500593          	li	a1,421
ffffffffc02016a8:	00003517          	auipc	a0,0x3
ffffffffc02016ac:	60050513          	addi	a0,a0,1536 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02016b0:	a57fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02016b4:	00004697          	auipc	a3,0x4
ffffffffc02016b8:	90c68693          	addi	a3,a3,-1780 # ffffffffc0204fc0 <commands+0xb80>
ffffffffc02016bc:	00003617          	auipc	a2,0x3
ffffffffc02016c0:	77460613          	addi	a2,a2,1908 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02016c4:	1a400593          	li	a1,420
ffffffffc02016c8:	00003517          	auipc	a0,0x3
ffffffffc02016cc:	5e050513          	addi	a0,a0,1504 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02016d0:	a37fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02016d4:	00004697          	auipc	a3,0x4
ffffffffc02016d8:	8b468693          	addi	a3,a3,-1868 # ffffffffc0204f88 <commands+0xb48>
ffffffffc02016dc:	00003617          	auipc	a2,0x3
ffffffffc02016e0:	75460613          	addi	a2,a2,1876 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02016e4:	1a300593          	li	a1,419
ffffffffc02016e8:	00003517          	auipc	a0,0x3
ffffffffc02016ec:	5c050513          	addi	a0,a0,1472 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02016f0:	a17fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02016f4:	00004697          	auipc	a3,0x4
ffffffffc02016f8:	86c68693          	addi	a3,a3,-1940 # ffffffffc0204f60 <commands+0xb20>
ffffffffc02016fc:	00003617          	auipc	a2,0x3
ffffffffc0201700:	73460613          	addi	a2,a2,1844 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201704:	1a000593          	li	a1,416
ffffffffc0201708:	00003517          	auipc	a0,0x3
ffffffffc020170c:	5a050513          	addi	a0,a0,1440 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201710:	9f7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201714:	86da                	mv	a3,s6
ffffffffc0201716:	00003617          	auipc	a2,0x3
ffffffffc020171a:	56a60613          	addi	a2,a2,1386 # ffffffffc0204c80 <commands+0x840>
ffffffffc020171e:	19f00593          	li	a1,415
ffffffffc0201722:	00003517          	auipc	a0,0x3
ffffffffc0201726:	58650513          	addi	a0,a0,1414 # ffffffffc0204ca8 <commands+0x868>
ffffffffc020172a:	9ddfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020172e:	86be                	mv	a3,a5
ffffffffc0201730:	00003617          	auipc	a2,0x3
ffffffffc0201734:	55060613          	addi	a2,a2,1360 # ffffffffc0204c80 <commands+0x840>
ffffffffc0201738:	19e00593          	li	a1,414
ffffffffc020173c:	00003517          	auipc	a0,0x3
ffffffffc0201740:	56c50513          	addi	a0,a0,1388 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201744:	9c3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201748:	00004697          	auipc	a3,0x4
ffffffffc020174c:	80068693          	addi	a3,a3,-2048 # ffffffffc0204f48 <commands+0xb08>
ffffffffc0201750:	00003617          	auipc	a2,0x3
ffffffffc0201754:	6e060613          	addi	a2,a2,1760 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201758:	19c00593          	li	a1,412
ffffffffc020175c:	00003517          	auipc	a0,0x3
ffffffffc0201760:	54c50513          	addi	a0,a0,1356 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201764:	9a3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201768:	00003697          	auipc	a3,0x3
ffffffffc020176c:	7c868693          	addi	a3,a3,1992 # ffffffffc0204f30 <commands+0xaf0>
ffffffffc0201770:	00003617          	auipc	a2,0x3
ffffffffc0201774:	6c060613          	addi	a2,a2,1728 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201778:	19b00593          	li	a1,411
ffffffffc020177c:	00003517          	auipc	a0,0x3
ffffffffc0201780:	52c50513          	addi	a0,a0,1324 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201784:	983fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201788:	00003697          	auipc	a3,0x3
ffffffffc020178c:	7a868693          	addi	a3,a3,1960 # ffffffffc0204f30 <commands+0xaf0>
ffffffffc0201790:	00003617          	auipc	a2,0x3
ffffffffc0201794:	6a060613          	addi	a2,a2,1696 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201798:	1ae00593          	li	a1,430
ffffffffc020179c:	00003517          	auipc	a0,0x3
ffffffffc02017a0:	50c50513          	addi	a0,a0,1292 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02017a4:	963fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02017a8:	00004697          	auipc	a3,0x4
ffffffffc02017ac:	81868693          	addi	a3,a3,-2024 # ffffffffc0204fc0 <commands+0xb80>
ffffffffc02017b0:	00003617          	auipc	a2,0x3
ffffffffc02017b4:	68060613          	addi	a2,a2,1664 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02017b8:	1ad00593          	li	a1,429
ffffffffc02017bc:	00003517          	auipc	a0,0x3
ffffffffc02017c0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02017c4:	943fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02017c8:	00004697          	auipc	a3,0x4
ffffffffc02017cc:	8c068693          	addi	a3,a3,-1856 # ffffffffc0205088 <commands+0xc48>
ffffffffc02017d0:	00003617          	auipc	a2,0x3
ffffffffc02017d4:	66060613          	addi	a2,a2,1632 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02017d8:	1ac00593          	li	a1,428
ffffffffc02017dc:	00003517          	auipc	a0,0x3
ffffffffc02017e0:	4cc50513          	addi	a0,a0,1228 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02017e4:	923fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02017e8:	00004697          	auipc	a3,0x4
ffffffffc02017ec:	88868693          	addi	a3,a3,-1912 # ffffffffc0205070 <commands+0xc30>
ffffffffc02017f0:	00003617          	auipc	a2,0x3
ffffffffc02017f4:	64060613          	addi	a2,a2,1600 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02017f8:	1ab00593          	li	a1,427
ffffffffc02017fc:	00003517          	auipc	a0,0x3
ffffffffc0201800:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201804:	903fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201808:	00004697          	auipc	a3,0x4
ffffffffc020180c:	83868693          	addi	a3,a3,-1992 # ffffffffc0205040 <commands+0xc00>
ffffffffc0201810:	00003617          	auipc	a2,0x3
ffffffffc0201814:	62060613          	addi	a2,a2,1568 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201818:	1aa00593          	li	a1,426
ffffffffc020181c:	00003517          	auipc	a0,0x3
ffffffffc0201820:	48c50513          	addi	a0,a0,1164 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201824:	8e3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201828:	00004697          	auipc	a3,0x4
ffffffffc020182c:	80068693          	addi	a3,a3,-2048 # ffffffffc0205028 <commands+0xbe8>
ffffffffc0201830:	00003617          	auipc	a2,0x3
ffffffffc0201834:	60060613          	addi	a2,a2,1536 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201838:	1a800593          	li	a1,424
ffffffffc020183c:	00003517          	auipc	a0,0x3
ffffffffc0201840:	46c50513          	addi	a0,a0,1132 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201844:	8c3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201848:	00003697          	auipc	a3,0x3
ffffffffc020184c:	7c868693          	addi	a3,a3,1992 # ffffffffc0205010 <commands+0xbd0>
ffffffffc0201850:	00003617          	auipc	a2,0x3
ffffffffc0201854:	5e060613          	addi	a2,a2,1504 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201858:	1a700593          	li	a1,423
ffffffffc020185c:	00003517          	auipc	a0,0x3
ffffffffc0201860:	44c50513          	addi	a0,a0,1100 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201864:	8a3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201868:	00003697          	auipc	a3,0x3
ffffffffc020186c:	79868693          	addi	a3,a3,1944 # ffffffffc0205000 <commands+0xbc0>
ffffffffc0201870:	00003617          	auipc	a2,0x3
ffffffffc0201874:	5c060613          	addi	a2,a2,1472 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201878:	1a600593          	li	a1,422
ffffffffc020187c:	00003517          	auipc	a0,0x3
ffffffffc0201880:	42c50513          	addi	a0,a0,1068 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201884:	883fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201888:	00004697          	auipc	a3,0x4
ffffffffc020188c:	87068693          	addi	a3,a3,-1936 # ffffffffc02050f8 <commands+0xcb8>
ffffffffc0201890:	00003617          	auipc	a2,0x3
ffffffffc0201894:	5a060613          	addi	a2,a2,1440 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201898:	1e800593          	li	a1,488
ffffffffc020189c:	00003517          	auipc	a0,0x3
ffffffffc02018a0:	40c50513          	addi	a0,a0,1036 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02018a4:	863fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02018a8:	00004697          	auipc	a3,0x4
ffffffffc02018ac:	9f868693          	addi	a3,a3,-1544 # ffffffffc02052a0 <commands+0xe60>
ffffffffc02018b0:	00003617          	auipc	a2,0x3
ffffffffc02018b4:	58060613          	addi	a2,a2,1408 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02018b8:	1e000593          	li	a1,480
ffffffffc02018bc:	00003517          	auipc	a0,0x3
ffffffffc02018c0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02018c4:	843fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02018c8:	00004697          	auipc	a3,0x4
ffffffffc02018cc:	9a068693          	addi	a3,a3,-1632 # ffffffffc0205268 <commands+0xe28>
ffffffffc02018d0:	00003617          	auipc	a2,0x3
ffffffffc02018d4:	56060613          	addi	a2,a2,1376 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02018d8:	1dd00593          	li	a1,477
ffffffffc02018dc:	00003517          	auipc	a0,0x3
ffffffffc02018e0:	3cc50513          	addi	a0,a0,972 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02018e4:	823fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02018e8:	00004697          	auipc	a3,0x4
ffffffffc02018ec:	95068693          	addi	a3,a3,-1712 # ffffffffc0205238 <commands+0xdf8>
ffffffffc02018f0:	00003617          	auipc	a2,0x3
ffffffffc02018f4:	54060613          	addi	a2,a2,1344 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02018f8:	1d900593          	li	a1,473
ffffffffc02018fc:	00003517          	auipc	a0,0x3
ffffffffc0201900:	3ac50513          	addi	a0,a0,940 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201904:	803fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201908:	00003697          	auipc	a3,0x3
ffffffffc020190c:	7b068693          	addi	a3,a3,1968 # ffffffffc02050b8 <commands+0xc78>
ffffffffc0201910:	00003617          	auipc	a2,0x3
ffffffffc0201914:	52060613          	addi	a2,a2,1312 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201918:	1b600593          	li	a1,438
ffffffffc020191c:	00003517          	auipc	a0,0x3
ffffffffc0201920:	38c50513          	addi	a0,a0,908 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201924:	fe2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201928:	00003697          	auipc	a3,0x3
ffffffffc020192c:	76068693          	addi	a3,a3,1888 # ffffffffc0205088 <commands+0xc48>
ffffffffc0201930:	00003617          	auipc	a2,0x3
ffffffffc0201934:	50060613          	addi	a2,a2,1280 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201938:	1b300593          	li	a1,435
ffffffffc020193c:	00003517          	auipc	a0,0x3
ffffffffc0201940:	36c50513          	addi	a0,a0,876 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201944:	fc2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201948:	00003697          	auipc	a3,0x3
ffffffffc020194c:	60068693          	addi	a3,a3,1536 # ffffffffc0204f48 <commands+0xb08>
ffffffffc0201950:	00003617          	auipc	a2,0x3
ffffffffc0201954:	4e060613          	addi	a2,a2,1248 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201958:	1b200593          	li	a1,434
ffffffffc020195c:	00003517          	auipc	a0,0x3
ffffffffc0201960:	34c50513          	addi	a0,a0,844 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201964:	fa2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201968:	00003697          	auipc	a3,0x3
ffffffffc020196c:	73868693          	addi	a3,a3,1848 # ffffffffc02050a0 <commands+0xc60>
ffffffffc0201970:	00003617          	auipc	a2,0x3
ffffffffc0201974:	4c060613          	addi	a2,a2,1216 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201978:	1af00593          	li	a1,431
ffffffffc020197c:	00003517          	auipc	a0,0x3
ffffffffc0201980:	32c50513          	addi	a0,a0,812 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201984:	f82fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201988:	00003697          	auipc	a3,0x3
ffffffffc020198c:	74868693          	addi	a3,a3,1864 # ffffffffc02050d0 <commands+0xc90>
ffffffffc0201990:	00003617          	auipc	a2,0x3
ffffffffc0201994:	4a060613          	addi	a2,a2,1184 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201998:	1b900593          	li	a1,441
ffffffffc020199c:	00003517          	auipc	a0,0x3
ffffffffc02019a0:	30c50513          	addi	a0,a0,780 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02019a4:	f62fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02019a8:	00003697          	auipc	a3,0x3
ffffffffc02019ac:	6e068693          	addi	a3,a3,1760 # ffffffffc0205088 <commands+0xc48>
ffffffffc02019b0:	00003617          	auipc	a2,0x3
ffffffffc02019b4:	48060613          	addi	a2,a2,1152 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02019b8:	1b700593          	li	a1,439
ffffffffc02019bc:	00003517          	auipc	a0,0x3
ffffffffc02019c0:	2ec50513          	addi	a0,a0,748 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02019c4:	f42fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02019c8:	00003697          	auipc	a3,0x3
ffffffffc02019cc:	44868693          	addi	a3,a3,1096 # ffffffffc0204e10 <commands+0x9d0>
ffffffffc02019d0:	00003617          	auipc	a2,0x3
ffffffffc02019d4:	46060613          	addi	a2,a2,1120 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02019d8:	19200593          	li	a1,402
ffffffffc02019dc:	00003517          	auipc	a0,0x3
ffffffffc02019e0:	2cc50513          	addi	a0,a0,716 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02019e4:	f22fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02019e8:	00003617          	auipc	a2,0x3
ffffffffc02019ec:	3e060613          	addi	a2,a2,992 # ffffffffc0204dc8 <commands+0x988>
ffffffffc02019f0:	0bd00593          	li	a1,189
ffffffffc02019f4:	00003517          	auipc	a0,0x3
ffffffffc02019f8:	2b450513          	addi	a0,a0,692 # ffffffffc0204ca8 <commands+0x868>
ffffffffc02019fc:	f0afe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a00:	00003697          	auipc	a3,0x3
ffffffffc0201a04:	7f868693          	addi	a3,a3,2040 # ffffffffc02051f8 <commands+0xdb8>
ffffffffc0201a08:	00003617          	auipc	a2,0x3
ffffffffc0201a0c:	42860613          	addi	a2,a2,1064 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201a10:	1d800593          	li	a1,472
ffffffffc0201a14:	00003517          	auipc	a0,0x3
ffffffffc0201a18:	29450513          	addi	a0,a0,660 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201a1c:	eeafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201a20:	00003697          	auipc	a3,0x3
ffffffffc0201a24:	7c068693          	addi	a3,a3,1984 # ffffffffc02051e0 <commands+0xda0>
ffffffffc0201a28:	00003617          	auipc	a2,0x3
ffffffffc0201a2c:	40860613          	addi	a2,a2,1032 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201a30:	1d700593          	li	a1,471
ffffffffc0201a34:	00003517          	auipc	a0,0x3
ffffffffc0201a38:	27450513          	addi	a0,a0,628 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201a3c:	ecafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a40:	00003697          	auipc	a3,0x3
ffffffffc0201a44:	76868693          	addi	a3,a3,1896 # ffffffffc02051a8 <commands+0xd68>
ffffffffc0201a48:	00003617          	auipc	a2,0x3
ffffffffc0201a4c:	3e860613          	addi	a2,a2,1000 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201a50:	1d600593          	li	a1,470
ffffffffc0201a54:	00003517          	auipc	a0,0x3
ffffffffc0201a58:	25450513          	addi	a0,a0,596 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201a5c:	eaafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a60:	00003697          	auipc	a3,0x3
ffffffffc0201a64:	73068693          	addi	a3,a3,1840 # ffffffffc0205190 <commands+0xd50>
ffffffffc0201a68:	00003617          	auipc	a2,0x3
ffffffffc0201a6c:	3c860613          	addi	a2,a2,968 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201a70:	1d200593          	li	a1,466
ffffffffc0201a74:	00003517          	auipc	a0,0x3
ffffffffc0201a78:	23450513          	addi	a0,a0,564 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201a7c:	e8afe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201a80 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a80:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0201a84:	8082                	ret

ffffffffc0201a86 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a86:	7179                	addi	sp,sp,-48
ffffffffc0201a88:	e84a                	sd	s2,16(sp)
ffffffffc0201a8a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201a8c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a8e:	f022                	sd	s0,32(sp)
ffffffffc0201a90:	ec26                	sd	s1,24(sp)
ffffffffc0201a92:	e44e                	sd	s3,8(sp)
ffffffffc0201a94:	f406                	sd	ra,40(sp)
ffffffffc0201a96:	84ae                	mv	s1,a1
ffffffffc0201a98:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201a9a:	852ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0201a9e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201aa0:	cd19                	beqz	a0,ffffffffc0201abe <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201aa2:	85aa                	mv	a1,a0
ffffffffc0201aa4:	86ce                	mv	a3,s3
ffffffffc0201aa6:	8626                	mv	a2,s1
ffffffffc0201aa8:	854a                	mv	a0,s2
ffffffffc0201aaa:	c28ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc0201aae:	ed39                	bnez	a0,ffffffffc0201b0c <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201ab0:	00010797          	auipc	a5,0x10
ffffffffc0201ab4:	9c078793          	addi	a5,a5,-1600 # ffffffffc0211470 <swap_init_ok>
ffffffffc0201ab8:	439c                	lw	a5,0(a5)
ffffffffc0201aba:	2781                	sext.w	a5,a5
ffffffffc0201abc:	eb89                	bnez	a5,ffffffffc0201ace <pgdir_alloc_page+0x48>
}
ffffffffc0201abe:	8522                	mv	a0,s0
ffffffffc0201ac0:	70a2                	ld	ra,40(sp)
ffffffffc0201ac2:	7402                	ld	s0,32(sp)
ffffffffc0201ac4:	64e2                	ld	s1,24(sp)
ffffffffc0201ac6:	6942                	ld	s2,16(sp)
ffffffffc0201ac8:	69a2                	ld	s3,8(sp)
ffffffffc0201aca:	6145                	addi	sp,sp,48
ffffffffc0201acc:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201ace:	00010797          	auipc	a5,0x10
ffffffffc0201ad2:	9d278793          	addi	a5,a5,-1582 # ffffffffc02114a0 <check_mm_struct>
ffffffffc0201ad6:	6388                	ld	a0,0(a5)
ffffffffc0201ad8:	4681                	li	a3,0
ffffffffc0201ada:	8622                	mv	a2,s0
ffffffffc0201adc:	85a6                	mv	a1,s1
ffffffffc0201ade:	080010ef          	jal	ra,ffffffffc0202b5e <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201ae2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201ae4:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201ae6:	4785                	li	a5,1
ffffffffc0201ae8:	fcf70be3          	beq	a4,a5,ffffffffc0201abe <pgdir_alloc_page+0x38>
ffffffffc0201aec:	00003697          	auipc	a3,0x3
ffffffffc0201af0:	23c68693          	addi	a3,a3,572 # ffffffffc0204d28 <commands+0x8e8>
ffffffffc0201af4:	00003617          	auipc	a2,0x3
ffffffffc0201af8:	33c60613          	addi	a2,a2,828 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201afc:	17a00593          	li	a1,378
ffffffffc0201b00:	00003517          	auipc	a0,0x3
ffffffffc0201b04:	1a850513          	addi	a0,a0,424 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201b08:	dfefe0ef          	jal	ra,ffffffffc0200106 <__panic>
            free_page(page);
ffffffffc0201b0c:	8522                	mv	a0,s0
ffffffffc0201b0e:	4585                	li	a1,1
ffffffffc0201b10:	864ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
            return NULL;
ffffffffc0201b14:	4401                	li	s0,0
ffffffffc0201b16:	b765                	j	ffffffffc0201abe <pgdir_alloc_page+0x38>

ffffffffc0201b18 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0201b18:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b1a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0201b1c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b1e:	fff50713          	addi	a4,a0,-1
ffffffffc0201b22:	17f9                	addi	a5,a5,-2
ffffffffc0201b24:	04e7ee63          	bltu	a5,a4,ffffffffc0201b80 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201b28:	6785                	lui	a5,0x1
ffffffffc0201b2a:	17fd                	addi	a5,a5,-1
ffffffffc0201b2c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0201b2e:	8131                	srli	a0,a0,0xc
ffffffffc0201b30:	fbdfe0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
    assert(base != NULL);
ffffffffc0201b34:	c159                	beqz	a0,ffffffffc0201bba <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b36:	00010797          	auipc	a5,0x10
ffffffffc0201b3a:	96278793          	addi	a5,a5,-1694 # ffffffffc0211498 <pages>
ffffffffc0201b3e:	639c                	ld	a5,0(a5)
ffffffffc0201b40:	8d1d                	sub	a0,a0,a5
ffffffffc0201b42:	00003797          	auipc	a5,0x3
ffffffffc0201b46:	13678793          	addi	a5,a5,310 # ffffffffc0204c78 <commands+0x838>
ffffffffc0201b4a:	6394                	ld	a3,0(a5)
ffffffffc0201b4c:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b4e:	00010797          	auipc	a5,0x10
ffffffffc0201b52:	90a78793          	addi	a5,a5,-1782 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b56:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b5a:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b5c:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b60:	57fd                	li	a5,-1
ffffffffc0201b62:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b64:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b66:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b68:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b6a:	02e7fb63          	bleu	a4,a5,ffffffffc0201ba0 <kmalloc+0x88>
ffffffffc0201b6e:	00010797          	auipc	a5,0x10
ffffffffc0201b72:	91a78793          	addi	a5,a5,-1766 # ffffffffc0211488 <va_pa_offset>
ffffffffc0201b76:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0201b78:	60a2                	ld	ra,8(sp)
ffffffffc0201b7a:	953e                	add	a0,a0,a5
ffffffffc0201b7c:	0141                	addi	sp,sp,16
ffffffffc0201b7e:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b80:	00003697          	auipc	a3,0x3
ffffffffc0201b84:	14868693          	addi	a3,a3,328 # ffffffffc0204cc8 <commands+0x888>
ffffffffc0201b88:	00003617          	auipc	a2,0x3
ffffffffc0201b8c:	2a860613          	addi	a2,a2,680 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201b90:	1f000593          	li	a1,496
ffffffffc0201b94:	00003517          	auipc	a0,0x3
ffffffffc0201b98:	11450513          	addi	a0,a0,276 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201b9c:	d6afe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201ba0:	86aa                	mv	a3,a0
ffffffffc0201ba2:	00003617          	auipc	a2,0x3
ffffffffc0201ba6:	0de60613          	addi	a2,a2,222 # ffffffffc0204c80 <commands+0x840>
ffffffffc0201baa:	06a00593          	li	a1,106
ffffffffc0201bae:	00003517          	auipc	a0,0x3
ffffffffc0201bb2:	16a50513          	addi	a0,a0,362 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc0201bb6:	d50fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(base != NULL);
ffffffffc0201bba:	00003697          	auipc	a3,0x3
ffffffffc0201bbe:	12e68693          	addi	a3,a3,302 # ffffffffc0204ce8 <commands+0x8a8>
ffffffffc0201bc2:	00003617          	auipc	a2,0x3
ffffffffc0201bc6:	26e60613          	addi	a2,a2,622 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201bca:	1f300593          	li	a1,499
ffffffffc0201bce:	00003517          	auipc	a0,0x3
ffffffffc0201bd2:	0da50513          	addi	a0,a0,218 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201bd6:	d30fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201bda <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0201bda:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201bdc:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0201bde:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201be0:	fff58713          	addi	a4,a1,-1
ffffffffc0201be4:	17f9                	addi	a5,a5,-2
ffffffffc0201be6:	04e7eb63          	bltu	a5,a4,ffffffffc0201c3c <kfree+0x62>
    assert(ptr != NULL);
ffffffffc0201bea:	c941                	beqz	a0,ffffffffc0201c7a <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201bec:	6785                	lui	a5,0x1
ffffffffc0201bee:	17fd                	addi	a5,a5,-1
ffffffffc0201bf0:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201bf2:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bf6:	81b1                	srli	a1,a1,0xc
ffffffffc0201bf8:	06f56463          	bltu	a0,a5,ffffffffc0201c60 <kfree+0x86>
ffffffffc0201bfc:	00010797          	auipc	a5,0x10
ffffffffc0201c00:	88c78793          	addi	a5,a5,-1908 # ffffffffc0211488 <va_pa_offset>
ffffffffc0201c04:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201c06:	00010717          	auipc	a4,0x10
ffffffffc0201c0a:	85270713          	addi	a4,a4,-1966 # ffffffffc0211458 <npage>
ffffffffc0201c0e:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201c10:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0201c14:	83b1                	srli	a5,a5,0xc
ffffffffc0201c16:	04e7f363          	bleu	a4,a5,ffffffffc0201c5c <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c1a:	fff80537          	lui	a0,0xfff80
ffffffffc0201c1e:	97aa                	add	a5,a5,a0
ffffffffc0201c20:	00010697          	auipc	a3,0x10
ffffffffc0201c24:	87868693          	addi	a3,a3,-1928 # ffffffffc0211498 <pages>
ffffffffc0201c28:	6288                	ld	a0,0(a3)
ffffffffc0201c2a:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0201c2e:	60a2                	ld	ra,8(sp)
ffffffffc0201c30:	97ba                	add	a5,a5,a4
ffffffffc0201c32:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0201c34:	953e                	add	a0,a0,a5
}
ffffffffc0201c36:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0201c38:	f3dfe06f          	j	ffffffffc0200b74 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c3c:	00003697          	auipc	a3,0x3
ffffffffc0201c40:	08c68693          	addi	a3,a3,140 # ffffffffc0204cc8 <commands+0x888>
ffffffffc0201c44:	00003617          	auipc	a2,0x3
ffffffffc0201c48:	1ec60613          	addi	a2,a2,492 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201c4c:	1f900593          	li	a1,505
ffffffffc0201c50:	00003517          	auipc	a0,0x3
ffffffffc0201c54:	05850513          	addi	a0,a0,88 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201c58:	caefe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201c5c:	e75fe0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201c60:	86aa                	mv	a3,a0
ffffffffc0201c62:	00003617          	auipc	a2,0x3
ffffffffc0201c66:	16660613          	addi	a2,a2,358 # ffffffffc0204dc8 <commands+0x988>
ffffffffc0201c6a:	06c00593          	li	a1,108
ffffffffc0201c6e:	00003517          	auipc	a0,0x3
ffffffffc0201c72:	0aa50513          	addi	a0,a0,170 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc0201c76:	c90fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(ptr != NULL);
ffffffffc0201c7a:	00003697          	auipc	a3,0x3
ffffffffc0201c7e:	03e68693          	addi	a3,a3,62 # ffffffffc0204cb8 <commands+0x878>
ffffffffc0201c82:	00003617          	auipc	a2,0x3
ffffffffc0201c86:	1ae60613          	addi	a2,a2,430 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201c8a:	1fa00593          	li	a1,506
ffffffffc0201c8e:	00003517          	auipc	a0,0x3
ffffffffc0201c92:	01a50513          	addi	a0,a0,26 # ffffffffc0204ca8 <commands+0x868>
ffffffffc0201c96:	c70fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201c9a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201c9a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201c9c:	00003697          	auipc	a3,0x3
ffffffffc0201ca0:	64c68693          	addi	a3,a3,1612 # ffffffffc02052e8 <commands+0xea8>
ffffffffc0201ca4:	00003617          	auipc	a2,0x3
ffffffffc0201ca8:	18c60613          	addi	a2,a2,396 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201cac:	07d00593          	li	a1,125
ffffffffc0201cb0:	00003517          	auipc	a0,0x3
ffffffffc0201cb4:	65850513          	addi	a0,a0,1624 # ffffffffc0205308 <commands+0xec8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201cb8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201cba:	c4cfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201cbe <mm_create>:
mm_create(void) {
ffffffffc0201cbe:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201cc0:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201cc4:	e022                	sd	s0,0(sp)
ffffffffc0201cc6:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201cc8:	e51ff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc0201ccc:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201cce:	c115                	beqz	a0,ffffffffc0201cf2 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cd0:	0000f797          	auipc	a5,0xf
ffffffffc0201cd4:	7a078793          	addi	a5,a5,1952 # ffffffffc0211470 <swap_init_ok>
ffffffffc0201cd8:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201cda:	e408                	sd	a0,8(s0)
ffffffffc0201cdc:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201cde:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201ce2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201ce6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cea:	2781                	sext.w	a5,a5
ffffffffc0201cec:	eb81                	bnez	a5,ffffffffc0201cfc <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201cee:	02053423          	sd	zero,40(a0)
}
ffffffffc0201cf2:	8522                	mv	a0,s0
ffffffffc0201cf4:	60a2                	ld	ra,8(sp)
ffffffffc0201cf6:	6402                	ld	s0,0(sp)
ffffffffc0201cf8:	0141                	addi	sp,sp,16
ffffffffc0201cfa:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cfc:	653000ef          	jal	ra,ffffffffc0202b4e <swap_init_mm>
}
ffffffffc0201d00:	8522                	mv	a0,s0
ffffffffc0201d02:	60a2                	ld	ra,8(sp)
ffffffffc0201d04:	6402                	ld	s0,0(sp)
ffffffffc0201d06:	0141                	addi	sp,sp,16
ffffffffc0201d08:	8082                	ret

ffffffffc0201d0a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201d0a:	1101                	addi	sp,sp,-32
ffffffffc0201d0c:	e04a                	sd	s2,0(sp)
ffffffffc0201d0e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d10:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201d14:	e822                	sd	s0,16(sp)
ffffffffc0201d16:	e426                	sd	s1,8(sp)
ffffffffc0201d18:	ec06                	sd	ra,24(sp)
ffffffffc0201d1a:	84ae                	mv	s1,a1
ffffffffc0201d1c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d1e:	dfbff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
    if (vma != NULL) {
ffffffffc0201d22:	c509                	beqz	a0,ffffffffc0201d2c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201d24:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d28:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d2a:	ed00                	sd	s0,24(a0)
}
ffffffffc0201d2c:	60e2                	ld	ra,24(sp)
ffffffffc0201d2e:	6442                	ld	s0,16(sp)
ffffffffc0201d30:	64a2                	ld	s1,8(sp)
ffffffffc0201d32:	6902                	ld	s2,0(sp)
ffffffffc0201d34:	6105                	addi	sp,sp,32
ffffffffc0201d36:	8082                	ret

ffffffffc0201d38 <find_vma>:
    if (mm != NULL) {
ffffffffc0201d38:	c51d                	beqz	a0,ffffffffc0201d66 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201d3a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d3c:	c781                	beqz	a5,ffffffffc0201d44 <find_vma+0xc>
ffffffffc0201d3e:	6798                	ld	a4,8(a5)
ffffffffc0201d40:	02e5f663          	bleu	a4,a1,ffffffffc0201d6c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201d44:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201d46:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201d48:	00f50f63          	beq	a0,a5,ffffffffc0201d66 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201d4c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201d50:	fee5ebe3          	bltu	a1,a4,ffffffffc0201d46 <find_vma+0xe>
ffffffffc0201d54:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201d58:	fee5f7e3          	bleu	a4,a1,ffffffffc0201d46 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201d5c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201d5e:	c781                	beqz	a5,ffffffffc0201d66 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201d60:	e91c                	sd	a5,16(a0)
}
ffffffffc0201d62:	853e                	mv	a0,a5
ffffffffc0201d64:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201d66:	4781                	li	a5,0
}
ffffffffc0201d68:	853e                	mv	a0,a5
ffffffffc0201d6a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d6c:	6b98                	ld	a4,16(a5)
ffffffffc0201d6e:	fce5fbe3          	bleu	a4,a1,ffffffffc0201d44 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201d72:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201d74:	b7fd                	j	ffffffffc0201d62 <find_vma+0x2a>

ffffffffc0201d76 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d76:	6590                	ld	a2,8(a1)
ffffffffc0201d78:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201d7c:	1141                	addi	sp,sp,-16
ffffffffc0201d7e:	e406                	sd	ra,8(sp)
ffffffffc0201d80:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d82:	01066863          	bltu	a2,a6,ffffffffc0201d92 <insert_vma_struct+0x1c>
ffffffffc0201d86:	a8b9                	j	ffffffffc0201de4 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201d88:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201d8c:	04d66763          	bltu	a2,a3,ffffffffc0201dda <insert_vma_struct+0x64>
ffffffffc0201d90:	873e                	mv	a4,a5
ffffffffc0201d92:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201d94:	fef51ae3          	bne	a0,a5,ffffffffc0201d88 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201d98:	02a70463          	beq	a4,a0,ffffffffc0201dc0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201d9c:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201da0:	fe873883          	ld	a7,-24(a4)
ffffffffc0201da4:	08d8f063          	bleu	a3,a7,ffffffffc0201e24 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201da8:	04d66e63          	bltu	a2,a3,ffffffffc0201e04 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201dac:	00f50a63          	beq	a0,a5,ffffffffc0201dc0 <insert_vma_struct+0x4a>
ffffffffc0201db0:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201db4:	0506e863          	bltu	a3,a6,ffffffffc0201e04 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201db8:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201dbc:	02c6f263          	bleu	a2,a3,ffffffffc0201de0 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201dc0:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201dc2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201dc4:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201dc8:	e390                	sd	a2,0(a5)
ffffffffc0201dca:	e710                	sd	a2,8(a4)
}
ffffffffc0201dcc:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201dce:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201dd0:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201dd2:	2685                	addiw	a3,a3,1
ffffffffc0201dd4:	d114                	sw	a3,32(a0)
}
ffffffffc0201dd6:	0141                	addi	sp,sp,16
ffffffffc0201dd8:	8082                	ret
    if (le_prev != list) {
ffffffffc0201dda:	fca711e3          	bne	a4,a0,ffffffffc0201d9c <insert_vma_struct+0x26>
ffffffffc0201dde:	bfd9                	j	ffffffffc0201db4 <insert_vma_struct+0x3e>
ffffffffc0201de0:	ebbff0ef          	jal	ra,ffffffffc0201c9a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201de4:	00003697          	auipc	a3,0x3
ffffffffc0201de8:	5d468693          	addi	a3,a3,1492 # ffffffffc02053b8 <commands+0xf78>
ffffffffc0201dec:	00003617          	auipc	a2,0x3
ffffffffc0201df0:	04460613          	addi	a2,a2,68 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201df4:	08400593          	li	a1,132
ffffffffc0201df8:	00003517          	auipc	a0,0x3
ffffffffc0201dfc:	51050513          	addi	a0,a0,1296 # ffffffffc0205308 <commands+0xec8>
ffffffffc0201e00:	b06fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201e04:	00003697          	auipc	a3,0x3
ffffffffc0201e08:	5f468693          	addi	a3,a3,1524 # ffffffffc02053f8 <commands+0xfb8>
ffffffffc0201e0c:	00003617          	auipc	a2,0x3
ffffffffc0201e10:	02460613          	addi	a2,a2,36 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201e14:	07c00593          	li	a1,124
ffffffffc0201e18:	00003517          	auipc	a0,0x3
ffffffffc0201e1c:	4f050513          	addi	a0,a0,1264 # ffffffffc0205308 <commands+0xec8>
ffffffffc0201e20:	ae6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201e24:	00003697          	auipc	a3,0x3
ffffffffc0201e28:	5b468693          	addi	a3,a3,1460 # ffffffffc02053d8 <commands+0xf98>
ffffffffc0201e2c:	00003617          	auipc	a2,0x3
ffffffffc0201e30:	00460613          	addi	a2,a2,4 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201e34:	07b00593          	li	a1,123
ffffffffc0201e38:	00003517          	auipc	a0,0x3
ffffffffc0201e3c:	4d050513          	addi	a0,a0,1232 # ffffffffc0205308 <commands+0xec8>
ffffffffc0201e40:	ac6fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201e44 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201e44:	1141                	addi	sp,sp,-16
ffffffffc0201e46:	e022                	sd	s0,0(sp)
ffffffffc0201e48:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201e4a:	6508                	ld	a0,8(a0)
ffffffffc0201e4c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201e4e:	00a40e63          	beq	s0,a0,ffffffffc0201e6a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201e52:	6118                	ld	a4,0(a0)
ffffffffc0201e54:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201e56:	03000593          	li	a1,48
ffffffffc0201e5a:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201e5c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201e5e:	e398                	sd	a4,0(a5)
ffffffffc0201e60:	d7bff0ef          	jal	ra,ffffffffc0201bda <kfree>
    return listelm->next;
ffffffffc0201e64:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201e66:	fea416e3          	bne	s0,a0,ffffffffc0201e52 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e6a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201e6c:	6402                	ld	s0,0(sp)
ffffffffc0201e6e:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e70:	03000593          	li	a1,48
}
ffffffffc0201e74:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e76:	d65ff06f          	j	ffffffffc0201bda <kfree>

ffffffffc0201e7a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201e7a:	715d                	addi	sp,sp,-80
ffffffffc0201e7c:	e486                	sd	ra,72(sp)
ffffffffc0201e7e:	e0a2                	sd	s0,64(sp)
ffffffffc0201e80:	fc26                	sd	s1,56(sp)
ffffffffc0201e82:	f84a                	sd	s2,48(sp)
ffffffffc0201e84:	f052                	sd	s4,32(sp)
ffffffffc0201e86:	f44e                	sd	s3,40(sp)
ffffffffc0201e88:	ec56                	sd	s5,24(sp)
ffffffffc0201e8a:	e85a                	sd	s6,16(sp)
ffffffffc0201e8c:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201e8e:	d2dfe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0201e92:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201e94:	d27fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0201e98:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0201e9a:	e25ff0ef          	jal	ra,ffffffffc0201cbe <mm_create>
    assert(mm != NULL);
ffffffffc0201e9e:	842a                	mv	s0,a0
ffffffffc0201ea0:	03200493          	li	s1,50
ffffffffc0201ea4:	e919                	bnez	a0,ffffffffc0201eba <vmm_init+0x40>
ffffffffc0201ea6:	aeed                	j	ffffffffc02022a0 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0201ea8:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201eaa:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201eac:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201eb0:	14ed                	addi	s1,s1,-5
ffffffffc0201eb2:	8522                	mv	a0,s0
ffffffffc0201eb4:	ec3ff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201eb8:	c88d                	beqz	s1,ffffffffc0201eea <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201eba:	03000513          	li	a0,48
ffffffffc0201ebe:	c5bff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc0201ec2:	85aa                	mv	a1,a0
ffffffffc0201ec4:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201ec8:	f165                	bnez	a0,ffffffffc0201ea8 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0201eca:	00003697          	auipc	a3,0x3
ffffffffc0201ece:	77668693          	addi	a3,a3,1910 # ffffffffc0205640 <commands+0x1200>
ffffffffc0201ed2:	00003617          	auipc	a2,0x3
ffffffffc0201ed6:	f5e60613          	addi	a2,a2,-162 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201eda:	0ce00593          	li	a1,206
ffffffffc0201ede:	00003517          	auipc	a0,0x3
ffffffffc0201ee2:	42a50513          	addi	a0,a0,1066 # ffffffffc0205308 <commands+0xec8>
ffffffffc0201ee6:	a20fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201eea:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201eee:	1f900993          	li	s3,505
ffffffffc0201ef2:	a819                	j	ffffffffc0201f08 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0201ef4:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201ef6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201ef8:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201efc:	0495                	addi	s1,s1,5
ffffffffc0201efe:	8522                	mv	a0,s0
ffffffffc0201f00:	e77ff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201f04:	03348a63          	beq	s1,s3,ffffffffc0201f38 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201f08:	03000513          	li	a0,48
ffffffffc0201f0c:	c0dff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc0201f10:	85aa                	mv	a1,a0
ffffffffc0201f12:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201f16:	fd79                	bnez	a0,ffffffffc0201ef4 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0201f18:	00003697          	auipc	a3,0x3
ffffffffc0201f1c:	72868693          	addi	a3,a3,1832 # ffffffffc0205640 <commands+0x1200>
ffffffffc0201f20:	00003617          	auipc	a2,0x3
ffffffffc0201f24:	f1060613          	addi	a2,a2,-240 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0201f28:	0d400593          	li	a1,212
ffffffffc0201f2c:	00003517          	auipc	a0,0x3
ffffffffc0201f30:	3dc50513          	addi	a0,a0,988 # ffffffffc0205308 <commands+0xec8>
ffffffffc0201f34:	9d2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201f38:	6418                	ld	a4,8(s0)
ffffffffc0201f3a:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201f3c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201f40:	2ae40063          	beq	s0,a4,ffffffffc02021e0 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201f44:	fe873603          	ld	a2,-24(a4)
ffffffffc0201f48:	ffe78693          	addi	a3,a5,-2
ffffffffc0201f4c:	20d61a63          	bne	a2,a3,ffffffffc0202160 <vmm_init+0x2e6>
ffffffffc0201f50:	ff073683          	ld	a3,-16(a4)
ffffffffc0201f54:	20d79663          	bne	a5,a3,ffffffffc0202160 <vmm_init+0x2e6>
ffffffffc0201f58:	0795                	addi	a5,a5,5
ffffffffc0201f5a:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201f5c:	feb792e3          	bne	a5,a1,ffffffffc0201f40 <vmm_init+0xc6>
ffffffffc0201f60:	499d                	li	s3,7
ffffffffc0201f62:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201f64:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201f68:	85a6                	mv	a1,s1
ffffffffc0201f6a:	8522                	mv	a0,s0
ffffffffc0201f6c:	dcdff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0201f70:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0201f72:	2e050763          	beqz	a0,ffffffffc0202260 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201f76:	00148593          	addi	a1,s1,1
ffffffffc0201f7a:	8522                	mv	a0,s0
ffffffffc0201f7c:	dbdff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0201f80:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0201f82:	2a050f63          	beqz	a0,ffffffffc0202240 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201f86:	85ce                	mv	a1,s3
ffffffffc0201f88:	8522                	mv	a0,s0
ffffffffc0201f8a:	dafff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
        assert(vma3 == NULL);
ffffffffc0201f8e:	28051963          	bnez	a0,ffffffffc0202220 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201f92:	00348593          	addi	a1,s1,3
ffffffffc0201f96:	8522                	mv	a0,s0
ffffffffc0201f98:	da1ff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201f9c:	26051263          	bnez	a0,ffffffffc0202200 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201fa0:	00448593          	addi	a1,s1,4
ffffffffc0201fa4:	8522                	mv	a0,s0
ffffffffc0201fa6:	d93ff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201faa:	2c051b63          	bnez	a0,ffffffffc0202280 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201fae:	008b3783          	ld	a5,8(s6)
ffffffffc0201fb2:	1c979763          	bne	a5,s1,ffffffffc0202180 <vmm_init+0x306>
ffffffffc0201fb6:	010b3783          	ld	a5,16(s6)
ffffffffc0201fba:	1d379363          	bne	a5,s3,ffffffffc0202180 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201fbe:	008ab783          	ld	a5,8(s5)
ffffffffc0201fc2:	1c979f63          	bne	a5,s1,ffffffffc02021a0 <vmm_init+0x326>
ffffffffc0201fc6:	010ab783          	ld	a5,16(s5)
ffffffffc0201fca:	1d379b63          	bne	a5,s3,ffffffffc02021a0 <vmm_init+0x326>
ffffffffc0201fce:	0495                	addi	s1,s1,5
ffffffffc0201fd0:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201fd2:	f9749be3          	bne	s1,s7,ffffffffc0201f68 <vmm_init+0xee>
ffffffffc0201fd6:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201fd8:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201fda:	85a6                	mv	a1,s1
ffffffffc0201fdc:	8522                	mv	a0,s0
ffffffffc0201fde:	d5bff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0201fe2:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201fe6:	c90d                	beqz	a0,ffffffffc0202018 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201fe8:	6914                	ld	a3,16(a0)
ffffffffc0201fea:	6510                	ld	a2,8(a0)
ffffffffc0201fec:	00003517          	auipc	a0,0x3
ffffffffc0201ff0:	53c50513          	addi	a0,a0,1340 # ffffffffc0205528 <commands+0x10e8>
ffffffffc0201ff4:	8cafe0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201ff8:	00003697          	auipc	a3,0x3
ffffffffc0201ffc:	55868693          	addi	a3,a3,1368 # ffffffffc0205550 <commands+0x1110>
ffffffffc0202000:	00003617          	auipc	a2,0x3
ffffffffc0202004:	e3060613          	addi	a2,a2,-464 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202008:	0f600593          	li	a1,246
ffffffffc020200c:	00003517          	auipc	a0,0x3
ffffffffc0202010:	2fc50513          	addi	a0,a0,764 # ffffffffc0205308 <commands+0xec8>
ffffffffc0202014:	8f2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0202018:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020201a:	fd3490e3          	bne	s1,s3,ffffffffc0201fda <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc020201e:	8522                	mv	a0,s0
ffffffffc0202020:	e25ff0ef          	jal	ra,ffffffffc0201e44 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202024:	b97fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202028:	28aa1c63          	bne	s4,a0,ffffffffc02022c0 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020202c:	00003517          	auipc	a0,0x3
ffffffffc0202030:	56450513          	addi	a0,a0,1380 # ffffffffc0205590 <commands+0x1150>
ffffffffc0202034:	88afe0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202038:	b83fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc020203c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020203e:	c81ff0ef          	jal	ra,ffffffffc0201cbe <mm_create>
ffffffffc0202042:	0000f797          	auipc	a5,0xf
ffffffffc0202046:	44a7bf23          	sd	a0,1118(a5) # ffffffffc02114a0 <check_mm_struct>
ffffffffc020204a:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc020204c:	2a050a63          	beqz	a0,ffffffffc0202300 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202050:	0000f797          	auipc	a5,0xf
ffffffffc0202054:	40078793          	addi	a5,a5,1024 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202058:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020205a:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020205c:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020205e:	32079d63          	bnez	a5,ffffffffc0202398 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202062:	03000513          	li	a0,48
ffffffffc0202066:	ab3ff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc020206a:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020206c:	14050a63          	beqz	a0,ffffffffc02021c0 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0202070:	002007b7          	lui	a5,0x200
ffffffffc0202074:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0202078:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020207a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020207c:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202080:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202082:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202086:	cf1ff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020208a:	10000593          	li	a1,256
ffffffffc020208e:	8522                	mv	a0,s0
ffffffffc0202090:	ca9ff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0202094:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0202098:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020209c:	2aaa1263          	bne	s4,a0,ffffffffc0202340 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc02020a0:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc02020a4:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02020a6:	fee79de3          	bne	a5,a4,ffffffffc02020a0 <vmm_init+0x226>
        sum += i;
ffffffffc02020aa:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02020ac:	10000793          	li	a5,256
        sum += i;
ffffffffc02020b0:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02020b4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02020b8:	0007c683          	lbu	a3,0(a5)
ffffffffc02020bc:	0785                	addi	a5,a5,1
ffffffffc02020be:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02020c0:	fec79ce3          	bne	a5,a2,ffffffffc02020b8 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc02020c4:	2a071a63          	bnez	a4,ffffffffc0202378 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02020c8:	4581                	li	a1,0
ffffffffc02020ca:	8526                	mv	a0,s1
ffffffffc02020cc:	d95fe0ef          	jal	ra,ffffffffc0200e60 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02020d0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02020d2:	0000f717          	auipc	a4,0xf
ffffffffc02020d6:	38670713          	addi	a4,a4,902 # ffffffffc0211458 <npage>
ffffffffc02020da:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020dc:	078a                	slli	a5,a5,0x2
ffffffffc02020de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020e0:	28e7f063          	bleu	a4,a5,ffffffffc0202360 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc02020e4:	00004717          	auipc	a4,0x4
ffffffffc02020e8:	02470713          	addi	a4,a4,36 # ffffffffc0206108 <nbase>
ffffffffc02020ec:	6318                	ld	a4,0(a4)
ffffffffc02020ee:	0000f697          	auipc	a3,0xf
ffffffffc02020f2:	3aa68693          	addi	a3,a3,938 # ffffffffc0211498 <pages>
ffffffffc02020f6:	6288                	ld	a0,0(a3)
ffffffffc02020f8:	8f99                	sub	a5,a5,a4
ffffffffc02020fa:	00379713          	slli	a4,a5,0x3
ffffffffc02020fe:	97ba                	add	a5,a5,a4
ffffffffc0202100:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0202102:	953e                	add	a0,a0,a5
ffffffffc0202104:	4585                	li	a1,1
ffffffffc0202106:	a6ffe0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    pgdir[0] = 0;
ffffffffc020210a:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020210e:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0202110:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0202114:	d31ff0ef          	jal	ra,ffffffffc0201e44 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0202118:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020211a:	0000f797          	auipc	a5,0xf
ffffffffc020211e:	3807b323          	sd	zero,902(a5) # ffffffffc02114a0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202122:	a99fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202126:	1aa99d63          	bne	s3,a0,ffffffffc02022e0 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020212a:	00003517          	auipc	a0,0x3
ffffffffc020212e:	4de50513          	addi	a0,a0,1246 # ffffffffc0205608 <commands+0x11c8>
ffffffffc0202132:	f8dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202136:	a85fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020213a:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020213c:	1ea91263          	bne	s2,a0,ffffffffc0202320 <vmm_init+0x4a6>
}
ffffffffc0202140:	6406                	ld	s0,64(sp)
ffffffffc0202142:	60a6                	ld	ra,72(sp)
ffffffffc0202144:	74e2                	ld	s1,56(sp)
ffffffffc0202146:	7942                	ld	s2,48(sp)
ffffffffc0202148:	79a2                	ld	s3,40(sp)
ffffffffc020214a:	7a02                	ld	s4,32(sp)
ffffffffc020214c:	6ae2                	ld	s5,24(sp)
ffffffffc020214e:	6b42                	ld	s6,16(sp)
ffffffffc0202150:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202152:	00003517          	auipc	a0,0x3
ffffffffc0202156:	4d650513          	addi	a0,a0,1238 # ffffffffc0205628 <commands+0x11e8>
}
ffffffffc020215a:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020215c:	f63fd06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202160:	00003697          	auipc	a3,0x3
ffffffffc0202164:	2e068693          	addi	a3,a3,736 # ffffffffc0205440 <commands+0x1000>
ffffffffc0202168:	00003617          	auipc	a2,0x3
ffffffffc020216c:	cc860613          	addi	a2,a2,-824 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202170:	0dd00593          	li	a1,221
ffffffffc0202174:	00003517          	auipc	a0,0x3
ffffffffc0202178:	19450513          	addi	a0,a0,404 # ffffffffc0205308 <commands+0xec8>
ffffffffc020217c:	f8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202180:	00003697          	auipc	a3,0x3
ffffffffc0202184:	34868693          	addi	a3,a3,840 # ffffffffc02054c8 <commands+0x1088>
ffffffffc0202188:	00003617          	auipc	a2,0x3
ffffffffc020218c:	ca860613          	addi	a2,a2,-856 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202190:	0ed00593          	li	a1,237
ffffffffc0202194:	00003517          	auipc	a0,0x3
ffffffffc0202198:	17450513          	addi	a0,a0,372 # ffffffffc0205308 <commands+0xec8>
ffffffffc020219c:	f6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02021a0:	00003697          	auipc	a3,0x3
ffffffffc02021a4:	35868693          	addi	a3,a3,856 # ffffffffc02054f8 <commands+0x10b8>
ffffffffc02021a8:	00003617          	auipc	a2,0x3
ffffffffc02021ac:	c8860613          	addi	a2,a2,-888 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02021b0:	0ee00593          	li	a1,238
ffffffffc02021b4:	00003517          	auipc	a0,0x3
ffffffffc02021b8:	15450513          	addi	a0,a0,340 # ffffffffc0205308 <commands+0xec8>
ffffffffc02021bc:	f4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(vma != NULL);
ffffffffc02021c0:	00003697          	auipc	a3,0x3
ffffffffc02021c4:	48068693          	addi	a3,a3,1152 # ffffffffc0205640 <commands+0x1200>
ffffffffc02021c8:	00003617          	auipc	a2,0x3
ffffffffc02021cc:	c6860613          	addi	a2,a2,-920 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02021d0:	11100593          	li	a1,273
ffffffffc02021d4:	00003517          	auipc	a0,0x3
ffffffffc02021d8:	13450513          	addi	a0,a0,308 # ffffffffc0205308 <commands+0xec8>
ffffffffc02021dc:	f2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02021e0:	00003697          	auipc	a3,0x3
ffffffffc02021e4:	24868693          	addi	a3,a3,584 # ffffffffc0205428 <commands+0xfe8>
ffffffffc02021e8:	00003617          	auipc	a2,0x3
ffffffffc02021ec:	c4860613          	addi	a2,a2,-952 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02021f0:	0db00593          	li	a1,219
ffffffffc02021f4:	00003517          	auipc	a0,0x3
ffffffffc02021f8:	11450513          	addi	a0,a0,276 # ffffffffc0205308 <commands+0xec8>
ffffffffc02021fc:	f0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma4 == NULL);
ffffffffc0202200:	00003697          	auipc	a3,0x3
ffffffffc0202204:	2a868693          	addi	a3,a3,680 # ffffffffc02054a8 <commands+0x1068>
ffffffffc0202208:	00003617          	auipc	a2,0x3
ffffffffc020220c:	c2860613          	addi	a2,a2,-984 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202210:	0e900593          	li	a1,233
ffffffffc0202214:	00003517          	auipc	a0,0x3
ffffffffc0202218:	0f450513          	addi	a0,a0,244 # ffffffffc0205308 <commands+0xec8>
ffffffffc020221c:	eebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma3 == NULL);
ffffffffc0202220:	00003697          	auipc	a3,0x3
ffffffffc0202224:	27868693          	addi	a3,a3,632 # ffffffffc0205498 <commands+0x1058>
ffffffffc0202228:	00003617          	auipc	a2,0x3
ffffffffc020222c:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202230:	0e700593          	li	a1,231
ffffffffc0202234:	00003517          	auipc	a0,0x3
ffffffffc0202238:	0d450513          	addi	a0,a0,212 # ffffffffc0205308 <commands+0xec8>
ffffffffc020223c:	ecbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2 != NULL);
ffffffffc0202240:	00003697          	auipc	a3,0x3
ffffffffc0202244:	24868693          	addi	a3,a3,584 # ffffffffc0205488 <commands+0x1048>
ffffffffc0202248:	00003617          	auipc	a2,0x3
ffffffffc020224c:	be860613          	addi	a2,a2,-1048 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202250:	0e500593          	li	a1,229
ffffffffc0202254:	00003517          	auipc	a0,0x3
ffffffffc0202258:	0b450513          	addi	a0,a0,180 # ffffffffc0205308 <commands+0xec8>
ffffffffc020225c:	eabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1 != NULL);
ffffffffc0202260:	00003697          	auipc	a3,0x3
ffffffffc0202264:	21868693          	addi	a3,a3,536 # ffffffffc0205478 <commands+0x1038>
ffffffffc0202268:	00003617          	auipc	a2,0x3
ffffffffc020226c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202270:	0e300593          	li	a1,227
ffffffffc0202274:	00003517          	auipc	a0,0x3
ffffffffc0202278:	09450513          	addi	a0,a0,148 # ffffffffc0205308 <commands+0xec8>
ffffffffc020227c:	e8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma5 == NULL);
ffffffffc0202280:	00003697          	auipc	a3,0x3
ffffffffc0202284:	23868693          	addi	a3,a3,568 # ffffffffc02054b8 <commands+0x1078>
ffffffffc0202288:	00003617          	auipc	a2,0x3
ffffffffc020228c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202290:	0eb00593          	li	a1,235
ffffffffc0202294:	00003517          	auipc	a0,0x3
ffffffffc0202298:	07450513          	addi	a0,a0,116 # ffffffffc0205308 <commands+0xec8>
ffffffffc020229c:	e6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(mm != NULL);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	17868693          	addi	a3,a3,376 # ffffffffc0205418 <commands+0xfd8>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02022b0:	0c700593          	li	a1,199
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	05450513          	addi	a0,a0,84 # ffffffffc0205308 <commands+0xec8>
ffffffffc02022bc:	e4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	2a868693          	addi	a3,a3,680 # ffffffffc0205568 <commands+0x1128>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02022d0:	0fb00593          	li	a1,251
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	03450513          	addi	a0,a0,52 # ffffffffc0205308 <commands+0xec8>
ffffffffc02022dc:	e2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	28868693          	addi	a3,a3,648 # ffffffffc0205568 <commands+0x1128>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02022f0:	12e00593          	li	a1,302
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	01450513          	addi	a0,a0,20 # ffffffffc0205308 <commands+0xec8>
ffffffffc02022fc:	e0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202300:	00003697          	auipc	a3,0x3
ffffffffc0202304:	2b068693          	addi	a3,a3,688 # ffffffffc02055b0 <commands+0x1170>
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202310:	10a00593          	li	a1,266
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	ff450513          	addi	a0,a0,-12 # ffffffffc0205308 <commands+0xec8>
ffffffffc020231c:	debfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202320:	00003697          	auipc	a3,0x3
ffffffffc0202324:	24868693          	addi	a3,a3,584 # ffffffffc0205568 <commands+0x1128>
ffffffffc0202328:	00003617          	auipc	a2,0x3
ffffffffc020232c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202330:	0bd00593          	li	a1,189
ffffffffc0202334:	00003517          	auipc	a0,0x3
ffffffffc0202338:	fd450513          	addi	a0,a0,-44 # ffffffffc0205308 <commands+0xec8>
ffffffffc020233c:	dcbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202340:	00003697          	auipc	a3,0x3
ffffffffc0202344:	29868693          	addi	a3,a3,664 # ffffffffc02055d8 <commands+0x1198>
ffffffffc0202348:	00003617          	auipc	a2,0x3
ffffffffc020234c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202350:	11600593          	li	a1,278
ffffffffc0202354:	00003517          	auipc	a0,0x3
ffffffffc0202358:	fb450513          	addi	a0,a0,-76 # ffffffffc0205308 <commands+0xec8>
ffffffffc020235c:	dabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202360:	00003617          	auipc	a2,0x3
ffffffffc0202364:	99860613          	addi	a2,a2,-1640 # ffffffffc0204cf8 <commands+0x8b8>
ffffffffc0202368:	06500593          	li	a1,101
ffffffffc020236c:	00003517          	auipc	a0,0x3
ffffffffc0202370:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc0202374:	d93fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(sum == 0);
ffffffffc0202378:	00003697          	auipc	a3,0x3
ffffffffc020237c:	28068693          	addi	a3,a3,640 # ffffffffc02055f8 <commands+0x11b8>
ffffffffc0202380:	00003617          	auipc	a2,0x3
ffffffffc0202384:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202388:	12000593          	li	a1,288
ffffffffc020238c:	00003517          	auipc	a0,0x3
ffffffffc0202390:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205308 <commands+0xec8>
ffffffffc0202394:	d73fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202398:	00003697          	auipc	a3,0x3
ffffffffc020239c:	23068693          	addi	a3,a3,560 # ffffffffc02055c8 <commands+0x1188>
ffffffffc02023a0:	00003617          	auipc	a2,0x3
ffffffffc02023a4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02023a8:	10d00593          	li	a1,269
ffffffffc02023ac:	00003517          	auipc	a0,0x3
ffffffffc02023b0:	f5c50513          	addi	a0,a0,-164 # ffffffffc0205308 <commands+0xec8>
ffffffffc02023b4:	d53fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02023b8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02023b8:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02023ba:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02023bc:	f822                	sd	s0,48(sp)
ffffffffc02023be:	f426                	sd	s1,40(sp)
ffffffffc02023c0:	fc06                	sd	ra,56(sp)
ffffffffc02023c2:	f04a                	sd	s2,32(sp)
ffffffffc02023c4:	ec4e                	sd	s3,24(sp)
ffffffffc02023c6:	8432                	mv	s0,a2
ffffffffc02023c8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02023ca:	96fff0ef          	jal	ra,ffffffffc0201d38 <find_vma>

    pgfault_num++;
ffffffffc02023ce:	0000f797          	auipc	a5,0xf
ffffffffc02023d2:	09278793          	addi	a5,a5,146 # ffffffffc0211460 <pgfault_num>
ffffffffc02023d6:	439c                	lw	a5,0(a5)
ffffffffc02023d8:	2785                	addiw	a5,a5,1
ffffffffc02023da:	0000f717          	auipc	a4,0xf
ffffffffc02023de:	08f72323          	sw	a5,134(a4) # ffffffffc0211460 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02023e2:	c54d                	beqz	a0,ffffffffc020248c <do_pgfault+0xd4>
ffffffffc02023e4:	651c                	ld	a5,8(a0)
ffffffffc02023e6:	0af46363          	bltu	s0,a5,ffffffffc020248c <do_pgfault+0xd4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023ea:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02023ec:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023ee:	8b89                	andi	a5,a5,2
ffffffffc02023f0:	efb9                	bnez	a5,ffffffffc020244e <do_pgfault+0x96>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023f2:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02023f4:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023f6:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02023f8:	85a2                	mv	a1,s0
ffffffffc02023fa:	4605                	li	a2,1
ffffffffc02023fc:	ffefe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0202400:	610c                	ld	a1,0(a0)
ffffffffc0202402:	c5b5                	beqz	a1,ffffffffc020246e <do_pgfault+0xb6>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202404:	0000f797          	auipc	a5,0xf
ffffffffc0202408:	06c78793          	addi	a5,a5,108 # ffffffffc0211470 <swap_init_ok>
ffffffffc020240c:	439c                	lw	a5,0(a5)
ffffffffc020240e:	2781                	sext.w	a5,a5
ffffffffc0202410:	c7d9                	beqz	a5,ffffffffc020249e <do_pgfault+0xe6>
            struct Page *page=NULL;//根据 mm 结构和 addr 地址，尝试将硬盘中的内容换入至 page 中
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0202412:	0030                	addi	a2,sp,8
ffffffffc0202414:	85a2                	mv	a1,s0
ffffffffc0202416:	8526                	mv	a0,s1
            struct Page *page=NULL;//根据 mm 结构和 addr 地址，尝试将硬盘中的内容换入至 page 中
ffffffffc0202418:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc020241a:	069000ef          	jal	ra,ffffffffc0202c82 <swap_in>
ffffffffc020241e:	892a                	mv	s2,a0
ffffffffc0202420:	e90d                	bnez	a0,ffffffffc0202452 <do_pgfault+0x9a>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);//建立虚拟地址和物理地址之间的对应关系
ffffffffc0202422:	65a2                	ld	a1,8(sp)
ffffffffc0202424:	6c88                	ld	a0,24(s1)
ffffffffc0202426:	86ce                	mv	a3,s3
ffffffffc0202428:	8622                	mv	a2,s0
ffffffffc020242a:	aa9fe0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
            swap_map_swappable(mm, addr, page, 1);//将此页面设置为可交换的
ffffffffc020242e:	6622                	ld	a2,8(sp)
ffffffffc0202430:	4685                	li	a3,1
ffffffffc0202432:	85a2                	mv	a1,s0
ffffffffc0202434:	8526                	mv	a0,s1
ffffffffc0202436:	728000ef          	jal	ra,ffffffffc0202b5e <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc020243a:	67a2                	ld	a5,8(sp)
ffffffffc020243c:	e3a0                	sd	s0,64(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc020243e:	70e2                	ld	ra,56(sp)
ffffffffc0202440:	7442                	ld	s0,48(sp)
ffffffffc0202442:	854a                	mv	a0,s2
ffffffffc0202444:	74a2                	ld	s1,40(sp)
ffffffffc0202446:	7902                	ld	s2,32(sp)
ffffffffc0202448:	69e2                	ld	s3,24(sp)
ffffffffc020244a:	6121                	addi	sp,sp,64
ffffffffc020244c:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc020244e:	49d9                	li	s3,22
ffffffffc0202450:	b74d                	j	ffffffffc02023f2 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0202452:	00003517          	auipc	a0,0x3
ffffffffc0202456:	f1e50513          	addi	a0,a0,-226 # ffffffffc0205370 <commands+0xf30>
ffffffffc020245a:	c65fd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc020245e:	70e2                	ld	ra,56(sp)
ffffffffc0202460:	7442                	ld	s0,48(sp)
ffffffffc0202462:	854a                	mv	a0,s2
ffffffffc0202464:	74a2                	ld	s1,40(sp)
ffffffffc0202466:	7902                	ld	s2,32(sp)
ffffffffc0202468:	69e2                	ld	s3,24(sp)
ffffffffc020246a:	6121                	addi	sp,sp,64
ffffffffc020246c:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020246e:	6c88                	ld	a0,24(s1)
ffffffffc0202470:	864e                	mv	a2,s3
ffffffffc0202472:	85a2                	mv	a1,s0
ffffffffc0202474:	e12ff0ef          	jal	ra,ffffffffc0201a86 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202478:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020247a:	f171                	bnez	a0,ffffffffc020243e <do_pgfault+0x86>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020247c:	00003517          	auipc	a0,0x3
ffffffffc0202480:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205348 <commands+0xf08>
ffffffffc0202484:	c3bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202488:	5971                	li	s2,-4
            goto failed;
ffffffffc020248a:	bf55                	j	ffffffffc020243e <do_pgfault+0x86>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020248c:	85a2                	mv	a1,s0
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	e8a50513          	addi	a0,a0,-374 # ffffffffc0205318 <commands+0xed8>
ffffffffc0202496:	c29fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc020249a:	5975                	li	s2,-3
        goto failed;
ffffffffc020249c:	b74d                	j	ffffffffc020243e <do_pgfault+0x86>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	ef250513          	addi	a0,a0,-270 # ffffffffc0205390 <commands+0xf50>
ffffffffc02024a6:	c19fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02024aa:	5971                	li	s2,-4
            goto failed;
ffffffffc02024ac:	bf49                	j	ffffffffc020243e <do_pgfault+0x86>

ffffffffc02024ae <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02024ae:	7135                	addi	sp,sp,-160
ffffffffc02024b0:	ed06                	sd	ra,152(sp)
ffffffffc02024b2:	e922                	sd	s0,144(sp)
ffffffffc02024b4:	e526                	sd	s1,136(sp)
ffffffffc02024b6:	e14a                	sd	s2,128(sp)
ffffffffc02024b8:	fcce                	sd	s3,120(sp)
ffffffffc02024ba:	f8d2                	sd	s4,112(sp)
ffffffffc02024bc:	f4d6                	sd	s5,104(sp)
ffffffffc02024be:	f0da                	sd	s6,96(sp)
ffffffffc02024c0:	ecde                	sd	s7,88(sp)
ffffffffc02024c2:	e8e2                	sd	s8,80(sp)
ffffffffc02024c4:	e4e6                	sd	s9,72(sp)
ffffffffc02024c6:	e0ea                	sd	s10,64(sp)
ffffffffc02024c8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02024ca:	72c010ef          	jal	ra,ffffffffc0203bf6 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02024ce:	0000f797          	auipc	a5,0xf
ffffffffc02024d2:	06278793          	addi	a5,a5,98 # ffffffffc0211530 <max_swap_offset>
ffffffffc02024d6:	6394                	ld	a3,0(a5)
ffffffffc02024d8:	010007b7          	lui	a5,0x1000
ffffffffc02024dc:	17e1                	addi	a5,a5,-8
ffffffffc02024de:	ff968713          	addi	a4,a3,-7
ffffffffc02024e2:	42e7ea63          	bltu	a5,a4,ffffffffc0202916 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02024e6:	00008797          	auipc	a5,0x8
ffffffffc02024ea:	b1a78793          	addi	a5,a5,-1254 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02024ee:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02024f0:	0000f697          	auipc	a3,0xf
ffffffffc02024f4:	f6f6bc23          	sd	a5,-136(a3) # ffffffffc0211468 <sm>
     int r = sm->init();
ffffffffc02024f8:	9702                	jalr	a4
ffffffffc02024fa:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc02024fc:	c10d                	beqz	a0,ffffffffc020251e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02024fe:	60ea                	ld	ra,152(sp)
ffffffffc0202500:	644a                	ld	s0,144(sp)
ffffffffc0202502:	855a                	mv	a0,s6
ffffffffc0202504:	64aa                	ld	s1,136(sp)
ffffffffc0202506:	690a                	ld	s2,128(sp)
ffffffffc0202508:	79e6                	ld	s3,120(sp)
ffffffffc020250a:	7a46                	ld	s4,112(sp)
ffffffffc020250c:	7aa6                	ld	s5,104(sp)
ffffffffc020250e:	7b06                	ld	s6,96(sp)
ffffffffc0202510:	6be6                	ld	s7,88(sp)
ffffffffc0202512:	6c46                	ld	s8,80(sp)
ffffffffc0202514:	6ca6                	ld	s9,72(sp)
ffffffffc0202516:	6d06                	ld	s10,64(sp)
ffffffffc0202518:	7de2                	ld	s11,56(sp)
ffffffffc020251a:	610d                	addi	sp,sp,160
ffffffffc020251c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020251e:	0000f797          	auipc	a5,0xf
ffffffffc0202522:	f4a78793          	addi	a5,a5,-182 # ffffffffc0211468 <sm>
ffffffffc0202526:	639c                	ld	a5,0(a5)
ffffffffc0202528:	00003517          	auipc	a0,0x3
ffffffffc020252c:	1a850513          	addi	a0,a0,424 # ffffffffc02056d0 <commands+0x1290>
ffffffffc0202530:	0000f417          	auipc	s0,0xf
ffffffffc0202534:	05040413          	addi	s0,s0,80 # ffffffffc0211580 <free_area>
ffffffffc0202538:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020253a:	4785                	li	a5,1
ffffffffc020253c:	0000f717          	auipc	a4,0xf
ffffffffc0202540:	f2f72a23          	sw	a5,-204(a4) # ffffffffc0211470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202544:	b7bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202548:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020254a:	2e878a63          	beq	a5,s0,ffffffffc020283e <swap_init+0x390>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020254e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202552:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202554:	8b05                	andi	a4,a4,1
ffffffffc0202556:	2e070863          	beqz	a4,ffffffffc0202846 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc020255a:	4481                	li	s1,0
ffffffffc020255c:	4901                	li	s2,0
ffffffffc020255e:	a031                	j	ffffffffc020256a <swap_init+0xbc>
ffffffffc0202560:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202564:	8b09                	andi	a4,a4,2
ffffffffc0202566:	2e070063          	beqz	a4,ffffffffc0202846 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc020256a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020256e:	679c                	ld	a5,8(a5)
ffffffffc0202570:	2905                	addiw	s2,s2,1
ffffffffc0202572:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202574:	fe8796e3          	bne	a5,s0,ffffffffc0202560 <swap_init+0xb2>
ffffffffc0202578:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020257a:	e40fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc020257e:	5b351863          	bne	a0,s3,ffffffffc0202b2e <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202582:	8626                	mv	a2,s1
ffffffffc0202584:	85ca                	mv	a1,s2
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	19250513          	addi	a0,a0,402 # ffffffffc0205718 <commands+0x12d8>
ffffffffc020258e:	b31fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202592:	f2cff0ef          	jal	ra,ffffffffc0201cbe <mm_create>
ffffffffc0202596:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202598:	50050b63          	beqz	a0,ffffffffc0202aae <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020259c:	0000f797          	auipc	a5,0xf
ffffffffc02025a0:	f0478793          	addi	a5,a5,-252 # ffffffffc02114a0 <check_mm_struct>
ffffffffc02025a4:	639c                	ld	a5,0(a5)
ffffffffc02025a6:	52079463          	bnez	a5,ffffffffc0202ace <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02025aa:	0000f797          	auipc	a5,0xf
ffffffffc02025ae:	ea678793          	addi	a5,a5,-346 # ffffffffc0211450 <boot_pgdir>
ffffffffc02025b2:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc02025b4:	0000f797          	auipc	a5,0xf
ffffffffc02025b8:	eea7b623          	sd	a0,-276(a5) # ffffffffc02114a0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02025bc:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02025be:	ec3a                	sd	a4,24(sp)
ffffffffc02025c0:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02025c2:	52079663          	bnez	a5,ffffffffc0202aee <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02025c6:	6599                	lui	a1,0x6
ffffffffc02025c8:	460d                	li	a2,3
ffffffffc02025ca:	6505                	lui	a0,0x1
ffffffffc02025cc:	f3eff0ef          	jal	ra,ffffffffc0201d0a <vma_create>
ffffffffc02025d0:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02025d2:	52050e63          	beqz	a0,ffffffffc0202b0e <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc02025d6:	855e                	mv	a0,s7
ffffffffc02025d8:	f9eff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02025dc:	00003517          	auipc	a0,0x3
ffffffffc02025e0:	17c50513          	addi	a0,a0,380 # ffffffffc0205758 <commands+0x1318>
ffffffffc02025e4:	adbfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02025e8:	018bb503          	ld	a0,24(s7)
ffffffffc02025ec:	4605                	li	a2,1
ffffffffc02025ee:	6585                	lui	a1,0x1
ffffffffc02025f0:	e0afe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02025f4:	40050d63          	beqz	a0,ffffffffc0202a0e <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02025f8:	00003517          	auipc	a0,0x3
ffffffffc02025fc:	1b050513          	addi	a0,a0,432 # ffffffffc02057a8 <commands+0x1368>
ffffffffc0202600:	0000fa17          	auipc	s4,0xf
ffffffffc0202604:	ea8a0a13          	addi	s4,s4,-344 # ffffffffc02114a8 <check_rp>
ffffffffc0202608:	ab7fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020260c:	0000fa97          	auipc	s5,0xf
ffffffffc0202610:	ebca8a93          	addi	s5,s5,-324 # ffffffffc02114c8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202614:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202616:	4505                	li	a0,1
ffffffffc0202618:	cd4fe0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc020261c:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea60>
          assert(check_rp[i] != NULL );
ffffffffc0202620:	2a050b63          	beqz	a0,ffffffffc02028d6 <swap_init+0x428>
ffffffffc0202624:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202626:	8b89                	andi	a5,a5,2
ffffffffc0202628:	28079763          	bnez	a5,ffffffffc02028b6 <swap_init+0x408>
ffffffffc020262c:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020262e:	ff5994e3          	bne	s3,s5,ffffffffc0202616 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202632:	601c                	ld	a5,0(s0)
ffffffffc0202634:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202638:	0000fd17          	auipc	s10,0xf
ffffffffc020263c:	e70d0d13          	addi	s10,s10,-400 # ffffffffc02114a8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202640:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202642:	481c                	lw	a5,16(s0)
ffffffffc0202644:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202646:	0000f797          	auipc	a5,0xf
ffffffffc020264a:	f487b123          	sd	s0,-190(a5) # ffffffffc0211588 <free_area+0x8>
ffffffffc020264e:	0000f797          	auipc	a5,0xf
ffffffffc0202652:	f287b923          	sd	s0,-206(a5) # ffffffffc0211580 <free_area>
     nr_free = 0;
ffffffffc0202656:	0000f797          	auipc	a5,0xf
ffffffffc020265a:	f207ad23          	sw	zero,-198(a5) # ffffffffc0211590 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020265e:	000d3503          	ld	a0,0(s10)
ffffffffc0202662:	4585                	li	a1,1
ffffffffc0202664:	0d21                	addi	s10,s10,8
ffffffffc0202666:	d0efe0ef          	jal	ra,ffffffffc0200b74 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020266a:	ff5d1ae3          	bne	s10,s5,ffffffffc020265e <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020266e:	01042d03          	lw	s10,16(s0)
ffffffffc0202672:	4791                	li	a5,4
ffffffffc0202674:	36fd1d63          	bne	s10,a5,ffffffffc02029ee <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202678:	00003517          	auipc	a0,0x3
ffffffffc020267c:	1b850513          	addi	a0,a0,440 # ffffffffc0205830 <commands+0x13f0>
ffffffffc0202680:	a3ffd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202684:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202686:	0000f797          	auipc	a5,0xf
ffffffffc020268a:	dc07ad23          	sw	zero,-550(a5) # ffffffffc0211460 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020268e:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202690:	0000f797          	auipc	a5,0xf
ffffffffc0202694:	dd078793          	addi	a5,a5,-560 # ffffffffc0211460 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202698:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc020269c:	4398                	lw	a4,0(a5)
ffffffffc020269e:	4585                	li	a1,1
ffffffffc02026a0:	2701                	sext.w	a4,a4
ffffffffc02026a2:	30b71663          	bne	a4,a1,ffffffffc02029ae <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02026a6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02026aa:	4394                	lw	a3,0(a5)
ffffffffc02026ac:	2681                	sext.w	a3,a3
ffffffffc02026ae:	32e69063          	bne	a3,a4,ffffffffc02029ce <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026b2:	6689                	lui	a3,0x2
ffffffffc02026b4:	462d                	li	a2,11
ffffffffc02026b6:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02026ba:	4398                	lw	a4,0(a5)
ffffffffc02026bc:	4589                	li	a1,2
ffffffffc02026be:	2701                	sext.w	a4,a4
ffffffffc02026c0:	26b71763          	bne	a4,a1,ffffffffc020292e <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02026c4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02026c8:	4394                	lw	a3,0(a5)
ffffffffc02026ca:	2681                	sext.w	a3,a3
ffffffffc02026cc:	28e69163          	bne	a3,a4,ffffffffc020294e <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026d0:	668d                	lui	a3,0x3
ffffffffc02026d2:	4631                	li	a2,12
ffffffffc02026d4:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02026d8:	4398                	lw	a4,0(a5)
ffffffffc02026da:	458d                	li	a1,3
ffffffffc02026dc:	2701                	sext.w	a4,a4
ffffffffc02026de:	28b71863          	bne	a4,a1,ffffffffc020296e <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02026e2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02026e6:	4394                	lw	a3,0(a5)
ffffffffc02026e8:	2681                	sext.w	a3,a3
ffffffffc02026ea:	2ae69263          	bne	a3,a4,ffffffffc020298e <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026ee:	6691                	lui	a3,0x4
ffffffffc02026f0:	4635                	li	a2,13
ffffffffc02026f2:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02026f6:	4398                	lw	a4,0(a5)
ffffffffc02026f8:	2701                	sext.w	a4,a4
ffffffffc02026fa:	33a71a63          	bne	a4,s10,ffffffffc0202a2e <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02026fe:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202702:	439c                	lw	a5,0(a5)
ffffffffc0202704:	2781                	sext.w	a5,a5
ffffffffc0202706:	34e79463          	bne	a5,a4,ffffffffc0202a4e <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020270a:	481c                	lw	a5,16(s0)
ffffffffc020270c:	36079163          	bnez	a5,ffffffffc0202a6e <swap_init+0x5c0>
ffffffffc0202710:	0000f797          	auipc	a5,0xf
ffffffffc0202714:	db878793          	addi	a5,a5,-584 # ffffffffc02114c8 <swap_in_seq_no>
ffffffffc0202718:	0000f717          	auipc	a4,0xf
ffffffffc020271c:	dd870713          	addi	a4,a4,-552 # ffffffffc02114f0 <swap_out_seq_no>
ffffffffc0202720:	0000f617          	auipc	a2,0xf
ffffffffc0202724:	dd060613          	addi	a2,a2,-560 # ffffffffc02114f0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202728:	56fd                	li	a3,-1
ffffffffc020272a:	c394                	sw	a3,0(a5)
ffffffffc020272c:	c314                	sw	a3,0(a4)
ffffffffc020272e:	0791                	addi	a5,a5,4
ffffffffc0202730:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202732:	fec79ce3          	bne	a5,a2,ffffffffc020272a <swap_init+0x27c>
ffffffffc0202736:	0000f697          	auipc	a3,0xf
ffffffffc020273a:	e1a68693          	addi	a3,a3,-486 # ffffffffc0211550 <check_ptep>
ffffffffc020273e:	0000f817          	auipc	a6,0xf
ffffffffc0202742:	d6a80813          	addi	a6,a6,-662 # ffffffffc02114a8 <check_rp>
ffffffffc0202746:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202748:	0000fc97          	auipc	s9,0xf
ffffffffc020274c:	d10c8c93          	addi	s9,s9,-752 # ffffffffc0211458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202750:	0000fd97          	auipc	s11,0xf
ffffffffc0202754:	d48d8d93          	addi	s11,s11,-696 # ffffffffc0211498 <pages>
ffffffffc0202758:	00004d17          	auipc	s10,0x4
ffffffffc020275c:	9b0d0d13          	addi	s10,s10,-1616 # ffffffffc0206108 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202760:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202762:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202766:	4601                	li	a2,0
ffffffffc0202768:	85e2                	mv	a1,s8
ffffffffc020276a:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020276c:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020276e:	c8cfe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc0202772:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202774:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202776:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202778:	16050f63          	beqz	a0,ffffffffc02028f6 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020277c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020277e:	0017f613          	andi	a2,a5,1
ffffffffc0202782:	10060263          	beqz	a2,ffffffffc0202886 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202786:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020278a:	078a                	slli	a5,a5,0x2
ffffffffc020278c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020278e:	10c7f863          	bleu	a2,a5,ffffffffc020289e <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202792:	000d3603          	ld	a2,0(s10)
ffffffffc0202796:	000db583          	ld	a1,0(s11)
ffffffffc020279a:	00083503          	ld	a0,0(a6)
ffffffffc020279e:	8f91                	sub	a5,a5,a2
ffffffffc02027a0:	00379613          	slli	a2,a5,0x3
ffffffffc02027a4:	97b2                	add	a5,a5,a2
ffffffffc02027a6:	078e                	slli	a5,a5,0x3
ffffffffc02027a8:	97ae                	add	a5,a5,a1
ffffffffc02027aa:	0af51e63          	bne	a0,a5,ffffffffc0202866 <swap_init+0x3b8>
ffffffffc02027ae:	6785                	lui	a5,0x1
ffffffffc02027b0:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02027b2:	6795                	lui	a5,0x5
ffffffffc02027b4:	06a1                	addi	a3,a3,8
ffffffffc02027b6:	0821                	addi	a6,a6,8
ffffffffc02027b8:	fafc14e3          	bne	s8,a5,ffffffffc0202760 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02027bc:	00003517          	auipc	a0,0x3
ffffffffc02027c0:	12c50513          	addi	a0,a0,300 # ffffffffc02058e8 <commands+0x14a8>
ffffffffc02027c4:	8fbfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc02027c8:	0000f797          	auipc	a5,0xf
ffffffffc02027cc:	ca078793          	addi	a5,a5,-864 # ffffffffc0211468 <sm>
ffffffffc02027d0:	639c                	ld	a5,0(a5)
ffffffffc02027d2:	7f9c                	ld	a5,56(a5)
ffffffffc02027d4:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02027d6:	2a051c63          	bnez	a0,ffffffffc0202a8e <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02027da:	000a3503          	ld	a0,0(s4)
ffffffffc02027de:	4585                	li	a1,1
ffffffffc02027e0:	0a21                	addi	s4,s4,8
ffffffffc02027e2:	b92fe0ef          	jal	ra,ffffffffc0200b74 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02027e6:	ff5a1ae3          	bne	s4,s5,ffffffffc02027da <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02027ea:	855e                	mv	a0,s7
ffffffffc02027ec:	e58ff0ef          	jal	ra,ffffffffc0201e44 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc02027f0:	77a2                	ld	a5,40(sp)
ffffffffc02027f2:	0000f717          	auipc	a4,0xf
ffffffffc02027f6:	d8f72f23          	sw	a5,-610(a4) # ffffffffc0211590 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02027fa:	7782                	ld	a5,32(sp)
ffffffffc02027fc:	0000f717          	auipc	a4,0xf
ffffffffc0202800:	d8f73223          	sd	a5,-636(a4) # ffffffffc0211580 <free_area>
ffffffffc0202804:	0000f797          	auipc	a5,0xf
ffffffffc0202808:	d937b223          	sd	s3,-636(a5) # ffffffffc0211588 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020280c:	00898a63          	beq	s3,s0,ffffffffc0202820 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202810:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202814:	0089b983          	ld	s3,8(s3)
ffffffffc0202818:	397d                	addiw	s2,s2,-1
ffffffffc020281a:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc020281c:	fe899ae3          	bne	s3,s0,ffffffffc0202810 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202820:	8626                	mv	a2,s1
ffffffffc0202822:	85ca                	mv	a1,s2
ffffffffc0202824:	00003517          	auipc	a0,0x3
ffffffffc0202828:	0f450513          	addi	a0,a0,244 # ffffffffc0205918 <commands+0x14d8>
ffffffffc020282c:	893fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202830:	00003517          	auipc	a0,0x3
ffffffffc0202834:	10850513          	addi	a0,a0,264 # ffffffffc0205938 <commands+0x14f8>
ffffffffc0202838:	887fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020283c:	b1c9                	j	ffffffffc02024fe <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc020283e:	4481                	li	s1,0
ffffffffc0202840:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202842:	4981                	li	s3,0
ffffffffc0202844:	bb1d                	j	ffffffffc020257a <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202846:	00003697          	auipc	a3,0x3
ffffffffc020284a:	ea268693          	addi	a3,a3,-350 # ffffffffc02056e8 <commands+0x12a8>
ffffffffc020284e:	00002617          	auipc	a2,0x2
ffffffffc0202852:	5e260613          	addi	a2,a2,1506 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202856:	0ba00593          	li	a1,186
ffffffffc020285a:	00003517          	auipc	a0,0x3
ffffffffc020285e:	e6650513          	addi	a0,a0,-410 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202862:	8a5fd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202866:	00003697          	auipc	a3,0x3
ffffffffc020286a:	05a68693          	addi	a3,a3,90 # ffffffffc02058c0 <commands+0x1480>
ffffffffc020286e:	00002617          	auipc	a2,0x2
ffffffffc0202872:	5c260613          	addi	a2,a2,1474 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202876:	0fa00593          	li	a1,250
ffffffffc020287a:	00003517          	auipc	a0,0x3
ffffffffc020287e:	e4650513          	addi	a0,a0,-442 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202882:	885fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202886:	00002617          	auipc	a2,0x2
ffffffffc020288a:	68260613          	addi	a2,a2,1666 # ffffffffc0204f08 <commands+0xac8>
ffffffffc020288e:	07000593          	li	a1,112
ffffffffc0202892:	00002517          	auipc	a0,0x2
ffffffffc0202896:	48650513          	addi	a0,a0,1158 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc020289a:	86dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020289e:	00002617          	auipc	a2,0x2
ffffffffc02028a2:	45a60613          	addi	a2,a2,1114 # ffffffffc0204cf8 <commands+0x8b8>
ffffffffc02028a6:	06500593          	li	a1,101
ffffffffc02028aa:	00002517          	auipc	a0,0x2
ffffffffc02028ae:	46e50513          	addi	a0,a0,1134 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc02028b2:	855fd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02028b6:	00003697          	auipc	a3,0x3
ffffffffc02028ba:	f3268693          	addi	a3,a3,-206 # ffffffffc02057e8 <commands+0x13a8>
ffffffffc02028be:	00002617          	auipc	a2,0x2
ffffffffc02028c2:	57260613          	addi	a2,a2,1394 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02028c6:	0db00593          	li	a1,219
ffffffffc02028ca:	00003517          	auipc	a0,0x3
ffffffffc02028ce:	df650513          	addi	a0,a0,-522 # ffffffffc02056c0 <commands+0x1280>
ffffffffc02028d2:	835fd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02028d6:	00003697          	auipc	a3,0x3
ffffffffc02028da:	efa68693          	addi	a3,a3,-262 # ffffffffc02057d0 <commands+0x1390>
ffffffffc02028de:	00002617          	auipc	a2,0x2
ffffffffc02028e2:	55260613          	addi	a2,a2,1362 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02028e6:	0da00593          	li	a1,218
ffffffffc02028ea:	00003517          	auipc	a0,0x3
ffffffffc02028ee:	dd650513          	addi	a0,a0,-554 # ffffffffc02056c0 <commands+0x1280>
ffffffffc02028f2:	815fd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02028f6:	00003697          	auipc	a3,0x3
ffffffffc02028fa:	fb268693          	addi	a3,a3,-78 # ffffffffc02058a8 <commands+0x1468>
ffffffffc02028fe:	00002617          	auipc	a2,0x2
ffffffffc0202902:	53260613          	addi	a2,a2,1330 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202906:	0f900593          	li	a1,249
ffffffffc020290a:	00003517          	auipc	a0,0x3
ffffffffc020290e:	db650513          	addi	a0,a0,-586 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202912:	ff4fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202916:	00003617          	auipc	a2,0x3
ffffffffc020291a:	d8a60613          	addi	a2,a2,-630 # ffffffffc02056a0 <commands+0x1260>
ffffffffc020291e:	02700593          	li	a1,39
ffffffffc0202922:	00003517          	auipc	a0,0x3
ffffffffc0202926:	d9e50513          	addi	a0,a0,-610 # ffffffffc02056c0 <commands+0x1280>
ffffffffc020292a:	fdcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc020292e:	00003697          	auipc	a3,0x3
ffffffffc0202932:	f3a68693          	addi	a3,a3,-198 # ffffffffc0205868 <commands+0x1428>
ffffffffc0202936:	00002617          	auipc	a2,0x2
ffffffffc020293a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020293e:	09500593          	li	a1,149
ffffffffc0202942:	00003517          	auipc	a0,0x3
ffffffffc0202946:	d7e50513          	addi	a0,a0,-642 # ffffffffc02056c0 <commands+0x1280>
ffffffffc020294a:	fbcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc020294e:	00003697          	auipc	a3,0x3
ffffffffc0202952:	f1a68693          	addi	a3,a3,-230 # ffffffffc0205868 <commands+0x1428>
ffffffffc0202956:	00002617          	auipc	a2,0x2
ffffffffc020295a:	4da60613          	addi	a2,a2,1242 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020295e:	09700593          	li	a1,151
ffffffffc0202962:	00003517          	auipc	a0,0x3
ffffffffc0202966:	d5e50513          	addi	a0,a0,-674 # ffffffffc02056c0 <commands+0x1280>
ffffffffc020296a:	f9cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc020296e:	00003697          	auipc	a3,0x3
ffffffffc0202972:	f0a68693          	addi	a3,a3,-246 # ffffffffc0205878 <commands+0x1438>
ffffffffc0202976:	00002617          	auipc	a2,0x2
ffffffffc020297a:	4ba60613          	addi	a2,a2,1210 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020297e:	09900593          	li	a1,153
ffffffffc0202982:	00003517          	auipc	a0,0x3
ffffffffc0202986:	d3e50513          	addi	a0,a0,-706 # ffffffffc02056c0 <commands+0x1280>
ffffffffc020298a:	f7cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc020298e:	00003697          	auipc	a3,0x3
ffffffffc0202992:	eea68693          	addi	a3,a3,-278 # ffffffffc0205878 <commands+0x1438>
ffffffffc0202996:	00002617          	auipc	a2,0x2
ffffffffc020299a:	49a60613          	addi	a2,a2,1178 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020299e:	09b00593          	li	a1,155
ffffffffc02029a2:	00003517          	auipc	a0,0x3
ffffffffc02029a6:	d1e50513          	addi	a0,a0,-738 # ffffffffc02056c0 <commands+0x1280>
ffffffffc02029aa:	f5cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02029ae:	00003697          	auipc	a3,0x3
ffffffffc02029b2:	eaa68693          	addi	a3,a3,-342 # ffffffffc0205858 <commands+0x1418>
ffffffffc02029b6:	00002617          	auipc	a2,0x2
ffffffffc02029ba:	47a60613          	addi	a2,a2,1146 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02029be:	09100593          	li	a1,145
ffffffffc02029c2:	00003517          	auipc	a0,0x3
ffffffffc02029c6:	cfe50513          	addi	a0,a0,-770 # ffffffffc02056c0 <commands+0x1280>
ffffffffc02029ca:	f3cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02029ce:	00003697          	auipc	a3,0x3
ffffffffc02029d2:	e8a68693          	addi	a3,a3,-374 # ffffffffc0205858 <commands+0x1418>
ffffffffc02029d6:	00002617          	auipc	a2,0x2
ffffffffc02029da:	45a60613          	addi	a2,a2,1114 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02029de:	09300593          	li	a1,147
ffffffffc02029e2:	00003517          	auipc	a0,0x3
ffffffffc02029e6:	cde50513          	addi	a0,a0,-802 # ffffffffc02056c0 <commands+0x1280>
ffffffffc02029ea:	f1cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029ee:	00003697          	auipc	a3,0x3
ffffffffc02029f2:	e1a68693          	addi	a3,a3,-486 # ffffffffc0205808 <commands+0x13c8>
ffffffffc02029f6:	00002617          	auipc	a2,0x2
ffffffffc02029fa:	43a60613          	addi	a2,a2,1082 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02029fe:	0e800593          	li	a1,232
ffffffffc0202a02:	00003517          	auipc	a0,0x3
ffffffffc0202a06:	cbe50513          	addi	a0,a0,-834 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202a0a:	efcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202a0e:	00003697          	auipc	a3,0x3
ffffffffc0202a12:	d8268693          	addi	a3,a3,-638 # ffffffffc0205790 <commands+0x1350>
ffffffffc0202a16:	00002617          	auipc	a2,0x2
ffffffffc0202a1a:	41a60613          	addi	a2,a2,1050 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202a1e:	0d500593          	li	a1,213
ffffffffc0202a22:	00003517          	auipc	a0,0x3
ffffffffc0202a26:	c9e50513          	addi	a0,a0,-866 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202a2a:	edcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a2e:	00003697          	auipc	a3,0x3
ffffffffc0202a32:	e5a68693          	addi	a3,a3,-422 # ffffffffc0205888 <commands+0x1448>
ffffffffc0202a36:	00002617          	auipc	a2,0x2
ffffffffc0202a3a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202a3e:	09d00593          	li	a1,157
ffffffffc0202a42:	00003517          	auipc	a0,0x3
ffffffffc0202a46:	c7e50513          	addi	a0,a0,-898 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202a4a:	ebcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a4e:	00003697          	auipc	a3,0x3
ffffffffc0202a52:	e3a68693          	addi	a3,a3,-454 # ffffffffc0205888 <commands+0x1448>
ffffffffc0202a56:	00002617          	auipc	a2,0x2
ffffffffc0202a5a:	3da60613          	addi	a2,a2,986 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202a5e:	09f00593          	li	a1,159
ffffffffc0202a62:	00003517          	auipc	a0,0x3
ffffffffc0202a66:	c5e50513          	addi	a0,a0,-930 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202a6a:	e9cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert( nr_free == 0);         
ffffffffc0202a6e:	00003697          	auipc	a3,0x3
ffffffffc0202a72:	e2a68693          	addi	a3,a3,-470 # ffffffffc0205898 <commands+0x1458>
ffffffffc0202a76:	00002617          	auipc	a2,0x2
ffffffffc0202a7a:	3ba60613          	addi	a2,a2,954 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202a7e:	0f100593          	li	a1,241
ffffffffc0202a82:	00003517          	auipc	a0,0x3
ffffffffc0202a86:	c3e50513          	addi	a0,a0,-962 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202a8a:	e7cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(ret==0);
ffffffffc0202a8e:	00003697          	auipc	a3,0x3
ffffffffc0202a92:	e8268693          	addi	a3,a3,-382 # ffffffffc0205910 <commands+0x14d0>
ffffffffc0202a96:	00002617          	auipc	a2,0x2
ffffffffc0202a9a:	39a60613          	addi	a2,a2,922 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202a9e:	10000593          	li	a1,256
ffffffffc0202aa2:	00003517          	auipc	a0,0x3
ffffffffc0202aa6:	c1e50513          	addi	a0,a0,-994 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202aaa:	e5cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(mm != NULL);
ffffffffc0202aae:	00003697          	auipc	a3,0x3
ffffffffc0202ab2:	96a68693          	addi	a3,a3,-1686 # ffffffffc0205418 <commands+0xfd8>
ffffffffc0202ab6:	00002617          	auipc	a2,0x2
ffffffffc0202aba:	37a60613          	addi	a2,a2,890 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202abe:	0c200593          	li	a1,194
ffffffffc0202ac2:	00003517          	auipc	a0,0x3
ffffffffc0202ac6:	bfe50513          	addi	a0,a0,-1026 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202aca:	e3cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202ace:	00003697          	auipc	a3,0x3
ffffffffc0202ad2:	c7268693          	addi	a3,a3,-910 # ffffffffc0205740 <commands+0x1300>
ffffffffc0202ad6:	00002617          	auipc	a2,0x2
ffffffffc0202ada:	35a60613          	addi	a2,a2,858 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202ade:	0c500593          	li	a1,197
ffffffffc0202ae2:	00003517          	auipc	a0,0x3
ffffffffc0202ae6:	bde50513          	addi	a0,a0,-1058 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202aea:	e1cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202aee:	00003697          	auipc	a3,0x3
ffffffffc0202af2:	ada68693          	addi	a3,a3,-1318 # ffffffffc02055c8 <commands+0x1188>
ffffffffc0202af6:	00002617          	auipc	a2,0x2
ffffffffc0202afa:	33a60613          	addi	a2,a2,826 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202afe:	0ca00593          	li	a1,202
ffffffffc0202b02:	00003517          	auipc	a0,0x3
ffffffffc0202b06:	bbe50513          	addi	a0,a0,-1090 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202b0a:	dfcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(vma != NULL);
ffffffffc0202b0e:	00003697          	auipc	a3,0x3
ffffffffc0202b12:	b3268693          	addi	a3,a3,-1230 # ffffffffc0205640 <commands+0x1200>
ffffffffc0202b16:	00002617          	auipc	a2,0x2
ffffffffc0202b1a:	31a60613          	addi	a2,a2,794 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202b1e:	0cd00593          	li	a1,205
ffffffffc0202b22:	00003517          	auipc	a0,0x3
ffffffffc0202b26:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202b2a:	ddcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202b2e:	00003697          	auipc	a3,0x3
ffffffffc0202b32:	bca68693          	addi	a3,a3,-1078 # ffffffffc02056f8 <commands+0x12b8>
ffffffffc0202b36:	00002617          	auipc	a2,0x2
ffffffffc0202b3a:	2fa60613          	addi	a2,a2,762 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202b3e:	0bd00593          	li	a1,189
ffffffffc0202b42:	00003517          	auipc	a0,0x3
ffffffffc0202b46:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202b4a:	dbcfd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202b4e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202b4e:	0000f797          	auipc	a5,0xf
ffffffffc0202b52:	91a78793          	addi	a5,a5,-1766 # ffffffffc0211468 <sm>
ffffffffc0202b56:	639c                	ld	a5,0(a5)
ffffffffc0202b58:	0107b303          	ld	t1,16(a5)
ffffffffc0202b5c:	8302                	jr	t1

ffffffffc0202b5e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202b5e:	0000f797          	auipc	a5,0xf
ffffffffc0202b62:	90a78793          	addi	a5,a5,-1782 # ffffffffc0211468 <sm>
ffffffffc0202b66:	639c                	ld	a5,0(a5)
ffffffffc0202b68:	0207b303          	ld	t1,32(a5)
ffffffffc0202b6c:	8302                	jr	t1

ffffffffc0202b6e <swap_out>:
{
ffffffffc0202b6e:	711d                	addi	sp,sp,-96
ffffffffc0202b70:	ec86                	sd	ra,88(sp)
ffffffffc0202b72:	e8a2                	sd	s0,80(sp)
ffffffffc0202b74:	e4a6                	sd	s1,72(sp)
ffffffffc0202b76:	e0ca                	sd	s2,64(sp)
ffffffffc0202b78:	fc4e                	sd	s3,56(sp)
ffffffffc0202b7a:	f852                	sd	s4,48(sp)
ffffffffc0202b7c:	f456                	sd	s5,40(sp)
ffffffffc0202b7e:	f05a                	sd	s6,32(sp)
ffffffffc0202b80:	ec5e                	sd	s7,24(sp)
ffffffffc0202b82:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202b84:	cde9                	beqz	a1,ffffffffc0202c5e <swap_out+0xf0>
ffffffffc0202b86:	8ab2                	mv	s5,a2
ffffffffc0202b88:	892a                	mv	s2,a0
ffffffffc0202b8a:	8a2e                	mv	s4,a1
ffffffffc0202b8c:	4401                	li	s0,0
ffffffffc0202b8e:	0000f997          	auipc	s3,0xf
ffffffffc0202b92:	8da98993          	addi	s3,s3,-1830 # ffffffffc0211468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b96:	00003b17          	auipc	s6,0x3
ffffffffc0202b9a:	e22b0b13          	addi	s6,s6,-478 # ffffffffc02059b8 <commands+0x1578>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202b9e:	00003b97          	auipc	s7,0x3
ffffffffc0202ba2:	e02b8b93          	addi	s7,s7,-510 # ffffffffc02059a0 <commands+0x1560>
ffffffffc0202ba6:	a825                	j	ffffffffc0202bde <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ba8:	67a2                	ld	a5,8(sp)
ffffffffc0202baa:	8626                	mv	a2,s1
ffffffffc0202bac:	85a2                	mv	a1,s0
ffffffffc0202bae:	63b4                	ld	a3,64(a5)
ffffffffc0202bb0:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202bb2:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202bb4:	82b1                	srli	a3,a3,0xc
ffffffffc0202bb6:	0685                	addi	a3,a3,1
ffffffffc0202bb8:	d06fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202bbc:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202bbe:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202bc0:	613c                	ld	a5,64(a0)
ffffffffc0202bc2:	83b1                	srli	a5,a5,0xc
ffffffffc0202bc4:	0785                	addi	a5,a5,1
ffffffffc0202bc6:	07a2                	slli	a5,a5,0x8
ffffffffc0202bc8:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202bcc:	fa9fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202bd0:	01893503          	ld	a0,24(s2)
ffffffffc0202bd4:	85a6                	mv	a1,s1
ffffffffc0202bd6:	eabfe0ef          	jal	ra,ffffffffc0201a80 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202bda:	048a0d63          	beq	s4,s0,ffffffffc0202c34 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202bde:	0009b783          	ld	a5,0(s3)
ffffffffc0202be2:	8656                	mv	a2,s5
ffffffffc0202be4:	002c                	addi	a1,sp,8
ffffffffc0202be6:	7b9c                	ld	a5,48(a5)
ffffffffc0202be8:	854a                	mv	a0,s2
ffffffffc0202bea:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202bec:	e12d                	bnez	a0,ffffffffc0202c4e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202bee:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bf0:	01893503          	ld	a0,24(s2)
ffffffffc0202bf4:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202bf6:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bf8:	85a6                	mv	a1,s1
ffffffffc0202bfa:	800fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202bfe:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202c00:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202c02:	8b85                	andi	a5,a5,1
ffffffffc0202c04:	cfb9                	beqz	a5,ffffffffc0202c62 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202c06:	65a2                	ld	a1,8(sp)
ffffffffc0202c08:	61bc                	ld	a5,64(a1)
ffffffffc0202c0a:	83b1                	srli	a5,a5,0xc
ffffffffc0202c0c:	00178513          	addi	a0,a5,1
ffffffffc0202c10:	0522                	slli	a0,a0,0x8
ffffffffc0202c12:	0c2010ef          	jal	ra,ffffffffc0203cd4 <swapfs_write>
ffffffffc0202c16:	d949                	beqz	a0,ffffffffc0202ba8 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202c18:	855e                	mv	a0,s7
ffffffffc0202c1a:	ca4fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202c1e:	0009b783          	ld	a5,0(s3)
ffffffffc0202c22:	6622                	ld	a2,8(sp)
ffffffffc0202c24:	4681                	li	a3,0
ffffffffc0202c26:	739c                	ld	a5,32(a5)
ffffffffc0202c28:	85a6                	mv	a1,s1
ffffffffc0202c2a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202c2c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202c2e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202c30:	fa8a17e3          	bne	s4,s0,ffffffffc0202bde <swap_out+0x70>
}
ffffffffc0202c34:	8522                	mv	a0,s0
ffffffffc0202c36:	60e6                	ld	ra,88(sp)
ffffffffc0202c38:	6446                	ld	s0,80(sp)
ffffffffc0202c3a:	64a6                	ld	s1,72(sp)
ffffffffc0202c3c:	6906                	ld	s2,64(sp)
ffffffffc0202c3e:	79e2                	ld	s3,56(sp)
ffffffffc0202c40:	7a42                	ld	s4,48(sp)
ffffffffc0202c42:	7aa2                	ld	s5,40(sp)
ffffffffc0202c44:	7b02                	ld	s6,32(sp)
ffffffffc0202c46:	6be2                	ld	s7,24(sp)
ffffffffc0202c48:	6c42                	ld	s8,16(sp)
ffffffffc0202c4a:	6125                	addi	sp,sp,96
ffffffffc0202c4c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202c4e:	85a2                	mv	a1,s0
ffffffffc0202c50:	00003517          	auipc	a0,0x3
ffffffffc0202c54:	d0850513          	addi	a0,a0,-760 # ffffffffc0205958 <commands+0x1518>
ffffffffc0202c58:	c66fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202c5c:	bfe1                	j	ffffffffc0202c34 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202c5e:	4401                	li	s0,0
ffffffffc0202c60:	bfd1                	j	ffffffffc0202c34 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202c62:	00003697          	auipc	a3,0x3
ffffffffc0202c66:	d2668693          	addi	a3,a3,-730 # ffffffffc0205988 <commands+0x1548>
ffffffffc0202c6a:	00002617          	auipc	a2,0x2
ffffffffc0202c6e:	1c660613          	addi	a2,a2,454 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202c72:	06600593          	li	a1,102
ffffffffc0202c76:	00003517          	auipc	a0,0x3
ffffffffc0202c7a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202c7e:	c88fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202c82 <swap_in>:
{
ffffffffc0202c82:	7179                	addi	sp,sp,-48
ffffffffc0202c84:	e84a                	sd	s2,16(sp)
ffffffffc0202c86:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202c88:	4505                	li	a0,1
{
ffffffffc0202c8a:	ec26                	sd	s1,24(sp)
ffffffffc0202c8c:	e44e                	sd	s3,8(sp)
ffffffffc0202c8e:	f406                	sd	ra,40(sp)
ffffffffc0202c90:	f022                	sd	s0,32(sp)
ffffffffc0202c92:	84ae                	mv	s1,a1
ffffffffc0202c94:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202c96:	e57fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
     assert(result!=NULL);
ffffffffc0202c9a:	c129                	beqz	a0,ffffffffc0202cdc <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202c9c:	842a                	mv	s0,a0
ffffffffc0202c9e:	01893503          	ld	a0,24(s2)
ffffffffc0202ca2:	4601                	li	a2,0
ffffffffc0202ca4:	85a6                	mv	a1,s1
ffffffffc0202ca6:	f55fd0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc0202caa:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202cac:	6108                	ld	a0,0(a0)
ffffffffc0202cae:	85a2                	mv	a1,s0
ffffffffc0202cb0:	77f000ef          	jal	ra,ffffffffc0203c2e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202cb4:	00093583          	ld	a1,0(s2)
ffffffffc0202cb8:	8626                	mv	a2,s1
ffffffffc0202cba:	00003517          	auipc	a0,0x3
ffffffffc0202cbe:	9a650513          	addi	a0,a0,-1626 # ffffffffc0205660 <commands+0x1220>
ffffffffc0202cc2:	81a1                	srli	a1,a1,0x8
ffffffffc0202cc4:	bfafd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0202cc8:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202cca:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202cce:	7402                	ld	s0,32(sp)
ffffffffc0202cd0:	64e2                	ld	s1,24(sp)
ffffffffc0202cd2:	6942                	ld	s2,16(sp)
ffffffffc0202cd4:	69a2                	ld	s3,8(sp)
ffffffffc0202cd6:	4501                	li	a0,0
ffffffffc0202cd8:	6145                	addi	sp,sp,48
ffffffffc0202cda:	8082                	ret
     assert(result!=NULL);
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	97468693          	addi	a3,a3,-1676 # ffffffffc0205650 <commands+0x1210>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	14c60613          	addi	a2,a2,332 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0202cec:	07c00593          	li	a1,124
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	9d050513          	addi	a0,a0,-1584 # ffffffffc02056c0 <commands+0x1280>
ffffffffc0202cf8:	c0efd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202cfc <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202cfc:	0000f797          	auipc	a5,0xf
ffffffffc0202d00:	88478793          	addi	a5,a5,-1916 # ffffffffc0211580 <free_area>
ffffffffc0202d04:	e79c                	sd	a5,8(a5)
ffffffffc0202d06:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202d08:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202d0c:	8082                	ret

ffffffffc0202d0e <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202d0e:	0000f517          	auipc	a0,0xf
ffffffffc0202d12:	88256503          	lwu	a0,-1918(a0) # ffffffffc0211590 <free_area+0x10>
ffffffffc0202d16:	8082                	ret

ffffffffc0202d18 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202d18:	715d                	addi	sp,sp,-80
ffffffffc0202d1a:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0202d1c:	0000f917          	auipc	s2,0xf
ffffffffc0202d20:	86490913          	addi	s2,s2,-1948 # ffffffffc0211580 <free_area>
ffffffffc0202d24:	00893783          	ld	a5,8(s2)
ffffffffc0202d28:	e486                	sd	ra,72(sp)
ffffffffc0202d2a:	e0a2                	sd	s0,64(sp)
ffffffffc0202d2c:	fc26                	sd	s1,56(sp)
ffffffffc0202d2e:	f44e                	sd	s3,40(sp)
ffffffffc0202d30:	f052                	sd	s4,32(sp)
ffffffffc0202d32:	ec56                	sd	s5,24(sp)
ffffffffc0202d34:	e85a                	sd	s6,16(sp)
ffffffffc0202d36:	e45e                	sd	s7,8(sp)
ffffffffc0202d38:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d3a:	31278f63          	beq	a5,s2,ffffffffc0203058 <default_check+0x340>
ffffffffc0202d3e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202d42:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202d44:	8b05                	andi	a4,a4,1
ffffffffc0202d46:	30070d63          	beqz	a4,ffffffffc0203060 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0202d4a:	4401                	li	s0,0
ffffffffc0202d4c:	4481                	li	s1,0
ffffffffc0202d4e:	a031                	j	ffffffffc0202d5a <default_check+0x42>
ffffffffc0202d50:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202d54:	8b09                	andi	a4,a4,2
ffffffffc0202d56:	30070563          	beqz	a4,ffffffffc0203060 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0202d5a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d5e:	679c                	ld	a5,8(a5)
ffffffffc0202d60:	2485                	addiw	s1,s1,1
ffffffffc0202d62:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d64:	ff2796e3          	bne	a5,s2,ffffffffc0202d50 <default_check+0x38>
ffffffffc0202d68:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0202d6a:	e51fd0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202d6e:	75351963          	bne	a0,s3,ffffffffc02034c0 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202d72:	4505                	li	a0,1
ffffffffc0202d74:	d79fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202d78:	8a2a                	mv	s4,a0
ffffffffc0202d7a:	48050363          	beqz	a0,ffffffffc0203200 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202d7e:	4505                	li	a0,1
ffffffffc0202d80:	d6dfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202d84:	89aa                	mv	s3,a0
ffffffffc0202d86:	74050d63          	beqz	a0,ffffffffc02034e0 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202d8a:	4505                	li	a0,1
ffffffffc0202d8c:	d61fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202d90:	8aaa                	mv	s5,a0
ffffffffc0202d92:	4e050763          	beqz	a0,ffffffffc0203280 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202d96:	2f3a0563          	beq	s4,s3,ffffffffc0203080 <default_check+0x368>
ffffffffc0202d9a:	2eaa0363          	beq	s4,a0,ffffffffc0203080 <default_check+0x368>
ffffffffc0202d9e:	2ea98163          	beq	s3,a0,ffffffffc0203080 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202da2:	000a2783          	lw	a5,0(s4)
ffffffffc0202da6:	2e079d63          	bnez	a5,ffffffffc02030a0 <default_check+0x388>
ffffffffc0202daa:	0009a783          	lw	a5,0(s3)
ffffffffc0202dae:	2e079963          	bnez	a5,ffffffffc02030a0 <default_check+0x388>
ffffffffc0202db2:	411c                	lw	a5,0(a0)
ffffffffc0202db4:	2e079663          	bnez	a5,ffffffffc02030a0 <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202db8:	0000e797          	auipc	a5,0xe
ffffffffc0202dbc:	6e078793          	addi	a5,a5,1760 # ffffffffc0211498 <pages>
ffffffffc0202dc0:	639c                	ld	a5,0(a5)
ffffffffc0202dc2:	00002717          	auipc	a4,0x2
ffffffffc0202dc6:	eb670713          	addi	a4,a4,-330 # ffffffffc0204c78 <commands+0x838>
ffffffffc0202dca:	630c                	ld	a1,0(a4)
ffffffffc0202dcc:	40fa0733          	sub	a4,s4,a5
ffffffffc0202dd0:	870d                	srai	a4,a4,0x3
ffffffffc0202dd2:	02b70733          	mul	a4,a4,a1
ffffffffc0202dd6:	00003697          	auipc	a3,0x3
ffffffffc0202dda:	33268693          	addi	a3,a3,818 # ffffffffc0206108 <nbase>
ffffffffc0202dde:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202de0:	0000e697          	auipc	a3,0xe
ffffffffc0202de4:	67868693          	addi	a3,a3,1656 # ffffffffc0211458 <npage>
ffffffffc0202de8:	6294                	ld	a3,0(a3)
ffffffffc0202dea:	06b2                	slli	a3,a3,0xc
ffffffffc0202dec:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202dee:	0732                	slli	a4,a4,0xc
ffffffffc0202df0:	2cd77863          	bleu	a3,a4,ffffffffc02030c0 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202df4:	40f98733          	sub	a4,s3,a5
ffffffffc0202df8:	870d                	srai	a4,a4,0x3
ffffffffc0202dfa:	02b70733          	mul	a4,a4,a1
ffffffffc0202dfe:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e00:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202e02:	4ed77f63          	bleu	a3,a4,ffffffffc0203300 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e06:	40f507b3          	sub	a5,a0,a5
ffffffffc0202e0a:	878d                	srai	a5,a5,0x3
ffffffffc0202e0c:	02b787b3          	mul	a5,a5,a1
ffffffffc0202e10:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e12:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202e14:	34d7f663          	bleu	a3,a5,ffffffffc0203160 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0202e18:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202e1a:	00093c03          	ld	s8,0(s2)
ffffffffc0202e1e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0202e22:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0202e26:	0000e797          	auipc	a5,0xe
ffffffffc0202e2a:	7727b123          	sd	s2,1890(a5) # ffffffffc0211588 <free_area+0x8>
ffffffffc0202e2e:	0000e797          	auipc	a5,0xe
ffffffffc0202e32:	7527b923          	sd	s2,1874(a5) # ffffffffc0211580 <free_area>
    nr_free = 0;
ffffffffc0202e36:	0000e797          	auipc	a5,0xe
ffffffffc0202e3a:	7407ad23          	sw	zero,1882(a5) # ffffffffc0211590 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202e3e:	caffd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202e42:	2e051f63          	bnez	a0,ffffffffc0203140 <default_check+0x428>
    free_page(p0);
ffffffffc0202e46:	4585                	li	a1,1
ffffffffc0202e48:	8552                	mv	a0,s4
ffffffffc0202e4a:	d2bfd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p1);
ffffffffc0202e4e:	4585                	li	a1,1
ffffffffc0202e50:	854e                	mv	a0,s3
ffffffffc0202e52:	d23fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc0202e56:	4585                	li	a1,1
ffffffffc0202e58:	8556                	mv	a0,s5
ffffffffc0202e5a:	d1bfd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(nr_free == 3);
ffffffffc0202e5e:	01092703          	lw	a4,16(s2)
ffffffffc0202e62:	478d                	li	a5,3
ffffffffc0202e64:	2af71e63          	bne	a4,a5,ffffffffc0203120 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e68:	4505                	li	a0,1
ffffffffc0202e6a:	c83fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202e6e:	89aa                	mv	s3,a0
ffffffffc0202e70:	28050863          	beqz	a0,ffffffffc0203100 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202e74:	4505                	li	a0,1
ffffffffc0202e76:	c77fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202e7a:	8aaa                	mv	s5,a0
ffffffffc0202e7c:	3e050263          	beqz	a0,ffffffffc0203260 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e80:	4505                	li	a0,1
ffffffffc0202e82:	c6bfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202e86:	8a2a                	mv	s4,a0
ffffffffc0202e88:	3a050c63          	beqz	a0,ffffffffc0203240 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0202e8c:	4505                	li	a0,1
ffffffffc0202e8e:	c5ffd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202e92:	38051763          	bnez	a0,ffffffffc0203220 <default_check+0x508>
    free_page(p0);
ffffffffc0202e96:	4585                	li	a1,1
ffffffffc0202e98:	854e                	mv	a0,s3
ffffffffc0202e9a:	cdbfd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202e9e:	00893783          	ld	a5,8(s2)
ffffffffc0202ea2:	23278f63          	beq	a5,s2,ffffffffc02030e0 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0202ea6:	4505                	li	a0,1
ffffffffc0202ea8:	c45fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202eac:	32a99a63          	bne	s3,a0,ffffffffc02031e0 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0202eb0:	4505                	li	a0,1
ffffffffc0202eb2:	c3bfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202eb6:	30051563          	bnez	a0,ffffffffc02031c0 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0202eba:	01092783          	lw	a5,16(s2)
ffffffffc0202ebe:	2e079163          	bnez	a5,ffffffffc02031a0 <default_check+0x488>
    free_page(p);
ffffffffc0202ec2:	854e                	mv	a0,s3
ffffffffc0202ec4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202ec6:	0000e797          	auipc	a5,0xe
ffffffffc0202eca:	6b87bd23          	sd	s8,1722(a5) # ffffffffc0211580 <free_area>
ffffffffc0202ece:	0000e797          	auipc	a5,0xe
ffffffffc0202ed2:	6b77bd23          	sd	s7,1722(a5) # ffffffffc0211588 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0202ed6:	0000e797          	auipc	a5,0xe
ffffffffc0202eda:	6b67ad23          	sw	s6,1722(a5) # ffffffffc0211590 <free_area+0x10>
    free_page(p);
ffffffffc0202ede:	c97fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p1);
ffffffffc0202ee2:	4585                	li	a1,1
ffffffffc0202ee4:	8556                	mv	a0,s5
ffffffffc0202ee6:	c8ffd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc0202eea:	4585                	li	a1,1
ffffffffc0202eec:	8552                	mv	a0,s4
ffffffffc0202eee:	c87fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202ef2:	4515                	li	a0,5
ffffffffc0202ef4:	bf9fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202ef8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202efa:	28050363          	beqz	a0,ffffffffc0203180 <default_check+0x468>
ffffffffc0202efe:	651c                	ld	a5,8(a0)
ffffffffc0202f00:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202f02:	8b85                	andi	a5,a5,1
ffffffffc0202f04:	54079e63          	bnez	a5,ffffffffc0203460 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202f08:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202f0a:	00093b03          	ld	s6,0(s2)
ffffffffc0202f0e:	00893a83          	ld	s5,8(s2)
ffffffffc0202f12:	0000e797          	auipc	a5,0xe
ffffffffc0202f16:	6727b723          	sd	s2,1646(a5) # ffffffffc0211580 <free_area>
ffffffffc0202f1a:	0000e797          	auipc	a5,0xe
ffffffffc0202f1e:	6727b723          	sd	s2,1646(a5) # ffffffffc0211588 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0202f22:	bcbfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202f26:	50051d63          	bnez	a0,ffffffffc0203440 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202f2a:	09098a13          	addi	s4,s3,144
ffffffffc0202f2e:	8552                	mv	a0,s4
ffffffffc0202f30:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202f32:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0202f36:	0000e797          	auipc	a5,0xe
ffffffffc0202f3a:	6407ad23          	sw	zero,1626(a5) # ffffffffc0211590 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202f3e:	c37fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202f42:	4511                	li	a0,4
ffffffffc0202f44:	ba9fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202f48:	4c051c63          	bnez	a0,ffffffffc0203420 <default_check+0x708>
ffffffffc0202f4c:	0989b783          	ld	a5,152(s3)
ffffffffc0202f50:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202f52:	8b85                	andi	a5,a5,1
ffffffffc0202f54:	4a078663          	beqz	a5,ffffffffc0203400 <default_check+0x6e8>
ffffffffc0202f58:	0a89a703          	lw	a4,168(s3)
ffffffffc0202f5c:	478d                	li	a5,3
ffffffffc0202f5e:	4af71163          	bne	a4,a5,ffffffffc0203400 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202f62:	450d                	li	a0,3
ffffffffc0202f64:	b89fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202f68:	8c2a                	mv	s8,a0
ffffffffc0202f6a:	46050b63          	beqz	a0,ffffffffc02033e0 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0202f6e:	4505                	li	a0,1
ffffffffc0202f70:	b7dfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202f74:	44051663          	bnez	a0,ffffffffc02033c0 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0202f78:	438a1463          	bne	s4,s8,ffffffffc02033a0 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202f7c:	4585                	li	a1,1
ffffffffc0202f7e:	854e                	mv	a0,s3
ffffffffc0202f80:	bf5fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_pages(p1, 3);
ffffffffc0202f84:	458d                	li	a1,3
ffffffffc0202f86:	8552                	mv	a0,s4
ffffffffc0202f88:	bedfd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
ffffffffc0202f8c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202f90:	04898c13          	addi	s8,s3,72
ffffffffc0202f94:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202f96:	8b85                	andi	a5,a5,1
ffffffffc0202f98:	3e078463          	beqz	a5,ffffffffc0203380 <default_check+0x668>
ffffffffc0202f9c:	0189a703          	lw	a4,24(s3)
ffffffffc0202fa0:	4785                	li	a5,1
ffffffffc0202fa2:	3cf71f63          	bne	a4,a5,ffffffffc0203380 <default_check+0x668>
ffffffffc0202fa6:	008a3783          	ld	a5,8(s4)
ffffffffc0202faa:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202fac:	8b85                	andi	a5,a5,1
ffffffffc0202fae:	3a078963          	beqz	a5,ffffffffc0203360 <default_check+0x648>
ffffffffc0202fb2:	018a2703          	lw	a4,24(s4)
ffffffffc0202fb6:	478d                	li	a5,3
ffffffffc0202fb8:	3af71463          	bne	a4,a5,ffffffffc0203360 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202fbc:	4505                	li	a0,1
ffffffffc0202fbe:	b2ffd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202fc2:	36a99f63          	bne	s3,a0,ffffffffc0203340 <default_check+0x628>
    free_page(p0);
ffffffffc0202fc6:	4585                	li	a1,1
ffffffffc0202fc8:	badfd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202fcc:	4509                	li	a0,2
ffffffffc0202fce:	b1ffd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202fd2:	34aa1763          	bne	s4,a0,ffffffffc0203320 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0202fd6:	4589                	li	a1,2
ffffffffc0202fd8:	b9dfd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc0202fdc:	4585                	li	a1,1
ffffffffc0202fde:	8562                	mv	a0,s8
ffffffffc0202fe0:	b95fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202fe4:	4515                	li	a0,5
ffffffffc0202fe6:	b07fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202fea:	89aa                	mv	s3,a0
ffffffffc0202fec:	48050a63          	beqz	a0,ffffffffc0203480 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0202ff0:	4505                	li	a0,1
ffffffffc0202ff2:	afbfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202ff6:	2e051563          	bnez	a0,ffffffffc02032e0 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0202ffa:	01092783          	lw	a5,16(s2)
ffffffffc0202ffe:	2c079163          	bnez	a5,ffffffffc02032c0 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0203002:	4595                	li	a1,5
ffffffffc0203004:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0203006:	0000e797          	auipc	a5,0xe
ffffffffc020300a:	5977a523          	sw	s7,1418(a5) # ffffffffc0211590 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020300e:	0000e797          	auipc	a5,0xe
ffffffffc0203012:	5767b923          	sd	s6,1394(a5) # ffffffffc0211580 <free_area>
ffffffffc0203016:	0000e797          	auipc	a5,0xe
ffffffffc020301a:	5757b923          	sd	s5,1394(a5) # ffffffffc0211588 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020301e:	b57fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return listelm->next;
ffffffffc0203022:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203026:	01278963          	beq	a5,s2,ffffffffc0203038 <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020302a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020302e:	679c                	ld	a5,8(a5)
ffffffffc0203030:	34fd                	addiw	s1,s1,-1
ffffffffc0203032:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203034:	ff279be3          	bne	a5,s2,ffffffffc020302a <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0203038:	26049463          	bnez	s1,ffffffffc02032a0 <default_check+0x588>
    assert(total == 0);
ffffffffc020303c:	46041263          	bnez	s0,ffffffffc02034a0 <default_check+0x788>
}
ffffffffc0203040:	60a6                	ld	ra,72(sp)
ffffffffc0203042:	6406                	ld	s0,64(sp)
ffffffffc0203044:	74e2                	ld	s1,56(sp)
ffffffffc0203046:	7942                	ld	s2,48(sp)
ffffffffc0203048:	79a2                	ld	s3,40(sp)
ffffffffc020304a:	7a02                	ld	s4,32(sp)
ffffffffc020304c:	6ae2                	ld	s5,24(sp)
ffffffffc020304e:	6b42                	ld	s6,16(sp)
ffffffffc0203050:	6ba2                	ld	s7,8(sp)
ffffffffc0203052:	6c02                	ld	s8,0(sp)
ffffffffc0203054:	6161                	addi	sp,sp,80
ffffffffc0203056:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203058:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020305a:	4401                	li	s0,0
ffffffffc020305c:	4481                	li	s1,0
ffffffffc020305e:	b331                	j	ffffffffc0202d6a <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203060:	00002697          	auipc	a3,0x2
ffffffffc0203064:	68868693          	addi	a3,a3,1672 # ffffffffc02056e8 <commands+0x12a8>
ffffffffc0203068:	00002617          	auipc	a2,0x2
ffffffffc020306c:	dc860613          	addi	a2,a2,-568 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203070:	0f000593          	li	a1,240
ffffffffc0203074:	00003517          	auipc	a0,0x3
ffffffffc0203078:	98450513          	addi	a0,a0,-1660 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020307c:	88afd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203080:	00003697          	auipc	a3,0x3
ffffffffc0203084:	9f068693          	addi	a3,a3,-1552 # ffffffffc0205a70 <commands+0x1630>
ffffffffc0203088:	00002617          	auipc	a2,0x2
ffffffffc020308c:	da860613          	addi	a2,a2,-600 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203090:	0bd00593          	li	a1,189
ffffffffc0203094:	00003517          	auipc	a0,0x3
ffffffffc0203098:	96450513          	addi	a0,a0,-1692 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020309c:	86afd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02030a0:	00003697          	auipc	a3,0x3
ffffffffc02030a4:	9f868693          	addi	a3,a3,-1544 # ffffffffc0205a98 <commands+0x1658>
ffffffffc02030a8:	00002617          	auipc	a2,0x2
ffffffffc02030ac:	d8860613          	addi	a2,a2,-632 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02030b0:	0be00593          	li	a1,190
ffffffffc02030b4:	00003517          	auipc	a0,0x3
ffffffffc02030b8:	94450513          	addi	a0,a0,-1724 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02030bc:	84afd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02030c0:	00003697          	auipc	a3,0x3
ffffffffc02030c4:	a1868693          	addi	a3,a3,-1512 # ffffffffc0205ad8 <commands+0x1698>
ffffffffc02030c8:	00002617          	auipc	a2,0x2
ffffffffc02030cc:	d6860613          	addi	a2,a2,-664 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02030d0:	0c000593          	li	a1,192
ffffffffc02030d4:	00003517          	auipc	a0,0x3
ffffffffc02030d8:	92450513          	addi	a0,a0,-1756 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02030dc:	82afd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02030e0:	00003697          	auipc	a3,0x3
ffffffffc02030e4:	a8068693          	addi	a3,a3,-1408 # ffffffffc0205b60 <commands+0x1720>
ffffffffc02030e8:	00002617          	auipc	a2,0x2
ffffffffc02030ec:	d4860613          	addi	a2,a2,-696 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02030f0:	0d900593          	li	a1,217
ffffffffc02030f4:	00003517          	auipc	a0,0x3
ffffffffc02030f8:	90450513          	addi	a0,a0,-1788 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02030fc:	80afd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203100:	00003697          	auipc	a3,0x3
ffffffffc0203104:	91068693          	addi	a3,a3,-1776 # ffffffffc0205a10 <commands+0x15d0>
ffffffffc0203108:	00002617          	auipc	a2,0x2
ffffffffc020310c:	d2860613          	addi	a2,a2,-728 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203110:	0d200593          	li	a1,210
ffffffffc0203114:	00003517          	auipc	a0,0x3
ffffffffc0203118:	8e450513          	addi	a0,a0,-1820 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020311c:	febfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 3);
ffffffffc0203120:	00003697          	auipc	a3,0x3
ffffffffc0203124:	a3068693          	addi	a3,a3,-1488 # ffffffffc0205b50 <commands+0x1710>
ffffffffc0203128:	00002617          	auipc	a2,0x2
ffffffffc020312c:	d0860613          	addi	a2,a2,-760 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203130:	0d000593          	li	a1,208
ffffffffc0203134:	00003517          	auipc	a0,0x3
ffffffffc0203138:	8c450513          	addi	a0,a0,-1852 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020313c:	fcbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203140:	00003697          	auipc	a3,0x3
ffffffffc0203144:	9f868693          	addi	a3,a3,-1544 # ffffffffc0205b38 <commands+0x16f8>
ffffffffc0203148:	00002617          	auipc	a2,0x2
ffffffffc020314c:	ce860613          	addi	a2,a2,-792 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203150:	0cb00593          	li	a1,203
ffffffffc0203154:	00003517          	auipc	a0,0x3
ffffffffc0203158:	8a450513          	addi	a0,a0,-1884 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020315c:	fabfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203160:	00003697          	auipc	a3,0x3
ffffffffc0203164:	9b868693          	addi	a3,a3,-1608 # ffffffffc0205b18 <commands+0x16d8>
ffffffffc0203168:	00002617          	auipc	a2,0x2
ffffffffc020316c:	cc860613          	addi	a2,a2,-824 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203170:	0c200593          	li	a1,194
ffffffffc0203174:	00003517          	auipc	a0,0x3
ffffffffc0203178:	88450513          	addi	a0,a0,-1916 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020317c:	f8bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != NULL);
ffffffffc0203180:	00003697          	auipc	a3,0x3
ffffffffc0203184:	a1868693          	addi	a3,a3,-1512 # ffffffffc0205b98 <commands+0x1758>
ffffffffc0203188:	00002617          	auipc	a2,0x2
ffffffffc020318c:	ca860613          	addi	a2,a2,-856 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203190:	0f800593          	li	a1,248
ffffffffc0203194:	00003517          	auipc	a0,0x3
ffffffffc0203198:	86450513          	addi	a0,a0,-1948 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020319c:	f6bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc02031a0:	00002697          	auipc	a3,0x2
ffffffffc02031a4:	6f868693          	addi	a3,a3,1784 # ffffffffc0205898 <commands+0x1458>
ffffffffc02031a8:	00002617          	auipc	a2,0x2
ffffffffc02031ac:	c8860613          	addi	a2,a2,-888 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02031b0:	0df00593          	li	a1,223
ffffffffc02031b4:	00003517          	auipc	a0,0x3
ffffffffc02031b8:	84450513          	addi	a0,a0,-1980 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02031bc:	f4bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02031c0:	00003697          	auipc	a3,0x3
ffffffffc02031c4:	97868693          	addi	a3,a3,-1672 # ffffffffc0205b38 <commands+0x16f8>
ffffffffc02031c8:	00002617          	auipc	a2,0x2
ffffffffc02031cc:	c6860613          	addi	a2,a2,-920 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02031d0:	0dd00593          	li	a1,221
ffffffffc02031d4:	00003517          	auipc	a0,0x3
ffffffffc02031d8:	82450513          	addi	a0,a0,-2012 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02031dc:	f2bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02031e0:	00003697          	auipc	a3,0x3
ffffffffc02031e4:	99868693          	addi	a3,a3,-1640 # ffffffffc0205b78 <commands+0x1738>
ffffffffc02031e8:	00002617          	auipc	a2,0x2
ffffffffc02031ec:	c4860613          	addi	a2,a2,-952 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02031f0:	0dc00593          	li	a1,220
ffffffffc02031f4:	00003517          	auipc	a0,0x3
ffffffffc02031f8:	80450513          	addi	a0,a0,-2044 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02031fc:	f0bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203200:	00003697          	auipc	a3,0x3
ffffffffc0203204:	81068693          	addi	a3,a3,-2032 # ffffffffc0205a10 <commands+0x15d0>
ffffffffc0203208:	00002617          	auipc	a2,0x2
ffffffffc020320c:	c2860613          	addi	a2,a2,-984 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203210:	0b900593          	li	a1,185
ffffffffc0203214:	00002517          	auipc	a0,0x2
ffffffffc0203218:	7e450513          	addi	a0,a0,2020 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020321c:	eebfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203220:	00003697          	auipc	a3,0x3
ffffffffc0203224:	91868693          	addi	a3,a3,-1768 # ffffffffc0205b38 <commands+0x16f8>
ffffffffc0203228:	00002617          	auipc	a2,0x2
ffffffffc020322c:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203230:	0d600593          	li	a1,214
ffffffffc0203234:	00002517          	auipc	a0,0x2
ffffffffc0203238:	7c450513          	addi	a0,a0,1988 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020323c:	ecbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203240:	00003697          	auipc	a3,0x3
ffffffffc0203244:	81068693          	addi	a3,a3,-2032 # ffffffffc0205a50 <commands+0x1610>
ffffffffc0203248:	00002617          	auipc	a2,0x2
ffffffffc020324c:	be860613          	addi	a2,a2,-1048 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203250:	0d400593          	li	a1,212
ffffffffc0203254:	00002517          	auipc	a0,0x2
ffffffffc0203258:	7a450513          	addi	a0,a0,1956 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020325c:	eabfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203260:	00002697          	auipc	a3,0x2
ffffffffc0203264:	7d068693          	addi	a3,a3,2000 # ffffffffc0205a30 <commands+0x15f0>
ffffffffc0203268:	00002617          	auipc	a2,0x2
ffffffffc020326c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203270:	0d300593          	li	a1,211
ffffffffc0203274:	00002517          	auipc	a0,0x2
ffffffffc0203278:	78450513          	addi	a0,a0,1924 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020327c:	e8bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203280:	00002697          	auipc	a3,0x2
ffffffffc0203284:	7d068693          	addi	a3,a3,2000 # ffffffffc0205a50 <commands+0x1610>
ffffffffc0203288:	00002617          	auipc	a2,0x2
ffffffffc020328c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203290:	0bb00593          	li	a1,187
ffffffffc0203294:	00002517          	auipc	a0,0x2
ffffffffc0203298:	76450513          	addi	a0,a0,1892 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020329c:	e6bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(count == 0);
ffffffffc02032a0:	00003697          	auipc	a3,0x3
ffffffffc02032a4:	a4868693          	addi	a3,a3,-1464 # ffffffffc0205ce8 <commands+0x18a8>
ffffffffc02032a8:	00002617          	auipc	a2,0x2
ffffffffc02032ac:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02032b0:	12500593          	li	a1,293
ffffffffc02032b4:	00002517          	auipc	a0,0x2
ffffffffc02032b8:	74450513          	addi	a0,a0,1860 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02032bc:	e4bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc02032c0:	00002697          	auipc	a3,0x2
ffffffffc02032c4:	5d868693          	addi	a3,a3,1496 # ffffffffc0205898 <commands+0x1458>
ffffffffc02032c8:	00002617          	auipc	a2,0x2
ffffffffc02032cc:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02032d0:	11a00593          	li	a1,282
ffffffffc02032d4:	00002517          	auipc	a0,0x2
ffffffffc02032d8:	72450513          	addi	a0,a0,1828 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02032dc:	e2bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02032e0:	00003697          	auipc	a3,0x3
ffffffffc02032e4:	85868693          	addi	a3,a3,-1960 # ffffffffc0205b38 <commands+0x16f8>
ffffffffc02032e8:	00002617          	auipc	a2,0x2
ffffffffc02032ec:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02032f0:	11800593          	li	a1,280
ffffffffc02032f4:	00002517          	auipc	a0,0x2
ffffffffc02032f8:	70450513          	addi	a0,a0,1796 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02032fc:	e0bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203300:	00002697          	auipc	a3,0x2
ffffffffc0203304:	7f868693          	addi	a3,a3,2040 # ffffffffc0205af8 <commands+0x16b8>
ffffffffc0203308:	00002617          	auipc	a2,0x2
ffffffffc020330c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203310:	0c100593          	li	a1,193
ffffffffc0203314:	00002517          	auipc	a0,0x2
ffffffffc0203318:	6e450513          	addi	a0,a0,1764 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020331c:	debfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203320:	00003697          	auipc	a3,0x3
ffffffffc0203324:	98868693          	addi	a3,a3,-1656 # ffffffffc0205ca8 <commands+0x1868>
ffffffffc0203328:	00002617          	auipc	a2,0x2
ffffffffc020332c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203330:	11200593          	li	a1,274
ffffffffc0203334:	00002517          	auipc	a0,0x2
ffffffffc0203338:	6c450513          	addi	a0,a0,1732 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020333c:	dcbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203340:	00003697          	auipc	a3,0x3
ffffffffc0203344:	94868693          	addi	a3,a3,-1720 # ffffffffc0205c88 <commands+0x1848>
ffffffffc0203348:	00002617          	auipc	a2,0x2
ffffffffc020334c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203350:	11000593          	li	a1,272
ffffffffc0203354:	00002517          	auipc	a0,0x2
ffffffffc0203358:	6a450513          	addi	a0,a0,1700 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020335c:	dabfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203360:	00003697          	auipc	a3,0x3
ffffffffc0203364:	90068693          	addi	a3,a3,-1792 # ffffffffc0205c60 <commands+0x1820>
ffffffffc0203368:	00002617          	auipc	a2,0x2
ffffffffc020336c:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203370:	10e00593          	li	a1,270
ffffffffc0203374:	00002517          	auipc	a0,0x2
ffffffffc0203378:	68450513          	addi	a0,a0,1668 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020337c:	d8bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203380:	00003697          	auipc	a3,0x3
ffffffffc0203384:	8b868693          	addi	a3,a3,-1864 # ffffffffc0205c38 <commands+0x17f8>
ffffffffc0203388:	00002617          	auipc	a2,0x2
ffffffffc020338c:	aa860613          	addi	a2,a2,-1368 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203390:	10d00593          	li	a1,269
ffffffffc0203394:	00002517          	auipc	a0,0x2
ffffffffc0203398:	66450513          	addi	a0,a0,1636 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020339c:	d6bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02033a0:	00003697          	auipc	a3,0x3
ffffffffc02033a4:	88868693          	addi	a3,a3,-1912 # ffffffffc0205c28 <commands+0x17e8>
ffffffffc02033a8:	00002617          	auipc	a2,0x2
ffffffffc02033ac:	a8860613          	addi	a2,a2,-1400 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02033b0:	10800593          	li	a1,264
ffffffffc02033b4:	00002517          	auipc	a0,0x2
ffffffffc02033b8:	64450513          	addi	a0,a0,1604 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02033bc:	d4bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02033c0:	00002697          	auipc	a3,0x2
ffffffffc02033c4:	77868693          	addi	a3,a3,1912 # ffffffffc0205b38 <commands+0x16f8>
ffffffffc02033c8:	00002617          	auipc	a2,0x2
ffffffffc02033cc:	a6860613          	addi	a2,a2,-1432 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02033d0:	10700593          	li	a1,263
ffffffffc02033d4:	00002517          	auipc	a0,0x2
ffffffffc02033d8:	62450513          	addi	a0,a0,1572 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02033dc:	d2bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02033e0:	00003697          	auipc	a3,0x3
ffffffffc02033e4:	82868693          	addi	a3,a3,-2008 # ffffffffc0205c08 <commands+0x17c8>
ffffffffc02033e8:	00002617          	auipc	a2,0x2
ffffffffc02033ec:	a4860613          	addi	a2,a2,-1464 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02033f0:	10600593          	li	a1,262
ffffffffc02033f4:	00002517          	auipc	a0,0x2
ffffffffc02033f8:	60450513          	addi	a0,a0,1540 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02033fc:	d0bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203400:	00002697          	auipc	a3,0x2
ffffffffc0203404:	7d868693          	addi	a3,a3,2008 # ffffffffc0205bd8 <commands+0x1798>
ffffffffc0203408:	00002617          	auipc	a2,0x2
ffffffffc020340c:	a2860613          	addi	a2,a2,-1496 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203410:	10500593          	li	a1,261
ffffffffc0203414:	00002517          	auipc	a0,0x2
ffffffffc0203418:	5e450513          	addi	a0,a0,1508 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020341c:	cebfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203420:	00002697          	auipc	a3,0x2
ffffffffc0203424:	7a068693          	addi	a3,a3,1952 # ffffffffc0205bc0 <commands+0x1780>
ffffffffc0203428:	00002617          	auipc	a2,0x2
ffffffffc020342c:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203430:	10400593          	li	a1,260
ffffffffc0203434:	00002517          	auipc	a0,0x2
ffffffffc0203438:	5c450513          	addi	a0,a0,1476 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020343c:	ccbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203440:	00002697          	auipc	a3,0x2
ffffffffc0203444:	6f868693          	addi	a3,a3,1784 # ffffffffc0205b38 <commands+0x16f8>
ffffffffc0203448:	00002617          	auipc	a2,0x2
ffffffffc020344c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203450:	0fe00593          	li	a1,254
ffffffffc0203454:	00002517          	auipc	a0,0x2
ffffffffc0203458:	5a450513          	addi	a0,a0,1444 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020345c:	cabfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203460:	00002697          	auipc	a3,0x2
ffffffffc0203464:	74868693          	addi	a3,a3,1864 # ffffffffc0205ba8 <commands+0x1768>
ffffffffc0203468:	00002617          	auipc	a2,0x2
ffffffffc020346c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203470:	0f900593          	li	a1,249
ffffffffc0203474:	00002517          	auipc	a0,0x2
ffffffffc0203478:	58450513          	addi	a0,a0,1412 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020347c:	c8bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203480:	00003697          	auipc	a3,0x3
ffffffffc0203484:	84868693          	addi	a3,a3,-1976 # ffffffffc0205cc8 <commands+0x1888>
ffffffffc0203488:	00002617          	auipc	a2,0x2
ffffffffc020348c:	9a860613          	addi	a2,a2,-1624 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203490:	11700593          	li	a1,279
ffffffffc0203494:	00002517          	auipc	a0,0x2
ffffffffc0203498:	56450513          	addi	a0,a0,1380 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020349c:	c6bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == 0);
ffffffffc02034a0:	00003697          	auipc	a3,0x3
ffffffffc02034a4:	85868693          	addi	a3,a3,-1960 # ffffffffc0205cf8 <commands+0x18b8>
ffffffffc02034a8:	00002617          	auipc	a2,0x2
ffffffffc02034ac:	98860613          	addi	a2,a2,-1656 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02034b0:	12600593          	li	a1,294
ffffffffc02034b4:	00002517          	auipc	a0,0x2
ffffffffc02034b8:	54450513          	addi	a0,a0,1348 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02034bc:	c4bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == nr_free_pages());
ffffffffc02034c0:	00002697          	auipc	a3,0x2
ffffffffc02034c4:	23868693          	addi	a3,a3,568 # ffffffffc02056f8 <commands+0x12b8>
ffffffffc02034c8:	00002617          	auipc	a2,0x2
ffffffffc02034cc:	96860613          	addi	a2,a2,-1688 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02034d0:	0f300593          	li	a1,243
ffffffffc02034d4:	00002517          	auipc	a0,0x2
ffffffffc02034d8:	52450513          	addi	a0,a0,1316 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02034dc:	c2bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02034e0:	00002697          	auipc	a3,0x2
ffffffffc02034e4:	55068693          	addi	a3,a3,1360 # ffffffffc0205a30 <commands+0x15f0>
ffffffffc02034e8:	00002617          	auipc	a2,0x2
ffffffffc02034ec:	94860613          	addi	a2,a2,-1720 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02034f0:	0ba00593          	li	a1,186
ffffffffc02034f4:	00002517          	auipc	a0,0x2
ffffffffc02034f8:	50450513          	addi	a0,a0,1284 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02034fc:	c0bfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203500 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203500:	1141                	addi	sp,sp,-16
ffffffffc0203502:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203504:	18058063          	beqz	a1,ffffffffc0203684 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0203508:	00359693          	slli	a3,a1,0x3
ffffffffc020350c:	96ae                	add	a3,a3,a1
ffffffffc020350e:	068e                	slli	a3,a3,0x3
ffffffffc0203510:	96aa                	add	a3,a3,a0
ffffffffc0203512:	02d50d63          	beq	a0,a3,ffffffffc020354c <default_free_pages+0x4c>
ffffffffc0203516:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203518:	8b85                	andi	a5,a5,1
ffffffffc020351a:	14079563          	bnez	a5,ffffffffc0203664 <default_free_pages+0x164>
ffffffffc020351e:	651c                	ld	a5,8(a0)
ffffffffc0203520:	8385                	srli	a5,a5,0x1
ffffffffc0203522:	8b85                	andi	a5,a5,1
ffffffffc0203524:	14079063          	bnez	a5,ffffffffc0203664 <default_free_pages+0x164>
ffffffffc0203528:	87aa                	mv	a5,a0
ffffffffc020352a:	a809                	j	ffffffffc020353c <default_free_pages+0x3c>
ffffffffc020352c:	6798                	ld	a4,8(a5)
ffffffffc020352e:	8b05                	andi	a4,a4,1
ffffffffc0203530:	12071a63          	bnez	a4,ffffffffc0203664 <default_free_pages+0x164>
ffffffffc0203534:	6798                	ld	a4,8(a5)
ffffffffc0203536:	8b09                	andi	a4,a4,2
ffffffffc0203538:	12071663          	bnez	a4,ffffffffc0203664 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc020353c:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0203540:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203544:	04878793          	addi	a5,a5,72
ffffffffc0203548:	fed792e3          	bne	a5,a3,ffffffffc020352c <default_free_pages+0x2c>
    base->property = n;
ffffffffc020354c:	2581                	sext.w	a1,a1
ffffffffc020354e:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0203550:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203554:	4789                	li	a5,2
ffffffffc0203556:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020355a:	0000e697          	auipc	a3,0xe
ffffffffc020355e:	02668693          	addi	a3,a3,38 # ffffffffc0211580 <free_area>
ffffffffc0203562:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203564:	669c                	ld	a5,8(a3)
ffffffffc0203566:	9db9                	addw	a1,a1,a4
ffffffffc0203568:	0000e717          	auipc	a4,0xe
ffffffffc020356c:	02b72423          	sw	a1,40(a4) # ffffffffc0211590 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203570:	08d78f63          	beq	a5,a3,ffffffffc020360e <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0203574:	fe078713          	addi	a4,a5,-32
ffffffffc0203578:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020357a:	4801                	li	a6,0
ffffffffc020357c:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0203580:	00e56a63          	bltu	a0,a4,ffffffffc0203594 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0203584:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203586:	02d70563          	beq	a4,a3,ffffffffc02035b0 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020358a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020358c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203590:	fee57ae3          	bleu	a4,a0,ffffffffc0203584 <default_free_pages+0x84>
ffffffffc0203594:	00080663          	beqz	a6,ffffffffc02035a0 <default_free_pages+0xa0>
ffffffffc0203598:	0000e817          	auipc	a6,0xe
ffffffffc020359c:	feb83423          	sd	a1,-24(a6) # ffffffffc0211580 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02035a0:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02035a2:	e390                	sd	a2,0(a5)
ffffffffc02035a4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02035a6:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02035a8:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02035aa:	02d59163          	bne	a1,a3,ffffffffc02035cc <default_free_pages+0xcc>
ffffffffc02035ae:	a091                	j	ffffffffc02035f2 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02035b0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02035b2:	f514                	sd	a3,40(a0)
ffffffffc02035b4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02035b6:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02035b8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02035ba:	00d70563          	beq	a4,a3,ffffffffc02035c4 <default_free_pages+0xc4>
ffffffffc02035be:	4805                	li	a6,1
ffffffffc02035c0:	87ba                	mv	a5,a4
ffffffffc02035c2:	b7e9                	j	ffffffffc020358c <default_free_pages+0x8c>
ffffffffc02035c4:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02035c6:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02035c8:	02d78163          	beq	a5,a3,ffffffffc02035ea <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02035cc:	ff85a803          	lw	a6,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc02035d0:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02035d4:	02081713          	slli	a4,a6,0x20
ffffffffc02035d8:	9301                	srli	a4,a4,0x20
ffffffffc02035da:	00371793          	slli	a5,a4,0x3
ffffffffc02035de:	97ba                	add	a5,a5,a4
ffffffffc02035e0:	078e                	slli	a5,a5,0x3
ffffffffc02035e2:	97b2                	add	a5,a5,a2
ffffffffc02035e4:	02f50e63          	beq	a0,a5,ffffffffc0203620 <default_free_pages+0x120>
ffffffffc02035e8:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02035ea:	fe078713          	addi	a4,a5,-32
ffffffffc02035ee:	00d78d63          	beq	a5,a3,ffffffffc0203608 <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02035f2:	4d0c                	lw	a1,24(a0)
ffffffffc02035f4:	02059613          	slli	a2,a1,0x20
ffffffffc02035f8:	9201                	srli	a2,a2,0x20
ffffffffc02035fa:	00361693          	slli	a3,a2,0x3
ffffffffc02035fe:	96b2                	add	a3,a3,a2
ffffffffc0203600:	068e                	slli	a3,a3,0x3
ffffffffc0203602:	96aa                	add	a3,a3,a0
ffffffffc0203604:	04d70063          	beq	a4,a3,ffffffffc0203644 <default_free_pages+0x144>
}
ffffffffc0203608:	60a2                	ld	ra,8(sp)
ffffffffc020360a:	0141                	addi	sp,sp,16
ffffffffc020360c:	8082                	ret
ffffffffc020360e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203610:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0203614:	e398                	sd	a4,0(a5)
ffffffffc0203616:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203618:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020361a:	f11c                	sd	a5,32(a0)
}
ffffffffc020361c:	0141                	addi	sp,sp,16
ffffffffc020361e:	8082                	ret
            p->property += base->property;
ffffffffc0203620:	4d1c                	lw	a5,24(a0)
ffffffffc0203622:	0107883b          	addw	a6,a5,a6
ffffffffc0203626:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020362a:	57f5                	li	a5,-3
ffffffffc020362c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203630:	02053803          	ld	a6,32(a0)
ffffffffc0203634:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0203636:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203638:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020363c:	659c                	ld	a5,8(a1)
ffffffffc020363e:	01073023          	sd	a6,0(a4)
ffffffffc0203642:	b765                	j	ffffffffc02035ea <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0203644:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203648:	fe878693          	addi	a3,a5,-24
ffffffffc020364c:	9db9                	addw	a1,a1,a4
ffffffffc020364e:	cd0c                	sw	a1,24(a0)
ffffffffc0203650:	5775                	li	a4,-3
ffffffffc0203652:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203656:	6398                	ld	a4,0(a5)
ffffffffc0203658:	679c                	ld	a5,8(a5)
}
ffffffffc020365a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020365c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020365e:	e398                	sd	a4,0(a5)
ffffffffc0203660:	0141                	addi	sp,sp,16
ffffffffc0203662:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203664:	00002697          	auipc	a3,0x2
ffffffffc0203668:	6a468693          	addi	a3,a3,1700 # ffffffffc0205d08 <commands+0x18c8>
ffffffffc020366c:	00001617          	auipc	a2,0x1
ffffffffc0203670:	7c460613          	addi	a2,a2,1988 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203674:	08300593          	li	a1,131
ffffffffc0203678:	00002517          	auipc	a0,0x2
ffffffffc020367c:	38050513          	addi	a0,a0,896 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc0203680:	a87fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc0203684:	00002697          	auipc	a3,0x2
ffffffffc0203688:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205d30 <commands+0x18f0>
ffffffffc020368c:	00001617          	auipc	a2,0x1
ffffffffc0203690:	7a460613          	addi	a2,a2,1956 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203694:	08000593          	li	a1,128
ffffffffc0203698:	00002517          	auipc	a0,0x2
ffffffffc020369c:	36050513          	addi	a0,a0,864 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc02036a0:	a67fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02036a4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02036a4:	cd51                	beqz	a0,ffffffffc0203740 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02036a6:	0000e597          	auipc	a1,0xe
ffffffffc02036aa:	eda58593          	addi	a1,a1,-294 # ffffffffc0211580 <free_area>
ffffffffc02036ae:	0105a803          	lw	a6,16(a1)
ffffffffc02036b2:	862a                	mv	a2,a0
ffffffffc02036b4:	02081793          	slli	a5,a6,0x20
ffffffffc02036b8:	9381                	srli	a5,a5,0x20
ffffffffc02036ba:	00a7ee63          	bltu	a5,a0,ffffffffc02036d6 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02036be:	87ae                	mv	a5,a1
ffffffffc02036c0:	a801                	j	ffffffffc02036d0 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02036c2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02036c6:	02071693          	slli	a3,a4,0x20
ffffffffc02036ca:	9281                	srli	a3,a3,0x20
ffffffffc02036cc:	00c6f763          	bleu	a2,a3,ffffffffc02036da <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02036d0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02036d2:	feb798e3          	bne	a5,a1,ffffffffc02036c2 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02036d6:	4501                	li	a0,0
}
ffffffffc02036d8:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02036da:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02036de:	dd6d                	beqz	a0,ffffffffc02036d8 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02036e0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02036e4:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02036e8:	00060e1b          	sext.w	t3,a2
ffffffffc02036ec:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02036f0:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02036f4:	02d67b63          	bleu	a3,a2,ffffffffc020372a <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02036f8:	00361693          	slli	a3,a2,0x3
ffffffffc02036fc:	96b2                	add	a3,a3,a2
ffffffffc02036fe:	068e                	slli	a3,a3,0x3
ffffffffc0203700:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0203702:	41c7073b          	subw	a4,a4,t3
ffffffffc0203706:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203708:	00868613          	addi	a2,a3,8
ffffffffc020370c:	4709                	li	a4,2
ffffffffc020370e:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203712:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203716:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020371a:	0105a803          	lw	a6,16(a1)
ffffffffc020371e:	e310                	sd	a2,0(a4)
ffffffffc0203720:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203724:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0203726:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020372a:	41c8083b          	subw	a6,a6,t3
ffffffffc020372e:	0000e717          	auipc	a4,0xe
ffffffffc0203732:	e7072123          	sw	a6,-414(a4) # ffffffffc0211590 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203736:	5775                	li	a4,-3
ffffffffc0203738:	17a1                	addi	a5,a5,-24
ffffffffc020373a:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020373e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203740:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203742:	00002697          	auipc	a3,0x2
ffffffffc0203746:	5ee68693          	addi	a3,a3,1518 # ffffffffc0205d30 <commands+0x18f0>
ffffffffc020374a:	00001617          	auipc	a2,0x1
ffffffffc020374e:	6e660613          	addi	a2,a2,1766 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203752:	06200593          	li	a1,98
ffffffffc0203756:	00002517          	auipc	a0,0x2
ffffffffc020375a:	2a250513          	addi	a0,a0,674 # ffffffffc02059f8 <commands+0x15b8>
default_alloc_pages(size_t n) {
ffffffffc020375e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203760:	9a7fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203764 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203764:	1141                	addi	sp,sp,-16
ffffffffc0203766:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203768:	c1fd                	beqz	a1,ffffffffc020384e <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020376a:	00359693          	slli	a3,a1,0x3
ffffffffc020376e:	96ae                	add	a3,a3,a1
ffffffffc0203770:	068e                	slli	a3,a3,0x3
ffffffffc0203772:	96aa                	add	a3,a3,a0
ffffffffc0203774:	02d50463          	beq	a0,a3,ffffffffc020379c <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203778:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020377a:	87aa                	mv	a5,a0
ffffffffc020377c:	8b05                	andi	a4,a4,1
ffffffffc020377e:	e709                	bnez	a4,ffffffffc0203788 <default_init_memmap+0x24>
ffffffffc0203780:	a07d                	j	ffffffffc020382e <default_init_memmap+0xca>
ffffffffc0203782:	6798                	ld	a4,8(a5)
ffffffffc0203784:	8b05                	andi	a4,a4,1
ffffffffc0203786:	c745                	beqz	a4,ffffffffc020382e <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0203788:	0007ac23          	sw	zero,24(a5)
ffffffffc020378c:	0007b423          	sd	zero,8(a5)
ffffffffc0203790:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203794:	04878793          	addi	a5,a5,72
ffffffffc0203798:	fed795e3          	bne	a5,a3,ffffffffc0203782 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc020379c:	2581                	sext.w	a1,a1
ffffffffc020379e:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02037a0:	4789                	li	a5,2
ffffffffc02037a2:	00850713          	addi	a4,a0,8
ffffffffc02037a6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02037aa:	0000e697          	auipc	a3,0xe
ffffffffc02037ae:	dd668693          	addi	a3,a3,-554 # ffffffffc0211580 <free_area>
ffffffffc02037b2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02037b4:	669c                	ld	a5,8(a3)
ffffffffc02037b6:	9db9                	addw	a1,a1,a4
ffffffffc02037b8:	0000e717          	auipc	a4,0xe
ffffffffc02037bc:	dcb72c23          	sw	a1,-552(a4) # ffffffffc0211590 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02037c0:	04d78a63          	beq	a5,a3,ffffffffc0203814 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02037c4:	fe078713          	addi	a4,a5,-32
ffffffffc02037c8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02037ca:	4801                	li	a6,0
ffffffffc02037cc:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02037d0:	00e56a63          	bltu	a0,a4,ffffffffc02037e4 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02037d4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02037d6:	02d70563          	beq	a4,a3,ffffffffc0203800 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02037da:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02037dc:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02037e0:	fee57ae3          	bleu	a4,a0,ffffffffc02037d4 <default_init_memmap+0x70>
ffffffffc02037e4:	00080663          	beqz	a6,ffffffffc02037f0 <default_init_memmap+0x8c>
ffffffffc02037e8:	0000e717          	auipc	a4,0xe
ffffffffc02037ec:	d8b73c23          	sd	a1,-616(a4) # ffffffffc0211580 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02037f0:	6398                	ld	a4,0(a5)
}
ffffffffc02037f2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02037f4:	e390                	sd	a2,0(a5)
ffffffffc02037f6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02037f8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02037fa:	f118                	sd	a4,32(a0)
ffffffffc02037fc:	0141                	addi	sp,sp,16
ffffffffc02037fe:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203800:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203802:	f514                	sd	a3,40(a0)
ffffffffc0203804:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203806:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0203808:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020380a:	00d70e63          	beq	a4,a3,ffffffffc0203826 <default_init_memmap+0xc2>
ffffffffc020380e:	4805                	li	a6,1
ffffffffc0203810:	87ba                	mv	a5,a4
ffffffffc0203812:	b7e9                	j	ffffffffc02037dc <default_init_memmap+0x78>
}
ffffffffc0203814:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203816:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020381a:	e398                	sd	a4,0(a5)
ffffffffc020381c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020381e:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203820:	f11c                	sd	a5,32(a0)
}
ffffffffc0203822:	0141                	addi	sp,sp,16
ffffffffc0203824:	8082                	ret
ffffffffc0203826:	60a2                	ld	ra,8(sp)
ffffffffc0203828:	e290                	sd	a2,0(a3)
ffffffffc020382a:	0141                	addi	sp,sp,16
ffffffffc020382c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020382e:	00002697          	auipc	a3,0x2
ffffffffc0203832:	50a68693          	addi	a3,a3,1290 # ffffffffc0205d38 <commands+0x18f8>
ffffffffc0203836:	00001617          	auipc	a2,0x1
ffffffffc020383a:	5fa60613          	addi	a2,a2,1530 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020383e:	04900593          	li	a1,73
ffffffffc0203842:	00002517          	auipc	a0,0x2
ffffffffc0203846:	1b650513          	addi	a0,a0,438 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020384a:	8bdfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc020384e:	00002697          	auipc	a3,0x2
ffffffffc0203852:	4e268693          	addi	a3,a3,1250 # ffffffffc0205d30 <commands+0x18f0>
ffffffffc0203856:	00001617          	auipc	a2,0x1
ffffffffc020385a:	5da60613          	addi	a2,a2,1498 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020385e:	04600593          	li	a1,70
ffffffffc0203862:	00002517          	auipc	a0,0x2
ffffffffc0203866:	19650513          	addi	a0,a0,406 # ffffffffc02059f8 <commands+0x15b8>
ffffffffc020386a:	89dfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020386e <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020386e:	0000e797          	auipc	a5,0xe
ffffffffc0203872:	d0278793          	addi	a5,a5,-766 # ffffffffc0211570 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr=&pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc0203876:	f51c                	sd	a5,40(a0)
ffffffffc0203878:	e79c                	sd	a5,8(a5)
ffffffffc020387a:	e39c                	sd	a5,0(a5)
     curr_ptr=&pra_list_head;
ffffffffc020387c:	0000e717          	auipc	a4,0xe
ffffffffc0203880:	d0f73e23          	sd	a5,-740(a4) # ffffffffc0211598 <curr_ptr>
     return 0;
}
ffffffffc0203884:	4501                	li	a0,0
ffffffffc0203886:	8082                	ret

ffffffffc0203888 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203888:	4501                	li	a0,0
ffffffffc020388a:	8082                	ret

ffffffffc020388c <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020388c:	4501                	li	a0,0
ffffffffc020388e:	8082                	ret

ffffffffc0203890 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203890:	4501                	li	a0,0
ffffffffc0203892:	8082                	ret

ffffffffc0203894 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0203894:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203896:	678d                	lui	a5,0x3
ffffffffc0203898:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc020389a:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020389c:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02038a0:	0000e797          	auipc	a5,0xe
ffffffffc02038a4:	bc078793          	addi	a5,a5,-1088 # ffffffffc0211460 <pgfault_num>
ffffffffc02038a8:	4398                	lw	a4,0(a5)
ffffffffc02038aa:	4691                	li	a3,4
ffffffffc02038ac:	2701                	sext.w	a4,a4
ffffffffc02038ae:	08d71f63          	bne	a4,a3,ffffffffc020394c <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02038b2:	6685                	lui	a3,0x1
ffffffffc02038b4:	4629                	li	a2,10
ffffffffc02038b6:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02038ba:	4394                	lw	a3,0(a5)
ffffffffc02038bc:	2681                	sext.w	a3,a3
ffffffffc02038be:	20e69763          	bne	a3,a4,ffffffffc0203acc <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02038c2:	6711                	lui	a4,0x4
ffffffffc02038c4:	4635                	li	a2,13
ffffffffc02038c6:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02038ca:	4398                	lw	a4,0(a5)
ffffffffc02038cc:	2701                	sext.w	a4,a4
ffffffffc02038ce:	1cd71f63          	bne	a4,a3,ffffffffc0203aac <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02038d2:	6689                	lui	a3,0x2
ffffffffc02038d4:	462d                	li	a2,11
ffffffffc02038d6:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02038da:	4394                	lw	a3,0(a5)
ffffffffc02038dc:	2681                	sext.w	a3,a3
ffffffffc02038de:	1ae69763          	bne	a3,a4,ffffffffc0203a8c <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02038e2:	6715                	lui	a4,0x5
ffffffffc02038e4:	46b9                	li	a3,14
ffffffffc02038e6:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02038ea:	4398                	lw	a4,0(a5)
ffffffffc02038ec:	4695                	li	a3,5
ffffffffc02038ee:	2701                	sext.w	a4,a4
ffffffffc02038f0:	16d71e63          	bne	a4,a3,ffffffffc0203a6c <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc02038f4:	4394                	lw	a3,0(a5)
ffffffffc02038f6:	2681                	sext.w	a3,a3
ffffffffc02038f8:	14e69a63          	bne	a3,a4,ffffffffc0203a4c <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc02038fc:	4398                	lw	a4,0(a5)
ffffffffc02038fe:	2701                	sext.w	a4,a4
ffffffffc0203900:	12d71663          	bne	a4,a3,ffffffffc0203a2c <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0203904:	4394                	lw	a3,0(a5)
ffffffffc0203906:	2681                	sext.w	a3,a3
ffffffffc0203908:	10e69263          	bne	a3,a4,ffffffffc0203a0c <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc020390c:	4398                	lw	a4,0(a5)
ffffffffc020390e:	2701                	sext.w	a4,a4
ffffffffc0203910:	0cd71e63          	bne	a4,a3,ffffffffc02039ec <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203914:	4394                	lw	a3,0(a5)
ffffffffc0203916:	2681                	sext.w	a3,a3
ffffffffc0203918:	0ae69a63          	bne	a3,a4,ffffffffc02039cc <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020391c:	6715                	lui	a4,0x5
ffffffffc020391e:	46b9                	li	a3,14
ffffffffc0203920:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203924:	4398                	lw	a4,0(a5)
ffffffffc0203926:	4695                	li	a3,5
ffffffffc0203928:	2701                	sext.w	a4,a4
ffffffffc020392a:	08d71163          	bne	a4,a3,ffffffffc02039ac <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020392e:	6705                	lui	a4,0x1
ffffffffc0203930:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203934:	4729                	li	a4,10
ffffffffc0203936:	04e69b63          	bne	a3,a4,ffffffffc020398c <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc020393a:	439c                	lw	a5,0(a5)
ffffffffc020393c:	4719                	li	a4,6
ffffffffc020393e:	2781                	sext.w	a5,a5
ffffffffc0203940:	02e79663          	bne	a5,a4,ffffffffc020396c <_clock_check_swap+0xd8>
}
ffffffffc0203944:	60a2                	ld	ra,8(sp)
ffffffffc0203946:	4501                	li	a0,0
ffffffffc0203948:	0141                	addi	sp,sp,16
ffffffffc020394a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020394c:	00002697          	auipc	a3,0x2
ffffffffc0203950:	f3c68693          	addi	a3,a3,-196 # ffffffffc0205888 <commands+0x1448>
ffffffffc0203954:	00001617          	auipc	a2,0x1
ffffffffc0203958:	4dc60613          	addi	a2,a2,1244 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020395c:	08f00593          	li	a1,143
ffffffffc0203960:	00002517          	auipc	a0,0x2
ffffffffc0203964:	43850513          	addi	a0,a0,1080 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203968:	f9efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==6);
ffffffffc020396c:	00002697          	auipc	a3,0x2
ffffffffc0203970:	47c68693          	addi	a3,a3,1148 # ffffffffc0205de8 <default_pmm_manager+0xa0>
ffffffffc0203974:	00001617          	auipc	a2,0x1
ffffffffc0203978:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020397c:	0a600593          	li	a1,166
ffffffffc0203980:	00002517          	auipc	a0,0x2
ffffffffc0203984:	41850513          	addi	a0,a0,1048 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203988:	f7efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020398c:	00002697          	auipc	a3,0x2
ffffffffc0203990:	43468693          	addi	a3,a3,1076 # ffffffffc0205dc0 <default_pmm_manager+0x78>
ffffffffc0203994:	00001617          	auipc	a2,0x1
ffffffffc0203998:	49c60613          	addi	a2,a2,1180 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc020399c:	0a400593          	li	a1,164
ffffffffc02039a0:	00002517          	auipc	a0,0x2
ffffffffc02039a4:	3f850513          	addi	a0,a0,1016 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc02039a8:	f5efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02039ac:	00002697          	auipc	a3,0x2
ffffffffc02039b0:	40468693          	addi	a3,a3,1028 # ffffffffc0205db0 <default_pmm_manager+0x68>
ffffffffc02039b4:	00001617          	auipc	a2,0x1
ffffffffc02039b8:	47c60613          	addi	a2,a2,1148 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02039bc:	0a300593          	li	a1,163
ffffffffc02039c0:	00002517          	auipc	a0,0x2
ffffffffc02039c4:	3d850513          	addi	a0,a0,984 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc02039c8:	f3efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02039cc:	00002697          	auipc	a3,0x2
ffffffffc02039d0:	3e468693          	addi	a3,a3,996 # ffffffffc0205db0 <default_pmm_manager+0x68>
ffffffffc02039d4:	00001617          	auipc	a2,0x1
ffffffffc02039d8:	45c60613          	addi	a2,a2,1116 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02039dc:	0a100593          	li	a1,161
ffffffffc02039e0:	00002517          	auipc	a0,0x2
ffffffffc02039e4:	3b850513          	addi	a0,a0,952 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc02039e8:	f1efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02039ec:	00002697          	auipc	a3,0x2
ffffffffc02039f0:	3c468693          	addi	a3,a3,964 # ffffffffc0205db0 <default_pmm_manager+0x68>
ffffffffc02039f4:	00001617          	auipc	a2,0x1
ffffffffc02039f8:	43c60613          	addi	a2,a2,1084 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc02039fc:	09f00593          	li	a1,159
ffffffffc0203a00:	00002517          	auipc	a0,0x2
ffffffffc0203a04:	39850513          	addi	a0,a0,920 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203a08:	efefc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a0c:	00002697          	auipc	a3,0x2
ffffffffc0203a10:	3a468693          	addi	a3,a3,932 # ffffffffc0205db0 <default_pmm_manager+0x68>
ffffffffc0203a14:	00001617          	auipc	a2,0x1
ffffffffc0203a18:	41c60613          	addi	a2,a2,1052 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203a1c:	09d00593          	li	a1,157
ffffffffc0203a20:	00002517          	auipc	a0,0x2
ffffffffc0203a24:	37850513          	addi	a0,a0,888 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203a28:	edefc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a2c:	00002697          	auipc	a3,0x2
ffffffffc0203a30:	38468693          	addi	a3,a3,900 # ffffffffc0205db0 <default_pmm_manager+0x68>
ffffffffc0203a34:	00001617          	auipc	a2,0x1
ffffffffc0203a38:	3fc60613          	addi	a2,a2,1020 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203a3c:	09b00593          	li	a1,155
ffffffffc0203a40:	00002517          	auipc	a0,0x2
ffffffffc0203a44:	35850513          	addi	a0,a0,856 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203a48:	ebefc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a4c:	00002697          	auipc	a3,0x2
ffffffffc0203a50:	36468693          	addi	a3,a3,868 # ffffffffc0205db0 <default_pmm_manager+0x68>
ffffffffc0203a54:	00001617          	auipc	a2,0x1
ffffffffc0203a58:	3dc60613          	addi	a2,a2,988 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203a5c:	09900593          	li	a1,153
ffffffffc0203a60:	00002517          	auipc	a0,0x2
ffffffffc0203a64:	33850513          	addi	a0,a0,824 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203a68:	e9efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a6c:	00002697          	auipc	a3,0x2
ffffffffc0203a70:	34468693          	addi	a3,a3,836 # ffffffffc0205db0 <default_pmm_manager+0x68>
ffffffffc0203a74:	00001617          	auipc	a2,0x1
ffffffffc0203a78:	3bc60613          	addi	a2,a2,956 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203a7c:	09700593          	li	a1,151
ffffffffc0203a80:	00002517          	auipc	a0,0x2
ffffffffc0203a84:	31850513          	addi	a0,a0,792 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203a88:	e7efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203a8c:	00002697          	auipc	a3,0x2
ffffffffc0203a90:	dfc68693          	addi	a3,a3,-516 # ffffffffc0205888 <commands+0x1448>
ffffffffc0203a94:	00001617          	auipc	a2,0x1
ffffffffc0203a98:	39c60613          	addi	a2,a2,924 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203a9c:	09500593          	li	a1,149
ffffffffc0203aa0:	00002517          	auipc	a0,0x2
ffffffffc0203aa4:	2f850513          	addi	a0,a0,760 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203aa8:	e5efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203aac:	00002697          	auipc	a3,0x2
ffffffffc0203ab0:	ddc68693          	addi	a3,a3,-548 # ffffffffc0205888 <commands+0x1448>
ffffffffc0203ab4:	00001617          	auipc	a2,0x1
ffffffffc0203ab8:	37c60613          	addi	a2,a2,892 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203abc:	09300593          	li	a1,147
ffffffffc0203ac0:	00002517          	auipc	a0,0x2
ffffffffc0203ac4:	2d850513          	addi	a0,a0,728 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203ac8:	e3efc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203acc:	00002697          	auipc	a3,0x2
ffffffffc0203ad0:	dbc68693          	addi	a3,a3,-580 # ffffffffc0205888 <commands+0x1448>
ffffffffc0203ad4:	00001617          	auipc	a2,0x1
ffffffffc0203ad8:	35c60613          	addi	a2,a2,860 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203adc:	09100593          	li	a1,145
ffffffffc0203ae0:	00002517          	auipc	a0,0x2
ffffffffc0203ae4:	2b850513          	addi	a0,a0,696 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203ae8:	e1efc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203aec <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203aec:	03060713          	addi	a4,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203af0:	c305                	beqz	a4,ffffffffc0203b10 <_clock_map_swappable+0x24>
ffffffffc0203af2:	0000e797          	auipc	a5,0xe
ffffffffc0203af6:	aa678793          	addi	a5,a5,-1370 # ffffffffc0211598 <curr_ptr>
ffffffffc0203afa:	639c                	ld	a5,0(a5)
ffffffffc0203afc:	cb91                	beqz	a5,ffffffffc0203b10 <_clock_map_swappable+0x24>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203afe:	6794                	ld	a3,8(a5)
}
ffffffffc0203b00:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0203b02:	e298                	sd	a4,0(a3)
ffffffffc0203b04:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0203b06:	fa1c                	sd	a5,48(a2)
    page->visited=1;
ffffffffc0203b08:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203b0a:	fe14                	sd	a3,56(a2)
ffffffffc0203b0c:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203b0e:	8082                	ret
{
ffffffffc0203b10:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203b12:	00002697          	auipc	a3,0x2
ffffffffc0203b16:	2e668693          	addi	a3,a3,742 # ffffffffc0205df8 <default_pmm_manager+0xb0>
ffffffffc0203b1a:	00001617          	auipc	a2,0x1
ffffffffc0203b1e:	31660613          	addi	a2,a2,790 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203b22:	03800593          	li	a1,56
ffffffffc0203b26:	00002517          	auipc	a0,0x2
ffffffffc0203b2a:	27250513          	addi	a0,a0,626 # ffffffffc0205d98 <default_pmm_manager+0x50>
{
ffffffffc0203b2e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203b30:	dd6fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203b34 <_clock_swap_out_victim>:
{
ffffffffc0203b34:	7179                	addi	sp,sp,-48
ffffffffc0203b36:	f022                	sd	s0,32(sp)
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203b38:	7500                	ld	s0,40(a0)
{
ffffffffc0203b3a:	f406                	sd	ra,40(sp)
ffffffffc0203b3c:	ec26                	sd	s1,24(sp)
ffffffffc0203b3e:	e84a                	sd	s2,16(sp)
ffffffffc0203b40:	e44e                	sd	s3,8(sp)
         assert(head != NULL);
ffffffffc0203b42:	c835                	beqz	s0,ffffffffc0203bb6 <_clock_swap_out_victim+0x82>
     assert(in_tick==0);
ffffffffc0203b44:	ea49                	bnez	a2,ffffffffc0203bd6 <_clock_swap_out_victim+0xa2>
ffffffffc0203b46:	0000e497          	auipc	s1,0xe
ffffffffc0203b4a:	a5248493          	addi	s1,s1,-1454 # ffffffffc0211598 <curr_ptr>
ffffffffc0203b4e:	89ae                	mv	s3,a1
ffffffffc0203b50:	608c                	ld	a1,0(s1)
        cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc0203b52:	00002917          	auipc	s2,0x2
ffffffffc0203b56:	2ee90913          	addi	s2,s2,750 # ffffffffc0205e40 <default_pmm_manager+0xf8>
        if(curr_ptr==head)
ffffffffc0203b5a:	02b40263          	beq	s0,a1,ffffffffc0203b7e <_clock_swap_out_victim+0x4a>
        cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc0203b5e:	854a                	mv	a0,s2
ffffffffc0203b60:	d5efc0ef          	jal	ra,ffffffffc02000be <cprintf>
        struct Page* curr_page = le2page(curr_ptr,pra_page_link);
ffffffffc0203b64:	609c                	ld	a5,0(s1)
        if(curr_page->visited == 0)
ffffffffc0203b66:	fe07b703          	ld	a4,-32(a5)
ffffffffc0203b6a:	c305                	beqz	a4,ffffffffc0203b8a <_clock_swap_out_victim+0x56>
    return listelm->prev;
ffffffffc0203b6c:	638c                	ld	a1,0(a5)
        curr_page->visited = 0;
ffffffffc0203b6e:	fe07b023          	sd	zero,-32(a5)
        curr_ptr = list_prev(curr_ptr);
ffffffffc0203b72:	0000e797          	auipc	a5,0xe
ffffffffc0203b76:	a2b7b323          	sd	a1,-1498(a5) # ffffffffc0211598 <curr_ptr>
        if(curr_ptr==head)
ffffffffc0203b7a:	feb412e3          	bne	s0,a1,ffffffffc0203b5e <_clock_swap_out_victim+0x2a>
ffffffffc0203b7e:	600c                	ld	a1,0(s0)
            curr_ptr=list_prev(curr_ptr);
ffffffffc0203b80:	0000e797          	auipc	a5,0xe
ffffffffc0203b84:	a0b7bc23          	sd	a1,-1512(a5) # ffffffffc0211598 <curr_ptr>
            continue;
ffffffffc0203b88:	bfc9                	j	ffffffffc0203b5a <_clock_swap_out_victim+0x26>
ffffffffc0203b8a:	6394                	ld	a3,0(a5)
}
ffffffffc0203b8c:	70a2                	ld	ra,40(sp)
ffffffffc0203b8e:	7402                	ld	s0,32(sp)
    return listelm->next;
ffffffffc0203b90:	6698                	ld	a4,8(a3)
            curr_ptr = list_prev(curr_ptr);
ffffffffc0203b92:	0000e617          	auipc	a2,0xe
ffffffffc0203b96:	a0d63323          	sd	a3,-1530(a2) # ffffffffc0211598 <curr_ptr>
        struct Page* curr_page = le2page(curr_ptr,pra_page_link);
ffffffffc0203b9a:	fd078793          	addi	a5,a5,-48
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b9e:	6314                	ld	a3,0(a4)
ffffffffc0203ba0:	6718                	ld	a4,8(a4)
}
ffffffffc0203ba2:	64e2                	ld	s1,24(sp)
ffffffffc0203ba4:	6942                	ld	s2,16(sp)
    prev->next = next;
ffffffffc0203ba6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203ba8:	e314                	sd	a3,0(a4)
            *ptr_page = curr_page;
ffffffffc0203baa:	00f9b023          	sd	a5,0(s3)
}
ffffffffc0203bae:	4501                	li	a0,0
ffffffffc0203bb0:	69a2                	ld	s3,8(sp)
ffffffffc0203bb2:	6145                	addi	sp,sp,48
ffffffffc0203bb4:	8082                	ret
         assert(head != NULL);
ffffffffc0203bb6:	00002697          	auipc	a3,0x2
ffffffffc0203bba:	26a68693          	addi	a3,a3,618 # ffffffffc0205e20 <default_pmm_manager+0xd8>
ffffffffc0203bbe:	00001617          	auipc	a2,0x1
ffffffffc0203bc2:	27260613          	addi	a2,a2,626 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203bc6:	04a00593          	li	a1,74
ffffffffc0203bca:	00002517          	auipc	a0,0x2
ffffffffc0203bce:	1ce50513          	addi	a0,a0,462 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203bd2:	d34fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(in_tick==0);
ffffffffc0203bd6:	00002697          	auipc	a3,0x2
ffffffffc0203bda:	25a68693          	addi	a3,a3,602 # ffffffffc0205e30 <default_pmm_manager+0xe8>
ffffffffc0203bde:	00001617          	auipc	a2,0x1
ffffffffc0203be2:	25260613          	addi	a2,a2,594 # ffffffffc0204e30 <commands+0x9f0>
ffffffffc0203be6:	04b00593          	li	a1,75
ffffffffc0203bea:	00002517          	auipc	a0,0x2
ffffffffc0203bee:	1ae50513          	addi	a0,a0,430 # ffffffffc0205d98 <default_pmm_manager+0x50>
ffffffffc0203bf2:	d14fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203bf6 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203bf6:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bf8:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203bfa:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bfc:	fdafc0ef          	jal	ra,ffffffffc02003d6 <ide_device_valid>
ffffffffc0203c00:	cd01                	beqz	a0,ffffffffc0203c18 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c02:	4505                	li	a0,1
ffffffffc0203c04:	fd8fc0ef          	jal	ra,ffffffffc02003dc <ide_device_size>
}
ffffffffc0203c08:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c0a:	810d                	srli	a0,a0,0x3
ffffffffc0203c0c:	0000e797          	auipc	a5,0xe
ffffffffc0203c10:	92a7b223          	sd	a0,-1756(a5) # ffffffffc0211530 <max_swap_offset>
}
ffffffffc0203c14:	0141                	addi	sp,sp,16
ffffffffc0203c16:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c18:	00002617          	auipc	a2,0x2
ffffffffc0203c1c:	25060613          	addi	a2,a2,592 # ffffffffc0205e68 <default_pmm_manager+0x120>
ffffffffc0203c20:	45b5                	li	a1,13
ffffffffc0203c22:	00002517          	auipc	a0,0x2
ffffffffc0203c26:	26650513          	addi	a0,a0,614 # ffffffffc0205e88 <default_pmm_manager+0x140>
ffffffffc0203c2a:	cdcfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203c2e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c2e:	1141                	addi	sp,sp,-16
ffffffffc0203c30:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c32:	00855793          	srli	a5,a0,0x8
ffffffffc0203c36:	c7b5                	beqz	a5,ffffffffc0203ca2 <swapfs_read+0x74>
ffffffffc0203c38:	0000e717          	auipc	a4,0xe
ffffffffc0203c3c:	8f870713          	addi	a4,a4,-1800 # ffffffffc0211530 <max_swap_offset>
ffffffffc0203c40:	6318                	ld	a4,0(a4)
ffffffffc0203c42:	06e7f063          	bleu	a4,a5,ffffffffc0203ca2 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c46:	0000e717          	auipc	a4,0xe
ffffffffc0203c4a:	85270713          	addi	a4,a4,-1966 # ffffffffc0211498 <pages>
ffffffffc0203c4e:	6310                	ld	a2,0(a4)
ffffffffc0203c50:	00001717          	auipc	a4,0x1
ffffffffc0203c54:	02870713          	addi	a4,a4,40 # ffffffffc0204c78 <commands+0x838>
ffffffffc0203c58:	00002697          	auipc	a3,0x2
ffffffffc0203c5c:	4b068693          	addi	a3,a3,1200 # ffffffffc0206108 <nbase>
ffffffffc0203c60:	40c58633          	sub	a2,a1,a2
ffffffffc0203c64:	630c                	ld	a1,0(a4)
ffffffffc0203c66:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c68:	0000d717          	auipc	a4,0xd
ffffffffc0203c6c:	7f070713          	addi	a4,a4,2032 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c70:	02b60633          	mul	a2,a2,a1
ffffffffc0203c74:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203c78:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c7a:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c7c:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c7e:	57fd                	li	a5,-1
ffffffffc0203c80:	83b1                	srli	a5,a5,0xc
ffffffffc0203c82:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c84:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c86:	02e7fa63          	bleu	a4,a5,ffffffffc0203cba <swapfs_read+0x8c>
ffffffffc0203c8a:	0000d797          	auipc	a5,0xd
ffffffffc0203c8e:	7fe78793          	addi	a5,a5,2046 # ffffffffc0211488 <va_pa_offset>
ffffffffc0203c92:	639c                	ld	a5,0(a5)
}
ffffffffc0203c94:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c96:	46a1                	li	a3,8
ffffffffc0203c98:	963e                	add	a2,a2,a5
ffffffffc0203c9a:	4505                	li	a0,1
}
ffffffffc0203c9c:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c9e:	f44fc06f          	j	ffffffffc02003e2 <ide_read_secs>
ffffffffc0203ca2:	86aa                	mv	a3,a0
ffffffffc0203ca4:	00002617          	auipc	a2,0x2
ffffffffc0203ca8:	1fc60613          	addi	a2,a2,508 # ffffffffc0205ea0 <default_pmm_manager+0x158>
ffffffffc0203cac:	45d1                	li	a1,20
ffffffffc0203cae:	00002517          	auipc	a0,0x2
ffffffffc0203cb2:	1da50513          	addi	a0,a0,474 # ffffffffc0205e88 <default_pmm_manager+0x140>
ffffffffc0203cb6:	c50fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203cba:	86b2                	mv	a3,a2
ffffffffc0203cbc:	06a00593          	li	a1,106
ffffffffc0203cc0:	00001617          	auipc	a2,0x1
ffffffffc0203cc4:	fc060613          	addi	a2,a2,-64 # ffffffffc0204c80 <commands+0x840>
ffffffffc0203cc8:	00001517          	auipc	a0,0x1
ffffffffc0203ccc:	05050513          	addi	a0,a0,80 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc0203cd0:	c36fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203cd4 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203cd4:	1141                	addi	sp,sp,-16
ffffffffc0203cd6:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cd8:	00855793          	srli	a5,a0,0x8
ffffffffc0203cdc:	c7b5                	beqz	a5,ffffffffc0203d48 <swapfs_write+0x74>
ffffffffc0203cde:	0000e717          	auipc	a4,0xe
ffffffffc0203ce2:	85270713          	addi	a4,a4,-1966 # ffffffffc0211530 <max_swap_offset>
ffffffffc0203ce6:	6318                	ld	a4,0(a4)
ffffffffc0203ce8:	06e7f063          	bleu	a4,a5,ffffffffc0203d48 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cec:	0000d717          	auipc	a4,0xd
ffffffffc0203cf0:	7ac70713          	addi	a4,a4,1964 # ffffffffc0211498 <pages>
ffffffffc0203cf4:	6310                	ld	a2,0(a4)
ffffffffc0203cf6:	00001717          	auipc	a4,0x1
ffffffffc0203cfa:	f8270713          	addi	a4,a4,-126 # ffffffffc0204c78 <commands+0x838>
ffffffffc0203cfe:	00002697          	auipc	a3,0x2
ffffffffc0203d02:	40a68693          	addi	a3,a3,1034 # ffffffffc0206108 <nbase>
ffffffffc0203d06:	40c58633          	sub	a2,a1,a2
ffffffffc0203d0a:	630c                	ld	a1,0(a4)
ffffffffc0203d0c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d0e:	0000d717          	auipc	a4,0xd
ffffffffc0203d12:	74a70713          	addi	a4,a4,1866 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d16:	02b60633          	mul	a2,a2,a1
ffffffffc0203d1a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d1e:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d20:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d22:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d24:	57fd                	li	a5,-1
ffffffffc0203d26:	83b1                	srli	a5,a5,0xc
ffffffffc0203d28:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d2a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d2c:	02e7fa63          	bleu	a4,a5,ffffffffc0203d60 <swapfs_write+0x8c>
ffffffffc0203d30:	0000d797          	auipc	a5,0xd
ffffffffc0203d34:	75878793          	addi	a5,a5,1880 # ffffffffc0211488 <va_pa_offset>
ffffffffc0203d38:	639c                	ld	a5,0(a5)
}
ffffffffc0203d3a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d3c:	46a1                	li	a3,8
ffffffffc0203d3e:	963e                	add	a2,a2,a5
ffffffffc0203d40:	4505                	li	a0,1
}
ffffffffc0203d42:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d44:	ec2fc06f          	j	ffffffffc0200406 <ide_write_secs>
ffffffffc0203d48:	86aa                	mv	a3,a0
ffffffffc0203d4a:	00002617          	auipc	a2,0x2
ffffffffc0203d4e:	15660613          	addi	a2,a2,342 # ffffffffc0205ea0 <default_pmm_manager+0x158>
ffffffffc0203d52:	45e5                	li	a1,25
ffffffffc0203d54:	00002517          	auipc	a0,0x2
ffffffffc0203d58:	13450513          	addi	a0,a0,308 # ffffffffc0205e88 <default_pmm_manager+0x140>
ffffffffc0203d5c:	baafc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203d60:	86b2                	mv	a3,a2
ffffffffc0203d62:	06a00593          	li	a1,106
ffffffffc0203d66:	00001617          	auipc	a2,0x1
ffffffffc0203d6a:	f1a60613          	addi	a2,a2,-230 # ffffffffc0204c80 <commands+0x840>
ffffffffc0203d6e:	00001517          	auipc	a0,0x1
ffffffffc0203d72:	faa50513          	addi	a0,a0,-86 # ffffffffc0204d18 <commands+0x8d8>
ffffffffc0203d76:	b90fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203d7a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203d7a:	00054783          	lbu	a5,0(a0)
ffffffffc0203d7e:	cb91                	beqz	a5,ffffffffc0203d92 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0203d80:	4781                	li	a5,0
        cnt ++;
ffffffffc0203d82:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203d84:	00f50733          	add	a4,a0,a5
ffffffffc0203d88:	00074703          	lbu	a4,0(a4)
ffffffffc0203d8c:	fb7d                	bnez	a4,ffffffffc0203d82 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203d8e:	853e                	mv	a0,a5
ffffffffc0203d90:	8082                	ret
    size_t cnt = 0;
ffffffffc0203d92:	4781                	li	a5,0
}
ffffffffc0203d94:	853e                	mv	a0,a5
ffffffffc0203d96:	8082                	ret

ffffffffc0203d98 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d98:	c185                	beqz	a1,ffffffffc0203db8 <strnlen+0x20>
ffffffffc0203d9a:	00054783          	lbu	a5,0(a0)
ffffffffc0203d9e:	cf89                	beqz	a5,ffffffffc0203db8 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0203da0:	4781                	li	a5,0
ffffffffc0203da2:	a021                	j	ffffffffc0203daa <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203da4:	00074703          	lbu	a4,0(a4)
ffffffffc0203da8:	c711                	beqz	a4,ffffffffc0203db4 <strnlen+0x1c>
        cnt ++;
ffffffffc0203daa:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203dac:	00f50733          	add	a4,a0,a5
ffffffffc0203db0:	fef59ae3          	bne	a1,a5,ffffffffc0203da4 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0203db4:	853e                	mv	a0,a5
ffffffffc0203db6:	8082                	ret
    size_t cnt = 0;
ffffffffc0203db8:	4781                	li	a5,0
}
ffffffffc0203dba:	853e                	mv	a0,a5
ffffffffc0203dbc:	8082                	ret

ffffffffc0203dbe <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203dbe:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203dc0:	0585                	addi	a1,a1,1
ffffffffc0203dc2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203dc6:	0785                	addi	a5,a5,1
ffffffffc0203dc8:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203dcc:	fb75                	bnez	a4,ffffffffc0203dc0 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203dce:	8082                	ret

ffffffffc0203dd0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203dd0:	00054783          	lbu	a5,0(a0)
ffffffffc0203dd4:	0005c703          	lbu	a4,0(a1)
ffffffffc0203dd8:	cb91                	beqz	a5,ffffffffc0203dec <strcmp+0x1c>
ffffffffc0203dda:	00e79c63          	bne	a5,a4,ffffffffc0203df2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0203dde:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203de0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0203de4:	0585                	addi	a1,a1,1
ffffffffc0203de6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203dea:	fbe5                	bnez	a5,ffffffffc0203dda <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203dec:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203dee:	9d19                	subw	a0,a0,a4
ffffffffc0203df0:	8082                	ret
ffffffffc0203df2:	0007851b          	sext.w	a0,a5
ffffffffc0203df6:	9d19                	subw	a0,a0,a4
ffffffffc0203df8:	8082                	ret

ffffffffc0203dfa <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203dfa:	00054783          	lbu	a5,0(a0)
ffffffffc0203dfe:	cb91                	beqz	a5,ffffffffc0203e12 <strchr+0x18>
        if (*s == c) {
ffffffffc0203e00:	00b79563          	bne	a5,a1,ffffffffc0203e0a <strchr+0x10>
ffffffffc0203e04:	a809                	j	ffffffffc0203e16 <strchr+0x1c>
ffffffffc0203e06:	00b78763          	beq	a5,a1,ffffffffc0203e14 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0203e0a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203e0c:	00054783          	lbu	a5,0(a0)
ffffffffc0203e10:	fbfd                	bnez	a5,ffffffffc0203e06 <strchr+0xc>
    }
    return NULL;
ffffffffc0203e12:	4501                	li	a0,0
}
ffffffffc0203e14:	8082                	ret
ffffffffc0203e16:	8082                	ret

ffffffffc0203e18 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203e18:	ca01                	beqz	a2,ffffffffc0203e28 <memset+0x10>
ffffffffc0203e1a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203e1c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203e1e:	0785                	addi	a5,a5,1
ffffffffc0203e20:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203e24:	fec79de3          	bne	a5,a2,ffffffffc0203e1e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203e28:	8082                	ret

ffffffffc0203e2a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203e2a:	ca19                	beqz	a2,ffffffffc0203e40 <memcpy+0x16>
ffffffffc0203e2c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203e2e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203e30:	0585                	addi	a1,a1,1
ffffffffc0203e32:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e36:	0785                	addi	a5,a5,1
ffffffffc0203e38:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203e3c:	fec59ae3          	bne	a1,a2,ffffffffc0203e30 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203e40:	8082                	ret

ffffffffc0203e42 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203e42:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e46:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203e48:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e4c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203e4e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e52:	f022                	sd	s0,32(sp)
ffffffffc0203e54:	ec26                	sd	s1,24(sp)
ffffffffc0203e56:	e84a                	sd	s2,16(sp)
ffffffffc0203e58:	f406                	sd	ra,40(sp)
ffffffffc0203e5a:	e44e                	sd	s3,8(sp)
ffffffffc0203e5c:	84aa                	mv	s1,a0
ffffffffc0203e5e:	892e                	mv	s2,a1
ffffffffc0203e60:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203e64:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e66:	03067e63          	bleu	a6,a2,ffffffffc0203ea2 <printnum+0x60>
ffffffffc0203e6a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e6c:	00805763          	blez	s0,ffffffffc0203e7a <printnum+0x38>
ffffffffc0203e70:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e72:	85ca                	mv	a1,s2
ffffffffc0203e74:	854e                	mv	a0,s3
ffffffffc0203e76:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203e78:	fc65                	bnez	s0,ffffffffc0203e70 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e7a:	1a02                	slli	s4,s4,0x20
ffffffffc0203e7c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203e80:	00002797          	auipc	a5,0x2
ffffffffc0203e84:	1d078793          	addi	a5,a5,464 # ffffffffc0206050 <error_string+0x38>
ffffffffc0203e88:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e8a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e8c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e90:	70a2                	ld	ra,40(sp)
ffffffffc0203e92:	69a2                	ld	s3,8(sp)
ffffffffc0203e94:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e96:	85ca                	mv	a1,s2
ffffffffc0203e98:	8326                	mv	t1,s1
}
ffffffffc0203e9a:	6942                	ld	s2,16(sp)
ffffffffc0203e9c:	64e2                	ld	s1,24(sp)
ffffffffc0203e9e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ea0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203ea2:	03065633          	divu	a2,a2,a6
ffffffffc0203ea6:	8722                	mv	a4,s0
ffffffffc0203ea8:	f9bff0ef          	jal	ra,ffffffffc0203e42 <printnum>
ffffffffc0203eac:	b7f9                	j	ffffffffc0203e7a <printnum+0x38>

ffffffffc0203eae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203eae:	7119                	addi	sp,sp,-128
ffffffffc0203eb0:	f4a6                	sd	s1,104(sp)
ffffffffc0203eb2:	f0ca                	sd	s2,96(sp)
ffffffffc0203eb4:	e8d2                	sd	s4,80(sp)
ffffffffc0203eb6:	e4d6                	sd	s5,72(sp)
ffffffffc0203eb8:	e0da                	sd	s6,64(sp)
ffffffffc0203eba:	fc5e                	sd	s7,56(sp)
ffffffffc0203ebc:	f862                	sd	s8,48(sp)
ffffffffc0203ebe:	f06a                	sd	s10,32(sp)
ffffffffc0203ec0:	fc86                	sd	ra,120(sp)
ffffffffc0203ec2:	f8a2                	sd	s0,112(sp)
ffffffffc0203ec4:	ecce                	sd	s3,88(sp)
ffffffffc0203ec6:	f466                	sd	s9,40(sp)
ffffffffc0203ec8:	ec6e                	sd	s11,24(sp)
ffffffffc0203eca:	892a                	mv	s2,a0
ffffffffc0203ecc:	84ae                	mv	s1,a1
ffffffffc0203ece:	8d32                	mv	s10,a2
ffffffffc0203ed0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203ed2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ed4:	00002a17          	auipc	s4,0x2
ffffffffc0203ed8:	feca0a13          	addi	s4,s4,-20 # ffffffffc0205ec0 <default_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203edc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203ee0:	00002c17          	auipc	s8,0x2
ffffffffc0203ee4:	138c0c13          	addi	s8,s8,312 # ffffffffc0206018 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ee8:	000d4503          	lbu	a0,0(s10)
ffffffffc0203eec:	02500793          	li	a5,37
ffffffffc0203ef0:	001d0413          	addi	s0,s10,1
ffffffffc0203ef4:	00f50e63          	beq	a0,a5,ffffffffc0203f10 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203ef8:	c521                	beqz	a0,ffffffffc0203f40 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203efa:	02500993          	li	s3,37
ffffffffc0203efe:	a011                	j	ffffffffc0203f02 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203f00:	c121                	beqz	a0,ffffffffc0203f40 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203f02:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f04:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203f06:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f08:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203f0c:	ff351ae3          	bne	a0,s3,ffffffffc0203f00 <vprintfmt+0x52>
ffffffffc0203f10:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203f14:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203f18:	4981                	li	s3,0
ffffffffc0203f1a:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203f1c:	5cfd                	li	s9,-1
ffffffffc0203f1e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f20:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203f24:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f26:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203f2a:	0ff6f693          	andi	a3,a3,255
ffffffffc0203f2e:	00140d13          	addi	s10,s0,1
ffffffffc0203f32:	20d5e563          	bltu	a1,a3,ffffffffc020413c <vprintfmt+0x28e>
ffffffffc0203f36:	068a                	slli	a3,a3,0x2
ffffffffc0203f38:	96d2                	add	a3,a3,s4
ffffffffc0203f3a:	4294                	lw	a3,0(a3)
ffffffffc0203f3c:	96d2                	add	a3,a3,s4
ffffffffc0203f3e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203f40:	70e6                	ld	ra,120(sp)
ffffffffc0203f42:	7446                	ld	s0,112(sp)
ffffffffc0203f44:	74a6                	ld	s1,104(sp)
ffffffffc0203f46:	7906                	ld	s2,96(sp)
ffffffffc0203f48:	69e6                	ld	s3,88(sp)
ffffffffc0203f4a:	6a46                	ld	s4,80(sp)
ffffffffc0203f4c:	6aa6                	ld	s5,72(sp)
ffffffffc0203f4e:	6b06                	ld	s6,64(sp)
ffffffffc0203f50:	7be2                	ld	s7,56(sp)
ffffffffc0203f52:	7c42                	ld	s8,48(sp)
ffffffffc0203f54:	7ca2                	ld	s9,40(sp)
ffffffffc0203f56:	7d02                	ld	s10,32(sp)
ffffffffc0203f58:	6de2                	ld	s11,24(sp)
ffffffffc0203f5a:	6109                	addi	sp,sp,128
ffffffffc0203f5c:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203f5e:	4705                	li	a4,1
ffffffffc0203f60:	008a8593          	addi	a1,s5,8
ffffffffc0203f64:	01074463          	blt	a4,a6,ffffffffc0203f6c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203f68:	26080363          	beqz	a6,ffffffffc02041ce <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203f6c:	000ab603          	ld	a2,0(s5)
ffffffffc0203f70:	46c1                	li	a3,16
ffffffffc0203f72:	8aae                	mv	s5,a1
ffffffffc0203f74:	a06d                	j	ffffffffc020401e <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203f76:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203f7a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f7c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f7e:	b765                	j	ffffffffc0203f26 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203f80:	000aa503          	lw	a0,0(s5)
ffffffffc0203f84:	85a6                	mv	a1,s1
ffffffffc0203f86:	0aa1                	addi	s5,s5,8
ffffffffc0203f88:	9902                	jalr	s2
            break;
ffffffffc0203f8a:	bfb9                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f8c:	4705                	li	a4,1
ffffffffc0203f8e:	008a8993          	addi	s3,s5,8
ffffffffc0203f92:	01074463          	blt	a4,a6,ffffffffc0203f9a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f96:	22080463          	beqz	a6,ffffffffc02041be <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f9a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f9e:	24044463          	bltz	s0,ffffffffc02041e6 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203fa2:	8622                	mv	a2,s0
ffffffffc0203fa4:	8ace                	mv	s5,s3
ffffffffc0203fa6:	46a9                	li	a3,10
ffffffffc0203fa8:	a89d                	j	ffffffffc020401e <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203faa:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fae:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203fb0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203fb2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203fb6:	8fb5                	xor	a5,a5,a3
ffffffffc0203fb8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fbc:	1ad74363          	blt	a4,a3,ffffffffc0204162 <vprintfmt+0x2b4>
ffffffffc0203fc0:	00369793          	slli	a5,a3,0x3
ffffffffc0203fc4:	97e2                	add	a5,a5,s8
ffffffffc0203fc6:	639c                	ld	a5,0(a5)
ffffffffc0203fc8:	18078d63          	beqz	a5,ffffffffc0204162 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203fcc:	86be                	mv	a3,a5
ffffffffc0203fce:	00002617          	auipc	a2,0x2
ffffffffc0203fd2:	13260613          	addi	a2,a2,306 # ffffffffc0206100 <error_string+0xe8>
ffffffffc0203fd6:	85a6                	mv	a1,s1
ffffffffc0203fd8:	854a                	mv	a0,s2
ffffffffc0203fda:	240000ef          	jal	ra,ffffffffc020421a <printfmt>
ffffffffc0203fde:	b729                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203fe0:	00144603          	lbu	a2,1(s0)
ffffffffc0203fe4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fe6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203fe8:	bf3d                	j	ffffffffc0203f26 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203fea:	4705                	li	a4,1
ffffffffc0203fec:	008a8593          	addi	a1,s5,8
ffffffffc0203ff0:	01074463          	blt	a4,a6,ffffffffc0203ff8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203ff4:	1e080263          	beqz	a6,ffffffffc02041d8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203ff8:	000ab603          	ld	a2,0(s5)
ffffffffc0203ffc:	46a1                	li	a3,8
ffffffffc0203ffe:	8aae                	mv	s5,a1
ffffffffc0204000:	a839                	j	ffffffffc020401e <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204002:	03000513          	li	a0,48
ffffffffc0204006:	85a6                	mv	a1,s1
ffffffffc0204008:	e03e                	sd	a5,0(sp)
ffffffffc020400a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020400c:	85a6                	mv	a1,s1
ffffffffc020400e:	07800513          	li	a0,120
ffffffffc0204012:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204014:	0aa1                	addi	s5,s5,8
ffffffffc0204016:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020401a:	6782                	ld	a5,0(sp)
ffffffffc020401c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020401e:	876e                	mv	a4,s11
ffffffffc0204020:	85a6                	mv	a1,s1
ffffffffc0204022:	854a                	mv	a0,s2
ffffffffc0204024:	e1fff0ef          	jal	ra,ffffffffc0203e42 <printnum>
            break;
ffffffffc0204028:	b5c1                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020402a:	000ab603          	ld	a2,0(s5)
ffffffffc020402e:	0aa1                	addi	s5,s5,8
ffffffffc0204030:	1c060663          	beqz	a2,ffffffffc02041fc <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204034:	00160413          	addi	s0,a2,1
ffffffffc0204038:	17b05c63          	blez	s11,ffffffffc02041b0 <vprintfmt+0x302>
ffffffffc020403c:	02d00593          	li	a1,45
ffffffffc0204040:	14b79263          	bne	a5,a1,ffffffffc0204184 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204044:	00064783          	lbu	a5,0(a2)
ffffffffc0204048:	0007851b          	sext.w	a0,a5
ffffffffc020404c:	c905                	beqz	a0,ffffffffc020407c <vprintfmt+0x1ce>
ffffffffc020404e:	000cc563          	bltz	s9,ffffffffc0204058 <vprintfmt+0x1aa>
ffffffffc0204052:	3cfd                	addiw	s9,s9,-1
ffffffffc0204054:	036c8263          	beq	s9,s6,ffffffffc0204078 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204058:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020405a:	18098463          	beqz	s3,ffffffffc02041e2 <vprintfmt+0x334>
ffffffffc020405e:	3781                	addiw	a5,a5,-32
ffffffffc0204060:	18fbf163          	bleu	a5,s7,ffffffffc02041e2 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204064:	03f00513          	li	a0,63
ffffffffc0204068:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020406a:	0405                	addi	s0,s0,1
ffffffffc020406c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204070:	3dfd                	addiw	s11,s11,-1
ffffffffc0204072:	0007851b          	sext.w	a0,a5
ffffffffc0204076:	fd61                	bnez	a0,ffffffffc020404e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204078:	e7b058e3          	blez	s11,ffffffffc0203ee8 <vprintfmt+0x3a>
ffffffffc020407c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020407e:	85a6                	mv	a1,s1
ffffffffc0204080:	02000513          	li	a0,32
ffffffffc0204084:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204086:	e60d81e3          	beqz	s11,ffffffffc0203ee8 <vprintfmt+0x3a>
ffffffffc020408a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020408c:	85a6                	mv	a1,s1
ffffffffc020408e:	02000513          	li	a0,32
ffffffffc0204092:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204094:	fe0d94e3          	bnez	s11,ffffffffc020407c <vprintfmt+0x1ce>
ffffffffc0204098:	bd81                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020409a:	4705                	li	a4,1
ffffffffc020409c:	008a8593          	addi	a1,s5,8
ffffffffc02040a0:	01074463          	blt	a4,a6,ffffffffc02040a8 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02040a4:	12080063          	beqz	a6,ffffffffc02041c4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02040a8:	000ab603          	ld	a2,0(s5)
ffffffffc02040ac:	46a9                	li	a3,10
ffffffffc02040ae:	8aae                	mv	s5,a1
ffffffffc02040b0:	b7bd                	j	ffffffffc020401e <vprintfmt+0x170>
ffffffffc02040b2:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02040b6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040ba:	846a                	mv	s0,s10
ffffffffc02040bc:	b5ad                	j	ffffffffc0203f26 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02040be:	85a6                	mv	a1,s1
ffffffffc02040c0:	02500513          	li	a0,37
ffffffffc02040c4:	9902                	jalr	s2
            break;
ffffffffc02040c6:	b50d                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02040c8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02040cc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02040d0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d2:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02040d4:	e40dd9e3          	bgez	s11,ffffffffc0203f26 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02040d8:	8de6                	mv	s11,s9
ffffffffc02040da:	5cfd                	li	s9,-1
ffffffffc02040dc:	b5a9                	j	ffffffffc0203f26 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02040de:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02040e2:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040e6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040e8:	bd3d                	j	ffffffffc0203f26 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02040ea:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02040ee:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02040f4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02040f8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040fc:	fcd56ce3          	bltu	a0,a3,ffffffffc02040d4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204100:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204102:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204106:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020410a:	0196873b          	addw	a4,a3,s9
ffffffffc020410e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204112:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204116:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020411a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020411e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204122:	fcd57fe3          	bleu	a3,a0,ffffffffc0204100 <vprintfmt+0x252>
ffffffffc0204126:	b77d                	j	ffffffffc02040d4 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204128:	fffdc693          	not	a3,s11
ffffffffc020412c:	96fd                	srai	a3,a3,0x3f
ffffffffc020412e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204132:	00144603          	lbu	a2,1(s0)
ffffffffc0204136:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204138:	846a                	mv	s0,s10
ffffffffc020413a:	b3f5                	j	ffffffffc0203f26 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020413c:	85a6                	mv	a1,s1
ffffffffc020413e:	02500513          	li	a0,37
ffffffffc0204142:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204144:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204148:	02500793          	li	a5,37
ffffffffc020414c:	8d22                	mv	s10,s0
ffffffffc020414e:	d8f70de3          	beq	a4,a5,ffffffffc0203ee8 <vprintfmt+0x3a>
ffffffffc0204152:	02500713          	li	a4,37
ffffffffc0204156:	1d7d                	addi	s10,s10,-1
ffffffffc0204158:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020415c:	fee79de3          	bne	a5,a4,ffffffffc0204156 <vprintfmt+0x2a8>
ffffffffc0204160:	b361                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204162:	00002617          	auipc	a2,0x2
ffffffffc0204166:	f8e60613          	addi	a2,a2,-114 # ffffffffc02060f0 <error_string+0xd8>
ffffffffc020416a:	85a6                	mv	a1,s1
ffffffffc020416c:	854a                	mv	a0,s2
ffffffffc020416e:	0ac000ef          	jal	ra,ffffffffc020421a <printfmt>
ffffffffc0204172:	bb9d                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204174:	00002617          	auipc	a2,0x2
ffffffffc0204178:	f7460613          	addi	a2,a2,-140 # ffffffffc02060e8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020417c:	00002417          	auipc	s0,0x2
ffffffffc0204180:	f6d40413          	addi	s0,s0,-147 # ffffffffc02060e9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204184:	8532                	mv	a0,a2
ffffffffc0204186:	85e6                	mv	a1,s9
ffffffffc0204188:	e032                	sd	a2,0(sp)
ffffffffc020418a:	e43e                	sd	a5,8(sp)
ffffffffc020418c:	c0dff0ef          	jal	ra,ffffffffc0203d98 <strnlen>
ffffffffc0204190:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204194:	6602                	ld	a2,0(sp)
ffffffffc0204196:	01b05d63          	blez	s11,ffffffffc02041b0 <vprintfmt+0x302>
ffffffffc020419a:	67a2                	ld	a5,8(sp)
ffffffffc020419c:	2781                	sext.w	a5,a5
ffffffffc020419e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02041a0:	6522                	ld	a0,8(sp)
ffffffffc02041a2:	85a6                	mv	a1,s1
ffffffffc02041a4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041a6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02041a8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041aa:	6602                	ld	a2,0(sp)
ffffffffc02041ac:	fe0d9ae3          	bnez	s11,ffffffffc02041a0 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041b0:	00064783          	lbu	a5,0(a2)
ffffffffc02041b4:	0007851b          	sext.w	a0,a5
ffffffffc02041b8:	e8051be3          	bnez	a0,ffffffffc020404e <vprintfmt+0x1a0>
ffffffffc02041bc:	b335                	j	ffffffffc0203ee8 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02041be:	000aa403          	lw	s0,0(s5)
ffffffffc02041c2:	bbf1                	j	ffffffffc0203f9e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02041c4:	000ae603          	lwu	a2,0(s5)
ffffffffc02041c8:	46a9                	li	a3,10
ffffffffc02041ca:	8aae                	mv	s5,a1
ffffffffc02041cc:	bd89                	j	ffffffffc020401e <vprintfmt+0x170>
ffffffffc02041ce:	000ae603          	lwu	a2,0(s5)
ffffffffc02041d2:	46c1                	li	a3,16
ffffffffc02041d4:	8aae                	mv	s5,a1
ffffffffc02041d6:	b5a1                	j	ffffffffc020401e <vprintfmt+0x170>
ffffffffc02041d8:	000ae603          	lwu	a2,0(s5)
ffffffffc02041dc:	46a1                	li	a3,8
ffffffffc02041de:	8aae                	mv	s5,a1
ffffffffc02041e0:	bd3d                	j	ffffffffc020401e <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02041e2:	9902                	jalr	s2
ffffffffc02041e4:	b559                	j	ffffffffc020406a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02041e6:	85a6                	mv	a1,s1
ffffffffc02041e8:	02d00513          	li	a0,45
ffffffffc02041ec:	e03e                	sd	a5,0(sp)
ffffffffc02041ee:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02041f0:	8ace                	mv	s5,s3
ffffffffc02041f2:	40800633          	neg	a2,s0
ffffffffc02041f6:	46a9                	li	a3,10
ffffffffc02041f8:	6782                	ld	a5,0(sp)
ffffffffc02041fa:	b515                	j	ffffffffc020401e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02041fc:	01b05663          	blez	s11,ffffffffc0204208 <vprintfmt+0x35a>
ffffffffc0204200:	02d00693          	li	a3,45
ffffffffc0204204:	f6d798e3          	bne	a5,a3,ffffffffc0204174 <vprintfmt+0x2c6>
ffffffffc0204208:	00002417          	auipc	s0,0x2
ffffffffc020420c:	ee140413          	addi	s0,s0,-287 # ffffffffc02060e9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204210:	02800513          	li	a0,40
ffffffffc0204214:	02800793          	li	a5,40
ffffffffc0204218:	bd1d                	j	ffffffffc020404e <vprintfmt+0x1a0>

ffffffffc020421a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020421a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020421c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204220:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204222:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204224:	ec06                	sd	ra,24(sp)
ffffffffc0204226:	f83a                	sd	a4,48(sp)
ffffffffc0204228:	fc3e                	sd	a5,56(sp)
ffffffffc020422a:	e0c2                	sd	a6,64(sp)
ffffffffc020422c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020422e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204230:	c7fff0ef          	jal	ra,ffffffffc0203eae <vprintfmt>
}
ffffffffc0204234:	60e2                	ld	ra,24(sp)
ffffffffc0204236:	6161                	addi	sp,sp,80
ffffffffc0204238:	8082                	ret

ffffffffc020423a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020423a:	715d                	addi	sp,sp,-80
ffffffffc020423c:	e486                	sd	ra,72(sp)
ffffffffc020423e:	e0a2                	sd	s0,64(sp)
ffffffffc0204240:	fc26                	sd	s1,56(sp)
ffffffffc0204242:	f84a                	sd	s2,48(sp)
ffffffffc0204244:	f44e                	sd	s3,40(sp)
ffffffffc0204246:	f052                	sd	s4,32(sp)
ffffffffc0204248:	ec56                	sd	s5,24(sp)
ffffffffc020424a:	e85a                	sd	s6,16(sp)
ffffffffc020424c:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020424e:	c901                	beqz	a0,ffffffffc020425e <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0204250:	85aa                	mv	a1,a0
ffffffffc0204252:	00002517          	auipc	a0,0x2
ffffffffc0204256:	eae50513          	addi	a0,a0,-338 # ffffffffc0206100 <error_string+0xe8>
ffffffffc020425a:	e65fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc020425e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204260:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204262:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204264:	4aa9                	li	s5,10
ffffffffc0204266:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204268:	0000db97          	auipc	s7,0xd
ffffffffc020426c:	dd8b8b93          	addi	s7,s7,-552 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204270:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204274:	e83fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204278:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020427a:	00054b63          	bltz	a0,ffffffffc0204290 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020427e:	00a95b63          	ble	a0,s2,ffffffffc0204294 <readline+0x5a>
ffffffffc0204282:	029a5463          	ble	s1,s4,ffffffffc02042aa <readline+0x70>
        c = getchar();
ffffffffc0204286:	e71fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc020428a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020428c:	fe0559e3          	bgez	a0,ffffffffc020427e <readline+0x44>
            return NULL;
ffffffffc0204290:	4501                	li	a0,0
ffffffffc0204292:	a099                	j	ffffffffc02042d8 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204294:	03341463          	bne	s0,s3,ffffffffc02042bc <readline+0x82>
ffffffffc0204298:	e8b9                	bnez	s1,ffffffffc02042ee <readline+0xb4>
        c = getchar();
ffffffffc020429a:	e5dfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc020429e:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02042a0:	fe0548e3          	bltz	a0,ffffffffc0204290 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042a4:	fea958e3          	ble	a0,s2,ffffffffc0204294 <readline+0x5a>
ffffffffc02042a8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02042aa:	8522                	mv	a0,s0
ffffffffc02042ac:	e47fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc02042b0:	009b87b3          	add	a5,s7,s1
ffffffffc02042b4:	00878023          	sb	s0,0(a5)
ffffffffc02042b8:	2485                	addiw	s1,s1,1
ffffffffc02042ba:	bf6d                	j	ffffffffc0204274 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02042bc:	01540463          	beq	s0,s5,ffffffffc02042c4 <readline+0x8a>
ffffffffc02042c0:	fb641ae3          	bne	s0,s6,ffffffffc0204274 <readline+0x3a>
            cputchar(c);
ffffffffc02042c4:	8522                	mv	a0,s0
ffffffffc02042c6:	e2dfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc02042ca:	0000d517          	auipc	a0,0xd
ffffffffc02042ce:	d7650513          	addi	a0,a0,-650 # ffffffffc0211040 <buf>
ffffffffc02042d2:	94aa                	add	s1,s1,a0
ffffffffc02042d4:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02042d8:	60a6                	ld	ra,72(sp)
ffffffffc02042da:	6406                	ld	s0,64(sp)
ffffffffc02042dc:	74e2                	ld	s1,56(sp)
ffffffffc02042de:	7942                	ld	s2,48(sp)
ffffffffc02042e0:	79a2                	ld	s3,40(sp)
ffffffffc02042e2:	7a02                	ld	s4,32(sp)
ffffffffc02042e4:	6ae2                	ld	s5,24(sp)
ffffffffc02042e6:	6b42                	ld	s6,16(sp)
ffffffffc02042e8:	6ba2                	ld	s7,8(sp)
ffffffffc02042ea:	6161                	addi	sp,sp,80
ffffffffc02042ec:	8082                	ret
            cputchar(c);
ffffffffc02042ee:	4521                	li	a0,8
ffffffffc02042f0:	e03fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc02042f4:	34fd                	addiw	s1,s1,-1
ffffffffc02042f6:	bfbd                	j	ffffffffc0204274 <readline+0x3a>
