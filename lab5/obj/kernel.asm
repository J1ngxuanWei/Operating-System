
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	fb250513          	addi	a0,a0,-78 # ffffffffc02a0fe8 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	53a60613          	addi	a2,a2,1338 # ffffffffc02ac578 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	1aa060ef          	jal	ra,ffffffffc02061f8 <memset>
    cons_init();                // init the console
ffffffffc0200052:	58e000ef          	jal	ra,ffffffffc02005e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	5e258593          	addi	a1,a1,1506 # ffffffffc0206638 <etext+0x6>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	5fa50513          	addi	a0,a0,1530 # ffffffffc0206658 <etext+0x26>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	25a000ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5e6010ef          	jal	ra,ffffffffc0201654 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e2000ef          	jal	ra,ffffffffc0200654 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	6f2020ef          	jal	ra,ffffffffc020276c <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	585050ef          	jal	ra,ffffffffc0205e02 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4b0000ef          	jal	ra,ffffffffc0200532 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	5c9020ef          	jal	ra,ffffffffc0202e4e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	500000ef          	jal	ra,ffffffffc020058a <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c8000ef          	jal	ra,ffffffffc0200656 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	6bd050ef          	jal	ra,ffffffffc0205f4e <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	544000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	1ca060ef          	jal	ra,ffffffffc020628e <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	196060ef          	jal	ra,ffffffffc020628e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	4de0006f          	j	ffffffffc02005e2 <cons_putc>

ffffffffc0200108 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200108:	1101                	addi	sp,sp,-32
ffffffffc020010a:	e822                	sd	s0,16(sp)
ffffffffc020010c:	ec06                	sd	ra,24(sp)
ffffffffc020010e:	e426                	sd	s1,8(sp)
ffffffffc0200110:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	00054503          	lbu	a0,0(a0)
ffffffffc0200116:	c51d                	beqz	a0,ffffffffc0200144 <cputs+0x3c>
ffffffffc0200118:	0405                	addi	s0,s0,1
ffffffffc020011a:	4485                	li	s1,1
ffffffffc020011c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011e:	4c4000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012c:	f96d                	bnez	a0,ffffffffc020011e <cputs+0x16>
ffffffffc020012e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200132:	4529                	li	a0,10
ffffffffc0200134:	4ae000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200138:	8522                	mv	a0,s0
ffffffffc020013a:	60e2                	ld	ra,24(sp)
ffffffffc020013c:	6442                	ld	s0,16(sp)
ffffffffc020013e:	64a2                	ld	s1,8(sp)
ffffffffc0200140:	6105                	addi	sp,sp,32
ffffffffc0200142:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200144:	4405                	li	s0,1
ffffffffc0200146:	b7f5                	j	ffffffffc0200132 <cputs+0x2a>

ffffffffc0200148 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200148:	1141                	addi	sp,sp,-16
ffffffffc020014a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014c:	4cc000ef          	jal	ra,ffffffffc0200618 <cons_getc>
ffffffffc0200150:	dd75                	beqz	a0,ffffffffc020014c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200152:	60a2                	ld	ra,8(sp)
ffffffffc0200154:	0141                	addi	sp,sp,16
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200158:	715d                	addi	sp,sp,-80
ffffffffc020015a:	e486                	sd	ra,72(sp)
ffffffffc020015c:	e0a2                	sd	s0,64(sp)
ffffffffc020015e:	fc26                	sd	s1,56(sp)
ffffffffc0200160:	f84a                	sd	s2,48(sp)
ffffffffc0200162:	f44e                	sd	s3,40(sp)
ffffffffc0200164:	f052                	sd	s4,32(sp)
ffffffffc0200166:	ec56                	sd	s5,24(sp)
ffffffffc0200168:	e85a                	sd	s6,16(sp)
ffffffffc020016a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016c:	c901                	beqz	a0,ffffffffc020017c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00006517          	auipc	a0,0x6
ffffffffc0200174:	4f050513          	addi	a0,a0,1264 # ffffffffc0206660 <etext+0x2e>
ffffffffc0200178:	f59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200182:	4aa9                	li	s5,10
ffffffffc0200184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200186:	000a1b97          	auipc	s7,0xa1
ffffffffc020018a:	e62b8b93          	addi	s7,s7,-414 # ffffffffc02a0fe8 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200192:	fb7ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc0200196:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200198:	00054b63          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019c:	00a95b63          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001a0:	029a5463          	ble	s1,s4,ffffffffc02001c8 <readline+0x70>
        c = getchar();
ffffffffc02001a4:	fa5ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001a8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001aa:	fe0559e3          	bgez	a0,ffffffffc020019c <readline+0x44>
            return NULL;
ffffffffc02001ae:	4501                	li	a0,0
ffffffffc02001b0:	a099                	j	ffffffffc02001f6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b2:	03341463          	bne	s0,s3,ffffffffc02001da <readline+0x82>
ffffffffc02001b6:	e8b9                	bnez	s1,ffffffffc020020c <readline+0xb4>
        c = getchar();
ffffffffc02001b8:	f91ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001be:	fe0548e3          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c2:	fea958e3          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001c6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c8:	8522                	mv	a0,s0
ffffffffc02001ca:	f3bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001ce:	009b87b3          	add	a5,s7,s1
ffffffffc02001d2:	00878023          	sb	s0,0(a5)
ffffffffc02001d6:	2485                	addiw	s1,s1,1
ffffffffc02001d8:	bf6d                	j	ffffffffc0200192 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	01540463          	beq	s0,s5,ffffffffc02001e2 <readline+0x8a>
ffffffffc02001de:	fb641ae3          	bne	s0,s6,ffffffffc0200192 <readline+0x3a>
            cputchar(c);
ffffffffc02001e2:	8522                	mv	a0,s0
ffffffffc02001e4:	f21ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e8:	000a1517          	auipc	a0,0xa1
ffffffffc02001ec:	e0050513          	addi	a0,a0,-512 # ffffffffc02a0fe8 <edata>
ffffffffc02001f0:	94aa                	add	s1,s1,a0
ffffffffc02001f2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f6:	60a6                	ld	ra,72(sp)
ffffffffc02001f8:	6406                	ld	s0,64(sp)
ffffffffc02001fa:	74e2                	ld	s1,56(sp)
ffffffffc02001fc:	7942                	ld	s2,48(sp)
ffffffffc02001fe:	79a2                	ld	s3,40(sp)
ffffffffc0200200:	7a02                	ld	s4,32(sp)
ffffffffc0200202:	6ae2                	ld	s5,24(sp)
ffffffffc0200204:	6b42                	ld	s6,16(sp)
ffffffffc0200206:	6ba2                	ld	s7,8(sp)
ffffffffc0200208:	6161                	addi	sp,sp,80
ffffffffc020020a:	8082                	ret
            cputchar(c);
ffffffffc020020c:	4521                	li	a0,8
ffffffffc020020e:	ef7ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200212:	34fd                	addiw	s1,s1,-1
ffffffffc0200214:	bfbd                	j	ffffffffc0200192 <readline+0x3a>

ffffffffc0200216 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200216:	000ac317          	auipc	t1,0xac
ffffffffc020021a:	1d230313          	addi	t1,t1,466 # ffffffffc02ac3e8 <is_panic>
ffffffffc020021e:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200222:	715d                	addi	sp,sp,-80
ffffffffc0200224:	ec06                	sd	ra,24(sp)
ffffffffc0200226:	e822                	sd	s0,16(sp)
ffffffffc0200228:	f436                	sd	a3,40(sp)
ffffffffc020022a:	f83a                	sd	a4,48(sp)
ffffffffc020022c:	fc3e                	sd	a5,56(sp)
ffffffffc020022e:	e0c2                	sd	a6,64(sp)
ffffffffc0200230:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200232:	02031c63          	bnez	t1,ffffffffc020026a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200236:	4785                	li	a5,1
ffffffffc0200238:	8432                	mv	s0,a2
ffffffffc020023a:	000ac717          	auipc	a4,0xac
ffffffffc020023e:	1af73723          	sd	a5,430(a4) # ffffffffc02ac3e8 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200242:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200246:	85aa                	mv	a1,a0
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	42050513          	addi	a0,a0,1056 # ffffffffc0206668 <etext+0x36>
    va_start(ap, fmt);
ffffffffc0200250:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200252:	e7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200256:	65a2                	ld	a1,8(sp)
ffffffffc0200258:	8522                	mv	a0,s0
ffffffffc020025a:	e57ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025e:	00007517          	auipc	a0,0x7
ffffffffc0200262:	1f250513          	addi	a0,a0,498 # ffffffffc0207450 <commands+0xca8>
ffffffffc0200266:	e6bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	4581                	li	a1,0
ffffffffc020026e:	4601                	li	a2,0
ffffffffc0200270:	48a1                	li	a7,8
ffffffffc0200272:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200276:	3e6000ef          	jal	ra,ffffffffc020065c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	174000ef          	jal	ra,ffffffffc02003f0 <kmonitor>
ffffffffc0200280:	bfed                	j	ffffffffc020027a <__panic+0x64>

ffffffffc0200282 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200282:	715d                	addi	sp,sp,-80
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	fc3e                	sd	a5,56(sp)
ffffffffc0200288:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc020028a:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	862e                	mv	a2,a1
ffffffffc020028e:	85aa                	mv	a1,a0
ffffffffc0200290:	00006517          	auipc	a0,0x6
ffffffffc0200294:	3f850513          	addi	a0,a0,1016 # ffffffffc0206688 <etext+0x56>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200298:	ec06                	sd	ra,24(sp)
ffffffffc020029a:	f436                	sd	a3,40(sp)
ffffffffc020029c:	f83a                	sd	a4,48(sp)
ffffffffc020029e:	e0c2                	sd	a6,64(sp)
ffffffffc02002a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a2:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a4:	e2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a8:	65a2                	ld	a1,8(sp)
ffffffffc02002aa:	8522                	mv	a0,s0
ffffffffc02002ac:	e05ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002b0:	00007517          	auipc	a0,0x7
ffffffffc02002b4:	1a050513          	addi	a0,a0,416 # ffffffffc0207450 <commands+0xca8>
ffffffffc02002b8:	e19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002bc:	60e2                	ld	ra,24(sp)
ffffffffc02002be:	6442                	ld	s0,16(sp)
ffffffffc02002c0:	6161                	addi	sp,sp,80
ffffffffc02002c2:	8082                	ret

ffffffffc02002c4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	41250513          	addi	a0,a0,1042 # ffffffffc02066d8 <etext+0xa6>
void print_kerninfo(void) {
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	e01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d4:	00000597          	auipc	a1,0x0
ffffffffc02002d8:	d6258593          	addi	a1,a1,-670 # ffffffffc0200036 <kern_init>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	41c50513          	addi	a0,a0,1052 # ffffffffc02066f8 <etext+0xc6>
ffffffffc02002e4:	dedff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e8:	00006597          	auipc	a1,0x6
ffffffffc02002ec:	34a58593          	addi	a1,a1,842 # ffffffffc0206632 <etext>
ffffffffc02002f0:	00006517          	auipc	a0,0x6
ffffffffc02002f4:	42850513          	addi	a0,a0,1064 # ffffffffc0206718 <etext+0xe6>
ffffffffc02002f8:	dd9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fc:	000a1597          	auipc	a1,0xa1
ffffffffc0200300:	cec58593          	addi	a1,a1,-788 # ffffffffc02a0fe8 <edata>
ffffffffc0200304:	00006517          	auipc	a0,0x6
ffffffffc0200308:	43450513          	addi	a0,a0,1076 # ffffffffc0206738 <etext+0x106>
ffffffffc020030c:	dc5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200310:	000ac597          	auipc	a1,0xac
ffffffffc0200314:	26858593          	addi	a1,a1,616 # ffffffffc02ac578 <end>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	44050513          	addi	a0,a0,1088 # ffffffffc0206758 <etext+0x126>
ffffffffc0200320:	db1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200324:	000ac597          	auipc	a1,0xac
ffffffffc0200328:	65358593          	addi	a1,a1,1619 # ffffffffc02ac977 <end+0x3ff>
ffffffffc020032c:	00000797          	auipc	a5,0x0
ffffffffc0200330:	d0a78793          	addi	a5,a5,-758 # ffffffffc0200036 <kern_init>
ffffffffc0200334:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200338:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200342:	95be                	add	a1,a1,a5
ffffffffc0200344:	85a9                	srai	a1,a1,0xa
ffffffffc0200346:	00006517          	auipc	a0,0x6
ffffffffc020034a:	43250513          	addi	a0,a0,1074 # ffffffffc0206778 <etext+0x146>
}
ffffffffc020034e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200350:	d81ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200354 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200356:	00006617          	auipc	a2,0x6
ffffffffc020035a:	35260613          	addi	a2,a2,850 # ffffffffc02066a8 <etext+0x76>
ffffffffc020035e:	04d00593          	li	a1,77
ffffffffc0200362:	00006517          	auipc	a0,0x6
ffffffffc0200366:	35e50513          	addi	a0,a0,862 # ffffffffc02066c0 <etext+0x8e>
void print_stackframe(void) {
ffffffffc020036a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020036c:	eabff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200370 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200370:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200372:	00006617          	auipc	a2,0x6
ffffffffc0200376:	51660613          	addi	a2,a2,1302 # ffffffffc0206888 <commands+0xe0>
ffffffffc020037a:	00006597          	auipc	a1,0x6
ffffffffc020037e:	52e58593          	addi	a1,a1,1326 # ffffffffc02068a8 <commands+0x100>
ffffffffc0200382:	00006517          	auipc	a0,0x6
ffffffffc0200386:	52e50513          	addi	a0,a0,1326 # ffffffffc02068b0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020038a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020038c:	d45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200390:	00006617          	auipc	a2,0x6
ffffffffc0200394:	53060613          	addi	a2,a2,1328 # ffffffffc02068c0 <commands+0x118>
ffffffffc0200398:	00006597          	auipc	a1,0x6
ffffffffc020039c:	55058593          	addi	a1,a1,1360 # ffffffffc02068e8 <commands+0x140>
ffffffffc02003a0:	00006517          	auipc	a0,0x6
ffffffffc02003a4:	51050513          	addi	a0,a0,1296 # ffffffffc02068b0 <commands+0x108>
ffffffffc02003a8:	d29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003ac:	00006617          	auipc	a2,0x6
ffffffffc02003b0:	54c60613          	addi	a2,a2,1356 # ffffffffc02068f8 <commands+0x150>
ffffffffc02003b4:	00006597          	auipc	a1,0x6
ffffffffc02003b8:	56458593          	addi	a1,a1,1380 # ffffffffc0206918 <commands+0x170>
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	4f450513          	addi	a0,a0,1268 # ffffffffc02068b0 <commands+0x108>
ffffffffc02003c4:	d0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c8:	60a2                	ld	ra,8(sp)
ffffffffc02003ca:	4501                	li	a0,0
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d0:	1141                	addi	sp,sp,-16
ffffffffc02003d2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d4:	ef1ff0ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>
    return 0;
}
ffffffffc02003d8:	60a2                	ld	ra,8(sp)
ffffffffc02003da:	4501                	li	a0,0
ffffffffc02003dc:	0141                	addi	sp,sp,16
ffffffffc02003de:	8082                	ret

ffffffffc02003e0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e0:	1141                	addi	sp,sp,-16
ffffffffc02003e2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e4:	f71ff0ef          	jal	ra,ffffffffc0200354 <print_stackframe>
    return 0;
}
ffffffffc02003e8:	60a2                	ld	ra,8(sp)
ffffffffc02003ea:	4501                	li	a0,0
ffffffffc02003ec:	0141                	addi	sp,sp,16
ffffffffc02003ee:	8082                	ret

ffffffffc02003f0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f0:	7115                	addi	sp,sp,-224
ffffffffc02003f2:	e962                	sd	s8,144(sp)
ffffffffc02003f4:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	00006517          	auipc	a0,0x6
ffffffffc02003fa:	3fa50513          	addi	a0,a0,1018 # ffffffffc02067f0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fe:	ed86                	sd	ra,216(sp)
ffffffffc0200400:	e9a2                	sd	s0,208(sp)
ffffffffc0200402:	e5a6                	sd	s1,200(sp)
ffffffffc0200404:	e1ca                	sd	s2,192(sp)
ffffffffc0200406:	fd4e                	sd	s3,184(sp)
ffffffffc0200408:	f952                	sd	s4,176(sp)
ffffffffc020040a:	f556                	sd	s5,168(sp)
ffffffffc020040c:	f15a                	sd	s6,160(sp)
ffffffffc020040e:	ed5e                	sd	s7,152(sp)
ffffffffc0200410:	e566                	sd	s9,136(sp)
ffffffffc0200412:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200414:	cbdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200418:	00006517          	auipc	a0,0x6
ffffffffc020041c:	40050513          	addi	a0,a0,1024 # ffffffffc0206818 <commands+0x70>
ffffffffc0200420:	cb1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200424:	000c0563          	beqz	s8,ffffffffc020042e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200428:	8562                	mv	a0,s8
ffffffffc020042a:	420000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc020042e:	00006c97          	auipc	s9,0x6
ffffffffc0200432:	37ac8c93          	addi	s9,s9,890 # ffffffffc02067a8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200436:	00006997          	auipc	s3,0x6
ffffffffc020043a:	40a98993          	addi	s3,s3,1034 # ffffffffc0206840 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	40a90913          	addi	s2,s2,1034 # ffffffffc0206848 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200448:	00006b17          	auipc	s6,0x6
ffffffffc020044c:	408b0b13          	addi	s6,s6,1032 # ffffffffc0206850 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200450:	00006a97          	auipc	s5,0x6
ffffffffc0200454:	458a8a93          	addi	s5,s5,1112 # ffffffffc02068a8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200458:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020045a:	854e                	mv	a0,s3
ffffffffc020045c:	cfdff0ef          	jal	ra,ffffffffc0200158 <readline>
ffffffffc0200460:	842a                	mv	s0,a0
ffffffffc0200462:	dd65                	beqz	a0,ffffffffc020045a <kmonitor+0x6a>
ffffffffc0200464:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200468:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046a:	c999                	beqz	a1,ffffffffc0200480 <kmonitor+0x90>
ffffffffc020046c:	854a                	mv	a0,s2
ffffffffc020046e:	56d050ef          	jal	ra,ffffffffc02061da <strchr>
ffffffffc0200472:	c925                	beqz	a0,ffffffffc02004e2 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	f5fd                	bnez	a1,ffffffffc020046c <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200480:	dce9                	beqz	s1,ffffffffc020045a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006d17          	auipc	s10,0x6
ffffffffc0200488:	324d0d13          	addi	s10,s10,804 # ffffffffc02067a8 <commands>
    if (argc == 0) {
ffffffffc020048c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200490:	0d61                	addi	s10,s10,24
ffffffffc0200492:	51f050ef          	jal	ra,ffffffffc02061b0 <strcmp>
ffffffffc0200496:	c919                	beqz	a0,ffffffffc02004ac <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200498:	2405                	addiw	s0,s0,1
ffffffffc020049a:	09740463          	beq	s0,s7,ffffffffc0200522 <kmonitor+0x132>
ffffffffc020049e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02004a2:	6582                	ld	a1,0(sp)
ffffffffc02004a4:	0d61                	addi	s10,s10,24
ffffffffc02004a6:	50b050ef          	jal	ra,ffffffffc02061b0 <strcmp>
ffffffffc02004aa:	f57d                	bnez	a0,ffffffffc0200498 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ac:	00141793          	slli	a5,s0,0x1
ffffffffc02004b0:	97a2                	add	a5,a5,s0
ffffffffc02004b2:	078e                	slli	a5,a5,0x3
ffffffffc02004b4:	97e6                	add	a5,a5,s9
ffffffffc02004b6:	6b9c                	ld	a5,16(a5)
ffffffffc02004b8:	8662                	mv	a2,s8
ffffffffc02004ba:	002c                	addi	a1,sp,8
ffffffffc02004bc:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004c0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004c2:	f8055ce3          	bgez	a0,ffffffffc020045a <kmonitor+0x6a>
}
ffffffffc02004c6:	60ee                	ld	ra,216(sp)
ffffffffc02004c8:	644e                	ld	s0,208(sp)
ffffffffc02004ca:	64ae                	ld	s1,200(sp)
ffffffffc02004cc:	690e                	ld	s2,192(sp)
ffffffffc02004ce:	79ea                	ld	s3,184(sp)
ffffffffc02004d0:	7a4a                	ld	s4,176(sp)
ffffffffc02004d2:	7aaa                	ld	s5,168(sp)
ffffffffc02004d4:	7b0a                	ld	s6,160(sp)
ffffffffc02004d6:	6bea                	ld	s7,152(sp)
ffffffffc02004d8:	6c4a                	ld	s8,144(sp)
ffffffffc02004da:	6caa                	ld	s9,136(sp)
ffffffffc02004dc:	6d0a                	ld	s10,128(sp)
ffffffffc02004de:	612d                	addi	sp,sp,224
ffffffffc02004e0:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004e2:	00044783          	lbu	a5,0(s0)
ffffffffc02004e6:	dfc9                	beqz	a5,ffffffffc0200480 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e8:	03448863          	beq	s1,s4,ffffffffc0200518 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004ec:	00349793          	slli	a5,s1,0x3
ffffffffc02004f0:	0118                	addi	a4,sp,128
ffffffffc02004f2:	97ba                	add	a5,a5,a4
ffffffffc02004f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004fc:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fe:	e591                	bnez	a1,ffffffffc020050a <kmonitor+0x11a>
ffffffffc0200500:	b749                	j	ffffffffc0200482 <kmonitor+0x92>
            buf ++;
ffffffffc0200502:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	ddad                	beqz	a1,ffffffffc0200482 <kmonitor+0x92>
ffffffffc020050a:	854a                	mv	a0,s2
ffffffffc020050c:	4cf050ef          	jal	ra,ffffffffc02061da <strchr>
ffffffffc0200510:	d96d                	beqz	a0,ffffffffc0200502 <kmonitor+0x112>
ffffffffc0200512:	00044583          	lbu	a1,0(s0)
ffffffffc0200516:	bf91                	j	ffffffffc020046a <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200518:	45c1                	li	a1,16
ffffffffc020051a:	855a                	mv	a0,s6
ffffffffc020051c:	bb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200520:	b7f1                	j	ffffffffc02004ec <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200522:	6582                	ld	a1,0(sp)
ffffffffc0200524:	00006517          	auipc	a0,0x6
ffffffffc0200528:	34c50513          	addi	a0,a0,844 # ffffffffc0206870 <commands+0xc8>
ffffffffc020052c:	ba5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc0200530:	b72d                	j	ffffffffc020045a <kmonitor+0x6a>

ffffffffc0200532 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200534:	00253513          	sltiu	a0,a0,2
ffffffffc0200538:	8082                	ret

ffffffffc020053a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020053a:	03800513          	li	a0,56
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200540:	000a1797          	auipc	a5,0xa1
ffffffffc0200544:	ea878793          	addi	a5,a5,-344 # ffffffffc02a13e8 <ide>
ffffffffc0200548:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020054c:	1141                	addi	sp,sp,-16
ffffffffc020054e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200550:	95be                	add	a1,a1,a5
ffffffffc0200552:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200556:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200558:	4b3050ef          	jal	ra,ffffffffc020620a <memcpy>
    return 0;
}
ffffffffc020055c:	60a2                	ld	ra,8(sp)
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	0141                	addi	sp,sp,16
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200564:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200566:	0095979b          	slliw	a5,a1,0x9
ffffffffc020056a:	000a1517          	auipc	a0,0xa1
ffffffffc020056e:	e7e50513          	addi	a0,a0,-386 # ffffffffc02a13e8 <ide>
                   size_t nsecs) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200574:	00969613          	slli	a2,a3,0x9
ffffffffc0200578:	85ba                	mv	a1,a4
ffffffffc020057a:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057e:	48d050ef          	jal	ra,ffffffffc020620a <memcpy>
    return 0;
}
ffffffffc0200582:	60a2                	ld	ra,8(sp)
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	0141                	addi	sp,sp,16
ffffffffc0200588:	8082                	ret

ffffffffc020058a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020058a:	67e1                	lui	a5,0x18
ffffffffc020058c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc28>
ffffffffc0200590:	000ac717          	auipc	a4,0xac
ffffffffc0200594:	e6f73023          	sd	a5,-416(a4) # ffffffffc02ac3f0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200598:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020059c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059e:	953e                	add	a0,a0,a5
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a8:	02000793          	li	a5,32
ffffffffc02005ac:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b0:	00006517          	auipc	a0,0x6
ffffffffc02005b4:	37850513          	addi	a0,a0,888 # ffffffffc0206928 <commands+0x180>
    ticks = 0;
ffffffffc02005b8:	000ac797          	auipc	a5,0xac
ffffffffc02005bc:	e807b823          	sd	zero,-368(a5) # ffffffffc02ac448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005c0:	b11ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02005c4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005c4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c8:	000ac797          	auipc	a5,0xac
ffffffffc02005cc:	e2878793          	addi	a5,a5,-472 # ffffffffc02ac3f0 <timebase>
ffffffffc02005d0:	639c                	ld	a5,0(a5)
ffffffffc02005d2:	4581                	li	a1,0
ffffffffc02005d4:	4601                	li	a2,0
ffffffffc02005d6:	953e                	add	a0,a0,a5
ffffffffc02005d8:	4881                	li	a7,0
ffffffffc02005da:	00000073          	ecall
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005e0:	8082                	ret

ffffffffc02005e2 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e2:	100027f3          	csrr	a5,sstatus
ffffffffc02005e6:	8b89                	andi	a5,a5,2
ffffffffc02005e8:	0ff57513          	andi	a0,a0,255
ffffffffc02005ec:	e799                	bnez	a5,ffffffffc02005fa <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005ee:	4581                	li	a1,0
ffffffffc02005f0:	4601                	li	a2,0
ffffffffc02005f2:	4885                	li	a7,1
ffffffffc02005f4:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f8:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005fa:	1101                	addi	sp,sp,-32
ffffffffc02005fc:	ec06                	sd	ra,24(sp)
ffffffffc02005fe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200600:	05c000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200604:	6522                	ld	a0,8(sp)
ffffffffc0200606:	4581                	li	a1,0
ffffffffc0200608:	4601                	li	a2,0
ffffffffc020060a:	4885                	li	a7,1
ffffffffc020060c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200610:	60e2                	ld	ra,24(sp)
ffffffffc0200612:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200614:	0420006f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200618 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200618:	100027f3          	csrr	a5,sstatus
ffffffffc020061c:	8b89                	andi	a5,a5,2
ffffffffc020061e:	eb89                	bnez	a5,ffffffffc0200630 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	4581                	li	a1,0
ffffffffc0200624:	4601                	li	a2,0
ffffffffc0200626:	4889                	li	a7,2
ffffffffc0200628:	00000073          	ecall
ffffffffc020062c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020062e:	8082                	ret
int cons_getc(void) {
ffffffffc0200630:	1101                	addi	sp,sp,-32
ffffffffc0200632:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200634:	028000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200638:	4501                	li	a0,0
ffffffffc020063a:	4581                	li	a1,0
ffffffffc020063c:	4601                	li	a2,0
ffffffffc020063e:	4889                	li	a7,2
ffffffffc0200640:	00000073          	ecall
ffffffffc0200644:	2501                	sext.w	a0,a0
ffffffffc0200646:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200648:	00e000ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020064c:	60e2                	ld	ra,24(sp)
ffffffffc020064e:	6522                	ld	a0,8(sp)
ffffffffc0200650:	6105                	addi	sp,sp,32
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200654:	8082                	ret

ffffffffc0200656 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200656:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020065a:	8082                	ret

ffffffffc020065c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206c70 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	a43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	5f450513          	addi	a0,a0,1524 # ffffffffc0206c88 <commands+0x4e0>
ffffffffc020069c:	a35ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	5fe50513          	addi	a0,a0,1534 # ffffffffc0206ca0 <commands+0x4f8>
ffffffffc02006aa:	a27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	60850513          	addi	a0,a0,1544 # ffffffffc0206cb8 <commands+0x510>
ffffffffc02006b8:	a19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	61250513          	addi	a0,a0,1554 # ffffffffc0206cd0 <commands+0x528>
ffffffffc02006c6:	a0bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	61c50513          	addi	a0,a0,1564 # ffffffffc0206ce8 <commands+0x540>
ffffffffc02006d4:	9fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	62650513          	addi	a0,a0,1574 # ffffffffc0206d00 <commands+0x558>
ffffffffc02006e2:	9efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	63050513          	addi	a0,a0,1584 # ffffffffc0206d18 <commands+0x570>
ffffffffc02006f0:	9e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	63a50513          	addi	a0,a0,1594 # ffffffffc0206d30 <commands+0x588>
ffffffffc02006fe:	9d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	64450513          	addi	a0,a0,1604 # ffffffffc0206d48 <commands+0x5a0>
ffffffffc020070c:	9c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	64e50513          	addi	a0,a0,1614 # ffffffffc0206d60 <commands+0x5b8>
ffffffffc020071a:	9b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	65850513          	addi	a0,a0,1624 # ffffffffc0206d78 <commands+0x5d0>
ffffffffc0200728:	9a9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	66250513          	addi	a0,a0,1634 # ffffffffc0206d90 <commands+0x5e8>
ffffffffc0200736:	99bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	66c50513          	addi	a0,a0,1644 # ffffffffc0206da8 <commands+0x600>
ffffffffc0200744:	98dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	67650513          	addi	a0,a0,1654 # ffffffffc0206dc0 <commands+0x618>
ffffffffc0200752:	97fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	68050513          	addi	a0,a0,1664 # ffffffffc0206dd8 <commands+0x630>
ffffffffc0200760:	971ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	68a50513          	addi	a0,a0,1674 # ffffffffc0206df0 <commands+0x648>
ffffffffc020076e:	963ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	69450513          	addi	a0,a0,1684 # ffffffffc0206e08 <commands+0x660>
ffffffffc020077c:	955ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	69e50513          	addi	a0,a0,1694 # ffffffffc0206e20 <commands+0x678>
ffffffffc020078a:	947ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	6a850513          	addi	a0,a0,1704 # ffffffffc0206e38 <commands+0x690>
ffffffffc0200798:	939ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	6b250513          	addi	a0,a0,1714 # ffffffffc0206e50 <commands+0x6a8>
ffffffffc02007a6:	92bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206e68 <commands+0x6c0>
ffffffffc02007b4:	91dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	6c650513          	addi	a0,a0,1734 # ffffffffc0206e80 <commands+0x6d8>
ffffffffc02007c2:	90fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	6d050513          	addi	a0,a0,1744 # ffffffffc0206e98 <commands+0x6f0>
ffffffffc02007d0:	901ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	6da50513          	addi	a0,a0,1754 # ffffffffc0206eb0 <commands+0x708>
ffffffffc02007de:	8f3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	6e450513          	addi	a0,a0,1764 # ffffffffc0206ec8 <commands+0x720>
ffffffffc02007ec:	8e5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	6ee50513          	addi	a0,a0,1774 # ffffffffc0206ee0 <commands+0x738>
ffffffffc02007fa:	8d7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	6f850513          	addi	a0,a0,1784 # ffffffffc0206ef8 <commands+0x750>
ffffffffc0200808:	8c9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	70250513          	addi	a0,a0,1794 # ffffffffc0206f10 <commands+0x768>
ffffffffc0200816:	8bbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	70c50513          	addi	a0,a0,1804 # ffffffffc0206f28 <commands+0x780>
ffffffffc0200824:	8adff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	71650513          	addi	a0,a0,1814 # ffffffffc0206f40 <commands+0x798>
ffffffffc0200832:	89fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	71c50513          	addi	a0,a0,1820 # ffffffffc0206f58 <commands+0x7b0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	88bff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	71e50513          	addi	a0,a0,1822 # ffffffffc0206f70 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	875ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	71e50513          	addi	a0,a0,1822 # ffffffffc0206f88 <commands+0x7e0>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	72650513          	addi	a0,a0,1830 # ffffffffc0206fa0 <commands+0x7f8>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	72e50513          	addi	a0,a0,1838 # ffffffffc0206fb8 <commands+0x810>
ffffffffc0200892:	83fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	72a50513          	addi	a0,a0,1834 # ffffffffc0206fc8 <commands+0x820>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	829ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	bc048493          	addi	s1,s1,-1088 # ffffffffc02ac470 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	30a50513          	addi	a0,a0,778 # ffffffffc0206bf0 <commands+0x448>
ffffffffc02008ee:	fe2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	b3278793          	addi	a5,a5,-1230 # ffffffffc02ac428 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	b3078793          	addi	a5,a5,-1232 # ffffffffc02ac430 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	3940206f          	j	ffffffffc0202cb2 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	af278793          	addi	a5,a5,-1294 # ffffffffc02ac428 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	35e0206f          	j	ffffffffc0202cb2 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	2b868693          	addi	a3,a3,696 # ffffffffc0206c10 <commands+0x468>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	2c860613          	addi	a2,a2,712 # ffffffffc0206c28 <commands+0x480>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	2d450513          	addi	a0,a0,724 # ffffffffc0206c40 <commands+0x498>
ffffffffc0200974:	8a3ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	24e50513          	addi	a0,a0,590 # ffffffffc0206bf0 <commands+0x448>
ffffffffc02009aa:	f26ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	2aa60613          	addi	a2,a2,682 # ffffffffc0206c58 <commands+0x4b0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	28650513          	addi	a0,a0,646 # ffffffffc0206c40 <commands+0x498>
ffffffffc02009c2:	855ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	f6870713          	addi	a4,a4,-152 # ffffffffc0206944 <commands+0x19c>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	1c250513          	addi	a0,a0,450 # ffffffffc0206bb0 <commands+0x408>
ffffffffc02009f6:	edaff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	19650513          	addi	a0,a0,406 # ffffffffc0206b90 <commands+0x3e8>
ffffffffc0200a02:	eceff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	14a50513          	addi	a0,a0,330 # ffffffffc0206b50 <commands+0x3a8>
ffffffffc0200a0e:	ec2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	15e50513          	addi	a0,a0,350 # ffffffffc0206b70 <commands+0x3c8>
ffffffffc0200a1a:	eb6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	1b250513          	addi	a0,a0,434 # ffffffffc0206bd0 <commands+0x428>
ffffffffc0200a26:	eaaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b97ff0ef          	jal	ra,ffffffffc02005c4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	a1678793          	addi	a5,a5,-1514 # ffffffffc02ac448 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	a0f6b123          	sd	a5,-1534(a3) # ffffffffc02ac448 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	9d878793          	addi	a5,a5,-1576 # ffffffffc02ac428 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	f0070713          	addi	a4,a4,-256 # ffffffffc0206974 <commands+0x1cc>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	01850513          	addi	a0,a0,24 # ffffffffc0206aa8 <commands+0x300>
ffffffffc0200a98:	e38ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	62c0506f          	j	ffffffffc02060da <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	01650513          	addi	a0,a0,22 # ffffffffc0206ac8 <commands+0x320>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	e0eff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	02250513          	addi	a0,a0,34 # ffffffffc0206ae8 <commands+0x340>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	03850513          	addi	a0,a0,56 # ffffffffc0206b08 <commands+0x360>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	04650513          	addi	a0,a0,70 # ffffffffc0206b20 <commands+0x378>
ffffffffc0200ae2:	deeff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	03c50513          	addi	a0,a0,60 # ffffffffc0206b38 <commands+0x390>
ffffffffc0200b04:	dccff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	f3e60613          	addi	a2,a2,-194 # ffffffffc0206a58 <commands+0x2b0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	11a50513          	addi	a0,a0,282 # ffffffffc0206c40 <commands+0x498>
ffffffffc0200b2e:	ee8ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	e8650513          	addi	a0,a0,-378 # ffffffffc02069b8 <commands+0x210>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	e9c50513          	addi	a0,a0,-356 # ffffffffc02069d8 <commands+0x230>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	eb250513          	addi	a0,a0,-334 # ffffffffc02069f8 <commands+0x250>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	ec050513          	addi	a0,a0,-320 # ffffffffc0206a10 <commands+0x268>
ffffffffc0200b58:	d78ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	56c050ef          	jal	ra,ffffffffc02060da <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	8b678793          	addi	a5,a5,-1866 # ffffffffc02ac428 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	e9050513          	addi	a0,a0,-368 # ffffffffc0206a20 <commands+0x278>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	ea650513          	addi	a0,a0,-346 # ffffffffc0206a40 <commands+0x298>
ffffffffc0200ba2:	d2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	ea060613          	addi	a2,a2,-352 # ffffffffc0206a58 <commands+0x2b0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	07c50513          	addi	a0,a0,124 # ffffffffc0206c40 <commands+0x498>
ffffffffc0200bcc:	e4aff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	ec050513          	addi	a0,a0,-320 # ffffffffc0206a90 <commands+0x2e8>
ffffffffc0200bd8:	cf8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	e6860613          	addi	a2,a2,-408 # ffffffffc0206a58 <commands+0x2b0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	04450513          	addi	a0,a0,68 # ffffffffc0206c40 <commands+0x498>
ffffffffc0200c04:	e12ff0ef          	jal	ra,ffffffffc0200216 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	e6460613          	addi	a2,a2,-412 # ffffffffc0206a78 <commands+0x2d0>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	02050513          	addi	a0,a0,32 # ffffffffc0206c40 <commands+0x498>
ffffffffc0200c28:	deeff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	e2060613          	addi	a2,a2,-480 # ffffffffc0206a58 <commands+0x2b0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206c40 <commands+0x498>
ffffffffc0200c4c:	dcaff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ab417          	auipc	s0,0xab
ffffffffc0200c58:	7d440413          	addi	s0,s0,2004 # ffffffffc02ac428 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	3140506f          	j	ffffffffc0205fe4 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	776040ef          	jal	ra,ffffffffc020544c <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e56:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e58:	00006617          	auipc	a2,0x6
ffffffffc0200e5c:	1f060613          	addi	a2,a2,496 # ffffffffc0207048 <commands+0x8a0>
ffffffffc0200e60:	06200593          	li	a1,98
ffffffffc0200e64:	00006517          	auipc	a0,0x6
ffffffffc0200e68:	20450513          	addi	a0,a0,516 # ffffffffc0207068 <commands+0x8c0>
pa2page(uintptr_t pa) {
ffffffffc0200e6c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e6e:	ba8ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200e72 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e72:	715d                	addi	sp,sp,-80
ffffffffc0200e74:	e0a2                	sd	s0,64(sp)
ffffffffc0200e76:	fc26                	sd	s1,56(sp)
ffffffffc0200e78:	f84a                	sd	s2,48(sp)
ffffffffc0200e7a:	f44e                	sd	s3,40(sp)
ffffffffc0200e7c:	f052                	sd	s4,32(sp)
ffffffffc0200e7e:	ec56                	sd	s5,24(sp)
ffffffffc0200e80:	e486                	sd	ra,72(sp)
ffffffffc0200e82:	842a                	mv	s0,a0
ffffffffc0200e84:	000ab497          	auipc	s1,0xab
ffffffffc0200e88:	5cc48493          	addi	s1,s1,1484 # ffffffffc02ac450 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e8c:	4985                	li	s3,1
ffffffffc0200e8e:	000aba17          	auipc	s4,0xab
ffffffffc0200e92:	58aa0a13          	addi	s4,s4,1418 # ffffffffc02ac418 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e96:	0005091b          	sext.w	s2,a0
ffffffffc0200e9a:	000aba97          	auipc	s5,0xab
ffffffffc0200e9e:	5d6a8a93          	addi	s5,s5,1494 # ffffffffc02ac470 <check_mm_struct>
ffffffffc0200ea2:	a00d                	j	ffffffffc0200ec4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200ea4:	609c                	ld	a5,0(s1)
ffffffffc0200ea6:	6f9c                	ld	a5,24(a5)
ffffffffc0200ea8:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200eaa:	4601                	li	a2,0
ffffffffc0200eac:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200eae:	ed0d                	bnez	a0,ffffffffc0200ee8 <alloc_pages+0x76>
ffffffffc0200eb0:	0289ec63          	bltu	s3,s0,ffffffffc0200ee8 <alloc_pages+0x76>
ffffffffc0200eb4:	000a2783          	lw	a5,0(s4)
ffffffffc0200eb8:	2781                	sext.w	a5,a5
ffffffffc0200eba:	c79d                	beqz	a5,ffffffffc0200ee8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ebc:	000ab503          	ld	a0,0(s5)
ffffffffc0200ec0:	72e020ef          	jal	ra,ffffffffc02035ee <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ec4:	100027f3          	csrr	a5,sstatus
ffffffffc0200ec8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200eca:	8522                	mv	a0,s0
ffffffffc0200ecc:	dfe1                	beqz	a5,ffffffffc0200ea4 <alloc_pages+0x32>
        intr_disable();
ffffffffc0200ece:	f8eff0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200ed2:	609c                	ld	a5,0(s1)
ffffffffc0200ed4:	8522                	mv	a0,s0
ffffffffc0200ed6:	6f9c                	ld	a5,24(a5)
ffffffffc0200ed8:	9782                	jalr	a5
ffffffffc0200eda:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200edc:	f7aff0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0200ee0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ee2:	4601                	li	a2,0
ffffffffc0200ee4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ee6:	d569                	beqz	a0,ffffffffc0200eb0 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200ee8:	60a6                	ld	ra,72(sp)
ffffffffc0200eea:	6406                	ld	s0,64(sp)
ffffffffc0200eec:	74e2                	ld	s1,56(sp)
ffffffffc0200eee:	7942                	ld	s2,48(sp)
ffffffffc0200ef0:	79a2                	ld	s3,40(sp)
ffffffffc0200ef2:	7a02                	ld	s4,32(sp)
ffffffffc0200ef4:	6ae2                	ld	s5,24(sp)
ffffffffc0200ef6:	6161                	addi	sp,sp,80
ffffffffc0200ef8:	8082                	ret

ffffffffc0200efa <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200efa:	100027f3          	csrr	a5,sstatus
ffffffffc0200efe:	8b89                	andi	a5,a5,2
ffffffffc0200f00:	eb89                	bnez	a5,ffffffffc0200f12 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f02:	000ab797          	auipc	a5,0xab
ffffffffc0200f06:	54e78793          	addi	a5,a5,1358 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200f0a:	639c                	ld	a5,0(a5)
ffffffffc0200f0c:	0207b303          	ld	t1,32(a5)
ffffffffc0200f10:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f12:	1101                	addi	sp,sp,-32
ffffffffc0200f14:	ec06                	sd	ra,24(sp)
ffffffffc0200f16:	e822                	sd	s0,16(sp)
ffffffffc0200f18:	e426                	sd	s1,8(sp)
ffffffffc0200f1a:	842a                	mv	s0,a0
ffffffffc0200f1c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f1e:	f3eff0ef          	jal	ra,ffffffffc020065c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f22:	000ab797          	auipc	a5,0xab
ffffffffc0200f26:	52e78793          	addi	a5,a5,1326 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200f2a:	639c                	ld	a5,0(a5)
ffffffffc0200f2c:	85a6                	mv	a1,s1
ffffffffc0200f2e:	8522                	mv	a0,s0
ffffffffc0200f30:	739c                	ld	a5,32(a5)
ffffffffc0200f32:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f34:	6442                	ld	s0,16(sp)
ffffffffc0200f36:	60e2                	ld	ra,24(sp)
ffffffffc0200f38:	64a2                	ld	s1,8(sp)
ffffffffc0200f3a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f3c:	f1aff06f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200f40 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f40:	100027f3          	csrr	a5,sstatus
ffffffffc0200f44:	8b89                	andi	a5,a5,2
ffffffffc0200f46:	eb89                	bnez	a5,ffffffffc0200f58 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f48:	000ab797          	auipc	a5,0xab
ffffffffc0200f4c:	50878793          	addi	a5,a5,1288 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200f50:	639c                	ld	a5,0(a5)
ffffffffc0200f52:	0287b303          	ld	t1,40(a5)
ffffffffc0200f56:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200f58:	1141                	addi	sp,sp,-16
ffffffffc0200f5a:	e406                	sd	ra,8(sp)
ffffffffc0200f5c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f5e:	efeff0ef          	jal	ra,ffffffffc020065c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f62:	000ab797          	auipc	a5,0xab
ffffffffc0200f66:	4ee78793          	addi	a5,a5,1262 # ffffffffc02ac450 <pmm_manager>
ffffffffc0200f6a:	639c                	ld	a5,0(a5)
ffffffffc0200f6c:	779c                	ld	a5,40(a5)
ffffffffc0200f6e:	9782                	jalr	a5
ffffffffc0200f70:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f72:	ee4ff0ef          	jal	ra,ffffffffc0200656 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f76:	8522                	mv	a0,s0
ffffffffc0200f78:	60a2                	ld	ra,8(sp)
ffffffffc0200f7a:	6402                	ld	s0,0(sp)
ffffffffc0200f7c:	0141                	addi	sp,sp,16
ffffffffc0200f7e:	8082                	ret

ffffffffc0200f80 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f80:	7139                	addi	sp,sp,-64
ffffffffc0200f82:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f84:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200f88:	1ff4f493          	andi	s1,s1,511
ffffffffc0200f8c:	048e                	slli	s1,s1,0x3
ffffffffc0200f8e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f90:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f92:	f04a                	sd	s2,32(sp)
ffffffffc0200f94:	ec4e                	sd	s3,24(sp)
ffffffffc0200f96:	e852                	sd	s4,16(sp)
ffffffffc0200f98:	fc06                	sd	ra,56(sp)
ffffffffc0200f9a:	f822                	sd	s0,48(sp)
ffffffffc0200f9c:	e456                	sd	s5,8(sp)
ffffffffc0200f9e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fa0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fa4:	892e                	mv	s2,a1
ffffffffc0200fa6:	8a32                	mv	s4,a2
ffffffffc0200fa8:	000ab997          	auipc	s3,0xab
ffffffffc0200fac:	45898993          	addi	s3,s3,1112 # ffffffffc02ac400 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fb0:	e7bd                	bnez	a5,ffffffffc020101e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200fb2:	12060c63          	beqz	a2,ffffffffc02010ea <get_pte+0x16a>
ffffffffc0200fb6:	4505                	li	a0,1
ffffffffc0200fb8:	ebbff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0200fbc:	842a                	mv	s0,a0
ffffffffc0200fbe:	12050663          	beqz	a0,ffffffffc02010ea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200fc2:	000abb17          	auipc	s6,0xab
ffffffffc0200fc6:	4a6b0b13          	addi	s6,s6,1190 # ffffffffc02ac468 <pages>
ffffffffc0200fca:	000b3503          	ld	a0,0(s6)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fce:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200fd0:	000ab997          	auipc	s3,0xab
ffffffffc0200fd4:	43098993          	addi	s3,s3,1072 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0200fd8:	40a40533          	sub	a0,s0,a0
ffffffffc0200fdc:	00080ab7          	lui	s5,0x80
ffffffffc0200fe0:	8519                	srai	a0,a0,0x6
ffffffffc0200fe2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0200fe6:	c01c                	sw	a5,0(s0)
ffffffffc0200fe8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0200fea:	9556                	add	a0,a0,s5
ffffffffc0200fec:	83b1                	srli	a5,a5,0xc
ffffffffc0200fee:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ff0:	0532                	slli	a0,a0,0xc
ffffffffc0200ff2:	14e7f363          	bleu	a4,a5,ffffffffc0201138 <get_pte+0x1b8>
ffffffffc0200ff6:	000ab797          	auipc	a5,0xab
ffffffffc0200ffa:	46278793          	addi	a5,a5,1122 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0200ffe:	639c                	ld	a5,0(a5)
ffffffffc0201000:	6605                	lui	a2,0x1
ffffffffc0201002:	4581                	li	a1,0
ffffffffc0201004:	953e                	add	a0,a0,a5
ffffffffc0201006:	1f2050ef          	jal	ra,ffffffffc02061f8 <memset>
    return page - pages + nbase;
ffffffffc020100a:	000b3683          	ld	a3,0(s6)
ffffffffc020100e:	40d406b3          	sub	a3,s0,a3
ffffffffc0201012:	8699                	srai	a3,a3,0x6
ffffffffc0201014:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201016:	06aa                	slli	a3,a3,0xa
ffffffffc0201018:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020101c:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020101e:	77fd                	lui	a5,0xfffff
ffffffffc0201020:	068a                	slli	a3,a3,0x2
ffffffffc0201022:	0009b703          	ld	a4,0(s3)
ffffffffc0201026:	8efd                	and	a3,a3,a5
ffffffffc0201028:	00c6d793          	srli	a5,a3,0xc
ffffffffc020102c:	0ce7f163          	bleu	a4,a5,ffffffffc02010ee <get_pte+0x16e>
ffffffffc0201030:	000aba97          	auipc	s5,0xab
ffffffffc0201034:	428a8a93          	addi	s5,s5,1064 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0201038:	000ab403          	ld	s0,0(s5)
ffffffffc020103c:	01595793          	srli	a5,s2,0x15
ffffffffc0201040:	1ff7f793          	andi	a5,a5,511
ffffffffc0201044:	96a2                	add	a3,a3,s0
ffffffffc0201046:	00379413          	slli	s0,a5,0x3
ffffffffc020104a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020104c:	6014                	ld	a3,0(s0)
ffffffffc020104e:	0016f793          	andi	a5,a3,1
ffffffffc0201052:	e3ad                	bnez	a5,ffffffffc02010b4 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201054:	080a0b63          	beqz	s4,ffffffffc02010ea <get_pte+0x16a>
ffffffffc0201058:	4505                	li	a0,1
ffffffffc020105a:	e19ff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020105e:	84aa                	mv	s1,a0
ffffffffc0201060:	c549                	beqz	a0,ffffffffc02010ea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201062:	000abb17          	auipc	s6,0xab
ffffffffc0201066:	406b0b13          	addi	s6,s6,1030 # ffffffffc02ac468 <pages>
ffffffffc020106a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020106e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201070:	00080a37          	lui	s4,0x80
ffffffffc0201074:	40a48533          	sub	a0,s1,a0
ffffffffc0201078:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020107a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020107e:	c09c                	sw	a5,0(s1)
ffffffffc0201080:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201082:	9552                	add	a0,a0,s4
ffffffffc0201084:	83b1                	srli	a5,a5,0xc
ffffffffc0201086:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201088:	0532                	slli	a0,a0,0xc
ffffffffc020108a:	08e7fa63          	bleu	a4,a5,ffffffffc020111e <get_pte+0x19e>
ffffffffc020108e:	000ab783          	ld	a5,0(s5)
ffffffffc0201092:	6605                	lui	a2,0x1
ffffffffc0201094:	4581                	li	a1,0
ffffffffc0201096:	953e                	add	a0,a0,a5
ffffffffc0201098:	160050ef          	jal	ra,ffffffffc02061f8 <memset>
    return page - pages + nbase;
ffffffffc020109c:	000b3683          	ld	a3,0(s6)
ffffffffc02010a0:	40d486b3          	sub	a3,s1,a3
ffffffffc02010a4:	8699                	srai	a3,a3,0x6
ffffffffc02010a6:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02010a8:	06aa                	slli	a3,a3,0xa
ffffffffc02010aa:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02010ae:	e014                	sd	a3,0(s0)
ffffffffc02010b0:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010b4:	068a                	slli	a3,a3,0x2
ffffffffc02010b6:	757d                	lui	a0,0xfffff
ffffffffc02010b8:	8ee9                	and	a3,a3,a0
ffffffffc02010ba:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010be:	04e7f463          	bleu	a4,a5,ffffffffc0201106 <get_pte+0x186>
ffffffffc02010c2:	000ab503          	ld	a0,0(s5)
ffffffffc02010c6:	00c95793          	srli	a5,s2,0xc
ffffffffc02010ca:	1ff7f793          	andi	a5,a5,511
ffffffffc02010ce:	96aa                	add	a3,a3,a0
ffffffffc02010d0:	00379513          	slli	a0,a5,0x3
ffffffffc02010d4:	9536                	add	a0,a0,a3
}
ffffffffc02010d6:	70e2                	ld	ra,56(sp)
ffffffffc02010d8:	7442                	ld	s0,48(sp)
ffffffffc02010da:	74a2                	ld	s1,40(sp)
ffffffffc02010dc:	7902                	ld	s2,32(sp)
ffffffffc02010de:	69e2                	ld	s3,24(sp)
ffffffffc02010e0:	6a42                	ld	s4,16(sp)
ffffffffc02010e2:	6aa2                	ld	s5,8(sp)
ffffffffc02010e4:	6b02                	ld	s6,0(sp)
ffffffffc02010e6:	6121                	addi	sp,sp,64
ffffffffc02010e8:	8082                	ret
            return NULL;
ffffffffc02010ea:	4501                	li	a0,0
ffffffffc02010ec:	b7ed                	j	ffffffffc02010d6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010ee:	00006617          	auipc	a2,0x6
ffffffffc02010f2:	f2260613          	addi	a2,a2,-222 # ffffffffc0207010 <commands+0x868>
ffffffffc02010f6:	0e300593          	li	a1,227
ffffffffc02010fa:	00006517          	auipc	a0,0x6
ffffffffc02010fe:	f3e50513          	addi	a0,a0,-194 # ffffffffc0207038 <commands+0x890>
ffffffffc0201102:	914ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201106:	00006617          	auipc	a2,0x6
ffffffffc020110a:	f0a60613          	addi	a2,a2,-246 # ffffffffc0207010 <commands+0x868>
ffffffffc020110e:	0ee00593          	li	a1,238
ffffffffc0201112:	00006517          	auipc	a0,0x6
ffffffffc0201116:	f2650513          	addi	a0,a0,-218 # ffffffffc0207038 <commands+0x890>
ffffffffc020111a:	8fcff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020111e:	86aa                	mv	a3,a0
ffffffffc0201120:	00006617          	auipc	a2,0x6
ffffffffc0201124:	ef060613          	addi	a2,a2,-272 # ffffffffc0207010 <commands+0x868>
ffffffffc0201128:	0eb00593          	li	a1,235
ffffffffc020112c:	00006517          	auipc	a0,0x6
ffffffffc0201130:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207038 <commands+0x890>
ffffffffc0201134:	8e2ff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201138:	86aa                	mv	a3,a0
ffffffffc020113a:	00006617          	auipc	a2,0x6
ffffffffc020113e:	ed660613          	addi	a2,a2,-298 # ffffffffc0207010 <commands+0x868>
ffffffffc0201142:	0df00593          	li	a1,223
ffffffffc0201146:	00006517          	auipc	a0,0x6
ffffffffc020114a:	ef250513          	addi	a0,a0,-270 # ffffffffc0207038 <commands+0x890>
ffffffffc020114e:	8c8ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201152 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201152:	1141                	addi	sp,sp,-16
ffffffffc0201154:	e022                	sd	s0,0(sp)
ffffffffc0201156:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201158:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020115a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020115c:	e25ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201160:	c011                	beqz	s0,ffffffffc0201164 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201162:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201164:	c129                	beqz	a0,ffffffffc02011a6 <get_page+0x54>
ffffffffc0201166:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201168:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020116a:	0017f713          	andi	a4,a5,1
ffffffffc020116e:	e709                	bnez	a4,ffffffffc0201178 <get_page+0x26>
}
ffffffffc0201170:	60a2                	ld	ra,8(sp)
ffffffffc0201172:	6402                	ld	s0,0(sp)
ffffffffc0201174:	0141                	addi	sp,sp,16
ffffffffc0201176:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201178:	000ab717          	auipc	a4,0xab
ffffffffc020117c:	28870713          	addi	a4,a4,648 # ffffffffc02ac400 <npage>
ffffffffc0201180:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201182:	078a                	slli	a5,a5,0x2
ffffffffc0201184:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201186:	02e7f563          	bleu	a4,a5,ffffffffc02011b0 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020118a:	000ab717          	auipc	a4,0xab
ffffffffc020118e:	2de70713          	addi	a4,a4,734 # ffffffffc02ac468 <pages>
ffffffffc0201192:	6308                	ld	a0,0(a4)
ffffffffc0201194:	60a2                	ld	ra,8(sp)
ffffffffc0201196:	6402                	ld	s0,0(sp)
ffffffffc0201198:	fff80737          	lui	a4,0xfff80
ffffffffc020119c:	97ba                	add	a5,a5,a4
ffffffffc020119e:	079a                	slli	a5,a5,0x6
ffffffffc02011a0:	953e                	add	a0,a0,a5
ffffffffc02011a2:	0141                	addi	sp,sp,16
ffffffffc02011a4:	8082                	ret
ffffffffc02011a6:	60a2                	ld	ra,8(sp)
ffffffffc02011a8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02011aa:	4501                	li	a0,0
}
ffffffffc02011ac:	0141                	addi	sp,sp,16
ffffffffc02011ae:	8082                	ret
ffffffffc02011b0:	ca7ff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc02011b4 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02011b4:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011b6:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02011ba:	ec86                	sd	ra,88(sp)
ffffffffc02011bc:	e8a2                	sd	s0,80(sp)
ffffffffc02011be:	e4a6                	sd	s1,72(sp)
ffffffffc02011c0:	e0ca                	sd	s2,64(sp)
ffffffffc02011c2:	fc4e                	sd	s3,56(sp)
ffffffffc02011c4:	f852                	sd	s4,48(sp)
ffffffffc02011c6:	f456                	sd	s5,40(sp)
ffffffffc02011c8:	f05a                	sd	s6,32(sp)
ffffffffc02011ca:	ec5e                	sd	s7,24(sp)
ffffffffc02011cc:	e862                	sd	s8,16(sp)
ffffffffc02011ce:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011d0:	03479713          	slli	a4,a5,0x34
ffffffffc02011d4:	eb71                	bnez	a4,ffffffffc02012a8 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02011d6:	002007b7          	lui	a5,0x200
ffffffffc02011da:	842e                	mv	s0,a1
ffffffffc02011dc:	0af5e663          	bltu	a1,a5,ffffffffc0201288 <unmap_range+0xd4>
ffffffffc02011e0:	8932                	mv	s2,a2
ffffffffc02011e2:	0ac5f363          	bleu	a2,a1,ffffffffc0201288 <unmap_range+0xd4>
ffffffffc02011e6:	4785                	li	a5,1
ffffffffc02011e8:	07fe                	slli	a5,a5,0x1f
ffffffffc02011ea:	08c7ef63          	bltu	a5,a2,ffffffffc0201288 <unmap_range+0xd4>
ffffffffc02011ee:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011f0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011f2:	000abc97          	auipc	s9,0xab
ffffffffc02011f6:	20ec8c93          	addi	s9,s9,526 # ffffffffc02ac400 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011fa:	000abc17          	auipc	s8,0xab
ffffffffc02011fe:	26ec0c13          	addi	s8,s8,622 # ffffffffc02ac468 <pages>
ffffffffc0201202:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201206:	00200b37          	lui	s6,0x200
ffffffffc020120a:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020120e:	4601                	li	a2,0
ffffffffc0201210:	85a2                	mv	a1,s0
ffffffffc0201212:	854e                	mv	a0,s3
ffffffffc0201214:	d6dff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0201218:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020121a:	cd21                	beqz	a0,ffffffffc0201272 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc020121c:	611c                	ld	a5,0(a0)
ffffffffc020121e:	e38d                	bnez	a5,ffffffffc0201240 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0201220:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201222:	ff2466e3          	bltu	s0,s2,ffffffffc020120e <unmap_range+0x5a>
}
ffffffffc0201226:	60e6                	ld	ra,88(sp)
ffffffffc0201228:	6446                	ld	s0,80(sp)
ffffffffc020122a:	64a6                	ld	s1,72(sp)
ffffffffc020122c:	6906                	ld	s2,64(sp)
ffffffffc020122e:	79e2                	ld	s3,56(sp)
ffffffffc0201230:	7a42                	ld	s4,48(sp)
ffffffffc0201232:	7aa2                	ld	s5,40(sp)
ffffffffc0201234:	7b02                	ld	s6,32(sp)
ffffffffc0201236:	6be2                	ld	s7,24(sp)
ffffffffc0201238:	6c42                	ld	s8,16(sp)
ffffffffc020123a:	6ca2                	ld	s9,8(sp)
ffffffffc020123c:	6125                	addi	sp,sp,96
ffffffffc020123e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201240:	0017f713          	andi	a4,a5,1
ffffffffc0201244:	df71                	beqz	a4,ffffffffc0201220 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0201246:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020124a:	078a                	slli	a5,a5,0x2
ffffffffc020124c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020124e:	06e7fd63          	bleu	a4,a5,ffffffffc02012c8 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0201252:	000c3503          	ld	a0,0(s8)
ffffffffc0201256:	97de                	add	a5,a5,s7
ffffffffc0201258:	079a                	slli	a5,a5,0x6
ffffffffc020125a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020125c:	411c                	lw	a5,0(a0)
ffffffffc020125e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201262:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201264:	cf11                	beqz	a4,ffffffffc0201280 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201266:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020126a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020126e:	9452                	add	s0,s0,s4
ffffffffc0201270:	bf4d                	j	ffffffffc0201222 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201272:	945a                	add	s0,s0,s6
ffffffffc0201274:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201278:	d45d                	beqz	s0,ffffffffc0201226 <unmap_range+0x72>
ffffffffc020127a:	f9246ae3          	bltu	s0,s2,ffffffffc020120e <unmap_range+0x5a>
ffffffffc020127e:	b765                	j	ffffffffc0201226 <unmap_range+0x72>
            free_page(page);
ffffffffc0201280:	4585                	li	a1,1
ffffffffc0201282:	c79ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0201286:	b7c5                	j	ffffffffc0201266 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0201288:	00006697          	auipc	a3,0x6
ffffffffc020128c:	3b068693          	addi	a3,a3,944 # ffffffffc0207638 <commands+0xe90>
ffffffffc0201290:	00006617          	auipc	a2,0x6
ffffffffc0201294:	99860613          	addi	a2,a2,-1640 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201298:	11000593          	li	a1,272
ffffffffc020129c:	00006517          	auipc	a0,0x6
ffffffffc02012a0:	d9c50513          	addi	a0,a0,-612 # ffffffffc0207038 <commands+0x890>
ffffffffc02012a4:	f73fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012a8:	00006697          	auipc	a3,0x6
ffffffffc02012ac:	36068693          	addi	a3,a3,864 # ffffffffc0207608 <commands+0xe60>
ffffffffc02012b0:	00006617          	auipc	a2,0x6
ffffffffc02012b4:	97860613          	addi	a2,a2,-1672 # ffffffffc0206c28 <commands+0x480>
ffffffffc02012b8:	10f00593          	li	a1,271
ffffffffc02012bc:	00006517          	auipc	a0,0x6
ffffffffc02012c0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0207038 <commands+0x890>
ffffffffc02012c4:	f53fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02012c8:	b8fff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc02012cc <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012cc:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ce:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012d2:	fc86                	sd	ra,120(sp)
ffffffffc02012d4:	f8a2                	sd	s0,112(sp)
ffffffffc02012d6:	f4a6                	sd	s1,104(sp)
ffffffffc02012d8:	f0ca                	sd	s2,96(sp)
ffffffffc02012da:	ecce                	sd	s3,88(sp)
ffffffffc02012dc:	e8d2                	sd	s4,80(sp)
ffffffffc02012de:	e4d6                	sd	s5,72(sp)
ffffffffc02012e0:	e0da                	sd	s6,64(sp)
ffffffffc02012e2:	fc5e                	sd	s7,56(sp)
ffffffffc02012e4:	f862                	sd	s8,48(sp)
ffffffffc02012e6:	f466                	sd	s9,40(sp)
ffffffffc02012e8:	f06a                	sd	s10,32(sp)
ffffffffc02012ea:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ec:	03479713          	slli	a4,a5,0x34
ffffffffc02012f0:	1c071163          	bnez	a4,ffffffffc02014b2 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02012f4:	002007b7          	lui	a5,0x200
ffffffffc02012f8:	20f5e563          	bltu	a1,a5,ffffffffc0201502 <exit_range+0x236>
ffffffffc02012fc:	8b32                	mv	s6,a2
ffffffffc02012fe:	20c5f263          	bleu	a2,a1,ffffffffc0201502 <exit_range+0x236>
ffffffffc0201302:	4785                	li	a5,1
ffffffffc0201304:	07fe                	slli	a5,a5,0x1f
ffffffffc0201306:	1ec7ee63          	bltu	a5,a2,ffffffffc0201502 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020130a:	c00009b7          	lui	s3,0xc0000
ffffffffc020130e:	400007b7          	lui	a5,0x40000
ffffffffc0201312:	0135f9b3          	and	s3,a1,s3
ffffffffc0201316:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201318:	c0000337          	lui	t1,0xc0000
ffffffffc020131c:	00698933          	add	s2,s3,t1
ffffffffc0201320:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201324:	1ff97913          	andi	s2,s2,511
ffffffffc0201328:	8e2a                	mv	t3,a0
ffffffffc020132a:	090e                	slli	s2,s2,0x3
ffffffffc020132c:	9972                	add	s2,s2,t3
ffffffffc020132e:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201332:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0201336:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0201338:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020133c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020133e:	000abd17          	auipc	s10,0xab
ffffffffc0201342:	0c2d0d13          	addi	s10,s10,194 # ffffffffc02ac400 <npage>
    return KADDR(page2pa(page));
ffffffffc0201346:	00cddd93          	srli	s11,s11,0xc
ffffffffc020134a:	000ab717          	auipc	a4,0xab
ffffffffc020134e:	10e70713          	addi	a4,a4,270 # ffffffffc02ac458 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0201352:	000abe97          	auipc	t4,0xab
ffffffffc0201356:	116e8e93          	addi	t4,t4,278 # ffffffffc02ac468 <pages>
        if (pde1&PTE_V){
ffffffffc020135a:	e79d                	bnez	a5,ffffffffc0201388 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020135c:	12098963          	beqz	s3,ffffffffc020148e <exit_range+0x1c2>
ffffffffc0201360:	400007b7          	lui	a5,0x40000
ffffffffc0201364:	84ce                	mv	s1,s3
ffffffffc0201366:	97ce                	add	a5,a5,s3
ffffffffc0201368:	1369f363          	bleu	s6,s3,ffffffffc020148e <exit_range+0x1c2>
ffffffffc020136c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020136e:	00698933          	add	s2,s3,t1
ffffffffc0201372:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201376:	1ff97913          	andi	s2,s2,511
ffffffffc020137a:	090e                	slli	s2,s2,0x3
ffffffffc020137c:	9972                	add	s2,s2,t3
ffffffffc020137e:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0201382:	001bf793          	andi	a5,s7,1
ffffffffc0201386:	dbf9                	beqz	a5,ffffffffc020135c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201388:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020138c:	0b8a                	slli	s7,s7,0x2
ffffffffc020138e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201392:	14fbfc63          	bleu	a5,s7,ffffffffc02014ea <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201396:	fff80ab7          	lui	s5,0xfff80
ffffffffc020139a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020139c:	000806b7          	lui	a3,0x80
ffffffffc02013a0:	96d6                	add	a3,a3,s5
ffffffffc02013a2:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc02013a6:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc02013aa:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02013ac:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013ae:	12f67263          	bleu	a5,a2,ffffffffc02014d2 <exit_range+0x206>
ffffffffc02013b2:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc02013b6:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc02013b8:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc02013bc:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc02013be:	00080837          	lui	a6,0x80
ffffffffc02013c2:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02013c4:	00200c37          	lui	s8,0x200
ffffffffc02013c8:	a801                	j	ffffffffc02013d8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02013ca:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02013cc:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02013ce:	c0d9                	beqz	s1,ffffffffc0201454 <exit_range+0x188>
ffffffffc02013d0:	0934f263          	bleu	s3,s1,ffffffffc0201454 <exit_range+0x188>
ffffffffc02013d4:	0d64fc63          	bleu	s6,s1,ffffffffc02014ac <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013d8:	0154d413          	srli	s0,s1,0x15
ffffffffc02013dc:	1ff47413          	andi	s0,s0,511
ffffffffc02013e0:	040e                	slli	s0,s0,0x3
ffffffffc02013e2:	9452                	add	s0,s0,s4
ffffffffc02013e4:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02013e6:	0017f693          	andi	a3,a5,1
ffffffffc02013ea:	d2e5                	beqz	a3,ffffffffc02013ca <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02013ec:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013f0:	00279513          	slli	a0,a5,0x2
ffffffffc02013f4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013f6:	0eb57a63          	bleu	a1,a0,ffffffffc02014ea <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013fa:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02013fc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0201400:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc0201404:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201406:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201408:	0cb7f563          	bleu	a1,a5,ffffffffc02014d2 <exit_range+0x206>
ffffffffc020140c:	631c                	ld	a5,0(a4)
ffffffffc020140e:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0201410:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc0201414:	629c                	ld	a5,0(a3)
ffffffffc0201416:	8b85                	andi	a5,a5,1
ffffffffc0201418:	fbd5                	bnez	a5,ffffffffc02013cc <exit_range+0x100>
ffffffffc020141a:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020141c:	fed59ce3          	bne	a1,a3,ffffffffc0201414 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0201420:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0201424:	4585                	li	a1,1
ffffffffc0201426:	e072                	sd	t3,0(sp)
ffffffffc0201428:	953e                	add	a0,a0,a5
ffffffffc020142a:	ad1ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
                d0start += PTSIZE;
ffffffffc020142e:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201430:	00043023          	sd	zero,0(s0)
ffffffffc0201434:	000abe97          	auipc	t4,0xab
ffffffffc0201438:	034e8e93          	addi	t4,t4,52 # ffffffffc02ac468 <pages>
ffffffffc020143c:	6e02                	ld	t3,0(sp)
ffffffffc020143e:	c0000337          	lui	t1,0xc0000
ffffffffc0201442:	fff808b7          	lui	a7,0xfff80
ffffffffc0201446:	00080837          	lui	a6,0x80
ffffffffc020144a:	000ab717          	auipc	a4,0xab
ffffffffc020144e:	00e70713          	addi	a4,a4,14 # ffffffffc02ac458 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201452:	fcbd                	bnez	s1,ffffffffc02013d0 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0201454:	f00c84e3          	beqz	s9,ffffffffc020135c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201458:	000d3783          	ld	a5,0(s10)
ffffffffc020145c:	e072                	sd	t3,0(sp)
ffffffffc020145e:	08fbf663          	bleu	a5,s7,ffffffffc02014ea <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201462:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0201466:	67a2                	ld	a5,8(sp)
ffffffffc0201468:	4585                	li	a1,1
ffffffffc020146a:	953e                	add	a0,a0,a5
ffffffffc020146c:	a8fff0ef          	jal	ra,ffffffffc0200efa <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201470:	00093023          	sd	zero,0(s2)
ffffffffc0201474:	000ab717          	auipc	a4,0xab
ffffffffc0201478:	fe470713          	addi	a4,a4,-28 # ffffffffc02ac458 <va_pa_offset>
ffffffffc020147c:	c0000337          	lui	t1,0xc0000
ffffffffc0201480:	6e02                	ld	t3,0(sp)
ffffffffc0201482:	000abe97          	auipc	t4,0xab
ffffffffc0201486:	fe6e8e93          	addi	t4,t4,-26 # ffffffffc02ac468 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020148a:	ec099be3          	bnez	s3,ffffffffc0201360 <exit_range+0x94>
}
ffffffffc020148e:	70e6                	ld	ra,120(sp)
ffffffffc0201490:	7446                	ld	s0,112(sp)
ffffffffc0201492:	74a6                	ld	s1,104(sp)
ffffffffc0201494:	7906                	ld	s2,96(sp)
ffffffffc0201496:	69e6                	ld	s3,88(sp)
ffffffffc0201498:	6a46                	ld	s4,80(sp)
ffffffffc020149a:	6aa6                	ld	s5,72(sp)
ffffffffc020149c:	6b06                	ld	s6,64(sp)
ffffffffc020149e:	7be2                	ld	s7,56(sp)
ffffffffc02014a0:	7c42                	ld	s8,48(sp)
ffffffffc02014a2:	7ca2                	ld	s9,40(sp)
ffffffffc02014a4:	7d02                	ld	s10,32(sp)
ffffffffc02014a6:	6de2                	ld	s11,24(sp)
ffffffffc02014a8:	6109                	addi	sp,sp,128
ffffffffc02014aa:	8082                	ret
            if (free_pd0) {
ffffffffc02014ac:	ea0c8ae3          	beqz	s9,ffffffffc0201360 <exit_range+0x94>
ffffffffc02014b0:	b765                	j	ffffffffc0201458 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02014b2:	00006697          	auipc	a3,0x6
ffffffffc02014b6:	15668693          	addi	a3,a3,342 # ffffffffc0207608 <commands+0xe60>
ffffffffc02014ba:	00005617          	auipc	a2,0x5
ffffffffc02014be:	76e60613          	addi	a2,a2,1902 # ffffffffc0206c28 <commands+0x480>
ffffffffc02014c2:	12000593          	li	a1,288
ffffffffc02014c6:	00006517          	auipc	a0,0x6
ffffffffc02014ca:	b7250513          	addi	a0,a0,-1166 # ffffffffc0207038 <commands+0x890>
ffffffffc02014ce:	d49fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02014d2:	00006617          	auipc	a2,0x6
ffffffffc02014d6:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0207010 <commands+0x868>
ffffffffc02014da:	06900593          	li	a1,105
ffffffffc02014de:	00006517          	auipc	a0,0x6
ffffffffc02014e2:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02014e6:	d31fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014ea:	00006617          	auipc	a2,0x6
ffffffffc02014ee:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0207048 <commands+0x8a0>
ffffffffc02014f2:	06200593          	li	a1,98
ffffffffc02014f6:	00006517          	auipc	a0,0x6
ffffffffc02014fa:	b7250513          	addi	a0,a0,-1166 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02014fe:	d19fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0201502:	00006697          	auipc	a3,0x6
ffffffffc0201506:	13668693          	addi	a3,a3,310 # ffffffffc0207638 <commands+0xe90>
ffffffffc020150a:	00005617          	auipc	a2,0x5
ffffffffc020150e:	71e60613          	addi	a2,a2,1822 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201512:	12100593          	li	a1,289
ffffffffc0201516:	00006517          	auipc	a0,0x6
ffffffffc020151a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0207038 <commands+0x890>
ffffffffc020151e:	cf9fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201522 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201522:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201524:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201526:	e426                	sd	s1,8(sp)
ffffffffc0201528:	ec06                	sd	ra,24(sp)
ffffffffc020152a:	e822                	sd	s0,16(sp)
ffffffffc020152c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020152e:	a53ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    if (ptep != NULL) {
ffffffffc0201532:	c511                	beqz	a0,ffffffffc020153e <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201534:	611c                	ld	a5,0(a0)
ffffffffc0201536:	842a                	mv	s0,a0
ffffffffc0201538:	0017f713          	andi	a4,a5,1
ffffffffc020153c:	e711                	bnez	a4,ffffffffc0201548 <page_remove+0x26>
}
ffffffffc020153e:	60e2                	ld	ra,24(sp)
ffffffffc0201540:	6442                	ld	s0,16(sp)
ffffffffc0201542:	64a2                	ld	s1,8(sp)
ffffffffc0201544:	6105                	addi	sp,sp,32
ffffffffc0201546:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201548:	000ab717          	auipc	a4,0xab
ffffffffc020154c:	eb870713          	addi	a4,a4,-328 # ffffffffc02ac400 <npage>
ffffffffc0201550:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201552:	078a                	slli	a5,a5,0x2
ffffffffc0201554:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201556:	02e7fe63          	bleu	a4,a5,ffffffffc0201592 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020155a:	000ab717          	auipc	a4,0xab
ffffffffc020155e:	f0e70713          	addi	a4,a4,-242 # ffffffffc02ac468 <pages>
ffffffffc0201562:	6308                	ld	a0,0(a4)
ffffffffc0201564:	fff80737          	lui	a4,0xfff80
ffffffffc0201568:	97ba                	add	a5,a5,a4
ffffffffc020156a:	079a                	slli	a5,a5,0x6
ffffffffc020156c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020156e:	411c                	lw	a5,0(a0)
ffffffffc0201570:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201574:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201576:	cb11                	beqz	a4,ffffffffc020158a <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201578:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020157c:	12048073          	sfence.vma	s1
}
ffffffffc0201580:	60e2                	ld	ra,24(sp)
ffffffffc0201582:	6442                	ld	s0,16(sp)
ffffffffc0201584:	64a2                	ld	s1,8(sp)
ffffffffc0201586:	6105                	addi	sp,sp,32
ffffffffc0201588:	8082                	ret
            free_page(page);
ffffffffc020158a:	4585                	li	a1,1
ffffffffc020158c:	96fff0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0201590:	b7e5                	j	ffffffffc0201578 <page_remove+0x56>
ffffffffc0201592:	8c5ff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc0201596 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201596:	7179                	addi	sp,sp,-48
ffffffffc0201598:	e44e                	sd	s3,8(sp)
ffffffffc020159a:	89b2                	mv	s3,a2
ffffffffc020159c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020159e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015a0:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015a2:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015a4:	ec26                	sd	s1,24(sp)
ffffffffc02015a6:	f406                	sd	ra,40(sp)
ffffffffc02015a8:	e84a                	sd	s2,16(sp)
ffffffffc02015aa:	e052                	sd	s4,0(sp)
ffffffffc02015ac:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015ae:	9d3ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    if (ptep == NULL) {
ffffffffc02015b2:	cd49                	beqz	a0,ffffffffc020164c <page_insert+0xb6>
    page->ref += 1;
ffffffffc02015b4:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02015b6:	611c                	ld	a5,0(a0)
ffffffffc02015b8:	892a                	mv	s2,a0
ffffffffc02015ba:	0016871b          	addiw	a4,a3,1
ffffffffc02015be:	c018                	sw	a4,0(s0)
ffffffffc02015c0:	0017f713          	andi	a4,a5,1
ffffffffc02015c4:	ef05                	bnez	a4,ffffffffc02015fc <page_insert+0x66>
ffffffffc02015c6:	000ab797          	auipc	a5,0xab
ffffffffc02015ca:	ea278793          	addi	a5,a5,-350 # ffffffffc02ac468 <pages>
ffffffffc02015ce:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02015d0:	8c19                	sub	s0,s0,a4
ffffffffc02015d2:	000806b7          	lui	a3,0x80
ffffffffc02015d6:	8419                	srai	s0,s0,0x6
ffffffffc02015d8:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02015da:	042a                	slli	s0,s0,0xa
ffffffffc02015dc:	8c45                	or	s0,s0,s1
ffffffffc02015de:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02015e2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015e6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02015ea:	4501                	li	a0,0
}
ffffffffc02015ec:	70a2                	ld	ra,40(sp)
ffffffffc02015ee:	7402                	ld	s0,32(sp)
ffffffffc02015f0:	64e2                	ld	s1,24(sp)
ffffffffc02015f2:	6942                	ld	s2,16(sp)
ffffffffc02015f4:	69a2                	ld	s3,8(sp)
ffffffffc02015f6:	6a02                	ld	s4,0(sp)
ffffffffc02015f8:	6145                	addi	sp,sp,48
ffffffffc02015fa:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02015fc:	000ab717          	auipc	a4,0xab
ffffffffc0201600:	e0470713          	addi	a4,a4,-508 # ffffffffc02ac400 <npage>
ffffffffc0201604:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201606:	078a                	slli	a5,a5,0x2
ffffffffc0201608:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020160a:	04e7f363          	bleu	a4,a5,ffffffffc0201650 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc020160e:	000aba17          	auipc	s4,0xab
ffffffffc0201612:	e5aa0a13          	addi	s4,s4,-422 # ffffffffc02ac468 <pages>
ffffffffc0201616:	000a3703          	ld	a4,0(s4)
ffffffffc020161a:	fff80537          	lui	a0,0xfff80
ffffffffc020161e:	953e                	add	a0,a0,a5
ffffffffc0201620:	051a                	slli	a0,a0,0x6
ffffffffc0201622:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201624:	00a40a63          	beq	s0,a0,ffffffffc0201638 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201628:	411c                	lw	a5,0(a0)
ffffffffc020162a:	fff7869b          	addiw	a3,a5,-1
ffffffffc020162e:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0201630:	c691                	beqz	a3,ffffffffc020163c <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201632:	12098073          	sfence.vma	s3
ffffffffc0201636:	bf69                	j	ffffffffc02015d0 <page_insert+0x3a>
ffffffffc0201638:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020163a:	bf59                	j	ffffffffc02015d0 <page_insert+0x3a>
            free_page(page);
ffffffffc020163c:	4585                	li	a1,1
ffffffffc020163e:	8bdff0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0201642:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201646:	12098073          	sfence.vma	s3
ffffffffc020164a:	b759                	j	ffffffffc02015d0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020164c:	5571                	li	a0,-4
ffffffffc020164e:	bf79                	j	ffffffffc02015ec <page_insert+0x56>
ffffffffc0201650:	807ff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc0201654 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201654:	00007797          	auipc	a5,0x7
ffffffffc0201658:	d1478793          	addi	a5,a5,-748 # ffffffffc0208368 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020165c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020165e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201660:	00006517          	auipc	a0,0x6
ffffffffc0201664:	a3050513          	addi	a0,a0,-1488 # ffffffffc0207090 <commands+0x8e8>
void pmm_init(void) {
ffffffffc0201668:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020166a:	000ab717          	auipc	a4,0xab
ffffffffc020166e:	def73323          	sd	a5,-538(a4) # ffffffffc02ac450 <pmm_manager>
void pmm_init(void) {
ffffffffc0201672:	e0a2                	sd	s0,64(sp)
ffffffffc0201674:	fc26                	sd	s1,56(sp)
ffffffffc0201676:	f84a                	sd	s2,48(sp)
ffffffffc0201678:	f44e                	sd	s3,40(sp)
ffffffffc020167a:	f052                	sd	s4,32(sp)
ffffffffc020167c:	ec56                	sd	s5,24(sp)
ffffffffc020167e:	e85a                	sd	s6,16(sp)
ffffffffc0201680:	e45e                	sd	s7,8(sp)
ffffffffc0201682:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201684:	000ab417          	auipc	s0,0xab
ffffffffc0201688:	dcc40413          	addi	s0,s0,-564 # ffffffffc02ac450 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020168c:	a45fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc0201690:	601c                	ld	a5,0(s0)
ffffffffc0201692:	000ab497          	auipc	s1,0xab
ffffffffc0201696:	d6e48493          	addi	s1,s1,-658 # ffffffffc02ac400 <npage>
ffffffffc020169a:	000ab917          	auipc	s2,0xab
ffffffffc020169e:	dce90913          	addi	s2,s2,-562 # ffffffffc02ac468 <pages>
ffffffffc02016a2:	679c                	ld	a5,8(a5)
ffffffffc02016a4:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02016a6:	57f5                	li	a5,-3
ffffffffc02016a8:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02016aa:	00006517          	auipc	a0,0x6
ffffffffc02016ae:	9fe50513          	addi	a0,a0,-1538 # ffffffffc02070a8 <commands+0x900>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02016b2:	000ab717          	auipc	a4,0xab
ffffffffc02016b6:	daf73323          	sd	a5,-602(a4) # ffffffffc02ac458 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02016ba:	a17fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02016be:	46c5                	li	a3,17
ffffffffc02016c0:	06ee                	slli	a3,a3,0x1b
ffffffffc02016c2:	40100613          	li	a2,1025
ffffffffc02016c6:	16fd                	addi	a3,a3,-1
ffffffffc02016c8:	0656                	slli	a2,a2,0x15
ffffffffc02016ca:	07e005b7          	lui	a1,0x7e00
ffffffffc02016ce:	00006517          	auipc	a0,0x6
ffffffffc02016d2:	9f250513          	addi	a0,a0,-1550 # ffffffffc02070c0 <commands+0x918>
ffffffffc02016d6:	9fbfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016da:	777d                	lui	a4,0xfffff
ffffffffc02016dc:	000ac797          	auipc	a5,0xac
ffffffffc02016e0:	e9b78793          	addi	a5,a5,-357 # ffffffffc02ad577 <end+0xfff>
ffffffffc02016e4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02016e6:	00088737          	lui	a4,0x88
ffffffffc02016ea:	000ab697          	auipc	a3,0xab
ffffffffc02016ee:	d0e6bb23          	sd	a4,-746(a3) # ffffffffc02ac400 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016f2:	000ab717          	auipc	a4,0xab
ffffffffc02016f6:	d6f73b23          	sd	a5,-650(a4) # ffffffffc02ac468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016fa:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016fc:	4685                	li	a3,1
ffffffffc02016fe:	fff80837          	lui	a6,0xfff80
ffffffffc0201702:	a019                	j	ffffffffc0201708 <pmm_init+0xb4>
ffffffffc0201704:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201708:	00671613          	slli	a2,a4,0x6
ffffffffc020170c:	97b2                	add	a5,a5,a2
ffffffffc020170e:	07a1                	addi	a5,a5,8
ffffffffc0201710:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201714:	6090                	ld	a2,0(s1)
ffffffffc0201716:	0705                	addi	a4,a4,1
ffffffffc0201718:	010607b3          	add	a5,a2,a6
ffffffffc020171c:	fef764e3          	bltu	a4,a5,ffffffffc0201704 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201720:	00093503          	ld	a0,0(s2)
ffffffffc0201724:	fe0007b7          	lui	a5,0xfe000
ffffffffc0201728:	00661693          	slli	a3,a2,0x6
ffffffffc020172c:	97aa                	add	a5,a5,a0
ffffffffc020172e:	96be                	add	a3,a3,a5
ffffffffc0201730:	c02007b7          	lui	a5,0xc0200
ffffffffc0201734:	7af6ed63          	bltu	a3,a5,ffffffffc0201eee <pmm_init+0x89a>
ffffffffc0201738:	000ab997          	auipc	s3,0xab
ffffffffc020173c:	d2098993          	addi	s3,s3,-736 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0201740:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201744:	47c5                	li	a5,17
ffffffffc0201746:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201748:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020174a:	02f6f763          	bleu	a5,a3,ffffffffc0201778 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020174e:	6585                	lui	a1,0x1
ffffffffc0201750:	15fd                	addi	a1,a1,-1
ffffffffc0201752:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0201754:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201758:	48c77a63          	bleu	a2,a4,ffffffffc0201bec <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020175c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020175e:	75fd                	lui	a1,0xfffff
ffffffffc0201760:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0201762:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0201764:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201766:	40d786b3          	sub	a3,a5,a3
ffffffffc020176a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020176c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0201770:	953a                	add	a0,a0,a4
ffffffffc0201772:	9602                	jalr	a2
ffffffffc0201774:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201778:	00006517          	auipc	a0,0x6
ffffffffc020177c:	99850513          	addi	a0,a0,-1640 # ffffffffc0207110 <commands+0x968>
ffffffffc0201780:	951fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201784:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201786:	000ab417          	auipc	s0,0xab
ffffffffc020178a:	c7240413          	addi	s0,s0,-910 # ffffffffc02ac3f8 <boot_pgdir>
    pmm_manager->check();
ffffffffc020178e:	7b9c                	ld	a5,48(a5)
ffffffffc0201790:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201792:	00006517          	auipc	a0,0x6
ffffffffc0201796:	99650513          	addi	a0,a0,-1642 # ffffffffc0207128 <commands+0x980>
ffffffffc020179a:	937fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020179e:	0000a697          	auipc	a3,0xa
ffffffffc02017a2:	86268693          	addi	a3,a3,-1950 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02017a6:	000ab797          	auipc	a5,0xab
ffffffffc02017aa:	c4d7b923          	sd	a3,-942(a5) # ffffffffc02ac3f8 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02017ae:	c02007b7          	lui	a5,0xc0200
ffffffffc02017b2:	10f6eae3          	bltu	a3,a5,ffffffffc02020c6 <pmm_init+0xa72>
ffffffffc02017b6:	0009b783          	ld	a5,0(s3)
ffffffffc02017ba:	8e9d                	sub	a3,a3,a5
ffffffffc02017bc:	000ab797          	auipc	a5,0xab
ffffffffc02017c0:	cad7b223          	sd	a3,-860(a5) # ffffffffc02ac460 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02017c4:	f7cff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017c8:	6098                	ld	a4,0(s1)
ffffffffc02017ca:	c80007b7          	lui	a5,0xc8000
ffffffffc02017ce:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02017d0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017d2:	0ce7eae3          	bltu	a5,a4,ffffffffc02020a6 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02017d6:	6008                	ld	a0,0(s0)
ffffffffc02017d8:	44050463          	beqz	a0,ffffffffc0201c20 <pmm_init+0x5cc>
ffffffffc02017dc:	6785                	lui	a5,0x1
ffffffffc02017de:	17fd                	addi	a5,a5,-1
ffffffffc02017e0:	8fe9                	and	a5,a5,a0
ffffffffc02017e2:	2781                	sext.w	a5,a5
ffffffffc02017e4:	42079e63          	bnez	a5,ffffffffc0201c20 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02017e8:	4601                	li	a2,0
ffffffffc02017ea:	4581                	li	a1,0
ffffffffc02017ec:	967ff0ef          	jal	ra,ffffffffc0201152 <get_page>
ffffffffc02017f0:	78051b63          	bnez	a0,ffffffffc0201f86 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02017f4:	4505                	li	a0,1
ffffffffc02017f6:	e7cff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02017fa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02017fc:	6008                	ld	a0,0(s0)
ffffffffc02017fe:	4681                	li	a3,0
ffffffffc0201800:	4601                	li	a2,0
ffffffffc0201802:	85d6                	mv	a1,s5
ffffffffc0201804:	d93ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201808:	7a051f63          	bnez	a0,ffffffffc0201fc6 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020180c:	6008                	ld	a0,0(s0)
ffffffffc020180e:	4601                	li	a2,0
ffffffffc0201810:	4581                	li	a1,0
ffffffffc0201812:	f6eff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0201816:	78050863          	beqz	a0,ffffffffc0201fa6 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc020181a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020181c:	0017f713          	andi	a4,a5,1
ffffffffc0201820:	3e070463          	beqz	a4,ffffffffc0201c08 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0201824:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201826:	078a                	slli	a5,a5,0x2
ffffffffc0201828:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020182a:	3ce7f163          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020182e:	00093683          	ld	a3,0(s2)
ffffffffc0201832:	fff80637          	lui	a2,0xfff80
ffffffffc0201836:	97b2                	add	a5,a5,a2
ffffffffc0201838:	079a                	slli	a5,a5,0x6
ffffffffc020183a:	97b6                	add	a5,a5,a3
ffffffffc020183c:	72fa9563          	bne	s5,a5,ffffffffc0201f66 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0201840:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0201844:	4785                	li	a5,1
ffffffffc0201846:	70fb9063          	bne	s7,a5,ffffffffc0201f46 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020184a:	6008                	ld	a0,0(s0)
ffffffffc020184c:	76fd                	lui	a3,0xfffff
ffffffffc020184e:	611c                	ld	a5,0(a0)
ffffffffc0201850:	078a                	slli	a5,a5,0x2
ffffffffc0201852:	8ff5                	and	a5,a5,a3
ffffffffc0201854:	00c7d613          	srli	a2,a5,0xc
ffffffffc0201858:	66e67e63          	bleu	a4,a2,ffffffffc0201ed4 <pmm_init+0x880>
ffffffffc020185c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201860:	97e2                	add	a5,a5,s8
ffffffffc0201862:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0201866:	0b0a                	slli	s6,s6,0x2
ffffffffc0201868:	00db7b33          	and	s6,s6,a3
ffffffffc020186c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201870:	56e7f863          	bleu	a4,a5,ffffffffc0201de0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201874:	4601                	li	a2,0
ffffffffc0201876:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201878:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020187a:	f06ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020187e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201880:	55651063          	bne	a0,s6,ffffffffc0201dc0 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0201884:	4505                	li	a0,1
ffffffffc0201886:	decff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020188a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020188c:	6008                	ld	a0,0(s0)
ffffffffc020188e:	46d1                	li	a3,20
ffffffffc0201890:	6605                	lui	a2,0x1
ffffffffc0201892:	85da                	mv	a1,s6
ffffffffc0201894:	d03ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201898:	50051463          	bnez	a0,ffffffffc0201da0 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020189c:	6008                	ld	a0,0(s0)
ffffffffc020189e:	4601                	li	a2,0
ffffffffc02018a0:	6585                	lui	a1,0x1
ffffffffc02018a2:	edeff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc02018a6:	4c050d63          	beqz	a0,ffffffffc0201d80 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc02018aa:	611c                	ld	a5,0(a0)
ffffffffc02018ac:	0107f713          	andi	a4,a5,16
ffffffffc02018b0:	4a070863          	beqz	a4,ffffffffc0201d60 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc02018b4:	8b91                	andi	a5,a5,4
ffffffffc02018b6:	48078563          	beqz	a5,ffffffffc0201d40 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02018ba:	6008                	ld	a0,0(s0)
ffffffffc02018bc:	611c                	ld	a5,0(a0)
ffffffffc02018be:	8bc1                	andi	a5,a5,16
ffffffffc02018c0:	46078063          	beqz	a5,ffffffffc0201d20 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02018c4:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5588>
ffffffffc02018c8:	43779c63          	bne	a5,s7,ffffffffc0201d00 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02018cc:	4681                	li	a3,0
ffffffffc02018ce:	6605                	lui	a2,0x1
ffffffffc02018d0:	85d6                	mv	a1,s5
ffffffffc02018d2:	cc5ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc02018d6:	40051563          	bnez	a0,ffffffffc0201ce0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02018da:	000aa703          	lw	a4,0(s5)
ffffffffc02018de:	4789                	li	a5,2
ffffffffc02018e0:	3ef71063          	bne	a4,a5,ffffffffc0201cc0 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02018e4:	000b2783          	lw	a5,0(s6)
ffffffffc02018e8:	3a079c63          	bnez	a5,ffffffffc0201ca0 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02018ec:	6008                	ld	a0,0(s0)
ffffffffc02018ee:	4601                	li	a2,0
ffffffffc02018f0:	6585                	lui	a1,0x1
ffffffffc02018f2:	e8eff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc02018f6:	38050563          	beqz	a0,ffffffffc0201c80 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02018fa:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02018fc:	00177793          	andi	a5,a4,1
ffffffffc0201900:	30078463          	beqz	a5,ffffffffc0201c08 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0201904:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201906:	00271793          	slli	a5,a4,0x2
ffffffffc020190a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020190c:	2ed7f063          	bleu	a3,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201910:	00093683          	ld	a3,0(s2)
ffffffffc0201914:	fff80637          	lui	a2,0xfff80
ffffffffc0201918:	97b2                	add	a5,a5,a2
ffffffffc020191a:	079a                	slli	a5,a5,0x6
ffffffffc020191c:	97b6                	add	a5,a5,a3
ffffffffc020191e:	32fa9163          	bne	s5,a5,ffffffffc0201c40 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201922:	8b41                	andi	a4,a4,16
ffffffffc0201924:	70071163          	bnez	a4,ffffffffc0202026 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201928:	6008                	ld	a0,0(s0)
ffffffffc020192a:	4581                	li	a1,0
ffffffffc020192c:	bf7ff0ef          	jal	ra,ffffffffc0201522 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201930:	000aa703          	lw	a4,0(s5)
ffffffffc0201934:	4785                	li	a5,1
ffffffffc0201936:	6cf71863          	bne	a4,a5,ffffffffc0202006 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020193a:	000b2783          	lw	a5,0(s6)
ffffffffc020193e:	6a079463          	bnez	a5,ffffffffc0201fe6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201942:	6008                	ld	a0,0(s0)
ffffffffc0201944:	6585                	lui	a1,0x1
ffffffffc0201946:	bddff0ef          	jal	ra,ffffffffc0201522 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020194a:	000aa783          	lw	a5,0(s5)
ffffffffc020194e:	50079363          	bnez	a5,ffffffffc0201e54 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0201952:	000b2783          	lw	a5,0(s6)
ffffffffc0201956:	4c079f63          	bnez	a5,ffffffffc0201e34 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020195a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020195e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201960:	000ab783          	ld	a5,0(s5)
ffffffffc0201964:	078a                	slli	a5,a5,0x2
ffffffffc0201966:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201968:	28c7f263          	bleu	a2,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020196c:	fff80737          	lui	a4,0xfff80
ffffffffc0201970:	00093503          	ld	a0,0(s2)
ffffffffc0201974:	97ba                	add	a5,a5,a4
ffffffffc0201976:	079a                	slli	a5,a5,0x6
ffffffffc0201978:	00f50733          	add	a4,a0,a5
ffffffffc020197c:	4314                	lw	a3,0(a4)
ffffffffc020197e:	4705                	li	a4,1
ffffffffc0201980:	48e69a63          	bne	a3,a4,ffffffffc0201e14 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0201984:	8799                	srai	a5,a5,0x6
ffffffffc0201986:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020198a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020198c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020198e:	8331                	srli	a4,a4,0xc
ffffffffc0201990:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201992:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201994:	46c77363          	bleu	a2,a4,ffffffffc0201dfa <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201998:	0009b683          	ld	a3,0(s3)
ffffffffc020199c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020199e:	639c                	ld	a5,0(a5)
ffffffffc02019a0:	078a                	slli	a5,a5,0x2
ffffffffc02019a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019a4:	24c7f463          	bleu	a2,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02019a8:	416787b3          	sub	a5,a5,s6
ffffffffc02019ac:	079a                	slli	a5,a5,0x6
ffffffffc02019ae:	953e                	add	a0,a0,a5
ffffffffc02019b0:	4585                	li	a1,1
ffffffffc02019b2:	d48ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02019b6:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02019ba:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02019bc:	078a                	slli	a5,a5,0x2
ffffffffc02019be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019c0:	22e7f663          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02019c4:	00093503          	ld	a0,0(s2)
ffffffffc02019c8:	416787b3          	sub	a5,a5,s6
ffffffffc02019cc:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02019ce:	953e                	add	a0,a0,a5
ffffffffc02019d0:	4585                	li	a1,1
ffffffffc02019d2:	d28ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02019d6:	601c                	ld	a5,0(s0)
ffffffffc02019d8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02019dc:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02019e0:	d60ff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc02019e4:	68aa1163          	bne	s4,a0,ffffffffc0202066 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02019e8:	00006517          	auipc	a0,0x6
ffffffffc02019ec:	a5050513          	addi	a0,a0,-1456 # ffffffffc0207438 <commands+0xc90>
ffffffffc02019f0:	ee0fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02019f4:	d4cff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019f8:	6098                	ld	a4,0(s1)
ffffffffc02019fa:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02019fe:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a00:	00c71693          	slli	a3,a4,0xc
ffffffffc0201a04:	18d7f563          	bleu	a3,a5,ffffffffc0201b8e <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a08:	83b1                	srli	a5,a5,0xc
ffffffffc0201a0a:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a0c:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a10:	1ae7f163          	bleu	a4,a5,ffffffffc0201bb2 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a14:	7bfd                	lui	s7,0xfffff
ffffffffc0201a16:	6b05                	lui	s6,0x1
ffffffffc0201a18:	a029                	j	ffffffffc0201a22 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a1a:	00cad713          	srli	a4,s5,0xc
ffffffffc0201a1e:	18f77a63          	bleu	a5,a4,ffffffffc0201bb2 <pmm_init+0x55e>
ffffffffc0201a22:	0009b583          	ld	a1,0(s3)
ffffffffc0201a26:	4601                	li	a2,0
ffffffffc0201a28:	95d6                	add	a1,a1,s5
ffffffffc0201a2a:	d56ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0201a2e:	16050263          	beqz	a0,ffffffffc0201b92 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a32:	611c                	ld	a5,0(a0)
ffffffffc0201a34:	078a                	slli	a5,a5,0x2
ffffffffc0201a36:	0177f7b3          	and	a5,a5,s7
ffffffffc0201a3a:	19579963          	bne	a5,s5,ffffffffc0201bcc <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a3e:	609c                	ld	a5,0(s1)
ffffffffc0201a40:	9ada                	add	s5,s5,s6
ffffffffc0201a42:	6008                	ld	a0,0(s0)
ffffffffc0201a44:	00c79713          	slli	a4,a5,0xc
ffffffffc0201a48:	fceae9e3          	bltu	s5,a4,ffffffffc0201a1a <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201a4c:	611c                	ld	a5,0(a0)
ffffffffc0201a4e:	62079c63          	bnez	a5,ffffffffc0202086 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0201a52:	4505                	li	a0,1
ffffffffc0201a54:	c1eff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0201a58:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a5a:	6008                	ld	a0,0(s0)
ffffffffc0201a5c:	4699                	li	a3,6
ffffffffc0201a5e:	10000613          	li	a2,256
ffffffffc0201a62:	85d6                	mv	a1,s5
ffffffffc0201a64:	b33ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201a68:	1e051c63          	bnez	a0,ffffffffc0201c60 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0201a6c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201a70:	4785                	li	a5,1
ffffffffc0201a72:	44f71163          	bne	a4,a5,ffffffffc0201eb4 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a76:	6008                	ld	a0,0(s0)
ffffffffc0201a78:	6b05                	lui	s6,0x1
ffffffffc0201a7a:	4699                	li	a3,6
ffffffffc0201a7c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8470>
ffffffffc0201a80:	85d6                	mv	a1,s5
ffffffffc0201a82:	b15ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201a86:	40051763          	bnez	a0,ffffffffc0201e94 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0201a8a:	000aa703          	lw	a4,0(s5)
ffffffffc0201a8e:	4789                	li	a5,2
ffffffffc0201a90:	3ef71263          	bne	a4,a5,ffffffffc0201e74 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201a94:	00006597          	auipc	a1,0x6
ffffffffc0201a98:	adc58593          	addi	a1,a1,-1316 # ffffffffc0207570 <commands+0xdc8>
ffffffffc0201a9c:	10000513          	li	a0,256
ffffffffc0201aa0:	6fe040ef          	jal	ra,ffffffffc020619e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201aa4:	100b0593          	addi	a1,s6,256
ffffffffc0201aa8:	10000513          	li	a0,256
ffffffffc0201aac:	704040ef          	jal	ra,ffffffffc02061b0 <strcmp>
ffffffffc0201ab0:	44051b63          	bnez	a0,ffffffffc0201f06 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0201ab4:	00093683          	ld	a3,0(s2)
ffffffffc0201ab8:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201abc:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201abe:	40da86b3          	sub	a3,s5,a3
ffffffffc0201ac2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201ac4:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201ac6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201ac8:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201acc:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ad0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ad2:	10f77f63          	bleu	a5,a4,ffffffffc0201bf0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ad6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ada:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ade:	96be                	add	a3,a3,a5
ffffffffc0201ae0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52b88>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ae4:	676040ef          	jal	ra,ffffffffc020615a <strlen>
ffffffffc0201ae8:	54051f63          	bnez	a0,ffffffffc0202046 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201aec:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201af0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201af2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52a88>
ffffffffc0201af6:	068a                	slli	a3,a3,0x2
ffffffffc0201af8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201afa:	0ef6f963          	bleu	a5,a3,ffffffffc0201bec <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0201afe:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b02:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b04:	0efb7663          	bleu	a5,s6,ffffffffc0201bf0 <pmm_init+0x59c>
ffffffffc0201b08:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201b0c:	4585                	li	a1,1
ffffffffc0201b0e:	8556                	mv	a0,s5
ffffffffc0201b10:	99b6                	add	s3,s3,a3
ffffffffc0201b12:	be8ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b16:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201b1a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b1c:	078a                	slli	a5,a5,0x2
ffffffffc0201b1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b20:	0ce7f663          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b24:	00093503          	ld	a0,0(s2)
ffffffffc0201b28:	fff809b7          	lui	s3,0xfff80
ffffffffc0201b2c:	97ce                	add	a5,a5,s3
ffffffffc0201b2e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201b30:	953e                	add	a0,a0,a5
ffffffffc0201b32:	4585                	li	a1,1
ffffffffc0201b34:	bc6ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b38:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201b3c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b3e:	078a                	slli	a5,a5,0x2
ffffffffc0201b40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b42:	0ae7f563          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b46:	00093503          	ld	a0,0(s2)
ffffffffc0201b4a:	97ce                	add	a5,a5,s3
ffffffffc0201b4c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201b4e:	953e                	add	a0,a0,a5
ffffffffc0201b50:	4585                	li	a1,1
ffffffffc0201b52:	ba8ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201b56:	601c                	ld	a5,0(s0)
ffffffffc0201b58:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201b5c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201b60:	be0ff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0201b64:	3caa1163          	bne	s4,a0,ffffffffc0201f26 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201b68:	00006517          	auipc	a0,0x6
ffffffffc0201b6c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02075e8 <commands+0xe40>
ffffffffc0201b70:	d60fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201b74:	6406                	ld	s0,64(sp)
ffffffffc0201b76:	60a6                	ld	ra,72(sp)
ffffffffc0201b78:	74e2                	ld	s1,56(sp)
ffffffffc0201b7a:	7942                	ld	s2,48(sp)
ffffffffc0201b7c:	79a2                	ld	s3,40(sp)
ffffffffc0201b7e:	7a02                	ld	s4,32(sp)
ffffffffc0201b80:	6ae2                	ld	s5,24(sp)
ffffffffc0201b82:	6b42                	ld	s6,16(sp)
ffffffffc0201b84:	6ba2                	ld	s7,8(sp)
ffffffffc0201b86:	6c02                	ld	s8,0(sp)
ffffffffc0201b88:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201b8a:	6810106f          	j	ffffffffc0203a0a <kmalloc_init>
ffffffffc0201b8e:	6008                	ld	a0,0(s0)
ffffffffc0201b90:	bd75                	j	ffffffffc0201a4c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b92:	00006697          	auipc	a3,0x6
ffffffffc0201b96:	8c668693          	addi	a3,a3,-1850 # ffffffffc0207458 <commands+0xcb0>
ffffffffc0201b9a:	00005617          	auipc	a2,0x5
ffffffffc0201b9e:	08e60613          	addi	a2,a2,142 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201ba2:	22600593          	li	a1,550
ffffffffc0201ba6:	00005517          	auipc	a0,0x5
ffffffffc0201baa:	49250513          	addi	a0,a0,1170 # ffffffffc0207038 <commands+0x890>
ffffffffc0201bae:	e68fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201bb2:	86d6                	mv	a3,s5
ffffffffc0201bb4:	00005617          	auipc	a2,0x5
ffffffffc0201bb8:	45c60613          	addi	a2,a2,1116 # ffffffffc0207010 <commands+0x868>
ffffffffc0201bbc:	22600593          	li	a1,550
ffffffffc0201bc0:	00005517          	auipc	a0,0x5
ffffffffc0201bc4:	47850513          	addi	a0,a0,1144 # ffffffffc0207038 <commands+0x890>
ffffffffc0201bc8:	e4efe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201bcc:	00006697          	auipc	a3,0x6
ffffffffc0201bd0:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0207498 <commands+0xcf0>
ffffffffc0201bd4:	00005617          	auipc	a2,0x5
ffffffffc0201bd8:	05460613          	addi	a2,a2,84 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201bdc:	22700593          	li	a1,551
ffffffffc0201be0:	00005517          	auipc	a0,0x5
ffffffffc0201be4:	45850513          	addi	a0,a0,1112 # ffffffffc0207038 <commands+0x890>
ffffffffc0201be8:	e2efe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201bec:	a6aff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201bf0:	00005617          	auipc	a2,0x5
ffffffffc0201bf4:	42060613          	addi	a2,a2,1056 # ffffffffc0207010 <commands+0x868>
ffffffffc0201bf8:	06900593          	li	a1,105
ffffffffc0201bfc:	00005517          	auipc	a0,0x5
ffffffffc0201c00:	46c50513          	addi	a0,a0,1132 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0201c04:	e12fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201c08:	00005617          	auipc	a2,0x5
ffffffffc0201c0c:	62060613          	addi	a2,a2,1568 # ffffffffc0207228 <commands+0xa80>
ffffffffc0201c10:	07400593          	li	a1,116
ffffffffc0201c14:	00005517          	auipc	a0,0x5
ffffffffc0201c18:	45450513          	addi	a0,a0,1108 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0201c1c:	dfafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c20:	00005697          	auipc	a3,0x5
ffffffffc0201c24:	54868693          	addi	a3,a3,1352 # ffffffffc0207168 <commands+0x9c0>
ffffffffc0201c28:	00005617          	auipc	a2,0x5
ffffffffc0201c2c:	00060613          	mv	a2,a2
ffffffffc0201c30:	1ea00593          	li	a1,490
ffffffffc0201c34:	00005517          	auipc	a0,0x5
ffffffffc0201c38:	40450513          	addi	a0,a0,1028 # ffffffffc0207038 <commands+0x890>
ffffffffc0201c3c:	ddafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c40:	00005697          	auipc	a3,0x5
ffffffffc0201c44:	61068693          	addi	a3,a3,1552 # ffffffffc0207250 <commands+0xaa8>
ffffffffc0201c48:	00005617          	auipc	a2,0x5
ffffffffc0201c4c:	fe060613          	addi	a2,a2,-32 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201c50:	20600593          	li	a1,518
ffffffffc0201c54:	00005517          	auipc	a0,0x5
ffffffffc0201c58:	3e450513          	addi	a0,a0,996 # ffffffffc0207038 <commands+0x890>
ffffffffc0201c5c:	dbafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201c60:	00006697          	auipc	a3,0x6
ffffffffc0201c64:	86868693          	addi	a3,a3,-1944 # ffffffffc02074c8 <commands+0xd20>
ffffffffc0201c68:	00005617          	auipc	a2,0x5
ffffffffc0201c6c:	fc060613          	addi	a2,a2,-64 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201c70:	22f00593          	li	a1,559
ffffffffc0201c74:	00005517          	auipc	a0,0x5
ffffffffc0201c78:	3c450513          	addi	a0,a0,964 # ffffffffc0207038 <commands+0x890>
ffffffffc0201c7c:	d9afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201c80:	00005697          	auipc	a3,0x5
ffffffffc0201c84:	66068693          	addi	a3,a3,1632 # ffffffffc02072e0 <commands+0xb38>
ffffffffc0201c88:	00005617          	auipc	a2,0x5
ffffffffc0201c8c:	fa060613          	addi	a2,a2,-96 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201c90:	20500593          	li	a1,517
ffffffffc0201c94:	00005517          	auipc	a0,0x5
ffffffffc0201c98:	3a450513          	addi	a0,a0,932 # ffffffffc0207038 <commands+0x890>
ffffffffc0201c9c:	d7afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201ca0:	00005697          	auipc	a3,0x5
ffffffffc0201ca4:	70868693          	addi	a3,a3,1800 # ffffffffc02073a8 <commands+0xc00>
ffffffffc0201ca8:	00005617          	auipc	a2,0x5
ffffffffc0201cac:	f8060613          	addi	a2,a2,-128 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201cb0:	20400593          	li	a1,516
ffffffffc0201cb4:	00005517          	auipc	a0,0x5
ffffffffc0201cb8:	38450513          	addi	a0,a0,900 # ffffffffc0207038 <commands+0x890>
ffffffffc0201cbc:	d5afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201cc0:	00005697          	auipc	a3,0x5
ffffffffc0201cc4:	6d068693          	addi	a3,a3,1744 # ffffffffc0207390 <commands+0xbe8>
ffffffffc0201cc8:	00005617          	auipc	a2,0x5
ffffffffc0201ccc:	f6060613          	addi	a2,a2,-160 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201cd0:	20300593          	li	a1,515
ffffffffc0201cd4:	00005517          	auipc	a0,0x5
ffffffffc0201cd8:	36450513          	addi	a0,a0,868 # ffffffffc0207038 <commands+0x890>
ffffffffc0201cdc:	d3afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201ce0:	00005697          	auipc	a3,0x5
ffffffffc0201ce4:	68068693          	addi	a3,a3,1664 # ffffffffc0207360 <commands+0xbb8>
ffffffffc0201ce8:	00005617          	auipc	a2,0x5
ffffffffc0201cec:	f4060613          	addi	a2,a2,-192 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201cf0:	20200593          	li	a1,514
ffffffffc0201cf4:	00005517          	auipc	a0,0x5
ffffffffc0201cf8:	34450513          	addi	a0,a0,836 # ffffffffc0207038 <commands+0x890>
ffffffffc0201cfc:	d1afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201d00:	00005697          	auipc	a3,0x5
ffffffffc0201d04:	64868693          	addi	a3,a3,1608 # ffffffffc0207348 <commands+0xba0>
ffffffffc0201d08:	00005617          	auipc	a2,0x5
ffffffffc0201d0c:	f2060613          	addi	a2,a2,-224 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201d10:	20000593          	li	a1,512
ffffffffc0201d14:	00005517          	auipc	a0,0x5
ffffffffc0201d18:	32450513          	addi	a0,a0,804 # ffffffffc0207038 <commands+0x890>
ffffffffc0201d1c:	cfafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d20:	00005697          	auipc	a3,0x5
ffffffffc0201d24:	61068693          	addi	a3,a3,1552 # ffffffffc0207330 <commands+0xb88>
ffffffffc0201d28:	00005617          	auipc	a2,0x5
ffffffffc0201d2c:	f0060613          	addi	a2,a2,-256 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201d30:	1ff00593          	li	a1,511
ffffffffc0201d34:	00005517          	auipc	a0,0x5
ffffffffc0201d38:	30450513          	addi	a0,a0,772 # ffffffffc0207038 <commands+0x890>
ffffffffc0201d3c:	cdafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201d40:	00005697          	auipc	a3,0x5
ffffffffc0201d44:	5e068693          	addi	a3,a3,1504 # ffffffffc0207320 <commands+0xb78>
ffffffffc0201d48:	00005617          	auipc	a2,0x5
ffffffffc0201d4c:	ee060613          	addi	a2,a2,-288 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201d50:	1fe00593          	li	a1,510
ffffffffc0201d54:	00005517          	auipc	a0,0x5
ffffffffc0201d58:	2e450513          	addi	a0,a0,740 # ffffffffc0207038 <commands+0x890>
ffffffffc0201d5c:	cbafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d60:	00005697          	auipc	a3,0x5
ffffffffc0201d64:	5b068693          	addi	a3,a3,1456 # ffffffffc0207310 <commands+0xb68>
ffffffffc0201d68:	00005617          	auipc	a2,0x5
ffffffffc0201d6c:	ec060613          	addi	a2,a2,-320 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201d70:	1fd00593          	li	a1,509
ffffffffc0201d74:	00005517          	auipc	a0,0x5
ffffffffc0201d78:	2c450513          	addi	a0,a0,708 # ffffffffc0207038 <commands+0x890>
ffffffffc0201d7c:	c9afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d80:	00005697          	auipc	a3,0x5
ffffffffc0201d84:	56068693          	addi	a3,a3,1376 # ffffffffc02072e0 <commands+0xb38>
ffffffffc0201d88:	00005617          	auipc	a2,0x5
ffffffffc0201d8c:	ea060613          	addi	a2,a2,-352 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201d90:	1fc00593          	li	a1,508
ffffffffc0201d94:	00005517          	auipc	a0,0x5
ffffffffc0201d98:	2a450513          	addi	a0,a0,676 # ffffffffc0207038 <commands+0x890>
ffffffffc0201d9c:	c7afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201da0:	00005697          	auipc	a3,0x5
ffffffffc0201da4:	50868693          	addi	a3,a3,1288 # ffffffffc02072a8 <commands+0xb00>
ffffffffc0201da8:	00005617          	auipc	a2,0x5
ffffffffc0201dac:	e8060613          	addi	a2,a2,-384 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201db0:	1fb00593          	li	a1,507
ffffffffc0201db4:	00005517          	auipc	a0,0x5
ffffffffc0201db8:	28450513          	addi	a0,a0,644 # ffffffffc0207038 <commands+0x890>
ffffffffc0201dbc:	c5afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201dc0:	00005697          	auipc	a3,0x5
ffffffffc0201dc4:	4c068693          	addi	a3,a3,1216 # ffffffffc0207280 <commands+0xad8>
ffffffffc0201dc8:	00005617          	auipc	a2,0x5
ffffffffc0201dcc:	e6060613          	addi	a2,a2,-416 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201dd0:	1f800593          	li	a1,504
ffffffffc0201dd4:	00005517          	auipc	a0,0x5
ffffffffc0201dd8:	26450513          	addi	a0,a0,612 # ffffffffc0207038 <commands+0x890>
ffffffffc0201ddc:	c3afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201de0:	86da                	mv	a3,s6
ffffffffc0201de2:	00005617          	auipc	a2,0x5
ffffffffc0201de6:	22e60613          	addi	a2,a2,558 # ffffffffc0207010 <commands+0x868>
ffffffffc0201dea:	1f700593          	li	a1,503
ffffffffc0201dee:	00005517          	auipc	a0,0x5
ffffffffc0201df2:	24a50513          	addi	a0,a0,586 # ffffffffc0207038 <commands+0x890>
ffffffffc0201df6:	c20fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201dfa:	86be                	mv	a3,a5
ffffffffc0201dfc:	00005617          	auipc	a2,0x5
ffffffffc0201e00:	21460613          	addi	a2,a2,532 # ffffffffc0207010 <commands+0x868>
ffffffffc0201e04:	06900593          	li	a1,105
ffffffffc0201e08:	00005517          	auipc	a0,0x5
ffffffffc0201e0c:	26050513          	addi	a0,a0,608 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0201e10:	c06fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e14:	00005697          	auipc	a3,0x5
ffffffffc0201e18:	5dc68693          	addi	a3,a3,1500 # ffffffffc02073f0 <commands+0xc48>
ffffffffc0201e1c:	00005617          	auipc	a2,0x5
ffffffffc0201e20:	e0c60613          	addi	a2,a2,-500 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201e24:	21100593          	li	a1,529
ffffffffc0201e28:	00005517          	auipc	a0,0x5
ffffffffc0201e2c:	21050513          	addi	a0,a0,528 # ffffffffc0207038 <commands+0x890>
ffffffffc0201e30:	be6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201e34:	00005697          	auipc	a3,0x5
ffffffffc0201e38:	57468693          	addi	a3,a3,1396 # ffffffffc02073a8 <commands+0xc00>
ffffffffc0201e3c:	00005617          	auipc	a2,0x5
ffffffffc0201e40:	dec60613          	addi	a2,a2,-532 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201e44:	20f00593          	li	a1,527
ffffffffc0201e48:	00005517          	auipc	a0,0x5
ffffffffc0201e4c:	1f050513          	addi	a0,a0,496 # ffffffffc0207038 <commands+0x890>
ffffffffc0201e50:	bc6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201e54:	00005697          	auipc	a3,0x5
ffffffffc0201e58:	58468693          	addi	a3,a3,1412 # ffffffffc02073d8 <commands+0xc30>
ffffffffc0201e5c:	00005617          	auipc	a2,0x5
ffffffffc0201e60:	dcc60613          	addi	a2,a2,-564 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201e64:	20e00593          	li	a1,526
ffffffffc0201e68:	00005517          	auipc	a0,0x5
ffffffffc0201e6c:	1d050513          	addi	a0,a0,464 # ffffffffc0207038 <commands+0x890>
ffffffffc0201e70:	ba6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201e74:	00005697          	auipc	a3,0x5
ffffffffc0201e78:	6e468693          	addi	a3,a3,1764 # ffffffffc0207558 <commands+0xdb0>
ffffffffc0201e7c:	00005617          	auipc	a2,0x5
ffffffffc0201e80:	dac60613          	addi	a2,a2,-596 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201e84:	23200593          	li	a1,562
ffffffffc0201e88:	00005517          	auipc	a0,0x5
ffffffffc0201e8c:	1b050513          	addi	a0,a0,432 # ffffffffc0207038 <commands+0x890>
ffffffffc0201e90:	b86fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201e94:	00005697          	auipc	a3,0x5
ffffffffc0201e98:	68468693          	addi	a3,a3,1668 # ffffffffc0207518 <commands+0xd70>
ffffffffc0201e9c:	00005617          	auipc	a2,0x5
ffffffffc0201ea0:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201ea4:	23100593          	li	a1,561
ffffffffc0201ea8:	00005517          	auipc	a0,0x5
ffffffffc0201eac:	19050513          	addi	a0,a0,400 # ffffffffc0207038 <commands+0x890>
ffffffffc0201eb0:	b66fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201eb4:	00005697          	auipc	a3,0x5
ffffffffc0201eb8:	64c68693          	addi	a3,a3,1612 # ffffffffc0207500 <commands+0xd58>
ffffffffc0201ebc:	00005617          	auipc	a2,0x5
ffffffffc0201ec0:	d6c60613          	addi	a2,a2,-660 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201ec4:	23000593          	li	a1,560
ffffffffc0201ec8:	00005517          	auipc	a0,0x5
ffffffffc0201ecc:	17050513          	addi	a0,a0,368 # ffffffffc0207038 <commands+0x890>
ffffffffc0201ed0:	b46fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201ed4:	86be                	mv	a3,a5
ffffffffc0201ed6:	00005617          	auipc	a2,0x5
ffffffffc0201eda:	13a60613          	addi	a2,a2,314 # ffffffffc0207010 <commands+0x868>
ffffffffc0201ede:	1f600593          	li	a1,502
ffffffffc0201ee2:	00005517          	auipc	a0,0x5
ffffffffc0201ee6:	15650513          	addi	a0,a0,342 # ffffffffc0207038 <commands+0x890>
ffffffffc0201eea:	b2cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201eee:	00005617          	auipc	a2,0x5
ffffffffc0201ef2:	1fa60613          	addi	a2,a2,506 # ffffffffc02070e8 <commands+0x940>
ffffffffc0201ef6:	07f00593          	li	a1,127
ffffffffc0201efa:	00005517          	auipc	a0,0x5
ffffffffc0201efe:	13e50513          	addi	a0,a0,318 # ffffffffc0207038 <commands+0x890>
ffffffffc0201f02:	b14fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f06:	00005697          	auipc	a3,0x5
ffffffffc0201f0a:	68268693          	addi	a3,a3,1666 # ffffffffc0207588 <commands+0xde0>
ffffffffc0201f0e:	00005617          	auipc	a2,0x5
ffffffffc0201f12:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201f16:	23600593          	li	a1,566
ffffffffc0201f1a:	00005517          	auipc	a0,0x5
ffffffffc0201f1e:	11e50513          	addi	a0,a0,286 # ffffffffc0207038 <commands+0x890>
ffffffffc0201f22:	af4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201f26:	00005697          	auipc	a3,0x5
ffffffffc0201f2a:	4f268693          	addi	a3,a3,1266 # ffffffffc0207418 <commands+0xc70>
ffffffffc0201f2e:	00005617          	auipc	a2,0x5
ffffffffc0201f32:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201f36:	24200593          	li	a1,578
ffffffffc0201f3a:	00005517          	auipc	a0,0x5
ffffffffc0201f3e:	0fe50513          	addi	a0,a0,254 # ffffffffc0207038 <commands+0x890>
ffffffffc0201f42:	ad4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201f46:	00005697          	auipc	a3,0x5
ffffffffc0201f4a:	32268693          	addi	a3,a3,802 # ffffffffc0207268 <commands+0xac0>
ffffffffc0201f4e:	00005617          	auipc	a2,0x5
ffffffffc0201f52:	cda60613          	addi	a2,a2,-806 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201f56:	1f400593          	li	a1,500
ffffffffc0201f5a:	00005517          	auipc	a0,0x5
ffffffffc0201f5e:	0de50513          	addi	a0,a0,222 # ffffffffc0207038 <commands+0x890>
ffffffffc0201f62:	ab4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201f66:	00005697          	auipc	a3,0x5
ffffffffc0201f6a:	2ea68693          	addi	a3,a3,746 # ffffffffc0207250 <commands+0xaa8>
ffffffffc0201f6e:	00005617          	auipc	a2,0x5
ffffffffc0201f72:	cba60613          	addi	a2,a2,-838 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201f76:	1f300593          	li	a1,499
ffffffffc0201f7a:	00005517          	auipc	a0,0x5
ffffffffc0201f7e:	0be50513          	addi	a0,a0,190 # ffffffffc0207038 <commands+0x890>
ffffffffc0201f82:	a94fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201f86:	00005697          	auipc	a3,0x5
ffffffffc0201f8a:	21a68693          	addi	a3,a3,538 # ffffffffc02071a0 <commands+0x9f8>
ffffffffc0201f8e:	00005617          	auipc	a2,0x5
ffffffffc0201f92:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201f96:	1eb00593          	li	a1,491
ffffffffc0201f9a:	00005517          	auipc	a0,0x5
ffffffffc0201f9e:	09e50513          	addi	a0,a0,158 # ffffffffc0207038 <commands+0x890>
ffffffffc0201fa2:	a74fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201fa6:	00005697          	auipc	a3,0x5
ffffffffc0201faa:	25268693          	addi	a3,a3,594 # ffffffffc02071f8 <commands+0xa50>
ffffffffc0201fae:	00005617          	auipc	a2,0x5
ffffffffc0201fb2:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201fb6:	1f200593          	li	a1,498
ffffffffc0201fba:	00005517          	auipc	a0,0x5
ffffffffc0201fbe:	07e50513          	addi	a0,a0,126 # ffffffffc0207038 <commands+0x890>
ffffffffc0201fc2:	a54fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201fc6:	00005697          	auipc	a3,0x5
ffffffffc0201fca:	20268693          	addi	a3,a3,514 # ffffffffc02071c8 <commands+0xa20>
ffffffffc0201fce:	00005617          	auipc	a2,0x5
ffffffffc0201fd2:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201fd6:	1ef00593          	li	a1,495
ffffffffc0201fda:	00005517          	auipc	a0,0x5
ffffffffc0201fde:	05e50513          	addi	a0,a0,94 # ffffffffc0207038 <commands+0x890>
ffffffffc0201fe2:	a34fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201fe6:	00005697          	auipc	a3,0x5
ffffffffc0201fea:	3c268693          	addi	a3,a3,962 # ffffffffc02073a8 <commands+0xc00>
ffffffffc0201fee:	00005617          	auipc	a2,0x5
ffffffffc0201ff2:	c3a60613          	addi	a2,a2,-966 # ffffffffc0206c28 <commands+0x480>
ffffffffc0201ff6:	20b00593          	li	a1,523
ffffffffc0201ffa:	00005517          	auipc	a0,0x5
ffffffffc0201ffe:	03e50513          	addi	a0,a0,62 # ffffffffc0207038 <commands+0x890>
ffffffffc0202002:	a14fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202006:	00005697          	auipc	a3,0x5
ffffffffc020200a:	26268693          	addi	a3,a3,610 # ffffffffc0207268 <commands+0xac0>
ffffffffc020200e:	00005617          	auipc	a2,0x5
ffffffffc0202012:	c1a60613          	addi	a2,a2,-998 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202016:	20a00593          	li	a1,522
ffffffffc020201a:	00005517          	auipc	a0,0x5
ffffffffc020201e:	01e50513          	addi	a0,a0,30 # ffffffffc0207038 <commands+0x890>
ffffffffc0202022:	9f4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202026:	00005697          	auipc	a3,0x5
ffffffffc020202a:	39a68693          	addi	a3,a3,922 # ffffffffc02073c0 <commands+0xc18>
ffffffffc020202e:	00005617          	auipc	a2,0x5
ffffffffc0202032:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202036:	20700593          	li	a1,519
ffffffffc020203a:	00005517          	auipc	a0,0x5
ffffffffc020203e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0207038 <commands+0x890>
ffffffffc0202042:	9d4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202046:	00005697          	auipc	a3,0x5
ffffffffc020204a:	57a68693          	addi	a3,a3,1402 # ffffffffc02075c0 <commands+0xe18>
ffffffffc020204e:	00005617          	auipc	a2,0x5
ffffffffc0202052:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202056:	23900593          	li	a1,569
ffffffffc020205a:	00005517          	auipc	a0,0x5
ffffffffc020205e:	fde50513          	addi	a0,a0,-34 # ffffffffc0207038 <commands+0x890>
ffffffffc0202062:	9b4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202066:	00005697          	auipc	a3,0x5
ffffffffc020206a:	3b268693          	addi	a3,a3,946 # ffffffffc0207418 <commands+0xc70>
ffffffffc020206e:	00005617          	auipc	a2,0x5
ffffffffc0202072:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202076:	21900593          	li	a1,537
ffffffffc020207a:	00005517          	auipc	a0,0x5
ffffffffc020207e:	fbe50513          	addi	a0,a0,-66 # ffffffffc0207038 <commands+0x890>
ffffffffc0202082:	994fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202086:	00005697          	auipc	a3,0x5
ffffffffc020208a:	42a68693          	addi	a3,a3,1066 # ffffffffc02074b0 <commands+0xd08>
ffffffffc020208e:	00005617          	auipc	a2,0x5
ffffffffc0202092:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202096:	22b00593          	li	a1,555
ffffffffc020209a:	00005517          	auipc	a0,0x5
ffffffffc020209e:	f9e50513          	addi	a0,a0,-98 # ffffffffc0207038 <commands+0x890>
ffffffffc02020a2:	974fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02020a6:	00005697          	auipc	a3,0x5
ffffffffc02020aa:	0a268693          	addi	a3,a3,162 # ffffffffc0207148 <commands+0x9a0>
ffffffffc02020ae:	00005617          	auipc	a2,0x5
ffffffffc02020b2:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0206c28 <commands+0x480>
ffffffffc02020b6:	1e900593          	li	a1,489
ffffffffc02020ba:	00005517          	auipc	a0,0x5
ffffffffc02020be:	f7e50513          	addi	a0,a0,-130 # ffffffffc0207038 <commands+0x890>
ffffffffc02020c2:	954fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02020c6:	00005617          	auipc	a2,0x5
ffffffffc02020ca:	02260613          	addi	a2,a2,34 # ffffffffc02070e8 <commands+0x940>
ffffffffc02020ce:	0c100593          	li	a1,193
ffffffffc02020d2:	00005517          	auipc	a0,0x5
ffffffffc02020d6:	f6650513          	addi	a0,a0,-154 # ffffffffc0207038 <commands+0x890>
ffffffffc02020da:	93cfe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02020de <copy_range>:
               bool share) {
ffffffffc02020de:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020e0:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02020e4:	f486                	sd	ra,104(sp)
ffffffffc02020e6:	f0a2                	sd	s0,96(sp)
ffffffffc02020e8:	eca6                	sd	s1,88(sp)
ffffffffc02020ea:	e8ca                	sd	s2,80(sp)
ffffffffc02020ec:	e4ce                	sd	s3,72(sp)
ffffffffc02020ee:	e0d2                	sd	s4,64(sp)
ffffffffc02020f0:	fc56                	sd	s5,56(sp)
ffffffffc02020f2:	f85a                	sd	s6,48(sp)
ffffffffc02020f4:	f45e                	sd	s7,40(sp)
ffffffffc02020f6:	f062                	sd	s8,32(sp)
ffffffffc02020f8:	ec66                	sd	s9,24(sp)
ffffffffc02020fa:	e86a                	sd	s10,16(sp)
ffffffffc02020fc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020fe:	03479713          	slli	a4,a5,0x34
ffffffffc0202102:	1e071863          	bnez	a4,ffffffffc02022f2 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc0202106:	002007b7          	lui	a5,0x200
ffffffffc020210a:	8432                	mv	s0,a2
ffffffffc020210c:	16f66b63          	bltu	a2,a5,ffffffffc0202282 <copy_range+0x1a4>
ffffffffc0202110:	84b6                	mv	s1,a3
ffffffffc0202112:	16d67863          	bleu	a3,a2,ffffffffc0202282 <copy_range+0x1a4>
ffffffffc0202116:	4785                	li	a5,1
ffffffffc0202118:	07fe                	slli	a5,a5,0x1f
ffffffffc020211a:	16d7e463          	bltu	a5,a3,ffffffffc0202282 <copy_range+0x1a4>
ffffffffc020211e:	5a7d                	li	s4,-1
ffffffffc0202120:	8aaa                	mv	s5,a0
ffffffffc0202122:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc0202124:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202126:	000aac17          	auipc	s8,0xaa
ffffffffc020212a:	2dac0c13          	addi	s8,s8,730 # ffffffffc02ac400 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020212e:	000aab97          	auipc	s7,0xaa
ffffffffc0202132:	33ab8b93          	addi	s7,s7,826 # ffffffffc02ac468 <pages>
    return page - pages + nbase;
ffffffffc0202136:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020213a:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020213e:	4601                	li	a2,0
ffffffffc0202140:	85a2                	mv	a1,s0
ffffffffc0202142:	854a                	mv	a0,s2
ffffffffc0202144:	e3dfe0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0202148:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc020214a:	c17d                	beqz	a0,ffffffffc0202230 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc020214c:	611c                	ld	a5,0(a0)
ffffffffc020214e:	8b85                	andi	a5,a5,1
ffffffffc0202150:	e785                	bnez	a5,ffffffffc0202178 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0202152:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202154:	fe9465e3          	bltu	s0,s1,ffffffffc020213e <copy_range+0x60>
    return 0;
ffffffffc0202158:	4501                	li	a0,0
}
ffffffffc020215a:	70a6                	ld	ra,104(sp)
ffffffffc020215c:	7406                	ld	s0,96(sp)
ffffffffc020215e:	64e6                	ld	s1,88(sp)
ffffffffc0202160:	6946                	ld	s2,80(sp)
ffffffffc0202162:	69a6                	ld	s3,72(sp)
ffffffffc0202164:	6a06                	ld	s4,64(sp)
ffffffffc0202166:	7ae2                	ld	s5,56(sp)
ffffffffc0202168:	7b42                	ld	s6,48(sp)
ffffffffc020216a:	7ba2                	ld	s7,40(sp)
ffffffffc020216c:	7c02                	ld	s8,32(sp)
ffffffffc020216e:	6ce2                	ld	s9,24(sp)
ffffffffc0202170:	6d42                	ld	s10,16(sp)
ffffffffc0202172:	6da2                	ld	s11,8(sp)
ffffffffc0202174:	6165                	addi	sp,sp,112
ffffffffc0202176:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0202178:	4605                	li	a2,1
ffffffffc020217a:	85a2                	mv	a1,s0
ffffffffc020217c:	8556                	mv	a0,s5
ffffffffc020217e:	e03fe0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0202182:	c169                	beqz	a0,ffffffffc0202244 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202184:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0202188:	0017f713          	andi	a4,a5,1
ffffffffc020218c:	01f7fc93          	andi	s9,a5,31
ffffffffc0202190:	14070563          	beqz	a4,ffffffffc02022da <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0202194:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202198:	078a                	slli	a5,a5,0x2
ffffffffc020219a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020219e:	12d77263          	bleu	a3,a4,ffffffffc02022c2 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a2:	000bb783          	ld	a5,0(s7)
ffffffffc02021a6:	fff806b7          	lui	a3,0xfff80
ffffffffc02021aa:	9736                	add	a4,a4,a3
ffffffffc02021ac:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc02021ae:	4505                	li	a0,1
ffffffffc02021b0:	00e78db3          	add	s11,a5,a4
ffffffffc02021b4:	cbffe0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02021b8:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02021ba:	0a0d8463          	beqz	s11,ffffffffc0202262 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc02021be:	c175                	beqz	a0,ffffffffc02022a2 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc02021c0:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc02021c4:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02021c8:	40ed86b3          	sub	a3,s11,a4
ffffffffc02021cc:	8699                	srai	a3,a3,0x6
ffffffffc02021ce:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02021d0:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02021d4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021d6:	06c7fa63          	bleu	a2,a5,ffffffffc020224a <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02021da:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02021de:	000aa717          	auipc	a4,0xaa
ffffffffc02021e2:	27a70713          	addi	a4,a4,634 # ffffffffc02ac458 <va_pa_offset>
ffffffffc02021e6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02021e8:	8799                	srai	a5,a5,0x6
ffffffffc02021ea:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02021ec:	0147f733          	and	a4,a5,s4
ffffffffc02021f0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02021f4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02021f6:	04c77963          	bleu	a2,a4,ffffffffc0202248 <copy_range+0x16a>
            memcpy(kva_dst,kva_src,PGSIZE);
ffffffffc02021fa:	6605                	lui	a2,0x1
ffffffffc02021fc:	953e                	add	a0,a0,a5
ffffffffc02021fe:	00c040ef          	jal	ra,ffffffffc020620a <memcpy>
            ret=page_insert(to,npage,start,perm);
ffffffffc0202202:	86e6                	mv	a3,s9
ffffffffc0202204:	8622                	mv	a2,s0
ffffffffc0202206:	85ea                	mv	a1,s10
ffffffffc0202208:	8556                	mv	a0,s5
ffffffffc020220a:	b8cff0ef          	jal	ra,ffffffffc0201596 <page_insert>
            assert(ret == 0);
ffffffffc020220e:	d131                	beqz	a0,ffffffffc0202152 <copy_range+0x74>
ffffffffc0202210:	00005697          	auipc	a3,0x5
ffffffffc0202214:	df068693          	addi	a3,a3,-528 # ffffffffc0207000 <commands+0x858>
ffffffffc0202218:	00005617          	auipc	a2,0x5
ffffffffc020221c:	a1060613          	addi	a2,a2,-1520 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202220:	18b00593          	li	a1,395
ffffffffc0202224:	00005517          	auipc	a0,0x5
ffffffffc0202228:	e1450513          	addi	a0,a0,-492 # ffffffffc0207038 <commands+0x890>
ffffffffc020222c:	febfd0ef          	jal	ra,ffffffffc0200216 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202230:	002007b7          	lui	a5,0x200
ffffffffc0202234:	943e                	add	s0,s0,a5
ffffffffc0202236:	ffe007b7          	lui	a5,0xffe00
ffffffffc020223a:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc020223c:	dc11                	beqz	s0,ffffffffc0202158 <copy_range+0x7a>
ffffffffc020223e:	f09460e3          	bltu	s0,s1,ffffffffc020213e <copy_range+0x60>
ffffffffc0202242:	bf19                	j	ffffffffc0202158 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0202244:	5571                	li	a0,-4
ffffffffc0202246:	bf11                	j	ffffffffc020215a <copy_range+0x7c>
ffffffffc0202248:	86be                	mv	a3,a5
ffffffffc020224a:	00005617          	auipc	a2,0x5
ffffffffc020224e:	dc660613          	addi	a2,a2,-570 # ffffffffc0207010 <commands+0x868>
ffffffffc0202252:	06900593          	li	a1,105
ffffffffc0202256:	00005517          	auipc	a0,0x5
ffffffffc020225a:	e1250513          	addi	a0,a0,-494 # ffffffffc0207068 <commands+0x8c0>
ffffffffc020225e:	fb9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(page != NULL);
ffffffffc0202262:	00005697          	auipc	a3,0x5
ffffffffc0202266:	d7e68693          	addi	a3,a3,-642 # ffffffffc0206fe0 <commands+0x838>
ffffffffc020226a:	00005617          	auipc	a2,0x5
ffffffffc020226e:	9be60613          	addi	a2,a2,-1602 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202272:	17200593          	li	a1,370
ffffffffc0202276:	00005517          	auipc	a0,0x5
ffffffffc020227a:	dc250513          	addi	a0,a0,-574 # ffffffffc0207038 <commands+0x890>
ffffffffc020227e:	f99fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202282:	00005697          	auipc	a3,0x5
ffffffffc0202286:	3b668693          	addi	a3,a3,950 # ffffffffc0207638 <commands+0xe90>
ffffffffc020228a:	00005617          	auipc	a2,0x5
ffffffffc020228e:	99e60613          	addi	a2,a2,-1634 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202292:	15e00593          	li	a1,350
ffffffffc0202296:	00005517          	auipc	a0,0x5
ffffffffc020229a:	da250513          	addi	a0,a0,-606 # ffffffffc0207038 <commands+0x890>
ffffffffc020229e:	f79fd0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(npage != NULL);
ffffffffc02022a2:	00005697          	auipc	a3,0x5
ffffffffc02022a6:	d4e68693          	addi	a3,a3,-690 # ffffffffc0206ff0 <commands+0x848>
ffffffffc02022aa:	00005617          	auipc	a2,0x5
ffffffffc02022ae:	97e60613          	addi	a2,a2,-1666 # ffffffffc0206c28 <commands+0x480>
ffffffffc02022b2:	17300593          	li	a1,371
ffffffffc02022b6:	00005517          	auipc	a0,0x5
ffffffffc02022ba:	d8250513          	addi	a0,a0,-638 # ffffffffc0207038 <commands+0x890>
ffffffffc02022be:	f59fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02022c2:	00005617          	auipc	a2,0x5
ffffffffc02022c6:	d8660613          	addi	a2,a2,-634 # ffffffffc0207048 <commands+0x8a0>
ffffffffc02022ca:	06200593          	li	a1,98
ffffffffc02022ce:	00005517          	auipc	a0,0x5
ffffffffc02022d2:	d9a50513          	addi	a0,a0,-614 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02022d6:	f41fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02022da:	00005617          	auipc	a2,0x5
ffffffffc02022de:	f4e60613          	addi	a2,a2,-178 # ffffffffc0207228 <commands+0xa80>
ffffffffc02022e2:	07400593          	li	a1,116
ffffffffc02022e6:	00005517          	auipc	a0,0x5
ffffffffc02022ea:	d8250513          	addi	a0,a0,-638 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02022ee:	f29fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022f2:	00005697          	auipc	a3,0x5
ffffffffc02022f6:	31668693          	addi	a3,a3,790 # ffffffffc0207608 <commands+0xe60>
ffffffffc02022fa:	00005617          	auipc	a2,0x5
ffffffffc02022fe:	92e60613          	addi	a2,a2,-1746 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202302:	15d00593          	li	a1,349
ffffffffc0202306:	00005517          	auipc	a0,0x5
ffffffffc020230a:	d3250513          	addi	a0,a0,-718 # ffffffffc0207038 <commands+0x890>
ffffffffc020230e:	f09fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202312 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202312:	12058073          	sfence.vma	a1
}
ffffffffc0202316:	8082                	ret

ffffffffc0202318 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202318:	7179                	addi	sp,sp,-48
ffffffffc020231a:	e84a                	sd	s2,16(sp)
ffffffffc020231c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020231e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202320:	f022                	sd	s0,32(sp)
ffffffffc0202322:	ec26                	sd	s1,24(sp)
ffffffffc0202324:	e44e                	sd	s3,8(sp)
ffffffffc0202326:	f406                	sd	ra,40(sp)
ffffffffc0202328:	84ae                	mv	s1,a1
ffffffffc020232a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020232c:	b47fe0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0202330:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202332:	cd1d                	beqz	a0,ffffffffc0202370 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202334:	85aa                	mv	a1,a0
ffffffffc0202336:	86ce                	mv	a3,s3
ffffffffc0202338:	8626                	mv	a2,s1
ffffffffc020233a:	854a                	mv	a0,s2
ffffffffc020233c:	a5aff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0202340:	e121                	bnez	a0,ffffffffc0202380 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0202342:	000aa797          	auipc	a5,0xaa
ffffffffc0202346:	0d678793          	addi	a5,a5,214 # ffffffffc02ac418 <swap_init_ok>
ffffffffc020234a:	439c                	lw	a5,0(a5)
ffffffffc020234c:	2781                	sext.w	a5,a5
ffffffffc020234e:	c38d                	beqz	a5,ffffffffc0202370 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0202350:	000aa797          	auipc	a5,0xaa
ffffffffc0202354:	12078793          	addi	a5,a5,288 # ffffffffc02ac470 <check_mm_struct>
ffffffffc0202358:	6388                	ld	a0,0(a5)
ffffffffc020235a:	c919                	beqz	a0,ffffffffc0202370 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020235c:	4681                	li	a3,0
ffffffffc020235e:	8622                	mv	a2,s0
ffffffffc0202360:	85a6                	mv	a1,s1
ffffffffc0202362:	27c010ef          	jal	ra,ffffffffc02035de <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0202366:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0202368:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020236a:	4785                	li	a5,1
ffffffffc020236c:	02f71063          	bne	a4,a5,ffffffffc020238c <pgdir_alloc_page+0x74>
}
ffffffffc0202370:	8522                	mv	a0,s0
ffffffffc0202372:	70a2                	ld	ra,40(sp)
ffffffffc0202374:	7402                	ld	s0,32(sp)
ffffffffc0202376:	64e2                	ld	s1,24(sp)
ffffffffc0202378:	6942                	ld	s2,16(sp)
ffffffffc020237a:	69a2                	ld	s3,8(sp)
ffffffffc020237c:	6145                	addi	sp,sp,48
ffffffffc020237e:	8082                	ret
            free_page(page);
ffffffffc0202380:	8522                	mv	a0,s0
ffffffffc0202382:	4585                	li	a1,1
ffffffffc0202384:	b77fe0ef          	jal	ra,ffffffffc0200efa <free_pages>
            return NULL;
ffffffffc0202388:	4401                	li	s0,0
ffffffffc020238a:	b7dd                	j	ffffffffc0202370 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020238c:	00005697          	auipc	a3,0x5
ffffffffc0202390:	cec68693          	addi	a3,a3,-788 # ffffffffc0207078 <commands+0x8d0>
ffffffffc0202394:	00005617          	auipc	a2,0x5
ffffffffc0202398:	89460613          	addi	a2,a2,-1900 # ffffffffc0206c28 <commands+0x480>
ffffffffc020239c:	1ca00593          	li	a1,458
ffffffffc02023a0:	00005517          	auipc	a0,0x5
ffffffffc02023a4:	c9850513          	addi	a0,a0,-872 # ffffffffc0207038 <commands+0x890>
ffffffffc02023a8:	e6ffd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02023ac <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02023ac:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02023ae:	00005697          	auipc	a3,0x5
ffffffffc02023b2:	2a268693          	addi	a3,a3,674 # ffffffffc0207650 <commands+0xea8>
ffffffffc02023b6:	00005617          	auipc	a2,0x5
ffffffffc02023ba:	87260613          	addi	a2,a2,-1934 # ffffffffc0206c28 <commands+0x480>
ffffffffc02023be:	06d00593          	li	a1,109
ffffffffc02023c2:	00005517          	auipc	a0,0x5
ffffffffc02023c6:	2ae50513          	addi	a0,a0,686 # ffffffffc0207670 <commands+0xec8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02023ca:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02023cc:	e4bfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02023d0 <mm_create>:
mm_create(void) {
ffffffffc02023d0:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02023d2:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02023d6:	e022                	sd	s0,0(sp)
ffffffffc02023d8:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02023da:	654010ef          	jal	ra,ffffffffc0203a2e <kmalloc>
ffffffffc02023de:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02023e0:	c515                	beqz	a0,ffffffffc020240c <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023e2:	000aa797          	auipc	a5,0xaa
ffffffffc02023e6:	03678793          	addi	a5,a5,54 # ffffffffc02ac418 <swap_init_ok>
ffffffffc02023ea:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02023ec:	e408                	sd	a0,8(s0)
ffffffffc02023ee:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02023f0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02023f4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02023f8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023fc:	2781                	sext.w	a5,a5
ffffffffc02023fe:	ef81                	bnez	a5,ffffffffc0202416 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0202400:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0202404:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0202408:	02043c23          	sd	zero,56(s0)
}
ffffffffc020240c:	8522                	mv	a0,s0
ffffffffc020240e:	60a2                	ld	ra,8(sp)
ffffffffc0202410:	6402                	ld	s0,0(sp)
ffffffffc0202412:	0141                	addi	sp,sp,16
ffffffffc0202414:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202416:	1b8010ef          	jal	ra,ffffffffc02035ce <swap_init_mm>
ffffffffc020241a:	b7ed                	j	ffffffffc0202404 <mm_create+0x34>

ffffffffc020241c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020241c:	1101                	addi	sp,sp,-32
ffffffffc020241e:	e04a                	sd	s2,0(sp)
ffffffffc0202420:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202422:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202426:	e822                	sd	s0,16(sp)
ffffffffc0202428:	e426                	sd	s1,8(sp)
ffffffffc020242a:	ec06                	sd	ra,24(sp)
ffffffffc020242c:	84ae                	mv	s1,a1
ffffffffc020242e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202430:	5fe010ef          	jal	ra,ffffffffc0203a2e <kmalloc>
    if (vma != NULL) {
ffffffffc0202434:	c509                	beqz	a0,ffffffffc020243e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202436:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020243a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020243c:	cd00                	sw	s0,24(a0)
}
ffffffffc020243e:	60e2                	ld	ra,24(sp)
ffffffffc0202440:	6442                	ld	s0,16(sp)
ffffffffc0202442:	64a2                	ld	s1,8(sp)
ffffffffc0202444:	6902                	ld	s2,0(sp)
ffffffffc0202446:	6105                	addi	sp,sp,32
ffffffffc0202448:	8082                	ret

ffffffffc020244a <find_vma>:
    if (mm != NULL) {
ffffffffc020244a:	c51d                	beqz	a0,ffffffffc0202478 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020244c:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020244e:	c781                	beqz	a5,ffffffffc0202456 <find_vma+0xc>
ffffffffc0202450:	6798                	ld	a4,8(a5)
ffffffffc0202452:	02e5f663          	bleu	a4,a1,ffffffffc020247e <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0202456:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202458:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020245a:	00f50f63          	beq	a0,a5,ffffffffc0202478 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020245e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202462:	fee5ebe3          	bltu	a1,a4,ffffffffc0202458 <find_vma+0xe>
ffffffffc0202466:	ff07b703          	ld	a4,-16(a5)
ffffffffc020246a:	fee5f7e3          	bleu	a4,a1,ffffffffc0202458 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020246e:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0202470:	c781                	beqz	a5,ffffffffc0202478 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0202472:	e91c                	sd	a5,16(a0)
}
ffffffffc0202474:	853e                	mv	a0,a5
ffffffffc0202476:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0202478:	4781                	li	a5,0
}
ffffffffc020247a:	853e                	mv	a0,a5
ffffffffc020247c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020247e:	6b98                	ld	a4,16(a5)
ffffffffc0202480:	fce5fbe3          	bleu	a4,a1,ffffffffc0202456 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0202484:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0202486:	b7fd                	j	ffffffffc0202474 <find_vma+0x2a>

ffffffffc0202488 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202488:	6590                	ld	a2,8(a1)
ffffffffc020248a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020248e:	1141                	addi	sp,sp,-16
ffffffffc0202490:	e406                	sd	ra,8(sp)
ffffffffc0202492:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202494:	01066863          	bltu	a2,a6,ffffffffc02024a4 <insert_vma_struct+0x1c>
ffffffffc0202498:	a8b9                	j	ffffffffc02024f6 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020249a:	fe87b683          	ld	a3,-24(a5)
ffffffffc020249e:	04d66763          	bltu	a2,a3,ffffffffc02024ec <insert_vma_struct+0x64>
ffffffffc02024a2:	873e                	mv	a4,a5
ffffffffc02024a4:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02024a6:	fef51ae3          	bne	a0,a5,ffffffffc020249a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02024aa:	02a70463          	beq	a4,a0,ffffffffc02024d2 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02024ae:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02024b2:	fe873883          	ld	a7,-24(a4)
ffffffffc02024b6:	08d8f063          	bleu	a3,a7,ffffffffc0202536 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024ba:	04d66e63          	bltu	a2,a3,ffffffffc0202516 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02024be:	00f50a63          	beq	a0,a5,ffffffffc02024d2 <insert_vma_struct+0x4a>
ffffffffc02024c2:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024c6:	0506e863          	bltu	a3,a6,ffffffffc0202516 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02024ca:	ff07b603          	ld	a2,-16(a5)
ffffffffc02024ce:	02c6f263          	bleu	a2,a3,ffffffffc02024f2 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02024d2:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02024d4:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02024d6:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02024da:	e390                	sd	a2,0(a5)
ffffffffc02024dc:	e710                	sd	a2,8(a4)
}
ffffffffc02024de:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02024e0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02024e2:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02024e4:	2685                	addiw	a3,a3,1
ffffffffc02024e6:	d114                	sw	a3,32(a0)
}
ffffffffc02024e8:	0141                	addi	sp,sp,16
ffffffffc02024ea:	8082                	ret
    if (le_prev != list) {
ffffffffc02024ec:	fca711e3          	bne	a4,a0,ffffffffc02024ae <insert_vma_struct+0x26>
ffffffffc02024f0:	bfd9                	j	ffffffffc02024c6 <insert_vma_struct+0x3e>
ffffffffc02024f2:	ebbff0ef          	jal	ra,ffffffffc02023ac <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02024f6:	00005697          	auipc	a3,0x5
ffffffffc02024fa:	28a68693          	addi	a3,a3,650 # ffffffffc0207780 <commands+0xfd8>
ffffffffc02024fe:	00004617          	auipc	a2,0x4
ffffffffc0202502:	72a60613          	addi	a2,a2,1834 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202506:	07400593          	li	a1,116
ffffffffc020250a:	00005517          	auipc	a0,0x5
ffffffffc020250e:	16650513          	addi	a0,a0,358 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202512:	d05fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202516:	00005697          	auipc	a3,0x5
ffffffffc020251a:	2aa68693          	addi	a3,a3,682 # ffffffffc02077c0 <commands+0x1018>
ffffffffc020251e:	00004617          	auipc	a2,0x4
ffffffffc0202522:	70a60613          	addi	a2,a2,1802 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202526:	06c00593          	li	a1,108
ffffffffc020252a:	00005517          	auipc	a0,0x5
ffffffffc020252e:	14650513          	addi	a0,a0,326 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202532:	ce5fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202536:	00005697          	auipc	a3,0x5
ffffffffc020253a:	26a68693          	addi	a3,a3,618 # ffffffffc02077a0 <commands+0xff8>
ffffffffc020253e:	00004617          	auipc	a2,0x4
ffffffffc0202542:	6ea60613          	addi	a2,a2,1770 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202546:	06b00593          	li	a1,107
ffffffffc020254a:	00005517          	auipc	a0,0x5
ffffffffc020254e:	12650513          	addi	a0,a0,294 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202552:	cc5fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202556 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202556:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202558:	1141                	addi	sp,sp,-16
ffffffffc020255a:	e406                	sd	ra,8(sp)
ffffffffc020255c:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020255e:	e78d                	bnez	a5,ffffffffc0202588 <mm_destroy+0x32>
ffffffffc0202560:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202562:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0202564:	00a40c63          	beq	s0,a0,ffffffffc020257c <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202568:	6118                	ld	a4,0(a0)
ffffffffc020256a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020256c:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020256e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202570:	e398                	sd	a4,0(a5)
ffffffffc0202572:	578010ef          	jal	ra,ffffffffc0203aea <kfree>
    return listelm->next;
ffffffffc0202576:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202578:	fea418e3          	bne	s0,a0,ffffffffc0202568 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc020257c:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020257e:	6402                	ld	s0,0(sp)
ffffffffc0202580:	60a2                	ld	ra,8(sp)
ffffffffc0202582:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0202584:	5660106f          	j	ffffffffc0203aea <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202588:	00005697          	auipc	a3,0x5
ffffffffc020258c:	25868693          	addi	a3,a3,600 # ffffffffc02077e0 <commands+0x1038>
ffffffffc0202590:	00004617          	auipc	a2,0x4
ffffffffc0202594:	69860613          	addi	a2,a2,1688 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202598:	09400593          	li	a1,148
ffffffffc020259c:	00005517          	auipc	a0,0x5
ffffffffc02025a0:	0d450513          	addi	a0,a0,212 # ffffffffc0207670 <commands+0xec8>
ffffffffc02025a4:	c73fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02025a8 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025a8:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02025aa:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025ac:	17fd                	addi	a5,a5,-1
ffffffffc02025ae:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02025b0:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025b2:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02025b6:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025b8:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02025ba:	fc06                	sd	ra,56(sp)
ffffffffc02025bc:	f04a                	sd	s2,32(sp)
ffffffffc02025be:	ec4e                	sd	s3,24(sp)
ffffffffc02025c0:	e852                	sd	s4,16(sp)
ffffffffc02025c2:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02025c4:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02025c8:	002007b7          	lui	a5,0x200
ffffffffc02025cc:	01047433          	and	s0,s0,a6
ffffffffc02025d0:	06f4e363          	bltu	s1,a5,ffffffffc0202636 <mm_map+0x8e>
ffffffffc02025d4:	0684f163          	bleu	s0,s1,ffffffffc0202636 <mm_map+0x8e>
ffffffffc02025d8:	4785                	li	a5,1
ffffffffc02025da:	07fe                	slli	a5,a5,0x1f
ffffffffc02025dc:	0487ed63          	bltu	a5,s0,ffffffffc0202636 <mm_map+0x8e>
ffffffffc02025e0:	89aa                	mv	s3,a0
ffffffffc02025e2:	8a3a                	mv	s4,a4
ffffffffc02025e4:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02025e6:	c931                	beqz	a0,ffffffffc020263a <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02025e8:	85a6                	mv	a1,s1
ffffffffc02025ea:	e61ff0ef          	jal	ra,ffffffffc020244a <find_vma>
ffffffffc02025ee:	c501                	beqz	a0,ffffffffc02025f6 <mm_map+0x4e>
ffffffffc02025f0:	651c                	ld	a5,8(a0)
ffffffffc02025f2:	0487e263          	bltu	a5,s0,ffffffffc0202636 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02025f6:	03000513          	li	a0,48
ffffffffc02025fa:	434010ef          	jal	ra,ffffffffc0203a2e <kmalloc>
ffffffffc02025fe:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202600:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202602:	02090163          	beqz	s2,ffffffffc0202624 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202606:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202608:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020260c:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202610:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202614:	85ca                	mv	a1,s2
ffffffffc0202616:	e73ff0ef          	jal	ra,ffffffffc0202488 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020261a:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020261c:	000a0463          	beqz	s4,ffffffffc0202624 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0202620:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0202624:	70e2                	ld	ra,56(sp)
ffffffffc0202626:	7442                	ld	s0,48(sp)
ffffffffc0202628:	74a2                	ld	s1,40(sp)
ffffffffc020262a:	7902                	ld	s2,32(sp)
ffffffffc020262c:	69e2                	ld	s3,24(sp)
ffffffffc020262e:	6a42                	ld	s4,16(sp)
ffffffffc0202630:	6aa2                	ld	s5,8(sp)
ffffffffc0202632:	6121                	addi	sp,sp,64
ffffffffc0202634:	8082                	ret
        return -E_INVAL;
ffffffffc0202636:	5575                	li	a0,-3
ffffffffc0202638:	b7f5                	j	ffffffffc0202624 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc020263a:	00005697          	auipc	a3,0x5
ffffffffc020263e:	1be68693          	addi	a3,a3,446 # ffffffffc02077f8 <commands+0x1050>
ffffffffc0202642:	00004617          	auipc	a2,0x4
ffffffffc0202646:	5e660613          	addi	a2,a2,1510 # ffffffffc0206c28 <commands+0x480>
ffffffffc020264a:	0a700593          	li	a1,167
ffffffffc020264e:	00005517          	auipc	a0,0x5
ffffffffc0202652:	02250513          	addi	a0,a0,34 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202656:	bc1fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020265a <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc020265a:	7139                	addi	sp,sp,-64
ffffffffc020265c:	fc06                	sd	ra,56(sp)
ffffffffc020265e:	f822                	sd	s0,48(sp)
ffffffffc0202660:	f426                	sd	s1,40(sp)
ffffffffc0202662:	f04a                	sd	s2,32(sp)
ffffffffc0202664:	ec4e                	sd	s3,24(sp)
ffffffffc0202666:	e852                	sd	s4,16(sp)
ffffffffc0202668:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020266a:	c535                	beqz	a0,ffffffffc02026d6 <dup_mmap+0x7c>
ffffffffc020266c:	892a                	mv	s2,a0
ffffffffc020266e:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202670:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202672:	e59d                	bnez	a1,ffffffffc02026a0 <dup_mmap+0x46>
ffffffffc0202674:	a08d                	j	ffffffffc02026d6 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202676:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0202678:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5590>
        insert_vma_struct(to, nvma);
ffffffffc020267c:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc020267e:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0202682:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0202686:	e03ff0ef          	jal	ra,ffffffffc0202488 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc020268a:	ff043683          	ld	a3,-16(s0)
ffffffffc020268e:	fe843603          	ld	a2,-24(s0)
ffffffffc0202692:	6c8c                	ld	a1,24(s1)
ffffffffc0202694:	01893503          	ld	a0,24(s2)
ffffffffc0202698:	4701                	li	a4,0
ffffffffc020269a:	a45ff0ef          	jal	ra,ffffffffc02020de <copy_range>
ffffffffc020269e:	e105                	bnez	a0,ffffffffc02026be <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02026a0:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02026a2:	02848863          	beq	s1,s0,ffffffffc02026d2 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02026a6:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02026aa:	fe843a83          	ld	s5,-24(s0)
ffffffffc02026ae:	ff043a03          	ld	s4,-16(s0)
ffffffffc02026b2:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02026b6:	378010ef          	jal	ra,ffffffffc0203a2e <kmalloc>
ffffffffc02026ba:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02026bc:	fd4d                	bnez	a0,ffffffffc0202676 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02026be:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02026c0:	70e2                	ld	ra,56(sp)
ffffffffc02026c2:	7442                	ld	s0,48(sp)
ffffffffc02026c4:	74a2                	ld	s1,40(sp)
ffffffffc02026c6:	7902                	ld	s2,32(sp)
ffffffffc02026c8:	69e2                	ld	s3,24(sp)
ffffffffc02026ca:	6a42                	ld	s4,16(sp)
ffffffffc02026cc:	6aa2                	ld	s5,8(sp)
ffffffffc02026ce:	6121                	addi	sp,sp,64
ffffffffc02026d0:	8082                	ret
    return 0;
ffffffffc02026d2:	4501                	li	a0,0
ffffffffc02026d4:	b7f5                	j	ffffffffc02026c0 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02026d6:	00005697          	auipc	a3,0x5
ffffffffc02026da:	06a68693          	addi	a3,a3,106 # ffffffffc0207740 <commands+0xf98>
ffffffffc02026de:	00004617          	auipc	a2,0x4
ffffffffc02026e2:	54a60613          	addi	a2,a2,1354 # ffffffffc0206c28 <commands+0x480>
ffffffffc02026e6:	0c000593          	li	a1,192
ffffffffc02026ea:	00005517          	auipc	a0,0x5
ffffffffc02026ee:	f8650513          	addi	a0,a0,-122 # ffffffffc0207670 <commands+0xec8>
ffffffffc02026f2:	b25fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02026f6 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02026f6:	1101                	addi	sp,sp,-32
ffffffffc02026f8:	ec06                	sd	ra,24(sp)
ffffffffc02026fa:	e822                	sd	s0,16(sp)
ffffffffc02026fc:	e426                	sd	s1,8(sp)
ffffffffc02026fe:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202700:	c531                	beqz	a0,ffffffffc020274c <exit_mmap+0x56>
ffffffffc0202702:	591c                	lw	a5,48(a0)
ffffffffc0202704:	84aa                	mv	s1,a0
ffffffffc0202706:	e3b9                	bnez	a5,ffffffffc020274c <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202708:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020270a:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc020270e:	02850663          	beq	a0,s0,ffffffffc020273a <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202712:	ff043603          	ld	a2,-16(s0)
ffffffffc0202716:	fe843583          	ld	a1,-24(s0)
ffffffffc020271a:	854a                	mv	a0,s2
ffffffffc020271c:	a99fe0ef          	jal	ra,ffffffffc02011b4 <unmap_range>
ffffffffc0202720:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202722:	fe8498e3          	bne	s1,s0,ffffffffc0202712 <exit_mmap+0x1c>
ffffffffc0202726:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202728:	00848c63          	beq	s1,s0,ffffffffc0202740 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020272c:	ff043603          	ld	a2,-16(s0)
ffffffffc0202730:	fe843583          	ld	a1,-24(s0)
ffffffffc0202734:	854a                	mv	a0,s2
ffffffffc0202736:	b97fe0ef          	jal	ra,ffffffffc02012cc <exit_range>
ffffffffc020273a:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020273c:	fe8498e3          	bne	s1,s0,ffffffffc020272c <exit_mmap+0x36>
    }
}
ffffffffc0202740:	60e2                	ld	ra,24(sp)
ffffffffc0202742:	6442                	ld	s0,16(sp)
ffffffffc0202744:	64a2                	ld	s1,8(sp)
ffffffffc0202746:	6902                	ld	s2,0(sp)
ffffffffc0202748:	6105                	addi	sp,sp,32
ffffffffc020274a:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020274c:	00005697          	auipc	a3,0x5
ffffffffc0202750:	01468693          	addi	a3,a3,20 # ffffffffc0207760 <commands+0xfb8>
ffffffffc0202754:	00004617          	auipc	a2,0x4
ffffffffc0202758:	4d460613          	addi	a2,a2,1236 # ffffffffc0206c28 <commands+0x480>
ffffffffc020275c:	0d600593          	li	a1,214
ffffffffc0202760:	00005517          	auipc	a0,0x5
ffffffffc0202764:	f1050513          	addi	a0,a0,-240 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202768:	aaffd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020276c <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020276c:	7139                	addi	sp,sp,-64
ffffffffc020276e:	f822                	sd	s0,48(sp)
ffffffffc0202770:	f426                	sd	s1,40(sp)
ffffffffc0202772:	fc06                	sd	ra,56(sp)
ffffffffc0202774:	f04a                	sd	s2,32(sp)
ffffffffc0202776:	ec4e                	sd	s3,24(sp)
ffffffffc0202778:	e852                	sd	s4,16(sp)
ffffffffc020277a:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc020277c:	c55ff0ef          	jal	ra,ffffffffc02023d0 <mm_create>
    assert(mm != NULL);
ffffffffc0202780:	842a                	mv	s0,a0
ffffffffc0202782:	03200493          	li	s1,50
ffffffffc0202786:	e919                	bnez	a0,ffffffffc020279c <vmm_init+0x30>
ffffffffc0202788:	a989                	j	ffffffffc0202bda <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc020278a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020278c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020278e:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202792:	14ed                	addi	s1,s1,-5
ffffffffc0202794:	8522                	mv	a0,s0
ffffffffc0202796:	cf3ff0ef          	jal	ra,ffffffffc0202488 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020279a:	c88d                	beqz	s1,ffffffffc02027cc <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020279c:	03000513          	li	a0,48
ffffffffc02027a0:	28e010ef          	jal	ra,ffffffffc0203a2e <kmalloc>
ffffffffc02027a4:	85aa                	mv	a1,a0
ffffffffc02027a6:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02027aa:	f165                	bnez	a0,ffffffffc020278a <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02027ac:	00005697          	auipc	a3,0x5
ffffffffc02027b0:	27468693          	addi	a3,a3,628 # ffffffffc0207a20 <commands+0x1278>
ffffffffc02027b4:	00004617          	auipc	a2,0x4
ffffffffc02027b8:	47460613          	addi	a2,a2,1140 # ffffffffc0206c28 <commands+0x480>
ffffffffc02027bc:	11300593          	li	a1,275
ffffffffc02027c0:	00005517          	auipc	a0,0x5
ffffffffc02027c4:	eb050513          	addi	a0,a0,-336 # ffffffffc0207670 <commands+0xec8>
ffffffffc02027c8:	a4ffd0ef          	jal	ra,ffffffffc0200216 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02027cc:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02027d0:	1f900913          	li	s2,505
ffffffffc02027d4:	a819                	j	ffffffffc02027ea <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02027d6:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02027d8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02027da:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02027de:	0495                	addi	s1,s1,5
ffffffffc02027e0:	8522                	mv	a0,s0
ffffffffc02027e2:	ca7ff0ef          	jal	ra,ffffffffc0202488 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02027e6:	03248a63          	beq	s1,s2,ffffffffc020281a <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02027ea:	03000513          	li	a0,48
ffffffffc02027ee:	240010ef          	jal	ra,ffffffffc0203a2e <kmalloc>
ffffffffc02027f2:	85aa                	mv	a1,a0
ffffffffc02027f4:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02027f8:	fd79                	bnez	a0,ffffffffc02027d6 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02027fa:	00005697          	auipc	a3,0x5
ffffffffc02027fe:	22668693          	addi	a3,a3,550 # ffffffffc0207a20 <commands+0x1278>
ffffffffc0202802:	00004617          	auipc	a2,0x4
ffffffffc0202806:	42660613          	addi	a2,a2,1062 # ffffffffc0206c28 <commands+0x480>
ffffffffc020280a:	11900593          	li	a1,281
ffffffffc020280e:	00005517          	auipc	a0,0x5
ffffffffc0202812:	e6250513          	addi	a0,a0,-414 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202816:	a01fd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc020281a:	6418                	ld	a4,8(s0)
ffffffffc020281c:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020281e:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202822:	2ee40063          	beq	s0,a4,ffffffffc0202b02 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202826:	fe873603          	ld	a2,-24(a4)
ffffffffc020282a:	ffe78693          	addi	a3,a5,-2
ffffffffc020282e:	24d61a63          	bne	a2,a3,ffffffffc0202a82 <vmm_init+0x316>
ffffffffc0202832:	ff073683          	ld	a3,-16(a4)
ffffffffc0202836:	24f69663          	bne	a3,a5,ffffffffc0202a82 <vmm_init+0x316>
ffffffffc020283a:	0795                	addi	a5,a5,5
ffffffffc020283c:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc020283e:	feb792e3          	bne	a5,a1,ffffffffc0202822 <vmm_init+0xb6>
ffffffffc0202842:	491d                	li	s2,7
ffffffffc0202844:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202846:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020284a:	85a6                	mv	a1,s1
ffffffffc020284c:	8522                	mv	a0,s0
ffffffffc020284e:	bfdff0ef          	jal	ra,ffffffffc020244a <find_vma>
ffffffffc0202852:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0202854:	30050763          	beqz	a0,ffffffffc0202b62 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202858:	00148593          	addi	a1,s1,1
ffffffffc020285c:	8522                	mv	a0,s0
ffffffffc020285e:	bedff0ef          	jal	ra,ffffffffc020244a <find_vma>
ffffffffc0202862:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202864:	2c050f63          	beqz	a0,ffffffffc0202b42 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202868:	85ca                	mv	a1,s2
ffffffffc020286a:	8522                	mv	a0,s0
ffffffffc020286c:	bdfff0ef          	jal	ra,ffffffffc020244a <find_vma>
        assert(vma3 == NULL);
ffffffffc0202870:	2a051963          	bnez	a0,ffffffffc0202b22 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202874:	00348593          	addi	a1,s1,3
ffffffffc0202878:	8522                	mv	a0,s0
ffffffffc020287a:	bd1ff0ef          	jal	ra,ffffffffc020244a <find_vma>
        assert(vma4 == NULL);
ffffffffc020287e:	32051263          	bnez	a0,ffffffffc0202ba2 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202882:	00448593          	addi	a1,s1,4
ffffffffc0202886:	8522                	mv	a0,s0
ffffffffc0202888:	bc3ff0ef          	jal	ra,ffffffffc020244a <find_vma>
        assert(vma5 == NULL);
ffffffffc020288c:	2e051b63          	bnez	a0,ffffffffc0202b82 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202890:	008a3783          	ld	a5,8(s4)
ffffffffc0202894:	20979763          	bne	a5,s1,ffffffffc0202aa2 <vmm_init+0x336>
ffffffffc0202898:	010a3783          	ld	a5,16(s4)
ffffffffc020289c:	21279363          	bne	a5,s2,ffffffffc0202aa2 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02028a0:	0089b783          	ld	a5,8(s3) # 1008 <_binary_obj___user_faultread_out_size-0x8568>
ffffffffc02028a4:	20979f63          	bne	a5,s1,ffffffffc0202ac2 <vmm_init+0x356>
ffffffffc02028a8:	0109b783          	ld	a5,16(s3)
ffffffffc02028ac:	21279b63          	bne	a5,s2,ffffffffc0202ac2 <vmm_init+0x356>
ffffffffc02028b0:	0495                	addi	s1,s1,5
ffffffffc02028b2:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02028b4:	f9549be3          	bne	s1,s5,ffffffffc020284a <vmm_init+0xde>
ffffffffc02028b8:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02028ba:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02028bc:	85a6                	mv	a1,s1
ffffffffc02028be:	8522                	mv	a0,s0
ffffffffc02028c0:	b8bff0ef          	jal	ra,ffffffffc020244a <find_vma>
ffffffffc02028c4:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02028c8:	c90d                	beqz	a0,ffffffffc02028fa <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02028ca:	6914                	ld	a3,16(a0)
ffffffffc02028cc:	6510                	ld	a2,8(a0)
ffffffffc02028ce:	00005517          	auipc	a0,0x5
ffffffffc02028d2:	03a50513          	addi	a0,a0,58 # ffffffffc0207908 <commands+0x1160>
ffffffffc02028d6:	ffafd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02028da:	00005697          	auipc	a3,0x5
ffffffffc02028de:	05668693          	addi	a3,a3,86 # ffffffffc0207930 <commands+0x1188>
ffffffffc02028e2:	00004617          	auipc	a2,0x4
ffffffffc02028e6:	34660613          	addi	a2,a2,838 # ffffffffc0206c28 <commands+0x480>
ffffffffc02028ea:	13b00593          	li	a1,315
ffffffffc02028ee:	00005517          	auipc	a0,0x5
ffffffffc02028f2:	d8250513          	addi	a0,a0,-638 # ffffffffc0207670 <commands+0xec8>
ffffffffc02028f6:	921fd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02028fa:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02028fc:	fd2490e3          	bne	s1,s2,ffffffffc02028bc <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202900:	8522                	mv	a0,s0
ffffffffc0202902:	c55ff0ef          	jal	ra,ffffffffc0202556 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202906:	00005517          	auipc	a0,0x5
ffffffffc020290a:	04250513          	addi	a0,a0,66 # ffffffffc0207948 <commands+0x11a0>
ffffffffc020290e:	fc2fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202912:	e2efe0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0202916:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0202918:	ab9ff0ef          	jal	ra,ffffffffc02023d0 <mm_create>
ffffffffc020291c:	000aa797          	auipc	a5,0xaa
ffffffffc0202920:	b4a7ba23          	sd	a0,-1196(a5) # ffffffffc02ac470 <check_mm_struct>
ffffffffc0202924:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0202926:	36050663          	beqz	a0,ffffffffc0202c92 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020292a:	000aa797          	auipc	a5,0xaa
ffffffffc020292e:	ace78793          	addi	a5,a5,-1330 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc0202932:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0202936:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020293a:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020293e:	2c079e63          	bnez	a5,ffffffffc0202c1a <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202942:	03000513          	li	a0,48
ffffffffc0202946:	0e8010ef          	jal	ra,ffffffffc0203a2e <kmalloc>
ffffffffc020294a:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc020294c:	18050b63          	beqz	a0,ffffffffc0202ae2 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0202950:	002007b7          	lui	a5,0x200
ffffffffc0202954:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0202956:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202958:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020295a:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc020295c:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc020295e:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202962:	b27ff0ef          	jal	ra,ffffffffc0202488 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202966:	10000593          	li	a1,256
ffffffffc020296a:	8526                	mv	a0,s1
ffffffffc020296c:	adfff0ef          	jal	ra,ffffffffc020244a <find_vma>
ffffffffc0202970:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0202974:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202978:	2ca41163          	bne	s0,a0,ffffffffc0202c3a <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc020297c:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5588>
        sum += i;
ffffffffc0202980:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0202982:	fee79de3          	bne	a5,a4,ffffffffc020297c <vmm_init+0x210>
        sum += i;
ffffffffc0202986:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0202988:	10000793          	li	a5,256
        sum += i;
ffffffffc020298c:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x821a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202990:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202994:	0007c683          	lbu	a3,0(a5)
ffffffffc0202998:	0785                	addi	a5,a5,1
ffffffffc020299a:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020299c:	fec79ce3          	bne	a5,a2,ffffffffc0202994 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02029a0:	2c071963          	bnez	a4,ffffffffc0202c72 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029a4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02029a8:	000aaa97          	auipc	s5,0xaa
ffffffffc02029ac:	a58a8a93          	addi	s5,s5,-1448 # ffffffffc02ac400 <npage>
ffffffffc02029b0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029b4:	078a                	slli	a5,a5,0x2
ffffffffc02029b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029b8:	20e7f563          	bleu	a4,a5,ffffffffc0202bc2 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02029bc:	00006697          	auipc	a3,0x6
ffffffffc02029c0:	36c68693          	addi	a3,a3,876 # ffffffffc0208d28 <nbase>
ffffffffc02029c4:	0006ba03          	ld	s4,0(a3)
ffffffffc02029c8:	414786b3          	sub	a3,a5,s4
ffffffffc02029cc:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02029ce:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02029d0:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02029d2:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02029d4:	83b1                	srli	a5,a5,0xc
ffffffffc02029d6:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02029d8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029da:	28e7f063          	bleu	a4,a5,ffffffffc0202c5a <vmm_init+0x4ee>
ffffffffc02029de:	000aa797          	auipc	a5,0xaa
ffffffffc02029e2:	a7a78793          	addi	a5,a5,-1414 # ffffffffc02ac458 <va_pa_offset>
ffffffffc02029e6:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02029e8:	4581                	li	a1,0
ffffffffc02029ea:	854a                	mv	a0,s2
ffffffffc02029ec:	9436                	add	s0,s0,a3
ffffffffc02029ee:	b35fe0ef          	jal	ra,ffffffffc0201522 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029f2:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02029f4:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029f8:	078a                	slli	a5,a5,0x2
ffffffffc02029fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029fc:	1ce7f363          	bleu	a4,a5,ffffffffc0202bc2 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a00:	000aa417          	auipc	s0,0xaa
ffffffffc0202a04:	a6840413          	addi	s0,s0,-1432 # ffffffffc02ac468 <pages>
ffffffffc0202a08:	6008                	ld	a0,0(s0)
ffffffffc0202a0a:	414787b3          	sub	a5,a5,s4
ffffffffc0202a0e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202a10:	953e                	add	a0,a0,a5
ffffffffc0202a12:	4585                	li	a1,1
ffffffffc0202a14:	ce6fe0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a18:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a1c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a20:	078a                	slli	a5,a5,0x2
ffffffffc0202a22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a24:	18e7ff63          	bleu	a4,a5,ffffffffc0202bc2 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a28:	6008                	ld	a0,0(s0)
ffffffffc0202a2a:	414787b3          	sub	a5,a5,s4
ffffffffc0202a2e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202a30:	4585                	li	a1,1
ffffffffc0202a32:	953e                	add	a0,a0,a5
ffffffffc0202a34:	cc6fe0ef          	jal	ra,ffffffffc0200efa <free_pages>
    pgdir[0] = 0;
ffffffffc0202a38:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202a3c:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202a40:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202a44:	8526                	mv	a0,s1
ffffffffc0202a46:	b11ff0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202a4a:	000aa797          	auipc	a5,0xaa
ffffffffc0202a4e:	a207b323          	sd	zero,-1498(a5) # ffffffffc02ac470 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202a52:	ceefe0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0202a56:	1aa99263          	bne	s3,a0,ffffffffc0202bfa <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202a5a:	00005517          	auipc	a0,0x5
ffffffffc0202a5e:	f8e50513          	addi	a0,a0,-114 # ffffffffc02079e8 <commands+0x1240>
ffffffffc0202a62:	e6efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202a66:	7442                	ld	s0,48(sp)
ffffffffc0202a68:	70e2                	ld	ra,56(sp)
ffffffffc0202a6a:	74a2                	ld	s1,40(sp)
ffffffffc0202a6c:	7902                	ld	s2,32(sp)
ffffffffc0202a6e:	69e2                	ld	s3,24(sp)
ffffffffc0202a70:	6a42                	ld	s4,16(sp)
ffffffffc0202a72:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202a74:	00005517          	auipc	a0,0x5
ffffffffc0202a78:	f9450513          	addi	a0,a0,-108 # ffffffffc0207a08 <commands+0x1260>
}
ffffffffc0202a7c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202a7e:	e52fd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202a82:	00005697          	auipc	a3,0x5
ffffffffc0202a86:	d9e68693          	addi	a3,a3,-610 # ffffffffc0207820 <commands+0x1078>
ffffffffc0202a8a:	00004617          	auipc	a2,0x4
ffffffffc0202a8e:	19e60613          	addi	a2,a2,414 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202a92:	12200593          	li	a1,290
ffffffffc0202a96:	00005517          	auipc	a0,0x5
ffffffffc0202a9a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202a9e:	f78fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202aa2:	00005697          	auipc	a3,0x5
ffffffffc0202aa6:	e0668693          	addi	a3,a3,-506 # ffffffffc02078a8 <commands+0x1100>
ffffffffc0202aaa:	00004617          	auipc	a2,0x4
ffffffffc0202aae:	17e60613          	addi	a2,a2,382 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202ab2:	13200593          	li	a1,306
ffffffffc0202ab6:	00005517          	auipc	a0,0x5
ffffffffc0202aba:	bba50513          	addi	a0,a0,-1094 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202abe:	f58fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202ac2:	00005697          	auipc	a3,0x5
ffffffffc0202ac6:	e1668693          	addi	a3,a3,-490 # ffffffffc02078d8 <commands+0x1130>
ffffffffc0202aca:	00004617          	auipc	a2,0x4
ffffffffc0202ace:	15e60613          	addi	a2,a2,350 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202ad2:	13300593          	li	a1,307
ffffffffc0202ad6:	00005517          	auipc	a0,0x5
ffffffffc0202ada:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202ade:	f38fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(vma != NULL);
ffffffffc0202ae2:	00005697          	auipc	a3,0x5
ffffffffc0202ae6:	f3e68693          	addi	a3,a3,-194 # ffffffffc0207a20 <commands+0x1278>
ffffffffc0202aea:	00004617          	auipc	a2,0x4
ffffffffc0202aee:	13e60613          	addi	a2,a2,318 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202af2:	15200593          	li	a1,338
ffffffffc0202af6:	00005517          	auipc	a0,0x5
ffffffffc0202afa:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202afe:	f18fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202b02:	00005697          	auipc	a3,0x5
ffffffffc0202b06:	d0668693          	addi	a3,a3,-762 # ffffffffc0207808 <commands+0x1060>
ffffffffc0202b0a:	00004617          	auipc	a2,0x4
ffffffffc0202b0e:	11e60613          	addi	a2,a2,286 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202b12:	12000593          	li	a1,288
ffffffffc0202b16:	00005517          	auipc	a0,0x5
ffffffffc0202b1a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202b1e:	ef8fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma3 == NULL);
ffffffffc0202b22:	00005697          	auipc	a3,0x5
ffffffffc0202b26:	d5668693          	addi	a3,a3,-682 # ffffffffc0207878 <commands+0x10d0>
ffffffffc0202b2a:	00004617          	auipc	a2,0x4
ffffffffc0202b2e:	0fe60613          	addi	a2,a2,254 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202b32:	12c00593          	li	a1,300
ffffffffc0202b36:	00005517          	auipc	a0,0x5
ffffffffc0202b3a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202b3e:	ed8fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2 != NULL);
ffffffffc0202b42:	00005697          	auipc	a3,0x5
ffffffffc0202b46:	d2668693          	addi	a3,a3,-730 # ffffffffc0207868 <commands+0x10c0>
ffffffffc0202b4a:	00004617          	auipc	a2,0x4
ffffffffc0202b4e:	0de60613          	addi	a2,a2,222 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202b52:	12a00593          	li	a1,298
ffffffffc0202b56:	00005517          	auipc	a0,0x5
ffffffffc0202b5a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202b5e:	eb8fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1 != NULL);
ffffffffc0202b62:	00005697          	auipc	a3,0x5
ffffffffc0202b66:	cf668693          	addi	a3,a3,-778 # ffffffffc0207858 <commands+0x10b0>
ffffffffc0202b6a:	00004617          	auipc	a2,0x4
ffffffffc0202b6e:	0be60613          	addi	a2,a2,190 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202b72:	12800593          	li	a1,296
ffffffffc0202b76:	00005517          	auipc	a0,0x5
ffffffffc0202b7a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202b7e:	e98fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma5 == NULL);
ffffffffc0202b82:	00005697          	auipc	a3,0x5
ffffffffc0202b86:	d1668693          	addi	a3,a3,-746 # ffffffffc0207898 <commands+0x10f0>
ffffffffc0202b8a:	00004617          	auipc	a2,0x4
ffffffffc0202b8e:	09e60613          	addi	a2,a2,158 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202b92:	13000593          	li	a1,304
ffffffffc0202b96:	00005517          	auipc	a0,0x5
ffffffffc0202b9a:	ada50513          	addi	a0,a0,-1318 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202b9e:	e78fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma4 == NULL);
ffffffffc0202ba2:	00005697          	auipc	a3,0x5
ffffffffc0202ba6:	ce668693          	addi	a3,a3,-794 # ffffffffc0207888 <commands+0x10e0>
ffffffffc0202baa:	00004617          	auipc	a2,0x4
ffffffffc0202bae:	07e60613          	addi	a2,a2,126 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202bb2:	12e00593          	li	a1,302
ffffffffc0202bb6:	00005517          	auipc	a0,0x5
ffffffffc0202bba:	aba50513          	addi	a0,a0,-1350 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202bbe:	e58fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202bc2:	00004617          	auipc	a2,0x4
ffffffffc0202bc6:	48660613          	addi	a2,a2,1158 # ffffffffc0207048 <commands+0x8a0>
ffffffffc0202bca:	06200593          	li	a1,98
ffffffffc0202bce:	00004517          	auipc	a0,0x4
ffffffffc0202bd2:	49a50513          	addi	a0,a0,1178 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0202bd6:	e40fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(mm != NULL);
ffffffffc0202bda:	00005697          	auipc	a3,0x5
ffffffffc0202bde:	c1e68693          	addi	a3,a3,-994 # ffffffffc02077f8 <commands+0x1050>
ffffffffc0202be2:	00004617          	auipc	a2,0x4
ffffffffc0202be6:	04660613          	addi	a2,a2,70 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202bea:	10c00593          	li	a1,268
ffffffffc0202bee:	00005517          	auipc	a0,0x5
ffffffffc0202bf2:	a8250513          	addi	a0,a0,-1406 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202bf6:	e20fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202bfa:	00005697          	auipc	a3,0x5
ffffffffc0202bfe:	dc668693          	addi	a3,a3,-570 # ffffffffc02079c0 <commands+0x1218>
ffffffffc0202c02:	00004617          	auipc	a2,0x4
ffffffffc0202c06:	02660613          	addi	a2,a2,38 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202c0a:	17000593          	li	a1,368
ffffffffc0202c0e:	00005517          	auipc	a0,0x5
ffffffffc0202c12:	a6250513          	addi	a0,a0,-1438 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202c16:	e00fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202c1a:	00005697          	auipc	a3,0x5
ffffffffc0202c1e:	d6668693          	addi	a3,a3,-666 # ffffffffc0207980 <commands+0x11d8>
ffffffffc0202c22:	00004617          	auipc	a2,0x4
ffffffffc0202c26:	00660613          	addi	a2,a2,6 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202c2a:	14f00593          	li	a1,335
ffffffffc0202c2e:	00005517          	auipc	a0,0x5
ffffffffc0202c32:	a4250513          	addi	a0,a0,-1470 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202c36:	de0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202c3a:	00005697          	auipc	a3,0x5
ffffffffc0202c3e:	d5668693          	addi	a3,a3,-682 # ffffffffc0207990 <commands+0x11e8>
ffffffffc0202c42:	00004617          	auipc	a2,0x4
ffffffffc0202c46:	fe660613          	addi	a2,a2,-26 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202c4a:	15700593          	li	a1,343
ffffffffc0202c4e:	00005517          	auipc	a0,0x5
ffffffffc0202c52:	a2250513          	addi	a0,a0,-1502 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202c56:	dc0fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202c5a:	00004617          	auipc	a2,0x4
ffffffffc0202c5e:	3b660613          	addi	a2,a2,950 # ffffffffc0207010 <commands+0x868>
ffffffffc0202c62:	06900593          	li	a1,105
ffffffffc0202c66:	00004517          	auipc	a0,0x4
ffffffffc0202c6a:	40250513          	addi	a0,a0,1026 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0202c6e:	da8fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(sum == 0);
ffffffffc0202c72:	00005697          	auipc	a3,0x5
ffffffffc0202c76:	d3e68693          	addi	a3,a3,-706 # ffffffffc02079b0 <commands+0x1208>
ffffffffc0202c7a:	00004617          	auipc	a2,0x4
ffffffffc0202c7e:	fae60613          	addi	a2,a2,-82 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202c82:	16300593          	li	a1,355
ffffffffc0202c86:	00005517          	auipc	a0,0x5
ffffffffc0202c8a:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202c8e:	d88fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202c92:	00005697          	auipc	a3,0x5
ffffffffc0202c96:	cd668693          	addi	a3,a3,-810 # ffffffffc0207968 <commands+0x11c0>
ffffffffc0202c9a:	00004617          	auipc	a2,0x4
ffffffffc0202c9e:	f8e60613          	addi	a2,a2,-114 # ffffffffc0206c28 <commands+0x480>
ffffffffc0202ca2:	14b00593          	li	a1,331
ffffffffc0202ca6:	00005517          	auipc	a0,0x5
ffffffffc0202caa:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0207670 <commands+0xec8>
ffffffffc0202cae:	d68fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202cb2 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202cb2:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202cb4:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202cb6:	f822                	sd	s0,48(sp)
ffffffffc0202cb8:	f426                	sd	s1,40(sp)
ffffffffc0202cba:	fc06                	sd	ra,56(sp)
ffffffffc0202cbc:	f04a                	sd	s2,32(sp)
ffffffffc0202cbe:	ec4e                	sd	s3,24(sp)
ffffffffc0202cc0:	8432                	mv	s0,a2
ffffffffc0202cc2:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202cc4:	f86ff0ef          	jal	ra,ffffffffc020244a <find_vma>

    pgfault_num++;
ffffffffc0202cc8:	000a9797          	auipc	a5,0xa9
ffffffffc0202ccc:	74078793          	addi	a5,a5,1856 # ffffffffc02ac408 <pgfault_num>
ffffffffc0202cd0:	439c                	lw	a5,0(a5)
ffffffffc0202cd2:	2785                	addiw	a5,a5,1
ffffffffc0202cd4:	000a9717          	auipc	a4,0xa9
ffffffffc0202cd8:	72f72a23          	sw	a5,1844(a4) # ffffffffc02ac408 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202cdc:	c555                	beqz	a0,ffffffffc0202d88 <do_pgfault+0xd6>
ffffffffc0202cde:	651c                	ld	a5,8(a0)
ffffffffc0202ce0:	0af46463          	bltu	s0,a5,ffffffffc0202d88 <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202ce4:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0202ce6:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202ce8:	8b89                	andi	a5,a5,2
ffffffffc0202cea:	e3a5                	bnez	a5,ffffffffc0202d4a <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202cec:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202cee:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202cf0:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202cf2:	85a2                	mv	a1,s0
ffffffffc0202cf4:	4605                	li	a2,1
ffffffffc0202cf6:	a8afe0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0202cfa:	c945                	beqz	a0,ffffffffc0202daa <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202cfc:	610c                	ld	a1,0(a0)
ffffffffc0202cfe:	c5b5                	beqz	a1,ffffffffc0202d6a <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202d00:	000a9797          	auipc	a5,0xa9
ffffffffc0202d04:	71878793          	addi	a5,a5,1816 # ffffffffc02ac418 <swap_init_ok>
ffffffffc0202d08:	439c                	lw	a5,0(a5)
ffffffffc0202d0a:	2781                	sext.w	a5,a5
ffffffffc0202d0c:	c7d9                	beqz	a5,ffffffffc0202d9a <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0202d0e:	0030                	addi	a2,sp,8
ffffffffc0202d10:	85a2                	mv	a1,s0
ffffffffc0202d12:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202d14:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0202d16:	1ed000ef          	jal	ra,ffffffffc0203702 <swap_in>
ffffffffc0202d1a:	892a                	mv	s2,a0
ffffffffc0202d1c:	e90d                	bnez	a0,ffffffffc0202d4e <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);//建立虚拟地址和物理地址之间的对应关系
ffffffffc0202d1e:	65a2                	ld	a1,8(sp)
ffffffffc0202d20:	6c88                	ld	a0,24(s1)
ffffffffc0202d22:	86ce                	mv	a3,s3
ffffffffc0202d24:	8622                	mv	a2,s0
ffffffffc0202d26:	871fe0ef          	jal	ra,ffffffffc0201596 <page_insert>
            swap_map_swappable(mm, addr, page, 1);//将此页面设置为可交换的
ffffffffc0202d2a:	6622                	ld	a2,8(sp)
ffffffffc0202d2c:	4685                	li	a3,1
ffffffffc0202d2e:	85a2                	mv	a1,s0
ffffffffc0202d30:	8526                	mv	a0,s1
ffffffffc0202d32:	0ad000ef          	jal	ra,ffffffffc02035de <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202d36:	67a2                	ld	a5,8(sp)
ffffffffc0202d38:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0202d3a:	70e2                	ld	ra,56(sp)
ffffffffc0202d3c:	7442                	ld	s0,48(sp)
ffffffffc0202d3e:	854a                	mv	a0,s2
ffffffffc0202d40:	74a2                	ld	s1,40(sp)
ffffffffc0202d42:	7902                	ld	s2,32(sp)
ffffffffc0202d44:	69e2                	ld	s3,24(sp)
ffffffffc0202d46:	6121                	addi	sp,sp,64
ffffffffc0202d48:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0202d4a:	49dd                	li	s3,23
ffffffffc0202d4c:	b745                	j	ffffffffc0202cec <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0202d4e:	00005517          	auipc	a0,0x5
ffffffffc0202d52:	9aa50513          	addi	a0,a0,-1622 # ffffffffc02076f8 <commands+0xf50>
ffffffffc0202d56:	b7afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202d5a:	70e2                	ld	ra,56(sp)
ffffffffc0202d5c:	7442                	ld	s0,48(sp)
ffffffffc0202d5e:	854a                	mv	a0,s2
ffffffffc0202d60:	74a2                	ld	s1,40(sp)
ffffffffc0202d62:	7902                	ld	s2,32(sp)
ffffffffc0202d64:	69e2                	ld	s3,24(sp)
ffffffffc0202d66:	6121                	addi	sp,sp,64
ffffffffc0202d68:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d6a:	6c88                	ld	a0,24(s1)
ffffffffc0202d6c:	864e                	mv	a2,s3
ffffffffc0202d6e:	85a2                	mv	a1,s0
ffffffffc0202d70:	da8ff0ef          	jal	ra,ffffffffc0202318 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202d74:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d76:	f171                	bnez	a0,ffffffffc0202d3a <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202d78:	00005517          	auipc	a0,0x5
ffffffffc0202d7c:	95850513          	addi	a0,a0,-1704 # ffffffffc02076d0 <commands+0xf28>
ffffffffc0202d80:	b50fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d84:	5971                	li	s2,-4
            goto failed;
ffffffffc0202d86:	bf55                	j	ffffffffc0202d3a <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202d88:	85a2                	mv	a1,s0
ffffffffc0202d8a:	00005517          	auipc	a0,0x5
ffffffffc0202d8e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207680 <commands+0xed8>
ffffffffc0202d92:	b3efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d96:	5975                	li	s2,-3
        goto failed;
ffffffffc0202d98:	b74d                	j	ffffffffc0202d3a <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202d9a:	00005517          	auipc	a0,0x5
ffffffffc0202d9e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0207718 <commands+0xf70>
ffffffffc0202da2:	b2efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202da6:	5971                	li	s2,-4
            goto failed;
ffffffffc0202da8:	bf49                	j	ffffffffc0202d3a <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202daa:	00005517          	auipc	a0,0x5
ffffffffc0202dae:	90650513          	addi	a0,a0,-1786 # ffffffffc02076b0 <commands+0xf08>
ffffffffc0202db2:	b1efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202db6:	5971                	li	s2,-4
        goto failed;
ffffffffc0202db8:	b749                	j	ffffffffc0202d3a <do_pgfault+0x88>

ffffffffc0202dba <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0202dba:	7179                	addi	sp,sp,-48
ffffffffc0202dbc:	f022                	sd	s0,32(sp)
ffffffffc0202dbe:	f406                	sd	ra,40(sp)
ffffffffc0202dc0:	ec26                	sd	s1,24(sp)
ffffffffc0202dc2:	e84a                	sd	s2,16(sp)
ffffffffc0202dc4:	e44e                	sd	s3,8(sp)
ffffffffc0202dc6:	e052                	sd	s4,0(sp)
ffffffffc0202dc8:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0202dca:	c135                	beqz	a0,ffffffffc0202e2e <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0202dcc:	002007b7          	lui	a5,0x200
ffffffffc0202dd0:	04f5e663          	bltu	a1,a5,ffffffffc0202e1c <user_mem_check+0x62>
ffffffffc0202dd4:	00c584b3          	add	s1,a1,a2
ffffffffc0202dd8:	0495f263          	bleu	s1,a1,ffffffffc0202e1c <user_mem_check+0x62>
ffffffffc0202ddc:	4785                	li	a5,1
ffffffffc0202dde:	07fe                	slli	a5,a5,0x1f
ffffffffc0202de0:	0297ee63          	bltu	a5,s1,ffffffffc0202e1c <user_mem_check+0x62>
ffffffffc0202de4:	892a                	mv	s2,a0
ffffffffc0202de6:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202de8:	6a05                	lui	s4,0x1
ffffffffc0202dea:	a821                	j	ffffffffc0202e02 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202dec:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202df0:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202df2:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202df4:	c685                	beqz	a3,ffffffffc0202e1c <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202df6:	c399                	beqz	a5,ffffffffc0202dfc <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202df8:	02e46263          	bltu	s0,a4,ffffffffc0202e1c <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0202dfc:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0202dfe:	04947663          	bleu	s1,s0,ffffffffc0202e4a <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0202e02:	85a2                	mv	a1,s0
ffffffffc0202e04:	854a                	mv	a0,s2
ffffffffc0202e06:	e44ff0ef          	jal	ra,ffffffffc020244a <find_vma>
ffffffffc0202e0a:	c909                	beqz	a0,ffffffffc0202e1c <user_mem_check+0x62>
ffffffffc0202e0c:	6518                	ld	a4,8(a0)
ffffffffc0202e0e:	00e46763          	bltu	s0,a4,ffffffffc0202e1c <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202e12:	4d1c                	lw	a5,24(a0)
ffffffffc0202e14:	fc099ce3          	bnez	s3,ffffffffc0202dec <user_mem_check+0x32>
ffffffffc0202e18:	8b85                	andi	a5,a5,1
ffffffffc0202e1a:	f3ed                	bnez	a5,ffffffffc0202dfc <user_mem_check+0x42>
            return 0;
ffffffffc0202e1c:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0202e1e:	70a2                	ld	ra,40(sp)
ffffffffc0202e20:	7402                	ld	s0,32(sp)
ffffffffc0202e22:	64e2                	ld	s1,24(sp)
ffffffffc0202e24:	6942                	ld	s2,16(sp)
ffffffffc0202e26:	69a2                	ld	s3,8(sp)
ffffffffc0202e28:	6a02                	ld	s4,0(sp)
ffffffffc0202e2a:	6145                	addi	sp,sp,48
ffffffffc0202e2c:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0202e2e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202e32:	4501                	li	a0,0
ffffffffc0202e34:	fef5e5e3          	bltu	a1,a5,ffffffffc0202e1e <user_mem_check+0x64>
ffffffffc0202e38:	962e                	add	a2,a2,a1
ffffffffc0202e3a:	fec5f2e3          	bleu	a2,a1,ffffffffc0202e1e <user_mem_check+0x64>
ffffffffc0202e3e:	c8000537          	lui	a0,0xc8000
ffffffffc0202e42:	0505                	addi	a0,a0,1
ffffffffc0202e44:	00a63533          	sltu	a0,a2,a0
ffffffffc0202e48:	bfd9                	j	ffffffffc0202e1e <user_mem_check+0x64>
        return 1;
ffffffffc0202e4a:	4505                	li	a0,1
ffffffffc0202e4c:	bfc9                	j	ffffffffc0202e1e <user_mem_check+0x64>

ffffffffc0202e4e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202e4e:	7135                	addi	sp,sp,-160
ffffffffc0202e50:	ed06                	sd	ra,152(sp)
ffffffffc0202e52:	e922                	sd	s0,144(sp)
ffffffffc0202e54:	e526                	sd	s1,136(sp)
ffffffffc0202e56:	e14a                	sd	s2,128(sp)
ffffffffc0202e58:	fcce                	sd	s3,120(sp)
ffffffffc0202e5a:	f8d2                	sd	s4,112(sp)
ffffffffc0202e5c:	f4d6                	sd	s5,104(sp)
ffffffffc0202e5e:	f0da                	sd	s6,96(sp)
ffffffffc0202e60:	ecde                	sd	s7,88(sp)
ffffffffc0202e62:	e8e2                	sd	s8,80(sp)
ffffffffc0202e64:	e4e6                	sd	s9,72(sp)
ffffffffc0202e66:	e0ea                	sd	s10,64(sp)
ffffffffc0202e68:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202e6a:	4db010ef          	jal	ra,ffffffffc0204b44 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202e6e:	000a9797          	auipc	a5,0xa9
ffffffffc0202e72:	69278793          	addi	a5,a5,1682 # ffffffffc02ac500 <max_swap_offset>
ffffffffc0202e76:	6394                	ld	a3,0(a5)
ffffffffc0202e78:	010007b7          	lui	a5,0x1000
ffffffffc0202e7c:	17e1                	addi	a5,a5,-8
ffffffffc0202e7e:	ff968713          	addi	a4,a3,-7
ffffffffc0202e82:	4ae7ee63          	bltu	a5,a4,ffffffffc020333e <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0202e86:	0009e797          	auipc	a5,0x9e
ffffffffc0202e8a:	11278793          	addi	a5,a5,274 # ffffffffc02a0f98 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202e8e:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202e90:	000a9697          	auipc	a3,0xa9
ffffffffc0202e94:	58f6b023          	sd	a5,1408(a3) # ffffffffc02ac410 <sm>
     int r = sm->init();
ffffffffc0202e98:	9702                	jalr	a4
ffffffffc0202e9a:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202e9c:	c10d                	beqz	a0,ffffffffc0202ebe <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202e9e:	60ea                	ld	ra,152(sp)
ffffffffc0202ea0:	644a                	ld	s0,144(sp)
ffffffffc0202ea2:	8556                	mv	a0,s5
ffffffffc0202ea4:	64aa                	ld	s1,136(sp)
ffffffffc0202ea6:	690a                	ld	s2,128(sp)
ffffffffc0202ea8:	79e6                	ld	s3,120(sp)
ffffffffc0202eaa:	7a46                	ld	s4,112(sp)
ffffffffc0202eac:	7aa6                	ld	s5,104(sp)
ffffffffc0202eae:	7b06                	ld	s6,96(sp)
ffffffffc0202eb0:	6be6                	ld	s7,88(sp)
ffffffffc0202eb2:	6c46                	ld	s8,80(sp)
ffffffffc0202eb4:	6ca6                	ld	s9,72(sp)
ffffffffc0202eb6:	6d06                	ld	s10,64(sp)
ffffffffc0202eb8:	7de2                	ld	s11,56(sp)
ffffffffc0202eba:	610d                	addi	sp,sp,160
ffffffffc0202ebc:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ebe:	000a9797          	auipc	a5,0xa9
ffffffffc0202ec2:	55278793          	addi	a5,a5,1362 # ffffffffc02ac410 <sm>
ffffffffc0202ec6:	639c                	ld	a5,0(a5)
ffffffffc0202ec8:	00005517          	auipc	a0,0x5
ffffffffc0202ecc:	be850513          	addi	a0,a0,-1048 # ffffffffc0207ab0 <commands+0x1308>
ffffffffc0202ed0:	000a9417          	auipc	s0,0xa9
ffffffffc0202ed4:	68040413          	addi	s0,s0,1664 # ffffffffc02ac550 <free_area>
ffffffffc0202ed8:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202eda:	4785                	li	a5,1
ffffffffc0202edc:	000a9717          	auipc	a4,0xa9
ffffffffc0202ee0:	52f72e23          	sw	a5,1340(a4) # ffffffffc02ac418 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ee4:	9ecfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202ee8:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202eea:	36878e63          	beq	a5,s0,ffffffffc0203266 <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202eee:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202ef2:	8305                	srli	a4,a4,0x1
ffffffffc0202ef4:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202ef6:	36070c63          	beqz	a4,ffffffffc020326e <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0202efa:	4481                	li	s1,0
ffffffffc0202efc:	4901                	li	s2,0
ffffffffc0202efe:	a031                	j	ffffffffc0202f0a <swap_init+0xbc>
ffffffffc0202f00:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202f04:	8b09                	andi	a4,a4,2
ffffffffc0202f06:	36070463          	beqz	a4,ffffffffc020326e <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0202f0a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f0e:	679c                	ld	a5,8(a5)
ffffffffc0202f10:	2905                	addiw	s2,s2,1
ffffffffc0202f12:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f14:	fe8796e3          	bne	a5,s0,ffffffffc0202f00 <swap_init+0xb2>
ffffffffc0202f18:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202f1a:	826fe0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0202f1e:	69351863          	bne	a0,s3,ffffffffc02035ae <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202f22:	8626                	mv	a2,s1
ffffffffc0202f24:	85ca                	mv	a1,s2
ffffffffc0202f26:	00005517          	auipc	a0,0x5
ffffffffc0202f2a:	bd250513          	addi	a0,a0,-1070 # ffffffffc0207af8 <commands+0x1350>
ffffffffc0202f2e:	9a2fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202f32:	c9eff0ef          	jal	ra,ffffffffc02023d0 <mm_create>
ffffffffc0202f36:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202f38:	60050b63          	beqz	a0,ffffffffc020354e <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202f3c:	000a9797          	auipc	a5,0xa9
ffffffffc0202f40:	53478793          	addi	a5,a5,1332 # ffffffffc02ac470 <check_mm_struct>
ffffffffc0202f44:	639c                	ld	a5,0(a5)
ffffffffc0202f46:	62079463          	bnez	a5,ffffffffc020356e <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f4a:	000a9797          	auipc	a5,0xa9
ffffffffc0202f4e:	4ae78793          	addi	a5,a5,1198 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc0202f52:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202f56:	000a9797          	auipc	a5,0xa9
ffffffffc0202f5a:	50a7bd23          	sd	a0,1306(a5) # ffffffffc02ac470 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202f5e:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75588>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f62:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202f66:	4e079863          	bnez	a5,ffffffffc0203456 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202f6a:	6599                	lui	a1,0x6
ffffffffc0202f6c:	460d                	li	a2,3
ffffffffc0202f6e:	6505                	lui	a0,0x1
ffffffffc0202f70:	cacff0ef          	jal	ra,ffffffffc020241c <vma_create>
ffffffffc0202f74:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202f76:	50050063          	beqz	a0,ffffffffc0203476 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0202f7a:	855e                	mv	a0,s7
ffffffffc0202f7c:	d0cff0ef          	jal	ra,ffffffffc0202488 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202f80:	00005517          	auipc	a0,0x5
ffffffffc0202f84:	bb850513          	addi	a0,a0,-1096 # ffffffffc0207b38 <commands+0x1390>
ffffffffc0202f88:	948fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202f8c:	018bb503          	ld	a0,24(s7)
ffffffffc0202f90:	4605                	li	a2,1
ffffffffc0202f92:	6585                	lui	a1,0x1
ffffffffc0202f94:	fedfd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202f98:	4e050f63          	beqz	a0,ffffffffc0203496 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202f9c:	00005517          	auipc	a0,0x5
ffffffffc0202fa0:	bec50513          	addi	a0,a0,-1044 # ffffffffc0207b88 <commands+0x13e0>
ffffffffc0202fa4:	000a9997          	auipc	s3,0xa9
ffffffffc0202fa8:	4d498993          	addi	s3,s3,1236 # ffffffffc02ac478 <check_rp>
ffffffffc0202fac:	924fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202fb0:	000a9a17          	auipc	s4,0xa9
ffffffffc0202fb4:	4e8a0a13          	addi	s4,s4,1256 # ffffffffc02ac498 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202fb8:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202fba:	4505                	li	a0,1
ffffffffc0202fbc:	eb7fd0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0202fc0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202fc4:	32050d63          	beqz	a0,ffffffffc02032fe <swap_init+0x4b0>
ffffffffc0202fc8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202fca:	8b89                	andi	a5,a5,2
ffffffffc0202fcc:	30079963          	bnez	a5,ffffffffc02032de <swap_init+0x490>
ffffffffc0202fd0:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202fd2:	ff4c14e3          	bne	s8,s4,ffffffffc0202fba <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202fd6:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202fd8:	000a9c17          	auipc	s8,0xa9
ffffffffc0202fdc:	4a0c0c13          	addi	s8,s8,1184 # ffffffffc02ac478 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202fe0:	ec3e                	sd	a5,24(sp)
ffffffffc0202fe2:	641c                	ld	a5,8(s0)
ffffffffc0202fe4:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202fe6:	481c                	lw	a5,16(s0)
ffffffffc0202fe8:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202fea:	000a9797          	auipc	a5,0xa9
ffffffffc0202fee:	5687b723          	sd	s0,1390(a5) # ffffffffc02ac558 <free_area+0x8>
ffffffffc0202ff2:	000a9797          	auipc	a5,0xa9
ffffffffc0202ff6:	5487bf23          	sd	s0,1374(a5) # ffffffffc02ac550 <free_area>
     nr_free = 0;
ffffffffc0202ffa:	000a9797          	auipc	a5,0xa9
ffffffffc0202ffe:	5607a323          	sw	zero,1382(a5) # ffffffffc02ac560 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203002:	000c3503          	ld	a0,0(s8)
ffffffffc0203006:	4585                	li	a1,1
ffffffffc0203008:	0c21                	addi	s8,s8,8
ffffffffc020300a:	ef1fd0ef          	jal	ra,ffffffffc0200efa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020300e:	ff4c1ae3          	bne	s8,s4,ffffffffc0203002 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203012:	01042c03          	lw	s8,16(s0)
ffffffffc0203016:	4791                	li	a5,4
ffffffffc0203018:	50fc1b63          	bne	s8,a5,ffffffffc020352e <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020301c:	00005517          	auipc	a0,0x5
ffffffffc0203020:	bf450513          	addi	a0,a0,-1036 # ffffffffc0207c10 <commands+0x1468>
ffffffffc0203024:	8acfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203028:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020302a:	000a9797          	auipc	a5,0xa9
ffffffffc020302e:	3c07af23          	sw	zero,990(a5) # ffffffffc02ac408 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203032:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203034:	000a9797          	auipc	a5,0xa9
ffffffffc0203038:	3d478793          	addi	a5,a5,980 # ffffffffc02ac408 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020303c:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
     assert(pgfault_num==1);
ffffffffc0203040:	4398                	lw	a4,0(a5)
ffffffffc0203042:	4585                	li	a1,1
ffffffffc0203044:	2701                	sext.w	a4,a4
ffffffffc0203046:	38b71863          	bne	a4,a1,ffffffffc02033d6 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020304a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020304e:	4394                	lw	a3,0(a5)
ffffffffc0203050:	2681                	sext.w	a3,a3
ffffffffc0203052:	3ae69263          	bne	a3,a4,ffffffffc02033f6 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203056:	6689                	lui	a3,0x2
ffffffffc0203058:	462d                	li	a2,11
ffffffffc020305a:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
     assert(pgfault_num==2);
ffffffffc020305e:	4398                	lw	a4,0(a5)
ffffffffc0203060:	4589                	li	a1,2
ffffffffc0203062:	2701                	sext.w	a4,a4
ffffffffc0203064:	2eb71963          	bne	a4,a1,ffffffffc0203356 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203068:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020306c:	4394                	lw	a3,0(a5)
ffffffffc020306e:	2681                	sext.w	a3,a3
ffffffffc0203070:	30e69363          	bne	a3,a4,ffffffffc0203376 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203074:	668d                	lui	a3,0x3
ffffffffc0203076:	4631                	li	a2,12
ffffffffc0203078:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
     assert(pgfault_num==3);
ffffffffc020307c:	4398                	lw	a4,0(a5)
ffffffffc020307e:	458d                	li	a1,3
ffffffffc0203080:	2701                	sext.w	a4,a4
ffffffffc0203082:	30b71a63          	bne	a4,a1,ffffffffc0203396 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203086:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc020308a:	4394                	lw	a3,0(a5)
ffffffffc020308c:	2681                	sext.w	a3,a3
ffffffffc020308e:	32e69463          	bne	a3,a4,ffffffffc02033b6 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203092:	6691                	lui	a3,0x4
ffffffffc0203094:	4635                	li	a2,13
ffffffffc0203096:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
     assert(pgfault_num==4);
ffffffffc020309a:	4398                	lw	a4,0(a5)
ffffffffc020309c:	2701                	sext.w	a4,a4
ffffffffc020309e:	37871c63          	bne	a4,s8,ffffffffc0203416 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02030a2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02030a6:	439c                	lw	a5,0(a5)
ffffffffc02030a8:	2781                	sext.w	a5,a5
ffffffffc02030aa:	38e79663          	bne	a5,a4,ffffffffc0203436 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02030ae:	481c                	lw	a5,16(s0)
ffffffffc02030b0:	40079363          	bnez	a5,ffffffffc02034b6 <swap_init+0x668>
ffffffffc02030b4:	000a9797          	auipc	a5,0xa9
ffffffffc02030b8:	3e478793          	addi	a5,a5,996 # ffffffffc02ac498 <swap_in_seq_no>
ffffffffc02030bc:	000a9717          	auipc	a4,0xa9
ffffffffc02030c0:	40470713          	addi	a4,a4,1028 # ffffffffc02ac4c0 <swap_out_seq_no>
ffffffffc02030c4:	000a9617          	auipc	a2,0xa9
ffffffffc02030c8:	3fc60613          	addi	a2,a2,1020 # ffffffffc02ac4c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02030cc:	56fd                	li	a3,-1
ffffffffc02030ce:	c394                	sw	a3,0(a5)
ffffffffc02030d0:	c314                	sw	a3,0(a4)
ffffffffc02030d2:	0791                	addi	a5,a5,4
ffffffffc02030d4:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02030d6:	fef61ce3          	bne	a2,a5,ffffffffc02030ce <swap_init+0x280>
ffffffffc02030da:	000a9697          	auipc	a3,0xa9
ffffffffc02030de:	44668693          	addi	a3,a3,1094 # ffffffffc02ac520 <check_ptep>
ffffffffc02030e2:	000a9817          	auipc	a6,0xa9
ffffffffc02030e6:	39680813          	addi	a6,a6,918 # ffffffffc02ac478 <check_rp>
ffffffffc02030ea:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030ec:	000a9c97          	auipc	s9,0xa9
ffffffffc02030f0:	314c8c93          	addi	s9,s9,788 # ffffffffc02ac400 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030f4:	00006d97          	auipc	s11,0x6
ffffffffc02030f8:	c34d8d93          	addi	s11,s11,-972 # ffffffffc0208d28 <nbase>
ffffffffc02030fc:	000a9c17          	auipc	s8,0xa9
ffffffffc0203100:	36cc0c13          	addi	s8,s8,876 # ffffffffc02ac468 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203104:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203108:	4601                	li	a2,0
ffffffffc020310a:	85ea                	mv	a1,s10
ffffffffc020310c:	855a                	mv	a0,s6
ffffffffc020310e:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0203110:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203112:	e6ffd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0203116:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203118:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020311a:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020311c:	20050163          	beqz	a0,ffffffffc020331e <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203120:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203122:	0017f613          	andi	a2,a5,1
ffffffffc0203126:	1a060063          	beqz	a2,ffffffffc02032c6 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc020312a:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020312e:	078a                	slli	a5,a5,0x2
ffffffffc0203130:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203132:	14c7fe63          	bleu	a2,a5,ffffffffc020328e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203136:	000db703          	ld	a4,0(s11)
ffffffffc020313a:	000c3603          	ld	a2,0(s8)
ffffffffc020313e:	00083583          	ld	a1,0(a6)
ffffffffc0203142:	8f99                	sub	a5,a5,a4
ffffffffc0203144:	079a                	slli	a5,a5,0x6
ffffffffc0203146:	e43a                	sd	a4,8(sp)
ffffffffc0203148:	97b2                	add	a5,a5,a2
ffffffffc020314a:	14f59e63          	bne	a1,a5,ffffffffc02032a6 <swap_init+0x458>
ffffffffc020314e:	6785                	lui	a5,0x1
ffffffffc0203150:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203152:	6795                	lui	a5,0x5
ffffffffc0203154:	06a1                	addi	a3,a3,8
ffffffffc0203156:	0821                	addi	a6,a6,8
ffffffffc0203158:	fafd16e3          	bne	s10,a5,ffffffffc0203104 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020315c:	00005517          	auipc	a0,0x5
ffffffffc0203160:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0207cc8 <commands+0x1520>
ffffffffc0203164:	f6dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203168:	000a9797          	auipc	a5,0xa9
ffffffffc020316c:	2a878793          	addi	a5,a5,680 # ffffffffc02ac410 <sm>
ffffffffc0203170:	639c                	ld	a5,0(a5)
ffffffffc0203172:	7f9c                	ld	a5,56(a5)
ffffffffc0203174:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203176:	40051c63          	bnez	a0,ffffffffc020358e <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc020317a:	77a2                	ld	a5,40(sp)
ffffffffc020317c:	000a9717          	auipc	a4,0xa9
ffffffffc0203180:	3ef72223          	sw	a5,996(a4) # ffffffffc02ac560 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0203184:	67e2                	ld	a5,24(sp)
ffffffffc0203186:	000a9717          	auipc	a4,0xa9
ffffffffc020318a:	3cf73523          	sd	a5,970(a4) # ffffffffc02ac550 <free_area>
ffffffffc020318e:	7782                	ld	a5,32(sp)
ffffffffc0203190:	000a9717          	auipc	a4,0xa9
ffffffffc0203194:	3cf73423          	sd	a5,968(a4) # ffffffffc02ac558 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203198:	0009b503          	ld	a0,0(s3)
ffffffffc020319c:	4585                	li	a1,1
ffffffffc020319e:	09a1                	addi	s3,s3,8
ffffffffc02031a0:	d5bfd0ef          	jal	ra,ffffffffc0200efa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02031a4:	ff499ae3          	bne	s3,s4,ffffffffc0203198 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02031a8:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02031ac:	855e                	mv	a0,s7
ffffffffc02031ae:	ba8ff0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02031b2:	000a9797          	auipc	a5,0xa9
ffffffffc02031b6:	24678793          	addi	a5,a5,582 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc02031ba:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02031bc:	000a9697          	auipc	a3,0xa9
ffffffffc02031c0:	2a06ba23          	sd	zero,692(a3) # ffffffffc02ac470 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02031c4:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031c8:	6394                	ld	a3,0(a5)
ffffffffc02031ca:	068a                	slli	a3,a3,0x2
ffffffffc02031cc:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031ce:	0ce6f063          	bleu	a4,a3,ffffffffc020328e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02031d2:	67a2                	ld	a5,8(sp)
ffffffffc02031d4:	000c3503          	ld	a0,0(s8)
ffffffffc02031d8:	8e9d                	sub	a3,a3,a5
ffffffffc02031da:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02031dc:	8699                	srai	a3,a3,0x6
ffffffffc02031de:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02031e0:	57fd                	li	a5,-1
ffffffffc02031e2:	83b1                	srli	a5,a5,0xc
ffffffffc02031e4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02031e6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031e8:	2ee7f763          	bleu	a4,a5,ffffffffc02034d6 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02031ec:	000a9797          	auipc	a5,0xa9
ffffffffc02031f0:	26c78793          	addi	a5,a5,620 # ffffffffc02ac458 <va_pa_offset>
ffffffffc02031f4:	639c                	ld	a5,0(a5)
ffffffffc02031f6:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02031f8:	629c                	ld	a5,0(a3)
ffffffffc02031fa:	078a                	slli	a5,a5,0x2
ffffffffc02031fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031fe:	08e7f863          	bleu	a4,a5,ffffffffc020328e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203202:	69a2                	ld	s3,8(sp)
ffffffffc0203204:	4585                	li	a1,1
ffffffffc0203206:	413787b3          	sub	a5,a5,s3
ffffffffc020320a:	079a                	slli	a5,a5,0x6
ffffffffc020320c:	953e                	add	a0,a0,a5
ffffffffc020320e:	cedfd0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203212:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203216:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020321a:	078a                	slli	a5,a5,0x2
ffffffffc020321c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020321e:	06e7f863          	bleu	a4,a5,ffffffffc020328e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203222:	000c3503          	ld	a0,0(s8)
ffffffffc0203226:	413787b3          	sub	a5,a5,s3
ffffffffc020322a:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020322c:	4585                	li	a1,1
ffffffffc020322e:	953e                	add	a0,a0,a5
ffffffffc0203230:	ccbfd0ef          	jal	ra,ffffffffc0200efa <free_pages>
     pgdir[0] = 0;
ffffffffc0203234:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203238:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020323c:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020323e:	00878963          	beq	a5,s0,ffffffffc0203250 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203242:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203246:	679c                	ld	a5,8(a5)
ffffffffc0203248:	397d                	addiw	s2,s2,-1
ffffffffc020324a:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020324c:	fe879be3          	bne	a5,s0,ffffffffc0203242 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0203250:	28091f63          	bnez	s2,ffffffffc02034ee <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203254:	2a049d63          	bnez	s1,ffffffffc020350e <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203258:	00005517          	auipc	a0,0x5
ffffffffc020325c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0207d18 <commands+0x1570>
ffffffffc0203260:	e71fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0203264:	b92d                	j	ffffffffc0202e9e <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203266:	4481                	li	s1,0
ffffffffc0203268:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc020326a:	4981                	li	s3,0
ffffffffc020326c:	b17d                	j	ffffffffc0202f1a <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020326e:	00005697          	auipc	a3,0x5
ffffffffc0203272:	85a68693          	addi	a3,a3,-1958 # ffffffffc0207ac8 <commands+0x1320>
ffffffffc0203276:	00004617          	auipc	a2,0x4
ffffffffc020327a:	9b260613          	addi	a2,a2,-1614 # ffffffffc0206c28 <commands+0x480>
ffffffffc020327e:	0bc00593          	li	a1,188
ffffffffc0203282:	00005517          	auipc	a0,0x5
ffffffffc0203286:	81e50513          	addi	a0,a0,-2018 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020328a:	f8dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020328e:	00004617          	auipc	a2,0x4
ffffffffc0203292:	dba60613          	addi	a2,a2,-582 # ffffffffc0207048 <commands+0x8a0>
ffffffffc0203296:	06200593          	li	a1,98
ffffffffc020329a:	00004517          	auipc	a0,0x4
ffffffffc020329e:	dce50513          	addi	a0,a0,-562 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02032a2:	f75fc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02032a6:	00005697          	auipc	a3,0x5
ffffffffc02032aa:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207ca0 <commands+0x14f8>
ffffffffc02032ae:	00004617          	auipc	a2,0x4
ffffffffc02032b2:	97a60613          	addi	a2,a2,-1670 # ffffffffc0206c28 <commands+0x480>
ffffffffc02032b6:	0fc00593          	li	a1,252
ffffffffc02032ba:	00004517          	auipc	a0,0x4
ffffffffc02032be:	7e650513          	addi	a0,a0,2022 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02032c2:	f55fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032c6:	00004617          	auipc	a2,0x4
ffffffffc02032ca:	f6260613          	addi	a2,a2,-158 # ffffffffc0207228 <commands+0xa80>
ffffffffc02032ce:	07400593          	li	a1,116
ffffffffc02032d2:	00004517          	auipc	a0,0x4
ffffffffc02032d6:	d9650513          	addi	a0,a0,-618 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02032da:	f3dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02032de:	00005697          	auipc	a3,0x5
ffffffffc02032e2:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0207bc8 <commands+0x1420>
ffffffffc02032e6:	00004617          	auipc	a2,0x4
ffffffffc02032ea:	94260613          	addi	a2,a2,-1726 # ffffffffc0206c28 <commands+0x480>
ffffffffc02032ee:	0dd00593          	li	a1,221
ffffffffc02032f2:	00004517          	auipc	a0,0x4
ffffffffc02032f6:	7ae50513          	addi	a0,a0,1966 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02032fa:	f1dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02032fe:	00005697          	auipc	a3,0x5
ffffffffc0203302:	8b268693          	addi	a3,a3,-1870 # ffffffffc0207bb0 <commands+0x1408>
ffffffffc0203306:	00004617          	auipc	a2,0x4
ffffffffc020330a:	92260613          	addi	a2,a2,-1758 # ffffffffc0206c28 <commands+0x480>
ffffffffc020330e:	0dc00593          	li	a1,220
ffffffffc0203312:	00004517          	auipc	a0,0x4
ffffffffc0203316:	78e50513          	addi	a0,a0,1934 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020331a:	efdfc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020331e:	00005697          	auipc	a3,0x5
ffffffffc0203322:	96a68693          	addi	a3,a3,-1686 # ffffffffc0207c88 <commands+0x14e0>
ffffffffc0203326:	00004617          	auipc	a2,0x4
ffffffffc020332a:	90260613          	addi	a2,a2,-1790 # ffffffffc0206c28 <commands+0x480>
ffffffffc020332e:	0fb00593          	li	a1,251
ffffffffc0203332:	00004517          	auipc	a0,0x4
ffffffffc0203336:	76e50513          	addi	a0,a0,1902 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020333a:	eddfc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020333e:	00004617          	auipc	a2,0x4
ffffffffc0203342:	74260613          	addi	a2,a2,1858 # ffffffffc0207a80 <commands+0x12d8>
ffffffffc0203346:	02800593          	li	a1,40
ffffffffc020334a:	00004517          	auipc	a0,0x4
ffffffffc020334e:	75650513          	addi	a0,a0,1878 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203352:	ec5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0203356:	00005697          	auipc	a3,0x5
ffffffffc020335a:	8f268693          	addi	a3,a3,-1806 # ffffffffc0207c48 <commands+0x14a0>
ffffffffc020335e:	00004617          	auipc	a2,0x4
ffffffffc0203362:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203366:	09700593          	li	a1,151
ffffffffc020336a:	00004517          	auipc	a0,0x4
ffffffffc020336e:	73650513          	addi	a0,a0,1846 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203372:	ea5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0203376:	00005697          	auipc	a3,0x5
ffffffffc020337a:	8d268693          	addi	a3,a3,-1838 # ffffffffc0207c48 <commands+0x14a0>
ffffffffc020337e:	00004617          	auipc	a2,0x4
ffffffffc0203382:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203386:	09900593          	li	a1,153
ffffffffc020338a:	00004517          	auipc	a0,0x4
ffffffffc020338e:	71650513          	addi	a0,a0,1814 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203392:	e85fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0203396:	00005697          	auipc	a3,0x5
ffffffffc020339a:	8c268693          	addi	a3,a3,-1854 # ffffffffc0207c58 <commands+0x14b0>
ffffffffc020339e:	00004617          	auipc	a2,0x4
ffffffffc02033a2:	88a60613          	addi	a2,a2,-1910 # ffffffffc0206c28 <commands+0x480>
ffffffffc02033a6:	09b00593          	li	a1,155
ffffffffc02033aa:	00004517          	auipc	a0,0x4
ffffffffc02033ae:	6f650513          	addi	a0,a0,1782 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02033b2:	e65fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc02033b6:	00005697          	auipc	a3,0x5
ffffffffc02033ba:	8a268693          	addi	a3,a3,-1886 # ffffffffc0207c58 <commands+0x14b0>
ffffffffc02033be:	00004617          	auipc	a2,0x4
ffffffffc02033c2:	86a60613          	addi	a2,a2,-1942 # ffffffffc0206c28 <commands+0x480>
ffffffffc02033c6:	09d00593          	li	a1,157
ffffffffc02033ca:	00004517          	auipc	a0,0x4
ffffffffc02033ce:	6d650513          	addi	a0,a0,1750 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02033d2:	e45fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc02033d6:	00005697          	auipc	a3,0x5
ffffffffc02033da:	86268693          	addi	a3,a3,-1950 # ffffffffc0207c38 <commands+0x1490>
ffffffffc02033de:	00004617          	auipc	a2,0x4
ffffffffc02033e2:	84a60613          	addi	a2,a2,-1974 # ffffffffc0206c28 <commands+0x480>
ffffffffc02033e6:	09300593          	li	a1,147
ffffffffc02033ea:	00004517          	auipc	a0,0x4
ffffffffc02033ee:	6b650513          	addi	a0,a0,1718 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02033f2:	e25fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc02033f6:	00005697          	auipc	a3,0x5
ffffffffc02033fa:	84268693          	addi	a3,a3,-1982 # ffffffffc0207c38 <commands+0x1490>
ffffffffc02033fe:	00004617          	auipc	a2,0x4
ffffffffc0203402:	82a60613          	addi	a2,a2,-2006 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203406:	09500593          	li	a1,149
ffffffffc020340a:	00004517          	auipc	a0,0x4
ffffffffc020340e:	69650513          	addi	a0,a0,1686 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203412:	e05fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0203416:	00005697          	auipc	a3,0x5
ffffffffc020341a:	85268693          	addi	a3,a3,-1966 # ffffffffc0207c68 <commands+0x14c0>
ffffffffc020341e:	00004617          	auipc	a2,0x4
ffffffffc0203422:	80a60613          	addi	a2,a2,-2038 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203426:	09f00593          	li	a1,159
ffffffffc020342a:	00004517          	auipc	a0,0x4
ffffffffc020342e:	67650513          	addi	a0,a0,1654 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203432:	de5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0203436:	00005697          	auipc	a3,0x5
ffffffffc020343a:	83268693          	addi	a3,a3,-1998 # ffffffffc0207c68 <commands+0x14c0>
ffffffffc020343e:	00003617          	auipc	a2,0x3
ffffffffc0203442:	7ea60613          	addi	a2,a2,2026 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203446:	0a100593          	li	a1,161
ffffffffc020344a:	00004517          	auipc	a0,0x4
ffffffffc020344e:	65650513          	addi	a0,a0,1622 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203452:	dc5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203456:	00004697          	auipc	a3,0x4
ffffffffc020345a:	52a68693          	addi	a3,a3,1322 # ffffffffc0207980 <commands+0x11d8>
ffffffffc020345e:	00003617          	auipc	a2,0x3
ffffffffc0203462:	7ca60613          	addi	a2,a2,1994 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203466:	0cc00593          	li	a1,204
ffffffffc020346a:	00004517          	auipc	a0,0x4
ffffffffc020346e:	63650513          	addi	a0,a0,1590 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203472:	da5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(vma != NULL);
ffffffffc0203476:	00004697          	auipc	a3,0x4
ffffffffc020347a:	5aa68693          	addi	a3,a3,1450 # ffffffffc0207a20 <commands+0x1278>
ffffffffc020347e:	00003617          	auipc	a2,0x3
ffffffffc0203482:	7aa60613          	addi	a2,a2,1962 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203486:	0cf00593          	li	a1,207
ffffffffc020348a:	00004517          	auipc	a0,0x4
ffffffffc020348e:	61650513          	addi	a0,a0,1558 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203492:	d85fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203496:	00004697          	auipc	a3,0x4
ffffffffc020349a:	6da68693          	addi	a3,a3,1754 # ffffffffc0207b70 <commands+0x13c8>
ffffffffc020349e:	00003617          	auipc	a2,0x3
ffffffffc02034a2:	78a60613          	addi	a2,a2,1930 # ffffffffc0206c28 <commands+0x480>
ffffffffc02034a6:	0d700593          	li	a1,215
ffffffffc02034aa:	00004517          	auipc	a0,0x4
ffffffffc02034ae:	5f650513          	addi	a0,a0,1526 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02034b2:	d65fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert( nr_free == 0);         
ffffffffc02034b6:	00004697          	auipc	a3,0x4
ffffffffc02034ba:	7c268693          	addi	a3,a3,1986 # ffffffffc0207c78 <commands+0x14d0>
ffffffffc02034be:	00003617          	auipc	a2,0x3
ffffffffc02034c2:	76a60613          	addi	a2,a2,1898 # ffffffffc0206c28 <commands+0x480>
ffffffffc02034c6:	0f300593          	li	a1,243
ffffffffc02034ca:	00004517          	auipc	a0,0x4
ffffffffc02034ce:	5d650513          	addi	a0,a0,1494 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02034d2:	d45fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02034d6:	00004617          	auipc	a2,0x4
ffffffffc02034da:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0207010 <commands+0x868>
ffffffffc02034de:	06900593          	li	a1,105
ffffffffc02034e2:	00004517          	auipc	a0,0x4
ffffffffc02034e6:	b8650513          	addi	a0,a0,-1146 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02034ea:	d2dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(count==0);
ffffffffc02034ee:	00005697          	auipc	a3,0x5
ffffffffc02034f2:	80a68693          	addi	a3,a3,-2038 # ffffffffc0207cf8 <commands+0x1550>
ffffffffc02034f6:	00003617          	auipc	a2,0x3
ffffffffc02034fa:	73260613          	addi	a2,a2,1842 # ffffffffc0206c28 <commands+0x480>
ffffffffc02034fe:	11d00593          	li	a1,285
ffffffffc0203502:	00004517          	auipc	a0,0x4
ffffffffc0203506:	59e50513          	addi	a0,a0,1438 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020350a:	d0dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total==0);
ffffffffc020350e:	00004697          	auipc	a3,0x4
ffffffffc0203512:	7fa68693          	addi	a3,a3,2042 # ffffffffc0207d08 <commands+0x1560>
ffffffffc0203516:	00003617          	auipc	a2,0x3
ffffffffc020351a:	71260613          	addi	a2,a2,1810 # ffffffffc0206c28 <commands+0x480>
ffffffffc020351e:	11e00593          	li	a1,286
ffffffffc0203522:	00004517          	auipc	a0,0x4
ffffffffc0203526:	57e50513          	addi	a0,a0,1406 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020352a:	cedfc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020352e:	00004697          	auipc	a3,0x4
ffffffffc0203532:	6ba68693          	addi	a3,a3,1722 # ffffffffc0207be8 <commands+0x1440>
ffffffffc0203536:	00003617          	auipc	a2,0x3
ffffffffc020353a:	6f260613          	addi	a2,a2,1778 # ffffffffc0206c28 <commands+0x480>
ffffffffc020353e:	0ea00593          	li	a1,234
ffffffffc0203542:	00004517          	auipc	a0,0x4
ffffffffc0203546:	55e50513          	addi	a0,a0,1374 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020354a:	ccdfc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(mm != NULL);
ffffffffc020354e:	00004697          	auipc	a3,0x4
ffffffffc0203552:	2aa68693          	addi	a3,a3,682 # ffffffffc02077f8 <commands+0x1050>
ffffffffc0203556:	00003617          	auipc	a2,0x3
ffffffffc020355a:	6d260613          	addi	a2,a2,1746 # ffffffffc0206c28 <commands+0x480>
ffffffffc020355e:	0c400593          	li	a1,196
ffffffffc0203562:	00004517          	auipc	a0,0x4
ffffffffc0203566:	53e50513          	addi	a0,a0,1342 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020356a:	cadfc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020356e:	00004697          	auipc	a3,0x4
ffffffffc0203572:	5b268693          	addi	a3,a3,1458 # ffffffffc0207b20 <commands+0x1378>
ffffffffc0203576:	00003617          	auipc	a2,0x3
ffffffffc020357a:	6b260613          	addi	a2,a2,1714 # ffffffffc0206c28 <commands+0x480>
ffffffffc020357e:	0c700593          	li	a1,199
ffffffffc0203582:	00004517          	auipc	a0,0x4
ffffffffc0203586:	51e50513          	addi	a0,a0,1310 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc020358a:	c8dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(ret==0);
ffffffffc020358e:	00004697          	auipc	a3,0x4
ffffffffc0203592:	76268693          	addi	a3,a3,1890 # ffffffffc0207cf0 <commands+0x1548>
ffffffffc0203596:	00003617          	auipc	a2,0x3
ffffffffc020359a:	69260613          	addi	a2,a2,1682 # ffffffffc0206c28 <commands+0x480>
ffffffffc020359e:	10200593          	li	a1,258
ffffffffc02035a2:	00004517          	auipc	a0,0x4
ffffffffc02035a6:	4fe50513          	addi	a0,a0,1278 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02035aa:	c6dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total == nr_free_pages());
ffffffffc02035ae:	00004697          	auipc	a3,0x4
ffffffffc02035b2:	52a68693          	addi	a3,a3,1322 # ffffffffc0207ad8 <commands+0x1330>
ffffffffc02035b6:	00003617          	auipc	a2,0x3
ffffffffc02035ba:	67260613          	addi	a2,a2,1650 # ffffffffc0206c28 <commands+0x480>
ffffffffc02035be:	0bf00593          	li	a1,191
ffffffffc02035c2:	00004517          	auipc	a0,0x4
ffffffffc02035c6:	4de50513          	addi	a0,a0,1246 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02035ca:	c4dfc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02035ce <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02035ce:	000a9797          	auipc	a5,0xa9
ffffffffc02035d2:	e4278793          	addi	a5,a5,-446 # ffffffffc02ac410 <sm>
ffffffffc02035d6:	639c                	ld	a5,0(a5)
ffffffffc02035d8:	0107b303          	ld	t1,16(a5)
ffffffffc02035dc:	8302                	jr	t1

ffffffffc02035de <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02035de:	000a9797          	auipc	a5,0xa9
ffffffffc02035e2:	e3278793          	addi	a5,a5,-462 # ffffffffc02ac410 <sm>
ffffffffc02035e6:	639c                	ld	a5,0(a5)
ffffffffc02035e8:	0207b303          	ld	t1,32(a5)
ffffffffc02035ec:	8302                	jr	t1

ffffffffc02035ee <swap_out>:
{
ffffffffc02035ee:	711d                	addi	sp,sp,-96
ffffffffc02035f0:	ec86                	sd	ra,88(sp)
ffffffffc02035f2:	e8a2                	sd	s0,80(sp)
ffffffffc02035f4:	e4a6                	sd	s1,72(sp)
ffffffffc02035f6:	e0ca                	sd	s2,64(sp)
ffffffffc02035f8:	fc4e                	sd	s3,56(sp)
ffffffffc02035fa:	f852                	sd	s4,48(sp)
ffffffffc02035fc:	f456                	sd	s5,40(sp)
ffffffffc02035fe:	f05a                	sd	s6,32(sp)
ffffffffc0203600:	ec5e                	sd	s7,24(sp)
ffffffffc0203602:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203604:	cde9                	beqz	a1,ffffffffc02036de <swap_out+0xf0>
ffffffffc0203606:	8ab2                	mv	s5,a2
ffffffffc0203608:	892a                	mv	s2,a0
ffffffffc020360a:	8a2e                	mv	s4,a1
ffffffffc020360c:	4401                	li	s0,0
ffffffffc020360e:	000a9997          	auipc	s3,0xa9
ffffffffc0203612:	e0298993          	addi	s3,s3,-510 # ffffffffc02ac410 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203616:	00004b17          	auipc	s6,0x4
ffffffffc020361a:	782b0b13          	addi	s6,s6,1922 # ffffffffc0207d98 <commands+0x15f0>
                    cprintf("SWAP: failed to save\n");
ffffffffc020361e:	00004b97          	auipc	s7,0x4
ffffffffc0203622:	762b8b93          	addi	s7,s7,1890 # ffffffffc0207d80 <commands+0x15d8>
ffffffffc0203626:	a825                	j	ffffffffc020365e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203628:	67a2                	ld	a5,8(sp)
ffffffffc020362a:	8626                	mv	a2,s1
ffffffffc020362c:	85a2                	mv	a1,s0
ffffffffc020362e:	7f94                	ld	a3,56(a5)
ffffffffc0203630:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203632:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203634:	82b1                	srli	a3,a3,0xc
ffffffffc0203636:	0685                	addi	a3,a3,1
ffffffffc0203638:	a99fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020363c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020363e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203640:	7d1c                	ld	a5,56(a0)
ffffffffc0203642:	83b1                	srli	a5,a5,0xc
ffffffffc0203644:	0785                	addi	a5,a5,1
ffffffffc0203646:	07a2                	slli	a5,a5,0x8
ffffffffc0203648:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020364c:	8affd0ef          	jal	ra,ffffffffc0200efa <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203650:	01893503          	ld	a0,24(s2)
ffffffffc0203654:	85a6                	mv	a1,s1
ffffffffc0203656:	cbdfe0ef          	jal	ra,ffffffffc0202312 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020365a:	048a0d63          	beq	s4,s0,ffffffffc02036b4 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020365e:	0009b783          	ld	a5,0(s3)
ffffffffc0203662:	8656                	mv	a2,s5
ffffffffc0203664:	002c                	addi	a1,sp,8
ffffffffc0203666:	7b9c                	ld	a5,48(a5)
ffffffffc0203668:	854a                	mv	a0,s2
ffffffffc020366a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020366c:	e12d                	bnez	a0,ffffffffc02036ce <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020366e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203670:	01893503          	ld	a0,24(s2)
ffffffffc0203674:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203676:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203678:	85a6                	mv	a1,s1
ffffffffc020367a:	907fd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020367e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203680:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203682:	8b85                	andi	a5,a5,1
ffffffffc0203684:	cfb9                	beqz	a5,ffffffffc02036e2 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203686:	65a2                	ld	a1,8(sp)
ffffffffc0203688:	7d9c                	ld	a5,56(a1)
ffffffffc020368a:	83b1                	srli	a5,a5,0xc
ffffffffc020368c:	00178513          	addi	a0,a5,1
ffffffffc0203690:	0522                	slli	a0,a0,0x8
ffffffffc0203692:	582010ef          	jal	ra,ffffffffc0204c14 <swapfs_write>
ffffffffc0203696:	d949                	beqz	a0,ffffffffc0203628 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203698:	855e                	mv	a0,s7
ffffffffc020369a:	a37fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020369e:	0009b783          	ld	a5,0(s3)
ffffffffc02036a2:	6622                	ld	a2,8(sp)
ffffffffc02036a4:	4681                	li	a3,0
ffffffffc02036a6:	739c                	ld	a5,32(a5)
ffffffffc02036a8:	85a6                	mv	a1,s1
ffffffffc02036aa:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02036ac:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02036ae:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02036b0:	fa8a17e3          	bne	s4,s0,ffffffffc020365e <swap_out+0x70>
}
ffffffffc02036b4:	8522                	mv	a0,s0
ffffffffc02036b6:	60e6                	ld	ra,88(sp)
ffffffffc02036b8:	6446                	ld	s0,80(sp)
ffffffffc02036ba:	64a6                	ld	s1,72(sp)
ffffffffc02036bc:	6906                	ld	s2,64(sp)
ffffffffc02036be:	79e2                	ld	s3,56(sp)
ffffffffc02036c0:	7a42                	ld	s4,48(sp)
ffffffffc02036c2:	7aa2                	ld	s5,40(sp)
ffffffffc02036c4:	7b02                	ld	s6,32(sp)
ffffffffc02036c6:	6be2                	ld	s7,24(sp)
ffffffffc02036c8:	6c42                	ld	s8,16(sp)
ffffffffc02036ca:	6125                	addi	sp,sp,96
ffffffffc02036cc:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02036ce:	85a2                	mv	a1,s0
ffffffffc02036d0:	00004517          	auipc	a0,0x4
ffffffffc02036d4:	66850513          	addi	a0,a0,1640 # ffffffffc0207d38 <commands+0x1590>
ffffffffc02036d8:	9f9fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc02036dc:	bfe1                	j	ffffffffc02036b4 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02036de:	4401                	li	s0,0
ffffffffc02036e0:	bfd1                	j	ffffffffc02036b4 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02036e2:	00004697          	auipc	a3,0x4
ffffffffc02036e6:	68668693          	addi	a3,a3,1670 # ffffffffc0207d68 <commands+0x15c0>
ffffffffc02036ea:	00003617          	auipc	a2,0x3
ffffffffc02036ee:	53e60613          	addi	a2,a2,1342 # ffffffffc0206c28 <commands+0x480>
ffffffffc02036f2:	06800593          	li	a1,104
ffffffffc02036f6:	00004517          	auipc	a0,0x4
ffffffffc02036fa:	3aa50513          	addi	a0,a0,938 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc02036fe:	b19fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203702 <swap_in>:
{
ffffffffc0203702:	7179                	addi	sp,sp,-48
ffffffffc0203704:	e84a                	sd	s2,16(sp)
ffffffffc0203706:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203708:	4505                	li	a0,1
{
ffffffffc020370a:	ec26                	sd	s1,24(sp)
ffffffffc020370c:	e44e                	sd	s3,8(sp)
ffffffffc020370e:	f406                	sd	ra,40(sp)
ffffffffc0203710:	f022                	sd	s0,32(sp)
ffffffffc0203712:	84ae                	mv	s1,a1
ffffffffc0203714:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203716:	f5cfd0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
     assert(result!=NULL);
ffffffffc020371a:	c129                	beqz	a0,ffffffffc020375c <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020371c:	842a                	mv	s0,a0
ffffffffc020371e:	01893503          	ld	a0,24(s2)
ffffffffc0203722:	4601                	li	a2,0
ffffffffc0203724:	85a6                	mv	a1,s1
ffffffffc0203726:	85bfd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc020372a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020372c:	6108                	ld	a0,0(a0)
ffffffffc020372e:	85a2                	mv	a1,s0
ffffffffc0203730:	44c010ef          	jal	ra,ffffffffc0204b7c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203734:	00093583          	ld	a1,0(s2)
ffffffffc0203738:	8626                	mv	a2,s1
ffffffffc020373a:	00004517          	auipc	a0,0x4
ffffffffc020373e:	30650513          	addi	a0,a0,774 # ffffffffc0207a40 <commands+0x1298>
ffffffffc0203742:	81a1                	srli	a1,a1,0x8
ffffffffc0203744:	98dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0203748:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020374a:	0089b023          	sd	s0,0(s3)
}
ffffffffc020374e:	7402                	ld	s0,32(sp)
ffffffffc0203750:	64e2                	ld	s1,24(sp)
ffffffffc0203752:	6942                	ld	s2,16(sp)
ffffffffc0203754:	69a2                	ld	s3,8(sp)
ffffffffc0203756:	4501                	li	a0,0
ffffffffc0203758:	6145                	addi	sp,sp,48
ffffffffc020375a:	8082                	ret
     assert(result!=NULL);
ffffffffc020375c:	00004697          	auipc	a3,0x4
ffffffffc0203760:	2d468693          	addi	a3,a3,724 # ffffffffc0207a30 <commands+0x1288>
ffffffffc0203764:	00003617          	auipc	a2,0x3
ffffffffc0203768:	4c460613          	addi	a2,a2,1220 # ffffffffc0206c28 <commands+0x480>
ffffffffc020376c:	07e00593          	li	a1,126
ffffffffc0203770:	00004517          	auipc	a0,0x4
ffffffffc0203774:	33050513          	addi	a0,a0,816 # ffffffffc0207aa0 <commands+0x12f8>
ffffffffc0203778:	a9ffc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020377c <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020377c:	c125                	beqz	a0,ffffffffc02037dc <slob_free+0x60>
		return;

	if (size)
ffffffffc020377e:	e1a5                	bnez	a1,ffffffffc02037de <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203780:	100027f3          	csrr	a5,sstatus
ffffffffc0203784:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203786:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203788:	e3bd                	bnez	a5,ffffffffc02037ee <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020378a:	0009e797          	auipc	a5,0x9e
ffffffffc020378e:	84e78793          	addi	a5,a5,-1970 # ffffffffc02a0fd8 <slobfree>
ffffffffc0203792:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203794:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203796:	00a7fa63          	bleu	a0,a5,ffffffffc02037aa <slob_free+0x2e>
ffffffffc020379a:	00e56c63          	bltu	a0,a4,ffffffffc02037b2 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020379e:	00e7fa63          	bleu	a4,a5,ffffffffc02037b2 <slob_free+0x36>
    return 0;
ffffffffc02037a2:	87ba                	mv	a5,a4
ffffffffc02037a4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037a6:	fea7eae3          	bltu	a5,a0,ffffffffc020379a <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02037aa:	fee7ece3          	bltu	a5,a4,ffffffffc02037a2 <slob_free+0x26>
ffffffffc02037ae:	fee57ae3          	bleu	a4,a0,ffffffffc02037a2 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02037b2:	4110                	lw	a2,0(a0)
ffffffffc02037b4:	00461693          	slli	a3,a2,0x4
ffffffffc02037b8:	96aa                	add	a3,a3,a0
ffffffffc02037ba:	08d70b63          	beq	a4,a3,ffffffffc0203850 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02037be:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02037c0:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02037c2:	00469713          	slli	a4,a3,0x4
ffffffffc02037c6:	973e                	add	a4,a4,a5
ffffffffc02037c8:	08e50f63          	beq	a0,a4,ffffffffc0203866 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02037cc:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02037ce:	0009e717          	auipc	a4,0x9e
ffffffffc02037d2:	80f73523          	sd	a5,-2038(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc02037d6:	c199                	beqz	a1,ffffffffc02037dc <slob_free+0x60>
        intr_enable();
ffffffffc02037d8:	e7ffc06f          	j	ffffffffc0200656 <intr_enable>
ffffffffc02037dc:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02037de:	05bd                	addi	a1,a1,15
ffffffffc02037e0:	8191                	srli	a1,a1,0x4
ffffffffc02037e2:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037e4:	100027f3          	csrr	a5,sstatus
ffffffffc02037e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02037ea:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037ec:	dfd9                	beqz	a5,ffffffffc020378a <slob_free+0xe>
{
ffffffffc02037ee:	1101                	addi	sp,sp,-32
ffffffffc02037f0:	e42a                	sd	a0,8(sp)
ffffffffc02037f2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02037f4:	e69fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037f8:	0009d797          	auipc	a5,0x9d
ffffffffc02037fc:	7e078793          	addi	a5,a5,2016 # ffffffffc02a0fd8 <slobfree>
ffffffffc0203800:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0203802:	6522                	ld	a0,8(sp)
ffffffffc0203804:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203806:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203808:	00a7fa63          	bleu	a0,a5,ffffffffc020381c <slob_free+0xa0>
ffffffffc020380c:	00e56c63          	bltu	a0,a4,ffffffffc0203824 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203810:	00e7fa63          	bleu	a4,a5,ffffffffc0203824 <slob_free+0xa8>
    return 0;
ffffffffc0203814:	87ba                	mv	a5,a4
ffffffffc0203816:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203818:	fea7eae3          	bltu	a5,a0,ffffffffc020380c <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020381c:	fee7ece3          	bltu	a5,a4,ffffffffc0203814 <slob_free+0x98>
ffffffffc0203820:	fee57ae3          	bleu	a4,a0,ffffffffc0203814 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0203824:	4110                	lw	a2,0(a0)
ffffffffc0203826:	00461693          	slli	a3,a2,0x4
ffffffffc020382a:	96aa                	add	a3,a3,a0
ffffffffc020382c:	04d70763          	beq	a4,a3,ffffffffc020387a <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0203830:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203832:	4394                	lw	a3,0(a5)
ffffffffc0203834:	00469713          	slli	a4,a3,0x4
ffffffffc0203838:	973e                	add	a4,a4,a5
ffffffffc020383a:	04e50663          	beq	a0,a4,ffffffffc0203886 <slob_free+0x10a>
		cur->next = b;
ffffffffc020383e:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0203840:	0009d717          	auipc	a4,0x9d
ffffffffc0203844:	78f73c23          	sd	a5,1944(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc0203848:	e58d                	bnez	a1,ffffffffc0203872 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020384a:	60e2                	ld	ra,24(sp)
ffffffffc020384c:	6105                	addi	sp,sp,32
ffffffffc020384e:	8082                	ret
		b->units += cur->next->units;
ffffffffc0203850:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203852:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0203854:	9e35                	addw	a2,a2,a3
ffffffffc0203856:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0203858:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020385a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020385c:	00469713          	slli	a4,a3,0x4
ffffffffc0203860:	973e                	add	a4,a4,a5
ffffffffc0203862:	f6e515e3          	bne	a0,a4,ffffffffc02037cc <slob_free+0x50>
		cur->units += b->units;
ffffffffc0203866:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203868:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc020386a:	9eb9                	addw	a3,a3,a4
ffffffffc020386c:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020386e:	e790                	sd	a2,8(a5)
ffffffffc0203870:	bfb9                	j	ffffffffc02037ce <slob_free+0x52>
}
ffffffffc0203872:	60e2                	ld	ra,24(sp)
ffffffffc0203874:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203876:	de1fc06f          	j	ffffffffc0200656 <intr_enable>
		b->units += cur->next->units;
ffffffffc020387a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020387c:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020387e:	9e35                	addw	a2,a2,a3
ffffffffc0203880:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0203882:	e518                	sd	a4,8(a0)
ffffffffc0203884:	b77d                	j	ffffffffc0203832 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0203886:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203888:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc020388a:	9eb9                	addw	a3,a3,a4
ffffffffc020388c:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020388e:	e790                	sd	a2,8(a5)
ffffffffc0203890:	bf45                	j	ffffffffc0203840 <slob_free+0xc4>

ffffffffc0203892 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203892:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203894:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203896:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020389a:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020389c:	dd6fd0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
  if(!page)
ffffffffc02038a0:	c139                	beqz	a0,ffffffffc02038e6 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc02038a2:	000a9797          	auipc	a5,0xa9
ffffffffc02038a6:	bc678793          	addi	a5,a5,-1082 # ffffffffc02ac468 <pages>
ffffffffc02038aa:	6394                	ld	a3,0(a5)
ffffffffc02038ac:	00005797          	auipc	a5,0x5
ffffffffc02038b0:	47c78793          	addi	a5,a5,1148 # ffffffffc0208d28 <nbase>
    return KADDR(page2pa(page));
ffffffffc02038b4:	000a9717          	auipc	a4,0xa9
ffffffffc02038b8:	b4c70713          	addi	a4,a4,-1204 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc02038bc:	40d506b3          	sub	a3,a0,a3
ffffffffc02038c0:	6388                	ld	a0,0(a5)
ffffffffc02038c2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02038c4:	57fd                	li	a5,-1
ffffffffc02038c6:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02038c8:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02038ca:	83b1                	srli	a5,a5,0xc
ffffffffc02038cc:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02038ce:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02038d0:	00e7ff63          	bleu	a4,a5,ffffffffc02038ee <__slob_get_free_pages.isra.0+0x5c>
ffffffffc02038d4:	000a9797          	auipc	a5,0xa9
ffffffffc02038d8:	b8478793          	addi	a5,a5,-1148 # ffffffffc02ac458 <va_pa_offset>
ffffffffc02038dc:	6388                	ld	a0,0(a5)
}
ffffffffc02038de:	60a2                	ld	ra,8(sp)
ffffffffc02038e0:	9536                	add	a0,a0,a3
ffffffffc02038e2:	0141                	addi	sp,sp,16
ffffffffc02038e4:	8082                	ret
ffffffffc02038e6:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc02038e8:	4501                	li	a0,0
}
ffffffffc02038ea:	0141                	addi	sp,sp,16
ffffffffc02038ec:	8082                	ret
ffffffffc02038ee:	00003617          	auipc	a2,0x3
ffffffffc02038f2:	72260613          	addi	a2,a2,1826 # ffffffffc0207010 <commands+0x868>
ffffffffc02038f6:	06900593          	li	a1,105
ffffffffc02038fa:	00003517          	auipc	a0,0x3
ffffffffc02038fe:	76e50513          	addi	a0,a0,1902 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0203902:	915fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203906 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0203906:	7179                	addi	sp,sp,-48
ffffffffc0203908:	f406                	sd	ra,40(sp)
ffffffffc020390a:	f022                	sd	s0,32(sp)
ffffffffc020390c:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020390e:	01050713          	addi	a4,a0,16
ffffffffc0203912:	6785                	lui	a5,0x1
ffffffffc0203914:	0cf77b63          	bleu	a5,a4,ffffffffc02039ea <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0203918:	00f50413          	addi	s0,a0,15
ffffffffc020391c:	8011                	srli	s0,s0,0x4
ffffffffc020391e:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203920:	10002673          	csrr	a2,sstatus
ffffffffc0203924:	8a09                	andi	a2,a2,2
ffffffffc0203926:	ea5d                	bnez	a2,ffffffffc02039dc <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0203928:	0009d497          	auipc	s1,0x9d
ffffffffc020392c:	6b048493          	addi	s1,s1,1712 # ffffffffc02a0fd8 <slobfree>
ffffffffc0203930:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203932:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203934:	4398                	lw	a4,0(a5)
ffffffffc0203936:	0a875763          	ble	s0,a4,ffffffffc02039e4 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc020393a:	00f68a63          	beq	a3,a5,ffffffffc020394e <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020393e:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203940:	4118                	lw	a4,0(a0)
ffffffffc0203942:	02875763          	ble	s0,a4,ffffffffc0203970 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0203946:	6094                	ld	a3,0(s1)
ffffffffc0203948:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc020394a:	fef69ae3          	bne	a3,a5,ffffffffc020393e <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc020394e:	ea39                	bnez	a2,ffffffffc02039a4 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203950:	4501                	li	a0,0
ffffffffc0203952:	f41ff0ef          	jal	ra,ffffffffc0203892 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0203956:	cd29                	beqz	a0,ffffffffc02039b0 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203958:	6585                	lui	a1,0x1
ffffffffc020395a:	e23ff0ef          	jal	ra,ffffffffc020377c <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020395e:	10002673          	csrr	a2,sstatus
ffffffffc0203962:	8a09                	andi	a2,a2,2
ffffffffc0203964:	ea1d                	bnez	a2,ffffffffc020399a <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0203966:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203968:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020396a:	4118                	lw	a4,0(a0)
ffffffffc020396c:	fc874de3          	blt	a4,s0,ffffffffc0203946 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0203970:	04e40663          	beq	s0,a4,ffffffffc02039bc <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0203974:	00441693          	slli	a3,s0,0x4
ffffffffc0203978:	96aa                	add	a3,a3,a0
ffffffffc020397a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc020397c:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc020397e:	9f01                	subw	a4,a4,s0
ffffffffc0203980:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0203982:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0203984:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0203986:	0009d717          	auipc	a4,0x9d
ffffffffc020398a:	64f73923          	sd	a5,1618(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc020398e:	ee15                	bnez	a2,ffffffffc02039ca <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0203990:	70a2                	ld	ra,40(sp)
ffffffffc0203992:	7402                	ld	s0,32(sp)
ffffffffc0203994:	64e2                	ld	s1,24(sp)
ffffffffc0203996:	6145                	addi	sp,sp,48
ffffffffc0203998:	8082                	ret
        intr_disable();
ffffffffc020399a:	cc3fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc020399e:	4605                	li	a2,1
			cur = slobfree;
ffffffffc02039a0:	609c                	ld	a5,0(s1)
ffffffffc02039a2:	b7d9                	j	ffffffffc0203968 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc02039a4:	cb3fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02039a8:	4501                	li	a0,0
ffffffffc02039aa:	ee9ff0ef          	jal	ra,ffffffffc0203892 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02039ae:	f54d                	bnez	a0,ffffffffc0203958 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc02039b0:	70a2                	ld	ra,40(sp)
ffffffffc02039b2:	7402                	ld	s0,32(sp)
ffffffffc02039b4:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc02039b6:	4501                	li	a0,0
}
ffffffffc02039b8:	6145                	addi	sp,sp,48
ffffffffc02039ba:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02039bc:	6518                	ld	a4,8(a0)
ffffffffc02039be:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc02039c0:	0009d717          	auipc	a4,0x9d
ffffffffc02039c4:	60f73c23          	sd	a5,1560(a4) # ffffffffc02a0fd8 <slobfree>
    if (flag) {
ffffffffc02039c8:	d661                	beqz	a2,ffffffffc0203990 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc02039ca:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02039cc:	c8bfc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc02039d0:	70a2                	ld	ra,40(sp)
ffffffffc02039d2:	7402                	ld	s0,32(sp)
ffffffffc02039d4:	6522                	ld	a0,8(sp)
ffffffffc02039d6:	64e2                	ld	s1,24(sp)
ffffffffc02039d8:	6145                	addi	sp,sp,48
ffffffffc02039da:	8082                	ret
        intr_disable();
ffffffffc02039dc:	c81fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc02039e0:	4605                	li	a2,1
ffffffffc02039e2:	b799                	j	ffffffffc0203928 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02039e4:	853e                	mv	a0,a5
ffffffffc02039e6:	87b6                	mv	a5,a3
ffffffffc02039e8:	b761                	j	ffffffffc0203970 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02039ea:	00004697          	auipc	a3,0x4
ffffffffc02039ee:	40e68693          	addi	a3,a3,1038 # ffffffffc0207df8 <commands+0x1650>
ffffffffc02039f2:	00003617          	auipc	a2,0x3
ffffffffc02039f6:	23660613          	addi	a2,a2,566 # ffffffffc0206c28 <commands+0x480>
ffffffffc02039fa:	06400593          	li	a1,100
ffffffffc02039fe:	00004517          	auipc	a0,0x4
ffffffffc0203a02:	41a50513          	addi	a0,a0,1050 # ffffffffc0207e18 <commands+0x1670>
ffffffffc0203a06:	811fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203a0a <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0203a0a:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203a0c:	00004517          	auipc	a0,0x4
ffffffffc0203a10:	42450513          	addi	a0,a0,1060 # ffffffffc0207e30 <commands+0x1688>
kmalloc_init(void) {
ffffffffc0203a14:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0203a16:	ebafc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203a1a:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203a1c:	00004517          	auipc	a0,0x4
ffffffffc0203a20:	3bc50513          	addi	a0,a0,956 # ffffffffc0207dd8 <commands+0x1630>
}
ffffffffc0203a24:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203a26:	eaafc06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0203a2a <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0203a2a:	4501                	li	a0,0
ffffffffc0203a2c:	8082                	ret

ffffffffc0203a2e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203a2e:	1101                	addi	sp,sp,-32
ffffffffc0203a30:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a32:	6905                	lui	s2,0x1
{
ffffffffc0203a34:	e822                	sd	s0,16(sp)
ffffffffc0203a36:	ec06                	sd	ra,24(sp)
ffffffffc0203a38:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a3a:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8581>
{
ffffffffc0203a3e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a40:	04a7fc63          	bleu	a0,a5,ffffffffc0203a98 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0203a44:	4561                	li	a0,24
ffffffffc0203a46:	ec1ff0ef          	jal	ra,ffffffffc0203906 <slob_alloc.isra.1.constprop.3>
ffffffffc0203a4a:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0203a4c:	cd21                	beqz	a0,ffffffffc0203aa4 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0203a4e:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0203a52:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203a54:	00f95763          	ble	a5,s2,ffffffffc0203a62 <kmalloc+0x34>
ffffffffc0203a58:	6705                	lui	a4,0x1
ffffffffc0203a5a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0203a5c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203a5e:	fef74ee3          	blt	a4,a5,ffffffffc0203a5a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0203a62:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0203a64:	e2fff0ef          	jal	ra,ffffffffc0203892 <__slob_get_free_pages.isra.0>
ffffffffc0203a68:	e488                	sd	a0,8(s1)
ffffffffc0203a6a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203a6c:	c935                	beqz	a0,ffffffffc0203ae0 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a6e:	100027f3          	csrr	a5,sstatus
ffffffffc0203a72:	8b89                	andi	a5,a5,2
ffffffffc0203a74:	e3a1                	bnez	a5,ffffffffc0203ab4 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0203a76:	000a9797          	auipc	a5,0xa9
ffffffffc0203a7a:	9aa78793          	addi	a5,a5,-1622 # ffffffffc02ac420 <bigblocks>
ffffffffc0203a7e:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203a80:	000a9717          	auipc	a4,0xa9
ffffffffc0203a84:	9a973023          	sd	s1,-1632(a4) # ffffffffc02ac420 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203a88:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203a8a:	8522                	mv	a0,s0
ffffffffc0203a8c:	60e2                	ld	ra,24(sp)
ffffffffc0203a8e:	6442                	ld	s0,16(sp)
ffffffffc0203a90:	64a2                	ld	s1,8(sp)
ffffffffc0203a92:	6902                	ld	s2,0(sp)
ffffffffc0203a94:	6105                	addi	sp,sp,32
ffffffffc0203a96:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203a98:	0541                	addi	a0,a0,16
ffffffffc0203a9a:	e6dff0ef          	jal	ra,ffffffffc0203906 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203a9e:	01050413          	addi	s0,a0,16
ffffffffc0203aa2:	f565                	bnez	a0,ffffffffc0203a8a <kmalloc+0x5c>
ffffffffc0203aa4:	4401                	li	s0,0
}
ffffffffc0203aa6:	8522                	mv	a0,s0
ffffffffc0203aa8:	60e2                	ld	ra,24(sp)
ffffffffc0203aaa:	6442                	ld	s0,16(sp)
ffffffffc0203aac:	64a2                	ld	s1,8(sp)
ffffffffc0203aae:	6902                	ld	s2,0(sp)
ffffffffc0203ab0:	6105                	addi	sp,sp,32
ffffffffc0203ab2:	8082                	ret
        intr_disable();
ffffffffc0203ab4:	ba9fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
		bb->next = bigblocks;
ffffffffc0203ab8:	000a9797          	auipc	a5,0xa9
ffffffffc0203abc:	96878793          	addi	a5,a5,-1688 # ffffffffc02ac420 <bigblocks>
ffffffffc0203ac0:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203ac2:	000a9717          	auipc	a4,0xa9
ffffffffc0203ac6:	94973f23          	sd	s1,-1698(a4) # ffffffffc02ac420 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203aca:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0203acc:	b8bfc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203ad0:	6480                	ld	s0,8(s1)
}
ffffffffc0203ad2:	60e2                	ld	ra,24(sp)
ffffffffc0203ad4:	64a2                	ld	s1,8(sp)
ffffffffc0203ad6:	8522                	mv	a0,s0
ffffffffc0203ad8:	6442                	ld	s0,16(sp)
ffffffffc0203ada:	6902                	ld	s2,0(sp)
ffffffffc0203adc:	6105                	addi	sp,sp,32
ffffffffc0203ade:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203ae0:	45e1                	li	a1,24
ffffffffc0203ae2:	8526                	mv	a0,s1
ffffffffc0203ae4:	c99ff0ef          	jal	ra,ffffffffc020377c <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203ae8:	b74d                	j	ffffffffc0203a8a <kmalloc+0x5c>

ffffffffc0203aea <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203aea:	c175                	beqz	a0,ffffffffc0203bce <kfree+0xe4>
{
ffffffffc0203aec:	1101                	addi	sp,sp,-32
ffffffffc0203aee:	e426                	sd	s1,8(sp)
ffffffffc0203af0:	ec06                	sd	ra,24(sp)
ffffffffc0203af2:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203af4:	03451793          	slli	a5,a0,0x34
ffffffffc0203af8:	84aa                	mv	s1,a0
ffffffffc0203afa:	eb8d                	bnez	a5,ffffffffc0203b2c <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203afc:	100027f3          	csrr	a5,sstatus
ffffffffc0203b00:	8b89                	andi	a5,a5,2
ffffffffc0203b02:	efc9                	bnez	a5,ffffffffc0203b9c <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203b04:	000a9797          	auipc	a5,0xa9
ffffffffc0203b08:	91c78793          	addi	a5,a5,-1764 # ffffffffc02ac420 <bigblocks>
ffffffffc0203b0c:	6394                	ld	a3,0(a5)
ffffffffc0203b0e:	ce99                	beqz	a3,ffffffffc0203b2c <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0203b10:	669c                	ld	a5,8(a3)
ffffffffc0203b12:	6a80                	ld	s0,16(a3)
ffffffffc0203b14:	0af50e63          	beq	a0,a5,ffffffffc0203bd0 <kfree+0xe6>
    return 0;
ffffffffc0203b18:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203b1a:	c801                	beqz	s0,ffffffffc0203b2a <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0203b1c:	6418                	ld	a4,8(s0)
ffffffffc0203b1e:	681c                	ld	a5,16(s0)
ffffffffc0203b20:	00970f63          	beq	a4,s1,ffffffffc0203b3e <kfree+0x54>
ffffffffc0203b24:	86a2                	mv	a3,s0
ffffffffc0203b26:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203b28:	f875                	bnez	s0,ffffffffc0203b1c <kfree+0x32>
    if (flag) {
ffffffffc0203b2a:	e659                	bnez	a2,ffffffffc0203bb8 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0203b2c:	6442                	ld	s0,16(sp)
ffffffffc0203b2e:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b30:	ff048513          	addi	a0,s1,-16
}
ffffffffc0203b34:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b36:	4581                	li	a1,0
}
ffffffffc0203b38:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b3a:	c43ff06f          	j	ffffffffc020377c <slob_free>
				*last = bb->next;
ffffffffc0203b3e:	ea9c                	sd	a5,16(a3)
ffffffffc0203b40:	e641                	bnez	a2,ffffffffc0203bc8 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0203b42:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0203b46:	4018                	lw	a4,0(s0)
ffffffffc0203b48:	08f4ea63          	bltu	s1,a5,ffffffffc0203bdc <kfree+0xf2>
ffffffffc0203b4c:	000a9797          	auipc	a5,0xa9
ffffffffc0203b50:	90c78793          	addi	a5,a5,-1780 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0203b54:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b56:	000a9797          	auipc	a5,0xa9
ffffffffc0203b5a:	8aa78793          	addi	a5,a5,-1878 # ffffffffc02ac400 <npage>
ffffffffc0203b5e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0203b60:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0203b62:	80b1                	srli	s1,s1,0xc
ffffffffc0203b64:	08f4f963          	bleu	a5,s1,ffffffffc0203bf6 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b68:	00005797          	auipc	a5,0x5
ffffffffc0203b6c:	1c078793          	addi	a5,a5,448 # ffffffffc0208d28 <nbase>
ffffffffc0203b70:	639c                	ld	a5,0(a5)
ffffffffc0203b72:	000a9697          	auipc	a3,0xa9
ffffffffc0203b76:	8f668693          	addi	a3,a3,-1802 # ffffffffc02ac468 <pages>
ffffffffc0203b7a:	6288                	ld	a0,0(a3)
ffffffffc0203b7c:	8c9d                	sub	s1,s1,a5
ffffffffc0203b7e:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0203b80:	4585                	li	a1,1
ffffffffc0203b82:	9526                	add	a0,a0,s1
ffffffffc0203b84:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203b88:	b72fd0ef          	jal	ra,ffffffffc0200efa <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203b8c:	8522                	mv	a0,s0
}
ffffffffc0203b8e:	6442                	ld	s0,16(sp)
ffffffffc0203b90:	60e2                	ld	ra,24(sp)
ffffffffc0203b92:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203b94:	45e1                	li	a1,24
}
ffffffffc0203b96:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b98:	be5ff06f          	j	ffffffffc020377c <slob_free>
        intr_disable();
ffffffffc0203b9c:	ac1fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203ba0:	000a9797          	auipc	a5,0xa9
ffffffffc0203ba4:	88078793          	addi	a5,a5,-1920 # ffffffffc02ac420 <bigblocks>
ffffffffc0203ba8:	6394                	ld	a3,0(a5)
ffffffffc0203baa:	c699                	beqz	a3,ffffffffc0203bb8 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0203bac:	669c                	ld	a5,8(a3)
ffffffffc0203bae:	6a80                	ld	s0,16(a3)
ffffffffc0203bb0:	00f48763          	beq	s1,a5,ffffffffc0203bbe <kfree+0xd4>
        return 1;
ffffffffc0203bb4:	4605                	li	a2,1
ffffffffc0203bb6:	b795                	j	ffffffffc0203b1a <kfree+0x30>
        intr_enable();
ffffffffc0203bb8:	a9ffc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203bbc:	bf85                	j	ffffffffc0203b2c <kfree+0x42>
				*last = bb->next;
ffffffffc0203bbe:	000a9797          	auipc	a5,0xa9
ffffffffc0203bc2:	8687b123          	sd	s0,-1950(a5) # ffffffffc02ac420 <bigblocks>
ffffffffc0203bc6:	8436                	mv	s0,a3
ffffffffc0203bc8:	a8ffc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203bcc:	bf9d                	j	ffffffffc0203b42 <kfree+0x58>
ffffffffc0203bce:	8082                	ret
ffffffffc0203bd0:	000a9797          	auipc	a5,0xa9
ffffffffc0203bd4:	8487b823          	sd	s0,-1968(a5) # ffffffffc02ac420 <bigblocks>
ffffffffc0203bd8:	8436                	mv	s0,a3
ffffffffc0203bda:	b7a5                	j	ffffffffc0203b42 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0203bdc:	86a6                	mv	a3,s1
ffffffffc0203bde:	00003617          	auipc	a2,0x3
ffffffffc0203be2:	50a60613          	addi	a2,a2,1290 # ffffffffc02070e8 <commands+0x940>
ffffffffc0203be6:	06e00593          	li	a1,110
ffffffffc0203bea:	00003517          	auipc	a0,0x3
ffffffffc0203bee:	47e50513          	addi	a0,a0,1150 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0203bf2:	e24fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203bf6:	00003617          	auipc	a2,0x3
ffffffffc0203bfa:	45260613          	addi	a2,a2,1106 # ffffffffc0207048 <commands+0x8a0>
ffffffffc0203bfe:	06200593          	li	a1,98
ffffffffc0203c02:	00003517          	auipc	a0,0x3
ffffffffc0203c06:	46650513          	addi	a0,a0,1126 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0203c0a:	e0cfc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203c0e <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203c0e:	000a9797          	auipc	a5,0xa9
ffffffffc0203c12:	93278793          	addi	a5,a5,-1742 # ffffffffc02ac540 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203c16:	f51c                	sd	a5,40(a0)
ffffffffc0203c18:	e79c                	sd	a5,8(a5)
ffffffffc0203c1a:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203c1c:	4501                	li	a0,0
ffffffffc0203c1e:	8082                	ret

ffffffffc0203c20 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203c20:	4501                	li	a0,0
ffffffffc0203c22:	8082                	ret

ffffffffc0203c24 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203c24:	4501                	li	a0,0
ffffffffc0203c26:	8082                	ret

ffffffffc0203c28 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203c28:	4501                	li	a0,0
ffffffffc0203c2a:	8082                	ret

ffffffffc0203c2c <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203c2c:	711d                	addi	sp,sp,-96
ffffffffc0203c2e:	fc4e                	sd	s3,56(sp)
ffffffffc0203c30:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c32:	00004517          	auipc	a0,0x4
ffffffffc0203c36:	21650513          	addi	a0,a0,534 # ffffffffc0207e48 <commands+0x16a0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c3a:	698d                	lui	s3,0x3
ffffffffc0203c3c:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203c3e:	e8a2                	sd	s0,80(sp)
ffffffffc0203c40:	e4a6                	sd	s1,72(sp)
ffffffffc0203c42:	ec86                	sd	ra,88(sp)
ffffffffc0203c44:	e0ca                	sd	s2,64(sp)
ffffffffc0203c46:	f456                	sd	s5,40(sp)
ffffffffc0203c48:	f05a                	sd	s6,32(sp)
ffffffffc0203c4a:	ec5e                	sd	s7,24(sp)
ffffffffc0203c4c:	e862                	sd	s8,16(sp)
ffffffffc0203c4e:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203c50:	000a8417          	auipc	s0,0xa8
ffffffffc0203c54:	7b840413          	addi	s0,s0,1976 # ffffffffc02ac408 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c58:	c78fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c5c:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
    assert(pgfault_num==4);
ffffffffc0203c60:	4004                	lw	s1,0(s0)
ffffffffc0203c62:	4791                	li	a5,4
ffffffffc0203c64:	2481                	sext.w	s1,s1
ffffffffc0203c66:	14f49963          	bne	s1,a5,ffffffffc0203db8 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c6a:	00004517          	auipc	a0,0x4
ffffffffc0203c6e:	21e50513          	addi	a0,a0,542 # ffffffffc0207e88 <commands+0x16e0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c72:	6a85                	lui	s5,0x1
ffffffffc0203c74:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c76:	c5afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c7a:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
    assert(pgfault_num==4);
ffffffffc0203c7e:	00042903          	lw	s2,0(s0)
ffffffffc0203c82:	2901                	sext.w	s2,s2
ffffffffc0203c84:	2a991a63          	bne	s2,s1,ffffffffc0203f38 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c88:	00004517          	auipc	a0,0x4
ffffffffc0203c8c:	22850513          	addi	a0,a0,552 # ffffffffc0207eb0 <commands+0x1708>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c90:	6b91                	lui	s7,0x4
ffffffffc0203c92:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c94:	c3cfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c98:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
    assert(pgfault_num==4);
ffffffffc0203c9c:	4004                	lw	s1,0(s0)
ffffffffc0203c9e:	2481                	sext.w	s1,s1
ffffffffc0203ca0:	27249c63          	bne	s1,s2,ffffffffc0203f18 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ca4:	00004517          	auipc	a0,0x4
ffffffffc0203ca8:	23450513          	addi	a0,a0,564 # ffffffffc0207ed8 <commands+0x1730>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cac:	6909                	lui	s2,0x2
ffffffffc0203cae:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cb0:	c20fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cb4:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
    assert(pgfault_num==4);
ffffffffc0203cb8:	401c                	lw	a5,0(s0)
ffffffffc0203cba:	2781                	sext.w	a5,a5
ffffffffc0203cbc:	22979e63          	bne	a5,s1,ffffffffc0203ef8 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203cc0:	00004517          	auipc	a0,0x4
ffffffffc0203cc4:	24050513          	addi	a0,a0,576 # ffffffffc0207f00 <commands+0x1758>
ffffffffc0203cc8:	c08fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203ccc:	6795                	lui	a5,0x5
ffffffffc0203cce:	4739                	li	a4,14
ffffffffc0203cd0:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==5);
ffffffffc0203cd4:	4004                	lw	s1,0(s0)
ffffffffc0203cd6:	4795                	li	a5,5
ffffffffc0203cd8:	2481                	sext.w	s1,s1
ffffffffc0203cda:	1ef49f63          	bne	s1,a5,ffffffffc0203ed8 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cde:	00004517          	auipc	a0,0x4
ffffffffc0203ce2:	1fa50513          	addi	a0,a0,506 # ffffffffc0207ed8 <commands+0x1730>
ffffffffc0203ce6:	beafc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cea:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203cee:	401c                	lw	a5,0(s0)
ffffffffc0203cf0:	2781                	sext.w	a5,a5
ffffffffc0203cf2:	1c979363          	bne	a5,s1,ffffffffc0203eb8 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203cf6:	00004517          	auipc	a0,0x4
ffffffffc0203cfa:	19250513          	addi	a0,a0,402 # ffffffffc0207e88 <commands+0x16e0>
ffffffffc0203cfe:	bd2fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d02:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203d06:	401c                	lw	a5,0(s0)
ffffffffc0203d08:	4719                	li	a4,6
ffffffffc0203d0a:	2781                	sext.w	a5,a5
ffffffffc0203d0c:	18e79663          	bne	a5,a4,ffffffffc0203e98 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d10:	00004517          	auipc	a0,0x4
ffffffffc0203d14:	1c850513          	addi	a0,a0,456 # ffffffffc0207ed8 <commands+0x1730>
ffffffffc0203d18:	bb8fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d1c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203d20:	401c                	lw	a5,0(s0)
ffffffffc0203d22:	471d                	li	a4,7
ffffffffc0203d24:	2781                	sext.w	a5,a5
ffffffffc0203d26:	14e79963          	bne	a5,a4,ffffffffc0203e78 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d2a:	00004517          	auipc	a0,0x4
ffffffffc0203d2e:	11e50513          	addi	a0,a0,286 # ffffffffc0207e48 <commands+0x16a0>
ffffffffc0203d32:	b9efc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d36:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203d3a:	401c                	lw	a5,0(s0)
ffffffffc0203d3c:	4721                	li	a4,8
ffffffffc0203d3e:	2781                	sext.w	a5,a5
ffffffffc0203d40:	10e79c63          	bne	a5,a4,ffffffffc0203e58 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d44:	00004517          	auipc	a0,0x4
ffffffffc0203d48:	16c50513          	addi	a0,a0,364 # ffffffffc0207eb0 <commands+0x1708>
ffffffffc0203d4c:	b84fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d50:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d54:	401c                	lw	a5,0(s0)
ffffffffc0203d56:	4725                	li	a4,9
ffffffffc0203d58:	2781                	sext.w	a5,a5
ffffffffc0203d5a:	0ce79f63          	bne	a5,a4,ffffffffc0203e38 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d5e:	00004517          	auipc	a0,0x4
ffffffffc0203d62:	1a250513          	addi	a0,a0,418 # ffffffffc0207f00 <commands+0x1758>
ffffffffc0203d66:	b6afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d6a:	6795                	lui	a5,0x5
ffffffffc0203d6c:	4739                	li	a4,14
ffffffffc0203d6e:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==10);
ffffffffc0203d72:	4004                	lw	s1,0(s0)
ffffffffc0203d74:	47a9                	li	a5,10
ffffffffc0203d76:	2481                	sext.w	s1,s1
ffffffffc0203d78:	0af49063          	bne	s1,a5,ffffffffc0203e18 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d7c:	00004517          	auipc	a0,0x4
ffffffffc0203d80:	10c50513          	addi	a0,a0,268 # ffffffffc0207e88 <commands+0x16e0>
ffffffffc0203d84:	b4cfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d88:	6785                	lui	a5,0x1
ffffffffc0203d8a:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0203d8e:	06979563          	bne	a5,s1,ffffffffc0203df8 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203d92:	401c                	lw	a5,0(s0)
ffffffffc0203d94:	472d                	li	a4,11
ffffffffc0203d96:	2781                	sext.w	a5,a5
ffffffffc0203d98:	04e79063          	bne	a5,a4,ffffffffc0203dd8 <_fifo_check_swap+0x1ac>
}
ffffffffc0203d9c:	60e6                	ld	ra,88(sp)
ffffffffc0203d9e:	6446                	ld	s0,80(sp)
ffffffffc0203da0:	64a6                	ld	s1,72(sp)
ffffffffc0203da2:	6906                	ld	s2,64(sp)
ffffffffc0203da4:	79e2                	ld	s3,56(sp)
ffffffffc0203da6:	7a42                	ld	s4,48(sp)
ffffffffc0203da8:	7aa2                	ld	s5,40(sp)
ffffffffc0203daa:	7b02                	ld	s6,32(sp)
ffffffffc0203dac:	6be2                	ld	s7,24(sp)
ffffffffc0203dae:	6c42                	ld	s8,16(sp)
ffffffffc0203db0:	6ca2                	ld	s9,8(sp)
ffffffffc0203db2:	4501                	li	a0,0
ffffffffc0203db4:	6125                	addi	sp,sp,96
ffffffffc0203db6:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203db8:	00004697          	auipc	a3,0x4
ffffffffc0203dbc:	eb068693          	addi	a3,a3,-336 # ffffffffc0207c68 <commands+0x14c0>
ffffffffc0203dc0:	00003617          	auipc	a2,0x3
ffffffffc0203dc4:	e6860613          	addi	a2,a2,-408 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203dc8:	05100593          	li	a1,81
ffffffffc0203dcc:	00004517          	auipc	a0,0x4
ffffffffc0203dd0:	0a450513          	addi	a0,a0,164 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203dd4:	c42fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==11);
ffffffffc0203dd8:	00004697          	auipc	a3,0x4
ffffffffc0203ddc:	1d868693          	addi	a3,a3,472 # ffffffffc0207fb0 <commands+0x1808>
ffffffffc0203de0:	00003617          	auipc	a2,0x3
ffffffffc0203de4:	e4860613          	addi	a2,a2,-440 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203de8:	07300593          	li	a1,115
ffffffffc0203dec:	00004517          	auipc	a0,0x4
ffffffffc0203df0:	08450513          	addi	a0,a0,132 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203df4:	c22fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203df8:	00004697          	auipc	a3,0x4
ffffffffc0203dfc:	19068693          	addi	a3,a3,400 # ffffffffc0207f88 <commands+0x17e0>
ffffffffc0203e00:	00003617          	auipc	a2,0x3
ffffffffc0203e04:	e2860613          	addi	a2,a2,-472 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203e08:	07100593          	li	a1,113
ffffffffc0203e0c:	00004517          	auipc	a0,0x4
ffffffffc0203e10:	06450513          	addi	a0,a0,100 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203e14:	c02fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==10);
ffffffffc0203e18:	00004697          	auipc	a3,0x4
ffffffffc0203e1c:	16068693          	addi	a3,a3,352 # ffffffffc0207f78 <commands+0x17d0>
ffffffffc0203e20:	00003617          	auipc	a2,0x3
ffffffffc0203e24:	e0860613          	addi	a2,a2,-504 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203e28:	06f00593          	li	a1,111
ffffffffc0203e2c:	00004517          	auipc	a0,0x4
ffffffffc0203e30:	04450513          	addi	a0,a0,68 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203e34:	be2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==9);
ffffffffc0203e38:	00004697          	auipc	a3,0x4
ffffffffc0203e3c:	13068693          	addi	a3,a3,304 # ffffffffc0207f68 <commands+0x17c0>
ffffffffc0203e40:	00003617          	auipc	a2,0x3
ffffffffc0203e44:	de860613          	addi	a2,a2,-536 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203e48:	06c00593          	li	a1,108
ffffffffc0203e4c:	00004517          	auipc	a0,0x4
ffffffffc0203e50:	02450513          	addi	a0,a0,36 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203e54:	bc2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==8);
ffffffffc0203e58:	00004697          	auipc	a3,0x4
ffffffffc0203e5c:	10068693          	addi	a3,a3,256 # ffffffffc0207f58 <commands+0x17b0>
ffffffffc0203e60:	00003617          	auipc	a2,0x3
ffffffffc0203e64:	dc860613          	addi	a2,a2,-568 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203e68:	06900593          	li	a1,105
ffffffffc0203e6c:	00004517          	auipc	a0,0x4
ffffffffc0203e70:	00450513          	addi	a0,a0,4 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203e74:	ba2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==7);
ffffffffc0203e78:	00004697          	auipc	a3,0x4
ffffffffc0203e7c:	0d068693          	addi	a3,a3,208 # ffffffffc0207f48 <commands+0x17a0>
ffffffffc0203e80:	00003617          	auipc	a2,0x3
ffffffffc0203e84:	da860613          	addi	a2,a2,-600 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203e88:	06600593          	li	a1,102
ffffffffc0203e8c:	00004517          	auipc	a0,0x4
ffffffffc0203e90:	fe450513          	addi	a0,a0,-28 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203e94:	b82fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==6);
ffffffffc0203e98:	00004697          	auipc	a3,0x4
ffffffffc0203e9c:	0a068693          	addi	a3,a3,160 # ffffffffc0207f38 <commands+0x1790>
ffffffffc0203ea0:	00003617          	auipc	a2,0x3
ffffffffc0203ea4:	d8860613          	addi	a2,a2,-632 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203ea8:	06300593          	li	a1,99
ffffffffc0203eac:	00004517          	auipc	a0,0x4
ffffffffc0203eb0:	fc450513          	addi	a0,a0,-60 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203eb4:	b62fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0203eb8:	00004697          	auipc	a3,0x4
ffffffffc0203ebc:	07068693          	addi	a3,a3,112 # ffffffffc0207f28 <commands+0x1780>
ffffffffc0203ec0:	00003617          	auipc	a2,0x3
ffffffffc0203ec4:	d6860613          	addi	a2,a2,-664 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203ec8:	06000593          	li	a1,96
ffffffffc0203ecc:	00004517          	auipc	a0,0x4
ffffffffc0203ed0:	fa450513          	addi	a0,a0,-92 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203ed4:	b42fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ed8:	00004697          	auipc	a3,0x4
ffffffffc0203edc:	05068693          	addi	a3,a3,80 # ffffffffc0207f28 <commands+0x1780>
ffffffffc0203ee0:	00003617          	auipc	a2,0x3
ffffffffc0203ee4:	d4860613          	addi	a2,a2,-696 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203ee8:	05d00593          	li	a1,93
ffffffffc0203eec:	00004517          	auipc	a0,0x4
ffffffffc0203ef0:	f8450513          	addi	a0,a0,-124 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203ef4:	b22fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0203ef8:	00004697          	auipc	a3,0x4
ffffffffc0203efc:	d7068693          	addi	a3,a3,-656 # ffffffffc0207c68 <commands+0x14c0>
ffffffffc0203f00:	00003617          	auipc	a2,0x3
ffffffffc0203f04:	d2860613          	addi	a2,a2,-728 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203f08:	05a00593          	li	a1,90
ffffffffc0203f0c:	00004517          	auipc	a0,0x4
ffffffffc0203f10:	f6450513          	addi	a0,a0,-156 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203f14:	b02fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f18:	00004697          	auipc	a3,0x4
ffffffffc0203f1c:	d5068693          	addi	a3,a3,-688 # ffffffffc0207c68 <commands+0x14c0>
ffffffffc0203f20:	00003617          	auipc	a2,0x3
ffffffffc0203f24:	d0860613          	addi	a2,a2,-760 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203f28:	05700593          	li	a1,87
ffffffffc0203f2c:	00004517          	auipc	a0,0x4
ffffffffc0203f30:	f4450513          	addi	a0,a0,-188 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203f34:	ae2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f38:	00004697          	auipc	a3,0x4
ffffffffc0203f3c:	d3068693          	addi	a3,a3,-720 # ffffffffc0207c68 <commands+0x14c0>
ffffffffc0203f40:	00003617          	auipc	a2,0x3
ffffffffc0203f44:	ce860613          	addi	a2,a2,-792 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203f48:	05400593          	li	a1,84
ffffffffc0203f4c:	00004517          	auipc	a0,0x4
ffffffffc0203f50:	f2450513          	addi	a0,a0,-220 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203f54:	ac2fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203f58 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f58:	751c                	ld	a5,40(a0)
{
ffffffffc0203f5a:	1141                	addi	sp,sp,-16
ffffffffc0203f5c:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f5e:	cf91                	beqz	a5,ffffffffc0203f7a <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f60:	ee0d                	bnez	a2,ffffffffc0203f9a <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f62:	679c                	ld	a5,8(a5)
}
ffffffffc0203f64:	60a2                	ld	ra,8(sp)
ffffffffc0203f66:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f68:	6394                	ld	a3,0(a5)
ffffffffc0203f6a:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f6c:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f70:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f72:	e314                	sd	a3,0(a4)
ffffffffc0203f74:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f76:	0141                	addi	sp,sp,16
ffffffffc0203f78:	8082                	ret
         assert(head != NULL);
ffffffffc0203f7a:	00004697          	auipc	a3,0x4
ffffffffc0203f7e:	06668693          	addi	a3,a3,102 # ffffffffc0207fe0 <commands+0x1838>
ffffffffc0203f82:	00003617          	auipc	a2,0x3
ffffffffc0203f86:	ca660613          	addi	a2,a2,-858 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203f8a:	04100593          	li	a1,65
ffffffffc0203f8e:	00004517          	auipc	a0,0x4
ffffffffc0203f92:	ee250513          	addi	a0,a0,-286 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203f96:	a80fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(in_tick==0);
ffffffffc0203f9a:	00004697          	auipc	a3,0x4
ffffffffc0203f9e:	05668693          	addi	a3,a3,86 # ffffffffc0207ff0 <commands+0x1848>
ffffffffc0203fa2:	00003617          	auipc	a2,0x3
ffffffffc0203fa6:	c8660613          	addi	a2,a2,-890 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203faa:	04200593          	li	a1,66
ffffffffc0203fae:	00004517          	auipc	a0,0x4
ffffffffc0203fb2:	ec250513          	addi	a0,a0,-318 # ffffffffc0207e70 <commands+0x16c8>
ffffffffc0203fb6:	a60fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203fba <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203fba:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203fbe:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203fc0:	cb09                	beqz	a4,ffffffffc0203fd2 <_fifo_map_swappable+0x18>
ffffffffc0203fc2:	cb81                	beqz	a5,ffffffffc0203fd2 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203fc4:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203fc6:	e398                	sd	a4,0(a5)
}
ffffffffc0203fc8:	4501                	li	a0,0
ffffffffc0203fca:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203fcc:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203fce:	f614                	sd	a3,40(a2)
ffffffffc0203fd0:	8082                	ret
{
ffffffffc0203fd2:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203fd4:	00004697          	auipc	a3,0x4
ffffffffc0203fd8:	fec68693          	addi	a3,a3,-20 # ffffffffc0207fc0 <commands+0x1818>
ffffffffc0203fdc:	00003617          	auipc	a2,0x3
ffffffffc0203fe0:	c4c60613          	addi	a2,a2,-948 # ffffffffc0206c28 <commands+0x480>
ffffffffc0203fe4:	03200593          	li	a1,50
ffffffffc0203fe8:	00004517          	auipc	a0,0x4
ffffffffc0203fec:	e8850513          	addi	a0,a0,-376 # ffffffffc0207e70 <commands+0x16c8>
{
ffffffffc0203ff0:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203ff2:	a24fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203ff6 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203ff6:	000a8797          	auipc	a5,0xa8
ffffffffc0203ffa:	55a78793          	addi	a5,a5,1370 # ffffffffc02ac550 <free_area>
ffffffffc0203ffe:	e79c                	sd	a5,8(a5)
ffffffffc0204000:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0204002:	0007a823          	sw	zero,16(a5)
}
ffffffffc0204006:	8082                	ret

ffffffffc0204008 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0204008:	000a8517          	auipc	a0,0xa8
ffffffffc020400c:	55856503          	lwu	a0,1368(a0) # ffffffffc02ac560 <free_area+0x10>
ffffffffc0204010:	8082                	ret

ffffffffc0204012 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0204012:	715d                	addi	sp,sp,-80
ffffffffc0204014:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0204016:	000a8917          	auipc	s2,0xa8
ffffffffc020401a:	53a90913          	addi	s2,s2,1338 # ffffffffc02ac550 <free_area>
ffffffffc020401e:	00893783          	ld	a5,8(s2)
ffffffffc0204022:	e486                	sd	ra,72(sp)
ffffffffc0204024:	e0a2                	sd	s0,64(sp)
ffffffffc0204026:	fc26                	sd	s1,56(sp)
ffffffffc0204028:	f44e                	sd	s3,40(sp)
ffffffffc020402a:	f052                	sd	s4,32(sp)
ffffffffc020402c:	ec56                	sd	s5,24(sp)
ffffffffc020402e:	e85a                	sd	s6,16(sp)
ffffffffc0204030:	e45e                	sd	s7,8(sp)
ffffffffc0204032:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204034:	31278463          	beq	a5,s2,ffffffffc020433c <default_check+0x32a>
ffffffffc0204038:	ff07b703          	ld	a4,-16(a5)
ffffffffc020403c:	8305                	srli	a4,a4,0x1
ffffffffc020403e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0204040:	30070263          	beqz	a4,ffffffffc0204344 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0204044:	4401                	li	s0,0
ffffffffc0204046:	4481                	li	s1,0
ffffffffc0204048:	a031                	j	ffffffffc0204054 <default_check+0x42>
ffffffffc020404a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020404e:	8b09                	andi	a4,a4,2
ffffffffc0204050:	2e070a63          	beqz	a4,ffffffffc0204344 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0204054:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204058:	679c                	ld	a5,8(a5)
ffffffffc020405a:	2485                	addiw	s1,s1,1
ffffffffc020405c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020405e:	ff2796e3          	bne	a5,s2,ffffffffc020404a <default_check+0x38>
ffffffffc0204062:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0204064:	eddfc0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0204068:	73351e63          	bne	a0,s3,ffffffffc02047a4 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020406c:	4505                	li	a0,1
ffffffffc020406e:	e05fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204072:	8a2a                	mv	s4,a0
ffffffffc0204074:	46050863          	beqz	a0,ffffffffc02044e4 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204078:	4505                	li	a0,1
ffffffffc020407a:	df9fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020407e:	89aa                	mv	s3,a0
ffffffffc0204080:	74050263          	beqz	a0,ffffffffc02047c4 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204084:	4505                	li	a0,1
ffffffffc0204086:	dedfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020408a:	8aaa                	mv	s5,a0
ffffffffc020408c:	4c050c63          	beqz	a0,ffffffffc0204564 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204090:	2d3a0a63          	beq	s4,s3,ffffffffc0204364 <default_check+0x352>
ffffffffc0204094:	2caa0863          	beq	s4,a0,ffffffffc0204364 <default_check+0x352>
ffffffffc0204098:	2ca98663          	beq	s3,a0,ffffffffc0204364 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020409c:	000a2783          	lw	a5,0(s4)
ffffffffc02040a0:	2e079263          	bnez	a5,ffffffffc0204384 <default_check+0x372>
ffffffffc02040a4:	0009a783          	lw	a5,0(s3)
ffffffffc02040a8:	2c079e63          	bnez	a5,ffffffffc0204384 <default_check+0x372>
ffffffffc02040ac:	411c                	lw	a5,0(a0)
ffffffffc02040ae:	2c079b63          	bnez	a5,ffffffffc0204384 <default_check+0x372>
    return page - pages + nbase;
ffffffffc02040b2:	000a8797          	auipc	a5,0xa8
ffffffffc02040b6:	3b678793          	addi	a5,a5,950 # ffffffffc02ac468 <pages>
ffffffffc02040ba:	639c                	ld	a5,0(a5)
ffffffffc02040bc:	00005717          	auipc	a4,0x5
ffffffffc02040c0:	c6c70713          	addi	a4,a4,-916 # ffffffffc0208d28 <nbase>
ffffffffc02040c4:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02040c6:	000a8717          	auipc	a4,0xa8
ffffffffc02040ca:	33a70713          	addi	a4,a4,826 # ffffffffc02ac400 <npage>
ffffffffc02040ce:	6314                	ld	a3,0(a4)
ffffffffc02040d0:	40fa0733          	sub	a4,s4,a5
ffffffffc02040d4:	8719                	srai	a4,a4,0x6
ffffffffc02040d6:	9732                	add	a4,a4,a2
ffffffffc02040d8:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02040da:	0732                	slli	a4,a4,0xc
ffffffffc02040dc:	2cd77463          	bleu	a3,a4,ffffffffc02043a4 <default_check+0x392>
    return page - pages + nbase;
ffffffffc02040e0:	40f98733          	sub	a4,s3,a5
ffffffffc02040e4:	8719                	srai	a4,a4,0x6
ffffffffc02040e6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040e8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02040ea:	4ed77d63          	bleu	a3,a4,ffffffffc02045e4 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc02040ee:	40f507b3          	sub	a5,a0,a5
ffffffffc02040f2:	8799                	srai	a5,a5,0x6
ffffffffc02040f4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040f6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02040f8:	34d7f663          	bleu	a3,a5,ffffffffc0204444 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02040fc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02040fe:	00093c03          	ld	s8,0(s2)
ffffffffc0204102:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0204106:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc020410a:	000a8797          	auipc	a5,0xa8
ffffffffc020410e:	4527b723          	sd	s2,1102(a5) # ffffffffc02ac558 <free_area+0x8>
ffffffffc0204112:	000a8797          	auipc	a5,0xa8
ffffffffc0204116:	4327bf23          	sd	s2,1086(a5) # ffffffffc02ac550 <free_area>
    nr_free = 0;
ffffffffc020411a:	000a8797          	auipc	a5,0xa8
ffffffffc020411e:	4407a323          	sw	zero,1094(a5) # ffffffffc02ac560 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0204122:	d51fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204126:	2e051f63          	bnez	a0,ffffffffc0204424 <default_check+0x412>
    free_page(p0);
ffffffffc020412a:	4585                	li	a1,1
ffffffffc020412c:	8552                	mv	a0,s4
ffffffffc020412e:	dcdfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p1);
ffffffffc0204132:	4585                	li	a1,1
ffffffffc0204134:	854e                	mv	a0,s3
ffffffffc0204136:	dc5fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p2);
ffffffffc020413a:	4585                	li	a1,1
ffffffffc020413c:	8556                	mv	a0,s5
ffffffffc020413e:	dbdfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert(nr_free == 3);
ffffffffc0204142:	01092703          	lw	a4,16(s2)
ffffffffc0204146:	478d                	li	a5,3
ffffffffc0204148:	2af71e63          	bne	a4,a5,ffffffffc0204404 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020414c:	4505                	li	a0,1
ffffffffc020414e:	d25fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204152:	89aa                	mv	s3,a0
ffffffffc0204154:	28050863          	beqz	a0,ffffffffc02043e4 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204158:	4505                	li	a0,1
ffffffffc020415a:	d19fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020415e:	8aaa                	mv	s5,a0
ffffffffc0204160:	3e050263          	beqz	a0,ffffffffc0204544 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204164:	4505                	li	a0,1
ffffffffc0204166:	d0dfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020416a:	8a2a                	mv	s4,a0
ffffffffc020416c:	3a050c63          	beqz	a0,ffffffffc0204524 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0204170:	4505                	li	a0,1
ffffffffc0204172:	d01fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204176:	38051763          	bnez	a0,ffffffffc0204504 <default_check+0x4f2>
    free_page(p0);
ffffffffc020417a:	4585                	li	a1,1
ffffffffc020417c:	854e                	mv	a0,s3
ffffffffc020417e:	d7dfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0204182:	00893783          	ld	a5,8(s2)
ffffffffc0204186:	23278f63          	beq	a5,s2,ffffffffc02043c4 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc020418a:	4505                	li	a0,1
ffffffffc020418c:	ce7fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204190:	32a99a63          	bne	s3,a0,ffffffffc02044c4 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0204194:	4505                	li	a0,1
ffffffffc0204196:	cddfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020419a:	30051563          	bnez	a0,ffffffffc02044a4 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc020419e:	01092783          	lw	a5,16(s2)
ffffffffc02041a2:	2e079163          	bnez	a5,ffffffffc0204484 <default_check+0x472>
    free_page(p);
ffffffffc02041a6:	854e                	mv	a0,s3
ffffffffc02041a8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02041aa:	000a8797          	auipc	a5,0xa8
ffffffffc02041ae:	3b87b323          	sd	s8,934(a5) # ffffffffc02ac550 <free_area>
ffffffffc02041b2:	000a8797          	auipc	a5,0xa8
ffffffffc02041b6:	3b77b323          	sd	s7,934(a5) # ffffffffc02ac558 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc02041ba:	000a8797          	auipc	a5,0xa8
ffffffffc02041be:	3b67a323          	sw	s6,934(a5) # ffffffffc02ac560 <free_area+0x10>
    free_page(p);
ffffffffc02041c2:	d39fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p1);
ffffffffc02041c6:	4585                	li	a1,1
ffffffffc02041c8:	8556                	mv	a0,s5
ffffffffc02041ca:	d31fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p2);
ffffffffc02041ce:	4585                	li	a1,1
ffffffffc02041d0:	8552                	mv	a0,s4
ffffffffc02041d2:	d29fc0ef          	jal	ra,ffffffffc0200efa <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02041d6:	4515                	li	a0,5
ffffffffc02041d8:	c9bfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02041dc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02041de:	28050363          	beqz	a0,ffffffffc0204464 <default_check+0x452>
ffffffffc02041e2:	651c                	ld	a5,8(a0)
ffffffffc02041e4:	8385                	srli	a5,a5,0x1
ffffffffc02041e6:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02041e8:	54079e63          	bnez	a5,ffffffffc0204744 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02041ec:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02041ee:	00093b03          	ld	s6,0(s2)
ffffffffc02041f2:	00893a83          	ld	s5,8(s2)
ffffffffc02041f6:	000a8797          	auipc	a5,0xa8
ffffffffc02041fa:	3527bd23          	sd	s2,858(a5) # ffffffffc02ac550 <free_area>
ffffffffc02041fe:	000a8797          	auipc	a5,0xa8
ffffffffc0204202:	3527bd23          	sd	s2,858(a5) # ffffffffc02ac558 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0204206:	c6dfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020420a:	50051d63          	bnez	a0,ffffffffc0204724 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020420e:	08098a13          	addi	s4,s3,128
ffffffffc0204212:	8552                	mv	a0,s4
ffffffffc0204214:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0204216:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020421a:	000a8797          	auipc	a5,0xa8
ffffffffc020421e:	3407a323          	sw	zero,838(a5) # ffffffffc02ac560 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0204222:	cd9fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0204226:	4511                	li	a0,4
ffffffffc0204228:	c4bfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020422c:	4c051c63          	bnez	a0,ffffffffc0204704 <default_check+0x6f2>
ffffffffc0204230:	0889b783          	ld	a5,136(s3)
ffffffffc0204234:	8385                	srli	a5,a5,0x1
ffffffffc0204236:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0204238:	4a078663          	beqz	a5,ffffffffc02046e4 <default_check+0x6d2>
ffffffffc020423c:	0909a703          	lw	a4,144(s3)
ffffffffc0204240:	478d                	li	a5,3
ffffffffc0204242:	4af71163          	bne	a4,a5,ffffffffc02046e4 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204246:	450d                	li	a0,3
ffffffffc0204248:	c2bfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020424c:	8c2a                	mv	s8,a0
ffffffffc020424e:	46050b63          	beqz	a0,ffffffffc02046c4 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0204252:	4505                	li	a0,1
ffffffffc0204254:	c1ffc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204258:	44051663          	bnez	a0,ffffffffc02046a4 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc020425c:	438a1463          	bne	s4,s8,ffffffffc0204684 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0204260:	4585                	li	a1,1
ffffffffc0204262:	854e                	mv	a0,s3
ffffffffc0204264:	c97fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_pages(p1, 3);
ffffffffc0204268:	458d                	li	a1,3
ffffffffc020426a:	8552                	mv	a0,s4
ffffffffc020426c:	c8ffc0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0204270:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0204274:	04098c13          	addi	s8,s3,64
ffffffffc0204278:	8385                	srli	a5,a5,0x1
ffffffffc020427a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020427c:	3e078463          	beqz	a5,ffffffffc0204664 <default_check+0x652>
ffffffffc0204280:	0109a703          	lw	a4,16(s3)
ffffffffc0204284:	4785                	li	a5,1
ffffffffc0204286:	3cf71f63          	bne	a4,a5,ffffffffc0204664 <default_check+0x652>
ffffffffc020428a:	008a3783          	ld	a5,8(s4)
ffffffffc020428e:	8385                	srli	a5,a5,0x1
ffffffffc0204290:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204292:	3a078963          	beqz	a5,ffffffffc0204644 <default_check+0x632>
ffffffffc0204296:	010a2703          	lw	a4,16(s4)
ffffffffc020429a:	478d                	li	a5,3
ffffffffc020429c:	3af71463          	bne	a4,a5,ffffffffc0204644 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02042a0:	4505                	li	a0,1
ffffffffc02042a2:	bd1fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02042a6:	36a99f63          	bne	s3,a0,ffffffffc0204624 <default_check+0x612>
    free_page(p0);
ffffffffc02042aa:	4585                	li	a1,1
ffffffffc02042ac:	c4ffc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02042b0:	4509                	li	a0,2
ffffffffc02042b2:	bc1fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02042b6:	34aa1763          	bne	s4,a0,ffffffffc0204604 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc02042ba:	4589                	li	a1,2
ffffffffc02042bc:	c3ffc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p2);
ffffffffc02042c0:	4585                	li	a1,1
ffffffffc02042c2:	8562                	mv	a0,s8
ffffffffc02042c4:	c37fc0ef          	jal	ra,ffffffffc0200efa <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02042c8:	4515                	li	a0,5
ffffffffc02042ca:	ba9fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02042ce:	89aa                	mv	s3,a0
ffffffffc02042d0:	48050a63          	beqz	a0,ffffffffc0204764 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc02042d4:	4505                	li	a0,1
ffffffffc02042d6:	b9dfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02042da:	2e051563          	bnez	a0,ffffffffc02045c4 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02042de:	01092783          	lw	a5,16(s2)
ffffffffc02042e2:	2c079163          	bnez	a5,ffffffffc02045a4 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02042e6:	4595                	li	a1,5
ffffffffc02042e8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02042ea:	000a8797          	auipc	a5,0xa8
ffffffffc02042ee:	2777ab23          	sw	s7,630(a5) # ffffffffc02ac560 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02042f2:	000a8797          	auipc	a5,0xa8
ffffffffc02042f6:	2567bf23          	sd	s6,606(a5) # ffffffffc02ac550 <free_area>
ffffffffc02042fa:	000a8797          	auipc	a5,0xa8
ffffffffc02042fe:	2557bf23          	sd	s5,606(a5) # ffffffffc02ac558 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0204302:	bf9fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return listelm->next;
ffffffffc0204306:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020430a:	01278963          	beq	a5,s2,ffffffffc020431c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020430e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204312:	679c                	ld	a5,8(a5)
ffffffffc0204314:	34fd                	addiw	s1,s1,-1
ffffffffc0204316:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204318:	ff279be3          	bne	a5,s2,ffffffffc020430e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020431c:	26049463          	bnez	s1,ffffffffc0204584 <default_check+0x572>
    assert(total == 0);
ffffffffc0204320:	46041263          	bnez	s0,ffffffffc0204784 <default_check+0x772>
}
ffffffffc0204324:	60a6                	ld	ra,72(sp)
ffffffffc0204326:	6406                	ld	s0,64(sp)
ffffffffc0204328:	74e2                	ld	s1,56(sp)
ffffffffc020432a:	7942                	ld	s2,48(sp)
ffffffffc020432c:	79a2                	ld	s3,40(sp)
ffffffffc020432e:	7a02                	ld	s4,32(sp)
ffffffffc0204330:	6ae2                	ld	s5,24(sp)
ffffffffc0204332:	6b42                	ld	s6,16(sp)
ffffffffc0204334:	6ba2                	ld	s7,8(sp)
ffffffffc0204336:	6c02                	ld	s8,0(sp)
ffffffffc0204338:	6161                	addi	sp,sp,80
ffffffffc020433a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020433c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020433e:	4401                	li	s0,0
ffffffffc0204340:	4481                	li	s1,0
ffffffffc0204342:	b30d                	j	ffffffffc0204064 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0204344:	00003697          	auipc	a3,0x3
ffffffffc0204348:	78468693          	addi	a3,a3,1924 # ffffffffc0207ac8 <commands+0x1320>
ffffffffc020434c:	00003617          	auipc	a2,0x3
ffffffffc0204350:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204354:	0f000593          	li	a1,240
ffffffffc0204358:	00004517          	auipc	a0,0x4
ffffffffc020435c:	cc050513          	addi	a0,a0,-832 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204360:	eb7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204364:	00004697          	auipc	a3,0x4
ffffffffc0204368:	d2c68693          	addi	a3,a3,-724 # ffffffffc0208090 <commands+0x18e8>
ffffffffc020436c:	00003617          	auipc	a2,0x3
ffffffffc0204370:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204374:	0bd00593          	li	a1,189
ffffffffc0204378:	00004517          	auipc	a0,0x4
ffffffffc020437c:	ca050513          	addi	a0,a0,-864 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204380:	e97fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204384:	00004697          	auipc	a3,0x4
ffffffffc0204388:	d3468693          	addi	a3,a3,-716 # ffffffffc02080b8 <commands+0x1910>
ffffffffc020438c:	00003617          	auipc	a2,0x3
ffffffffc0204390:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204394:	0be00593          	li	a1,190
ffffffffc0204398:	00004517          	auipc	a0,0x4
ffffffffc020439c:	c8050513          	addi	a0,a0,-896 # ffffffffc0208018 <commands+0x1870>
ffffffffc02043a0:	e77fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02043a4:	00004697          	auipc	a3,0x4
ffffffffc02043a8:	d5468693          	addi	a3,a3,-684 # ffffffffc02080f8 <commands+0x1950>
ffffffffc02043ac:	00003617          	auipc	a2,0x3
ffffffffc02043b0:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206c28 <commands+0x480>
ffffffffc02043b4:	0c000593          	li	a1,192
ffffffffc02043b8:	00004517          	auipc	a0,0x4
ffffffffc02043bc:	c6050513          	addi	a0,a0,-928 # ffffffffc0208018 <commands+0x1870>
ffffffffc02043c0:	e57fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02043c4:	00004697          	auipc	a3,0x4
ffffffffc02043c8:	dbc68693          	addi	a3,a3,-580 # ffffffffc0208180 <commands+0x19d8>
ffffffffc02043cc:	00003617          	auipc	a2,0x3
ffffffffc02043d0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206c28 <commands+0x480>
ffffffffc02043d4:	0d900593          	li	a1,217
ffffffffc02043d8:	00004517          	auipc	a0,0x4
ffffffffc02043dc:	c4050513          	addi	a0,a0,-960 # ffffffffc0208018 <commands+0x1870>
ffffffffc02043e0:	e37fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02043e4:	00004697          	auipc	a3,0x4
ffffffffc02043e8:	c4c68693          	addi	a3,a3,-948 # ffffffffc0208030 <commands+0x1888>
ffffffffc02043ec:	00003617          	auipc	a2,0x3
ffffffffc02043f0:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206c28 <commands+0x480>
ffffffffc02043f4:	0d200593          	li	a1,210
ffffffffc02043f8:	00004517          	auipc	a0,0x4
ffffffffc02043fc:	c2050513          	addi	a0,a0,-992 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204400:	e17fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 3);
ffffffffc0204404:	00004697          	auipc	a3,0x4
ffffffffc0204408:	d6c68693          	addi	a3,a3,-660 # ffffffffc0208170 <commands+0x19c8>
ffffffffc020440c:	00003617          	auipc	a2,0x3
ffffffffc0204410:	81c60613          	addi	a2,a2,-2020 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204414:	0d000593          	li	a1,208
ffffffffc0204418:	00004517          	auipc	a0,0x4
ffffffffc020441c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204420:	df7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204424:	00004697          	auipc	a3,0x4
ffffffffc0204428:	d3468693          	addi	a3,a3,-716 # ffffffffc0208158 <commands+0x19b0>
ffffffffc020442c:	00002617          	auipc	a2,0x2
ffffffffc0204430:	7fc60613          	addi	a2,a2,2044 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204434:	0cb00593          	li	a1,203
ffffffffc0204438:	00004517          	auipc	a0,0x4
ffffffffc020443c:	be050513          	addi	a0,a0,-1056 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204440:	dd7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0204444:	00004697          	auipc	a3,0x4
ffffffffc0204448:	cf468693          	addi	a3,a3,-780 # ffffffffc0208138 <commands+0x1990>
ffffffffc020444c:	00002617          	auipc	a2,0x2
ffffffffc0204450:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204454:	0c200593          	li	a1,194
ffffffffc0204458:	00004517          	auipc	a0,0x4
ffffffffc020445c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204460:	db7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != NULL);
ffffffffc0204464:	00004697          	auipc	a3,0x4
ffffffffc0204468:	d5468693          	addi	a3,a3,-684 # ffffffffc02081b8 <commands+0x1a10>
ffffffffc020446c:	00002617          	auipc	a2,0x2
ffffffffc0204470:	7bc60613          	addi	a2,a2,1980 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204474:	0f800593          	li	a1,248
ffffffffc0204478:	00004517          	auipc	a0,0x4
ffffffffc020447c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204480:	d97fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc0204484:	00003697          	auipc	a3,0x3
ffffffffc0204488:	7f468693          	addi	a3,a3,2036 # ffffffffc0207c78 <commands+0x14d0>
ffffffffc020448c:	00002617          	auipc	a2,0x2
ffffffffc0204490:	79c60613          	addi	a2,a2,1948 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204494:	0df00593          	li	a1,223
ffffffffc0204498:	00004517          	auipc	a0,0x4
ffffffffc020449c:	b8050513          	addi	a0,a0,-1152 # ffffffffc0208018 <commands+0x1870>
ffffffffc02044a0:	d77fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044a4:	00004697          	auipc	a3,0x4
ffffffffc02044a8:	cb468693          	addi	a3,a3,-844 # ffffffffc0208158 <commands+0x19b0>
ffffffffc02044ac:	00002617          	auipc	a2,0x2
ffffffffc02044b0:	77c60613          	addi	a2,a2,1916 # ffffffffc0206c28 <commands+0x480>
ffffffffc02044b4:	0dd00593          	li	a1,221
ffffffffc02044b8:	00004517          	auipc	a0,0x4
ffffffffc02044bc:	b6050513          	addi	a0,a0,-1184 # ffffffffc0208018 <commands+0x1870>
ffffffffc02044c0:	d57fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02044c4:	00004697          	auipc	a3,0x4
ffffffffc02044c8:	cd468693          	addi	a3,a3,-812 # ffffffffc0208198 <commands+0x19f0>
ffffffffc02044cc:	00002617          	auipc	a2,0x2
ffffffffc02044d0:	75c60613          	addi	a2,a2,1884 # ffffffffc0206c28 <commands+0x480>
ffffffffc02044d4:	0dc00593          	li	a1,220
ffffffffc02044d8:	00004517          	auipc	a0,0x4
ffffffffc02044dc:	b4050513          	addi	a0,a0,-1216 # ffffffffc0208018 <commands+0x1870>
ffffffffc02044e0:	d37fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02044e4:	00004697          	auipc	a3,0x4
ffffffffc02044e8:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0208030 <commands+0x1888>
ffffffffc02044ec:	00002617          	auipc	a2,0x2
ffffffffc02044f0:	73c60613          	addi	a2,a2,1852 # ffffffffc0206c28 <commands+0x480>
ffffffffc02044f4:	0b900593          	li	a1,185
ffffffffc02044f8:	00004517          	auipc	a0,0x4
ffffffffc02044fc:	b2050513          	addi	a0,a0,-1248 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204500:	d17fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204504:	00004697          	auipc	a3,0x4
ffffffffc0204508:	c5468693          	addi	a3,a3,-940 # ffffffffc0208158 <commands+0x19b0>
ffffffffc020450c:	00002617          	auipc	a2,0x2
ffffffffc0204510:	71c60613          	addi	a2,a2,1820 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204514:	0d600593          	li	a1,214
ffffffffc0204518:	00004517          	auipc	a0,0x4
ffffffffc020451c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204520:	cf7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204524:	00004697          	auipc	a3,0x4
ffffffffc0204528:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0208070 <commands+0x18c8>
ffffffffc020452c:	00002617          	auipc	a2,0x2
ffffffffc0204530:	6fc60613          	addi	a2,a2,1788 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204534:	0d400593          	li	a1,212
ffffffffc0204538:	00004517          	auipc	a0,0x4
ffffffffc020453c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204540:	cd7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204544:	00004697          	auipc	a3,0x4
ffffffffc0204548:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0208050 <commands+0x18a8>
ffffffffc020454c:	00002617          	auipc	a2,0x2
ffffffffc0204550:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204554:	0d300593          	li	a1,211
ffffffffc0204558:	00004517          	auipc	a0,0x4
ffffffffc020455c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204560:	cb7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204564:	00004697          	auipc	a3,0x4
ffffffffc0204568:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0208070 <commands+0x18c8>
ffffffffc020456c:	00002617          	auipc	a2,0x2
ffffffffc0204570:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204574:	0bb00593          	li	a1,187
ffffffffc0204578:	00004517          	auipc	a0,0x4
ffffffffc020457c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204580:	c97fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(count == 0);
ffffffffc0204584:	00004697          	auipc	a3,0x4
ffffffffc0204588:	d8468693          	addi	a3,a3,-636 # ffffffffc0208308 <commands+0x1b60>
ffffffffc020458c:	00002617          	auipc	a2,0x2
ffffffffc0204590:	69c60613          	addi	a2,a2,1692 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204594:	12500593          	li	a1,293
ffffffffc0204598:	00004517          	auipc	a0,0x4
ffffffffc020459c:	a8050513          	addi	a0,a0,-1408 # ffffffffc0208018 <commands+0x1870>
ffffffffc02045a0:	c77fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc02045a4:	00003697          	auipc	a3,0x3
ffffffffc02045a8:	6d468693          	addi	a3,a3,1748 # ffffffffc0207c78 <commands+0x14d0>
ffffffffc02045ac:	00002617          	auipc	a2,0x2
ffffffffc02045b0:	67c60613          	addi	a2,a2,1660 # ffffffffc0206c28 <commands+0x480>
ffffffffc02045b4:	11a00593          	li	a1,282
ffffffffc02045b8:	00004517          	auipc	a0,0x4
ffffffffc02045bc:	a6050513          	addi	a0,a0,-1440 # ffffffffc0208018 <commands+0x1870>
ffffffffc02045c0:	c57fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02045c4:	00004697          	auipc	a3,0x4
ffffffffc02045c8:	b9468693          	addi	a3,a3,-1132 # ffffffffc0208158 <commands+0x19b0>
ffffffffc02045cc:	00002617          	auipc	a2,0x2
ffffffffc02045d0:	65c60613          	addi	a2,a2,1628 # ffffffffc0206c28 <commands+0x480>
ffffffffc02045d4:	11800593          	li	a1,280
ffffffffc02045d8:	00004517          	auipc	a0,0x4
ffffffffc02045dc:	a4050513          	addi	a0,a0,-1472 # ffffffffc0208018 <commands+0x1870>
ffffffffc02045e0:	c37fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02045e4:	00004697          	auipc	a3,0x4
ffffffffc02045e8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0208118 <commands+0x1970>
ffffffffc02045ec:	00002617          	auipc	a2,0x2
ffffffffc02045f0:	63c60613          	addi	a2,a2,1596 # ffffffffc0206c28 <commands+0x480>
ffffffffc02045f4:	0c100593          	li	a1,193
ffffffffc02045f8:	00004517          	auipc	a0,0x4
ffffffffc02045fc:	a2050513          	addi	a0,a0,-1504 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204600:	c17fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204604:	00004697          	auipc	a3,0x4
ffffffffc0204608:	cc468693          	addi	a3,a3,-828 # ffffffffc02082c8 <commands+0x1b20>
ffffffffc020460c:	00002617          	auipc	a2,0x2
ffffffffc0204610:	61c60613          	addi	a2,a2,1564 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204614:	11200593          	li	a1,274
ffffffffc0204618:	00004517          	auipc	a0,0x4
ffffffffc020461c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204620:	bf7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0204624:	00004697          	auipc	a3,0x4
ffffffffc0204628:	c8468693          	addi	a3,a3,-892 # ffffffffc02082a8 <commands+0x1b00>
ffffffffc020462c:	00002617          	auipc	a2,0x2
ffffffffc0204630:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204634:	11000593          	li	a1,272
ffffffffc0204638:	00004517          	auipc	a0,0x4
ffffffffc020463c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204640:	bd7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204644:	00004697          	auipc	a3,0x4
ffffffffc0204648:	c3c68693          	addi	a3,a3,-964 # ffffffffc0208280 <commands+0x1ad8>
ffffffffc020464c:	00002617          	auipc	a2,0x2
ffffffffc0204650:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204654:	10e00593          	li	a1,270
ffffffffc0204658:	00004517          	auipc	a0,0x4
ffffffffc020465c:	9c050513          	addi	a0,a0,-1600 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204660:	bb7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204664:	00004697          	auipc	a3,0x4
ffffffffc0204668:	bf468693          	addi	a3,a3,-1036 # ffffffffc0208258 <commands+0x1ab0>
ffffffffc020466c:	00002617          	auipc	a2,0x2
ffffffffc0204670:	5bc60613          	addi	a2,a2,1468 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204674:	10d00593          	li	a1,269
ffffffffc0204678:	00004517          	auipc	a0,0x4
ffffffffc020467c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204680:	b97fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204684:	00004697          	auipc	a3,0x4
ffffffffc0204688:	bc468693          	addi	a3,a3,-1084 # ffffffffc0208248 <commands+0x1aa0>
ffffffffc020468c:	00002617          	auipc	a2,0x2
ffffffffc0204690:	59c60613          	addi	a2,a2,1436 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204694:	10800593          	li	a1,264
ffffffffc0204698:	00004517          	auipc	a0,0x4
ffffffffc020469c:	98050513          	addi	a0,a0,-1664 # ffffffffc0208018 <commands+0x1870>
ffffffffc02046a0:	b77fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02046a4:	00004697          	auipc	a3,0x4
ffffffffc02046a8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0208158 <commands+0x19b0>
ffffffffc02046ac:	00002617          	auipc	a2,0x2
ffffffffc02046b0:	57c60613          	addi	a2,a2,1404 # ffffffffc0206c28 <commands+0x480>
ffffffffc02046b4:	10700593          	li	a1,263
ffffffffc02046b8:	00004517          	auipc	a0,0x4
ffffffffc02046bc:	96050513          	addi	a0,a0,-1696 # ffffffffc0208018 <commands+0x1870>
ffffffffc02046c0:	b57fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02046c4:	00004697          	auipc	a3,0x4
ffffffffc02046c8:	b6468693          	addi	a3,a3,-1180 # ffffffffc0208228 <commands+0x1a80>
ffffffffc02046cc:	00002617          	auipc	a2,0x2
ffffffffc02046d0:	55c60613          	addi	a2,a2,1372 # ffffffffc0206c28 <commands+0x480>
ffffffffc02046d4:	10600593          	li	a1,262
ffffffffc02046d8:	00004517          	auipc	a0,0x4
ffffffffc02046dc:	94050513          	addi	a0,a0,-1728 # ffffffffc0208018 <commands+0x1870>
ffffffffc02046e0:	b37fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02046e4:	00004697          	auipc	a3,0x4
ffffffffc02046e8:	b1468693          	addi	a3,a3,-1260 # ffffffffc02081f8 <commands+0x1a50>
ffffffffc02046ec:	00002617          	auipc	a2,0x2
ffffffffc02046f0:	53c60613          	addi	a2,a2,1340 # ffffffffc0206c28 <commands+0x480>
ffffffffc02046f4:	10500593          	li	a1,261
ffffffffc02046f8:	00004517          	auipc	a0,0x4
ffffffffc02046fc:	92050513          	addi	a0,a0,-1760 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204700:	b17fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0204704:	00004697          	auipc	a3,0x4
ffffffffc0204708:	adc68693          	addi	a3,a3,-1316 # ffffffffc02081e0 <commands+0x1a38>
ffffffffc020470c:	00002617          	auipc	a2,0x2
ffffffffc0204710:	51c60613          	addi	a2,a2,1308 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204714:	10400593          	li	a1,260
ffffffffc0204718:	00004517          	auipc	a0,0x4
ffffffffc020471c:	90050513          	addi	a0,a0,-1792 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204720:	af7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204724:	00004697          	auipc	a3,0x4
ffffffffc0204728:	a3468693          	addi	a3,a3,-1484 # ffffffffc0208158 <commands+0x19b0>
ffffffffc020472c:	00002617          	auipc	a2,0x2
ffffffffc0204730:	4fc60613          	addi	a2,a2,1276 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204734:	0fe00593          	li	a1,254
ffffffffc0204738:	00004517          	auipc	a0,0x4
ffffffffc020473c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204740:	ad7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!PageProperty(p0));
ffffffffc0204744:	00004697          	auipc	a3,0x4
ffffffffc0204748:	a8468693          	addi	a3,a3,-1404 # ffffffffc02081c8 <commands+0x1a20>
ffffffffc020474c:	00002617          	auipc	a2,0x2
ffffffffc0204750:	4dc60613          	addi	a2,a2,1244 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204754:	0f900593          	li	a1,249
ffffffffc0204758:	00004517          	auipc	a0,0x4
ffffffffc020475c:	8c050513          	addi	a0,a0,-1856 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204760:	ab7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204764:	00004697          	auipc	a3,0x4
ffffffffc0204768:	b8468693          	addi	a3,a3,-1148 # ffffffffc02082e8 <commands+0x1b40>
ffffffffc020476c:	00002617          	auipc	a2,0x2
ffffffffc0204770:	4bc60613          	addi	a2,a2,1212 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204774:	11700593          	li	a1,279
ffffffffc0204778:	00004517          	auipc	a0,0x4
ffffffffc020477c:	8a050513          	addi	a0,a0,-1888 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204780:	a97fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == 0);
ffffffffc0204784:	00004697          	auipc	a3,0x4
ffffffffc0204788:	b9468693          	addi	a3,a3,-1132 # ffffffffc0208318 <commands+0x1b70>
ffffffffc020478c:	00002617          	auipc	a2,0x2
ffffffffc0204790:	49c60613          	addi	a2,a2,1180 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204794:	12600593          	li	a1,294
ffffffffc0204798:	00004517          	auipc	a0,0x4
ffffffffc020479c:	88050513          	addi	a0,a0,-1920 # ffffffffc0208018 <commands+0x1870>
ffffffffc02047a0:	a77fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == nr_free_pages());
ffffffffc02047a4:	00003697          	auipc	a3,0x3
ffffffffc02047a8:	33468693          	addi	a3,a3,820 # ffffffffc0207ad8 <commands+0x1330>
ffffffffc02047ac:	00002617          	auipc	a2,0x2
ffffffffc02047b0:	47c60613          	addi	a2,a2,1148 # ffffffffc0206c28 <commands+0x480>
ffffffffc02047b4:	0f300593          	li	a1,243
ffffffffc02047b8:	00004517          	auipc	a0,0x4
ffffffffc02047bc:	86050513          	addi	a0,a0,-1952 # ffffffffc0208018 <commands+0x1870>
ffffffffc02047c0:	a57fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02047c4:	00004697          	auipc	a3,0x4
ffffffffc02047c8:	88c68693          	addi	a3,a3,-1908 # ffffffffc0208050 <commands+0x18a8>
ffffffffc02047cc:	00002617          	auipc	a2,0x2
ffffffffc02047d0:	45c60613          	addi	a2,a2,1116 # ffffffffc0206c28 <commands+0x480>
ffffffffc02047d4:	0ba00593          	li	a1,186
ffffffffc02047d8:	00004517          	auipc	a0,0x4
ffffffffc02047dc:	84050513          	addi	a0,a0,-1984 # ffffffffc0208018 <commands+0x1870>
ffffffffc02047e0:	a37fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02047e4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02047e4:	1141                	addi	sp,sp,-16
ffffffffc02047e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02047e8:	16058e63          	beqz	a1,ffffffffc0204964 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02047ec:	00659693          	slli	a3,a1,0x6
ffffffffc02047f0:	96aa                	add	a3,a3,a0
ffffffffc02047f2:	02d50d63          	beq	a0,a3,ffffffffc020482c <default_free_pages+0x48>
ffffffffc02047f6:	651c                	ld	a5,8(a0)
ffffffffc02047f8:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02047fa:	14079563          	bnez	a5,ffffffffc0204944 <default_free_pages+0x160>
ffffffffc02047fe:	651c                	ld	a5,8(a0)
ffffffffc0204800:	8385                	srli	a5,a5,0x1
ffffffffc0204802:	8b85                	andi	a5,a5,1
ffffffffc0204804:	14079063          	bnez	a5,ffffffffc0204944 <default_free_pages+0x160>
ffffffffc0204808:	87aa                	mv	a5,a0
ffffffffc020480a:	a809                	j	ffffffffc020481c <default_free_pages+0x38>
ffffffffc020480c:	6798                	ld	a4,8(a5)
ffffffffc020480e:	8b05                	andi	a4,a4,1
ffffffffc0204810:	12071a63          	bnez	a4,ffffffffc0204944 <default_free_pages+0x160>
ffffffffc0204814:	6798                	ld	a4,8(a5)
ffffffffc0204816:	8b09                	andi	a4,a4,2
ffffffffc0204818:	12071663          	bnez	a4,ffffffffc0204944 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020481c:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0204820:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204824:	04078793          	addi	a5,a5,64
ffffffffc0204828:	fed792e3          	bne	a5,a3,ffffffffc020480c <default_free_pages+0x28>
    base->property = n;
ffffffffc020482c:	2581                	sext.w	a1,a1
ffffffffc020482e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0204830:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204834:	4789                	li	a5,2
ffffffffc0204836:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020483a:	000a8697          	auipc	a3,0xa8
ffffffffc020483e:	d1668693          	addi	a3,a3,-746 # ffffffffc02ac550 <free_area>
ffffffffc0204842:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204844:	669c                	ld	a5,8(a3)
ffffffffc0204846:	9db9                	addw	a1,a1,a4
ffffffffc0204848:	000a8717          	auipc	a4,0xa8
ffffffffc020484c:	d0b72c23          	sw	a1,-744(a4) # ffffffffc02ac560 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204850:	0cd78163          	beq	a5,a3,ffffffffc0204912 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0204854:	fe878713          	addi	a4,a5,-24
ffffffffc0204858:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020485a:	4801                	li	a6,0
ffffffffc020485c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204860:	00e56a63          	bltu	a0,a4,ffffffffc0204874 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0204864:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204866:	04d70f63          	beq	a4,a3,ffffffffc02048c4 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020486a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020486c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204870:	fee57ae3          	bleu	a4,a0,ffffffffc0204864 <default_free_pages+0x80>
ffffffffc0204874:	00080663          	beqz	a6,ffffffffc0204880 <default_free_pages+0x9c>
ffffffffc0204878:	000a8817          	auipc	a6,0xa8
ffffffffc020487c:	ccb83c23          	sd	a1,-808(a6) # ffffffffc02ac550 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204880:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204882:	e390                	sd	a2,0(a5)
ffffffffc0204884:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0204886:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204888:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020488a:	06d58a63          	beq	a1,a3,ffffffffc02048fe <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc020488e:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x8578>
        p = le2page(le, page_link);
ffffffffc0204892:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0204896:	02061793          	slli	a5,a2,0x20
ffffffffc020489a:	83e9                	srli	a5,a5,0x1a
ffffffffc020489c:	97ba                	add	a5,a5,a4
ffffffffc020489e:	04f51b63          	bne	a0,a5,ffffffffc02048f4 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02048a2:	491c                	lw	a5,16(a0)
ffffffffc02048a4:	9e3d                	addw	a2,a2,a5
ffffffffc02048a6:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02048aa:	57f5                	li	a5,-3
ffffffffc02048ac:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02048b0:	01853803          	ld	a6,24(a0)
ffffffffc02048b4:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02048b6:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc02048b8:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02048bc:	659c                	ld	a5,8(a1)
ffffffffc02048be:	01063023          	sd	a6,0(a2)
ffffffffc02048c2:	a815                	j	ffffffffc02048f6 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc02048c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02048c6:	f114                	sd	a3,32(a0)
ffffffffc02048c8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02048ca:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02048cc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02048ce:	00d70563          	beq	a4,a3,ffffffffc02048d8 <default_free_pages+0xf4>
ffffffffc02048d2:	4805                	li	a6,1
ffffffffc02048d4:	87ba                	mv	a5,a4
ffffffffc02048d6:	bf59                	j	ffffffffc020486c <default_free_pages+0x88>
ffffffffc02048d8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02048da:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02048dc:	00d78d63          	beq	a5,a3,ffffffffc02048f6 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02048e0:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02048e4:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02048e8:	02061793          	slli	a5,a2,0x20
ffffffffc02048ec:	83e9                	srli	a5,a5,0x1a
ffffffffc02048ee:	97ba                	add	a5,a5,a4
ffffffffc02048f0:	faf509e3          	beq	a0,a5,ffffffffc02048a2 <default_free_pages+0xbe>
ffffffffc02048f4:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02048f6:	fe878713          	addi	a4,a5,-24
ffffffffc02048fa:	00d78963          	beq	a5,a3,ffffffffc020490c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02048fe:	4910                	lw	a2,16(a0)
ffffffffc0204900:	02061693          	slli	a3,a2,0x20
ffffffffc0204904:	82e9                	srli	a3,a3,0x1a
ffffffffc0204906:	96aa                	add	a3,a3,a0
ffffffffc0204908:	00d70e63          	beq	a4,a3,ffffffffc0204924 <default_free_pages+0x140>
}
ffffffffc020490c:	60a2                	ld	ra,8(sp)
ffffffffc020490e:	0141                	addi	sp,sp,16
ffffffffc0204910:	8082                	ret
ffffffffc0204912:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204914:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204918:	e398                	sd	a4,0(a5)
ffffffffc020491a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020491c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020491e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204920:	0141                	addi	sp,sp,16
ffffffffc0204922:	8082                	ret
            base->property += p->property;
ffffffffc0204924:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204928:	ff078693          	addi	a3,a5,-16
ffffffffc020492c:	9e39                	addw	a2,a2,a4
ffffffffc020492e:	c910                	sw	a2,16(a0)
ffffffffc0204930:	5775                	li	a4,-3
ffffffffc0204932:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204936:	6398                	ld	a4,0(a5)
ffffffffc0204938:	679c                	ld	a5,8(a5)
}
ffffffffc020493a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020493c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020493e:	e398                	sd	a4,0(a5)
ffffffffc0204940:	0141                	addi	sp,sp,16
ffffffffc0204942:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204944:	00004697          	auipc	a3,0x4
ffffffffc0204948:	9e468693          	addi	a3,a3,-1564 # ffffffffc0208328 <commands+0x1b80>
ffffffffc020494c:	00002617          	auipc	a2,0x2
ffffffffc0204950:	2dc60613          	addi	a2,a2,732 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204954:	08300593          	li	a1,131
ffffffffc0204958:	00003517          	auipc	a0,0x3
ffffffffc020495c:	6c050513          	addi	a0,a0,1728 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204960:	8b7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc0204964:	00004697          	auipc	a3,0x4
ffffffffc0204968:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0208350 <commands+0x1ba8>
ffffffffc020496c:	00002617          	auipc	a2,0x2
ffffffffc0204970:	2bc60613          	addi	a2,a2,700 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204974:	08000593          	li	a1,128
ffffffffc0204978:	00003517          	auipc	a0,0x3
ffffffffc020497c:	6a050513          	addi	a0,a0,1696 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204980:	897fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204984 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0204984:	c959                	beqz	a0,ffffffffc0204a1a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0204986:	000a8597          	auipc	a1,0xa8
ffffffffc020498a:	bca58593          	addi	a1,a1,-1078 # ffffffffc02ac550 <free_area>
ffffffffc020498e:	0105a803          	lw	a6,16(a1)
ffffffffc0204992:	862a                	mv	a2,a0
ffffffffc0204994:	02081793          	slli	a5,a6,0x20
ffffffffc0204998:	9381                	srli	a5,a5,0x20
ffffffffc020499a:	00a7ee63          	bltu	a5,a0,ffffffffc02049b6 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020499e:	87ae                	mv	a5,a1
ffffffffc02049a0:	a801                	j	ffffffffc02049b0 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02049a2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02049a6:	02071693          	slli	a3,a4,0x20
ffffffffc02049aa:	9281                	srli	a3,a3,0x20
ffffffffc02049ac:	00c6f763          	bleu	a2,a3,ffffffffc02049ba <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02049b0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02049b2:	feb798e3          	bne	a5,a1,ffffffffc02049a2 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02049b6:	4501                	li	a0,0
}
ffffffffc02049b8:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02049ba:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02049be:	dd6d                	beqz	a0,ffffffffc02049b8 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02049c0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02049c4:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02049c8:	00060e1b          	sext.w	t3,a2
ffffffffc02049cc:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3a90>
    next->prev = prev;
ffffffffc02049d0:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5588>
        if (page->property > n) {
ffffffffc02049d4:	02d67863          	bleu	a3,a2,ffffffffc0204a04 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02049d8:	061a                	slli	a2,a2,0x6
ffffffffc02049da:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02049dc:	41c7073b          	subw	a4,a4,t3
ffffffffc02049e0:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02049e2:	00860693          	addi	a3,a2,8
ffffffffc02049e6:	4709                	li	a4,2
ffffffffc02049e8:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02049ec:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02049f0:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc02049f4:	0105a803          	lw	a6,16(a1)
ffffffffc02049f8:	e314                	sd	a3,0(a4)
ffffffffc02049fa:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02049fe:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0204a00:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0204a04:	41c8083b          	subw	a6,a6,t3
ffffffffc0204a08:	000a8717          	auipc	a4,0xa8
ffffffffc0204a0c:	b5072c23          	sw	a6,-1192(a4) # ffffffffc02ac560 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204a10:	5775                	li	a4,-3
ffffffffc0204a12:	17c1                	addi	a5,a5,-16
ffffffffc0204a14:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0204a18:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204a1a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204a1c:	00004697          	auipc	a3,0x4
ffffffffc0204a20:	93468693          	addi	a3,a3,-1740 # ffffffffc0208350 <commands+0x1ba8>
ffffffffc0204a24:	00002617          	auipc	a2,0x2
ffffffffc0204a28:	20460613          	addi	a2,a2,516 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204a2c:	06200593          	li	a1,98
ffffffffc0204a30:	00003517          	auipc	a0,0x3
ffffffffc0204a34:	5e850513          	addi	a0,a0,1512 # ffffffffc0208018 <commands+0x1870>
default_alloc_pages(size_t n) {
ffffffffc0204a38:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a3a:	fdcfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204a3e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204a3e:	1141                	addi	sp,sp,-16
ffffffffc0204a40:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a42:	c1ed                	beqz	a1,ffffffffc0204b24 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0204a44:	00659693          	slli	a3,a1,0x6
ffffffffc0204a48:	96aa                	add	a3,a3,a0
ffffffffc0204a4a:	02d50463          	beq	a0,a3,ffffffffc0204a72 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204a4e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0204a50:	87aa                	mv	a5,a0
ffffffffc0204a52:	8b05                	andi	a4,a4,1
ffffffffc0204a54:	e709                	bnez	a4,ffffffffc0204a5e <default_init_memmap+0x20>
ffffffffc0204a56:	a07d                	j	ffffffffc0204b04 <default_init_memmap+0xc6>
ffffffffc0204a58:	6798                	ld	a4,8(a5)
ffffffffc0204a5a:	8b05                	andi	a4,a4,1
ffffffffc0204a5c:	c745                	beqz	a4,ffffffffc0204b04 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0204a5e:	0007a823          	sw	zero,16(a5)
ffffffffc0204a62:	0007b423          	sd	zero,8(a5)
ffffffffc0204a66:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204a6a:	04078793          	addi	a5,a5,64
ffffffffc0204a6e:	fed795e3          	bne	a5,a3,ffffffffc0204a58 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0204a72:	2581                	sext.w	a1,a1
ffffffffc0204a74:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204a76:	4789                	li	a5,2
ffffffffc0204a78:	00850713          	addi	a4,a0,8
ffffffffc0204a7c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204a80:	000a8697          	auipc	a3,0xa8
ffffffffc0204a84:	ad068693          	addi	a3,a3,-1328 # ffffffffc02ac550 <free_area>
ffffffffc0204a88:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204a8a:	669c                	ld	a5,8(a3)
ffffffffc0204a8c:	9db9                	addw	a1,a1,a4
ffffffffc0204a8e:	000a8717          	auipc	a4,0xa8
ffffffffc0204a92:	acb72923          	sw	a1,-1326(a4) # ffffffffc02ac560 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204a96:	04d78a63          	beq	a5,a3,ffffffffc0204aea <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0204a9a:	fe878713          	addi	a4,a5,-24
ffffffffc0204a9e:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204aa0:	4801                	li	a6,0
ffffffffc0204aa2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204aa6:	00e56a63          	bltu	a0,a4,ffffffffc0204aba <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0204aaa:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204aac:	02d70563          	beq	a4,a3,ffffffffc0204ad6 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204ab0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204ab2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204ab6:	fee57ae3          	bleu	a4,a0,ffffffffc0204aaa <default_init_memmap+0x6c>
ffffffffc0204aba:	00080663          	beqz	a6,ffffffffc0204ac6 <default_init_memmap+0x88>
ffffffffc0204abe:	000a8717          	auipc	a4,0xa8
ffffffffc0204ac2:	a8b73923          	sd	a1,-1390(a4) # ffffffffc02ac550 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204ac6:	6398                	ld	a4,0(a5)
}
ffffffffc0204ac8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204aca:	e390                	sd	a2,0(a5)
ffffffffc0204acc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204ace:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204ad0:	ed18                	sd	a4,24(a0)
ffffffffc0204ad2:	0141                	addi	sp,sp,16
ffffffffc0204ad4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204ad6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204ad8:	f114                	sd	a3,32(a0)
ffffffffc0204ada:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204adc:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0204ade:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204ae0:	00d70e63          	beq	a4,a3,ffffffffc0204afc <default_init_memmap+0xbe>
ffffffffc0204ae4:	4805                	li	a6,1
ffffffffc0204ae6:	87ba                	mv	a5,a4
ffffffffc0204ae8:	b7e9                	j	ffffffffc0204ab2 <default_init_memmap+0x74>
}
ffffffffc0204aea:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204aec:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204af0:	e398                	sd	a4,0(a5)
ffffffffc0204af2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204af4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204af6:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204af8:	0141                	addi	sp,sp,16
ffffffffc0204afa:	8082                	ret
ffffffffc0204afc:	60a2                	ld	ra,8(sp)
ffffffffc0204afe:	e290                	sd	a2,0(a3)
ffffffffc0204b00:	0141                	addi	sp,sp,16
ffffffffc0204b02:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204b04:	00004697          	auipc	a3,0x4
ffffffffc0204b08:	85468693          	addi	a3,a3,-1964 # ffffffffc0208358 <commands+0x1bb0>
ffffffffc0204b0c:	00002617          	auipc	a2,0x2
ffffffffc0204b10:	11c60613          	addi	a2,a2,284 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204b14:	04900593          	li	a1,73
ffffffffc0204b18:	00003517          	auipc	a0,0x3
ffffffffc0204b1c:	50050513          	addi	a0,a0,1280 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204b20:	ef6fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc0204b24:	00004697          	auipc	a3,0x4
ffffffffc0204b28:	82c68693          	addi	a3,a3,-2004 # ffffffffc0208350 <commands+0x1ba8>
ffffffffc0204b2c:	00002617          	auipc	a2,0x2
ffffffffc0204b30:	0fc60613          	addi	a2,a2,252 # ffffffffc0206c28 <commands+0x480>
ffffffffc0204b34:	04600593          	li	a1,70
ffffffffc0204b38:	00003517          	auipc	a0,0x3
ffffffffc0204b3c:	4e050513          	addi	a0,a0,1248 # ffffffffc0208018 <commands+0x1870>
ffffffffc0204b40:	ed6fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b44 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b44:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b46:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b48:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b4a:	9ebfb0ef          	jal	ra,ffffffffc0200534 <ide_device_valid>
ffffffffc0204b4e:	cd01                	beqz	a0,ffffffffc0204b66 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b50:	4505                	li	a0,1
ffffffffc0204b52:	9e9fb0ef          	jal	ra,ffffffffc020053a <ide_device_size>
}
ffffffffc0204b56:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b58:	810d                	srli	a0,a0,0x3
ffffffffc0204b5a:	000a8797          	auipc	a5,0xa8
ffffffffc0204b5e:	9aa7b323          	sd	a0,-1626(a5) # ffffffffc02ac500 <max_swap_offset>
}
ffffffffc0204b62:	0141                	addi	sp,sp,16
ffffffffc0204b64:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b66:	00004617          	auipc	a2,0x4
ffffffffc0204b6a:	85260613          	addi	a2,a2,-1966 # ffffffffc02083b8 <default_pmm_manager+0x50>
ffffffffc0204b6e:	45b5                	li	a1,13
ffffffffc0204b70:	00004517          	auipc	a0,0x4
ffffffffc0204b74:	86850513          	addi	a0,a0,-1944 # ffffffffc02083d8 <default_pmm_manager+0x70>
ffffffffc0204b78:	e9efb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b7c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b7c:	1141                	addi	sp,sp,-16
ffffffffc0204b7e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b80:	00855793          	srli	a5,a0,0x8
ffffffffc0204b84:	cfb9                	beqz	a5,ffffffffc0204be2 <swapfs_read+0x66>
ffffffffc0204b86:	000a8717          	auipc	a4,0xa8
ffffffffc0204b8a:	97a70713          	addi	a4,a4,-1670 # ffffffffc02ac500 <max_swap_offset>
ffffffffc0204b8e:	6318                	ld	a4,0(a4)
ffffffffc0204b90:	04e7f963          	bleu	a4,a5,ffffffffc0204be2 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b94:	000a8717          	auipc	a4,0xa8
ffffffffc0204b98:	8d470713          	addi	a4,a4,-1836 # ffffffffc02ac468 <pages>
ffffffffc0204b9c:	6310                	ld	a2,0(a4)
ffffffffc0204b9e:	00004717          	auipc	a4,0x4
ffffffffc0204ba2:	18a70713          	addi	a4,a4,394 # ffffffffc0208d28 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204ba6:	000a8697          	auipc	a3,0xa8
ffffffffc0204baa:	85a68693          	addi	a3,a3,-1958 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0204bae:	40c58633          	sub	a2,a1,a2
ffffffffc0204bb2:	630c                	ld	a1,0(a4)
ffffffffc0204bb4:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204bb6:	577d                	li	a4,-1
ffffffffc0204bb8:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204bba:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bbc:	8331                	srli	a4,a4,0xc
ffffffffc0204bbe:	8f71                	and	a4,a4,a2
ffffffffc0204bc0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bc4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bc6:	02d77a63          	bleu	a3,a4,ffffffffc0204bfa <swapfs_read+0x7e>
ffffffffc0204bca:	000a8797          	auipc	a5,0xa8
ffffffffc0204bce:	88e78793          	addi	a5,a5,-1906 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204bd2:	639c                	ld	a5,0(a5)
}
ffffffffc0204bd4:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bd6:	46a1                	li	a3,8
ffffffffc0204bd8:	963e                	add	a2,a2,a5
ffffffffc0204bda:	4505                	li	a0,1
}
ffffffffc0204bdc:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bde:	963fb06f          	j	ffffffffc0200540 <ide_read_secs>
ffffffffc0204be2:	86aa                	mv	a3,a0
ffffffffc0204be4:	00004617          	auipc	a2,0x4
ffffffffc0204be8:	80c60613          	addi	a2,a2,-2036 # ffffffffc02083f0 <default_pmm_manager+0x88>
ffffffffc0204bec:	45d1                	li	a1,20
ffffffffc0204bee:	00003517          	auipc	a0,0x3
ffffffffc0204bf2:	7ea50513          	addi	a0,a0,2026 # ffffffffc02083d8 <default_pmm_manager+0x70>
ffffffffc0204bf6:	e20fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204bfa:	86b2                	mv	a3,a2
ffffffffc0204bfc:	06900593          	li	a1,105
ffffffffc0204c00:	00002617          	auipc	a2,0x2
ffffffffc0204c04:	41060613          	addi	a2,a2,1040 # ffffffffc0207010 <commands+0x868>
ffffffffc0204c08:	00002517          	auipc	a0,0x2
ffffffffc0204c0c:	46050513          	addi	a0,a0,1120 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0204c10:	e06fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c14 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c14:	1141                	addi	sp,sp,-16
ffffffffc0204c16:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c18:	00855793          	srli	a5,a0,0x8
ffffffffc0204c1c:	cfb9                	beqz	a5,ffffffffc0204c7a <swapfs_write+0x66>
ffffffffc0204c1e:	000a8717          	auipc	a4,0xa8
ffffffffc0204c22:	8e270713          	addi	a4,a4,-1822 # ffffffffc02ac500 <max_swap_offset>
ffffffffc0204c26:	6318                	ld	a4,0(a4)
ffffffffc0204c28:	04e7f963          	bleu	a4,a5,ffffffffc0204c7a <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c2c:	000a8717          	auipc	a4,0xa8
ffffffffc0204c30:	83c70713          	addi	a4,a4,-1988 # ffffffffc02ac468 <pages>
ffffffffc0204c34:	6310                	ld	a2,0(a4)
ffffffffc0204c36:	00004717          	auipc	a4,0x4
ffffffffc0204c3a:	0f270713          	addi	a4,a4,242 # ffffffffc0208d28 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c3e:	000a7697          	auipc	a3,0xa7
ffffffffc0204c42:	7c268693          	addi	a3,a3,1986 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0204c46:	40c58633          	sub	a2,a1,a2
ffffffffc0204c4a:	630c                	ld	a1,0(a4)
ffffffffc0204c4c:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c4e:	577d                	li	a4,-1
ffffffffc0204c50:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c52:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c54:	8331                	srli	a4,a4,0xc
ffffffffc0204c56:	8f71                	and	a4,a4,a2
ffffffffc0204c58:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c5c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c5e:	02d77a63          	bleu	a3,a4,ffffffffc0204c92 <swapfs_write+0x7e>
ffffffffc0204c62:	000a7797          	auipc	a5,0xa7
ffffffffc0204c66:	7f678793          	addi	a5,a5,2038 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204c6a:	639c                	ld	a5,0(a5)
}
ffffffffc0204c6c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c6e:	46a1                	li	a3,8
ffffffffc0204c70:	963e                	add	a2,a2,a5
ffffffffc0204c72:	4505                	li	a0,1
}
ffffffffc0204c74:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c76:	8effb06f          	j	ffffffffc0200564 <ide_write_secs>
ffffffffc0204c7a:	86aa                	mv	a3,a0
ffffffffc0204c7c:	00003617          	auipc	a2,0x3
ffffffffc0204c80:	77460613          	addi	a2,a2,1908 # ffffffffc02083f0 <default_pmm_manager+0x88>
ffffffffc0204c84:	45e5                	li	a1,25
ffffffffc0204c86:	00003517          	auipc	a0,0x3
ffffffffc0204c8a:	75250513          	addi	a0,a0,1874 # ffffffffc02083d8 <default_pmm_manager+0x70>
ffffffffc0204c8e:	d88fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204c92:	86b2                	mv	a3,a2
ffffffffc0204c94:	06900593          	li	a1,105
ffffffffc0204c98:	00002617          	auipc	a2,0x2
ffffffffc0204c9c:	37860613          	addi	a2,a2,888 # ffffffffc0207010 <commands+0x868>
ffffffffc0204ca0:	00002517          	auipc	a0,0x2
ffffffffc0204ca4:	3c850513          	addi	a0,a0,968 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0204ca8:	d6efb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204cac <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204cac:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204cae:	9402                	jalr	s0

	jal do_exit
ffffffffc0204cb0:	79c000ef          	jal	ra,ffffffffc020544c <do_exit>

ffffffffc0204cb4 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204cb4:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204cb8:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204cbc:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204cbe:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204cc0:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204cc4:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204cc8:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204ccc:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204cd0:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204cd4:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204cd8:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204cdc:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204ce0:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204ce4:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204ce8:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204cec:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204cf0:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204cf2:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204cf4:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204cf8:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204cfc:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204d00:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204d04:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204d08:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204d0c:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204d10:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204d14:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204d18:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204d1c:	8082                	ret

ffffffffc0204d1e <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d1e:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d20:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d24:	e022                	sd	s0,0(sp)
ffffffffc0204d26:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d28:	d07fe0ef          	jal	ra,ffffffffc0203a2e <kmalloc>
ffffffffc0204d2c:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d2e:	cd29                	beqz	a0,ffffffffc0204d88 <alloc_proc+0x6a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT;  //设置进程为未初始化状态
ffffffffc0204d30:	57fd                	li	a5,-1
ffffffffc0204d32:	1782                	slli	a5,a5,0x20
ffffffffc0204d34:	e11c                	sd	a5,0(a0)
    proc->runs = 0;             //初始化时间片
    proc->kstack = 0;           //内存栈的地址
    proc->need_resched = 0;     //是否需要调度设为不需要
    proc->parent = NULL;        //父节点设为空
    proc->mm = NULL;            //虚拟内存设为空
    memset(&(proc->context), 0, sizeof(struct context));//上下文的初始化
ffffffffc0204d36:	07000613          	li	a2,112
ffffffffc0204d3a:	4581                	li	a1,0
    proc->runs = 0;             //初始化时间片
ffffffffc0204d3c:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;           //内存栈的地址
ffffffffc0204d40:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;     //是否需要调度设为不需要
ffffffffc0204d44:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;        //父节点设为空
ffffffffc0204d48:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;            //虚拟内存设为空
ffffffffc0204d4c:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));//上下文的初始化
ffffffffc0204d50:	03050513          	addi	a0,a0,48
ffffffffc0204d54:	4a4010ef          	jal	ra,ffffffffc02061f8 <memset>
    proc->tf = NULL;            //中断帧指针置为空
    proc->cr3 = boot_cr3;       //页目录设为内核页目录表的基址
ffffffffc0204d58:	000a7797          	auipc	a5,0xa7
ffffffffc0204d5c:	70878793          	addi	a5,a5,1800 # ffffffffc02ac460 <boot_cr3>
ffffffffc0204d60:	639c                	ld	a5,0(a5)
    proc->tf = NULL;            //中断帧指针置为空
ffffffffc0204d62:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;            //标志位
ffffffffc0204d66:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;       //页目录设为内核页目录表的基址
ffffffffc0204d6a:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN);//进程名
ffffffffc0204d6c:	463d                	li	a2,15
ffffffffc0204d6e:	4581                	li	a1,0
ffffffffc0204d70:	0b440513          	addi	a0,s0,180
ffffffffc0204d74:	484010ef          	jal	ra,ffffffffc02061f8 <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state=0;//初始化进程等待状态
ffffffffc0204d78:	0e042623          	sw	zero,236(s0)
    proc->cptr=proc->optr=proc->yptr=NULL;//进程相关指针初始化
ffffffffc0204d7c:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d80:	10043023          	sd	zero,256(s0)
ffffffffc0204d84:	0e043823          	sd	zero,240(s0)

    }
    return proc;
}
ffffffffc0204d88:	8522                	mv	a0,s0
ffffffffc0204d8a:	60a2                	ld	ra,8(sp)
ffffffffc0204d8c:	6402                	ld	s0,0(sp)
ffffffffc0204d8e:	0141                	addi	sp,sp,16
ffffffffc0204d90:	8082                	ret

ffffffffc0204d92 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d92:	000a7797          	auipc	a5,0xa7
ffffffffc0204d96:	69678793          	addi	a5,a5,1686 # ffffffffc02ac428 <current>
ffffffffc0204d9a:	639c                	ld	a5,0(a5)
ffffffffc0204d9c:	73c8                	ld	a0,160(a5)
ffffffffc0204d9e:	80cfc06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204da2 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204da2:	000a7797          	auipc	a5,0xa7
ffffffffc0204da6:	68678793          	addi	a5,a5,1670 # ffffffffc02ac428 <current>
ffffffffc0204daa:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204dac:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dae:	00004617          	auipc	a2,0x4
ffffffffc0204db2:	a4a60613          	addi	a2,a2,-1462 # ffffffffc02087f8 <default_pmm_manager+0x490>
ffffffffc0204db6:	43cc                	lw	a1,4(a5)
ffffffffc0204db8:	00004517          	auipc	a0,0x4
ffffffffc0204dbc:	a5050513          	addi	a0,a0,-1456 # ffffffffc0208808 <default_pmm_manager+0x4a0>
user_main(void *arg) {
ffffffffc0204dc0:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dc2:	b0efb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204dc6:	00004797          	auipc	a5,0x4
ffffffffc0204dca:	a3278793          	addi	a5,a5,-1486 # ffffffffc02087f8 <default_pmm_manager+0x490>
ffffffffc0204dce:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204dd2:	50a70713          	addi	a4,a4,1290 # a2d8 <_binary_obj___user_forktest_out_size>
ffffffffc0204dd6:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204dd8:	853e                	mv	a0,a5
ffffffffc0204dda:	00088717          	auipc	a4,0x88
ffffffffc0204dde:	76e70713          	addi	a4,a4,1902 # ffffffffc028d548 <_binary_obj___user_forktest_out_start>
ffffffffc0204de2:	f03a                	sd	a4,32(sp)
ffffffffc0204de4:	f43e                	sd	a5,40(sp)
ffffffffc0204de6:	e802                	sd	zero,16(sp)
ffffffffc0204de8:	372010ef          	jal	ra,ffffffffc020615a <strlen>
ffffffffc0204dec:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204dee:	4511                	li	a0,4
ffffffffc0204df0:	55a2                	lw	a1,40(sp)
ffffffffc0204df2:	4662                	lw	a2,24(sp)
ffffffffc0204df4:	5682                	lw	a3,32(sp)
ffffffffc0204df6:	4722                	lw	a4,8(sp)
ffffffffc0204df8:	48a9                	li	a7,10
ffffffffc0204dfa:	9002                	ebreak
ffffffffc0204dfc:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204dfe:	65c2                	ld	a1,16(sp)
ffffffffc0204e00:	00004517          	auipc	a0,0x4
ffffffffc0204e04:	a3050513          	addi	a0,a0,-1488 # ffffffffc0208830 <default_pmm_manager+0x4c8>
ffffffffc0204e08:	ac8fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e0c:	00004617          	auipc	a2,0x4
ffffffffc0204e10:	a3460613          	addi	a2,a2,-1484 # ffffffffc0208840 <default_pmm_manager+0x4d8>
ffffffffc0204e14:	34900593          	li	a1,841
ffffffffc0204e18:	00004517          	auipc	a0,0x4
ffffffffc0204e1c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0204e20:	bf6fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204e24 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e24:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e26:	1141                	addi	sp,sp,-16
ffffffffc0204e28:	e406                	sd	ra,8(sp)
ffffffffc0204e2a:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e2e:	04f6e263          	bltu	a3,a5,ffffffffc0204e72 <put_pgdir+0x4e>
ffffffffc0204e32:	000a7797          	auipc	a5,0xa7
ffffffffc0204e36:	62678793          	addi	a5,a5,1574 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204e3a:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204e3c:	000a7797          	auipc	a5,0xa7
ffffffffc0204e40:	5c478793          	addi	a5,a5,1476 # ffffffffc02ac400 <npage>
ffffffffc0204e44:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204e46:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e48:	82b1                	srli	a3,a3,0xc
ffffffffc0204e4a:	04f6f063          	bleu	a5,a3,ffffffffc0204e8a <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e4e:	00004797          	auipc	a5,0x4
ffffffffc0204e52:	eda78793          	addi	a5,a5,-294 # ffffffffc0208d28 <nbase>
ffffffffc0204e56:	639c                	ld	a5,0(a5)
ffffffffc0204e58:	000a7717          	auipc	a4,0xa7
ffffffffc0204e5c:	61070713          	addi	a4,a4,1552 # ffffffffc02ac468 <pages>
ffffffffc0204e60:	6308                	ld	a0,0(a4)
}
ffffffffc0204e62:	60a2                	ld	ra,8(sp)
ffffffffc0204e64:	8e9d                	sub	a3,a3,a5
ffffffffc0204e66:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e68:	4585                	li	a1,1
ffffffffc0204e6a:	9536                	add	a0,a0,a3
}
ffffffffc0204e6c:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e6e:	88cfc06f          	j	ffffffffc0200efa <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e72:	00002617          	auipc	a2,0x2
ffffffffc0204e76:	27660613          	addi	a2,a2,630 # ffffffffc02070e8 <commands+0x940>
ffffffffc0204e7a:	06e00593          	li	a1,110
ffffffffc0204e7e:	00002517          	auipc	a0,0x2
ffffffffc0204e82:	1ea50513          	addi	a0,a0,490 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0204e86:	b90fb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e8a:	00002617          	auipc	a2,0x2
ffffffffc0204e8e:	1be60613          	addi	a2,a2,446 # ffffffffc0207048 <commands+0x8a0>
ffffffffc0204e92:	06200593          	li	a1,98
ffffffffc0204e96:	00002517          	auipc	a0,0x2
ffffffffc0204e9a:	1d250513          	addi	a0,a0,466 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0204e9e:	b78fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204ea2 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204ea2:	1101                	addi	sp,sp,-32
ffffffffc0204ea4:	e426                	sd	s1,8(sp)
ffffffffc0204ea6:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204ea8:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204eaa:	ec06                	sd	ra,24(sp)
ffffffffc0204eac:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204eae:	fc5fb0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204eb2:	c125                	beqz	a0,ffffffffc0204f12 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204eb4:	000a7797          	auipc	a5,0xa7
ffffffffc0204eb8:	5b478793          	addi	a5,a5,1460 # ffffffffc02ac468 <pages>
ffffffffc0204ebc:	6394                	ld	a3,0(a5)
ffffffffc0204ebe:	00004797          	auipc	a5,0x4
ffffffffc0204ec2:	e6a78793          	addi	a5,a5,-406 # ffffffffc0208d28 <nbase>
ffffffffc0204ec6:	6380                	ld	s0,0(a5)
ffffffffc0204ec8:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204ecc:	000a7717          	auipc	a4,0xa7
ffffffffc0204ed0:	53470713          	addi	a4,a4,1332 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc0204ed4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204ed6:	57fd                	li	a5,-1
ffffffffc0204ed8:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204eda:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204edc:	83b1                	srli	a5,a5,0xc
ffffffffc0204ede:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ee0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ee2:	02e7fa63          	bleu	a4,a5,ffffffffc0204f16 <setup_pgdir+0x74>
ffffffffc0204ee6:	000a7797          	auipc	a5,0xa7
ffffffffc0204eea:	57278793          	addi	a5,a5,1394 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0204eee:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204ef0:	000a7797          	auipc	a5,0xa7
ffffffffc0204ef4:	50878793          	addi	a5,a5,1288 # ffffffffc02ac3f8 <boot_pgdir>
ffffffffc0204ef8:	638c                	ld	a1,0(a5)
ffffffffc0204efa:	9436                	add	s0,s0,a3
ffffffffc0204efc:	6605                	lui	a2,0x1
ffffffffc0204efe:	8522                	mv	a0,s0
ffffffffc0204f00:	30a010ef          	jal	ra,ffffffffc020620a <memcpy>
    return 0;
ffffffffc0204f04:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204f06:	ec80                	sd	s0,24(s1)
}
ffffffffc0204f08:	60e2                	ld	ra,24(sp)
ffffffffc0204f0a:	6442                	ld	s0,16(sp)
ffffffffc0204f0c:	64a2                	ld	s1,8(sp)
ffffffffc0204f0e:	6105                	addi	sp,sp,32
ffffffffc0204f10:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204f12:	5571                	li	a0,-4
ffffffffc0204f14:	bfd5                	j	ffffffffc0204f08 <setup_pgdir+0x66>
ffffffffc0204f16:	00002617          	auipc	a2,0x2
ffffffffc0204f1a:	0fa60613          	addi	a2,a2,250 # ffffffffc0207010 <commands+0x868>
ffffffffc0204f1e:	06900593          	li	a1,105
ffffffffc0204f22:	00002517          	auipc	a0,0x2
ffffffffc0204f26:	14650513          	addi	a0,a0,326 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0204f2a:	aecfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204f2e <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f2e:	1101                	addi	sp,sp,-32
ffffffffc0204f30:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f32:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f36:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f38:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f3a:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f3c:	8522                	mv	a0,s0
ffffffffc0204f3e:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f40:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f42:	2b6010ef          	jal	ra,ffffffffc02061f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f46:	8522                	mv	a0,s0
}
ffffffffc0204f48:	6442                	ld	s0,16(sp)
ffffffffc0204f4a:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f4c:	85a6                	mv	a1,s1
}
ffffffffc0204f4e:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f50:	463d                	li	a2,15
}
ffffffffc0204f52:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f54:	2b60106f          	j	ffffffffc020620a <memcpy>

ffffffffc0204f58 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f58:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204f5a:	000a7797          	auipc	a5,0xa7
ffffffffc0204f5e:	4ce78793          	addi	a5,a5,1230 # ffffffffc02ac428 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f62:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f64:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f66:	ec06                	sd	ra,24(sp)
ffffffffc0204f68:	e822                	sd	s0,16(sp)
ffffffffc0204f6a:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f6c:	02a48b63          	beq	s1,a0,ffffffffc0204fa2 <proc_run+0x4a>
ffffffffc0204f70:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f72:	100027f3          	csrr	a5,sstatus
ffffffffc0204f76:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f78:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f7a:	e3a9                	bnez	a5,ffffffffc0204fbc <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f7c:	745c                	ld	a5,168(s0)
            current=proc;
ffffffffc0204f7e:	000a7717          	auipc	a4,0xa7
ffffffffc0204f82:	4a873523          	sd	s0,1194(a4) # ffffffffc02ac428 <current>
ffffffffc0204f86:	577d                	li	a4,-1
ffffffffc0204f88:	177e                	slli	a4,a4,0x3f
ffffffffc0204f8a:	83b1                	srli	a5,a5,0xc
ffffffffc0204f8c:	8fd9                	or	a5,a5,a4
ffffffffc0204f8e:	18079073          	csrw	satp,a5
            switch_to(&(prev->context),&(next->context));
ffffffffc0204f92:	03040593          	addi	a1,s0,48
ffffffffc0204f96:	03048513          	addi	a0,s1,48
ffffffffc0204f9a:	d1bff0ef          	jal	ra,ffffffffc0204cb4 <switch_to>
    if (flag) {
ffffffffc0204f9e:	00091863          	bnez	s2,ffffffffc0204fae <proc_run+0x56>
}
ffffffffc0204fa2:	60e2                	ld	ra,24(sp)
ffffffffc0204fa4:	6442                	ld	s0,16(sp)
ffffffffc0204fa6:	64a2                	ld	s1,8(sp)
ffffffffc0204fa8:	6902                	ld	s2,0(sp)
ffffffffc0204faa:	6105                	addi	sp,sp,32
ffffffffc0204fac:	8082                	ret
ffffffffc0204fae:	6442                	ld	s0,16(sp)
ffffffffc0204fb0:	60e2                	ld	ra,24(sp)
ffffffffc0204fb2:	64a2                	ld	s1,8(sp)
ffffffffc0204fb4:	6902                	ld	s2,0(sp)
ffffffffc0204fb6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204fb8:	e9efb06f          	j	ffffffffc0200656 <intr_enable>
        intr_disable();
ffffffffc0204fbc:	ea0fb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0204fc0:	4905                	li	s2,1
ffffffffc0204fc2:	bf6d                	j	ffffffffc0204f7c <proc_run+0x24>

ffffffffc0204fc4 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204fc4:	0005071b          	sext.w	a4,a0
ffffffffc0204fc8:	6789                	lui	a5,0x2
ffffffffc0204fca:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204fce:	17f9                	addi	a5,a5,-2
ffffffffc0204fd0:	04d7e063          	bltu	a5,a3,ffffffffc0205010 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204fd4:	1141                	addi	sp,sp,-16
ffffffffc0204fd6:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fd8:	45a9                	li	a1,10
ffffffffc0204fda:	842a                	mv	s0,a0
ffffffffc0204fdc:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204fde:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fe0:	63a010ef          	jal	ra,ffffffffc020661a <hash32>
ffffffffc0204fe4:	02051693          	slli	a3,a0,0x20
ffffffffc0204fe8:	82f1                	srli	a3,a3,0x1c
ffffffffc0204fea:	000a3517          	auipc	a0,0xa3
ffffffffc0204fee:	3fe50513          	addi	a0,a0,1022 # ffffffffc02a83e8 <hash_list>
ffffffffc0204ff2:	96aa                	add	a3,a3,a0
ffffffffc0204ff4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204ff6:	a029                	j	ffffffffc0205000 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204ff8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7644>
ffffffffc0204ffc:	00870c63          	beq	a4,s0,ffffffffc0205014 <find_proc+0x50>
    return listelm->next;
ffffffffc0205000:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205002:	fef69be3          	bne	a3,a5,ffffffffc0204ff8 <find_proc+0x34>
}
ffffffffc0205006:	60a2                	ld	ra,8(sp)
ffffffffc0205008:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020500a:	4501                	li	a0,0
}
ffffffffc020500c:	0141                	addi	sp,sp,16
ffffffffc020500e:	8082                	ret
    return NULL;
ffffffffc0205010:	4501                	li	a0,0
}
ffffffffc0205012:	8082                	ret
ffffffffc0205014:	60a2                	ld	ra,8(sp)
ffffffffc0205016:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205018:	f2878513          	addi	a0,a5,-216
}
ffffffffc020501c:	0141                	addi	sp,sp,16
ffffffffc020501e:	8082                	ret

ffffffffc0205020 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205020:	7159                	addi	sp,sp,-112
ffffffffc0205022:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205024:	000a7a17          	auipc	s4,0xa7
ffffffffc0205028:	41ca0a13          	addi	s4,s4,1052 # ffffffffc02ac440 <nr_process>
ffffffffc020502c:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205030:	f486                	sd	ra,104(sp)
ffffffffc0205032:	f0a2                	sd	s0,96(sp)
ffffffffc0205034:	eca6                	sd	s1,88(sp)
ffffffffc0205036:	e8ca                	sd	s2,80(sp)
ffffffffc0205038:	e4ce                	sd	s3,72(sp)
ffffffffc020503a:	fc56                	sd	s5,56(sp)
ffffffffc020503c:	f85a                	sd	s6,48(sp)
ffffffffc020503e:	f45e                	sd	s7,40(sp)
ffffffffc0205040:	f062                	sd	s8,32(sp)
ffffffffc0205042:	ec66                	sd	s9,24(sp)
ffffffffc0205044:	e86a                	sd	s10,16(sp)
ffffffffc0205046:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205048:	6785                	lui	a5,0x1
ffffffffc020504a:	30f75a63          	ble	a5,a4,ffffffffc020535e <do_fork+0x33e>
ffffffffc020504e:	89aa                	mv	s3,a0
ffffffffc0205050:	892e                	mv	s2,a1
ffffffffc0205052:	84b2                	mv	s1,a2
    if((proc=alloc_proc())==NULL){
ffffffffc0205054:	ccbff0ef          	jal	ra,ffffffffc0204d1e <alloc_proc>
ffffffffc0205058:	842a                	mv	s0,a0
ffffffffc020505a:	2e050463          	beqz	a0,ffffffffc0205342 <do_fork+0x322>
    proc->parent=current;
ffffffffc020505e:	000a7c17          	auipc	s8,0xa7
ffffffffc0205062:	3cac0c13          	addi	s8,s8,970 # ffffffffc02ac428 <current>
ffffffffc0205066:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state==0);
ffffffffc020506a:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8484>
    proc->parent=current;
ffffffffc020506e:	f11c                	sd	a5,32(a0)
    assert(current->wait_state==0);
ffffffffc0205070:	30071563          	bnez	a4,ffffffffc020537a <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205074:	4509                	li	a0,2
ffffffffc0205076:	dfdfb0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
    if (page != NULL) {
ffffffffc020507a:	2c050163          	beqz	a0,ffffffffc020533c <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc020507e:	000a7a97          	auipc	s5,0xa7
ffffffffc0205082:	3eaa8a93          	addi	s5,s5,1002 # ffffffffc02ac468 <pages>
ffffffffc0205086:	000ab683          	ld	a3,0(s5)
ffffffffc020508a:	00004b17          	auipc	s6,0x4
ffffffffc020508e:	c9eb0b13          	addi	s6,s6,-866 # ffffffffc0208d28 <nbase>
ffffffffc0205092:	000b3783          	ld	a5,0(s6)
ffffffffc0205096:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc020509a:	000a7b97          	auipc	s7,0xa7
ffffffffc020509e:	366b8b93          	addi	s7,s7,870 # ffffffffc02ac400 <npage>
    return page - pages + nbase;
ffffffffc02050a2:	8699                	srai	a3,a3,0x6
ffffffffc02050a4:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02050a6:	000bb703          	ld	a4,0(s7)
ffffffffc02050aa:	57fd                	li	a5,-1
ffffffffc02050ac:	83b1                	srli	a5,a5,0xc
ffffffffc02050ae:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02050b0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050b2:	2ae7f863          	bleu	a4,a5,ffffffffc0205362 <do_fork+0x342>
ffffffffc02050b6:	000a7c97          	auipc	s9,0xa7
ffffffffc02050ba:	3a2c8c93          	addi	s9,s9,930 # ffffffffc02ac458 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02050be:	000c3703          	ld	a4,0(s8)
ffffffffc02050c2:	000cb783          	ld	a5,0(s9)
ffffffffc02050c6:	02873c03          	ld	s8,40(a4)
ffffffffc02050ca:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02050cc:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc02050ce:	020c0863          	beqz	s8,ffffffffc02050fe <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc02050d2:	1009f993          	andi	s3,s3,256
ffffffffc02050d6:	1e098163          	beqz	s3,ffffffffc02052b8 <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02050da:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050de:	018c3783          	ld	a5,24(s8)
ffffffffc02050e2:	c02006b7          	lui	a3,0xc0200
ffffffffc02050e6:	2705                	addiw	a4,a4,1
ffffffffc02050e8:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc02050ec:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050f0:	2ad7e563          	bltu	a5,a3,ffffffffc020539a <do_fork+0x37a>
ffffffffc02050f4:	000cb703          	ld	a4,0(s9)
ffffffffc02050f8:	6814                	ld	a3,16(s0)
ffffffffc02050fa:	8f99                	sub	a5,a5,a4
ffffffffc02050fc:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050fe:	6789                	lui	a5,0x2
ffffffffc0205100:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>
ffffffffc0205104:	96be                	add	a3,a3,a5
ffffffffc0205106:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205108:	87b6                	mv	a5,a3
ffffffffc020510a:	12048813          	addi	a6,s1,288
ffffffffc020510e:	6088                	ld	a0,0(s1)
ffffffffc0205110:	648c                	ld	a1,8(s1)
ffffffffc0205112:	6890                	ld	a2,16(s1)
ffffffffc0205114:	6c98                	ld	a4,24(s1)
ffffffffc0205116:	e388                	sd	a0,0(a5)
ffffffffc0205118:	e78c                	sd	a1,8(a5)
ffffffffc020511a:	eb90                	sd	a2,16(a5)
ffffffffc020511c:	ef98                	sd	a4,24(a5)
ffffffffc020511e:	02048493          	addi	s1,s1,32
ffffffffc0205122:	02078793          	addi	a5,a5,32
ffffffffc0205126:	ff0494e3          	bne	s1,a6,ffffffffc020510e <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc020512a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020512e:	12090e63          	beqz	s2,ffffffffc020526a <do_fork+0x24a>
ffffffffc0205132:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205136:	00000797          	auipc	a5,0x0
ffffffffc020513a:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d92 <forkret>
ffffffffc020513e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205140:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205142:	100027f3          	csrr	a5,sstatus
ffffffffc0205146:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205148:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020514a:	12079f63          	bnez	a5,ffffffffc0205288 <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc020514e:	0009c797          	auipc	a5,0x9c
ffffffffc0205152:	e9278793          	addi	a5,a5,-366 # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc0205156:	439c                	lw	a5,0(a5)
ffffffffc0205158:	6709                	lui	a4,0x2
ffffffffc020515a:	0017851b          	addiw	a0,a5,1
ffffffffc020515e:	0009c697          	auipc	a3,0x9c
ffffffffc0205162:	e8a6a123          	sw	a0,-382(a3) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc0205166:	14e55263          	ble	a4,a0,ffffffffc02052aa <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc020516a:	0009c797          	auipc	a5,0x9c
ffffffffc020516e:	e7a78793          	addi	a5,a5,-390 # ffffffffc02a0fe4 <next_safe.1690>
ffffffffc0205172:	439c                	lw	a5,0(a5)
ffffffffc0205174:	000a7497          	auipc	s1,0xa7
ffffffffc0205178:	3f448493          	addi	s1,s1,1012 # ffffffffc02ac568 <proc_list>
ffffffffc020517c:	06f54063          	blt	a0,a5,ffffffffc02051dc <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205180:	6789                	lui	a5,0x2
ffffffffc0205182:	0009c717          	auipc	a4,0x9c
ffffffffc0205186:	e6f72123          	sw	a5,-414(a4) # ffffffffc02a0fe4 <next_safe.1690>
ffffffffc020518a:	4581                	li	a1,0
ffffffffc020518c:	87aa                	mv	a5,a0
ffffffffc020518e:	000a7497          	auipc	s1,0xa7
ffffffffc0205192:	3da48493          	addi	s1,s1,986 # ffffffffc02ac568 <proc_list>
    repeat:
ffffffffc0205196:	6889                	lui	a7,0x2
ffffffffc0205198:	882e                	mv	a6,a1
ffffffffc020519a:	6609                	lui	a2,0x2
        le = list;
ffffffffc020519c:	000a7697          	auipc	a3,0xa7
ffffffffc02051a0:	3cc68693          	addi	a3,a3,972 # ffffffffc02ac568 <proc_list>
ffffffffc02051a4:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02051a6:	00968f63          	beq	a3,s1,ffffffffc02051c4 <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc02051aa:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02051ae:	0ae78963          	beq	a5,a4,ffffffffc0205260 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02051b2:	fee7d9e3          	ble	a4,a5,ffffffffc02051a4 <do_fork+0x184>
ffffffffc02051b6:	fec757e3          	ble	a2,a4,ffffffffc02051a4 <do_fork+0x184>
ffffffffc02051ba:	6694                	ld	a3,8(a3)
ffffffffc02051bc:	863a                	mv	a2,a4
ffffffffc02051be:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc02051c0:	fe9695e3          	bne	a3,s1,ffffffffc02051aa <do_fork+0x18a>
ffffffffc02051c4:	c591                	beqz	a1,ffffffffc02051d0 <do_fork+0x1b0>
ffffffffc02051c6:	0009c717          	auipc	a4,0x9c
ffffffffc02051ca:	e0f72d23          	sw	a5,-486(a4) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc02051ce:	853e                	mv	a0,a5
ffffffffc02051d0:	00080663          	beqz	a6,ffffffffc02051dc <do_fork+0x1bc>
ffffffffc02051d4:	0009c797          	auipc	a5,0x9c
ffffffffc02051d8:	e0c7a823          	sw	a2,-496(a5) # ffffffffc02a0fe4 <next_safe.1690>
        proc->pid=get_pid();
ffffffffc02051dc:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051de:	45a9                	li	a1,10
ffffffffc02051e0:	2501                	sext.w	a0,a0
ffffffffc02051e2:	438010ef          	jal	ra,ffffffffc020661a <hash32>
ffffffffc02051e6:	1502                	slli	a0,a0,0x20
ffffffffc02051e8:	000a3797          	auipc	a5,0xa3
ffffffffc02051ec:	20078793          	addi	a5,a5,512 # ffffffffc02a83e8 <hash_list>
ffffffffc02051f0:	8171                	srli	a0,a0,0x1c
ffffffffc02051f2:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051f4:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051f6:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051f8:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02051fc:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051fe:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205200:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205202:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205204:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205208:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020520a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020520c:	e21c                	sd	a5,0(a2)
ffffffffc020520e:	000a7597          	auipc	a1,0xa7
ffffffffc0205212:	36f5b123          	sd	a5,866(a1) # ffffffffc02ac570 <proc_list+0x8>
    elm->next = next;
ffffffffc0205216:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0205218:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc020521a:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020521e:	10e43023          	sd	a4,256(s0)
ffffffffc0205222:	c311                	beqz	a4,ffffffffc0205226 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc0205224:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205226:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc020522a:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc020522c:	2785                	addiw	a5,a5,1
ffffffffc020522e:	000a7717          	auipc	a4,0xa7
ffffffffc0205232:	20f72923          	sw	a5,530(a4) # ffffffffc02ac440 <nr_process>
    if (flag) {
ffffffffc0205236:	10091863          	bnez	s2,ffffffffc0205346 <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc020523a:	8522                	mv	a0,s0
ffffffffc020523c:	52d000ef          	jal	ra,ffffffffc0205f68 <wakeup_proc>
    ret=proc->pid;
ffffffffc0205240:	4048                	lw	a0,4(s0)
}
ffffffffc0205242:	70a6                	ld	ra,104(sp)
ffffffffc0205244:	7406                	ld	s0,96(sp)
ffffffffc0205246:	64e6                	ld	s1,88(sp)
ffffffffc0205248:	6946                	ld	s2,80(sp)
ffffffffc020524a:	69a6                	ld	s3,72(sp)
ffffffffc020524c:	6a06                	ld	s4,64(sp)
ffffffffc020524e:	7ae2                	ld	s5,56(sp)
ffffffffc0205250:	7b42                	ld	s6,48(sp)
ffffffffc0205252:	7ba2                	ld	s7,40(sp)
ffffffffc0205254:	7c02                	ld	s8,32(sp)
ffffffffc0205256:	6ce2                	ld	s9,24(sp)
ffffffffc0205258:	6d42                	ld	s10,16(sp)
ffffffffc020525a:	6da2                	ld	s11,8(sp)
ffffffffc020525c:	6165                	addi	sp,sp,112
ffffffffc020525e:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205260:	2785                	addiw	a5,a5,1
ffffffffc0205262:	0ec7d563          	ble	a2,a5,ffffffffc020534c <do_fork+0x32c>
ffffffffc0205266:	4585                	li	a1,1
ffffffffc0205268:	bf35                	j	ffffffffc02051a4 <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020526a:	8936                	mv	s2,a3
ffffffffc020526c:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205270:	00000797          	auipc	a5,0x0
ffffffffc0205274:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d92 <forkret>
ffffffffc0205278:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020527a:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020527c:	100027f3          	csrr	a5,sstatus
ffffffffc0205280:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205282:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205284:	ec0785e3          	beqz	a5,ffffffffc020514e <do_fork+0x12e>
        intr_disable();
ffffffffc0205288:	bd4fb0ef          	jal	ra,ffffffffc020065c <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc020528c:	0009c797          	auipc	a5,0x9c
ffffffffc0205290:	d5478793          	addi	a5,a5,-684 # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc0205294:	439c                	lw	a5,0(a5)
ffffffffc0205296:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205298:	4905                	li	s2,1
ffffffffc020529a:	0017851b          	addiw	a0,a5,1
ffffffffc020529e:	0009c697          	auipc	a3,0x9c
ffffffffc02052a2:	d4a6a123          	sw	a0,-702(a3) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc02052a6:	ece542e3          	blt	a0,a4,ffffffffc020516a <do_fork+0x14a>
        last_pid = 1;
ffffffffc02052aa:	4785                	li	a5,1
ffffffffc02052ac:	0009c717          	auipc	a4,0x9c
ffffffffc02052b0:	d2f72a23          	sw	a5,-716(a4) # ffffffffc02a0fe0 <last_pid.1691>
ffffffffc02052b4:	4505                	li	a0,1
ffffffffc02052b6:	b5e9                	j	ffffffffc0205180 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc02052b8:	918fd0ef          	jal	ra,ffffffffc02023d0 <mm_create>
ffffffffc02052bc:	8d2a                	mv	s10,a0
ffffffffc02052be:	c539                	beqz	a0,ffffffffc020530c <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc02052c0:	be3ff0ef          	jal	ra,ffffffffc0204ea2 <setup_pgdir>
ffffffffc02052c4:	e949                	bnez	a0,ffffffffc0205356 <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02052c6:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02052ca:	4785                	li	a5,1
ffffffffc02052cc:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc02052d0:	8b85                	andi	a5,a5,1
ffffffffc02052d2:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02052d4:	c799                	beqz	a5,ffffffffc02052e2 <do_fork+0x2c2>
        schedule();
ffffffffc02052d6:	50f000ef          	jal	ra,ffffffffc0205fe4 <schedule>
ffffffffc02052da:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc02052de:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02052e0:	fbfd                	bnez	a5,ffffffffc02052d6 <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc02052e2:	85e2                	mv	a1,s8
ffffffffc02052e4:	856a                	mv	a0,s10
ffffffffc02052e6:	b74fd0ef          	jal	ra,ffffffffc020265a <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02052ea:	57f9                	li	a5,-2
ffffffffc02052ec:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02052f0:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02052f2:	c3e9                	beqz	a5,ffffffffc02053b4 <do_fork+0x394>
    if (ret != 0) {
ffffffffc02052f4:	8c6a                	mv	s8,s10
ffffffffc02052f6:	de0502e3          	beqz	a0,ffffffffc02050da <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02052fa:	856a                	mv	a0,s10
ffffffffc02052fc:	bfafd0ef          	jal	ra,ffffffffc02026f6 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205300:	856a                	mv	a0,s10
ffffffffc0205302:	b23ff0ef          	jal	ra,ffffffffc0204e24 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205306:	856a                	mv	a0,s10
ffffffffc0205308:	a4efd0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020530c:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020530e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205312:	0cf6e963          	bltu	a3,a5,ffffffffc02053e4 <do_fork+0x3c4>
ffffffffc0205316:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc020531a:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc020531e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205322:	83b1                	srli	a5,a5,0xc
ffffffffc0205324:	0ae7f463          	bleu	a4,a5,ffffffffc02053cc <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc0205328:	000b3703          	ld	a4,0(s6)
ffffffffc020532c:	000ab503          	ld	a0,0(s5)
ffffffffc0205330:	4589                	li	a1,2
ffffffffc0205332:	8f99                	sub	a5,a5,a4
ffffffffc0205334:	079a                	slli	a5,a5,0x6
ffffffffc0205336:	953e                	add	a0,a0,a5
ffffffffc0205338:	bc3fb0ef          	jal	ra,ffffffffc0200efa <free_pages>
    kfree(proc);
ffffffffc020533c:	8522                	mv	a0,s0
ffffffffc020533e:	facfe0ef          	jal	ra,ffffffffc0203aea <kfree>
    ret = -E_NO_MEM;
ffffffffc0205342:	5571                	li	a0,-4
    return ret;
ffffffffc0205344:	bdfd                	j	ffffffffc0205242 <do_fork+0x222>
        intr_enable();
ffffffffc0205346:	b10fb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020534a:	bdc5                	j	ffffffffc020523a <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc020534c:	0117c363          	blt	a5,a7,ffffffffc0205352 <do_fork+0x332>
                        last_pid = 1;
ffffffffc0205350:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205352:	4585                	li	a1,1
ffffffffc0205354:	b591                	j	ffffffffc0205198 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc0205356:	856a                	mv	a0,s10
ffffffffc0205358:	9fefd0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
ffffffffc020535c:	bf45                	j	ffffffffc020530c <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc020535e:	556d                	li	a0,-5
ffffffffc0205360:	b5cd                	j	ffffffffc0205242 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc0205362:	00002617          	auipc	a2,0x2
ffffffffc0205366:	cae60613          	addi	a2,a2,-850 # ffffffffc0207010 <commands+0x868>
ffffffffc020536a:	06900593          	li	a1,105
ffffffffc020536e:	00002517          	auipc	a0,0x2
ffffffffc0205372:	cfa50513          	addi	a0,a0,-774 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0205376:	ea1fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(current->wait_state==0);
ffffffffc020537a:	00003697          	auipc	a3,0x3
ffffffffc020537e:	25e68693          	addi	a3,a3,606 # ffffffffc02085d8 <default_pmm_manager+0x270>
ffffffffc0205382:	00002617          	auipc	a2,0x2
ffffffffc0205386:	8a660613          	addi	a2,a2,-1882 # ffffffffc0206c28 <commands+0x480>
ffffffffc020538a:	1a800593          	li	a1,424
ffffffffc020538e:	00003517          	auipc	a0,0x3
ffffffffc0205392:	4d250513          	addi	a0,a0,1234 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205396:	e81fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020539a:	86be                	mv	a3,a5
ffffffffc020539c:	00002617          	auipc	a2,0x2
ffffffffc02053a0:	d4c60613          	addi	a2,a2,-692 # ffffffffc02070e8 <commands+0x940>
ffffffffc02053a4:	16400593          	li	a1,356
ffffffffc02053a8:	00003517          	auipc	a0,0x3
ffffffffc02053ac:	4b850513          	addi	a0,a0,1208 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc02053b0:	e67fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("Unlock failed.\n");
ffffffffc02053b4:	00003617          	auipc	a2,0x3
ffffffffc02053b8:	23c60613          	addi	a2,a2,572 # ffffffffc02085f0 <default_pmm_manager+0x288>
ffffffffc02053bc:	03100593          	li	a1,49
ffffffffc02053c0:	00003517          	auipc	a0,0x3
ffffffffc02053c4:	24050513          	addi	a0,a0,576 # ffffffffc0208600 <default_pmm_manager+0x298>
ffffffffc02053c8:	e4ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02053cc:	00002617          	auipc	a2,0x2
ffffffffc02053d0:	c7c60613          	addi	a2,a2,-900 # ffffffffc0207048 <commands+0x8a0>
ffffffffc02053d4:	06200593          	li	a1,98
ffffffffc02053d8:	00002517          	auipc	a0,0x2
ffffffffc02053dc:	c9050513          	addi	a0,a0,-880 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02053e0:	e37fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02053e4:	00002617          	auipc	a2,0x2
ffffffffc02053e8:	d0460613          	addi	a2,a2,-764 # ffffffffc02070e8 <commands+0x940>
ffffffffc02053ec:	06e00593          	li	a1,110
ffffffffc02053f0:	00002517          	auipc	a0,0x2
ffffffffc02053f4:	c7850513          	addi	a0,a0,-904 # ffffffffc0207068 <commands+0x8c0>
ffffffffc02053f8:	e1ffa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02053fc <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053fc:	7129                	addi	sp,sp,-320
ffffffffc02053fe:	fa22                	sd	s0,304(sp)
ffffffffc0205400:	f626                	sd	s1,296(sp)
ffffffffc0205402:	f24a                	sd	s2,288(sp)
ffffffffc0205404:	84ae                	mv	s1,a1
ffffffffc0205406:	892a                	mv	s2,a0
ffffffffc0205408:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020540a:	4581                	li	a1,0
ffffffffc020540c:	12000613          	li	a2,288
ffffffffc0205410:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205412:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205414:	5e5000ef          	jal	ra,ffffffffc02061f8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205418:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020541a:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020541c:	100027f3          	csrr	a5,sstatus
ffffffffc0205420:	edd7f793          	andi	a5,a5,-291
ffffffffc0205424:	1207e793          	ori	a5,a5,288
ffffffffc0205428:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020542a:	860a                	mv	a2,sp
ffffffffc020542c:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205430:	00000797          	auipc	a5,0x0
ffffffffc0205434:	87c78793          	addi	a5,a5,-1924 # ffffffffc0204cac <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205438:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020543a:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020543c:	be5ff0ef          	jal	ra,ffffffffc0205020 <do_fork>
}
ffffffffc0205440:	70f2                	ld	ra,312(sp)
ffffffffc0205442:	7452                	ld	s0,304(sp)
ffffffffc0205444:	74b2                	ld	s1,296(sp)
ffffffffc0205446:	7912                	ld	s2,288(sp)
ffffffffc0205448:	6131                	addi	sp,sp,320
ffffffffc020544a:	8082                	ret

ffffffffc020544c <do_exit>:
do_exit(int error_code) {
ffffffffc020544c:	7179                	addi	sp,sp,-48
ffffffffc020544e:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205450:	000a7717          	auipc	a4,0xa7
ffffffffc0205454:	fe070713          	addi	a4,a4,-32 # ffffffffc02ac430 <idleproc>
ffffffffc0205458:	000a7917          	auipc	s2,0xa7
ffffffffc020545c:	fd090913          	addi	s2,s2,-48 # ffffffffc02ac428 <current>
ffffffffc0205460:	00093783          	ld	a5,0(s2)
ffffffffc0205464:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205466:	f406                	sd	ra,40(sp)
ffffffffc0205468:	f022                	sd	s0,32(sp)
ffffffffc020546a:	ec26                	sd	s1,24(sp)
ffffffffc020546c:	e44e                	sd	s3,8(sp)
ffffffffc020546e:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205470:	0ce78c63          	beq	a5,a4,ffffffffc0205548 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205474:	000a7417          	auipc	s0,0xa7
ffffffffc0205478:	fc440413          	addi	s0,s0,-60 # ffffffffc02ac438 <initproc>
ffffffffc020547c:	6018                	ld	a4,0(s0)
ffffffffc020547e:	0ee78b63          	beq	a5,a4,ffffffffc0205574 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205482:	7784                	ld	s1,40(a5)
ffffffffc0205484:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205486:	c48d                	beqz	s1,ffffffffc02054b0 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205488:	000a7797          	auipc	a5,0xa7
ffffffffc020548c:	fd878793          	addi	a5,a5,-40 # ffffffffc02ac460 <boot_cr3>
ffffffffc0205490:	639c                	ld	a5,0(a5)
ffffffffc0205492:	577d                	li	a4,-1
ffffffffc0205494:	177e                	slli	a4,a4,0x3f
ffffffffc0205496:	83b1                	srli	a5,a5,0xc
ffffffffc0205498:	8fd9                	or	a5,a5,a4
ffffffffc020549a:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020549e:	589c                	lw	a5,48(s1)
ffffffffc02054a0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02054a4:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc02054a6:	cf4d                	beqz	a4,ffffffffc0205560 <do_exit+0x114>
        current->mm = NULL;
ffffffffc02054a8:	00093783          	ld	a5,0(s2)
ffffffffc02054ac:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02054b0:	00093783          	ld	a5,0(s2)
ffffffffc02054b4:	470d                	li	a4,3
ffffffffc02054b6:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02054b8:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054bc:	100027f3          	csrr	a5,sstatus
ffffffffc02054c0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02054c2:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054c4:	e7e1                	bnez	a5,ffffffffc020558c <do_exit+0x140>
        proc = current->parent;
ffffffffc02054c6:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054ca:	800007b7          	lui	a5,0x80000
ffffffffc02054ce:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02054d0:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054d2:	0ec52703          	lw	a4,236(a0)
ffffffffc02054d6:	0af70f63          	beq	a4,a5,ffffffffc0205594 <do_exit+0x148>
ffffffffc02054da:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054de:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054e2:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054e4:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc02054e6:	7afc                	ld	a5,240(a3)
ffffffffc02054e8:	cb95                	beqz	a5,ffffffffc020551c <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02054ea:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5688>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054ee:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02054f0:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054f2:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02054f4:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054f8:	10e7b023          	sd	a4,256(a5)
ffffffffc02054fc:	c311                	beqz	a4,ffffffffc0205500 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054fe:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205500:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205502:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205504:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205506:	fe9710e3          	bne	a4,s1,ffffffffc02054e6 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020550a:	0ec52783          	lw	a5,236(a0)
ffffffffc020550e:	fd379ce3          	bne	a5,s3,ffffffffc02054e6 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205512:	257000ef          	jal	ra,ffffffffc0205f68 <wakeup_proc>
ffffffffc0205516:	00093683          	ld	a3,0(s2)
ffffffffc020551a:	b7f1                	j	ffffffffc02054e6 <do_exit+0x9a>
    if (flag) {
ffffffffc020551c:	020a1363          	bnez	s4,ffffffffc0205542 <do_exit+0xf6>
    schedule();
ffffffffc0205520:	2c5000ef          	jal	ra,ffffffffc0205fe4 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205524:	00093783          	ld	a5,0(s2)
ffffffffc0205528:	00003617          	auipc	a2,0x3
ffffffffc020552c:	09060613          	addi	a2,a2,144 # ffffffffc02085b8 <default_pmm_manager+0x250>
ffffffffc0205530:	20100593          	li	a1,513
ffffffffc0205534:	43d4                	lw	a3,4(a5)
ffffffffc0205536:	00003517          	auipc	a0,0x3
ffffffffc020553a:	32a50513          	addi	a0,a0,810 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc020553e:	cd9fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_enable();
ffffffffc0205542:	914fb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0205546:	bfe9                	j	ffffffffc0205520 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205548:	00003617          	auipc	a2,0x3
ffffffffc020554c:	05060613          	addi	a2,a2,80 # ffffffffc0208598 <default_pmm_manager+0x230>
ffffffffc0205550:	1d500593          	li	a1,469
ffffffffc0205554:	00003517          	auipc	a0,0x3
ffffffffc0205558:	30c50513          	addi	a0,a0,780 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc020555c:	cbbfa0ef          	jal	ra,ffffffffc0200216 <__panic>
            exit_mmap(mm);
ffffffffc0205560:	8526                	mv	a0,s1
ffffffffc0205562:	994fd0ef          	jal	ra,ffffffffc02026f6 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205566:	8526                	mv	a0,s1
ffffffffc0205568:	8bdff0ef          	jal	ra,ffffffffc0204e24 <put_pgdir>
            mm_destroy(mm);
ffffffffc020556c:	8526                	mv	a0,s1
ffffffffc020556e:	fe9fc0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
ffffffffc0205572:	bf1d                	j	ffffffffc02054a8 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205574:	00003617          	auipc	a2,0x3
ffffffffc0205578:	03460613          	addi	a2,a2,52 # ffffffffc02085a8 <default_pmm_manager+0x240>
ffffffffc020557c:	1d800593          	li	a1,472
ffffffffc0205580:	00003517          	auipc	a0,0x3
ffffffffc0205584:	2e050513          	addi	a0,a0,736 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205588:	c8ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_disable();
ffffffffc020558c:	8d0fb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205590:	4a05                	li	s4,1
ffffffffc0205592:	bf15                	j	ffffffffc02054c6 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205594:	1d5000ef          	jal	ra,ffffffffc0205f68 <wakeup_proc>
ffffffffc0205598:	b789                	j	ffffffffc02054da <do_exit+0x8e>

ffffffffc020559a <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc020559a:	7139                	addi	sp,sp,-64
ffffffffc020559c:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc020559e:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02055a2:	f426                	sd	s1,40(sp)
ffffffffc02055a4:	f04a                	sd	s2,32(sp)
ffffffffc02055a6:	ec4e                	sd	s3,24(sp)
ffffffffc02055a8:	e456                	sd	s5,8(sp)
ffffffffc02055aa:	e05a                	sd	s6,0(sp)
ffffffffc02055ac:	fc06                	sd	ra,56(sp)
ffffffffc02055ae:	f822                	sd	s0,48(sp)
ffffffffc02055b0:	89aa                	mv	s3,a0
ffffffffc02055b2:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc02055b4:	000a7917          	auipc	s2,0xa7
ffffffffc02055b8:	e7490913          	addi	s2,s2,-396 # ffffffffc02ac428 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055bc:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02055be:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02055c0:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc02055c2:	02098f63          	beqz	s3,ffffffffc0205600 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02055c6:	854e                	mv	a0,s3
ffffffffc02055c8:	9fdff0ef          	jal	ra,ffffffffc0204fc4 <find_proc>
ffffffffc02055cc:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02055ce:	12050063          	beqz	a0,ffffffffc02056ee <do_wait.part.1+0x154>
ffffffffc02055d2:	00093703          	ld	a4,0(s2)
ffffffffc02055d6:	711c                	ld	a5,32(a0)
ffffffffc02055d8:	10e79b63          	bne	a5,a4,ffffffffc02056ee <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055dc:	411c                	lw	a5,0(a0)
ffffffffc02055de:	02978c63          	beq	a5,s1,ffffffffc0205616 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02055e2:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02055e6:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02055ea:	1fb000ef          	jal	ra,ffffffffc0205fe4 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02055ee:	00093783          	ld	a5,0(s2)
ffffffffc02055f2:	0b07a783          	lw	a5,176(a5)
ffffffffc02055f6:	8b85                	andi	a5,a5,1
ffffffffc02055f8:	d7e9                	beqz	a5,ffffffffc02055c2 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02055fa:	555d                	li	a0,-9
ffffffffc02055fc:	e51ff0ef          	jal	ra,ffffffffc020544c <do_exit>
        proc = current->cptr;
ffffffffc0205600:	00093703          	ld	a4,0(s2)
ffffffffc0205604:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205606:	e409                	bnez	s0,ffffffffc0205610 <do_wait.part.1+0x76>
ffffffffc0205608:	a0dd                	j	ffffffffc02056ee <do_wait.part.1+0x154>
ffffffffc020560a:	10043403          	ld	s0,256(s0)
ffffffffc020560e:	d871                	beqz	s0,ffffffffc02055e2 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205610:	401c                	lw	a5,0(s0)
ffffffffc0205612:	fe979ce3          	bne	a5,s1,ffffffffc020560a <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205616:	000a7797          	auipc	a5,0xa7
ffffffffc020561a:	e1a78793          	addi	a5,a5,-486 # ffffffffc02ac430 <idleproc>
ffffffffc020561e:	639c                	ld	a5,0(a5)
ffffffffc0205620:	0c878d63          	beq	a5,s0,ffffffffc02056fa <do_wait.part.1+0x160>
ffffffffc0205624:	000a7797          	auipc	a5,0xa7
ffffffffc0205628:	e1478793          	addi	a5,a5,-492 # ffffffffc02ac438 <initproc>
ffffffffc020562c:	639c                	ld	a5,0(a5)
ffffffffc020562e:	0cf40663          	beq	s0,a5,ffffffffc02056fa <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205632:	000b0663          	beqz	s6,ffffffffc020563e <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205636:	0e842783          	lw	a5,232(s0)
ffffffffc020563a:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020563e:	100027f3          	csrr	a5,sstatus
ffffffffc0205642:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205644:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205646:	e7d5                	bnez	a5,ffffffffc02056f2 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205648:	6c70                	ld	a2,216(s0)
ffffffffc020564a:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020564c:	10043703          	ld	a4,256(s0)
ffffffffc0205650:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205652:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205654:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205656:	6470                	ld	a2,200(s0)
ffffffffc0205658:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020565a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020565c:	e290                	sd	a2,0(a3)
ffffffffc020565e:	c319                	beqz	a4,ffffffffc0205664 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205660:	ff7c                	sd	a5,248(a4)
ffffffffc0205662:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205664:	c3d1                	beqz	a5,ffffffffc02056e8 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205666:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020566a:	000a7797          	auipc	a5,0xa7
ffffffffc020566e:	dd678793          	addi	a5,a5,-554 # ffffffffc02ac440 <nr_process>
ffffffffc0205672:	439c                	lw	a5,0(a5)
ffffffffc0205674:	37fd                	addiw	a5,a5,-1
ffffffffc0205676:	000a7717          	auipc	a4,0xa7
ffffffffc020567a:	dcf72523          	sw	a5,-566(a4) # ffffffffc02ac440 <nr_process>
    if (flag) {
ffffffffc020567e:	e1b5                	bnez	a1,ffffffffc02056e2 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205680:	6814                	ld	a3,16(s0)
ffffffffc0205682:	c02007b7          	lui	a5,0xc0200
ffffffffc0205686:	0af6e263          	bltu	a3,a5,ffffffffc020572a <do_wait.part.1+0x190>
ffffffffc020568a:	000a7797          	auipc	a5,0xa7
ffffffffc020568e:	dce78793          	addi	a5,a5,-562 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0205692:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205694:	000a7797          	auipc	a5,0xa7
ffffffffc0205698:	d6c78793          	addi	a5,a5,-660 # ffffffffc02ac400 <npage>
ffffffffc020569c:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020569e:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02056a0:	82b1                	srli	a3,a3,0xc
ffffffffc02056a2:	06f6f863          	bleu	a5,a3,ffffffffc0205712 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc02056a6:	00003797          	auipc	a5,0x3
ffffffffc02056aa:	68278793          	addi	a5,a5,1666 # ffffffffc0208d28 <nbase>
ffffffffc02056ae:	639c                	ld	a5,0(a5)
ffffffffc02056b0:	000a7717          	auipc	a4,0xa7
ffffffffc02056b4:	db870713          	addi	a4,a4,-584 # ffffffffc02ac468 <pages>
ffffffffc02056b8:	6308                	ld	a0,0(a4)
ffffffffc02056ba:	8e9d                	sub	a3,a3,a5
ffffffffc02056bc:	069a                	slli	a3,a3,0x6
ffffffffc02056be:	9536                	add	a0,a0,a3
ffffffffc02056c0:	4589                	li	a1,2
ffffffffc02056c2:	839fb0ef          	jal	ra,ffffffffc0200efa <free_pages>
    kfree(proc);
ffffffffc02056c6:	8522                	mv	a0,s0
ffffffffc02056c8:	c22fe0ef          	jal	ra,ffffffffc0203aea <kfree>
    return 0;
ffffffffc02056cc:	4501                	li	a0,0
}
ffffffffc02056ce:	70e2                	ld	ra,56(sp)
ffffffffc02056d0:	7442                	ld	s0,48(sp)
ffffffffc02056d2:	74a2                	ld	s1,40(sp)
ffffffffc02056d4:	7902                	ld	s2,32(sp)
ffffffffc02056d6:	69e2                	ld	s3,24(sp)
ffffffffc02056d8:	6a42                	ld	s4,16(sp)
ffffffffc02056da:	6aa2                	ld	s5,8(sp)
ffffffffc02056dc:	6b02                	ld	s6,0(sp)
ffffffffc02056de:	6121                	addi	sp,sp,64
ffffffffc02056e0:	8082                	ret
        intr_enable();
ffffffffc02056e2:	f75fa0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02056e6:	bf69                	j	ffffffffc0205680 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc02056e8:	701c                	ld	a5,32(s0)
ffffffffc02056ea:	fbf8                	sd	a4,240(a5)
ffffffffc02056ec:	bfbd                	j	ffffffffc020566a <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02056ee:	5579                	li	a0,-2
ffffffffc02056f0:	bff9                	j	ffffffffc02056ce <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02056f2:	f6bfa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc02056f6:	4585                	li	a1,1
ffffffffc02056f8:	bf81                	j	ffffffffc0205648 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02056fa:	00003617          	auipc	a2,0x3
ffffffffc02056fe:	f1e60613          	addi	a2,a2,-226 # ffffffffc0208618 <default_pmm_manager+0x2b0>
ffffffffc0205702:	2f700593          	li	a1,759
ffffffffc0205706:	00003517          	auipc	a0,0x3
ffffffffc020570a:	15a50513          	addi	a0,a0,346 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc020570e:	b09fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205712:	00002617          	auipc	a2,0x2
ffffffffc0205716:	93660613          	addi	a2,a2,-1738 # ffffffffc0207048 <commands+0x8a0>
ffffffffc020571a:	06200593          	li	a1,98
ffffffffc020571e:	00002517          	auipc	a0,0x2
ffffffffc0205722:	94a50513          	addi	a0,a0,-1718 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0205726:	af1fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020572a:	00002617          	auipc	a2,0x2
ffffffffc020572e:	9be60613          	addi	a2,a2,-1602 # ffffffffc02070e8 <commands+0x940>
ffffffffc0205732:	06e00593          	li	a1,110
ffffffffc0205736:	00002517          	auipc	a0,0x2
ffffffffc020573a:	93250513          	addi	a0,a0,-1742 # ffffffffc0207068 <commands+0x8c0>
ffffffffc020573e:	ad9fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205742 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205742:	1141                	addi	sp,sp,-16
ffffffffc0205744:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205746:	ffafb0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020574a:	ae0fe0ef          	jal	ra,ffffffffc0203a2a <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020574e:	4601                	li	a2,0
ffffffffc0205750:	4581                	li	a1,0
ffffffffc0205752:	fffff517          	auipc	a0,0xfffff
ffffffffc0205756:	65050513          	addi	a0,a0,1616 # ffffffffc0204da2 <user_main>
ffffffffc020575a:	ca3ff0ef          	jal	ra,ffffffffc02053fc <kernel_thread>
    if (pid <= 0) {
ffffffffc020575e:	00a04563          	bgtz	a0,ffffffffc0205768 <init_main+0x26>
ffffffffc0205762:	a841                	j	ffffffffc02057f2 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205764:	081000ef          	jal	ra,ffffffffc0205fe4 <schedule>
    if (code_store != NULL) {
ffffffffc0205768:	4581                	li	a1,0
ffffffffc020576a:	4501                	li	a0,0
ffffffffc020576c:	e2fff0ef          	jal	ra,ffffffffc020559a <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205770:	d975                	beqz	a0,ffffffffc0205764 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205772:	00003517          	auipc	a0,0x3
ffffffffc0205776:	ee650513          	addi	a0,a0,-282 # ffffffffc0208658 <default_pmm_manager+0x2f0>
ffffffffc020577a:	957fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020577e:	000a7797          	auipc	a5,0xa7
ffffffffc0205782:	cba78793          	addi	a5,a5,-838 # ffffffffc02ac438 <initproc>
ffffffffc0205786:	639c                	ld	a5,0(a5)
ffffffffc0205788:	7bf8                	ld	a4,240(a5)
ffffffffc020578a:	e721                	bnez	a4,ffffffffc02057d2 <init_main+0x90>
ffffffffc020578c:	7ff8                	ld	a4,248(a5)
ffffffffc020578e:	e331                	bnez	a4,ffffffffc02057d2 <init_main+0x90>
ffffffffc0205790:	1007b703          	ld	a4,256(a5)
ffffffffc0205794:	ef1d                	bnez	a4,ffffffffc02057d2 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205796:	000a7717          	auipc	a4,0xa7
ffffffffc020579a:	caa70713          	addi	a4,a4,-854 # ffffffffc02ac440 <nr_process>
ffffffffc020579e:	4314                	lw	a3,0(a4)
ffffffffc02057a0:	4709                	li	a4,2
ffffffffc02057a2:	0ae69463          	bne	a3,a4,ffffffffc020584a <init_main+0x108>
    return listelm->next;
ffffffffc02057a6:	000a7697          	auipc	a3,0xa7
ffffffffc02057aa:	dc268693          	addi	a3,a3,-574 # ffffffffc02ac568 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057ae:	6698                	ld	a4,8(a3)
ffffffffc02057b0:	0c878793          	addi	a5,a5,200
ffffffffc02057b4:	06f71b63          	bne	a4,a5,ffffffffc020582a <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057b8:	629c                	ld	a5,0(a3)
ffffffffc02057ba:	04f71863          	bne	a4,a5,ffffffffc020580a <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02057be:	00003517          	auipc	a0,0x3
ffffffffc02057c2:	f8250513          	addi	a0,a0,-126 # ffffffffc0208740 <default_pmm_manager+0x3d8>
ffffffffc02057c6:	90bfa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc02057ca:	60a2                	ld	ra,8(sp)
ffffffffc02057cc:	4501                	li	a0,0
ffffffffc02057ce:	0141                	addi	sp,sp,16
ffffffffc02057d0:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057d2:	00003697          	auipc	a3,0x3
ffffffffc02057d6:	eae68693          	addi	a3,a3,-338 # ffffffffc0208680 <default_pmm_manager+0x318>
ffffffffc02057da:	00001617          	auipc	a2,0x1
ffffffffc02057de:	44e60613          	addi	a2,a2,1102 # ffffffffc0206c28 <commands+0x480>
ffffffffc02057e2:	35c00593          	li	a1,860
ffffffffc02057e6:	00003517          	auipc	a0,0x3
ffffffffc02057ea:	07a50513          	addi	a0,a0,122 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc02057ee:	a29fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create user_main failed.\n");
ffffffffc02057f2:	00003617          	auipc	a2,0x3
ffffffffc02057f6:	e4660613          	addi	a2,a2,-442 # ffffffffc0208638 <default_pmm_manager+0x2d0>
ffffffffc02057fa:	35400593          	li	a1,852
ffffffffc02057fe:	00003517          	auipc	a0,0x3
ffffffffc0205802:	06250513          	addi	a0,a0,98 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205806:	a11fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020580a:	00003697          	auipc	a3,0x3
ffffffffc020580e:	f0668693          	addi	a3,a3,-250 # ffffffffc0208710 <default_pmm_manager+0x3a8>
ffffffffc0205812:	00001617          	auipc	a2,0x1
ffffffffc0205816:	41660613          	addi	a2,a2,1046 # ffffffffc0206c28 <commands+0x480>
ffffffffc020581a:	35f00593          	li	a1,863
ffffffffc020581e:	00003517          	auipc	a0,0x3
ffffffffc0205822:	04250513          	addi	a0,a0,66 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205826:	9f1fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020582a:	00003697          	auipc	a3,0x3
ffffffffc020582e:	eb668693          	addi	a3,a3,-330 # ffffffffc02086e0 <default_pmm_manager+0x378>
ffffffffc0205832:	00001617          	auipc	a2,0x1
ffffffffc0205836:	3f660613          	addi	a2,a2,1014 # ffffffffc0206c28 <commands+0x480>
ffffffffc020583a:	35e00593          	li	a1,862
ffffffffc020583e:	00003517          	auipc	a0,0x3
ffffffffc0205842:	02250513          	addi	a0,a0,34 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205846:	9d1fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_process == 2);
ffffffffc020584a:	00003697          	auipc	a3,0x3
ffffffffc020584e:	e8668693          	addi	a3,a3,-378 # ffffffffc02086d0 <default_pmm_manager+0x368>
ffffffffc0205852:	00001617          	auipc	a2,0x1
ffffffffc0205856:	3d660613          	addi	a2,a2,982 # ffffffffc0206c28 <commands+0x480>
ffffffffc020585a:	35d00593          	li	a1,861
ffffffffc020585e:	00003517          	auipc	a0,0x3
ffffffffc0205862:	00250513          	addi	a0,a0,2 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205866:	9b1fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020586a <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020586a:	7135                	addi	sp,sp,-160
ffffffffc020586c:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020586e:	000a7a17          	auipc	s4,0xa7
ffffffffc0205872:	bbaa0a13          	addi	s4,s4,-1094 # ffffffffc02ac428 <current>
ffffffffc0205876:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020587a:	e14a                	sd	s2,128(sp)
ffffffffc020587c:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020587e:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205882:	fcce                	sd	s3,120(sp)
ffffffffc0205884:	f0da                	sd	s6,96(sp)
ffffffffc0205886:	89aa                	mv	s3,a0
ffffffffc0205888:	842e                	mv	s0,a1
ffffffffc020588a:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020588c:	4681                	li	a3,0
ffffffffc020588e:	862e                	mv	a2,a1
ffffffffc0205890:	85aa                	mv	a1,a0
ffffffffc0205892:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205894:	ed06                	sd	ra,152(sp)
ffffffffc0205896:	e526                	sd	s1,136(sp)
ffffffffc0205898:	f4d6                	sd	s5,104(sp)
ffffffffc020589a:	ecde                	sd	s7,88(sp)
ffffffffc020589c:	e8e2                	sd	s8,80(sp)
ffffffffc020589e:	e4e6                	sd	s9,72(sp)
ffffffffc02058a0:	e0ea                	sd	s10,64(sp)
ffffffffc02058a2:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058a4:	d16fd0ef          	jal	ra,ffffffffc0202dba <user_mem_check>
ffffffffc02058a8:	40050463          	beqz	a0,ffffffffc0205cb0 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02058ac:	4641                	li	a2,16
ffffffffc02058ae:	4581                	li	a1,0
ffffffffc02058b0:	1008                	addi	a0,sp,32
ffffffffc02058b2:	147000ef          	jal	ra,ffffffffc02061f8 <memset>
    memcpy(local_name, name, len);
ffffffffc02058b6:	47bd                	li	a5,15
ffffffffc02058b8:	8622                	mv	a2,s0
ffffffffc02058ba:	0687ee63          	bltu	a5,s0,ffffffffc0205936 <do_execve+0xcc>
ffffffffc02058be:	85ce                	mv	a1,s3
ffffffffc02058c0:	1008                	addi	a0,sp,32
ffffffffc02058c2:	149000ef          	jal	ra,ffffffffc020620a <memcpy>
    if (mm != NULL) {
ffffffffc02058c6:	06090f63          	beqz	s2,ffffffffc0205944 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc02058ca:	00002517          	auipc	a0,0x2
ffffffffc02058ce:	f2e50513          	addi	a0,a0,-210 # ffffffffc02077f8 <commands+0x1050>
ffffffffc02058d2:	837fa0ef          	jal	ra,ffffffffc0200108 <cputs>
        lcr3(boot_cr3);
ffffffffc02058d6:	000a7797          	auipc	a5,0xa7
ffffffffc02058da:	b8a78793          	addi	a5,a5,-1142 # ffffffffc02ac460 <boot_cr3>
ffffffffc02058de:	639c                	ld	a5,0(a5)
ffffffffc02058e0:	577d                	li	a4,-1
ffffffffc02058e2:	177e                	slli	a4,a4,0x3f
ffffffffc02058e4:	83b1                	srli	a5,a5,0xc
ffffffffc02058e6:	8fd9                	or	a5,a5,a4
ffffffffc02058e8:	18079073          	csrw	satp,a5
ffffffffc02058ec:	03092783          	lw	a5,48(s2)
ffffffffc02058f0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02058f4:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc02058f8:	28070b63          	beqz	a4,ffffffffc0205b8e <do_execve+0x324>
        current->mm = NULL;
ffffffffc02058fc:	000a3783          	ld	a5,0(s4)
ffffffffc0205900:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205904:	acdfc0ef          	jal	ra,ffffffffc02023d0 <mm_create>
ffffffffc0205908:	892a                	mv	s2,a0
ffffffffc020590a:	c135                	beqz	a0,ffffffffc020596e <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc020590c:	d96ff0ef          	jal	ra,ffffffffc0204ea2 <setup_pgdir>
ffffffffc0205910:	e931                	bnez	a0,ffffffffc0205964 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205912:	000b2703          	lw	a4,0(s6)
ffffffffc0205916:	464c47b7          	lui	a5,0x464c4
ffffffffc020591a:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9b07>
ffffffffc020591e:	04f70a63          	beq	a4,a5,ffffffffc0205972 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205922:	854a                	mv	a0,s2
ffffffffc0205924:	d00ff0ef          	jal	ra,ffffffffc0204e24 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205928:	854a                	mv	a0,s2
ffffffffc020592a:	c2dfc0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020592e:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205930:	854e                	mv	a0,s3
ffffffffc0205932:	b1bff0ef          	jal	ra,ffffffffc020544c <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205936:	463d                	li	a2,15
ffffffffc0205938:	85ce                	mv	a1,s3
ffffffffc020593a:	1008                	addi	a0,sp,32
ffffffffc020593c:	0cf000ef          	jal	ra,ffffffffc020620a <memcpy>
    if (mm != NULL) {
ffffffffc0205940:	f80915e3          	bnez	s2,ffffffffc02058ca <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205944:	000a3783          	ld	a5,0(s4)
ffffffffc0205948:	779c                	ld	a5,40(a5)
ffffffffc020594a:	dfcd                	beqz	a5,ffffffffc0205904 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020594c:	00003617          	auipc	a2,0x3
ffffffffc0205950:	ac460613          	addi	a2,a2,-1340 # ffffffffc0208410 <default_pmm_manager+0xa8>
ffffffffc0205954:	20b00593          	li	a1,523
ffffffffc0205958:	00003517          	auipc	a0,0x3
ffffffffc020595c:	f0850513          	addi	a0,a0,-248 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205960:	8b7fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    mm_destroy(mm);
ffffffffc0205964:	854a                	mv	a0,s2
ffffffffc0205966:	bf1fc0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc020596a:	59f1                	li	s3,-4
ffffffffc020596c:	b7d1                	j	ffffffffc0205930 <do_execve+0xc6>
ffffffffc020596e:	59f1                	li	s3,-4
ffffffffc0205970:	b7c1                	j	ffffffffc0205930 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205972:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205976:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020597a:	00371793          	slli	a5,a4,0x3
ffffffffc020597e:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205980:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205982:	078e                	slli	a5,a5,0x3
ffffffffc0205984:	97a2                	add	a5,a5,s0
ffffffffc0205986:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205988:	02f47b63          	bleu	a5,s0,ffffffffc02059be <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc020598c:	5bfd                	li	s7,-1
ffffffffc020598e:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205992:	000a7d97          	auipc	s11,0xa7
ffffffffc0205996:	ad6d8d93          	addi	s11,s11,-1322 # ffffffffc02ac468 <pages>
ffffffffc020599a:	00003d17          	auipc	s10,0x3
ffffffffc020599e:	38ed0d13          	addi	s10,s10,910 # ffffffffc0208d28 <nbase>
    return KADDR(page2pa(page));
ffffffffc02059a2:	e43e                	sd	a5,8(sp)
ffffffffc02059a4:	000a7c97          	auipc	s9,0xa7
ffffffffc02059a8:	a5cc8c93          	addi	s9,s9,-1444 # ffffffffc02ac400 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02059ac:	4018                	lw	a4,0(s0)
ffffffffc02059ae:	4785                	li	a5,1
ffffffffc02059b0:	0ef70d63          	beq	a4,a5,ffffffffc0205aaa <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc02059b4:	67e2                	ld	a5,24(sp)
ffffffffc02059b6:	03840413          	addi	s0,s0,56
ffffffffc02059ba:	fef469e3          	bltu	s0,a5,ffffffffc02059ac <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02059be:	4701                	li	a4,0
ffffffffc02059c0:	46ad                	li	a3,11
ffffffffc02059c2:	00100637          	lui	a2,0x100
ffffffffc02059c6:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02059ca:	854a                	mv	a0,s2
ffffffffc02059cc:	bddfc0ef          	jal	ra,ffffffffc02025a8 <mm_map>
ffffffffc02059d0:	89aa                	mv	s3,a0
ffffffffc02059d2:	1a051463          	bnez	a0,ffffffffc0205b7a <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02059d6:	01893503          	ld	a0,24(s2)
ffffffffc02059da:	467d                	li	a2,31
ffffffffc02059dc:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02059e0:	939fc0ef          	jal	ra,ffffffffc0202318 <pgdir_alloc_page>
ffffffffc02059e4:	36050263          	beqz	a0,ffffffffc0205d48 <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02059e8:	01893503          	ld	a0,24(s2)
ffffffffc02059ec:	467d                	li	a2,31
ffffffffc02059ee:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059f2:	927fc0ef          	jal	ra,ffffffffc0202318 <pgdir_alloc_page>
ffffffffc02059f6:	32050963          	beqz	a0,ffffffffc0205d28 <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059fa:	01893503          	ld	a0,24(s2)
ffffffffc02059fe:	467d                	li	a2,31
ffffffffc0205a00:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205a04:	915fc0ef          	jal	ra,ffffffffc0202318 <pgdir_alloc_page>
ffffffffc0205a08:	30050063          	beqz	a0,ffffffffc0205d08 <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a0c:	01893503          	ld	a0,24(s2)
ffffffffc0205a10:	467d                	li	a2,31
ffffffffc0205a12:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205a16:	903fc0ef          	jal	ra,ffffffffc0202318 <pgdir_alloc_page>
ffffffffc0205a1a:	2c050763          	beqz	a0,ffffffffc0205ce8 <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc0205a1e:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205a22:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a26:	01893683          	ld	a3,24(s2)
ffffffffc0205a2a:	2785                	addiw	a5,a5,1
ffffffffc0205a2c:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205a30:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55b0>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a34:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a38:	28f6ec63          	bltu	a3,a5,ffffffffc0205cd0 <do_execve+0x466>
ffffffffc0205a3c:	000a7797          	auipc	a5,0xa7
ffffffffc0205a40:	a1c78793          	addi	a5,a5,-1508 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0205a44:	639c                	ld	a5,0(a5)
ffffffffc0205a46:	577d                	li	a4,-1
ffffffffc0205a48:	177e                	slli	a4,a4,0x3f
ffffffffc0205a4a:	8e9d                	sub	a3,a3,a5
ffffffffc0205a4c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a50:	f654                	sd	a3,168(a2)
ffffffffc0205a52:	8fd9                	or	a5,a5,a4
ffffffffc0205a54:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a58:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a5a:	4581                	li	a1,0
ffffffffc0205a5c:	12000613          	li	a2,288
ffffffffc0205a60:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a62:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a66:	792000ef          	jal	ra,ffffffffc02061f8 <memset>
    tf->epc=elf->e_entry;
ffffffffc0205a6a:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp=USTACKTOP;
ffffffffc0205a6e:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a70:	000a3503          	ld	a0,0(s4)
    tf->status=sstatus&(~(SSTATUS_SPP|SSTATUS_SPIE));
ffffffffc0205a74:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp=USTACKTOP;
ffffffffc0205a78:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a7a:	e81c                	sd	a5,16(s0)
    tf->epc=elf->e_entry;
ffffffffc0205a7c:	10e43423          	sd	a4,264(s0)
    tf->status=sstatus&(~(SSTATUS_SPP|SSTATUS_SPIE));
ffffffffc0205a80:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a84:	100c                	addi	a1,sp,32
ffffffffc0205a86:	ca8ff0ef          	jal	ra,ffffffffc0204f2e <set_proc_name>
}
ffffffffc0205a8a:	60ea                	ld	ra,152(sp)
ffffffffc0205a8c:	644a                	ld	s0,144(sp)
ffffffffc0205a8e:	854e                	mv	a0,s3
ffffffffc0205a90:	64aa                	ld	s1,136(sp)
ffffffffc0205a92:	690a                	ld	s2,128(sp)
ffffffffc0205a94:	79e6                	ld	s3,120(sp)
ffffffffc0205a96:	7a46                	ld	s4,112(sp)
ffffffffc0205a98:	7aa6                	ld	s5,104(sp)
ffffffffc0205a9a:	7b06                	ld	s6,96(sp)
ffffffffc0205a9c:	6be6                	ld	s7,88(sp)
ffffffffc0205a9e:	6c46                	ld	s8,80(sp)
ffffffffc0205aa0:	6ca6                	ld	s9,72(sp)
ffffffffc0205aa2:	6d06                	ld	s10,64(sp)
ffffffffc0205aa4:	7de2                	ld	s11,56(sp)
ffffffffc0205aa6:	610d                	addi	sp,sp,160
ffffffffc0205aa8:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205aaa:	7410                	ld	a2,40(s0)
ffffffffc0205aac:	701c                	ld	a5,32(s0)
ffffffffc0205aae:	20f66363          	bltu	a2,a5,ffffffffc0205cb4 <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205ab2:	405c                	lw	a5,4(s0)
ffffffffc0205ab4:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ab8:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205abc:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205abe:	0e071263          	bnez	a4,ffffffffc0205ba2 <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205ac2:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ac4:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205ac6:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ac8:	c789                	beqz	a5,ffffffffc0205ad2 <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205aca:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205acc:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205ad0:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205ad2:	0026f793          	andi	a5,a3,2
ffffffffc0205ad6:	efe1                	bnez	a5,ffffffffc0205bae <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205ad8:	0046f793          	andi	a5,a3,4
ffffffffc0205adc:	c789                	beqz	a5,ffffffffc0205ae6 <do_execve+0x27c>
ffffffffc0205ade:	6782                	ld	a5,0(sp)
ffffffffc0205ae0:	0087e793          	ori	a5,a5,8
ffffffffc0205ae4:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205ae6:	680c                	ld	a1,16(s0)
ffffffffc0205ae8:	4701                	li	a4,0
ffffffffc0205aea:	854a                	mv	a0,s2
ffffffffc0205aec:	abdfc0ef          	jal	ra,ffffffffc02025a8 <mm_map>
ffffffffc0205af0:	89aa                	mv	s3,a0
ffffffffc0205af2:	e541                	bnez	a0,ffffffffc0205b7a <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205af4:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205af8:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205afc:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b00:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b02:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b04:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b06:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205b0a:	053bef63          	bltu	s7,s3,ffffffffc0205b68 <do_execve+0x2fe>
ffffffffc0205b0e:	aa79                	j	ffffffffc0205cac <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b10:	6785                	lui	a5,0x1
ffffffffc0205b12:	418b8533          	sub	a0,s7,s8
ffffffffc0205b16:	9c3e                	add	s8,s8,a5
ffffffffc0205b18:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205b1c:	0189f463          	bleu	s8,s3,ffffffffc0205b24 <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205b20:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205b24:	000db683          	ld	a3,0(s11)
ffffffffc0205b28:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b2c:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b2e:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b32:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b34:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b38:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b3a:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b3e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b40:	16c5fc63          	bleu	a2,a1,ffffffffc0205cb8 <do_execve+0x44e>
ffffffffc0205b44:	000a7797          	auipc	a5,0xa7
ffffffffc0205b48:	91478793          	addi	a5,a5,-1772 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0205b4c:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b50:	85d6                	mv	a1,s5
ffffffffc0205b52:	8642                	mv	a2,a6
ffffffffc0205b54:	96c6                	add	a3,a3,a7
ffffffffc0205b56:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b58:	9bc2                	add	s7,s7,a6
ffffffffc0205b5a:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b5c:	6ae000ef          	jal	ra,ffffffffc020620a <memcpy>
            start += size, from += size;
ffffffffc0205b60:	6842                	ld	a6,16(sp)
ffffffffc0205b62:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b64:	053bf863          	bleu	s3,s7,ffffffffc0205bb4 <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b68:	01893503          	ld	a0,24(s2)
ffffffffc0205b6c:	6602                	ld	a2,0(sp)
ffffffffc0205b6e:	85e2                	mv	a1,s8
ffffffffc0205b70:	fa8fc0ef          	jal	ra,ffffffffc0202318 <pgdir_alloc_page>
ffffffffc0205b74:	84aa                	mv	s1,a0
ffffffffc0205b76:	fd49                	bnez	a0,ffffffffc0205b10 <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205b78:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b7a:	854a                	mv	a0,s2
ffffffffc0205b7c:	b7bfc0ef          	jal	ra,ffffffffc02026f6 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b80:	854a                	mv	a0,s2
ffffffffc0205b82:	aa2ff0ef          	jal	ra,ffffffffc0204e24 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b86:	854a                	mv	a0,s2
ffffffffc0205b88:	9cffc0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
    return ret;
ffffffffc0205b8c:	b355                	j	ffffffffc0205930 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b8e:	854a                	mv	a0,s2
ffffffffc0205b90:	b67fc0ef          	jal	ra,ffffffffc02026f6 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b94:	854a                	mv	a0,s2
ffffffffc0205b96:	a8eff0ef          	jal	ra,ffffffffc0204e24 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b9a:	854a                	mv	a0,s2
ffffffffc0205b9c:	9bbfc0ef          	jal	ra,ffffffffc0202556 <mm_destroy>
ffffffffc0205ba0:	bbb1                	j	ffffffffc02058fc <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ba2:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ba6:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ba8:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205baa:	f20790e3          	bnez	a5,ffffffffc0205aca <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205bae:	47dd                	li	a5,23
ffffffffc0205bb0:	e03e                	sd	a5,0(sp)
ffffffffc0205bb2:	b71d                	j	ffffffffc0205ad8 <do_execve+0x26e>
ffffffffc0205bb4:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205bb8:	7414                	ld	a3,40(s0)
ffffffffc0205bba:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205bbc:	098bf163          	bleu	s8,s7,ffffffffc0205c3e <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205bc0:	df798ae3          	beq	s3,s7,ffffffffc02059b4 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205bc4:	6505                	lui	a0,0x1
ffffffffc0205bc6:	955e                	add	a0,a0,s7
ffffffffc0205bc8:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205bcc:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205bd0:	0d89fb63          	bleu	s8,s3,ffffffffc0205ca6 <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205bd4:	000db683          	ld	a3,0(s11)
ffffffffc0205bd8:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205bdc:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205bde:	40d486b3          	sub	a3,s1,a3
ffffffffc0205be2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205be4:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205be8:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205bea:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bf0:	0cc5f463          	bleu	a2,a1,ffffffffc0205cb8 <do_execve+0x44e>
ffffffffc0205bf4:	000a7617          	auipc	a2,0xa7
ffffffffc0205bf8:	86460613          	addi	a2,a2,-1948 # ffffffffc02ac458 <va_pa_offset>
ffffffffc0205bfc:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c00:	4581                	li	a1,0
ffffffffc0205c02:	8656                	mv	a2,s5
ffffffffc0205c04:	96c2                	add	a3,a3,a6
ffffffffc0205c06:	9536                	add	a0,a0,a3
ffffffffc0205c08:	5f0000ef          	jal	ra,ffffffffc02061f8 <memset>
            start += size;
ffffffffc0205c0c:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205c10:	0389f463          	bleu	s8,s3,ffffffffc0205c38 <do_execve+0x3ce>
ffffffffc0205c14:	dae980e3          	beq	s3,a4,ffffffffc02059b4 <do_execve+0x14a>
ffffffffc0205c18:	00003697          	auipc	a3,0x3
ffffffffc0205c1c:	82068693          	addi	a3,a3,-2016 # ffffffffc0208438 <default_pmm_manager+0xd0>
ffffffffc0205c20:	00001617          	auipc	a2,0x1
ffffffffc0205c24:	00860613          	addi	a2,a2,8 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205c28:	26000593          	li	a1,608
ffffffffc0205c2c:	00003517          	auipc	a0,0x3
ffffffffc0205c30:	c3450513          	addi	a0,a0,-972 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205c34:	de2fa0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0205c38:	ff8710e3          	bne	a4,s8,ffffffffc0205c18 <do_execve+0x3ae>
ffffffffc0205c3c:	8be2                	mv	s7,s8
ffffffffc0205c3e:	000a7a97          	auipc	s5,0xa7
ffffffffc0205c42:	81aa8a93          	addi	s5,s5,-2022 # ffffffffc02ac458 <va_pa_offset>
        while (start < end) {
ffffffffc0205c46:	053be763          	bltu	s7,s3,ffffffffc0205c94 <do_execve+0x42a>
ffffffffc0205c4a:	b3ad                	j	ffffffffc02059b4 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c4c:	6785                	lui	a5,0x1
ffffffffc0205c4e:	418b8533          	sub	a0,s7,s8
ffffffffc0205c52:	9c3e                	add	s8,s8,a5
ffffffffc0205c54:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205c58:	0189f463          	bleu	s8,s3,ffffffffc0205c60 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205c5c:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c60:	000db683          	ld	a3,0(s11)
ffffffffc0205c64:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c68:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c6a:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c6e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c70:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c74:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c76:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c7a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c7c:	02b87e63          	bleu	a1,a6,ffffffffc0205cb8 <do_execve+0x44e>
ffffffffc0205c80:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c84:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c86:	4581                	li	a1,0
ffffffffc0205c88:	96c2                	add	a3,a3,a6
ffffffffc0205c8a:	9536                	add	a0,a0,a3
ffffffffc0205c8c:	56c000ef          	jal	ra,ffffffffc02061f8 <memset>
        while (start < end) {
ffffffffc0205c90:	d33bf2e3          	bleu	s3,s7,ffffffffc02059b4 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c94:	01893503          	ld	a0,24(s2)
ffffffffc0205c98:	6602                	ld	a2,0(sp)
ffffffffc0205c9a:	85e2                	mv	a1,s8
ffffffffc0205c9c:	e7cfc0ef          	jal	ra,ffffffffc0202318 <pgdir_alloc_page>
ffffffffc0205ca0:	84aa                	mv	s1,a0
ffffffffc0205ca2:	f54d                	bnez	a0,ffffffffc0205c4c <do_execve+0x3e2>
ffffffffc0205ca4:	bdd1                	j	ffffffffc0205b78 <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205ca6:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205caa:	b72d                	j	ffffffffc0205bd4 <do_execve+0x36a>
        while (start < end) {
ffffffffc0205cac:	89de                	mv	s3,s7
ffffffffc0205cae:	b729                	j	ffffffffc0205bb8 <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205cb0:	59f5                	li	s3,-3
ffffffffc0205cb2:	bbe1                	j	ffffffffc0205a8a <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205cb4:	59e1                	li	s3,-8
ffffffffc0205cb6:	b5d1                	j	ffffffffc0205b7a <do_execve+0x310>
ffffffffc0205cb8:	00001617          	auipc	a2,0x1
ffffffffc0205cbc:	35860613          	addi	a2,a2,856 # ffffffffc0207010 <commands+0x868>
ffffffffc0205cc0:	06900593          	li	a1,105
ffffffffc0205cc4:	00001517          	auipc	a0,0x1
ffffffffc0205cc8:	3a450513          	addi	a0,a0,932 # ffffffffc0207068 <commands+0x8c0>
ffffffffc0205ccc:	d4afa0ef          	jal	ra,ffffffffc0200216 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205cd0:	00001617          	auipc	a2,0x1
ffffffffc0205cd4:	41860613          	addi	a2,a2,1048 # ffffffffc02070e8 <commands+0x940>
ffffffffc0205cd8:	27b00593          	li	a1,635
ffffffffc0205cdc:	00003517          	auipc	a0,0x3
ffffffffc0205ce0:	b8450513          	addi	a0,a0,-1148 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205ce4:	d32fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ce8:	00003697          	auipc	a3,0x3
ffffffffc0205cec:	86868693          	addi	a3,a3,-1944 # ffffffffc0208550 <default_pmm_manager+0x1e8>
ffffffffc0205cf0:	00001617          	auipc	a2,0x1
ffffffffc0205cf4:	f3860613          	addi	a2,a2,-200 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205cf8:	27600593          	li	a1,630
ffffffffc0205cfc:	00003517          	auipc	a0,0x3
ffffffffc0205d00:	b6450513          	addi	a0,a0,-1180 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205d04:	d12fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d08:	00003697          	auipc	a3,0x3
ffffffffc0205d0c:	80068693          	addi	a3,a3,-2048 # ffffffffc0208508 <default_pmm_manager+0x1a0>
ffffffffc0205d10:	00001617          	auipc	a2,0x1
ffffffffc0205d14:	f1860613          	addi	a2,a2,-232 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205d18:	27500593          	li	a1,629
ffffffffc0205d1c:	00003517          	auipc	a0,0x3
ffffffffc0205d20:	b4450513          	addi	a0,a0,-1212 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205d24:	cf2fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d28:	00002697          	auipc	a3,0x2
ffffffffc0205d2c:	79868693          	addi	a3,a3,1944 # ffffffffc02084c0 <default_pmm_manager+0x158>
ffffffffc0205d30:	00001617          	auipc	a2,0x1
ffffffffc0205d34:	ef860613          	addi	a2,a2,-264 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205d38:	27400593          	li	a1,628
ffffffffc0205d3c:	00003517          	auipc	a0,0x3
ffffffffc0205d40:	b2450513          	addi	a0,a0,-1244 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205d44:	cd2fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d48:	00002697          	auipc	a3,0x2
ffffffffc0205d4c:	73068693          	addi	a3,a3,1840 # ffffffffc0208478 <default_pmm_manager+0x110>
ffffffffc0205d50:	00001617          	auipc	a2,0x1
ffffffffc0205d54:	ed860613          	addi	a2,a2,-296 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205d58:	27300593          	li	a1,627
ffffffffc0205d5c:	00003517          	auipc	a0,0x3
ffffffffc0205d60:	b0450513          	addi	a0,a0,-1276 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205d64:	cb2fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205d68 <do_yield>:
    current->need_resched = 1;
ffffffffc0205d68:	000a6797          	auipc	a5,0xa6
ffffffffc0205d6c:	6c078793          	addi	a5,a5,1728 # ffffffffc02ac428 <current>
ffffffffc0205d70:	639c                	ld	a5,0(a5)
ffffffffc0205d72:	4705                	li	a4,1
}
ffffffffc0205d74:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d76:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d78:	8082                	ret

ffffffffc0205d7a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d7a:	1101                	addi	sp,sp,-32
ffffffffc0205d7c:	e822                	sd	s0,16(sp)
ffffffffc0205d7e:	e426                	sd	s1,8(sp)
ffffffffc0205d80:	ec06                	sd	ra,24(sp)
ffffffffc0205d82:	842e                	mv	s0,a1
ffffffffc0205d84:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d86:	cd81                	beqz	a1,ffffffffc0205d9e <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d88:	000a6797          	auipc	a5,0xa6
ffffffffc0205d8c:	6a078793          	addi	a5,a5,1696 # ffffffffc02ac428 <current>
ffffffffc0205d90:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d92:	4685                	li	a3,1
ffffffffc0205d94:	4611                	li	a2,4
ffffffffc0205d96:	7788                	ld	a0,40(a5)
ffffffffc0205d98:	822fd0ef          	jal	ra,ffffffffc0202dba <user_mem_check>
ffffffffc0205d9c:	c909                	beqz	a0,ffffffffc0205dae <do_wait+0x34>
ffffffffc0205d9e:	85a2                	mv	a1,s0
}
ffffffffc0205da0:	6442                	ld	s0,16(sp)
ffffffffc0205da2:	60e2                	ld	ra,24(sp)
ffffffffc0205da4:	8526                	mv	a0,s1
ffffffffc0205da6:	64a2                	ld	s1,8(sp)
ffffffffc0205da8:	6105                	addi	sp,sp,32
ffffffffc0205daa:	ff0ff06f          	j	ffffffffc020559a <do_wait.part.1>
ffffffffc0205dae:	60e2                	ld	ra,24(sp)
ffffffffc0205db0:	6442                	ld	s0,16(sp)
ffffffffc0205db2:	64a2                	ld	s1,8(sp)
ffffffffc0205db4:	5575                	li	a0,-3
ffffffffc0205db6:	6105                	addi	sp,sp,32
ffffffffc0205db8:	8082                	ret

ffffffffc0205dba <do_kill>:
do_kill(int pid) {
ffffffffc0205dba:	1141                	addi	sp,sp,-16
ffffffffc0205dbc:	e406                	sd	ra,8(sp)
ffffffffc0205dbe:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205dc0:	a04ff0ef          	jal	ra,ffffffffc0204fc4 <find_proc>
ffffffffc0205dc4:	cd0d                	beqz	a0,ffffffffc0205dfe <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205dc6:	0b052703          	lw	a4,176(a0)
ffffffffc0205dca:	00177693          	andi	a3,a4,1
ffffffffc0205dce:	e695                	bnez	a3,ffffffffc0205dfa <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205dd0:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205dd4:	00176713          	ori	a4,a4,1
ffffffffc0205dd8:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205ddc:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205dde:	0006c763          	bltz	a3,ffffffffc0205dec <do_kill+0x32>
}
ffffffffc0205de2:	8522                	mv	a0,s0
ffffffffc0205de4:	60a2                	ld	ra,8(sp)
ffffffffc0205de6:	6402                	ld	s0,0(sp)
ffffffffc0205de8:	0141                	addi	sp,sp,16
ffffffffc0205dea:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205dec:	17c000ef          	jal	ra,ffffffffc0205f68 <wakeup_proc>
}
ffffffffc0205df0:	8522                	mv	a0,s0
ffffffffc0205df2:	60a2                	ld	ra,8(sp)
ffffffffc0205df4:	6402                	ld	s0,0(sp)
ffffffffc0205df6:	0141                	addi	sp,sp,16
ffffffffc0205df8:	8082                	ret
        return -E_KILLED;
ffffffffc0205dfa:	545d                	li	s0,-9
ffffffffc0205dfc:	b7dd                	j	ffffffffc0205de2 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205dfe:	5475                	li	s0,-3
ffffffffc0205e00:	b7cd                	j	ffffffffc0205de2 <do_kill+0x28>

ffffffffc0205e02 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205e02:	000a6797          	auipc	a5,0xa6
ffffffffc0205e06:	76678793          	addi	a5,a5,1894 # ffffffffc02ac568 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205e0a:	1101                	addi	sp,sp,-32
ffffffffc0205e0c:	000a6717          	auipc	a4,0xa6
ffffffffc0205e10:	76f73223          	sd	a5,1892(a4) # ffffffffc02ac570 <proc_list+0x8>
ffffffffc0205e14:	000a6717          	auipc	a4,0xa6
ffffffffc0205e18:	74f73a23          	sd	a5,1876(a4) # ffffffffc02ac568 <proc_list>
ffffffffc0205e1c:	ec06                	sd	ra,24(sp)
ffffffffc0205e1e:	e822                	sd	s0,16(sp)
ffffffffc0205e20:	e426                	sd	s1,8(sp)
ffffffffc0205e22:	000a2797          	auipc	a5,0xa2
ffffffffc0205e26:	5c678793          	addi	a5,a5,1478 # ffffffffc02a83e8 <hash_list>
ffffffffc0205e2a:	000a6717          	auipc	a4,0xa6
ffffffffc0205e2e:	5be70713          	addi	a4,a4,1470 # ffffffffc02ac3e8 <is_panic>
ffffffffc0205e32:	e79c                	sd	a5,8(a5)
ffffffffc0205e34:	e39c                	sd	a5,0(a5)
ffffffffc0205e36:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e38:	fee79de3          	bne	a5,a4,ffffffffc0205e32 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e3c:	ee3fe0ef          	jal	ra,ffffffffc0204d1e <alloc_proc>
ffffffffc0205e40:	000a6717          	auipc	a4,0xa6
ffffffffc0205e44:	5ea73823          	sd	a0,1520(a4) # ffffffffc02ac430 <idleproc>
ffffffffc0205e48:	000a6497          	auipc	s1,0xa6
ffffffffc0205e4c:	5e848493          	addi	s1,s1,1512 # ffffffffc02ac430 <idleproc>
ffffffffc0205e50:	c559                	beqz	a0,ffffffffc0205ede <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e52:	4709                	li	a4,2
ffffffffc0205e54:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e56:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e58:	00003717          	auipc	a4,0x3
ffffffffc0205e5c:	1a870713          	addi	a4,a4,424 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e60:	00003597          	auipc	a1,0x3
ffffffffc0205e64:	91858593          	addi	a1,a1,-1768 # ffffffffc0208778 <default_pmm_manager+0x410>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e68:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e6a:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e6c:	8c2ff0ef          	jal	ra,ffffffffc0204f2e <set_proc_name>
    nr_process ++;
ffffffffc0205e70:	000a6797          	auipc	a5,0xa6
ffffffffc0205e74:	5d078793          	addi	a5,a5,1488 # ffffffffc02ac440 <nr_process>
ffffffffc0205e78:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e7a:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e7c:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e7e:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e80:	4581                	li	a1,0
ffffffffc0205e82:	00000517          	auipc	a0,0x0
ffffffffc0205e86:	8c050513          	addi	a0,a0,-1856 # ffffffffc0205742 <init_main>
    nr_process ++;
ffffffffc0205e8a:	000a6697          	auipc	a3,0xa6
ffffffffc0205e8e:	5af6ab23          	sw	a5,1462(a3) # ffffffffc02ac440 <nr_process>
    current = idleproc;
ffffffffc0205e92:	000a6797          	auipc	a5,0xa6
ffffffffc0205e96:	58e7bb23          	sd	a4,1430(a5) # ffffffffc02ac428 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e9a:	d62ff0ef          	jal	ra,ffffffffc02053fc <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e9e:	08a05c63          	blez	a0,ffffffffc0205f36 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205ea2:	922ff0ef          	jal	ra,ffffffffc0204fc4 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205ea6:	00003597          	auipc	a1,0x3
ffffffffc0205eaa:	8fa58593          	addi	a1,a1,-1798 # ffffffffc02087a0 <default_pmm_manager+0x438>
    initproc = find_proc(pid);
ffffffffc0205eae:	000a6797          	auipc	a5,0xa6
ffffffffc0205eb2:	58a7b523          	sd	a0,1418(a5) # ffffffffc02ac438 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205eb6:	878ff0ef          	jal	ra,ffffffffc0204f2e <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205eba:	609c                	ld	a5,0(s1)
ffffffffc0205ebc:	cfa9                	beqz	a5,ffffffffc0205f16 <proc_init+0x114>
ffffffffc0205ebe:	43dc                	lw	a5,4(a5)
ffffffffc0205ec0:	ebb9                	bnez	a5,ffffffffc0205f16 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ec2:	000a6797          	auipc	a5,0xa6
ffffffffc0205ec6:	57678793          	addi	a5,a5,1398 # ffffffffc02ac438 <initproc>
ffffffffc0205eca:	639c                	ld	a5,0(a5)
ffffffffc0205ecc:	c78d                	beqz	a5,ffffffffc0205ef6 <proc_init+0xf4>
ffffffffc0205ece:	43dc                	lw	a5,4(a5)
ffffffffc0205ed0:	02879363          	bne	a5,s0,ffffffffc0205ef6 <proc_init+0xf4>
}
ffffffffc0205ed4:	60e2                	ld	ra,24(sp)
ffffffffc0205ed6:	6442                	ld	s0,16(sp)
ffffffffc0205ed8:	64a2                	ld	s1,8(sp)
ffffffffc0205eda:	6105                	addi	sp,sp,32
ffffffffc0205edc:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205ede:	00003617          	auipc	a2,0x3
ffffffffc0205ee2:	88260613          	addi	a2,a2,-1918 # ffffffffc0208760 <default_pmm_manager+0x3f8>
ffffffffc0205ee6:	37100593          	li	a1,881
ffffffffc0205eea:	00003517          	auipc	a0,0x3
ffffffffc0205eee:	97650513          	addi	a0,a0,-1674 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205ef2:	b24fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ef6:	00003697          	auipc	a3,0x3
ffffffffc0205efa:	8da68693          	addi	a3,a3,-1830 # ffffffffc02087d0 <default_pmm_manager+0x468>
ffffffffc0205efe:	00001617          	auipc	a2,0x1
ffffffffc0205f02:	d2a60613          	addi	a2,a2,-726 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205f06:	38600593          	li	a1,902
ffffffffc0205f0a:	00003517          	auipc	a0,0x3
ffffffffc0205f0e:	95650513          	addi	a0,a0,-1706 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205f12:	b04fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f16:	00003697          	auipc	a3,0x3
ffffffffc0205f1a:	89268693          	addi	a3,a3,-1902 # ffffffffc02087a8 <default_pmm_manager+0x440>
ffffffffc0205f1e:	00001617          	auipc	a2,0x1
ffffffffc0205f22:	d0a60613          	addi	a2,a2,-758 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205f26:	38500593          	li	a1,901
ffffffffc0205f2a:	00003517          	auipc	a0,0x3
ffffffffc0205f2e:	93650513          	addi	a0,a0,-1738 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205f32:	ae4fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205f36:	00003617          	auipc	a2,0x3
ffffffffc0205f3a:	84a60613          	addi	a2,a2,-1974 # ffffffffc0208780 <default_pmm_manager+0x418>
ffffffffc0205f3e:	37f00593          	li	a1,895
ffffffffc0205f42:	00003517          	auipc	a0,0x3
ffffffffc0205f46:	91e50513          	addi	a0,a0,-1762 # ffffffffc0208860 <default_pmm_manager+0x4f8>
ffffffffc0205f4a:	accfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205f4e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f4e:	1141                	addi	sp,sp,-16
ffffffffc0205f50:	e022                	sd	s0,0(sp)
ffffffffc0205f52:	e406                	sd	ra,8(sp)
ffffffffc0205f54:	000a6417          	auipc	s0,0xa6
ffffffffc0205f58:	4d440413          	addi	s0,s0,1236 # ffffffffc02ac428 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f5c:	6018                	ld	a4,0(s0)
ffffffffc0205f5e:	6f1c                	ld	a5,24(a4)
ffffffffc0205f60:	dffd                	beqz	a5,ffffffffc0205f5e <cpu_idle+0x10>
            schedule();
ffffffffc0205f62:	082000ef          	jal	ra,ffffffffc0205fe4 <schedule>
ffffffffc0205f66:	bfdd                	j	ffffffffc0205f5c <cpu_idle+0xe>

ffffffffc0205f68 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f68:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f6a:	1101                	addi	sp,sp,-32
ffffffffc0205f6c:	ec06                	sd	ra,24(sp)
ffffffffc0205f6e:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f70:	478d                	li	a5,3
ffffffffc0205f72:	04f70a63          	beq	a4,a5,ffffffffc0205fc6 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f76:	100027f3          	csrr	a5,sstatus
ffffffffc0205f7a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f7c:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f7e:	ef8d                	bnez	a5,ffffffffc0205fb8 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f80:	4789                	li	a5,2
ffffffffc0205f82:	00f70f63          	beq	a4,a5,ffffffffc0205fa0 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f86:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f88:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f8c:	e409                	bnez	s0,ffffffffc0205f96 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f8e:	60e2                	ld	ra,24(sp)
ffffffffc0205f90:	6442                	ld	s0,16(sp)
ffffffffc0205f92:	6105                	addi	sp,sp,32
ffffffffc0205f94:	8082                	ret
ffffffffc0205f96:	6442                	ld	s0,16(sp)
ffffffffc0205f98:	60e2                	ld	ra,24(sp)
ffffffffc0205f9a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f9c:	ebafa06f          	j	ffffffffc0200656 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205fa0:	00003617          	auipc	a2,0x3
ffffffffc0205fa4:	91060613          	addi	a2,a2,-1776 # ffffffffc02088b0 <default_pmm_manager+0x548>
ffffffffc0205fa8:	45c9                	li	a1,18
ffffffffc0205faa:	00003517          	auipc	a0,0x3
ffffffffc0205fae:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0208898 <default_pmm_manager+0x530>
ffffffffc0205fb2:	ad0fa0ef          	jal	ra,ffffffffc0200282 <__warn>
ffffffffc0205fb6:	bfd9                	j	ffffffffc0205f8c <wakeup_proc+0x24>
ffffffffc0205fb8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205fba:	ea2fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205fbe:	6522                	ld	a0,8(sp)
ffffffffc0205fc0:	4405                	li	s0,1
ffffffffc0205fc2:	4118                	lw	a4,0(a0)
ffffffffc0205fc4:	bf75                	j	ffffffffc0205f80 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fc6:	00003697          	auipc	a3,0x3
ffffffffc0205fca:	8b268693          	addi	a3,a3,-1870 # ffffffffc0208878 <default_pmm_manager+0x510>
ffffffffc0205fce:	00001617          	auipc	a2,0x1
ffffffffc0205fd2:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206c28 <commands+0x480>
ffffffffc0205fd6:	45a5                	li	a1,9
ffffffffc0205fd8:	00003517          	auipc	a0,0x3
ffffffffc0205fdc:	8c050513          	addi	a0,a0,-1856 # ffffffffc0208898 <default_pmm_manager+0x530>
ffffffffc0205fe0:	a36fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205fe4 <schedule>:

void
schedule(void) {
ffffffffc0205fe4:	1141                	addi	sp,sp,-16
ffffffffc0205fe6:	e406                	sd	ra,8(sp)
ffffffffc0205fe8:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fea:	100027f3          	csrr	a5,sstatus
ffffffffc0205fee:	8b89                	andi	a5,a5,2
ffffffffc0205ff0:	4401                	li	s0,0
ffffffffc0205ff2:	e3d1                	bnez	a5,ffffffffc0206076 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205ff4:	000a6797          	auipc	a5,0xa6
ffffffffc0205ff8:	43478793          	addi	a5,a5,1076 # ffffffffc02ac428 <current>
ffffffffc0205ffc:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206000:	000a6797          	auipc	a5,0xa6
ffffffffc0206004:	43078793          	addi	a5,a5,1072 # ffffffffc02ac430 <idleproc>
ffffffffc0206008:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc020600a:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7558>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020600e:	04a88e63          	beq	a7,a0,ffffffffc020606a <schedule+0x86>
ffffffffc0206012:	0c888693          	addi	a3,a7,200
ffffffffc0206016:	000a6617          	auipc	a2,0xa6
ffffffffc020601a:	55260613          	addi	a2,a2,1362 # ffffffffc02ac568 <proc_list>
        le = last;
ffffffffc020601e:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206020:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206022:	4809                	li	a6,2
    return listelm->next;
ffffffffc0206024:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206026:	00c78863          	beq	a5,a2,ffffffffc0206036 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020602a:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020602e:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206032:	01070463          	beq	a4,a6,ffffffffc020603a <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206036:	fef697e3          	bne	a3,a5,ffffffffc0206024 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020603a:	c589                	beqz	a1,ffffffffc0206044 <schedule+0x60>
ffffffffc020603c:	4198                	lw	a4,0(a1)
ffffffffc020603e:	4789                	li	a5,2
ffffffffc0206040:	00f70e63          	beq	a4,a5,ffffffffc020605c <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206044:	451c                	lw	a5,8(a0)
ffffffffc0206046:	2785                	addiw	a5,a5,1
ffffffffc0206048:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020604a:	00a88463          	beq	a7,a0,ffffffffc0206052 <schedule+0x6e>
            proc_run(next);
ffffffffc020604e:	f0bfe0ef          	jal	ra,ffffffffc0204f58 <proc_run>
    if (flag) {
ffffffffc0206052:	e419                	bnez	s0,ffffffffc0206060 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206054:	60a2                	ld	ra,8(sp)
ffffffffc0206056:	6402                	ld	s0,0(sp)
ffffffffc0206058:	0141                	addi	sp,sp,16
ffffffffc020605a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020605c:	852e                	mv	a0,a1
ffffffffc020605e:	b7dd                	j	ffffffffc0206044 <schedule+0x60>
}
ffffffffc0206060:	6402                	ld	s0,0(sp)
ffffffffc0206062:	60a2                	ld	ra,8(sp)
ffffffffc0206064:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206066:	df0fa06f          	j	ffffffffc0200656 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020606a:	000a6617          	auipc	a2,0xa6
ffffffffc020606e:	4fe60613          	addi	a2,a2,1278 # ffffffffc02ac568 <proc_list>
ffffffffc0206072:	86b2                	mv	a3,a2
ffffffffc0206074:	b76d                	j	ffffffffc020601e <schedule+0x3a>
        intr_disable();
ffffffffc0206076:	de6fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc020607a:	4405                	li	s0,1
ffffffffc020607c:	bfa5                	j	ffffffffc0205ff4 <schedule+0x10>

ffffffffc020607e <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020607e:	000a6797          	auipc	a5,0xa6
ffffffffc0206082:	3aa78793          	addi	a5,a5,938 # ffffffffc02ac428 <current>
ffffffffc0206086:	639c                	ld	a5,0(a5)
}
ffffffffc0206088:	43c8                	lw	a0,4(a5)
ffffffffc020608a:	8082                	ret

ffffffffc020608c <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020608c:	4501                	li	a0,0
ffffffffc020608e:	8082                	ret

ffffffffc0206090 <sys_putc>:
    cputchar(c);
ffffffffc0206090:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206092:	1141                	addi	sp,sp,-16
ffffffffc0206094:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206096:	86efa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc020609a:	60a2                	ld	ra,8(sp)
ffffffffc020609c:	4501                	li	a0,0
ffffffffc020609e:	0141                	addi	sp,sp,16
ffffffffc02060a0:	8082                	ret

ffffffffc02060a2 <sys_kill>:
    return do_kill(pid);
ffffffffc02060a2:	4108                	lw	a0,0(a0)
ffffffffc02060a4:	d17ff06f          	j	ffffffffc0205dba <do_kill>

ffffffffc02060a8 <sys_yield>:
    return do_yield();
ffffffffc02060a8:	cc1ff06f          	j	ffffffffc0205d68 <do_yield>

ffffffffc02060ac <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02060ac:	6d14                	ld	a3,24(a0)
ffffffffc02060ae:	6910                	ld	a2,16(a0)
ffffffffc02060b0:	650c                	ld	a1,8(a0)
ffffffffc02060b2:	6108                	ld	a0,0(a0)
ffffffffc02060b4:	fb6ff06f          	j	ffffffffc020586a <do_execve>

ffffffffc02060b8 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02060b8:	650c                	ld	a1,8(a0)
ffffffffc02060ba:	4108                	lw	a0,0(a0)
ffffffffc02060bc:	cbfff06f          	j	ffffffffc0205d7a <do_wait>

ffffffffc02060c0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02060c0:	000a6797          	auipc	a5,0xa6
ffffffffc02060c4:	36878793          	addi	a5,a5,872 # ffffffffc02ac428 <current>
ffffffffc02060c8:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc02060ca:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02060cc:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060ce:	6a0c                	ld	a1,16(a2)
ffffffffc02060d0:	f51fe06f          	j	ffffffffc0205020 <do_fork>

ffffffffc02060d4 <sys_exit>:
    return do_exit(error_code);
ffffffffc02060d4:	4108                	lw	a0,0(a0)
ffffffffc02060d6:	b76ff06f          	j	ffffffffc020544c <do_exit>

ffffffffc02060da <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060da:	715d                	addi	sp,sp,-80
ffffffffc02060dc:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060de:	000a6497          	auipc	s1,0xa6
ffffffffc02060e2:	34a48493          	addi	s1,s1,842 # ffffffffc02ac428 <current>
ffffffffc02060e6:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060e8:	e0a2                	sd	s0,64(sp)
ffffffffc02060ea:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060ec:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060ee:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060f0:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060f2:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060f6:	0327ee63          	bltu	a5,s2,ffffffffc0206132 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060fa:	00391713          	slli	a4,s2,0x3
ffffffffc02060fe:	00003797          	auipc	a5,0x3
ffffffffc0206102:	81a78793          	addi	a5,a5,-2022 # ffffffffc0208918 <syscalls>
ffffffffc0206106:	97ba                	add	a5,a5,a4
ffffffffc0206108:	639c                	ld	a5,0(a5)
ffffffffc020610a:	c785                	beqz	a5,ffffffffc0206132 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc020610c:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020610e:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206110:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206112:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206114:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206116:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206118:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc020611a:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020611c:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020611e:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206120:	0028                	addi	a0,sp,8
ffffffffc0206122:	9782                	jalr	a5
ffffffffc0206124:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206126:	60a6                	ld	ra,72(sp)
ffffffffc0206128:	6406                	ld	s0,64(sp)
ffffffffc020612a:	74e2                	ld	s1,56(sp)
ffffffffc020612c:	7942                	ld	s2,48(sp)
ffffffffc020612e:	6161                	addi	sp,sp,80
ffffffffc0206130:	8082                	ret
    print_trapframe(tf);
ffffffffc0206132:	8522                	mv	a0,s0
ffffffffc0206134:	f16fa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206138:	609c                	ld	a5,0(s1)
ffffffffc020613a:	86ca                	mv	a3,s2
ffffffffc020613c:	00002617          	auipc	a2,0x2
ffffffffc0206140:	79460613          	addi	a2,a2,1940 # ffffffffc02088d0 <default_pmm_manager+0x568>
ffffffffc0206144:	43d8                	lw	a4,4(a5)
ffffffffc0206146:	06300593          	li	a1,99
ffffffffc020614a:	0b478793          	addi	a5,a5,180
ffffffffc020614e:	00002517          	auipc	a0,0x2
ffffffffc0206152:	7b250513          	addi	a0,a0,1970 # ffffffffc0208900 <default_pmm_manager+0x598>
ffffffffc0206156:	8c0fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020615a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020615a:	00054783          	lbu	a5,0(a0)
ffffffffc020615e:	cb91                	beqz	a5,ffffffffc0206172 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206160:	4781                	li	a5,0
        cnt ++;
ffffffffc0206162:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0206164:	00f50733          	add	a4,a0,a5
ffffffffc0206168:	00074703          	lbu	a4,0(a4)
ffffffffc020616c:	fb7d                	bnez	a4,ffffffffc0206162 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020616e:	853e                	mv	a0,a5
ffffffffc0206170:	8082                	ret
    size_t cnt = 0;
ffffffffc0206172:	4781                	li	a5,0
}
ffffffffc0206174:	853e                	mv	a0,a5
ffffffffc0206176:	8082                	ret

ffffffffc0206178 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206178:	c185                	beqz	a1,ffffffffc0206198 <strnlen+0x20>
ffffffffc020617a:	00054783          	lbu	a5,0(a0)
ffffffffc020617e:	cf89                	beqz	a5,ffffffffc0206198 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206180:	4781                	li	a5,0
ffffffffc0206182:	a021                	j	ffffffffc020618a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206184:	00074703          	lbu	a4,0(a4)
ffffffffc0206188:	c711                	beqz	a4,ffffffffc0206194 <strnlen+0x1c>
        cnt ++;
ffffffffc020618a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020618c:	00f50733          	add	a4,a0,a5
ffffffffc0206190:	fef59ae3          	bne	a1,a5,ffffffffc0206184 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206194:	853e                	mv	a0,a5
ffffffffc0206196:	8082                	ret
    size_t cnt = 0;
ffffffffc0206198:	4781                	li	a5,0
}
ffffffffc020619a:	853e                	mv	a0,a5
ffffffffc020619c:	8082                	ret

ffffffffc020619e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020619e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02061a0:	0585                	addi	a1,a1,1
ffffffffc02061a2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02061a6:	0785                	addi	a5,a5,1
ffffffffc02061a8:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02061ac:	fb75                	bnez	a4,ffffffffc02061a0 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02061ae:	8082                	ret

ffffffffc02061b0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061b0:	00054783          	lbu	a5,0(a0)
ffffffffc02061b4:	0005c703          	lbu	a4,0(a1)
ffffffffc02061b8:	cb91                	beqz	a5,ffffffffc02061cc <strcmp+0x1c>
ffffffffc02061ba:	00e79c63          	bne	a5,a4,ffffffffc02061d2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02061be:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061c0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02061c4:	0585                	addi	a1,a1,1
ffffffffc02061c6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061ca:	fbe5                	bnez	a5,ffffffffc02061ba <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02061cc:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02061ce:	9d19                	subw	a0,a0,a4
ffffffffc02061d0:	8082                	ret
ffffffffc02061d2:	0007851b          	sext.w	a0,a5
ffffffffc02061d6:	9d19                	subw	a0,a0,a4
ffffffffc02061d8:	8082                	ret

ffffffffc02061da <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02061da:	00054783          	lbu	a5,0(a0)
ffffffffc02061de:	cb91                	beqz	a5,ffffffffc02061f2 <strchr+0x18>
        if (*s == c) {
ffffffffc02061e0:	00b79563          	bne	a5,a1,ffffffffc02061ea <strchr+0x10>
ffffffffc02061e4:	a809                	j	ffffffffc02061f6 <strchr+0x1c>
ffffffffc02061e6:	00b78763          	beq	a5,a1,ffffffffc02061f4 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02061ea:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02061ec:	00054783          	lbu	a5,0(a0)
ffffffffc02061f0:	fbfd                	bnez	a5,ffffffffc02061e6 <strchr+0xc>
    }
    return NULL;
ffffffffc02061f2:	4501                	li	a0,0
}
ffffffffc02061f4:	8082                	ret
ffffffffc02061f6:	8082                	ret

ffffffffc02061f8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02061f8:	ca01                	beqz	a2,ffffffffc0206208 <memset+0x10>
ffffffffc02061fa:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02061fc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061fe:	0785                	addi	a5,a5,1
ffffffffc0206200:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206204:	fec79de3          	bne	a5,a2,ffffffffc02061fe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206208:	8082                	ret

ffffffffc020620a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020620a:	ca19                	beqz	a2,ffffffffc0206220 <memcpy+0x16>
ffffffffc020620c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020620e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206210:	0585                	addi	a1,a1,1
ffffffffc0206212:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206216:	0785                	addi	a5,a5,1
ffffffffc0206218:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020621c:	fec59ae3          	bne	a1,a2,ffffffffc0206210 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206220:	8082                	ret

ffffffffc0206222 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206222:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206226:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206228:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020622c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020622e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206232:	f022                	sd	s0,32(sp)
ffffffffc0206234:	ec26                	sd	s1,24(sp)
ffffffffc0206236:	e84a                	sd	s2,16(sp)
ffffffffc0206238:	f406                	sd	ra,40(sp)
ffffffffc020623a:	e44e                	sd	s3,8(sp)
ffffffffc020623c:	84aa                	mv	s1,a0
ffffffffc020623e:	892e                	mv	s2,a1
ffffffffc0206240:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206244:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0206246:	03067e63          	bleu	a6,a2,ffffffffc0206282 <printnum+0x60>
ffffffffc020624a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020624c:	00805763          	blez	s0,ffffffffc020625a <printnum+0x38>
ffffffffc0206250:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206252:	85ca                	mv	a1,s2
ffffffffc0206254:	854e                	mv	a0,s3
ffffffffc0206256:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206258:	fc65                	bnez	s0,ffffffffc0206250 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020625a:	1a02                	slli	s4,s4,0x20
ffffffffc020625c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206260:	00003797          	auipc	a5,0x3
ffffffffc0206264:	9d878793          	addi	a5,a5,-1576 # ffffffffc0208c38 <error_string+0xc8>
ffffffffc0206268:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020626a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020626c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206270:	70a2                	ld	ra,40(sp)
ffffffffc0206272:	69a2                	ld	s3,8(sp)
ffffffffc0206274:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206276:	85ca                	mv	a1,s2
ffffffffc0206278:	8326                	mv	t1,s1
}
ffffffffc020627a:	6942                	ld	s2,16(sp)
ffffffffc020627c:	64e2                	ld	s1,24(sp)
ffffffffc020627e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206280:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206282:	03065633          	divu	a2,a2,a6
ffffffffc0206286:	8722                	mv	a4,s0
ffffffffc0206288:	f9bff0ef          	jal	ra,ffffffffc0206222 <printnum>
ffffffffc020628c:	b7f9                	j	ffffffffc020625a <printnum+0x38>

ffffffffc020628e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020628e:	7119                	addi	sp,sp,-128
ffffffffc0206290:	f4a6                	sd	s1,104(sp)
ffffffffc0206292:	f0ca                	sd	s2,96(sp)
ffffffffc0206294:	e8d2                	sd	s4,80(sp)
ffffffffc0206296:	e4d6                	sd	s5,72(sp)
ffffffffc0206298:	e0da                	sd	s6,64(sp)
ffffffffc020629a:	fc5e                	sd	s7,56(sp)
ffffffffc020629c:	f862                	sd	s8,48(sp)
ffffffffc020629e:	f06a                	sd	s10,32(sp)
ffffffffc02062a0:	fc86                	sd	ra,120(sp)
ffffffffc02062a2:	f8a2                	sd	s0,112(sp)
ffffffffc02062a4:	ecce                	sd	s3,88(sp)
ffffffffc02062a6:	f466                	sd	s9,40(sp)
ffffffffc02062a8:	ec6e                	sd	s11,24(sp)
ffffffffc02062aa:	892a                	mv	s2,a0
ffffffffc02062ac:	84ae                	mv	s1,a1
ffffffffc02062ae:	8d32                	mv	s10,a2
ffffffffc02062b0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02062b2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062b4:	00002a17          	auipc	s4,0x2
ffffffffc02062b8:	764a0a13          	addi	s4,s4,1892 # ffffffffc0208a18 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02062bc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062c0:	00003c17          	auipc	s8,0x3
ffffffffc02062c4:	8b0c0c13          	addi	s8,s8,-1872 # ffffffffc0208b70 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062c8:	000d4503          	lbu	a0,0(s10)
ffffffffc02062cc:	02500793          	li	a5,37
ffffffffc02062d0:	001d0413          	addi	s0,s10,1
ffffffffc02062d4:	00f50e63          	beq	a0,a5,ffffffffc02062f0 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02062d8:	c521                	beqz	a0,ffffffffc0206320 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062da:	02500993          	li	s3,37
ffffffffc02062de:	a011                	j	ffffffffc02062e2 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02062e0:	c121                	beqz	a0,ffffffffc0206320 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02062e2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062e4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062e6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062e8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062ec:	ff351ae3          	bne	a0,s3,ffffffffc02062e0 <vprintfmt+0x52>
ffffffffc02062f0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062f4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062f8:	4981                	li	s3,0
ffffffffc02062fa:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02062fc:	5cfd                	li	s9,-1
ffffffffc02062fe:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206300:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0206304:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206306:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020630a:	0ff6f693          	andi	a3,a3,255
ffffffffc020630e:	00140d13          	addi	s10,s0,1
ffffffffc0206312:	20d5e563          	bltu	a1,a3,ffffffffc020651c <vprintfmt+0x28e>
ffffffffc0206316:	068a                	slli	a3,a3,0x2
ffffffffc0206318:	96d2                	add	a3,a3,s4
ffffffffc020631a:	4294                	lw	a3,0(a3)
ffffffffc020631c:	96d2                	add	a3,a3,s4
ffffffffc020631e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206320:	70e6                	ld	ra,120(sp)
ffffffffc0206322:	7446                	ld	s0,112(sp)
ffffffffc0206324:	74a6                	ld	s1,104(sp)
ffffffffc0206326:	7906                	ld	s2,96(sp)
ffffffffc0206328:	69e6                	ld	s3,88(sp)
ffffffffc020632a:	6a46                	ld	s4,80(sp)
ffffffffc020632c:	6aa6                	ld	s5,72(sp)
ffffffffc020632e:	6b06                	ld	s6,64(sp)
ffffffffc0206330:	7be2                	ld	s7,56(sp)
ffffffffc0206332:	7c42                	ld	s8,48(sp)
ffffffffc0206334:	7ca2                	ld	s9,40(sp)
ffffffffc0206336:	7d02                	ld	s10,32(sp)
ffffffffc0206338:	6de2                	ld	s11,24(sp)
ffffffffc020633a:	6109                	addi	sp,sp,128
ffffffffc020633c:	8082                	ret
    if (lflag >= 2) {
ffffffffc020633e:	4705                	li	a4,1
ffffffffc0206340:	008a8593          	addi	a1,s5,8
ffffffffc0206344:	01074463          	blt	a4,a6,ffffffffc020634c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0206348:	26080363          	beqz	a6,ffffffffc02065ae <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020634c:	000ab603          	ld	a2,0(s5)
ffffffffc0206350:	46c1                	li	a3,16
ffffffffc0206352:	8aae                	mv	s5,a1
ffffffffc0206354:	a06d                	j	ffffffffc02063fe <vprintfmt+0x170>
            goto reswitch;
ffffffffc0206356:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020635a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020635c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020635e:	b765                	j	ffffffffc0206306 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0206360:	000aa503          	lw	a0,0(s5)
ffffffffc0206364:	85a6                	mv	a1,s1
ffffffffc0206366:	0aa1                	addi	s5,s5,8
ffffffffc0206368:	9902                	jalr	s2
            break;
ffffffffc020636a:	bfb9                	j	ffffffffc02062c8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020636c:	4705                	li	a4,1
ffffffffc020636e:	008a8993          	addi	s3,s5,8
ffffffffc0206372:	01074463          	blt	a4,a6,ffffffffc020637a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0206376:	22080463          	beqz	a6,ffffffffc020659e <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020637a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020637e:	24044463          	bltz	s0,ffffffffc02065c6 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0206382:	8622                	mv	a2,s0
ffffffffc0206384:	8ace                	mv	s5,s3
ffffffffc0206386:	46a9                	li	a3,10
ffffffffc0206388:	a89d                	j	ffffffffc02063fe <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020638a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020638e:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206390:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0206392:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206396:	8fb5                	xor	a5,a5,a3
ffffffffc0206398:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020639c:	1ad74363          	blt	a4,a3,ffffffffc0206542 <vprintfmt+0x2b4>
ffffffffc02063a0:	00369793          	slli	a5,a3,0x3
ffffffffc02063a4:	97e2                	add	a5,a5,s8
ffffffffc02063a6:	639c                	ld	a5,0(a5)
ffffffffc02063a8:	18078d63          	beqz	a5,ffffffffc0206542 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02063ac:	86be                	mv	a3,a5
ffffffffc02063ae:	00000617          	auipc	a2,0x0
ffffffffc02063b2:	2b260613          	addi	a2,a2,690 # ffffffffc0206660 <etext+0x2e>
ffffffffc02063b6:	85a6                	mv	a1,s1
ffffffffc02063b8:	854a                	mv	a0,s2
ffffffffc02063ba:	240000ef          	jal	ra,ffffffffc02065fa <printfmt>
ffffffffc02063be:	b729                	j	ffffffffc02062c8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02063c0:	00144603          	lbu	a2,1(s0)
ffffffffc02063c4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063c6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063c8:	bf3d                	j	ffffffffc0206306 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02063ca:	4705                	li	a4,1
ffffffffc02063cc:	008a8593          	addi	a1,s5,8
ffffffffc02063d0:	01074463          	blt	a4,a6,ffffffffc02063d8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02063d4:	1e080263          	beqz	a6,ffffffffc02065b8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02063d8:	000ab603          	ld	a2,0(s5)
ffffffffc02063dc:	46a1                	li	a3,8
ffffffffc02063de:	8aae                	mv	s5,a1
ffffffffc02063e0:	a839                	j	ffffffffc02063fe <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02063e2:	03000513          	li	a0,48
ffffffffc02063e6:	85a6                	mv	a1,s1
ffffffffc02063e8:	e03e                	sd	a5,0(sp)
ffffffffc02063ea:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02063ec:	85a6                	mv	a1,s1
ffffffffc02063ee:	07800513          	li	a0,120
ffffffffc02063f2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02063f4:	0aa1                	addi	s5,s5,8
ffffffffc02063f6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02063fa:	6782                	ld	a5,0(sp)
ffffffffc02063fc:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063fe:	876e                	mv	a4,s11
ffffffffc0206400:	85a6                	mv	a1,s1
ffffffffc0206402:	854a                	mv	a0,s2
ffffffffc0206404:	e1fff0ef          	jal	ra,ffffffffc0206222 <printnum>
            break;
ffffffffc0206408:	b5c1                	j	ffffffffc02062c8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020640a:	000ab603          	ld	a2,0(s5)
ffffffffc020640e:	0aa1                	addi	s5,s5,8
ffffffffc0206410:	1c060663          	beqz	a2,ffffffffc02065dc <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0206414:	00160413          	addi	s0,a2,1
ffffffffc0206418:	17b05c63          	blez	s11,ffffffffc0206590 <vprintfmt+0x302>
ffffffffc020641c:	02d00593          	li	a1,45
ffffffffc0206420:	14b79263          	bne	a5,a1,ffffffffc0206564 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206424:	00064783          	lbu	a5,0(a2)
ffffffffc0206428:	0007851b          	sext.w	a0,a5
ffffffffc020642c:	c905                	beqz	a0,ffffffffc020645c <vprintfmt+0x1ce>
ffffffffc020642e:	000cc563          	bltz	s9,ffffffffc0206438 <vprintfmt+0x1aa>
ffffffffc0206432:	3cfd                	addiw	s9,s9,-1
ffffffffc0206434:	036c8263          	beq	s9,s6,ffffffffc0206458 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0206438:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020643a:	18098463          	beqz	s3,ffffffffc02065c2 <vprintfmt+0x334>
ffffffffc020643e:	3781                	addiw	a5,a5,-32
ffffffffc0206440:	18fbf163          	bleu	a5,s7,ffffffffc02065c2 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0206444:	03f00513          	li	a0,63
ffffffffc0206448:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020644a:	0405                	addi	s0,s0,1
ffffffffc020644c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206450:	3dfd                	addiw	s11,s11,-1
ffffffffc0206452:	0007851b          	sext.w	a0,a5
ffffffffc0206456:	fd61                	bnez	a0,ffffffffc020642e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206458:	e7b058e3          	blez	s11,ffffffffc02062c8 <vprintfmt+0x3a>
ffffffffc020645c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020645e:	85a6                	mv	a1,s1
ffffffffc0206460:	02000513          	li	a0,32
ffffffffc0206464:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206466:	e60d81e3          	beqz	s11,ffffffffc02062c8 <vprintfmt+0x3a>
ffffffffc020646a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020646c:	85a6                	mv	a1,s1
ffffffffc020646e:	02000513          	li	a0,32
ffffffffc0206472:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206474:	fe0d94e3          	bnez	s11,ffffffffc020645c <vprintfmt+0x1ce>
ffffffffc0206478:	bd81                	j	ffffffffc02062c8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020647a:	4705                	li	a4,1
ffffffffc020647c:	008a8593          	addi	a1,s5,8
ffffffffc0206480:	01074463          	blt	a4,a6,ffffffffc0206488 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0206484:	12080063          	beqz	a6,ffffffffc02065a4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206488:	000ab603          	ld	a2,0(s5)
ffffffffc020648c:	46a9                	li	a3,10
ffffffffc020648e:	8aae                	mv	s5,a1
ffffffffc0206490:	b7bd                	j	ffffffffc02063fe <vprintfmt+0x170>
ffffffffc0206492:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0206496:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020649a:	846a                	mv	s0,s10
ffffffffc020649c:	b5ad                	j	ffffffffc0206306 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020649e:	85a6                	mv	a1,s1
ffffffffc02064a0:	02500513          	li	a0,37
ffffffffc02064a4:	9902                	jalr	s2
            break;
ffffffffc02064a6:	b50d                	j	ffffffffc02062c8 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02064a8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02064ac:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02064b0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064b2:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02064b4:	e40dd9e3          	bgez	s11,ffffffffc0206306 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02064b8:	8de6                	mv	s11,s9
ffffffffc02064ba:	5cfd                	li	s9,-1
ffffffffc02064bc:	b5a9                	j	ffffffffc0206306 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02064be:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02064c2:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064c6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064c8:	bd3d                	j	ffffffffc0206306 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02064ca:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02064ce:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064d2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02064d4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02064d8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064dc:	fcd56ce3          	bltu	a0,a3,ffffffffc02064b4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02064e0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02064e2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02064e6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02064ea:	0196873b          	addw	a4,a3,s9
ffffffffc02064ee:	0017171b          	slliw	a4,a4,0x1
ffffffffc02064f2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02064f6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02064fa:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02064fe:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206502:	fcd57fe3          	bleu	a3,a0,ffffffffc02064e0 <vprintfmt+0x252>
ffffffffc0206506:	b77d                	j	ffffffffc02064b4 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0206508:	fffdc693          	not	a3,s11
ffffffffc020650c:	96fd                	srai	a3,a3,0x3f
ffffffffc020650e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0206512:	00144603          	lbu	a2,1(s0)
ffffffffc0206516:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206518:	846a                	mv	s0,s10
ffffffffc020651a:	b3f5                	j	ffffffffc0206306 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020651c:	85a6                	mv	a1,s1
ffffffffc020651e:	02500513          	li	a0,37
ffffffffc0206522:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206524:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206528:	02500793          	li	a5,37
ffffffffc020652c:	8d22                	mv	s10,s0
ffffffffc020652e:	d8f70de3          	beq	a4,a5,ffffffffc02062c8 <vprintfmt+0x3a>
ffffffffc0206532:	02500713          	li	a4,37
ffffffffc0206536:	1d7d                	addi	s10,s10,-1
ffffffffc0206538:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020653c:	fee79de3          	bne	a5,a4,ffffffffc0206536 <vprintfmt+0x2a8>
ffffffffc0206540:	b361                	j	ffffffffc02062c8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206542:	00002617          	auipc	a2,0x2
ffffffffc0206546:	7d660613          	addi	a2,a2,2006 # ffffffffc0208d18 <error_string+0x1a8>
ffffffffc020654a:	85a6                	mv	a1,s1
ffffffffc020654c:	854a                	mv	a0,s2
ffffffffc020654e:	0ac000ef          	jal	ra,ffffffffc02065fa <printfmt>
ffffffffc0206552:	bb9d                	j	ffffffffc02062c8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206554:	00002617          	auipc	a2,0x2
ffffffffc0206558:	7bc60613          	addi	a2,a2,1980 # ffffffffc0208d10 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc020655c:	00002417          	auipc	s0,0x2
ffffffffc0206560:	7b540413          	addi	s0,s0,1973 # ffffffffc0208d11 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206564:	8532                	mv	a0,a2
ffffffffc0206566:	85e6                	mv	a1,s9
ffffffffc0206568:	e032                	sd	a2,0(sp)
ffffffffc020656a:	e43e                	sd	a5,8(sp)
ffffffffc020656c:	c0dff0ef          	jal	ra,ffffffffc0206178 <strnlen>
ffffffffc0206570:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206574:	6602                	ld	a2,0(sp)
ffffffffc0206576:	01b05d63          	blez	s11,ffffffffc0206590 <vprintfmt+0x302>
ffffffffc020657a:	67a2                	ld	a5,8(sp)
ffffffffc020657c:	2781                	sext.w	a5,a5
ffffffffc020657e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206580:	6522                	ld	a0,8(sp)
ffffffffc0206582:	85a6                	mv	a1,s1
ffffffffc0206584:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206586:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206588:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020658a:	6602                	ld	a2,0(sp)
ffffffffc020658c:	fe0d9ae3          	bnez	s11,ffffffffc0206580 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206590:	00064783          	lbu	a5,0(a2)
ffffffffc0206594:	0007851b          	sext.w	a0,a5
ffffffffc0206598:	e8051be3          	bnez	a0,ffffffffc020642e <vprintfmt+0x1a0>
ffffffffc020659c:	b335                	j	ffffffffc02062c8 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020659e:	000aa403          	lw	s0,0(s5)
ffffffffc02065a2:	bbf1                	j	ffffffffc020637e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02065a4:	000ae603          	lwu	a2,0(s5)
ffffffffc02065a8:	46a9                	li	a3,10
ffffffffc02065aa:	8aae                	mv	s5,a1
ffffffffc02065ac:	bd89                	j	ffffffffc02063fe <vprintfmt+0x170>
ffffffffc02065ae:	000ae603          	lwu	a2,0(s5)
ffffffffc02065b2:	46c1                	li	a3,16
ffffffffc02065b4:	8aae                	mv	s5,a1
ffffffffc02065b6:	b5a1                	j	ffffffffc02063fe <vprintfmt+0x170>
ffffffffc02065b8:	000ae603          	lwu	a2,0(s5)
ffffffffc02065bc:	46a1                	li	a3,8
ffffffffc02065be:	8aae                	mv	s5,a1
ffffffffc02065c0:	bd3d                	j	ffffffffc02063fe <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02065c2:	9902                	jalr	s2
ffffffffc02065c4:	b559                	j	ffffffffc020644a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02065c6:	85a6                	mv	a1,s1
ffffffffc02065c8:	02d00513          	li	a0,45
ffffffffc02065cc:	e03e                	sd	a5,0(sp)
ffffffffc02065ce:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065d0:	8ace                	mv	s5,s3
ffffffffc02065d2:	40800633          	neg	a2,s0
ffffffffc02065d6:	46a9                	li	a3,10
ffffffffc02065d8:	6782                	ld	a5,0(sp)
ffffffffc02065da:	b515                	j	ffffffffc02063fe <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02065dc:	01b05663          	blez	s11,ffffffffc02065e8 <vprintfmt+0x35a>
ffffffffc02065e0:	02d00693          	li	a3,45
ffffffffc02065e4:	f6d798e3          	bne	a5,a3,ffffffffc0206554 <vprintfmt+0x2c6>
ffffffffc02065e8:	00002417          	auipc	s0,0x2
ffffffffc02065ec:	72940413          	addi	s0,s0,1833 # ffffffffc0208d11 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065f0:	02800513          	li	a0,40
ffffffffc02065f4:	02800793          	li	a5,40
ffffffffc02065f8:	bd1d                	j	ffffffffc020642e <vprintfmt+0x1a0>

ffffffffc02065fa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065fa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065fc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206600:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206602:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206604:	ec06                	sd	ra,24(sp)
ffffffffc0206606:	f83a                	sd	a4,48(sp)
ffffffffc0206608:	fc3e                	sd	a5,56(sp)
ffffffffc020660a:	e0c2                	sd	a6,64(sp)
ffffffffc020660c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020660e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206610:	c7fff0ef          	jal	ra,ffffffffc020628e <vprintfmt>
}
ffffffffc0206614:	60e2                	ld	ra,24(sp)
ffffffffc0206616:	6161                	addi	sp,sp,80
ffffffffc0206618:	8082                	ret

ffffffffc020661a <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020661a:	9e3707b7          	lui	a5,0x9e370
ffffffffc020661e:	2785                	addiw	a5,a5,1
ffffffffc0206620:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206624:	02000793          	li	a5,32
ffffffffc0206628:	40b785bb          	subw	a1,a5,a1
}
ffffffffc020662c:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206630:	8082                	ret
