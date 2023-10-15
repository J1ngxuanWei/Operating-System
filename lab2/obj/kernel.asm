
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	44a60613          	addi	a2,a2,1098 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2f8010ef          	jal	ra,ffffffffc0201346 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	81250513          	addi	a0,a0,-2030 # ffffffffc0201868 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	04b000ef          	jal	ra,ffffffffc02008b4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	31a010ef          	jal	ra,ffffffffc02013c4 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	2e6010ef          	jal	ra,ffffffffc02013c4 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013e:	00006317          	auipc	t1,0x6
ffffffffc0200142:	2d230313          	addi	t1,t1,722 # ffffffffc0206410 <is_panic>
ffffffffc0200146:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020014a:	715d                	addi	sp,sp,-80
ffffffffc020014c:	ec06                	sd	ra,24(sp)
ffffffffc020014e:	e822                	sd	s0,16(sp)
ffffffffc0200150:	f436                	sd	a3,40(sp)
ffffffffc0200152:	f83a                	sd	a4,48(sp)
ffffffffc0200154:	fc3e                	sd	a5,56(sp)
ffffffffc0200156:	e0c2                	sd	a6,64(sp)
ffffffffc0200158:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020015a:	02031c63          	bnez	t1,ffffffffc0200192 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015e:	4785                	li	a5,1
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	00006717          	auipc	a4,0x6
ffffffffc0200166:	2af72723          	sw	a5,686(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016a:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020016c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00001517          	auipc	a0,0x1
ffffffffc0200174:	71850513          	addi	a0,a0,1816 # ffffffffc0201888 <etext+0x24>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f15ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	81a50513          	addi	a0,a0,-2022 # ffffffffc02019a0 <etext+0x13c>
ffffffffc020018e:	f29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200192:	2d2000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200196:	4501                	li	a0,0
ffffffffc0200198:	132000ef          	jal	ra,ffffffffc02002ca <kmonitor>
ffffffffc020019c:	bfed                	j	ffffffffc0200196 <__panic+0x58>

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00001517          	auipc	a0,0x1
ffffffffc02001a4:	73850513          	addi	a0,a0,1848 # ffffffffc02018d8 <etext+0x74>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00001517          	auipc	a0,0x1
ffffffffc02001ba:	74250513          	addi	a0,a0,1858 # ffffffffc02018f8 <etext+0x94>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00001597          	auipc	a1,0x1
ffffffffc02001c6:	6a258593          	addi	a1,a1,1698 # ffffffffc0201864 <etext>
ffffffffc02001ca:	00001517          	auipc	a0,0x1
ffffffffc02001ce:	74e50513          	addi	a0,a0,1870 # ffffffffc0201918 <etext+0xb4>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e3a58593          	addi	a1,a1,-454 # ffffffffc0206010 <edata>
ffffffffc02001de:	00001517          	auipc	a0,0x1
ffffffffc02001e2:	75a50513          	addi	a0,a0,1882 # ffffffffc0201938 <etext+0xd4>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	29e58593          	addi	a1,a1,670 # ffffffffc0206488 <end>
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	76650513          	addi	a0,a0,1894 # ffffffffc0201958 <etext+0xf4>
ffffffffc02001fa:	ebdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	00006597          	auipc	a1,0x6
ffffffffc0200202:	68958593          	addi	a1,a1,1673 # ffffffffc0206887 <end+0x3ff>
ffffffffc0200206:	00000797          	auipc	a5,0x0
ffffffffc020020a:	e3078793          	addi	a5,a5,-464 # ffffffffc0200036 <kern_init>
ffffffffc020020e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200212:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200218:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021c:	95be                	add	a1,a1,a5
ffffffffc020021e:	85a9                	srai	a1,a1,0xa
ffffffffc0200220:	00001517          	auipc	a0,0x1
ffffffffc0200224:	75850513          	addi	a0,a0,1880 # ffffffffc0201978 <etext+0x114>
}
ffffffffc0200228:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020022a:	e8dff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020022e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200230:	00001617          	auipc	a2,0x1
ffffffffc0200234:	67860613          	addi	a2,a2,1656 # ffffffffc02018a8 <etext+0x44>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00001517          	auipc	a0,0x1
ffffffffc0200240:	68450513          	addi	a0,a0,1668 # ffffffffc02018c0 <etext+0x5c>
void print_stackframe(void) {
ffffffffc0200244:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200246:	ef9ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020024a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020024c:	00002617          	auipc	a2,0x2
ffffffffc0200250:	83c60613          	addi	a2,a2,-1988 # ffffffffc0201a88 <commands+0xe0>
ffffffffc0200254:	00002597          	auipc	a1,0x2
ffffffffc0200258:	85458593          	addi	a1,a1,-1964 # ffffffffc0201aa8 <commands+0x100>
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	85450513          	addi	a0,a0,-1964 # ffffffffc0201ab0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	85660613          	addi	a2,a2,-1962 # ffffffffc0201ac0 <commands+0x118>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	87658593          	addi	a1,a1,-1930 # ffffffffc0201ae8 <commands+0x140>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	83650513          	addi	a0,a0,-1994 # ffffffffc0201ab0 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00002617          	auipc	a2,0x2
ffffffffc020028a:	87260613          	addi	a2,a2,-1934 # ffffffffc0201af8 <commands+0x150>
ffffffffc020028e:	00002597          	auipc	a1,0x2
ffffffffc0200292:	88a58593          	addi	a1,a1,-1910 # ffffffffc0201b18 <commands+0x170>
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	81a50513          	addi	a0,a0,-2022 # ffffffffc0201ab0 <commands+0x108>
ffffffffc020029e:	e19ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc02002a2:	60a2                	ld	ra,8(sp)
ffffffffc02002a4:	4501                	li	a0,0
ffffffffc02002a6:	0141                	addi	sp,sp,16
ffffffffc02002a8:	8082                	ret

ffffffffc02002aa <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ae:	ef1ff0ef          	jal	ra,ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
ffffffffc02002b4:	4501                	li	a0,0
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	8082                	ret

ffffffffc02002ba <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002be:	f71ff0ef          	jal	ra,ffffffffc020022e <print_stackframe>
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ca:	7115                	addi	sp,sp,-224
ffffffffc02002cc:	e962                	sd	s8,144(sp)
ffffffffc02002ce:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002d0:	00001517          	auipc	a0,0x1
ffffffffc02002d4:	72050513          	addi	a0,a0,1824 # ffffffffc02019f0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	ed86                	sd	ra,216(sp)
ffffffffc02002da:	e9a2                	sd	s0,208(sp)
ffffffffc02002dc:	e5a6                	sd	s1,200(sp)
ffffffffc02002de:	e1ca                	sd	s2,192(sp)
ffffffffc02002e0:	fd4e                	sd	s3,184(sp)
ffffffffc02002e2:	f952                	sd	s4,176(sp)
ffffffffc02002e4:	f556                	sd	s5,168(sp)
ffffffffc02002e6:	f15a                	sd	s6,160(sp)
ffffffffc02002e8:	ed5e                	sd	s7,152(sp)
ffffffffc02002ea:	e566                	sd	s9,136(sp)
ffffffffc02002ec:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ee:	dc9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002f2:	00001517          	auipc	a0,0x1
ffffffffc02002f6:	72650513          	addi	a0,a0,1830 # ffffffffc0201a18 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00001c97          	auipc	s9,0x1
ffffffffc020030c:	6a0c8c93          	addi	s9,s9,1696 # ffffffffc02019a8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00001997          	auipc	s3,0x1
ffffffffc0200314:	73098993          	addi	s3,s3,1840 # ffffffffc0201a40 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00001917          	auipc	s2,0x1
ffffffffc020031c:	73090913          	addi	s2,s2,1840 # ffffffffc0201a48 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00001b17          	auipc	s6,0x1
ffffffffc0200326:	72eb0b13          	addi	s6,s6,1838 # ffffffffc0201a50 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00001a97          	auipc	s5,0x1
ffffffffc020032e:	77ea8a93          	addi	s5,s5,1918 # ffffffffc0201aa8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	41a010ef          	jal	ra,ffffffffc0201750 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	7e1000ef          	jal	ra,ffffffffc0201328 <strchr>
ffffffffc020034c:	c925                	beqz	a0,ffffffffc02003bc <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
ffffffffc0200352:	00040023          	sb	zero,0(s0)
ffffffffc0200356:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	f5fd                	bnez	a1,ffffffffc0200346 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020035a:	dce9                	beqz	s1,ffffffffc0200334 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	6582                	ld	a1,0(sp)
ffffffffc020035e:	00001d17          	auipc	s10,0x1
ffffffffc0200362:	64ad0d13          	addi	s10,s10,1610 # ffffffffc02019a8 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	793000ef          	jal	ra,ffffffffc02012fe <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	77f000ef          	jal	ra,ffffffffc02012fe <strcmp>
ffffffffc0200384:	f57d                	bnez	a0,ffffffffc0200372 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200386:	00141793          	slli	a5,s0,0x1
ffffffffc020038a:	97a2                	add	a5,a5,s0
ffffffffc020038c:	078e                	slli	a5,a5,0x3
ffffffffc020038e:	97e6                	add	a5,a5,s9
ffffffffc0200390:	6b9c                	ld	a5,16(a5)
ffffffffc0200392:	8662                	mv	a2,s8
ffffffffc0200394:	002c                	addi	a1,sp,8
ffffffffc0200396:	fff4851b          	addiw	a0,s1,-1
ffffffffc020039a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020039c:	f8055ce3          	bgez	a0,ffffffffc0200334 <kmonitor+0x6a>
}
ffffffffc02003a0:	60ee                	ld	ra,216(sp)
ffffffffc02003a2:	644e                	ld	s0,208(sp)
ffffffffc02003a4:	64ae                	ld	s1,200(sp)
ffffffffc02003a6:	690e                	ld	s2,192(sp)
ffffffffc02003a8:	79ea                	ld	s3,184(sp)
ffffffffc02003aa:	7a4a                	ld	s4,176(sp)
ffffffffc02003ac:	7aaa                	ld	s5,168(sp)
ffffffffc02003ae:	7b0a                	ld	s6,160(sp)
ffffffffc02003b0:	6bea                	ld	s7,152(sp)
ffffffffc02003b2:	6c4a                	ld	s8,144(sp)
ffffffffc02003b4:	6caa                	ld	s9,136(sp)
ffffffffc02003b6:	6d0a                	ld	s10,128(sp)
ffffffffc02003b8:	612d                	addi	sp,sp,224
ffffffffc02003ba:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003bc:	00044783          	lbu	a5,0(s0)
ffffffffc02003c0:	dfc9                	beqz	a5,ffffffffc020035a <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003c2:	03448863          	beq	s1,s4,ffffffffc02003f2 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003c6:	00349793          	slli	a5,s1,0x3
ffffffffc02003ca:	0118                	addi	a4,sp,128
ffffffffc02003cc:	97ba                	add	a5,a5,a4
ffffffffc02003ce:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d6:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d8:	e591                	bnez	a1,ffffffffc02003e4 <kmonitor+0x11a>
ffffffffc02003da:	b749                	j	ffffffffc020035c <kmonitor+0x92>
            buf ++;
ffffffffc02003dc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003de:	00044583          	lbu	a1,0(s0)
ffffffffc02003e2:	ddad                	beqz	a1,ffffffffc020035c <kmonitor+0x92>
ffffffffc02003e4:	854a                	mv	a0,s2
ffffffffc02003e6:	743000ef          	jal	ra,ffffffffc0201328 <strchr>
ffffffffc02003ea:	d96d                	beqz	a0,ffffffffc02003dc <kmonitor+0x112>
ffffffffc02003ec:	00044583          	lbu	a1,0(s0)
ffffffffc02003f0:	bf91                	j	ffffffffc0200344 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003f2:	45c1                	li	a1,16
ffffffffc02003f4:	855a                	mv	a0,s6
ffffffffc02003f6:	cc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003fa:	b7f1                	j	ffffffffc02003c6 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00001517          	auipc	a0,0x1
ffffffffc0200402:	67250513          	addi	a0,a0,1650 # ffffffffc0201a70 <commands+0xc8>
ffffffffc0200406:	cb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc020040a:	b72d                	j	ffffffffc0200334 <kmonitor+0x6a>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	406010ef          	jal	ra,ffffffffc020182a <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007bf23          	sd	zero,30(a5) # ffffffffc0206448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	6f650513          	addi	a0,a0,1782 # ffffffffc0201b28 <commands+0x180>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	3de0106f          	j	ffffffffc020182a <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	3b80106f          	j	ffffffffc020180e <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	3ec0106f          	j	ffffffffc0201846 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	7bc50513          	addi	a0,a0,1980 # ffffffffc0201c40 <commands+0x298>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	7c450513          	addi	a0,a0,1988 # ffffffffc0201c58 <commands+0x2b0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	7ce50513          	addi	a0,a0,1998 # ffffffffc0201c70 <commands+0x2c8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	7d850513          	addi	a0,a0,2008 # ffffffffc0201c88 <commands+0x2e0>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	7e250513          	addi	a0,a0,2018 # ffffffffc0201ca0 <commands+0x2f8>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	7ec50513          	addi	a0,a0,2028 # ffffffffc0201cb8 <commands+0x310>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	7f650513          	addi	a0,a0,2038 # ffffffffc0201cd0 <commands+0x328>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	80050513          	addi	a0,a0,-2048 # ffffffffc0201ce8 <commands+0x340>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	80a50513          	addi	a0,a0,-2038 # ffffffffc0201d00 <commands+0x358>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	81450513          	addi	a0,a0,-2028 # ffffffffc0201d18 <commands+0x370>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	81e50513          	addi	a0,a0,-2018 # ffffffffc0201d30 <commands+0x388>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	82850513          	addi	a0,a0,-2008 # ffffffffc0201d48 <commands+0x3a0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	83250513          	addi	a0,a0,-1998 # ffffffffc0201d60 <commands+0x3b8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	83c50513          	addi	a0,a0,-1988 # ffffffffc0201d78 <commands+0x3d0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	84650513          	addi	a0,a0,-1978 # ffffffffc0201d90 <commands+0x3e8>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	85050513          	addi	a0,a0,-1968 # ffffffffc0201da8 <commands+0x400>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	85a50513          	addi	a0,a0,-1958 # ffffffffc0201dc0 <commands+0x418>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	86450513          	addi	a0,a0,-1948 # ffffffffc0201dd8 <commands+0x430>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	86e50513          	addi	a0,a0,-1938 # ffffffffc0201df0 <commands+0x448>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	87850513          	addi	a0,a0,-1928 # ffffffffc0201e08 <commands+0x460>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	88250513          	addi	a0,a0,-1918 # ffffffffc0201e20 <commands+0x478>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	88c50513          	addi	a0,a0,-1908 # ffffffffc0201e38 <commands+0x490>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	89650513          	addi	a0,a0,-1898 # ffffffffc0201e50 <commands+0x4a8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	8a050513          	addi	a0,a0,-1888 # ffffffffc0201e68 <commands+0x4c0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0201e80 <commands+0x4d8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	8b450513          	addi	a0,a0,-1868 # ffffffffc0201e98 <commands+0x4f0>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	8be50513          	addi	a0,a0,-1858 # ffffffffc0201eb0 <commands+0x508>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	8c850513          	addi	a0,a0,-1848 # ffffffffc0201ec8 <commands+0x520>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201ee0 <commands+0x538>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0201ef8 <commands+0x550>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201f10 <commands+0x568>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201f28 <commands+0x580>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201f40 <commands+0x598>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201f58 <commands+0x5b0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201f70 <commands+0x5c8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201f88 <commands+0x5e0>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	90250513          	addi	a0,a0,-1790 # ffffffffc0201fa0 <commands+0x5f8>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	48870713          	addi	a4,a4,1160 # ffffffffc0201b44 <commands+0x19c>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	50a50513          	addi	a0,a0,1290 # ffffffffc0201bd8 <commands+0x230>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	4de50513          	addi	a0,a0,1246 # ffffffffc0201bb8 <commands+0x210>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	49250513          	addi	a0,a0,1170 # ffffffffc0201b78 <commands+0x1d0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	50650513          	addi	a0,a0,1286 # ffffffffc0201bf8 <commands+0x250>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d4278793          	addi	a5,a5,-702 # ffffffffc0206448 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d2f6b723          	sd	a5,-722(a3) # ffffffffc0206448 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	4f650513          	addi	a0,a0,1270 # ffffffffc0201c20 <commands+0x278>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	46250513          	addi	a0,a0,1122 # ffffffffc0201b98 <commands+0x1f0>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	4c450513          	addi	a0,a0,1220 # ffffffffc0201c10 <commands+0x268>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020082a:	100027f3          	csrr	a5,sstatus
ffffffffc020082e:	8b89                	andi	a5,a5,2
ffffffffc0200830:	eb89                	bnez	a5,ffffffffc0200842 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200832:	00006797          	auipc	a5,0x6
ffffffffc0200836:	c2678793          	addi	a5,a5,-986 # ffffffffc0206458 <pmm_manager>
ffffffffc020083a:	639c                	ld	a5,0(a5)
ffffffffc020083c:	0187b303          	ld	t1,24(a5)
ffffffffc0200840:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e406                	sd	ra,8(sp)
ffffffffc0200846:	e022                	sd	s0,0(sp)
ffffffffc0200848:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020084a:	c1bff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020084e:	00006797          	auipc	a5,0x6
ffffffffc0200852:	c0a78793          	addi	a5,a5,-1014 # ffffffffc0206458 <pmm_manager>
ffffffffc0200856:	639c                	ld	a5,0(a5)
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	6f9c                	ld	a5,24(a5)
ffffffffc020085c:	9782                	jalr	a5
ffffffffc020085e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200864:	8522                	mv	a0,s0
ffffffffc0200866:	60a2                	ld	ra,8(sp)
ffffffffc0200868:	6402                	ld	s0,0(sp)
ffffffffc020086a:	0141                	addi	sp,sp,16
ffffffffc020086c:	8082                	ret

ffffffffc020086e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020086e:	100027f3          	csrr	a5,sstatus
ffffffffc0200872:	8b89                	andi	a5,a5,2
ffffffffc0200874:	eb89                	bnez	a5,ffffffffc0200886 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200876:	00006797          	auipc	a5,0x6
ffffffffc020087a:	be278793          	addi	a5,a5,-1054 # ffffffffc0206458 <pmm_manager>
ffffffffc020087e:	639c                	ld	a5,0(a5)
ffffffffc0200880:	0207b303          	ld	t1,32(a5)
ffffffffc0200884:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200886:	1101                	addi	sp,sp,-32
ffffffffc0200888:	ec06                	sd	ra,24(sp)
ffffffffc020088a:	e822                	sd	s0,16(sp)
ffffffffc020088c:	e426                	sd	s1,8(sp)
ffffffffc020088e:	842a                	mv	s0,a0
ffffffffc0200890:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200892:	bd3ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200896:	00006797          	auipc	a5,0x6
ffffffffc020089a:	bc278793          	addi	a5,a5,-1086 # ffffffffc0206458 <pmm_manager>
ffffffffc020089e:	639c                	ld	a5,0(a5)
ffffffffc02008a0:	85a6                	mv	a1,s1
ffffffffc02008a2:	8522                	mv	a0,s0
ffffffffc02008a4:	739c                	ld	a5,32(a5)
ffffffffc02008a6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008a8:	6442                	ld	s0,16(sp)
ffffffffc02008aa:	60e2                	ld	ra,24(sp)
ffffffffc02008ac:	64a2                	ld	s1,8(sp)
ffffffffc02008ae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02008b0:	bafff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc02008b4 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02008b4:	00002797          	auipc	a5,0x2
ffffffffc02008b8:	9f478793          	addi	a5,a5,-1548 # ffffffffc02022a8 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008bc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008be:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008c0:	00001517          	auipc	a0,0x1
ffffffffc02008c4:	6f850513          	addi	a0,a0,1784 # ffffffffc0201fb8 <commands+0x610>
void pmm_init(void) {
ffffffffc02008c8:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02008ca:	00006717          	auipc	a4,0x6
ffffffffc02008ce:	b8f73723          	sd	a5,-1138(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc02008d2:	e822                	sd	s0,16(sp)
ffffffffc02008d4:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02008d6:	00006417          	auipc	s0,0x6
ffffffffc02008da:	b8240413          	addi	s0,s0,-1150 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008de:	fd8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02008e2:	601c                	ld	a5,0(s0)
ffffffffc02008e4:	679c                	ld	a5,8(a5)
ffffffffc02008e6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008e8:	57f5                	li	a5,-3
ffffffffc02008ea:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008ec:	00001517          	auipc	a0,0x1
ffffffffc02008f0:	6e450513          	addi	a0,a0,1764 # ffffffffc0201fd0 <commands+0x628>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008f4:	00006717          	auipc	a4,0x6
ffffffffc02008f8:	b6f73623          	sd	a5,-1172(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02008fc:	fbaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200900:	46c5                	li	a3,17
ffffffffc0200902:	06ee                	slli	a3,a3,0x1b
ffffffffc0200904:	40100613          	li	a2,1025
ffffffffc0200908:	16fd                	addi	a3,a3,-1
ffffffffc020090a:	0656                	slli	a2,a2,0x15
ffffffffc020090c:	07e005b7          	lui	a1,0x7e00
ffffffffc0200910:	00001517          	auipc	a0,0x1
ffffffffc0200914:	6d850513          	addi	a0,a0,1752 # ffffffffc0201fe8 <commands+0x640>
ffffffffc0200918:	f9eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020091c:	777d                	lui	a4,0xfffff
ffffffffc020091e:	00007797          	auipc	a5,0x7
ffffffffc0200922:	b6978793          	addi	a5,a5,-1175 # ffffffffc0207487 <end+0xfff>
ffffffffc0200926:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200928:	00088737          	lui	a4,0x88
ffffffffc020092c:	00006697          	auipc	a3,0x6
ffffffffc0200930:	aee6b623          	sd	a4,-1300(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200934:	4601                	li	a2,0
ffffffffc0200936:	00006717          	auipc	a4,0x6
ffffffffc020093a:	b2f73923          	sd	a5,-1230(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020093e:	4681                	li	a3,0
ffffffffc0200940:	00006897          	auipc	a7,0x6
ffffffffc0200944:	ad888893          	addi	a7,a7,-1320 # ffffffffc0206418 <npage>
ffffffffc0200948:	00006597          	auipc	a1,0x6
ffffffffc020094c:	b2058593          	addi	a1,a1,-1248 # ffffffffc0206468 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200950:	4805                	li	a6,1
ffffffffc0200952:	fff80537          	lui	a0,0xfff80
ffffffffc0200956:	a011                	j	ffffffffc020095a <pmm_init+0xa6>
ffffffffc0200958:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020095a:	97b2                	add	a5,a5,a2
ffffffffc020095c:	07a1                	addi	a5,a5,8
ffffffffc020095e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200962:	0008b703          	ld	a4,0(a7)
ffffffffc0200966:	0685                	addi	a3,a3,1
ffffffffc0200968:	02860613          	addi	a2,a2,40
ffffffffc020096c:	00a707b3          	add	a5,a4,a0
ffffffffc0200970:	fef6e4e3          	bltu	a3,a5,ffffffffc0200958 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200974:	6190                	ld	a2,0(a1)
ffffffffc0200976:	00271793          	slli	a5,a4,0x2
ffffffffc020097a:	97ba                	add	a5,a5,a4
ffffffffc020097c:	fec006b7          	lui	a3,0xfec00
ffffffffc0200980:	078e                	slli	a5,a5,0x3
ffffffffc0200982:	96b2                	add	a3,a3,a2
ffffffffc0200984:	96be                	add	a3,a3,a5
ffffffffc0200986:	c02007b7          	lui	a5,0xc0200
ffffffffc020098a:	08f6e863          	bltu	a3,a5,ffffffffc0200a1a <pmm_init+0x166>
ffffffffc020098e:	00006497          	auipc	s1,0x6
ffffffffc0200992:	ad248493          	addi	s1,s1,-1326 # ffffffffc0206460 <va_pa_offset>
ffffffffc0200996:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200998:	45c5                	li	a1,17
ffffffffc020099a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020099c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020099e:	04b6e963          	bltu	a3,a1,ffffffffc02009f0 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02009a2:	601c                	ld	a5,0(s0)
ffffffffc02009a4:	7b9c                	ld	a5,48(a5)
ffffffffc02009a6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02009a8:	00001517          	auipc	a0,0x1
ffffffffc02009ac:	6d850513          	addi	a0,a0,1752 # ffffffffc0202080 <commands+0x6d8>
ffffffffc02009b0:	f06ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02009b4:	00004697          	auipc	a3,0x4
ffffffffc02009b8:	64c68693          	addi	a3,a3,1612 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009bc:	00006797          	auipc	a5,0x6
ffffffffc02009c0:	a6d7b223          	sd	a3,-1436(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02009c8:	06f6e563          	bltu	a3,a5,ffffffffc0200a32 <pmm_init+0x17e>
ffffffffc02009cc:	609c                	ld	a5,0(s1)
}
ffffffffc02009ce:	6442                	ld	s0,16(sp)
ffffffffc02009d0:	60e2                	ld	ra,24(sp)
ffffffffc02009d2:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009d4:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02009d6:	8e9d                	sub	a3,a3,a5
ffffffffc02009d8:	00006797          	auipc	a5,0x6
ffffffffc02009dc:	a6d7bc23          	sd	a3,-1416(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009e0:	00001517          	auipc	a0,0x1
ffffffffc02009e4:	6c050513          	addi	a0,a0,1728 # ffffffffc02020a0 <commands+0x6f8>
ffffffffc02009e8:	8636                	mv	a2,a3
}
ffffffffc02009ea:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009ec:	ecaff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02009f0:	6785                	lui	a5,0x1
ffffffffc02009f2:	17fd                	addi	a5,a5,-1
ffffffffc02009f4:	96be                	add	a3,a3,a5
ffffffffc02009f6:	77fd                	lui	a5,0xfffff
ffffffffc02009f8:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009fa:	00c6d793          	srli	a5,a3,0xc
ffffffffc02009fe:	04e7f663          	bleu	a4,a5,ffffffffc0200a4a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a02:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a04:	97aa                	add	a5,a5,a0
ffffffffc0200a06:	00279513          	slli	a0,a5,0x2
ffffffffc0200a0a:	953e                	add	a0,a0,a5
ffffffffc0200a0c:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a0e:	8d95                	sub	a1,a1,a3
ffffffffc0200a10:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a12:	81b1                	srli	a1,a1,0xc
ffffffffc0200a14:	9532                	add	a0,a0,a2
ffffffffc0200a16:	9782                	jalr	a5
ffffffffc0200a18:	b769                	j	ffffffffc02009a2 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a1a:	00001617          	auipc	a2,0x1
ffffffffc0200a1e:	5fe60613          	addi	a2,a2,1534 # ffffffffc0202018 <commands+0x670>
ffffffffc0200a22:	07100593          	li	a1,113
ffffffffc0200a26:	00001517          	auipc	a0,0x1
ffffffffc0200a2a:	61a50513          	addi	a0,a0,1562 # ffffffffc0202040 <commands+0x698>
ffffffffc0200a2e:	f10ff0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a32:	00001617          	auipc	a2,0x1
ffffffffc0200a36:	5e660613          	addi	a2,a2,1510 # ffffffffc0202018 <commands+0x670>
ffffffffc0200a3a:	08c00593          	li	a1,140
ffffffffc0200a3e:	00001517          	auipc	a0,0x1
ffffffffc0200a42:	60250513          	addi	a0,a0,1538 # ffffffffc0202040 <commands+0x698>
ffffffffc0200a46:	ef8ff0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200a4a:	00001617          	auipc	a2,0x1
ffffffffc0200a4e:	60660613          	addi	a2,a2,1542 # ffffffffc0202050 <commands+0x6a8>
ffffffffc0200a52:	06d00593          	li	a1,109
ffffffffc0200a56:	00001517          	auipc	a0,0x1
ffffffffc0200a5a:	61a50513          	addi	a0,a0,1562 # ffffffffc0202070 <commands+0x6c8>
ffffffffc0200a5e:	ee0ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200a62 <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a62:	00006797          	auipc	a5,0x6
ffffffffc0200a66:	a0e78793          	addi	a5,a5,-1522 # ffffffffc0206470 <free_area>
ffffffffc0200a6a:	e79c                	sd	a5,8(a5)
ffffffffc0200a6c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200a6e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200a72:	8082                	ret

ffffffffc0200a74 <buddy_nr_free_pages>:
    }
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200a74:	00006517          	auipc	a0,0x6
ffffffffc0200a78:	a0c56503          	lwu	a0,-1524(a0) # ffffffffc0206480 <free_area+0x10>
ffffffffc0200a7c:	8082                	ret

ffffffffc0200a7e <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200a7e:	1141                	addi	sp,sp,-16
ffffffffc0200a80:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a82:	18058d63          	beqz	a1,ffffffffc0200c1c <buddy_free_pages+0x19e>
    int64_t length = log2_round_up(n);
ffffffffc0200a86:	0005881b          	sext.w	a6,a1
    while(n!=1){
ffffffffc0200a8a:	4785                	li	a5,1
ffffffffc0200a8c:	16f80563          	beq	a6,a5,ffffffffc0200bf6 <buddy_free_pages+0x178>
ffffffffc0200a90:	87c2                	mv	a5,a6
    int32_t result=0;
ffffffffc0200a92:	4701                	li	a4,0
    while(n!=1){
ffffffffc0200a94:	4885                	li	a7,1
ffffffffc0200a96:	a011                	j	ffffffffc0200a9a <buddy_free_pages+0x1c>
        result++;
ffffffffc0200a98:	8732                	mv	a4,a2
        n/=2;
ffffffffc0200a9a:	01f7d69b          	srliw	a3,a5,0x1f
ffffffffc0200a9e:	9fb5                	addw	a5,a5,a3
ffffffffc0200aa0:	4017d79b          	sraiw	a5,a5,0x1
        result++;
ffffffffc0200aa4:	0017061b          	addiw	a2,a4,1
    while(n!=1){
ffffffffc0200aa8:	ff1798e3          	bne	a5,a7,ffffffffc0200a98 <buddy_free_pages+0x1a>
    if(temp%2==1)
ffffffffc0200aac:	41f8569b          	sraiw	a3,a6,0x1f
ffffffffc0200ab0:	01f6d89b          	srliw	a7,a3,0x1f
ffffffffc0200ab4:	010886bb          	addw	a3,a7,a6
ffffffffc0200ab8:	8a85                	andi	a3,a3,1
ffffffffc0200aba:	411686bb          	subw	a3,a3,a7
ffffffffc0200abe:	12f68563          	beq	a3,a5,ffffffffc0200be8 <buddy_free_pages+0x16a>
ffffffffc0200ac2:	8832                	mv	a6,a2
    int64_t begin = (base-buddy_base);
ffffffffc0200ac4:	00006797          	auipc	a5,0x6
ffffffffc0200ac8:	96c78793          	addi	a5,a5,-1684 # ffffffffc0206430 <buddy_base>
ffffffffc0200acc:	639c                	ld	a5,0(a5)
ffffffffc0200ace:	00001717          	auipc	a4,0x1
ffffffffc0200ad2:	74a70713          	addi	a4,a4,1866 # ffffffffc0202218 <commands+0x870>
ffffffffc0200ad6:	6318                	ld	a4,0(a4)
ffffffffc0200ad8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200adc:	878d                	srai	a5,a5,0x3
ffffffffc0200ade:	02e787b3          	mul	a5,a5,a4
    int64_t block = BUDDY_BLOCK(begin,end);
ffffffffc0200ae2:	00006717          	auipc	a4,0x6
ffffffffc0200ae6:	95670713          	addi	a4,a4,-1706 # ffffffffc0206438 <buddy_size>
ffffffffc0200aea:	00073883          	ld	a7,0(a4)
    for (; p != base + n; p ++) {
ffffffffc0200aee:	00259713          	slli	a4,a1,0x2
ffffffffc0200af2:	00b706b3          	add	a3,a4,a1
ffffffffc0200af6:	068e                	slli	a3,a3,0x3
ffffffffc0200af8:	96aa                	add	a3,a3,a0
    int64_t block = BUDDY_BLOCK(begin,end);
ffffffffc0200afa:	0307c7b3          	div	a5,a5,a6
ffffffffc0200afe:	0308c733          	div	a4,a7,a6
ffffffffc0200b02:	97ba                	add	a5,a5,a4
    for (; p != base + n; p ++) {
ffffffffc0200b04:	00d50d63          	beq	a0,a3,ffffffffc0200b1e <buddy_free_pages+0xa0>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b08:	6518                	ld	a4,8(a0)
        assert(!PageReserved(p));
ffffffffc0200b0a:	8b05                	andi	a4,a4,1
ffffffffc0200b0c:	eb65                	bnez	a4,ffffffffc0200bfc <buddy_free_pages+0x17e>
        p->flags = 0;
ffffffffc0200b0e:	00053423          	sd	zero,8(a0)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200b12:	00052023          	sw	zero,0(a0)
    for (; p != base + n; p ++) {
ffffffffc0200b16:	02850513          	addi	a0,a0,40
ffffffffc0200b1a:	fed517e3          	bne	a0,a3,ffffffffc0200b08 <buddy_free_pages+0x8a>
    nr_free += length;
ffffffffc0200b1e:	00006717          	auipc	a4,0x6
ffffffffc0200b22:	95270713          	addi	a4,a4,-1710 # ffffffffc0206470 <free_area>
ffffffffc0200b26:	4b18                	lw	a4,16(a4)
    buddy_array[block] = length;
ffffffffc0200b28:	00006697          	auipc	a3,0x6
ffffffffc0200b2c:	90068693          	addi	a3,a3,-1792 # ffffffffc0206428 <buddy_array>
ffffffffc0200b30:	0006be03          	ld	t3,0(a3)
    nr_free += length;
ffffffffc0200b34:	9e39                	addw	a2,a2,a4
    buddy_array[block] = length;
ffffffffc0200b36:	00379713          	slli	a4,a5,0x3
ffffffffc0200b3a:	9772                	add	a4,a4,t3
    nr_free += length;
ffffffffc0200b3c:	00006697          	auipc	a3,0x6
ffffffffc0200b40:	94c6a223          	sw	a2,-1724(a3) # ffffffffc0206480 <free_area+0x10>
    buddy_array[block] = length;
ffffffffc0200b44:	01073023          	sd	a6,0(a4)
    while (block != BUDDY_ROOT) {
ffffffffc0200b48:	4705                	li	a4,1
    while(n!=1){
ffffffffc0200b4a:	4585                	li	a1,1
    while (block != BUDDY_ROOT) {
ffffffffc0200b4c:	04e78d63          	beq	a5,a4,ffffffffc0200ba6 <buddy_free_pages+0x128>
        int64_t left = BUDDY_LEFT(block);
ffffffffc0200b50:	ffe7f613          	andi	a2,a5,-2
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200b54:	00361313          	slli	t1,a2,0x3
ffffffffc0200b58:	9372                	add	t1,t1,t3
ffffffffc0200b5a:	00033803          	ld	a6,0(t1)
        block = BUDDY_PARENT(block);
ffffffffc0200b5e:	4017d513          	srai	a0,a5,0x1
    int32_t result=0;
ffffffffc0200b62:	4701                	li	a4,0
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200b64:	0006079b          	sext.w	a5,a2
        n/=2;
ffffffffc0200b68:	01f7d69b          	srliw	a3,a5,0x1f
ffffffffc0200b6c:	9fb5                	addw	a5,a5,a3
ffffffffc0200b6e:	4017d79b          	sraiw	a5,a5,0x1
        result++;
ffffffffc0200b72:	2705                	addiw	a4,a4,1
    while(n!=1){
ffffffffc0200b74:	feb79ae3          	bne	a5,a1,ffffffffc0200b68 <buddy_free_pages+0xea>
    for(int i=0;i<n;i++)
ffffffffc0200b78:	4681                	li	a3,0
    int32_t result=1;
ffffffffc0200b7a:	4785                	li	a5,1
    for(int i=0;i<n;i++)
ffffffffc0200b7c:	2685                	addiw	a3,a3,1
    result*=2;
ffffffffc0200b7e:	0017979b          	slliw	a5,a5,0x1
    for(int i=0;i<n;i++)
ffffffffc0200b82:	fee69de3          	bne	a3,a4,ffffffffc0200b7c <buddy_free_pages+0xfe>
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200b86:	02f8c7b3          	div	a5,a7,a5
ffffffffc0200b8a:	00351e93          	slli	t4,a0,0x3
ffffffffc0200b8e:	9ef2                	add	t4,t4,t3
ffffffffc0200b90:	00f80e63          	beq	a6,a5,ffffffffc0200bac <buddy_free_pages+0x12e>
ffffffffc0200b94:	00833603          	ld	a2,8(t1)
            buddy_array[block] = buddy_array[BUDDY_LEFT(block)] | buddy_array[BUDDY_RIGHT(block)];
ffffffffc0200b98:	00c86833          	or	a6,a6,a2
ffffffffc0200b9c:	010eb023          	sd	a6,0(t4)
ffffffffc0200ba0:	87aa                	mv	a5,a0
    while (block != BUDDY_ROOT) {
ffffffffc0200ba2:	fab517e3          	bne	a0,a1,ffffffffc0200b50 <buddy_free_pages+0xd2>
}
ffffffffc0200ba6:	60a2                	ld	ra,8(sp)
ffffffffc0200ba8:	0141                	addi	sp,sp,16
ffffffffc0200baa:	8082                	ret
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200bac:	0016079b          	addiw	a5,a2,1
ffffffffc0200bb0:	00833603          	ld	a2,8(t1)
    while(n!=1){
ffffffffc0200bb4:	02b78d63          	beq	a5,a1,ffffffffc0200bee <buddy_free_pages+0x170>
    int32_t result=0;
ffffffffc0200bb8:	4701                	li	a4,0
        n/=2;
ffffffffc0200bba:	01f7d69b          	srliw	a3,a5,0x1f
ffffffffc0200bbe:	9fb5                	addw	a5,a5,a3
ffffffffc0200bc0:	4017d79b          	sraiw	a5,a5,0x1
        result++;
ffffffffc0200bc4:	2705                	addiw	a4,a4,1
    while(n!=1){
ffffffffc0200bc6:	feb79ae3          	bne	a5,a1,ffffffffc0200bba <buddy_free_pages+0x13c>
    for(int i=0;i<n;i++)
ffffffffc0200bca:	4681                	li	a3,0
    int32_t result=1;
ffffffffc0200bcc:	4785                	li	a5,1
    for(int i=0;i<n;i++)
ffffffffc0200bce:	2685                	addiw	a3,a3,1
    result*=2;
ffffffffc0200bd0:	0017979b          	slliw	a5,a5,0x1
    for(int i=0;i<n;i++)
ffffffffc0200bd4:	fee69de3          	bne	a3,a4,ffffffffc0200bce <buddy_free_pages+0x150>
ffffffffc0200bd8:	02f8c7b3          	div	a5,a7,a5
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200bdc:	faf61ee3          	bne	a2,a5,ffffffffc0200b98 <buddy_free_pages+0x11a>
            buddy_array[block] = buddy_array[left]<<1;
ffffffffc0200be0:	0806                	slli	a6,a6,0x1
ffffffffc0200be2:	010eb023          	sd	a6,0(t4)
ffffffffc0200be6:	bf6d                	j	ffffffffc0200ba0 <buddy_free_pages+0x122>
ffffffffc0200be8:	0027061b          	addiw	a2,a4,2
ffffffffc0200bec:	bdd9                	j	ffffffffc0200ac2 <buddy_free_pages+0x44>
    while(n!=1){
ffffffffc0200bee:	87c6                	mv	a5,a7
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200bf0:	faf614e3          	bne	a2,a5,ffffffffc0200b98 <buddy_free_pages+0x11a>
ffffffffc0200bf4:	b7f5                	j	ffffffffc0200be0 <buddy_free_pages+0x162>
    while(n!=1){
ffffffffc0200bf6:	4805                	li	a6,1
ffffffffc0200bf8:	4605                	li	a2,1
    return result+1;
ffffffffc0200bfa:	b5e9                	j	ffffffffc0200ac4 <buddy_free_pages+0x46>
        assert(!PageReserved(p));
ffffffffc0200bfc:	00001697          	auipc	a3,0x1
ffffffffc0200c00:	65c68693          	addi	a3,a3,1628 # ffffffffc0202258 <commands+0x8b0>
ffffffffc0200c04:	00001617          	auipc	a2,0x1
ffffffffc0200c08:	62460613          	addi	a2,a2,1572 # ffffffffc0202228 <commands+0x880>
ffffffffc0200c0c:	08200593          	li	a1,130
ffffffffc0200c10:	00001517          	auipc	a0,0x1
ffffffffc0200c14:	63050513          	addi	a0,a0,1584 # ffffffffc0202240 <commands+0x898>
ffffffffc0200c18:	d26ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc0200c1c:	00001697          	auipc	a3,0x1
ffffffffc0200c20:	60468693          	addi	a3,a3,1540 # ffffffffc0202220 <commands+0x878>
ffffffffc0200c24:	00001617          	auipc	a2,0x1
ffffffffc0200c28:	60460613          	addi	a2,a2,1540 # ffffffffc0202228 <commands+0x880>
ffffffffc0200c2c:	07900593          	li	a1,121
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	61050513          	addi	a0,a0,1552 # ffffffffc0202240 <commands+0x898>
ffffffffc0200c38:	d06ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200c3c <buddy_alloc_pages>:
static struct Page * buddy_alloc_pages(size_t n) {
ffffffffc0200c3c:	1141                	addi	sp,sp,-16
ffffffffc0200c3e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c40:	1a050f63          	beqz	a0,ffffffffc0200dfe <buddy_alloc_pages+0x1c2>
    int64_t length = pow2(log2_round_up(n));
ffffffffc0200c44:	0005061b          	sext.w	a2,a0
    while(n!=1){
ffffffffc0200c48:	4785                	li	a5,1
ffffffffc0200c4a:	1af60363          	beq	a2,a5,ffffffffc0200df0 <buddy_alloc_pages+0x1b4>
ffffffffc0200c4e:	87b2                	mv	a5,a2
    int32_t result=0;
ffffffffc0200c50:	4681                	li	a3,0
    while(n!=1){
ffffffffc0200c52:	4585                	li	a1,1
ffffffffc0200c54:	a011                	j	ffffffffc0200c58 <buddy_alloc_pages+0x1c>
        result++;
ffffffffc0200c56:	86ba                	mv	a3,a4
        n/=2;
ffffffffc0200c58:	01f7d71b          	srliw	a4,a5,0x1f
ffffffffc0200c5c:	9fb9                	addw	a5,a5,a4
ffffffffc0200c5e:	4017d79b          	sraiw	a5,a5,0x1
        result++;
ffffffffc0200c62:	0016871b          	addiw	a4,a3,1
    while(n!=1){
ffffffffc0200c66:	feb798e3          	bne	a5,a1,ffffffffc0200c56 <buddy_alloc_pages+0x1a>
    if(temp%2==1)
ffffffffc0200c6a:	41f6559b          	sraiw	a1,a2,0x1f
ffffffffc0200c6e:	01f5d59b          	srliw	a1,a1,0x1f
ffffffffc0200c72:	9e2d                	addw	a2,a2,a1
ffffffffc0200c74:	8a05                	andi	a2,a2,1
ffffffffc0200c76:	9e0d                	subw	a2,a2,a1
ffffffffc0200c78:	16f60963          	beq	a2,a5,ffffffffc0200dea <buddy_alloc_pages+0x1ae>
    int32_t result=1;
ffffffffc0200c7c:	4805                	li	a6,1
    for(int i=0;i<n;i++)
ffffffffc0200c7e:	4781                	li	a5,0
ffffffffc0200c80:	2785                	addiw	a5,a5,1
    result*=2;
ffffffffc0200c82:	0018181b          	slliw	a6,a6,0x1
    for(int i=0;i<n;i++)
ffffffffc0200c86:	fee79de3          	bne	a5,a4,ffffffffc0200c80 <buddy_alloc_pages+0x44>
    if(n==1)length=1;
ffffffffc0200c8a:	4785                	li	a5,1
ffffffffc0200c8c:	00f51363          	bne	a0,a5,ffffffffc0200c92 <buddy_alloc_pages+0x56>
ffffffffc0200c90:	4805                	li	a6,1
    while (length <= buddy_array[block]) {
ffffffffc0200c92:	00005797          	auipc	a5,0x5
ffffffffc0200c96:	79678793          	addi	a5,a5,1942 # ffffffffc0206428 <buddy_array>
ffffffffc0200c9a:	0007b883          	ld	a7,0(a5)
        if (BUDDY_EMPTY(block)) {
ffffffffc0200c9e:	00005797          	auipc	a5,0x5
ffffffffc0200ca2:	79a78793          	addi	a5,a5,1946 # ffffffffc0206438 <buddy_size>
ffffffffc0200ca6:	0007be03          	ld	t3,0(a5)
ffffffffc0200caa:	0088b503          	ld	a0,8(a7)
ffffffffc0200cae:	4585                	li	a1,1
ffffffffc0200cb0:	47a1                	li	a5,8
    while(n!=1){
ffffffffc0200cb2:	4605                	li	a2,1
    while (length <= buddy_array[block]) {
ffffffffc0200cb4:	00f88333          	add	t1,a7,a5
ffffffffc0200cb8:	0005871b          	sext.w	a4,a1
ffffffffc0200cbc:	05054e63          	blt	a0,a6,ffffffffc0200d18 <buddy_alloc_pages+0xdc>
        int64_t left = BUDDY_LEFT(block);
ffffffffc0200cc0:	0586                	slli	a1,a1,0x1
        int64_t right = BUDDY_RIGHT(block);
ffffffffc0200cc2:	00158e93          	addi	t4,a1,1
    while(n!=1){
ffffffffc0200cc6:	12c70063          	beq	a4,a2,ffffffffc0200de6 <buddy_alloc_pages+0x1aa>
    int32_t result=0;
ffffffffc0200cca:	4781                	li	a5,0
        n/=2;
ffffffffc0200ccc:	01f7569b          	srliw	a3,a4,0x1f
ffffffffc0200cd0:	9f35                	addw	a4,a4,a3
ffffffffc0200cd2:	4017571b          	sraiw	a4,a4,0x1
        result++;
ffffffffc0200cd6:	2785                	addiw	a5,a5,1
    while(n!=1){
ffffffffc0200cd8:	fec71ae3          	bne	a4,a2,ffffffffc0200ccc <buddy_alloc_pages+0x90>
    for(int i=0;i<n;i++)
ffffffffc0200cdc:	4681                	li	a3,0
    int32_t result=1;
ffffffffc0200cde:	4705                	li	a4,1
    for(int i=0;i<n;i++)
ffffffffc0200ce0:	2685                	addiw	a3,a3,1
    result*=2;
ffffffffc0200ce2:	0017171b          	slliw	a4,a4,0x1
    for(int i=0;i<n;i++)
ffffffffc0200ce6:	fef69de3          	bne	a3,a5,ffffffffc0200ce0 <buddy_alloc_pages+0xa4>
ffffffffc0200cea:	02ee4733          	div	a4,t3,a4
    return result;
ffffffffc0200cee:	00359793          	slli	a5,a1,0x3
ffffffffc0200cf2:	00f886b3          	add	a3,a7,a5
        if (BUDDY_EMPTY(block)) {
ffffffffc0200cf6:	0ea70163          	beq	a4,a0,ffffffffc0200dd8 <buddy_alloc_pages+0x19c>
        } else if (length <= buddy_array[left]) { 
ffffffffc0200cfa:	6288                	ld	a0,0(a3)
ffffffffc0200cfc:	fb055ce3          	ble	a6,a0,ffffffffc0200cb4 <buddy_alloc_pages+0x78>
        } else if (length <= buddy_array[right]) {
ffffffffc0200d00:	6688                	ld	a0,8(a3)
ffffffffc0200d02:	11054e63          	blt	a0,a6,ffffffffc0200e1e <buddy_alloc_pages+0x1e2>
            block = right;
ffffffffc0200d06:	85f6                	mv	a1,t4
ffffffffc0200d08:	003e9793          	slli	a5,t4,0x3
    while (length <= buddy_array[block]) {
ffffffffc0200d0c:	00f88333          	add	t1,a7,a5
ffffffffc0200d10:	0005871b          	sext.w	a4,a1
ffffffffc0200d14:	fb0556e3          	ble	a6,a0,ffffffffc0200cc0 <buddy_alloc_pages+0x84>
    while(n!=1){
ffffffffc0200d18:	4785                	li	a5,1
ffffffffc0200d1a:	0cf70d63          	beq	a4,a5,ffffffffc0200df4 <buddy_alloc_pages+0x1b8>
ffffffffc0200d1e:	87ba                	mv	a5,a4
    int32_t result=0;
ffffffffc0200d20:	4681                	li	a3,0
    while(n!=1){
ffffffffc0200d22:	4505                	li	a0,1
        n/=2;
ffffffffc0200d24:	01f7d61b          	srliw	a2,a5,0x1f
ffffffffc0200d28:	9fb1                	addw	a5,a5,a2
ffffffffc0200d2a:	4017d79b          	sraiw	a5,a5,0x1
        result++;
ffffffffc0200d2e:	2685                	addiw	a3,a3,1
    while(n!=1){
ffffffffc0200d30:	fea79ae3          	bne	a5,a0,ffffffffc0200d24 <buddy_alloc_pages+0xe8>
    for(int i=0;i<n;i++)
ffffffffc0200d34:	4601                	li	a2,0
    int32_t result=1;
ffffffffc0200d36:	4785                	li	a5,1
    for(int i=0;i<n;i++)
ffffffffc0200d38:	2605                	addiw	a2,a2,1
    result*=2;
ffffffffc0200d3a:	0017979b          	slliw	a5,a5,0x1
    for(int i=0;i<n;i++)
ffffffffc0200d3e:	fed61de3          	bne	a2,a3,ffffffffc0200d38 <buddy_alloc_pages+0xfc>
    int strr=buddy_size*(block-pow2(log2_round_down(block)))/pow2(log2_round_down(block));
ffffffffc0200d42:	40f587b3          	sub	a5,a1,a5
ffffffffc0200d46:	03c786b3          	mul	a3,a5,t3
ffffffffc0200d4a:	4601                	li	a2,0
    while(n!=1){
ffffffffc0200d4c:	4505                	li	a0,1
        n/=2;
ffffffffc0200d4e:	01f7579b          	srliw	a5,a4,0x1f
ffffffffc0200d52:	9f3d                	addw	a4,a4,a5
ffffffffc0200d54:	4017571b          	sraiw	a4,a4,0x1
        result++;
ffffffffc0200d58:	2605                	addiw	a2,a2,1
    while(n!=1){
ffffffffc0200d5a:	fea71ae3          	bne	a4,a0,ffffffffc0200d4e <buddy_alloc_pages+0x112>
    for(int i=0;i<n;i++)
ffffffffc0200d5e:	4701                	li	a4,0
    int32_t result=1;
ffffffffc0200d60:	4785                	li	a5,1
    for(int i=0;i<n;i++)
ffffffffc0200d62:	2705                	addiw	a4,a4,1
    result*=2;
ffffffffc0200d64:	0017979b          	slliw	a5,a5,0x1
    for(int i=0;i<n;i++)
ffffffffc0200d68:	fee61de3          	bne	a2,a4,ffffffffc0200d62 <buddy_alloc_pages+0x126>
ffffffffc0200d6c:	02f6c7b3          	div	a5,a3,a5
    page = buddy_base;
ffffffffc0200d70:	00005697          	auipc	a3,0x5
ffffffffc0200d74:	6c068693          	addi	a3,a3,1728 # ffffffffc0206430 <buddy_base>
    for(int i=0;i<strr;i++)
ffffffffc0200d78:	0007871b          	sext.w	a4,a5
    page = buddy_base;
ffffffffc0200d7c:	6288                	ld	a0,0(a3)
    for(int i=0;i<strr;i++)
ffffffffc0200d7e:	00e05b63          	blez	a4,ffffffffc0200d94 <buddy_alloc_pages+0x158>
    page++;
ffffffffc0200d82:	37fd                	addiw	a5,a5,-1
ffffffffc0200d84:	1782                	slli	a5,a5,0x20
ffffffffc0200d86:	9381                	srli	a5,a5,0x20
ffffffffc0200d88:	0785                	addi	a5,a5,1
ffffffffc0200d8a:	00279713          	slli	a4,a5,0x2
ffffffffc0200d8e:	97ba                	add	a5,a5,a4
ffffffffc0200d90:	078e                	slli	a5,a5,0x3
ffffffffc0200d92:	953e                	add	a0,a0,a5
    nr_free -= length;
ffffffffc0200d94:	00005797          	auipc	a5,0x5
ffffffffc0200d98:	6dc78793          	addi	a5,a5,1756 # ffffffffc0206470 <free_area>
ffffffffc0200d9c:	4b9c                	lw	a5,16(a5)
    buddy_array[block] = 0;
ffffffffc0200d9e:	00033023          	sd	zero,0(t1)
    while (block != BUDDY_ROOT) {
ffffffffc0200da2:	4705                	li	a4,1
    nr_free -= length;
ffffffffc0200da4:	4107883b          	subw	a6,a5,a6
ffffffffc0200da8:	00005797          	auipc	a5,0x5
ffffffffc0200dac:	6d07ac23          	sw	a6,1752(a5) # ffffffffc0206480 <free_area+0x10>
    while (block != BUDDY_ROOT) {
ffffffffc0200db0:	4605                	li	a2,1
ffffffffc0200db2:	02e58063          	beq	a1,a4,ffffffffc0200dd2 <buddy_alloc_pages+0x196>
        buddy_array[block] = buddy_array[BUDDY_LEFT(block)] | buddy_array[BUDDY_RIGHT(block)];
ffffffffc0200db6:	ffe5f793          	andi	a5,a1,-2
ffffffffc0200dba:	078e                	slli	a5,a5,0x3
ffffffffc0200dbc:	97c6                	add	a5,a5,a7
ffffffffc0200dbe:	6394                	ld	a3,0(a5)
ffffffffc0200dc0:	6798                	ld	a4,8(a5)
        block = BUDDY_PARENT(block);
ffffffffc0200dc2:	8585                	srai	a1,a1,0x1
        buddy_array[block] = buddy_array[BUDDY_LEFT(block)] | buddy_array[BUDDY_RIGHT(block)];
ffffffffc0200dc4:	00359793          	slli	a5,a1,0x3
ffffffffc0200dc8:	97c6                	add	a5,a5,a7
ffffffffc0200dca:	8f55                	or	a4,a4,a3
ffffffffc0200dcc:	e398                	sd	a4,0(a5)
    while (block != BUDDY_ROOT) {
ffffffffc0200dce:	fec594e3          	bne	a1,a2,ffffffffc0200db6 <buddy_alloc_pages+0x17a>
}
ffffffffc0200dd2:	60a2                	ld	ra,8(sp)
ffffffffc0200dd4:	0141                	addi	sp,sp,16
ffffffffc0200dd6:	8082                	ret
            buddy_array[left] = buddy_array[block]>>1;
ffffffffc0200dd8:	8505                	srai	a0,a0,0x1
ffffffffc0200dda:	e288                	sd	a0,0(a3)
            buddy_array[right] = buddy_array[block]>>1;
ffffffffc0200ddc:	00033703          	ld	a4,0(t1)
ffffffffc0200de0:	8705                	srai	a4,a4,0x1
ffffffffc0200de2:	e698                	sd	a4,8(a3)
            block = left;
ffffffffc0200de4:	bdc1                	j	ffffffffc0200cb4 <buddy_alloc_pages+0x78>
    while(n!=1){
ffffffffc0200de6:	8772                	mv	a4,t3
ffffffffc0200de8:	b719                	j	ffffffffc0200cee <buddy_alloc_pages+0xb2>
ffffffffc0200dea:	0026871b          	addiw	a4,a3,2
ffffffffc0200dee:	b579                	j	ffffffffc0200c7c <buddy_alloc_pages+0x40>
    while(n!=1){
ffffffffc0200df0:	4705                	li	a4,1
    return result+1;
ffffffffc0200df2:	b569                	j	ffffffffc0200c7c <buddy_alloc_pages+0x40>
    int strr=buddy_size*(block-pow2(log2_round_down(block)))/pow2(log2_round_down(block));
ffffffffc0200df4:	fff58793          	addi	a5,a1,-1
ffffffffc0200df8:	03c787b3          	mul	a5,a5,t3
ffffffffc0200dfc:	bf95                	j	ffffffffc0200d70 <buddy_alloc_pages+0x134>
    assert(n > 0);
ffffffffc0200dfe:	00001697          	auipc	a3,0x1
ffffffffc0200e02:	42268693          	addi	a3,a3,1058 # ffffffffc0202220 <commands+0x878>
ffffffffc0200e06:	00001617          	auipc	a2,0x1
ffffffffc0200e0a:	42260613          	addi	a2,a2,1058 # ffffffffc0202228 <commands+0x880>
ffffffffc0200e0e:	05100593          	li	a1,81
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	42e50513          	addi	a0,a0,1070 # ffffffffc0202240 <commands+0x898>
ffffffffc0200e1a:	b24ff0ef          	jal	ra,ffffffffc020013e <__panic>
            assert(0);
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	2c268693          	addi	a3,a3,706 # ffffffffc02020e0 <commands+0x738>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	40260613          	addi	a2,a2,1026 # ffffffffc0202228 <commands+0x880>
ffffffffc0200e2e:	06600593          	li	a1,102
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	40e50513          	addi	a0,a0,1038 # ffffffffc0202240 <commands+0x898>
ffffffffc0200e3a:	b04ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200e3e <buddy_init_memmap.part.1>:
    for (; p != base + n; p ++) {
ffffffffc0200e3e:	00259693          	slli	a3,a1,0x2
ffffffffc0200e42:	96ae                	add	a3,a3,a1
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200e44:	1101                	addi	sp,sp,-32
    for (; p != base + n; p ++) {
ffffffffc0200e46:	068e                	slli	a3,a3,0x3
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200e48:	ec06                	sd	ra,24(sp)
ffffffffc0200e4a:	e822                	sd	s0,16(sp)
ffffffffc0200e4c:	e426                	sd	s1,8(sp)
    for (; p != base + n; p ++) {
ffffffffc0200e4e:	96aa                	add	a3,a3,a0
ffffffffc0200e50:	02d50463          	beq	a0,a3,ffffffffc0200e78 <buddy_init_memmap.part.1+0x3a>
ffffffffc0200e54:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200e56:	87aa                	mv	a5,a0
ffffffffc0200e58:	8b05                	andi	a4,a4,1
ffffffffc0200e5a:	e709                	bnez	a4,ffffffffc0200e64 <buddy_init_memmap.part.1+0x26>
ffffffffc0200e5c:	a8c1                	j	ffffffffc0200f2c <buddy_init_memmap.part.1+0xee>
ffffffffc0200e5e:	6798                	ld	a4,8(a5)
ffffffffc0200e60:	8b05                	andi	a4,a4,1
ffffffffc0200e62:	c769                	beqz	a4,ffffffffc0200f2c <buddy_init_memmap.part.1+0xee>
        p->flags = p->property = 0;
ffffffffc0200e64:	0007a823          	sw	zero,16(a5)
ffffffffc0200e68:	0007b423          	sd	zero,8(a5)
ffffffffc0200e6c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200e70:	02878793          	addi	a5,a5,40
ffffffffc0200e74:	fed795e3          	bne	a5,a3,ffffffffc0200e5e <buddy_init_memmap.part.1+0x20>
    n=log2_round_down(n);
ffffffffc0200e78:	2581                	sext.w	a1,a1
    while(n!=1){
ffffffffc0200e7a:	4785                	li	a5,1
    int32_t result=0;
ffffffffc0200e7c:	4401                	li	s0,0
    while(n!=1){
ffffffffc0200e7e:	4705                	li	a4,1
ffffffffc0200e80:	4481                	li	s1,0
ffffffffc0200e82:	4601                	li	a2,0
ffffffffc0200e84:	00f58c63          	beq	a1,a5,ffffffffc0200e9c <buddy_init_memmap.part.1+0x5e>
        n/=2;
ffffffffc0200e88:	01f5d79b          	srliw	a5,a1,0x1f
ffffffffc0200e8c:	9dbd                	addw	a1,a1,a5
ffffffffc0200e8e:	4015d59b          	sraiw	a1,a1,0x1
        result++;
ffffffffc0200e92:	2405                	addiw	s0,s0,1
    while(n!=1){
ffffffffc0200e94:	fee59ae3          	bne	a1,a4,ffffffffc0200e88 <buddy_init_memmap.part.1+0x4a>
ffffffffc0200e98:	8622                	mv	a2,s0
ffffffffc0200e9a:	84a2                	mv	s1,s0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e9c:	00005797          	auipc	a5,0x5
ffffffffc0200ea0:	5cc78793          	addi	a5,a5,1484 # ffffffffc0206468 <pages>
ffffffffc0200ea4:	6394                	ld	a3,0(a5)
ffffffffc0200ea6:	00001797          	auipc	a5,0x1
ffffffffc0200eaa:	37278793          	addi	a5,a5,882 # ffffffffc0202218 <commands+0x870>
ffffffffc0200eae:	639c                	ld	a5,0(a5)
ffffffffc0200eb0:	40d506b3          	sub	a3,a0,a3
ffffffffc0200eb4:	868d                	srai	a3,a3,0x3
ffffffffc0200eb6:	02f686b3          	mul	a3,a3,a5
ffffffffc0200eba:	00001797          	auipc	a5,0x1
ffffffffc0200ebe:	68678793          	addi	a5,a5,1670 # ffffffffc0202540 <nbase>
ffffffffc0200ec2:	639c                	ld	a5,0(a5)
    buddy_array = KADDR(page2pa(base));
ffffffffc0200ec4:	00005717          	auipc	a4,0x5
ffffffffc0200ec8:	55470713          	addi	a4,a4,1364 # ffffffffc0206418 <npage>
ffffffffc0200ecc:	6318                	ld	a4,0(a4)
    buddy_size=n;
ffffffffc0200ece:	00005597          	auipc	a1,0x5
ffffffffc0200ed2:	5695b523          	sd	s1,1386(a1) # ffffffffc0206438 <buddy_size>
ffffffffc0200ed6:	96be                	add	a3,a3,a5
    buddy_array = KADDR(page2pa(base));
ffffffffc0200ed8:	57fd                	li	a5,-1
ffffffffc0200eda:	83b1                	srli	a5,a5,0xc
ffffffffc0200edc:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ede:	06b2                	slli	a3,a3,0xc
ffffffffc0200ee0:	06e7f663          	bleu	a4,a5,ffffffffc0200f4c <buddy_init_memmap.part.1+0x10e>
ffffffffc0200ee4:	00005797          	auipc	a5,0x5
ffffffffc0200ee8:	57c78793          	addi	a5,a5,1404 # ffffffffc0206460 <va_pa_offset>
ffffffffc0200eec:	639c                	ld	a5,0(a5)
    memset(buddy_array, 0, n*PGSIZE);
ffffffffc0200eee:	0632                	slli	a2,a2,0xc
ffffffffc0200ef0:	4581                	li	a1,0
    buddy_array = KADDR(page2pa(base));
ffffffffc0200ef2:	96be                	add	a3,a3,a5
    memset(buddy_array, 0, n*PGSIZE);
ffffffffc0200ef4:	8536                	mv	a0,a3
    buddy_array = KADDR(page2pa(base));
ffffffffc0200ef6:	00005797          	auipc	a5,0x5
ffffffffc0200efa:	52d7b923          	sd	a3,1330(a5) # ffffffffc0206428 <buddy_array>
    memset(buddy_array, 0, n*PGSIZE);
ffffffffc0200efe:	448000ef          	jal	ra,ffffffffc0201346 <memset>
    nr_free += n;
ffffffffc0200f02:	00005797          	auipc	a5,0x5
ffffffffc0200f06:	56e78793          	addi	a5,a5,1390 # ffffffffc0206470 <free_area>
ffffffffc0200f0a:	4b9c                	lw	a5,16(a5)
    buddy_array = KADDR(page2pa(base));
ffffffffc0200f0c:	00005717          	auipc	a4,0x5
ffffffffc0200f10:	51c70713          	addi	a4,a4,1308 # ffffffffc0206428 <buddy_array>
    buddy_array[BUDDY_ROOT]=n;
ffffffffc0200f14:	6318                	ld	a4,0(a4)
    nr_free += n;
ffffffffc0200f16:	9c3d                	addw	s0,s0,a5
ffffffffc0200f18:	00005797          	auipc	a5,0x5
ffffffffc0200f1c:	5687a423          	sw	s0,1384(a5) # ffffffffc0206480 <free_area+0x10>
}
ffffffffc0200f20:	60e2                	ld	ra,24(sp)
ffffffffc0200f22:	6442                	ld	s0,16(sp)
    buddy_array[BUDDY_ROOT]=n;
ffffffffc0200f24:	e704                	sd	s1,8(a4)
}
ffffffffc0200f26:	64a2                	ld	s1,8(sp)
ffffffffc0200f28:	6105                	addi	sp,sp,32
ffffffffc0200f2a:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200f2c:	00001697          	auipc	a3,0x1
ffffffffc0200f30:	34468693          	addi	a3,a3,836 # ffffffffc0202270 <commands+0x8c8>
ffffffffc0200f34:	00001617          	auipc	a2,0x1
ffffffffc0200f38:	2f460613          	addi	a2,a2,756 # ffffffffc0202228 <commands+0x880>
ffffffffc0200f3c:	04200593          	li	a1,66
ffffffffc0200f40:	00001517          	auipc	a0,0x1
ffffffffc0200f44:	30050513          	addi	a0,a0,768 # ffffffffc0202240 <commands+0x898>
ffffffffc0200f48:	9f6ff0ef          	jal	ra,ffffffffc020013e <__panic>
    buddy_array = KADDR(page2pa(base));
ffffffffc0200f4c:	00001617          	auipc	a2,0x1
ffffffffc0200f50:	33460613          	addi	a2,a2,820 # ffffffffc0202280 <commands+0x8d8>
ffffffffc0200f54:	04a00593          	li	a1,74
ffffffffc0200f58:	00001517          	auipc	a0,0x1
ffffffffc0200f5c:	2e850513          	addi	a0,a0,744 # ffffffffc0202240 <commands+0x898>
ffffffffc0200f60:	9deff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200f64 <buddy_init_memmap>:
    assert(n > 0);
ffffffffc0200f64:	c599                	beqz	a1,ffffffffc0200f72 <buddy_init_memmap+0xe>
    buddy_base=base;
ffffffffc0200f66:	00005717          	auipc	a4,0x5
ffffffffc0200f6a:	4ca73523          	sd	a0,1226(a4) # ffffffffc0206430 <buddy_base>
    for (; p != base + n; p ++) {
ffffffffc0200f6e:	ed1ff06f          	j	ffffffffc0200e3e <buddy_init_memmap.part.1>
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200f72:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	2ac68693          	addi	a3,a3,684 # ffffffffc0202220 <commands+0x878>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	2ac60613          	addi	a2,a2,684 # ffffffffc0202228 <commands+0x880>
ffffffffc0200f84:	03e00593          	li	a1,62
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	2b850513          	addi	a0,a0,696 # ffffffffc0202240 <commands+0x898>
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200f90:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f92:	9acff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200f96 <buddy_check>:
    assert(BUDDY_PARENT(6) == 3);
    assert(BUDDY_PARENT(7) == 3);

    int64_t temp=buddy_size;
    buddy_size=16;
    buddy_array[BUDDY_ROOT] = 16;
ffffffffc0200f96:	00005797          	auipc	a5,0x5
ffffffffc0200f9a:	49278793          	addi	a5,a5,1170 # ffffffffc0206428 <buddy_array>
    buddy_init_memmap(buddy_base, buddy_physical_size_store);
    
}

static void
buddy_check(void) {
ffffffffc0200f9e:	715d                	addi	sp,sp,-80
    buddy_array[BUDDY_ROOT] = 16;
ffffffffc0200fa0:	6398                	ld	a4,0(a5)
buddy_check(void) {
ffffffffc0200fa2:	fc26                	sd	s1,56(sp)
ffffffffc0200fa4:	f44e                	sd	s3,40(sp)
    for (struct Page *p = buddy_base; p < buddy_base + 1026; p++)
ffffffffc0200fa6:	00005497          	auipc	s1,0x5
ffffffffc0200faa:	48a48493          	addi	s1,s1,1162 # ffffffffc0206430 <buddy_base>
    int64_t temp=buddy_size;
ffffffffc0200fae:	00005997          	auipc	s3,0x5
ffffffffc0200fb2:	48a98993          	addi	s3,s3,1162 # ffffffffc0206438 <buddy_size>
buddy_check(void) {
ffffffffc0200fb6:	f052                	sd	s4,32(sp)
    buddy_array[BUDDY_ROOT] = 16;
ffffffffc0200fb8:	46c1                	li	a3,16
buddy_check(void) {
ffffffffc0200fba:	e486                	sd	ra,72(sp)
ffffffffc0200fbc:	e0a2                	sd	s0,64(sp)
ffffffffc0200fbe:	f84a                	sd	s2,48(sp)
ffffffffc0200fc0:	ec56                	sd	s5,24(sp)
ffffffffc0200fc2:	e85a                	sd	s6,16(sp)
ffffffffc0200fc4:	e45e                	sd	s7,8(sp)
    int64_t temp=buddy_size;
ffffffffc0200fc6:	0009ba03          	ld	s4,0(s3)
    for (struct Page *p = buddy_base; p < buddy_base + 1026; p++)
ffffffffc0200fca:	609c                	ld	a5,0(s1)
    buddy_array[BUDDY_ROOT] = 16;
ffffffffc0200fcc:	e714                	sd	a3,8(a4)
    for (struct Page *p = buddy_base; p < buddy_base + 1026; p++)
ffffffffc0200fce:	6729                	lui	a4,0xa
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fd0:	4685                	li	a3,1
ffffffffc0200fd2:	05070713          	addi	a4,a4,80 # a050 <BASE_ADDRESS-0xffffffffc01f5fb0>
ffffffffc0200fd6:	00878613          	addi	a2,a5,8
ffffffffc0200fda:	40d6302f          	amoor.d	zero,a3,(a2)
ffffffffc0200fde:	6088                	ld	a0,0(s1)
ffffffffc0200fe0:	02878793          	addi	a5,a5,40
ffffffffc0200fe4:	00e50633          	add	a2,a0,a4
ffffffffc0200fe8:	fec7e7e3          	bltu	a5,a2,ffffffffc0200fd6 <buddy_check+0x40>
ffffffffc0200fec:	00005917          	auipc	s2,0x5
ffffffffc0200ff0:	48490913          	addi	s2,s2,1156 # ffffffffc0206470 <free_area>
ffffffffc0200ff4:	40200593          	li	a1,1026
ffffffffc0200ff8:	00005797          	auipc	a5,0x5
ffffffffc0200ffc:	4927b023          	sd	s2,1152(a5) # ffffffffc0206478 <free_area+0x8>
ffffffffc0201000:	00005797          	auipc	a5,0x5
ffffffffc0201004:	4727b823          	sd	s2,1136(a5) # ffffffffc0206470 <free_area>
    nr_free = 0;
ffffffffc0201008:	00005797          	auipc	a5,0x5
ffffffffc020100c:	4607ac23          	sw	zero,1144(a5) # ffffffffc0206480 <free_area+0x10>
    for (; p != base + n; p ++) {
ffffffffc0201010:	e2fff0ef          	jal	ra,ffffffffc0200e3e <buddy_init_memmap.part.1>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201014:	4505                	li	a0,1
ffffffffc0201016:	815ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc020101a:	842a                	mv	s0,a0
ffffffffc020101c:	10050e63          	beqz	a0,ffffffffc0201138 <buddy_check+0x1a2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201020:	4505                	li	a0,1
ffffffffc0201022:	809ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0201026:	8aaa                	mv	s5,a0
ffffffffc0201028:	28050863          	beqz	a0,ffffffffc02012b8 <buddy_check+0x322>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020102c:	4505                	li	a0,1
ffffffffc020102e:	ffcff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0201032:	8b2a                	mv	s6,a0
ffffffffc0201034:	26050263          	beqz	a0,ffffffffc0201298 <buddy_check+0x302>
    assert((p3 = alloc_page()) != NULL);
ffffffffc0201038:	4505                	li	a0,1
ffffffffc020103a:	ff0ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc020103e:	8baa                	mv	s7,a0
ffffffffc0201040:	22050c63          	beqz	a0,ffffffffc0201278 <buddy_check+0x2e2>
    assert(p0 + 1 == p1);
ffffffffc0201044:	02840793          	addi	a5,s0,40
ffffffffc0201048:	20fa9863          	bne	s5,a5,ffffffffc0201258 <buddy_check+0x2c2>
    assert(p1 + 1 == p2);
ffffffffc020104c:	05040793          	addi	a5,s0,80
ffffffffc0201050:	1efb1463          	bne	s6,a5,ffffffffc0201238 <buddy_check+0x2a2>
    assert(p2 + 1 == p3);
ffffffffc0201054:	07840793          	addi	a5,s0,120
ffffffffc0201058:	1cf51063          	bne	a0,a5,ffffffffc0201218 <buddy_check+0x282>
    assert(nr_free == buddy_size-4);
ffffffffc020105c:	0009b783          	ld	a5,0(s3)
ffffffffc0201060:	00005717          	auipc	a4,0x5
ffffffffc0201064:	42076703          	lwu	a4,1056(a4) # ffffffffc0206480 <free_area+0x10>
ffffffffc0201068:	17f1                	addi	a5,a5,-4
ffffffffc020106a:	18f71763          	bne	a4,a5,ffffffffc02011f8 <buddy_check+0x262>
    free_page(p0);
ffffffffc020106e:	4585                	li	a1,1
ffffffffc0201070:	8522                	mv	a0,s0
ffffffffc0201072:	ffcff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p1);
ffffffffc0201076:	4585                	li	a1,1
ffffffffc0201078:	8556                	mv	a0,s5
ffffffffc020107a:	ff4ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p2);
ffffffffc020107e:	4585                	li	a1,1
ffffffffc0201080:	855a                	mv	a0,s6
ffffffffc0201082:	fecff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert(nr_free == buddy_size-1);
ffffffffc0201086:	0009b783          	ld	a5,0(s3)
ffffffffc020108a:	00005717          	auipc	a4,0x5
ffffffffc020108e:	3f676703          	lwu	a4,1014(a4) # ffffffffc0206480 <free_area+0x10>
ffffffffc0201092:	17fd                	addi	a5,a5,-1
ffffffffc0201094:	14f71263          	bne	a4,a5,ffffffffc02011d8 <buddy_check+0x242>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201098:	4505                	li	a0,1
ffffffffc020109a:	f90ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc020109e:	842a                	mv	s0,a0
ffffffffc02010a0:	10050c63          	beqz	a0,ffffffffc02011b8 <buddy_check+0x222>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc02010a4:	4509                	li	a0,2
ffffffffc02010a6:	f84ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc02010aa:	89aa                	mv	s3,a0
ffffffffc02010ac:	0e050663          	beqz	a0,ffffffffc0201198 <buddy_check+0x202>
    assert(p0 + 2 == p1);
ffffffffc02010b0:	05050793          	addi	a5,a0,80
ffffffffc02010b4:	0cf41263          	bne	s0,a5,ffffffffc0201178 <buddy_check+0x1e2>
    free_pages(p0, 2);
ffffffffc02010b8:	4589                	li	a1,2
ffffffffc02010ba:	fb4ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p1);
ffffffffc02010be:	4585                	li	a1,1
ffffffffc02010c0:	8522                	mv	a0,s0
ffffffffc02010c2:	facff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p3);
ffffffffc02010c6:	855e                	mv	a0,s7
ffffffffc02010c8:	4585                	li	a1,1
ffffffffc02010ca:	fa4ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert((p = alloc_pages(3)) == p0);
ffffffffc02010ce:	450d                	li	a0,3
ffffffffc02010d0:	f5aff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc02010d4:	08a99263          	bne	s3,a0,ffffffffc0201158 <buddy_check+0x1c2>
    for (struct Page *p = buddy_base; p < buddy_base + buddy_physical_size_store; p++)
ffffffffc02010d8:	609c                	ld	a5,0(s1)
ffffffffc02010da:	002a1713          	slli	a4,s4,0x2
ffffffffc02010de:	9752                	add	a4,a4,s4
ffffffffc02010e0:	070e                	slli	a4,a4,0x3
ffffffffc02010e2:	00e786b3          	add	a3,a5,a4
ffffffffc02010e6:	04d7f763          	bleu	a3,a5,ffffffffc0201134 <buddy_check+0x19e>
ffffffffc02010ea:	4605                	li	a2,1
ffffffffc02010ec:	00878693          	addi	a3,a5,8
ffffffffc02010f0:	40c6b02f          	amoor.d	zero,a2,(a3)
ffffffffc02010f4:	6088                	ld	a0,0(s1)
ffffffffc02010f6:	02878793          	addi	a5,a5,40
ffffffffc02010fa:	00e506b3          	add	a3,a0,a4
ffffffffc02010fe:	fed7e7e3          	bltu	a5,a3,ffffffffc02010ec <buddy_check+0x156>
    basic_check();
    alloc_check();
}
ffffffffc0201102:	6406                	ld	s0,64(sp)
ffffffffc0201104:	00005797          	auipc	a5,0x5
ffffffffc0201108:	3727ba23          	sd	s2,884(a5) # ffffffffc0206478 <free_area+0x8>
ffffffffc020110c:	00005797          	auipc	a5,0x5
ffffffffc0201110:	3727b223          	sd	s2,868(a5) # ffffffffc0206470 <free_area>
ffffffffc0201114:	60a6                	ld	ra,72(sp)
ffffffffc0201116:	74e2                	ld	s1,56(sp)
ffffffffc0201118:	7942                	ld	s2,48(sp)
ffffffffc020111a:	79a2                	ld	s3,40(sp)
ffffffffc020111c:	6ae2                	ld	s5,24(sp)
ffffffffc020111e:	6b42                	ld	s6,16(sp)
ffffffffc0201120:	6ba2                	ld	s7,8(sp)
    buddy_init_memmap(buddy_base, buddy_physical_size_store);
ffffffffc0201122:	85d2                	mv	a1,s4
}
ffffffffc0201124:	7a02                	ld	s4,32(sp)
    nr_free = 0;
ffffffffc0201126:	00005797          	auipc	a5,0x5
ffffffffc020112a:	3407ad23          	sw	zero,858(a5) # ffffffffc0206480 <free_area+0x10>
}
ffffffffc020112e:	6161                	addi	sp,sp,80
    buddy_init_memmap(buddy_base, buddy_physical_size_store);
ffffffffc0201130:	e35ff06f          	j	ffffffffc0200f64 <buddy_init_memmap>
    for (struct Page *p = buddy_base; p < buddy_base + buddy_physical_size_store; p++)
ffffffffc0201134:	853e                	mv	a0,a5
ffffffffc0201136:	b7f1                	j	ffffffffc0201102 <buddy_check+0x16c>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201138:	00001697          	auipc	a3,0x1
ffffffffc020113c:	fb068693          	addi	a3,a3,-80 # ffffffffc02020e8 <commands+0x740>
ffffffffc0201140:	00001617          	auipc	a2,0x1
ffffffffc0201144:	0e860613          	addi	a2,a2,232 # ffffffffc0202228 <commands+0x880>
ffffffffc0201148:	0b400593          	li	a1,180
ffffffffc020114c:	00001517          	auipc	a0,0x1
ffffffffc0201150:	0f450513          	addi	a0,a0,244 # ffffffffc0202240 <commands+0x898>
ffffffffc0201154:	febfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p = alloc_pages(3)) == p0);
ffffffffc0201158:	00001697          	auipc	a3,0x1
ffffffffc020115c:	0a068693          	addi	a3,a3,160 # ffffffffc02021f8 <commands+0x850>
ffffffffc0201160:	00001617          	auipc	a2,0x1
ffffffffc0201164:	0c860613          	addi	a2,a2,200 # ffffffffc0202228 <commands+0x880>
ffffffffc0201168:	0cd00593          	li	a1,205
ffffffffc020116c:	00001517          	auipc	a0,0x1
ffffffffc0201170:	0d450513          	addi	a0,a0,212 # ffffffffc0202240 <commands+0x898>
ffffffffc0201174:	fcbfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201178:	00001697          	auipc	a3,0x1
ffffffffc020117c:	07068693          	addi	a3,a3,112 # ffffffffc02021e8 <commands+0x840>
ffffffffc0201180:	00001617          	auipc	a2,0x1
ffffffffc0201184:	0a860613          	addi	a2,a2,168 # ffffffffc0202228 <commands+0x880>
ffffffffc0201188:	0c600593          	li	a1,198
ffffffffc020118c:	00001517          	auipc	a0,0x1
ffffffffc0201190:	0b450513          	addi	a0,a0,180 # ffffffffc0202240 <commands+0x898>
ffffffffc0201194:	fabfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc0201198:	00001697          	auipc	a3,0x1
ffffffffc020119c:	03068693          	addi	a3,a3,48 # ffffffffc02021c8 <commands+0x820>
ffffffffc02011a0:	00001617          	auipc	a2,0x1
ffffffffc02011a4:	08860613          	addi	a2,a2,136 # ffffffffc0202228 <commands+0x880>
ffffffffc02011a8:	0c500593          	li	a1,197
ffffffffc02011ac:	00001517          	auipc	a0,0x1
ffffffffc02011b0:	09450513          	addi	a0,a0,148 # ffffffffc0202240 <commands+0x898>
ffffffffc02011b4:	f8bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011b8:	00001697          	auipc	a3,0x1
ffffffffc02011bc:	f5068693          	addi	a3,a3,-176 # ffffffffc0202108 <commands+0x760>
ffffffffc02011c0:	00001617          	auipc	a2,0x1
ffffffffc02011c4:	06860613          	addi	a2,a2,104 # ffffffffc0202228 <commands+0x880>
ffffffffc02011c8:	0c400593          	li	a1,196
ffffffffc02011cc:	00001517          	auipc	a0,0x1
ffffffffc02011d0:	07450513          	addi	a0,a0,116 # ffffffffc0202240 <commands+0x898>
ffffffffc02011d4:	f6bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == buddy_size-1);
ffffffffc02011d8:	00001697          	auipc	a3,0x1
ffffffffc02011dc:	fd868693          	addi	a3,a3,-40 # ffffffffc02021b0 <commands+0x808>
ffffffffc02011e0:	00001617          	auipc	a2,0x1
ffffffffc02011e4:	04860613          	addi	a2,a2,72 # ffffffffc0202228 <commands+0x880>
ffffffffc02011e8:	0c200593          	li	a1,194
ffffffffc02011ec:	00001517          	auipc	a0,0x1
ffffffffc02011f0:	05450513          	addi	a0,a0,84 # ffffffffc0202240 <commands+0x898>
ffffffffc02011f4:	f4bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == buddy_size-4);
ffffffffc02011f8:	00001697          	auipc	a3,0x1
ffffffffc02011fc:	fa068693          	addi	a3,a3,-96 # ffffffffc0202198 <commands+0x7f0>
ffffffffc0201200:	00001617          	auipc	a2,0x1
ffffffffc0201204:	02860613          	addi	a2,a2,40 # ffffffffc0202228 <commands+0x880>
ffffffffc0201208:	0be00593          	li	a1,190
ffffffffc020120c:	00001517          	auipc	a0,0x1
ffffffffc0201210:	03450513          	addi	a0,a0,52 # ffffffffc0202240 <commands+0x898>
ffffffffc0201214:	f2bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p2 + 1 == p3);
ffffffffc0201218:	00001697          	auipc	a3,0x1
ffffffffc020121c:	f7068693          	addi	a3,a3,-144 # ffffffffc0202188 <commands+0x7e0>
ffffffffc0201220:	00001617          	auipc	a2,0x1
ffffffffc0201224:	00860613          	addi	a2,a2,8 # ffffffffc0202228 <commands+0x880>
ffffffffc0201228:	0bb00593          	li	a1,187
ffffffffc020122c:	00001517          	auipc	a0,0x1
ffffffffc0201230:	01450513          	addi	a0,a0,20 # ffffffffc0202240 <commands+0x898>
ffffffffc0201234:	f0bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p1 + 1 == p2);
ffffffffc0201238:	00001697          	auipc	a3,0x1
ffffffffc020123c:	f4068693          	addi	a3,a3,-192 # ffffffffc0202178 <commands+0x7d0>
ffffffffc0201240:	00001617          	auipc	a2,0x1
ffffffffc0201244:	fe860613          	addi	a2,a2,-24 # ffffffffc0202228 <commands+0x880>
ffffffffc0201248:	0ba00593          	li	a1,186
ffffffffc020124c:	00001517          	auipc	a0,0x1
ffffffffc0201250:	ff450513          	addi	a0,a0,-12 # ffffffffc0202240 <commands+0x898>
ffffffffc0201254:	eebfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 + 1 == p1);
ffffffffc0201258:	00001697          	auipc	a3,0x1
ffffffffc020125c:	f1068693          	addi	a3,a3,-240 # ffffffffc0202168 <commands+0x7c0>
ffffffffc0201260:	00001617          	auipc	a2,0x1
ffffffffc0201264:	fc860613          	addi	a2,a2,-56 # ffffffffc0202228 <commands+0x880>
ffffffffc0201268:	0b900593          	li	a1,185
ffffffffc020126c:	00001517          	auipc	a0,0x1
ffffffffc0201270:	fd450513          	addi	a0,a0,-44 # ffffffffc0202240 <commands+0x898>
ffffffffc0201274:	ecbfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p3 = alloc_page()) != NULL);
ffffffffc0201278:	00001697          	auipc	a3,0x1
ffffffffc020127c:	ed068693          	addi	a3,a3,-304 # ffffffffc0202148 <commands+0x7a0>
ffffffffc0201280:	00001617          	auipc	a2,0x1
ffffffffc0201284:	fa860613          	addi	a2,a2,-88 # ffffffffc0202228 <commands+0x880>
ffffffffc0201288:	0b700593          	li	a1,183
ffffffffc020128c:	00001517          	auipc	a0,0x1
ffffffffc0201290:	fb450513          	addi	a0,a0,-76 # ffffffffc0202240 <commands+0x898>
ffffffffc0201294:	eabfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201298:	00001697          	auipc	a3,0x1
ffffffffc020129c:	e9068693          	addi	a3,a3,-368 # ffffffffc0202128 <commands+0x780>
ffffffffc02012a0:	00001617          	auipc	a2,0x1
ffffffffc02012a4:	f8860613          	addi	a2,a2,-120 # ffffffffc0202228 <commands+0x880>
ffffffffc02012a8:	0b600593          	li	a1,182
ffffffffc02012ac:	00001517          	auipc	a0,0x1
ffffffffc02012b0:	f9450513          	addi	a0,a0,-108 # ffffffffc0202240 <commands+0x898>
ffffffffc02012b4:	e8bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012b8:	00001697          	auipc	a3,0x1
ffffffffc02012bc:	e5068693          	addi	a3,a3,-432 # ffffffffc0202108 <commands+0x760>
ffffffffc02012c0:	00001617          	auipc	a2,0x1
ffffffffc02012c4:	f6860613          	addi	a2,a2,-152 # ffffffffc0202228 <commands+0x880>
ffffffffc02012c8:	0b500593          	li	a1,181
ffffffffc02012cc:	00001517          	auipc	a0,0x1
ffffffffc02012d0:	f7450513          	addi	a0,a0,-140 # ffffffffc0202240 <commands+0x898>
ffffffffc02012d4:	e6bfe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02012d8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012d8:	c185                	beqz	a1,ffffffffc02012f8 <strnlen+0x20>
ffffffffc02012da:	00054783          	lbu	a5,0(a0)
ffffffffc02012de:	cf89                	beqz	a5,ffffffffc02012f8 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02012e0:	4781                	li	a5,0
ffffffffc02012e2:	a021                	j	ffffffffc02012ea <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012e4:	00074703          	lbu	a4,0(a4)
ffffffffc02012e8:	c711                	beqz	a4,ffffffffc02012f4 <strnlen+0x1c>
        cnt ++;
ffffffffc02012ea:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012ec:	00f50733          	add	a4,a0,a5
ffffffffc02012f0:	fef59ae3          	bne	a1,a5,ffffffffc02012e4 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02012f4:	853e                	mv	a0,a5
ffffffffc02012f6:	8082                	ret
    size_t cnt = 0;
ffffffffc02012f8:	4781                	li	a5,0
}
ffffffffc02012fa:	853e                	mv	a0,a5
ffffffffc02012fc:	8082                	ret

ffffffffc02012fe <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012fe:	00054783          	lbu	a5,0(a0)
ffffffffc0201302:	0005c703          	lbu	a4,0(a1)
ffffffffc0201306:	cb91                	beqz	a5,ffffffffc020131a <strcmp+0x1c>
ffffffffc0201308:	00e79c63          	bne	a5,a4,ffffffffc0201320 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020130c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020130e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201312:	0585                	addi	a1,a1,1
ffffffffc0201314:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201318:	fbe5                	bnez	a5,ffffffffc0201308 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020131a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020131c:	9d19                	subw	a0,a0,a4
ffffffffc020131e:	8082                	ret
ffffffffc0201320:	0007851b          	sext.w	a0,a5
ffffffffc0201324:	9d19                	subw	a0,a0,a4
ffffffffc0201326:	8082                	ret

ffffffffc0201328 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201328:	00054783          	lbu	a5,0(a0)
ffffffffc020132c:	cb91                	beqz	a5,ffffffffc0201340 <strchr+0x18>
        if (*s == c) {
ffffffffc020132e:	00b79563          	bne	a5,a1,ffffffffc0201338 <strchr+0x10>
ffffffffc0201332:	a809                	j	ffffffffc0201344 <strchr+0x1c>
ffffffffc0201334:	00b78763          	beq	a5,a1,ffffffffc0201342 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201338:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020133a:	00054783          	lbu	a5,0(a0)
ffffffffc020133e:	fbfd                	bnez	a5,ffffffffc0201334 <strchr+0xc>
    }
    return NULL;
ffffffffc0201340:	4501                	li	a0,0
}
ffffffffc0201342:	8082                	ret
ffffffffc0201344:	8082                	ret

ffffffffc0201346 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201346:	ca01                	beqz	a2,ffffffffc0201356 <memset+0x10>
ffffffffc0201348:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020134a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020134c:	0785                	addi	a5,a5,1
ffffffffc020134e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201352:	fec79de3          	bne	a5,a2,ffffffffc020134c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201356:	8082                	ret

ffffffffc0201358 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201358:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020135c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020135e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201362:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201364:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201368:	f022                	sd	s0,32(sp)
ffffffffc020136a:	ec26                	sd	s1,24(sp)
ffffffffc020136c:	e84a                	sd	s2,16(sp)
ffffffffc020136e:	f406                	sd	ra,40(sp)
ffffffffc0201370:	e44e                	sd	s3,8(sp)
ffffffffc0201372:	84aa                	mv	s1,a0
ffffffffc0201374:	892e                	mv	s2,a1
ffffffffc0201376:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020137a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020137c:	03067e63          	bleu	a6,a2,ffffffffc02013b8 <printnum+0x60>
ffffffffc0201380:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201382:	00805763          	blez	s0,ffffffffc0201390 <printnum+0x38>
ffffffffc0201386:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201388:	85ca                	mv	a1,s2
ffffffffc020138a:	854e                	mv	a0,s3
ffffffffc020138c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020138e:	fc65                	bnez	s0,ffffffffc0201386 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201390:	1a02                	slli	s4,s4,0x20
ffffffffc0201392:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201396:	00001797          	auipc	a5,0x1
ffffffffc020139a:	0f278793          	addi	a5,a5,242 # ffffffffc0202488 <error_string+0x38>
ffffffffc020139e:	9a3e                	add	s4,s4,a5
}
ffffffffc02013a0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013a2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02013a6:	70a2                	ld	ra,40(sp)
ffffffffc02013a8:	69a2                	ld	s3,8(sp)
ffffffffc02013aa:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013ac:	85ca                	mv	a1,s2
ffffffffc02013ae:	8326                	mv	t1,s1
}
ffffffffc02013b0:	6942                	ld	s2,16(sp)
ffffffffc02013b2:	64e2                	ld	s1,24(sp)
ffffffffc02013b4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013b6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02013b8:	03065633          	divu	a2,a2,a6
ffffffffc02013bc:	8722                	mv	a4,s0
ffffffffc02013be:	f9bff0ef          	jal	ra,ffffffffc0201358 <printnum>
ffffffffc02013c2:	b7f9                	j	ffffffffc0201390 <printnum+0x38>

ffffffffc02013c4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013c4:	7119                	addi	sp,sp,-128
ffffffffc02013c6:	f4a6                	sd	s1,104(sp)
ffffffffc02013c8:	f0ca                	sd	s2,96(sp)
ffffffffc02013ca:	e8d2                	sd	s4,80(sp)
ffffffffc02013cc:	e4d6                	sd	s5,72(sp)
ffffffffc02013ce:	e0da                	sd	s6,64(sp)
ffffffffc02013d0:	fc5e                	sd	s7,56(sp)
ffffffffc02013d2:	f862                	sd	s8,48(sp)
ffffffffc02013d4:	f06a                	sd	s10,32(sp)
ffffffffc02013d6:	fc86                	sd	ra,120(sp)
ffffffffc02013d8:	f8a2                	sd	s0,112(sp)
ffffffffc02013da:	ecce                	sd	s3,88(sp)
ffffffffc02013dc:	f466                	sd	s9,40(sp)
ffffffffc02013de:	ec6e                	sd	s11,24(sp)
ffffffffc02013e0:	892a                	mv	s2,a0
ffffffffc02013e2:	84ae                	mv	s1,a1
ffffffffc02013e4:	8d32                	mv	s10,a2
ffffffffc02013e6:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013e8:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ea:	00001a17          	auipc	s4,0x1
ffffffffc02013ee:	f0aa0a13          	addi	s4,s4,-246 # ffffffffc02022f4 <buddy_pmm_manager+0x4c>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013f2:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013f6:	00001c17          	auipc	s8,0x1
ffffffffc02013fa:	05ac0c13          	addi	s8,s8,90 # ffffffffc0202450 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013fe:	000d4503          	lbu	a0,0(s10)
ffffffffc0201402:	02500793          	li	a5,37
ffffffffc0201406:	001d0413          	addi	s0,s10,1
ffffffffc020140a:	00f50e63          	beq	a0,a5,ffffffffc0201426 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020140e:	c521                	beqz	a0,ffffffffc0201456 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201410:	02500993          	li	s3,37
ffffffffc0201414:	a011                	j	ffffffffc0201418 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201416:	c121                	beqz	a0,ffffffffc0201456 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201418:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020141a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020141c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020141e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201422:	ff351ae3          	bne	a0,s3,ffffffffc0201416 <vprintfmt+0x52>
ffffffffc0201426:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020142a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020142e:	4981                	li	s3,0
ffffffffc0201430:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201432:	5cfd                	li	s9,-1
ffffffffc0201434:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201436:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020143a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020143c:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201440:	0ff6f693          	andi	a3,a3,255
ffffffffc0201444:	00140d13          	addi	s10,s0,1
ffffffffc0201448:	20d5e563          	bltu	a1,a3,ffffffffc0201652 <vprintfmt+0x28e>
ffffffffc020144c:	068a                	slli	a3,a3,0x2
ffffffffc020144e:	96d2                	add	a3,a3,s4
ffffffffc0201450:	4294                	lw	a3,0(a3)
ffffffffc0201452:	96d2                	add	a3,a3,s4
ffffffffc0201454:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201456:	70e6                	ld	ra,120(sp)
ffffffffc0201458:	7446                	ld	s0,112(sp)
ffffffffc020145a:	74a6                	ld	s1,104(sp)
ffffffffc020145c:	7906                	ld	s2,96(sp)
ffffffffc020145e:	69e6                	ld	s3,88(sp)
ffffffffc0201460:	6a46                	ld	s4,80(sp)
ffffffffc0201462:	6aa6                	ld	s5,72(sp)
ffffffffc0201464:	6b06                	ld	s6,64(sp)
ffffffffc0201466:	7be2                	ld	s7,56(sp)
ffffffffc0201468:	7c42                	ld	s8,48(sp)
ffffffffc020146a:	7ca2                	ld	s9,40(sp)
ffffffffc020146c:	7d02                	ld	s10,32(sp)
ffffffffc020146e:	6de2                	ld	s11,24(sp)
ffffffffc0201470:	6109                	addi	sp,sp,128
ffffffffc0201472:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201474:	4705                	li	a4,1
ffffffffc0201476:	008a8593          	addi	a1,s5,8
ffffffffc020147a:	01074463          	blt	a4,a6,ffffffffc0201482 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020147e:	26080363          	beqz	a6,ffffffffc02016e4 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201482:	000ab603          	ld	a2,0(s5)
ffffffffc0201486:	46c1                	li	a3,16
ffffffffc0201488:	8aae                	mv	s5,a1
ffffffffc020148a:	a06d                	j	ffffffffc0201534 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020148c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201490:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201492:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201494:	b765                	j	ffffffffc020143c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201496:	000aa503          	lw	a0,0(s5)
ffffffffc020149a:	85a6                	mv	a1,s1
ffffffffc020149c:	0aa1                	addi	s5,s5,8
ffffffffc020149e:	9902                	jalr	s2
            break;
ffffffffc02014a0:	bfb9                	j	ffffffffc02013fe <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014a2:	4705                	li	a4,1
ffffffffc02014a4:	008a8993          	addi	s3,s5,8
ffffffffc02014a8:	01074463          	blt	a4,a6,ffffffffc02014b0 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02014ac:	22080463          	beqz	a6,ffffffffc02016d4 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02014b0:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02014b4:	24044463          	bltz	s0,ffffffffc02016fc <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02014b8:	8622                	mv	a2,s0
ffffffffc02014ba:	8ace                	mv	s5,s3
ffffffffc02014bc:	46a9                	li	a3,10
ffffffffc02014be:	a89d                	j	ffffffffc0201534 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02014c0:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014c4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014c6:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02014c8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014cc:	8fb5                	xor	a5,a5,a3
ffffffffc02014ce:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014d2:	1ad74363          	blt	a4,a3,ffffffffc0201678 <vprintfmt+0x2b4>
ffffffffc02014d6:	00369793          	slli	a5,a3,0x3
ffffffffc02014da:	97e2                	add	a5,a5,s8
ffffffffc02014dc:	639c                	ld	a5,0(a5)
ffffffffc02014de:	18078d63          	beqz	a5,ffffffffc0201678 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014e2:	86be                	mv	a3,a5
ffffffffc02014e4:	00001617          	auipc	a2,0x1
ffffffffc02014e8:	05460613          	addi	a2,a2,84 # ffffffffc0202538 <error_string+0xe8>
ffffffffc02014ec:	85a6                	mv	a1,s1
ffffffffc02014ee:	854a                	mv	a0,s2
ffffffffc02014f0:	240000ef          	jal	ra,ffffffffc0201730 <printfmt>
ffffffffc02014f4:	b729                	j	ffffffffc02013fe <vprintfmt+0x3a>
            lflag ++;
ffffffffc02014f6:	00144603          	lbu	a2,1(s0)
ffffffffc02014fa:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014fc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014fe:	bf3d                	j	ffffffffc020143c <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201500:	4705                	li	a4,1
ffffffffc0201502:	008a8593          	addi	a1,s5,8
ffffffffc0201506:	01074463          	blt	a4,a6,ffffffffc020150e <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020150a:	1e080263          	beqz	a6,ffffffffc02016ee <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020150e:	000ab603          	ld	a2,0(s5)
ffffffffc0201512:	46a1                	li	a3,8
ffffffffc0201514:	8aae                	mv	s5,a1
ffffffffc0201516:	a839                	j	ffffffffc0201534 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201518:	03000513          	li	a0,48
ffffffffc020151c:	85a6                	mv	a1,s1
ffffffffc020151e:	e03e                	sd	a5,0(sp)
ffffffffc0201520:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201522:	85a6                	mv	a1,s1
ffffffffc0201524:	07800513          	li	a0,120
ffffffffc0201528:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020152a:	0aa1                	addi	s5,s5,8
ffffffffc020152c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201530:	6782                	ld	a5,0(sp)
ffffffffc0201532:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201534:	876e                	mv	a4,s11
ffffffffc0201536:	85a6                	mv	a1,s1
ffffffffc0201538:	854a                	mv	a0,s2
ffffffffc020153a:	e1fff0ef          	jal	ra,ffffffffc0201358 <printnum>
            break;
ffffffffc020153e:	b5c1                	j	ffffffffc02013fe <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201540:	000ab603          	ld	a2,0(s5)
ffffffffc0201544:	0aa1                	addi	s5,s5,8
ffffffffc0201546:	1c060663          	beqz	a2,ffffffffc0201712 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020154a:	00160413          	addi	s0,a2,1
ffffffffc020154e:	17b05c63          	blez	s11,ffffffffc02016c6 <vprintfmt+0x302>
ffffffffc0201552:	02d00593          	li	a1,45
ffffffffc0201556:	14b79263          	bne	a5,a1,ffffffffc020169a <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020155a:	00064783          	lbu	a5,0(a2)
ffffffffc020155e:	0007851b          	sext.w	a0,a5
ffffffffc0201562:	c905                	beqz	a0,ffffffffc0201592 <vprintfmt+0x1ce>
ffffffffc0201564:	000cc563          	bltz	s9,ffffffffc020156e <vprintfmt+0x1aa>
ffffffffc0201568:	3cfd                	addiw	s9,s9,-1
ffffffffc020156a:	036c8263          	beq	s9,s6,ffffffffc020158e <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020156e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201570:	18098463          	beqz	s3,ffffffffc02016f8 <vprintfmt+0x334>
ffffffffc0201574:	3781                	addiw	a5,a5,-32
ffffffffc0201576:	18fbf163          	bleu	a5,s7,ffffffffc02016f8 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020157a:	03f00513          	li	a0,63
ffffffffc020157e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201580:	0405                	addi	s0,s0,1
ffffffffc0201582:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201586:	3dfd                	addiw	s11,s11,-1
ffffffffc0201588:	0007851b          	sext.w	a0,a5
ffffffffc020158c:	fd61                	bnez	a0,ffffffffc0201564 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020158e:	e7b058e3          	blez	s11,ffffffffc02013fe <vprintfmt+0x3a>
ffffffffc0201592:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201594:	85a6                	mv	a1,s1
ffffffffc0201596:	02000513          	li	a0,32
ffffffffc020159a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020159c:	e60d81e3          	beqz	s11,ffffffffc02013fe <vprintfmt+0x3a>
ffffffffc02015a0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015a2:	85a6                	mv	a1,s1
ffffffffc02015a4:	02000513          	li	a0,32
ffffffffc02015a8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015aa:	fe0d94e3          	bnez	s11,ffffffffc0201592 <vprintfmt+0x1ce>
ffffffffc02015ae:	bd81                	j	ffffffffc02013fe <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015b0:	4705                	li	a4,1
ffffffffc02015b2:	008a8593          	addi	a1,s5,8
ffffffffc02015b6:	01074463          	blt	a4,a6,ffffffffc02015be <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02015ba:	12080063          	beqz	a6,ffffffffc02016da <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02015be:	000ab603          	ld	a2,0(s5)
ffffffffc02015c2:	46a9                	li	a3,10
ffffffffc02015c4:	8aae                	mv	s5,a1
ffffffffc02015c6:	b7bd                	j	ffffffffc0201534 <vprintfmt+0x170>
ffffffffc02015c8:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02015cc:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015d0:	846a                	mv	s0,s10
ffffffffc02015d2:	b5ad                	j	ffffffffc020143c <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02015d4:	85a6                	mv	a1,s1
ffffffffc02015d6:	02500513          	li	a0,37
ffffffffc02015da:	9902                	jalr	s2
            break;
ffffffffc02015dc:	b50d                	j	ffffffffc02013fe <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02015de:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02015e2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02015e6:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015e8:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02015ea:	e40dd9e3          	bgez	s11,ffffffffc020143c <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02015ee:	8de6                	mv	s11,s9
ffffffffc02015f0:	5cfd                	li	s9,-1
ffffffffc02015f2:	b5a9                	j	ffffffffc020143c <vprintfmt+0x78>
            goto reswitch;
ffffffffc02015f4:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02015f8:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015fc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015fe:	bd3d                	j	ffffffffc020143c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201600:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201604:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201608:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020160a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020160e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201612:	fcd56ce3          	bltu	a0,a3,ffffffffc02015ea <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201616:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201618:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020161c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201620:	0196873b          	addw	a4,a3,s9
ffffffffc0201624:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201628:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020162c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201630:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201634:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201638:	fcd57fe3          	bleu	a3,a0,ffffffffc0201616 <vprintfmt+0x252>
ffffffffc020163c:	b77d                	j	ffffffffc02015ea <vprintfmt+0x226>
            if (width < 0)
ffffffffc020163e:	fffdc693          	not	a3,s11
ffffffffc0201642:	96fd                	srai	a3,a3,0x3f
ffffffffc0201644:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201648:	00144603          	lbu	a2,1(s0)
ffffffffc020164c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164e:	846a                	mv	s0,s10
ffffffffc0201650:	b3f5                	j	ffffffffc020143c <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201652:	85a6                	mv	a1,s1
ffffffffc0201654:	02500513          	li	a0,37
ffffffffc0201658:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020165a:	fff44703          	lbu	a4,-1(s0)
ffffffffc020165e:	02500793          	li	a5,37
ffffffffc0201662:	8d22                	mv	s10,s0
ffffffffc0201664:	d8f70de3          	beq	a4,a5,ffffffffc02013fe <vprintfmt+0x3a>
ffffffffc0201668:	02500713          	li	a4,37
ffffffffc020166c:	1d7d                	addi	s10,s10,-1
ffffffffc020166e:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201672:	fee79de3          	bne	a5,a4,ffffffffc020166c <vprintfmt+0x2a8>
ffffffffc0201676:	b361                	j	ffffffffc02013fe <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201678:	00001617          	auipc	a2,0x1
ffffffffc020167c:	eb060613          	addi	a2,a2,-336 # ffffffffc0202528 <error_string+0xd8>
ffffffffc0201680:	85a6                	mv	a1,s1
ffffffffc0201682:	854a                	mv	a0,s2
ffffffffc0201684:	0ac000ef          	jal	ra,ffffffffc0201730 <printfmt>
ffffffffc0201688:	bb9d                	j	ffffffffc02013fe <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020168a:	00001617          	auipc	a2,0x1
ffffffffc020168e:	e9660613          	addi	a2,a2,-362 # ffffffffc0202520 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201692:	00001417          	auipc	s0,0x1
ffffffffc0201696:	e8f40413          	addi	s0,s0,-369 # ffffffffc0202521 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020169a:	8532                	mv	a0,a2
ffffffffc020169c:	85e6                	mv	a1,s9
ffffffffc020169e:	e032                	sd	a2,0(sp)
ffffffffc02016a0:	e43e                	sd	a5,8(sp)
ffffffffc02016a2:	c37ff0ef          	jal	ra,ffffffffc02012d8 <strnlen>
ffffffffc02016a6:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02016aa:	6602                	ld	a2,0(sp)
ffffffffc02016ac:	01b05d63          	blez	s11,ffffffffc02016c6 <vprintfmt+0x302>
ffffffffc02016b0:	67a2                	ld	a5,8(sp)
ffffffffc02016b2:	2781                	sext.w	a5,a5
ffffffffc02016b4:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02016b6:	6522                	ld	a0,8(sp)
ffffffffc02016b8:	85a6                	mv	a1,s1
ffffffffc02016ba:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016bc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02016be:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016c0:	6602                	ld	a2,0(sp)
ffffffffc02016c2:	fe0d9ae3          	bnez	s11,ffffffffc02016b6 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016c6:	00064783          	lbu	a5,0(a2)
ffffffffc02016ca:	0007851b          	sext.w	a0,a5
ffffffffc02016ce:	e8051be3          	bnez	a0,ffffffffc0201564 <vprintfmt+0x1a0>
ffffffffc02016d2:	b335                	j	ffffffffc02013fe <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02016d4:	000aa403          	lw	s0,0(s5)
ffffffffc02016d8:	bbf1                	j	ffffffffc02014b4 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02016da:	000ae603          	lwu	a2,0(s5)
ffffffffc02016de:	46a9                	li	a3,10
ffffffffc02016e0:	8aae                	mv	s5,a1
ffffffffc02016e2:	bd89                	j	ffffffffc0201534 <vprintfmt+0x170>
ffffffffc02016e4:	000ae603          	lwu	a2,0(s5)
ffffffffc02016e8:	46c1                	li	a3,16
ffffffffc02016ea:	8aae                	mv	s5,a1
ffffffffc02016ec:	b5a1                	j	ffffffffc0201534 <vprintfmt+0x170>
ffffffffc02016ee:	000ae603          	lwu	a2,0(s5)
ffffffffc02016f2:	46a1                	li	a3,8
ffffffffc02016f4:	8aae                	mv	s5,a1
ffffffffc02016f6:	bd3d                	j	ffffffffc0201534 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02016f8:	9902                	jalr	s2
ffffffffc02016fa:	b559                	j	ffffffffc0201580 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02016fc:	85a6                	mv	a1,s1
ffffffffc02016fe:	02d00513          	li	a0,45
ffffffffc0201702:	e03e                	sd	a5,0(sp)
ffffffffc0201704:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201706:	8ace                	mv	s5,s3
ffffffffc0201708:	40800633          	neg	a2,s0
ffffffffc020170c:	46a9                	li	a3,10
ffffffffc020170e:	6782                	ld	a5,0(sp)
ffffffffc0201710:	b515                	j	ffffffffc0201534 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201712:	01b05663          	blez	s11,ffffffffc020171e <vprintfmt+0x35a>
ffffffffc0201716:	02d00693          	li	a3,45
ffffffffc020171a:	f6d798e3          	bne	a5,a3,ffffffffc020168a <vprintfmt+0x2c6>
ffffffffc020171e:	00001417          	auipc	s0,0x1
ffffffffc0201722:	e0340413          	addi	s0,s0,-509 # ffffffffc0202521 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201726:	02800513          	li	a0,40
ffffffffc020172a:	02800793          	li	a5,40
ffffffffc020172e:	bd1d                	j	ffffffffc0201564 <vprintfmt+0x1a0>

ffffffffc0201730 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201730:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201732:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201736:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201738:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020173a:	ec06                	sd	ra,24(sp)
ffffffffc020173c:	f83a                	sd	a4,48(sp)
ffffffffc020173e:	fc3e                	sd	a5,56(sp)
ffffffffc0201740:	e0c2                	sd	a6,64(sp)
ffffffffc0201742:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201744:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201746:	c7fff0ef          	jal	ra,ffffffffc02013c4 <vprintfmt>
}
ffffffffc020174a:	60e2                	ld	ra,24(sp)
ffffffffc020174c:	6161                	addi	sp,sp,80
ffffffffc020174e:	8082                	ret

ffffffffc0201750 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201750:	715d                	addi	sp,sp,-80
ffffffffc0201752:	e486                	sd	ra,72(sp)
ffffffffc0201754:	e0a2                	sd	s0,64(sp)
ffffffffc0201756:	fc26                	sd	s1,56(sp)
ffffffffc0201758:	f84a                	sd	s2,48(sp)
ffffffffc020175a:	f44e                	sd	s3,40(sp)
ffffffffc020175c:	f052                	sd	s4,32(sp)
ffffffffc020175e:	ec56                	sd	s5,24(sp)
ffffffffc0201760:	e85a                	sd	s6,16(sp)
ffffffffc0201762:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201764:	c901                	beqz	a0,ffffffffc0201774 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201766:	85aa                	mv	a1,a0
ffffffffc0201768:	00001517          	auipc	a0,0x1
ffffffffc020176c:	dd050513          	addi	a0,a0,-560 # ffffffffc0202538 <error_string+0xe8>
ffffffffc0201770:	947fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201774:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201776:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201778:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020177a:	4aa9                	li	s5,10
ffffffffc020177c:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020177e:	00005b97          	auipc	s7,0x5
ffffffffc0201782:	892b8b93          	addi	s7,s7,-1902 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201786:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020178a:	9a5fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020178e:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201790:	00054b63          	bltz	a0,ffffffffc02017a6 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201794:	00a95b63          	ble	a0,s2,ffffffffc02017aa <readline+0x5a>
ffffffffc0201798:	029a5463          	ble	s1,s4,ffffffffc02017c0 <readline+0x70>
        c = getchar();
ffffffffc020179c:	993fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017a0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017a2:	fe0559e3          	bgez	a0,ffffffffc0201794 <readline+0x44>
            return NULL;
ffffffffc02017a6:	4501                	li	a0,0
ffffffffc02017a8:	a099                	j	ffffffffc02017ee <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02017aa:	03341463          	bne	s0,s3,ffffffffc02017d2 <readline+0x82>
ffffffffc02017ae:	e8b9                	bnez	s1,ffffffffc0201804 <readline+0xb4>
        c = getchar();
ffffffffc02017b0:	97ffe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017b4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017b6:	fe0548e3          	bltz	a0,ffffffffc02017a6 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017ba:	fea958e3          	ble	a0,s2,ffffffffc02017aa <readline+0x5a>
ffffffffc02017be:	4481                	li	s1,0
            cputchar(c);
ffffffffc02017c0:	8522                	mv	a0,s0
ffffffffc02017c2:	929fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02017c6:	009b87b3          	add	a5,s7,s1
ffffffffc02017ca:	00878023          	sb	s0,0(a5)
ffffffffc02017ce:	2485                	addiw	s1,s1,1
ffffffffc02017d0:	bf6d                	j	ffffffffc020178a <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02017d2:	01540463          	beq	s0,s5,ffffffffc02017da <readline+0x8a>
ffffffffc02017d6:	fb641ae3          	bne	s0,s6,ffffffffc020178a <readline+0x3a>
            cputchar(c);
ffffffffc02017da:	8522                	mv	a0,s0
ffffffffc02017dc:	90ffe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02017e0:	00005517          	auipc	a0,0x5
ffffffffc02017e4:	83050513          	addi	a0,a0,-2000 # ffffffffc0206010 <edata>
ffffffffc02017e8:	94aa                	add	s1,s1,a0
ffffffffc02017ea:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02017ee:	60a6                	ld	ra,72(sp)
ffffffffc02017f0:	6406                	ld	s0,64(sp)
ffffffffc02017f2:	74e2                	ld	s1,56(sp)
ffffffffc02017f4:	7942                	ld	s2,48(sp)
ffffffffc02017f6:	79a2                	ld	s3,40(sp)
ffffffffc02017f8:	7a02                	ld	s4,32(sp)
ffffffffc02017fa:	6ae2                	ld	s5,24(sp)
ffffffffc02017fc:	6b42                	ld	s6,16(sp)
ffffffffc02017fe:	6ba2                	ld	s7,8(sp)
ffffffffc0201800:	6161                	addi	sp,sp,80
ffffffffc0201802:	8082                	ret
            cputchar(c);
ffffffffc0201804:	4521                	li	a0,8
ffffffffc0201806:	8e5fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc020180a:	34fd                	addiw	s1,s1,-1
ffffffffc020180c:	bfbd                	j	ffffffffc020178a <readline+0x3a>

ffffffffc020180e <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc020180e:	00004797          	auipc	a5,0x4
ffffffffc0201812:	7fa78793          	addi	a5,a5,2042 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201816:	6398                	ld	a4,0(a5)
ffffffffc0201818:	4781                	li	a5,0
ffffffffc020181a:	88ba                	mv	a7,a4
ffffffffc020181c:	852a                	mv	a0,a0
ffffffffc020181e:	85be                	mv	a1,a5
ffffffffc0201820:	863e                	mv	a2,a5
ffffffffc0201822:	00000073          	ecall
ffffffffc0201826:	87aa                	mv	a5,a0
}
ffffffffc0201828:	8082                	ret

ffffffffc020182a <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020182a:	00005797          	auipc	a5,0x5
ffffffffc020182e:	c1678793          	addi	a5,a5,-1002 # ffffffffc0206440 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201832:	6398                	ld	a4,0(a5)
ffffffffc0201834:	4781                	li	a5,0
ffffffffc0201836:	88ba                	mv	a7,a4
ffffffffc0201838:	852a                	mv	a0,a0
ffffffffc020183a:	85be                	mv	a1,a5
ffffffffc020183c:	863e                	mv	a2,a5
ffffffffc020183e:	00000073          	ecall
ffffffffc0201842:	87aa                	mv	a5,a0
}
ffffffffc0201844:	8082                	ret

ffffffffc0201846 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201846:	00004797          	auipc	a5,0x4
ffffffffc020184a:	7ba78793          	addi	a5,a5,1978 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc020184e:	639c                	ld	a5,0(a5)
ffffffffc0201850:	4501                	li	a0,0
ffffffffc0201852:	88be                	mv	a7,a5
ffffffffc0201854:	852a                	mv	a0,a0
ffffffffc0201856:	85aa                	mv	a1,a0
ffffffffc0201858:	862a                	mv	a2,a0
ffffffffc020185a:	00000073          	ecall
ffffffffc020185e:	852a                	mv	a0,a0
ffffffffc0201860:	2501                	sext.w	a0,a0
ffffffffc0201862:	8082                	ret
