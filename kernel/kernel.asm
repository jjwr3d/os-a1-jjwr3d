
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	5c813103          	ld	sp,1480(sp) # 8000a5c8 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	03e000ef          	jal	80000054 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000022:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000026:	577d                	li	a4,-1
    80000028:	177e                	slli	a4,a4,0x3f
    8000002a:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000030:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000038:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003c:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000040:	000f4737          	lui	a4,0xf4
    80000044:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004a:	14d79073          	csrw	stimecmp,a5
}
    8000004e:	6422                	ld	s0,8(sp)
    80000050:	0141                	addi	sp,sp,16
    80000052:	8082                	ret

0000000080000054 <start>:
{
    80000054:	1141                	addi	sp,sp,-16
    80000056:	e406                	sd	ra,8(sp)
    80000058:	e022                	sd	s0,0(sp)
    8000005a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000005c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000060:	7779                	lui	a4,0xffffe
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaccf>
    80000066:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000068:	6705                	lui	a4,0x1
    8000006a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000006e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000074:	00001797          	auipc	a5,0x1
    80000078:	dbc78793          	addi	a5,a5,-580 # 80000e30 <main>
    8000007c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000080:	4781                	li	a5,0
    80000082:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000086:	67c1                	lui	a5,0x10
    80000088:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000008e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000092:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000096:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009a:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000009e:	57fd                	li	a5,-1
    800000a0:	83a9                	srli	a5,a5,0xa
    800000a2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000a6:	47bd                	li	a5,15
    800000a8:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000ac:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b0:	4705                	li	a4,1
    800000b2:	1776                	slli	a4,a4,0x3d
    800000b4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000b6:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000ba:	f63ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000be:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c2:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c6:	30200073          	mret
}
    800000ca:	60a2                	ld	ra,8(sp)
    800000cc:	6402                	ld	s0,0(sp)
    800000ce:	0141                	addi	sp,sp,16
    800000d0:	8082                	ret

00000000800000d2 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d2:	7119                	addi	sp,sp,-128
    800000d4:	fc86                	sd	ra,120(sp)
    800000d6:	f8a2                	sd	s0,112(sp)
    800000d8:	f4a6                	sd	s1,104(sp)
    800000da:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000dc:	06c05a63          	blez	a2,80000150 <consolewrite+0x7e>
    800000e0:	f0ca                	sd	s2,96(sp)
    800000e2:	ecce                	sd	s3,88(sp)
    800000e4:	e8d2                	sd	s4,80(sp)
    800000e6:	e4d6                	sd	s5,72(sp)
    800000e8:	e0da                	sd	s6,64(sp)
    800000ea:	fc5e                	sd	s7,56(sp)
    800000ec:	f862                	sd	s8,48(sp)
    800000ee:	f466                	sd	s9,40(sp)
    800000f0:	8aaa                	mv	s5,a0
    800000f2:	8b2e                	mv	s6,a1
    800000f4:	8a32                	mv	s4,a2
  int i = 0;
    800000f6:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000f8:	02000c13          	li	s8,32
    800000fc:	02000c93          	li	s9,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000100:	5bfd                	li	s7,-1
    80000102:	a035                	j	8000012e <consolewrite+0x5c>
    if (nn > n - i)
    80000104:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000108:	86ce                	mv	a3,s3
    8000010a:	01648633          	add	a2,s1,s6
    8000010e:	85d6                	mv	a1,s5
    80000110:	f8040513          	addi	a0,s0,-128
    80000114:	1c0020ef          	jal	800022d4 <either_copyin>
    80000118:	03750e63          	beq	a0,s7,80000154 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011c:	85ce                	mv	a1,s3
    8000011e:	f8040513          	addi	a0,s0,-128
    80000122:	786000ef          	jal	800008a8 <uartwrite>
    i += nn;
    80000126:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    8000012a:	0144da63          	bge	s1,s4,8000013e <consolewrite+0x6c>
    if (nn > n - i)
    8000012e:	409a093b          	subw	s2,s4,s1
    80000132:	0009079b          	sext.w	a5,s2
    80000136:	fcfc57e3          	bge	s8,a5,80000104 <consolewrite+0x32>
    8000013a:	8966                	mv	s2,s9
    8000013c:	b7e1                	j	80000104 <consolewrite+0x32>
    8000013e:	7906                	ld	s2,96(sp)
    80000140:	69e6                	ld	s3,88(sp)
    80000142:	6a46                	ld	s4,80(sp)
    80000144:	6aa6                	ld	s5,72(sp)
    80000146:	6b06                	ld	s6,64(sp)
    80000148:	7be2                	ld	s7,56(sp)
    8000014a:	7c42                	ld	s8,48(sp)
    8000014c:	7ca2                	ld	s9,40(sp)
    8000014e:	a819                	j	80000164 <consolewrite+0x92>
  int i = 0;
    80000150:	4481                	li	s1,0
    80000152:	a809                	j	80000164 <consolewrite+0x92>
    80000154:	7906                	ld	s2,96(sp)
    80000156:	69e6                	ld	s3,88(sp)
    80000158:	6a46                	ld	s4,80(sp)
    8000015a:	6aa6                	ld	s5,72(sp)
    8000015c:	6b06                	ld	s6,64(sp)
    8000015e:	7be2                	ld	s7,56(sp)
    80000160:	7c42                	ld	s8,48(sp)
    80000162:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000164:	8526                	mv	a0,s1
    80000166:	70e6                	ld	ra,120(sp)
    80000168:	7446                	ld	s0,112(sp)
    8000016a:	74a6                	ld	s1,104(sp)
    8000016c:	6109                	addi	sp,sp,128
    8000016e:	8082                	ret

0000000080000170 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	711d                	addi	sp,sp,-96
    80000172:	ec86                	sd	ra,88(sp)
    80000174:	e8a2                	sd	s0,80(sp)
    80000176:	e4a6                	sd	s1,72(sp)
    80000178:	e0ca                	sd	s2,64(sp)
    8000017a:	fc4e                	sd	s3,56(sp)
    8000017c:	f852                	sd	s4,48(sp)
    8000017e:	f456                	sd	s5,40(sp)
    80000180:	f05a                	sd	s6,32(sp)
    80000182:	1080                	addi	s0,sp,96
    80000184:	8aaa                	mv	s5,a0
    80000186:	8a2e                	mv	s4,a1
    80000188:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000018a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018e:	00012517          	auipc	a0,0x12
    80000192:	48250513          	addi	a0,a0,1154 # 80012610 <cons>
    80000196:	23d000ef          	jal	80000bd2 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000019a:	00012497          	auipc	s1,0x12
    8000019e:	47648493          	addi	s1,s1,1142 # 80012610 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a2:	00012917          	auipc	s2,0x12
    800001a6:	50690913          	addi	s2,s2,1286 # 800126a8 <cons+0x98>
  while (n > 0) {
    800001aa:	0d305463          	blez	s3,80000272 <consoleread+0x102>
    while (cons.r == cons.w) {
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71963          	bne	a4,a5,80000268 <consoleread+0xf8>
      if (killed(myproc())) {
    800001ba:	72a010ef          	jal	800018e4 <myproc>
    800001be:	791010ef          	jal	8000214e <killed>
    800001c2:	e925                	bnez	a0,80000232 <consoleread+0xc2>
      sleep_prepare(&cons.r);
    800001c4:	854a                	mv	a0,s2
    800001c6:	52f010ef          	jal	80001ef4 <sleep_prepare>
      release(&cons.lock);
    800001ca:	8526                	mv	a0,s1
    800001cc:	293000ef          	jal	80000c5e <release>
      sleep();
    800001d0:	561010ef          	jal	80001f30 <sleep>
      acquire(&cons.lock);
    800001d4:	8526                	mv	a0,s1
    800001d6:	1fd000ef          	jal	80000bd2 <acquire>
    while (cons.r == cons.w) {
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70ce3          	beq	a4,a5,800001ba <consoleread+0x4a>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00012717          	auipc	a4,0x12
    800001ec:	42870713          	addi	a4,a4,1064 # 80012610 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8663          	beq	s7,a3,80000254 <consoleread+0xe4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	06e020ef          	jal	80002288 <either_copyout>
    8000021e:	57fd                	li	a5,-1
    80000220:	04f50863          	beq	a0,a5,80000270 <consoleread+0x100>
      break;

    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000228:	47a9                	li	a5,10
    8000022a:	04fb8d63          	beq	s7,a5,80000284 <consoleread+0x114>
    8000022e:	6be2                	ld	s7,24(sp)
    80000230:	bfad                	j	800001aa <consoleread+0x3a>
        release(&cons.lock);
    80000232:	00012517          	auipc	a0,0x12
    80000236:	3de50513          	addi	a0,a0,990 # 80012610 <cons>
    8000023a:	225000ef          	jal	80000c5e <release>
        return -1;
    8000023e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000240:	60e6                	ld	ra,88(sp)
    80000242:	6446                	ld	s0,80(sp)
    80000244:	64a6                	ld	s1,72(sp)
    80000246:	6906                	ld	s2,64(sp)
    80000248:	79e2                	ld	s3,56(sp)
    8000024a:	7a42                	ld	s4,48(sp)
    8000024c:	7aa2                	ld	s5,40(sp)
    8000024e:	7b02                	ld	s6,32(sp)
    80000250:	6125                	addi	sp,sp,96
    80000252:	8082                	ret
      if (n < target) {
    80000254:	0009871b          	sext.w	a4,s3
    80000258:	01677a63          	bgeu	a4,s6,8000026c <consoleread+0xfc>
        cons.r--;
    8000025c:	00012717          	auipc	a4,0x12
    80000260:	44f72623          	sw	a5,1100(a4) # 800126a8 <cons+0x98>
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	a031                	j	80000272 <consoleread+0x102>
    80000268:	ec5e                	sd	s7,24(sp)
    8000026a:	bfbd                	j	800001e8 <consoleread+0x78>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a011                	j	80000272 <consoleread+0x102>
    80000270:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000272:	00012517          	auipc	a0,0x12
    80000276:	39e50513          	addi	a0,a0,926 # 80012610 <cons>
    8000027a:	1e5000ef          	jal	80000c5e <release>
  return target - n;
    8000027e:	413b053b          	subw	a0,s6,s3
    80000282:	bf7d                	j	80000240 <consoleread+0xd0>
    80000284:	6be2                	ld	s7,24(sp)
    80000286:	b7f5                	j	80000272 <consoleread+0x102>

0000000080000288 <consputc>:
{
    80000288:	1141                	addi	sp,sp,-16
    8000028a:	e406                	sd	ra,8(sp)
    8000028c:	e022                	sd	s0,0(sp)
    8000028e:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000290:	10000793          	li	a5,256
    80000294:	00f50863          	beq	a0,a5,800002a4 <consputc+0x1c>
    uartputc_sync(c);
    80000298:	696000ef          	jal	8000092e <uartputc_sync>
}
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
    uartputc_sync('\b');
    800002a4:	4521                	li	a0,8
    800002a6:	688000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync(' ');
    800002aa:	02000513          	li	a0,32
    800002ae:	680000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	67a000ef          	jal	8000092e <uartputc_sync>
    800002b8:	b7d5                	j	8000029c <consputc+0x14>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00012517          	auipc	a0,0x12
    800002ca:	34a50513          	addi	a0,a0,842 # 80012610 <cons>
    800002ce:	105000ef          	jal	80000bd2 <acquire>

  switch (c) {
    800002d2:	47d5                	li	a5,21
    800002d4:	08f48f63          	beq	s1,a5,80000372 <consoleintr+0xb8>
    800002d8:	0297c563          	blt	a5,s1,80000302 <consoleintr+0x48>
    800002dc:	47a1                	li	a5,8
    800002de:	0ef48463          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    800002e2:	47c1                	li	a5,16
    800002e4:	10f49563          	bne	s1,a5,800003ee <consoleintr+0x134>
  case C('P'): // Print process list.
    procdump();
    800002e8:	038020ef          	jal	80002320 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ec:	00012517          	auipc	a0,0x12
    800002f0:	32450513          	addi	a0,a0,804 # 80012610 <cons>
    800002f4:	16b000ef          	jal	80000c5e <release>
}
    800002f8:	60e2                	ld	ra,24(sp)
    800002fa:	6442                	ld	s0,16(sp)
    800002fc:	64a2                	ld	s1,8(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch (c) {
    80000302:	07f00793          	li	a5,127
    80000306:	0cf48063          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030a:	00012717          	auipc	a4,0x12
    8000030e:	30670713          	addi	a4,a4,774 # 80012610 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf766e3          	bltu	a4,a5,800002ec <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x13a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	f5dff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000330:	00012797          	auipc	a5,0x12
    80000334:	2e078793          	addi	a5,a5,736 # 80012610 <cons>
    80000338:	0a07a683          	lw	a3,160(a5)
    8000033c:	0016871b          	addiw	a4,a3,1
    80000340:	0007061b          	sext.w	a2,a4
    80000344:	0ae7a023          	sw	a4,160(a5)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	97b6                	add	a5,a5,a3
    8000034e:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	47a9                	li	a5,10
    80000354:	0cf48563          	beq	s1,a5,8000041e <consoleintr+0x164>
    80000358:	4791                	li	a5,4
    8000035a:	0cf48263          	beq	s1,a5,8000041e <consoleintr+0x164>
    8000035e:	00012797          	auipc	a5,0x12
    80000362:	34a7a783          	lw	a5,842(a5) # 800126a8 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f710e3          	bne	a4,a5,800002ec <consoleintr+0x32>
    80000370:	a07d                	j	8000041e <consoleintr+0x164>
    80000372:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000374:	00012717          	auipc	a4,0x12
    80000378:	29c70713          	addi	a4,a4,668 # 80012610 <cons>
    8000037c:	0a072783          	lw	a5,160(a4)
    80000380:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000384:	00012497          	auipc	s1,0x12
    80000388:	28c48493          	addi	s1,s1,652 # 80012610 <cons>
    while (cons.e != cons.w &&
    8000038c:	4929                	li	s2,10
    8000038e:	02f70863          	beq	a4,a5,800003be <consoleintr+0x104>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	07f7f713          	andi	a4,a5,127
    80000398:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000039a:	01874703          	lbu	a4,24(a4)
    8000039e:	03270263          	beq	a4,s2,800003c2 <consoleintr+0x108>
      cons.e--;
    800003a2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a6:	10000513          	li	a0,256
    800003aa:	edfff0ef          	jal	80000288 <consputc>
    while (cons.e != cons.w &&
    800003ae:	0a04a783          	lw	a5,160(s1)
    800003b2:	09c4a703          	lw	a4,156(s1)
    800003b6:	fcf71ee3          	bne	a4,a5,80000392 <consoleintr+0xd8>
    800003ba:	6902                	ld	s2,0(sp)
    800003bc:	bf05                	j	800002ec <consoleintr+0x32>
    800003be:	6902                	ld	s2,0(sp)
    800003c0:	b735                	j	800002ec <consoleintr+0x32>
    800003c2:	6902                	ld	s2,0(sp)
    800003c4:	b725                	j	800002ec <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c6:	00012717          	auipc	a4,0x12
    800003ca:	24a70713          	addi	a4,a4,586 # 80012610 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70be3          	beq	a4,a5,800002ec <consoleintr+0x32>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00012717          	auipc	a4,0x12
    800003e0:	2cf72a23          	sw	a5,724(a4) # 800126b0 <cons+0xa0>
      consputc(BACKSPACE);
    800003e4:	10000513          	li	a0,256
    800003e8:	ea1ff0ef          	jal	80000288 <consputc>
    800003ec:	b701                	j	800002ec <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ee:	ee048fe3          	beqz	s1,800002ec <consoleintr+0x32>
    800003f2:	bf21                	j	8000030a <consoleintr+0x50>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	e93ff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003fa:	00012797          	auipc	a5,0x12
    800003fe:	21678793          	addi	a5,a5,534 # 80012610 <cons>
    80000402:	0a07a703          	lw	a4,160(a5)
    80000406:	0017069b          	addiw	a3,a4,1
    8000040a:	0006861b          	sext.w	a2,a3
    8000040e:	0ad7a023          	sw	a3,160(a5)
    80000412:	07f77713          	andi	a4,a4,127
    80000416:	97ba                	add	a5,a5,a4
    80000418:	4729                	li	a4,10
    8000041a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041e:	00012797          	auipc	a5,0x12
    80000422:	28c7a723          	sw	a2,654(a5) # 800126ac <cons+0x9c>
        wakeup(&cons.r);
    80000426:	00012517          	auipc	a0,0x12
    8000042a:	28250513          	addi	a0,a0,642 # 800126a8 <cons+0x98>
    8000042e:	333010ef          	jal	80001f60 <wakeup>
    80000432:	bd6d                	j	800002ec <consoleintr+0x32>

0000000080000434 <consoleinit>:

void
consoleinit(void)
{
    80000434:	1141                	addi	sp,sp,-16
    80000436:	e406                	sd	ra,8(sp)
    80000438:	e022                	sd	s0,0(sp)
    8000043a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000043c:	00007597          	auipc	a1,0x7
    80000440:	bc458593          	addi	a1,a1,-1084 # 80007000 <etext>
    80000444:	00012517          	auipc	a0,0x12
    80000448:	1cc50513          	addi	a0,a0,460 # 80012610 <cons>
    8000044c:	710000ef          	jal	80000b5c <initlock>

  uartinit();
    80000450:	400000ef          	jal	80000850 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000454:	00022797          	auipc	a5,0x22
    80000458:	54478793          	addi	a5,a5,1348 # 80022998 <devsw>
    8000045c:	00000717          	auipc	a4,0x0
    80000460:	d1470713          	addi	a4,a4,-748 # 80000170 <consoleread>
    80000464:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000466:	00000717          	auipc	a4,0x0
    8000046a:	c6c70713          	addi	a4,a4,-916 # 800000d2 <consolewrite>
    8000046e:	ef98                	sd	a4,24(a5)
}
    80000470:	60a2                	ld	ra,8(sp)
    80000472:	6402                	ld	s0,0(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000478:	7139                	addi	sp,sp,-64
    8000047a:	fc06                	sd	ra,56(sp)
    8000047c:	f822                	sd	s0,48(sp)
    8000047e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000480:	c219                	beqz	a2,80000486 <printint+0xe>
    80000482:	08054063          	bltz	a0,80000502 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000486:	4881                	li	a7,0
    80000488:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000048c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007617          	auipc	a2,0x7
    80000492:	3c260613          	addi	a2,a2,962 # 80007850 <digits>
    80000496:	883e                	mv	a6,a5
    80000498:	2785                	addiw	a5,a5,1
    8000049a:	02b57733          	remu	a4,a0,a1
    8000049e:	9732                	add	a4,a4,a2
    800004a0:	00074703          	lbu	a4,0(a4)
    800004a4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    800004a8:	872a                	mv	a4,a0
    800004aa:	02b55533          	divu	a0,a0,a1
    800004ae:	0685                	addi	a3,a3,1
    800004b0:	feb773e3          	bgeu	a4,a1,80000496 <printint+0x1e>

  if (sign)
    800004b4:	00088a63          	beqz	a7,800004c8 <printint+0x50>
    buf[i++] = '-';
    800004b8:	1781                	addi	a5,a5,-32
    800004ba:	97a2                	add	a5,a5,s0
    800004bc:	02d00713          	li	a4,45
    800004c0:	fee78423          	sb	a4,-24(a5)
    800004c4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    800004c8:	02f05963          	blez	a5,800004fa <printint+0x82>
    800004cc:	f426                	sd	s1,40(sp)
    800004ce:	f04a                	sd	s2,32(sp)
    800004d0:	fc840713          	addi	a4,s0,-56
    800004d4:	00f704b3          	add	s1,a4,a5
    800004d8:	fff70913          	addi	s2,a4,-1
    800004dc:	993e                	add	s2,s2,a5
    800004de:	37fd                	addiw	a5,a5,-1
    800004e0:	1782                	slli	a5,a5,0x20
    800004e2:	9381                	srli	a5,a5,0x20
    800004e4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004e8:	fff4c503          	lbu	a0,-1(s1)
    800004ec:	d9dff0ef          	jal	80000288 <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x70>
    800004f6:	74a2                	ld	s1,40(sp)
    800004f8:	7902                	ld	s2,32(sp)
}
    800004fa:	70e2                	ld	ra,56(sp)
    800004fc:	7442                	ld	s0,48(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4885                	li	a7,1
    x = -xx;
    80000508:	b741                	j	80000488 <printint+0x10>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	e8d2                	sd	s4,80(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	8a2a                	mv	s4,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	0000a797          	auipc	a5,0xa
    8000052c:	0bc7a783          	lw	a5,188(a5) # 8000a5e4 <panicking>
    80000530:	c3a1                	beqz	a5,80000570 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	000a4503          	lbu	a0,0(s4)
    8000053e:	28050763          	beqz	a0,800007cc <printk+0x2c2>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	f0ca                	sd	s2,96(sp)
    80000546:	ecce                	sd	s3,88(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	f862                	sd	s8,48(sp)
    8000054e:	f466                	sd	s9,40(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4981                	li	s3,0
    if (cx != '%') {
    80000556:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000056a:	07000d93          	li	s11,112
    8000056e:	a01d                	j	80000594 <printk+0x8a>
    acquire(&pr.lock);
    80000570:	00012517          	auipc	a0,0x12
    80000574:	14850513          	addi	a0,a0,328 # 800126b8 <pr>
    80000578:	65a000ef          	jal	80000bd2 <acquire>
    8000057c:	bf5d                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057e:	d0bff0ef          	jal	80000288 <consputc>
      continue;
    80000582:	84ce                	mv	s1,s3
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000584:	0014899b          	addiw	s3,s1,1
    80000588:	013a07b3          	add	a5,s4,s3
    8000058c:	0007c503          	lbu	a0,0(a5)
    80000590:	20050b63          	beqz	a0,800007a6 <printk+0x29c>
    if (cx != '%') {
    80000594:	ff5515e3          	bne	a0,s5,8000057e <printk+0x74>
    i++;
    80000598:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i + 0] & 0xff;
    8000059c:	009a07b3          	add	a5,s4,s1
    800005a0:	0007c903          	lbu	s2,0(a5)
    if (c0)
    800005a4:	20090b63          	beqz	s2,800007ba <printk+0x2b0>
      c1 = fmt[i + 1] & 0xff;
    800005a8:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005ac:	86be                	mv	a3,a5
    if (c1)
    800005ae:	c789                	beqz	a5,800005b8 <printk+0xae>
      c2 = fmt[i + 2] & 0xff;
    800005b0:	009a0733          	add	a4,s4,s1
    800005b4:	00274683          	lbu	a3,2(a4)
    if (c0 == 'd') {
    800005b8:	03690963          	beq	s2,s6,800005ea <printk+0xe0>
    } else if (c0 == 'l' && c1 == 'd') {
    800005bc:	05890363          	beq	s2,s8,80000602 <printk+0xf8>
    } else if (c0 == 'u') {
    800005c0:	0d990663          	beq	s2,s9,8000068c <printk+0x182>
    } else if (c0 == 'x') {
    800005c4:	11a90d63          	beq	s2,s10,800006de <printk+0x1d4>
    } else if (c0 == 'p') {
    800005c8:	15b90663          	beq	s2,s11,80000714 <printk+0x20a>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005cc:	06300793          	li	a5,99
    800005d0:	18f90563          	beq	s2,a5,8000075a <printk+0x250>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005d4:	07300793          	li	a5,115
    800005d8:	18f90b63          	beq	s2,a5,8000076e <printk+0x264>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005dc:	03591b63          	bne	s2,s5,80000612 <printk+0x108>
      consputc('%');
    800005e0:	02500513          	li	a0,37
    800005e4:	ca5ff0ef          	jal	80000288 <consputc>
    800005e8:	bf71                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005ea:	f8843783          	ld	a5,-120(s0)
    800005ee:	00878713          	addi	a4,a5,8
    800005f2:	f8e43423          	sd	a4,-120(s0)
    800005f6:	4605                	li	a2,1
    800005f8:	45a9                	li	a1,10
    800005fa:	4388                	lw	a0,0(a5)
    800005fc:	e7dff0ef          	jal	80000478 <printint>
    80000600:	b751                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    80000602:	01678f63          	beq	a5,s6,80000620 <printk+0x116>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000606:	03878b63          	beq	a5,s8,8000063c <printk+0x132>
    } else if (c0 == 'l' && c1 == 'u') {
    8000060a:	09978e63          	beq	a5,s9,800006a6 <printk+0x19c>
    } else if (c0 == 'l' && c1 == 'x') {
    8000060e:	0fa78563          	beq	a5,s10,800006f8 <printk+0x1ee>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000612:	8556                	mv	a0,s5
    80000614:	c75ff0ef          	jal	80000288 <consputc>
      consputc(c0);
    80000618:	854a                	mv	a0,s2
    8000061a:	c6fff0ef          	jal	80000288 <consputc>
    8000061e:	b79d                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000620:	f8843783          	ld	a5,-120(s0)
    80000624:	00878713          	addi	a4,a5,8
    80000628:	f8e43423          	sd	a4,-120(s0)
    8000062c:	4605                	li	a2,1
    8000062e:	45a9                	li	a1,10
    80000630:	6388                	ld	a0,0(a5)
    80000632:	e47ff0ef          	jal	80000478 <printint>
      i += 1;
    80000636:	0029849b          	addiw	s1,s3,2
    8000063a:	b7a9                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    8000063c:	06400793          	li	a5,100
    80000640:	02f68863          	beq	a3,a5,80000670 <printk+0x166>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000644:	07500793          	li	a5,117
    80000648:	06f68d63          	beq	a3,a5,800006c2 <printk+0x1b8>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    8000064c:	07800793          	li	a5,120
    80000650:	fcf691e3          	bne	a3,a5,80000612 <printk+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4601                	li	a2,0
    80000662:	45c1                	li	a1,16
    80000664:	6388                	ld	a0,0(a5)
    80000666:	e13ff0ef          	jal	80000478 <printint>
      i += 2;
    8000066a:	0039849b          	addiw	s1,s3,3
    8000066e:	bf19                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000670:	f8843783          	ld	a5,-120(s0)
    80000674:	00878713          	addi	a4,a5,8
    80000678:	f8e43423          	sd	a4,-120(s0)
    8000067c:	4605                	li	a2,1
    8000067e:	45a9                	li	a1,10
    80000680:	6388                	ld	a0,0(a5)
    80000682:	df7ff0ef          	jal	80000478 <printint>
      i += 2;
    80000686:	0039849b          	addiw	s1,s3,3
    8000068a:	bded                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4601                	li	a2,0
    8000069a:	45a9                	li	a1,10
    8000069c:	0007e503          	lwu	a0,0(a5)
    800006a0:	dd9ff0ef          	jal	80000478 <printint>
    800006a4:	b5c5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a6:	f8843783          	ld	a5,-120(s0)
    800006aa:	00878713          	addi	a4,a5,8
    800006ae:	f8e43423          	sd	a4,-120(s0)
    800006b2:	4601                	li	a2,0
    800006b4:	45a9                	li	a1,10
    800006b6:	6388                	ld	a0,0(a5)
    800006b8:	dc1ff0ef          	jal	80000478 <printint>
      i += 1;
    800006bc:	0029849b          	addiw	s1,s3,2
    800006c0:	b5d1                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c2:	f8843783          	ld	a5,-120(s0)
    800006c6:	00878713          	addi	a4,a5,8
    800006ca:	f8e43423          	sd	a4,-120(s0)
    800006ce:	4601                	li	a2,0
    800006d0:	45a9                	li	a1,10
    800006d2:	6388                	ld	a0,0(a5)
    800006d4:	da5ff0ef          	jal	80000478 <printint>
      i += 2;
    800006d8:	0039849b          	addiw	s1,s3,3
    800006dc:	b565                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	4601                	li	a2,0
    800006ec:	45c1                	li	a1,16
    800006ee:	0007e503          	lwu	a0,0(a5)
    800006f2:	d87ff0ef          	jal	80000478 <printint>
    800006f6:	b579                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4601                	li	a2,0
    80000706:	45c1                	li	a1,16
    80000708:	6388                	ld	a0,0(a5)
    8000070a:	d6fff0ef          	jal	80000478 <printint>
      i += 1;
    8000070e:	0029849b          	addiw	s1,s3,2
    80000712:	bd8d                	j	80000584 <printk+0x7a>
    80000714:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000716:	f8843783          	ld	a5,-120(s0)
    8000071a:	00878713          	addi	a4,a5,8
    8000071e:	f8e43423          	sd	a4,-120(s0)
    80000722:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000726:	03000513          	li	a0,48
    8000072a:	b5fff0ef          	jal	80000288 <consputc>
  consputc('x');
    8000072e:	07800513          	li	a0,120
    80000732:	b57ff0ef          	jal	80000288 <consputc>
    80000736:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000738:	00007b97          	auipc	s7,0x7
    8000073c:	118b8b93          	addi	s7,s7,280 # 80007850 <digits>
    80000740:	03c9d793          	srli	a5,s3,0x3c
    80000744:	97de                	add	a5,a5,s7
    80000746:	0007c503          	lbu	a0,0(a5)
    8000074a:	b3fff0ef          	jal	80000288 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000074e:	0992                	slli	s3,s3,0x4
    80000750:	397d                	addiw	s2,s2,-1
    80000752:	fe0917e3          	bnez	s2,80000740 <printk+0x236>
    80000756:	7be2                	ld	s7,56(sp)
    80000758:	b535                	j	80000584 <printk+0x7a>
      consputc(va_arg(ap, uint));
    8000075a:	f8843783          	ld	a5,-120(s0)
    8000075e:	00878713          	addi	a4,a5,8
    80000762:	f8e43423          	sd	a4,-120(s0)
    80000766:	4388                	lw	a0,0(a5)
    80000768:	b21ff0ef          	jal	80000288 <consputc>
    8000076c:	bd21                	j	80000584 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    8000076e:	f8843783          	ld	a5,-120(s0)
    80000772:	00878713          	addi	a4,a5,8
    80000776:	f8e43423          	sd	a4,-120(s0)
    8000077a:	0007b903          	ld	s2,0(a5)
    8000077e:	00090d63          	beqz	s2,80000798 <printk+0x28e>
      for (; *s; s++)
    80000782:	00094503          	lbu	a0,0(s2)
    80000786:	de050fe3          	beqz	a0,80000584 <printk+0x7a>
        consputc(*s);
    8000078a:	affff0ef          	jal	80000288 <consputc>
      for (; *s; s++)
    8000078e:	0905                	addi	s2,s2,1
    80000790:	00094503          	lbu	a0,0(s2)
    80000794:	f97d                	bnez	a0,8000078a <printk+0x280>
    80000796:	b3fd                	j	80000584 <printk+0x7a>
        s = "(null)";
    80000798:	00007917          	auipc	s2,0x7
    8000079c:	87090913          	addi	s2,s2,-1936 # 80007008 <etext+0x8>
      for (; *s; s++)
    800007a0:	02800513          	li	a0,40
    800007a4:	b7dd                	j	8000078a <printk+0x280>
    800007a6:	74a6                	ld	s1,104(sp)
    800007a8:	7906                	ld	s2,96(sp)
    800007aa:	69e6                	ld	s3,88(sp)
    800007ac:	6aa6                	ld	s5,72(sp)
    800007ae:	6b06                	ld	s6,64(sp)
    800007b0:	7c42                	ld	s8,48(sp)
    800007b2:	7ca2                	ld	s9,40(sp)
    800007b4:	7d02                	ld	s10,32(sp)
    800007b6:	6de2                	ld	s11,24(sp)
    800007b8:	a811                	j	800007cc <printk+0x2c2>
    800007ba:	74a6                	ld	s1,104(sp)
    800007bc:	7906                	ld	s2,96(sp)
    800007be:	69e6                	ld	s3,88(sp)
    800007c0:	6aa6                	ld	s5,72(sp)
    800007c2:	6b06                	ld	s6,64(sp)
    800007c4:	7c42                	ld	s8,48(sp)
    800007c6:	7ca2                	ld	s9,40(sp)
    800007c8:	7d02                	ld	s10,32(sp)
    800007ca:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007cc:	0000a797          	auipc	a5,0xa
    800007d0:	e187a783          	lw	a5,-488(a5) # 8000a5e4 <panicking>
    800007d4:	c799                	beqz	a5,800007e2 <printk+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007d6:	4501                	li	a0,0
    800007d8:	70e6                	ld	ra,120(sp)
    800007da:	7446                	ld	s0,112(sp)
    800007dc:	6a46                	ld	s4,80(sp)
    800007de:	6129                	addi	sp,sp,192
    800007e0:	8082                	ret
    release(&pr.lock);
    800007e2:	00012517          	auipc	a0,0x12
    800007e6:	ed650513          	addi	a0,a0,-298 # 800126b8 <pr>
    800007ea:	474000ef          	jal	80000c5e <release>
  return 0;
    800007ee:	b7e5                	j	800007d6 <printk+0x2cc>

00000000800007f0 <panic>:

void
panic(char *s)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	e04a                	sd	s2,0(sp)
    800007fa:	1000                	addi	s0,sp,32
    800007fc:	84aa                	mv	s1,a0
  panicking = 1;
    800007fe:	4905                	li	s2,1
    80000800:	0000a797          	auipc	a5,0xa
    80000804:	df27a223          	sw	s2,-540(a5) # 8000a5e4 <panicking>
  printk("panic: ");
    80000808:	00007517          	auipc	a0,0x7
    8000080c:	80850513          	addi	a0,a0,-2040 # 80007010 <etext+0x10>
    80000810:	cfbff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000814:	85a6                	mv	a1,s1
    80000816:	00007517          	auipc	a0,0x7
    8000081a:	80250513          	addi	a0,a0,-2046 # 80007018 <etext+0x18>
    8000081e:	cedff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000822:	0000a797          	auipc	a5,0xa
    80000826:	db27af23          	sw	s2,-578(a5) # 8000a5e0 <panicked>
  for (;;)
    8000082a:	a001                	j	8000082a <panic+0x3a>

000000008000082c <printkinit>:
    ;
}

void
printkinit(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e406                	sd	ra,8(sp)
    80000830:	e022                	sd	s0,0(sp)
    80000832:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000834:	00006597          	auipc	a1,0x6
    80000838:	7ec58593          	addi	a1,a1,2028 # 80007020 <etext+0x20>
    8000083c:	00012517          	auipc	a0,0x12
    80000840:	e7c50513          	addi	a0,a0,-388 # 800126b8 <pr>
    80000844:	318000ef          	jal	80000b5c <initlock>
}
    80000848:	60a2                	ld	ra,8(sp)
    8000084a:	6402                	ld	s0,0(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret

0000000080000850 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000850:	1141                	addi	sp,sp,-16
    80000852:	e406                	sd	ra,8(sp)
    80000854:	e022                	sd	s0,0(sp)
    80000856:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000858:	100007b7          	lui	a5,0x10000
    8000085c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000860:	10000737          	lui	a4,0x10000
    80000864:	f8000693          	li	a3,-128
    80000868:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000086c:	468d                	li	a3,3
    8000086e:	10000637          	lui	a2,0x10000
    80000872:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000876:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000087a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000087e:	10000737          	lui	a4,0x10000
    80000882:	461d                	li	a2,7
    80000884:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000888:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    8000088c:	00006597          	auipc	a1,0x6
    80000890:	79c58593          	addi	a1,a1,1948 # 80007028 <etext+0x28>
    80000894:	00012517          	auipc	a0,0x12
    80000898:	e3c50513          	addi	a0,a0,-452 # 800126d0 <tx_lock>
    8000089c:	23f030ef          	jal	800042da <initsleeplock>
}
    800008a0:	60a2                	ld	ra,8(sp)
    800008a2:	6402                	ld	s0,0(sp)
    800008a4:	0141                	addi	sp,sp,16
    800008a6:	8082                	ret

00000000800008a8 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008a8:	7139                	addi	sp,sp,-64
    800008aa:	fc06                	sd	ra,56(sp)
    800008ac:	f822                	sd	s0,48(sp)
    800008ae:	f04a                	sd	s2,32(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	0080                	addi	s0,sp,64
    800008b4:	8aaa                	mv	s5,a0
    800008b6:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008b8:	00012517          	auipc	a0,0x12
    800008bc:	e1850513          	addi	a0,a0,-488 # 800126d0 <tx_lock>
    800008c0:	251030ef          	jal	80004310 <acquiresleep>

  int i = 0;
  while (i < n) {
    800008c4:	05205963          	blez	s2,80000916 <uartwrite+0x6e>
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	ec4e                	sd	s3,24(sp)
    800008cc:	e852                	sd	s4,16(sp)
    800008ce:	e05a                	sd	s6,0(sp)
  int i = 0;
    800008d0:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    800008d2:	0000aa17          	auipc	s4,0xa
    800008d6:	d16a0a13          	addi	s4,s4,-746 # 8000a5e8 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008da:	100009b7          	lui	s3,0x10000
    800008de:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    800008e0:	10000b37          	lui	s6,0x10000
    800008e4:	a811                	j	800008f8 <uartwrite+0x50>
    800008e6:	009a87b3          	add	a5,s5,s1
    800008ea:	0007c783          	lbu	a5,0(a5)
    800008ee:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    800008f2:	2485                	addiw	s1,s1,1
  while (i < n) {
    800008f4:	0124dd63          	bge	s1,s2,8000090e <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    800008f8:	8552                	mv	a0,s4
    800008fa:	5fa010ef          	jal	80001ef4 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008fe:	0009c783          	lbu	a5,0(s3)
    80000902:	0207f793          	andi	a5,a5,32
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x3e>
    } else {
      sleep();
    80000908:	628010ef          	jal	80001f30 <sleep>
    8000090c:	b7e5                	j	800008f4 <uartwrite+0x4c>
    8000090e:	74a2                	ld	s1,40(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000916:	00012517          	auipc	a0,0x12
    8000091a:	dba50513          	addi	a0,a0,-582 # 800126d0 <tx_lock>
    8000091e:	247030ef          	jal	80004364 <releasesleep>
}
    80000922:	70e2                	ld	ra,56(sp)
    80000924:	7442                	ld	s0,48(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret

000000008000092e <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092e:	1101                	addi	sp,sp,-32
    80000930:	ec06                	sd	ra,24(sp)
    80000932:	e822                	sd	s0,16(sp)
    80000934:	e426                	sd	s1,8(sp)
    80000936:	1000                	addi	s0,sp,32
    80000938:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000093a:	0000a797          	auipc	a5,0xa
    8000093e:	caa7a783          	lw	a5,-854(a5) # 8000a5e4 <panicking>
    80000942:	cf95                	beqz	a5,8000097e <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000944:	0000a797          	auipc	a5,0xa
    80000948:	c9c7a783          	lw	a5,-868(a5) # 8000a5e0 <panicked>
    8000094c:	ef85                	bnez	a5,80000984 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094e:	10000737          	lui	a4,0x10000
    80000952:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000954:	00074783          	lbu	a5,0(a4)
    80000958:	0207f793          	andi	a5,a5,32
    8000095c:	dfe5                	beqz	a5,80000954 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095e:	0ff4f513          	zext.b	a0,s1
    80000962:	100007b7          	lui	a5,0x10000
    80000966:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	c7a7a783          	lw	a5,-902(a5) # 8000a5e4 <panicking>
    80000972:	cb91                	beqz	a5,80000986 <uartputc_sync+0x58>
    pop_off();
}
    80000974:	60e2                	ld	ra,24(sp)
    80000976:	6442                	ld	s0,16(sp)
    80000978:	64a2                	ld	s1,8(sp)
    8000097a:	6105                	addi	sp,sp,32
    8000097c:	8082                	ret
    push_off();
    8000097e:	21e000ef          	jal	80000b9c <push_off>
    80000982:	b7c9                	j	80000944 <uartputc_sync+0x16>
    for (;;)
    80000984:	a001                	j	80000984 <uartputc_sync+0x56>
    pop_off();
    80000986:	28c000ef          	jal	80000c12 <pop_off>
}
    8000098a:	b7ed                	j	80000974 <uartputc_sync+0x46>

000000008000098c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000098c:	1101                	addi	sp,sp,-32
    8000098e:	ec06                	sd	ra,24(sp)
    80000990:	e822                	sd	s0,16(sp)
    80000992:	e426                	sd	s1,8(sp)
    80000994:	e04a                	sd	s2,0(sp)
    80000996:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000099e:	0007c783          	lbu	a5,0(a5)

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009a8:	0007c783          	lbu	a5,0(a5)
    800009ac:	0207f793          	andi	a5,a5,32
    800009b0:	ef99                	bnez	a5,800009ce <uartintr+0x42>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009b2:	100004b7          	lui	s1,0x10000
    800009b6:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009b8:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009bc:	0004c783          	lbu	a5,0(s1)
    800009c0:	8b85                	andi	a5,a5,1
    800009c2:	cf89                	beqz	a5,800009dc <uartintr+0x50>
    return ReadReg(RHR);
    800009c4:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009c8:	8f3ff0ef          	jal	800002ba <consoleintr>
  while (1) {
    800009cc:	bfc5                	j	800009bc <uartintr+0x30>
    wakeup(&tx_chan);
    800009ce:	0000a517          	auipc	a0,0xa
    800009d2:	c1a50513          	addi	a0,a0,-998 # 8000a5e8 <tx_chan>
    800009d6:	58a010ef          	jal	80001f60 <wakeup>
    800009da:	bfe1                	j	800009b2 <uartintr+0x26>
  }
}
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6902                	ld	s2,0(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	e7a9                	bnez	a5,80000a42 <kfree+0x5a>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00023797          	auipc	a5,0x23
    80000a00:	13478793          	addi	a5,a5,308 # 80023b30 <end>
    80000a04:	02f56f63          	bltu	a0,a5,80000a42 <kfree+0x5a>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	02f57b63          	bgeu	a0,a5,80000a42 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	282000ef          	jal	80000c96 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a18:	00012917          	auipc	s2,0x12
    80000a1c:	ce890913          	addi	s2,s2,-792 # 80012700 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	1b0000ef          	jal	80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	22c000ef          	jal	80000c5e <release>
}
    80000a36:	60e2                	ld	ra,24(sp)
    80000a38:	6442                	ld	s0,16(sp)
    80000a3a:	64a2                	ld	s1,8(sp)
    80000a3c:	6902                	ld	s2,0(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret
    panic("kfree");
    80000a42:	00006517          	auipc	a0,0x6
    80000a46:	5ee50513          	addi	a0,a0,1518 # 80007030 <etext+0x30>
    80000a4a:	da7ff0ef          	jal	800007f0 <panic>

0000000080000a4e <freerange>:
{
    80000a4e:	7179                	addi	sp,sp,-48
    80000a50:	f406                	sd	ra,40(sp)
    80000a52:	f022                	sd	s0,32(sp)
    80000a54:	ec26                	sd	s1,24(sp)
    80000a56:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a58:	6785                	lui	a5,0x1
    80000a5a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a5e:	00e504b3          	add	s1,a0,a4
    80000a62:	777d                	lui	a4,0xfffff
    80000a64:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a66:	94be                	add	s1,s1,a5
    80000a68:	0295e263          	bltu	a1,s1,80000a8c <freerange+0x3e>
    80000a6c:	e84a                	sd	s2,16(sp)
    80000a6e:	e44e                	sd	s3,8(sp)
    80000a70:	e052                	sd	s4,0(sp)
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	f6dff0ef          	jal	800009e8 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe997be3          	bgeu	s2,s1,80000a78 <freerange+0x2a>
    80000a86:	6942                	ld	s2,16(sp)
    80000a88:	69a2                	ld	s3,8(sp)
    80000a8a:	6a02                	ld	s4,0(sp)
}
    80000a8c:	70a2                	ld	ra,40(sp)
    80000a8e:	7402                	ld	s0,32(sp)
    80000a90:	64e2                	ld	s1,24(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00006597          	auipc	a1,0x6
    80000aa2:	59a58593          	addi	a1,a1,1434 # 80007038 <etext+0x38>
    80000aa6:	00012517          	auipc	a0,0x12
    80000aaa:	c5a50513          	addi	a0,a0,-934 # 80012700 <kmem>
    80000aae:	0ae000ef          	jal	80000b5c <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00023517          	auipc	a0,0x23
    80000aba:	07a50513          	addi	a0,a0,122 # 80023b30 <end>
    80000abe:	f91ff0ef          	jal	80000a4e <freerange>
}
    80000ac2:	60a2                	ld	ra,8(sp)
    80000ac4:	6402                	ld	s0,0(sp)
    80000ac6:	0141                	addi	sp,sp,16
    80000ac8:	8082                	ret

0000000080000aca <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aca:	1101                	addi	sp,sp,-32
    80000acc:	ec06                	sd	ra,24(sp)
    80000ace:	e822                	sd	s0,16(sp)
    80000ad0:	e426                	sd	s1,8(sp)
    80000ad2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ad4:	00012497          	auipc	s1,0x12
    80000ad8:	c2c48493          	addi	s1,s1,-980 # 80012700 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	0f4000ef          	jal	80000bd2 <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if (r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	00012517          	auipc	a0,0x12
    80000aec:	c1850513          	addi	a0,a0,-1000 # 80012700 <kmem>
    80000af0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000af2:	16c000ef          	jal	80000c5e <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	8526                	mv	a0,s1
    80000afc:	19a000ef          	jal	80000c96 <memset>
  return (void *)r;
}
    80000b00:	8526                	mv	a0,s1
    80000b02:	60e2                	ld	ra,24(sp)
    80000b04:	6442                	ld	s0,16(sp)
    80000b06:	64a2                	ld	s1,8(sp)
    80000b08:	6105                	addi	sp,sp,32
    80000b0a:	8082                	ret
  release(&kmem.lock);
    80000b0c:	00012517          	auipc	a0,0x12
    80000b10:	bf450513          	addi	a0,a0,-1036 # 80012700 <kmem>
    80000b14:	14a000ef          	jal	80000c5e <release>
  if (r)
    80000b18:	b7e5                	j	80000b00 <kalloc+0x36>

0000000080000b1a <count_free_mem>:

uint64
count_free_mem(void)
{
    80000b1a:	1101                	addi	sp,sp,-32
    80000b1c:	ec06                	sd	ra,24(sp)
    80000b1e:	e822                	sd	s0,16(sp)
    80000b20:	e426                	sd	s1,8(sp)
    80000b22:	1000                	addi	s0,sp,32
  struct run *r;
  uint64 free_pages = 0;

  acquire(&kmem.lock);
    80000b24:	00012497          	auipc	s1,0x12
    80000b28:	bdc48493          	addi	s1,s1,-1060 # 80012700 <kmem>
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	0a4000ef          	jal	80000bd2 <acquire>
  r = kmem.freelist;
    80000b32:	6c9c                	ld	a5,24(s1)
  while(r){
    80000b34:	c395                	beqz	a5,80000b58 <count_free_mem+0x3e>
  uint64 free_pages = 0;
    80000b36:	4481                	li	s1,0
    free_pages++;
    80000b38:	0485                	addi	s1,s1,1
    r = r->next;
    80000b3a:	639c                	ld	a5,0(a5)
  while(r){
    80000b3c:	fff5                	bnez	a5,80000b38 <count_free_mem+0x1e>
  }
  release(&kmem.lock);
    80000b3e:	00012517          	auipc	a0,0x12
    80000b42:	bc250513          	addi	a0,a0,-1086 # 80012700 <kmem>
    80000b46:	118000ef          	jal	80000c5e <release>

  // Each page is 4096 bytes
  return free_pages * 4096; 
}
    80000b4a:	00c49513          	slli	a0,s1,0xc
    80000b4e:	60e2                	ld	ra,24(sp)
    80000b50:	6442                	ld	s0,16(sp)
    80000b52:	64a2                	ld	s1,8(sp)
    80000b54:	6105                	addi	sp,sp,32
    80000b56:	8082                	ret
  uint64 free_pages = 0;
    80000b58:	4481                	li	s1,0
    80000b5a:	b7d5                	j	80000b3e <count_free_mem+0x24>

0000000080000b5c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b5c:	1141                	addi	sp,sp,-16
    80000b5e:	e422                	sd	s0,8(sp)
    80000b60:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b62:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b64:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b68:	00053823          	sd	zero,16(a0)
}
    80000b6c:	6422                	ld	s0,8(sp)
    80000b6e:	0141                	addi	sp,sp,16
    80000b70:	8082                	ret

0000000080000b72 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b72:	411c                	lw	a5,0(a0)
    80000b74:	e399                	bnez	a5,80000b7a <holding+0x8>
    80000b76:	4501                	li	a0,0
  return r;
}
    80000b78:	8082                	ret
{
    80000b7a:	1101                	addi	sp,sp,-32
    80000b7c:	ec06                	sd	ra,24(sp)
    80000b7e:	e822                	sd	s0,16(sp)
    80000b80:	e426                	sd	s1,8(sp)
    80000b82:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b84:	6904                	ld	s1,16(a0)
    80000b86:	543000ef          	jal	800018c8 <mycpu>
    80000b8a:	40a48533          	sub	a0,s1,a0
    80000b8e:	00153513          	seqz	a0,a0
}
    80000b92:	60e2                	ld	ra,24(sp)
    80000b94:	6442                	ld	s0,16(sp)
    80000b96:	64a2                	ld	s1,8(sp)
    80000b98:	6105                	addi	sp,sp,32
    80000b9a:	8082                	ret

0000000080000b9c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000ba6:	100174f3          	csrrci	s1,sstatus,2
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000baa:	51f000ef          	jal	800018c8 <mycpu>
    80000bae:	5d3c                	lw	a5,120(a0)
    80000bb0:	cb99                	beqz	a5,80000bc6 <push_off+0x2a>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bb2:	517000ef          	jal	800018c8 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	503000ef          	jal	800018c8 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    mycpu()->intena = old;
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	b7cd                	j	80000bb2 <push_off+0x16>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	fbfff0ef          	jal	80000b9c <push_off>
  if (holding(lk))
    80000be2:	8526                	mv	a0,s1
    80000be4:	f8fff0ef          	jal	80000b72 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000be8:	4705                	li	a4,1
  if (holding(lk))
    80000bea:	ed11                	bnez	a0,80000c06 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000bec:	87ba                	mv	a5,a4
    80000bee:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf2:	2781                	sext.w	a5,a5
    80000bf4:	ffe5                	bnez	a5,80000bec <acquire+0x1a>
  lk->cpu = mycpu();
    80000bf6:	4d3000ef          	jal	800018c8 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	43a50513          	addi	a0,a0,1082 # 80007040 <etext+0x40>
    80000c0e:	be3ff0ef          	jal	800007f0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	4af000ef          	jal	800018c8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c24:	e38d                	bnez	a5,80000c46 <pop_off+0x34>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05563          	blez	a5,80000c52 <pop_off+0x40>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c34:	e709                	bnez	a4,80000c3e <pop_off+0x2c>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c399                	beqz	a5,80000c3e <pop_off+0x2c>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000c3a:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000c3e:	60a2                	ld	ra,8(sp)
    80000c40:	6402                	ld	s0,0(sp)
    80000c42:	0141                	addi	sp,sp,16
    80000c44:	8082                	ret
    panic("pop_off - interruptible");
    80000c46:	00006517          	auipc	a0,0x6
    80000c4a:	40250513          	addi	a0,a0,1026 # 80007048 <etext+0x48>
    80000c4e:	ba3ff0ef          	jal	800007f0 <panic>
    panic("pop_off");
    80000c52:	00006517          	auipc	a0,0x6
    80000c56:	40e50513          	addi	a0,a0,1038 # 80007060 <etext+0x60>
    80000c5a:	b97ff0ef          	jal	800007f0 <panic>

0000000080000c5e <release>:
{
    80000c5e:	1101                	addi	sp,sp,-32
    80000c60:	ec06                	sd	ra,24(sp)
    80000c62:	e822                	sd	s0,16(sp)
    80000c64:	e426                	sd	s1,8(sp)
    80000c66:	1000                	addi	s0,sp,32
    80000c68:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c6a:	f09ff0ef          	jal	80000b72 <holding>
    80000c6e:	cd11                	beqz	a0,80000c8a <release+0x2c>
  lk->cpu = 0;
    80000c70:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c74:	0310000f          	fence	rw,w
    80000c78:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c7c:	f97ff0ef          	jal	80000c12 <pop_off>
}
    80000c80:	60e2                	ld	ra,24(sp)
    80000c82:	6442                	ld	s0,16(sp)
    80000c84:	64a2                	ld	s1,8(sp)
    80000c86:	6105                	addi	sp,sp,32
    80000c88:	8082                	ret
    panic("release");
    80000c8a:	00006517          	auipc	a0,0x6
    80000c8e:	3de50513          	addi	a0,a0,990 # 80007068 <etext+0x68>
    80000c92:	b5fff0ef          	jal	800007f0 <panic>

0000000080000c96 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000c96:	1141                	addi	sp,sp,-16
    80000c98:	e422                	sd	s0,8(sp)
    80000c9a:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000c9c:	ca19                	beqz	a2,80000cb2 <memset+0x1c>
    80000c9e:	87aa                	mv	a5,a0
    80000ca0:	1602                	slli	a2,a2,0x20
    80000ca2:	9201                	srli	a2,a2,0x20
    80000ca4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ca8:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000cac:	0785                	addi	a5,a5,1
    80000cae:	fee79de3          	bne	a5,a4,80000ca8 <memset+0x12>
  }
  return dst;
}
    80000cb2:	6422                	ld	s0,8(sp)
    80000cb4:	0141                	addi	sp,sp,16
    80000cb6:	8082                	ret

0000000080000cb8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cb8:	1141                	addi	sp,sp,-16
    80000cba:	e422                	sd	s0,8(sp)
    80000cbc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000cbe:	ca05                	beqz	a2,80000cee <memcmp+0x36>
    80000cc0:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cc4:	1682                	slli	a3,a3,0x20
    80000cc6:	9281                	srli	a3,a3,0x20
    80000cc8:	0685                	addi	a3,a3,1
    80000cca:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000ccc:	00054783          	lbu	a5,0(a0)
    80000cd0:	0005c703          	lbu	a4,0(a1)
    80000cd4:	00e79863          	bne	a5,a4,80000ce4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000cd8:	0505                	addi	a0,a0,1
    80000cda:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000cdc:	fed518e3          	bne	a0,a3,80000ccc <memcmp+0x14>
  }

  return 0;
    80000ce0:	4501                	li	a0,0
    80000ce2:	a019                	j	80000ce8 <memcmp+0x30>
      return *s1 - *s2;
    80000ce4:	40e7853b          	subw	a0,a5,a4
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret
  return 0;
    80000cee:	4501                	li	a0,0
    80000cf0:	bfe5                	j	80000ce8 <memcmp+0x30>

0000000080000cf2 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000cf2:	1141                	addi	sp,sp,-16
    80000cf4:	e422                	sd	s0,8(sp)
    80000cf6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000cf8:	c205                	beqz	a2,80000d18 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000cfa:	02a5e263          	bltu	a1,a0,80000d1e <memmove+0x2c>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000cfe:	1602                	slli	a2,a2,0x20
    80000d00:	9201                	srli	a2,a2,0x20
    80000d02:	00c587b3          	add	a5,a1,a2
{
    80000d06:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d08:	0585                	addi	a1,a1,1
    80000d0a:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb4d1>
    80000d0c:	fff5c683          	lbu	a3,-1(a1)
    80000d10:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d14:	feb79ae3          	bne	a5,a1,80000d08 <memmove+0x16>

  return dst;
}
    80000d18:	6422                	ld	s0,8(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret
  if (s < d && s + n > d) {
    80000d1e:	02061693          	slli	a3,a2,0x20
    80000d22:	9281                	srli	a3,a3,0x20
    80000d24:	00d58733          	add	a4,a1,a3
    80000d28:	fce57be3          	bgeu	a0,a4,80000cfe <memmove+0xc>
    d += n;
    80000d2c:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d2e:	fff6079b          	addiw	a5,a2,-1
    80000d32:	1782                	slli	a5,a5,0x20
    80000d34:	9381                	srli	a5,a5,0x20
    80000d36:	fff7c793          	not	a5,a5
    80000d3a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d3c:	177d                	addi	a4,a4,-1
    80000d3e:	16fd                	addi	a3,a3,-1
    80000d40:	00074603          	lbu	a2,0(a4)
    80000d44:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d48:	fef71ae3          	bne	a4,a5,80000d3c <memmove+0x4a>
    80000d4c:	b7f1                	j	80000d18 <memmove+0x26>

0000000080000d4e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d4e:	1141                	addi	sp,sp,-16
    80000d50:	e406                	sd	ra,8(sp)
    80000d52:	e022                	sd	s0,0(sp)
    80000d54:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d56:	f9dff0ef          	jal	80000cf2 <memmove>
}
    80000d5a:	60a2                	ld	ra,8(sp)
    80000d5c:	6402                	ld	s0,0(sp)
    80000d5e:	0141                	addi	sp,sp,16
    80000d60:	8082                	ret

0000000080000d62 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d62:	1141                	addi	sp,sp,-16
    80000d64:	e422                	sd	s0,8(sp)
    80000d66:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d68:	ce11                	beqz	a2,80000d84 <strncmp+0x22>
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	cf89                	beqz	a5,80000d88 <strncmp+0x26>
    80000d70:	0005c703          	lbu	a4,0(a1)
    80000d74:	00f71a63          	bne	a4,a5,80000d88 <strncmp+0x26>
    n--, p++, q++;
    80000d78:	367d                	addiw	a2,a2,-1
    80000d7a:	0505                	addi	a0,a0,1
    80000d7c:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d7e:	f675                	bnez	a2,80000d6a <strncmp+0x8>
  if (n == 0)
    return 0;
    80000d80:	4501                	li	a0,0
    80000d82:	a801                	j	80000d92 <strncmp+0x30>
    80000d84:	4501                	li	a0,0
    80000d86:	a031                	j	80000d92 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d88:	00054503          	lbu	a0,0(a0)
    80000d8c:	0005c783          	lbu	a5,0(a1)
    80000d90:	9d1d                	subw	a0,a0,a5
}
    80000d92:	6422                	ld	s0,8(sp)
    80000d94:	0141                	addi	sp,sp,16
    80000d96:	8082                	ret

0000000080000d98 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000d98:	1141                	addi	sp,sp,-16
    80000d9a:	e422                	sd	s0,8(sp)
    80000d9c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000d9e:	87aa                	mv	a5,a0
    80000da0:	86b2                	mv	a3,a2
    80000da2:	367d                	addiw	a2,a2,-1
    80000da4:	02d05563          	blez	a3,80000dce <strncpy+0x36>
    80000da8:	0785                	addi	a5,a5,1
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	fee78fa3          	sb	a4,-1(a5)
    80000db2:	0585                	addi	a1,a1,1
    80000db4:	f775                	bnez	a4,80000da0 <strncpy+0x8>
    ;
  while (n-- > 0)
    80000db6:	873e                	mv	a4,a5
    80000db8:	9fb5                	addw	a5,a5,a3
    80000dba:	37fd                	addiw	a5,a5,-1
    80000dbc:	00c05963          	blez	a2,80000dce <strncpy+0x36>
    *s++ = 0;
    80000dc0:	0705                	addi	a4,a4,1
    80000dc2:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000dc6:	40e786bb          	subw	a3,a5,a4
    80000dca:	fed04be3          	bgtz	a3,80000dc0 <strncpy+0x28>
  return os;
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret

0000000080000dd4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000dd4:	1141                	addi	sp,sp,-16
    80000dd6:	e422                	sd	s0,8(sp)
    80000dd8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000dda:	02c05363          	blez	a2,80000e00 <safestrcpy+0x2c>
    80000dde:	fff6069b          	addiw	a3,a2,-1
    80000de2:	1682                	slli	a3,a3,0x20
    80000de4:	9281                	srli	a3,a3,0x20
    80000de6:	96ae                	add	a3,a3,a1
    80000de8:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000dea:	00d58963          	beq	a1,a3,80000dfc <safestrcpy+0x28>
    80000dee:	0585                	addi	a1,a1,1
    80000df0:	0785                	addi	a5,a5,1
    80000df2:	fff5c703          	lbu	a4,-1(a1)
    80000df6:	fee78fa3          	sb	a4,-1(a5)
    80000dfa:	fb65                	bnez	a4,80000dea <safestrcpy+0x16>
    ;
  *s = 0;
    80000dfc:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strlen>:

int
strlen(const char *s)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf91                	beqz	a5,80000e2c <strlen+0x26>
    80000e12:	0505                	addi	a0,a0,1
    80000e14:	87aa                	mv	a5,a0
    80000e16:	86be                	mv	a3,a5
    80000e18:	0785                	addi	a5,a5,1
    80000e1a:	fff7c703          	lbu	a4,-1(a5)
    80000e1e:	ff65                	bnez	a4,80000e16 <strlen+0x10>
    80000e20:	40a6853b          	subw	a0,a3,a0
    80000e24:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e26:	6422                	ld	s0,8(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e2c:	4501                	li	a0,0
    80000e2e:	bfe5                	j	80000e26 <strlen+0x20>

0000000080000e30 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e30:	1141                	addi	sp,sp,-16
    80000e32:	e406                	sd	ra,8(sp)
    80000e34:	e022                	sd	s0,0(sp)
    80000e36:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e38:	281000ef          	jal	800018b8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e3c:	00009717          	auipc	a4,0x9
    80000e40:	7b070713          	addi	a4,a4,1968 # 8000a5ec <started>
  if (cpuid() == 0) {
    80000e44:	c51d                	beqz	a0,80000e72 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e46:	431c                	lw	a5,0(a4)
    80000e48:	0230000f          	fence	r,rw
    80000e4c:	2781                	sext.w	a5,a5
    80000e4e:	dfe5                	beqz	a5,80000e46 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e50:	269000ef          	jal	800018b8 <cpuid>
    80000e54:	85aa                	mv	a1,a0
    80000e56:	00006517          	auipc	a0,0x6
    80000e5a:	23250513          	addi	a0,a0,562 # 80007088 <etext+0x88>
    80000e5e:	eacff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e62:	082000ef          	jal	80000ee4 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e66:	732010ef          	jal	80002598 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e6a:	34f040ef          	jal	800059b8 <plicinithart>
  }

  scheduler();
    80000e6e:	6ed000ef          	jal	80001d5a <scheduler>
    consoleinit();
    80000e72:	dc2ff0ef          	jal	80000434 <consoleinit>
    printkinit();
    80000e76:	9b7ff0ef          	jal	8000082c <printkinit>
    printk("\n");
    80000e7a:	00006517          	auipc	a0,0x6
    80000e7e:	21e50513          	addi	a0,a0,542 # 80007098 <etext+0x98>
    80000e82:	e88ff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1ea50513          	addi	a0,a0,490 # 80007070 <etext+0x70>
    80000e8e:	e7cff0ef          	jal	8000050a <printk>
    printk("\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	20650513          	addi	a0,a0,518 # 80007098 <etext+0x98>
    80000e9a:	e70ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000e9e:	bf9ff0ef          	jal	80000a96 <kinit>
    kvminit();          // create kernel page table
    80000ea2:	2cc000ef          	jal	8000116e <kvminit>
    kvminithart();      // turn on paging
    80000ea6:	03e000ef          	jal	80000ee4 <kvminithart>
    procinit();         // process table
    80000eaa:	159000ef          	jal	80001802 <procinit>
    trapinit();         // trap vectors
    80000eae:	6c6010ef          	jal	80002574 <trapinit>
    trapinithart();     // install kernel trap vector
    80000eb2:	6e6010ef          	jal	80002598 <trapinithart>
    plicinit();         // set up interrupt controller
    80000eb6:	2e9040ef          	jal	8000599e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000eba:	2ff040ef          	jal	800059b8 <plicinithart>
    binit();            // buffer cache
    80000ebe:	7ab010ef          	jal	80002e68 <binit>
    iinit();            // inode table
    80000ec2:	530020ef          	jal	800033f2 <iinit>
    fileinit();         // file table
    80000ec6:	520030ef          	jal	800043e6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000eca:	3df040ef          	jal	80005aa8 <virtio_disk_init>
    userinit();         // first user process
    80000ece:	4d9000ef          	jal	80001ba6 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000ed2:	00009797          	auipc	a5,0x9
    80000ed6:	71a78793          	addi	a5,a5,1818 # 8000a5ec <started>
    80000eda:	4705                	li	a4,1
    80000edc:	0310000f          	fence	rw,w
    80000ee0:	c398                	sw	a4,0(a5)
    80000ee2:	b771                	j	80000e6e <main+0x3e>

0000000080000ee4 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ee4:	1141                	addi	sp,sp,-16
    80000ee6:	e422                	sd	s0,8(sp)
    80000ee8:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000eea:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000eee:	00009797          	auipc	a5,0x9
    80000ef2:	7027b783          	ld	a5,1794(a5) # 8000a5f0 <kernel_pagetable>
    80000ef6:	83b1                	srli	a5,a5,0xc
    80000ef8:	577d                	li	a4,-1
    80000efa:	177e                	slli	a4,a4,0x3f
    80000efc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000efe:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f02:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f06:	6422                	ld	s0,8(sp)
    80000f08:	0141                	addi	sp,sp,16
    80000f0a:	8082                	ret

0000000080000f0c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f0c:	7139                	addi	sp,sp,-64
    80000f0e:	fc06                	sd	ra,56(sp)
    80000f10:	f822                	sd	s0,48(sp)
    80000f12:	f426                	sd	s1,40(sp)
    80000f14:	f04a                	sd	s2,32(sp)
    80000f16:	ec4e                	sd	s3,24(sp)
    80000f18:	e852                	sd	s4,16(sp)
    80000f1a:	e456                	sd	s5,8(sp)
    80000f1c:	e05a                	sd	s6,0(sp)
    80000f1e:	0080                	addi	s0,sp,64
    80000f20:	84aa                	mv	s1,a0
    80000f22:	89ae                	mv	s3,a1
    80000f24:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000f26:	57fd                	li	a5,-1
    80000f28:	83e9                	srli	a5,a5,0x1a
    80000f2a:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f2c:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000f2e:	02b7fc63          	bgeu	a5,a1,80000f66 <walk+0x5a>
    panic("walk");
    80000f32:	00006517          	auipc	a0,0x6
    80000f36:	16e50513          	addi	a0,a0,366 # 800070a0 <etext+0xa0>
    80000f3a:	8b7ff0ef          	jal	800007f0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if (*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000f3e:	060a8263          	beqz	s5,80000fa2 <walk+0x96>
    80000f42:	b89ff0ef          	jal	80000aca <kalloc>
    80000f46:	84aa                	mv	s1,a0
    80000f48:	c139                	beqz	a0,80000f8e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f4a:	6605                	lui	a2,0x1
    80000f4c:	4581                	li	a1,0
    80000f4e:	d49ff0ef          	jal	80000c96 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f52:	00c4d793          	srli	a5,s1,0xc
    80000f56:	07aa                	slli	a5,a5,0xa
    80000f58:	0017e793          	ori	a5,a5,1
    80000f5c:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000f60:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb4c7>
    80000f62:	036a0063          	beq	s4,s6,80000f82 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f66:	0149d933          	srl	s2,s3,s4
    80000f6a:	1ff97913          	andi	s2,s2,511
    80000f6e:	090e                	slli	s2,s2,0x3
    80000f70:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f72:	00093483          	ld	s1,0(s2)
    80000f76:	0014f793          	andi	a5,s1,1
    80000f7a:	d3f1                	beqz	a5,80000f3e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f7c:	80a9                	srli	s1,s1,0xa
    80000f7e:	04b2                	slli	s1,s1,0xc
    80000f80:	b7c5                	j	80000f60 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f82:	00c9d513          	srli	a0,s3,0xc
    80000f86:	1ff57513          	andi	a0,a0,511
    80000f8a:	050e                	slli	a0,a0,0x3
    80000f8c:	9526                	add	a0,a0,s1
}
    80000f8e:	70e2                	ld	ra,56(sp)
    80000f90:	7442                	ld	s0,48(sp)
    80000f92:	74a2                	ld	s1,40(sp)
    80000f94:	7902                	ld	s2,32(sp)
    80000f96:	69e2                	ld	s3,24(sp)
    80000f98:	6a42                	ld	s4,16(sp)
    80000f9a:	6aa2                	ld	s5,8(sp)
    80000f9c:	6b02                	ld	s6,0(sp)
    80000f9e:	6121                	addi	sp,sp,64
    80000fa0:	8082                	ret
        return 0;
    80000fa2:	4501                	li	a0,0
    80000fa4:	b7ed                	j	80000f8e <walk+0x82>

0000000080000fa6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	00b7f463          	bgeu	a5,a1,80000fb2 <walkaddr+0xc>
    return 0;
    80000fae:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fb0:	8082                	ret
{
    80000fb2:	1141                	addi	sp,sp,-16
    80000fb4:	e406                	sd	ra,8(sp)
    80000fb6:	e022                	sd	s0,0(sp)
    80000fb8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fba:	4601                	li	a2,0
    80000fbc:	f51ff0ef          	jal	80000f0c <walk>
  if (pte == 0)
    80000fc0:	c105                	beqz	a0,80000fe0 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    80000fc2:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000fc4:	0117f693          	andi	a3,a5,17
    80000fc8:	4745                	li	a4,17
    return 0;
    80000fca:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000fcc:	00e68663          	beq	a3,a4,80000fd8 <walkaddr+0x32>
}
    80000fd0:	60a2                	ld	ra,8(sp)
    80000fd2:	6402                	ld	s0,0(sp)
    80000fd4:	0141                	addi	sp,sp,16
    80000fd6:	8082                	ret
  pa = PTE2PA(*pte);
    80000fd8:	83a9                	srli	a5,a5,0xa
    80000fda:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fde:	bfcd                	j	80000fd0 <walkaddr+0x2a>
    return 0;
    80000fe0:	4501                	li	a0,0
    80000fe2:	b7fd                	j	80000fd0 <walkaddr+0x2a>

0000000080000fe4 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fe4:	715d                	addi	sp,sp,-80
    80000fe6:	e486                	sd	ra,72(sp)
    80000fe8:	e0a2                	sd	s0,64(sp)
    80000fea:	fc26                	sd	s1,56(sp)
    80000fec:	f84a                	sd	s2,48(sp)
    80000fee:	f44e                	sd	s3,40(sp)
    80000ff0:	f052                	sd	s4,32(sp)
    80000ff2:	ec56                	sd	s5,24(sp)
    80000ff4:	e85a                	sd	s6,16(sp)
    80000ff6:	e45e                	sd	s7,8(sp)
    80000ff8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000ffa:	03459793          	slli	a5,a1,0x34
    80000ffe:	e7a9                	bnez	a5,80001048 <mappages+0x64>
    80001000:	8aaa                	mv	s5,a0
    80001002:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001004:	03461793          	slli	a5,a2,0x34
    80001008:	e7b1                	bnez	a5,80001054 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    8000100a:	ca39                	beqz	a2,80001060 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000100c:	77fd                	lui	a5,0xfffff
    8000100e:	963e                	add	a2,a2,a5
    80001010:	00b609b3          	add	s3,a2,a1
  a = va;
    80001014:	892e                	mv	s2,a1
    80001016:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    8000101a:	6b85                	lui	s7,0x1
    8000101c:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001020:	4605                	li	a2,1
    80001022:	85ca                	mv	a1,s2
    80001024:	8556                	mv	a0,s5
    80001026:	ee7ff0ef          	jal	80000f0c <walk>
    8000102a:	c539                	beqz	a0,80001078 <mappages+0x94>
    if (*pte & PTE_V)
    8000102c:	611c                	ld	a5,0(a0)
    8000102e:	8b85                	andi	a5,a5,1
    80001030:	ef95                	bnez	a5,8000106c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001032:	80b1                	srli	s1,s1,0xc
    80001034:	04aa                	slli	s1,s1,0xa
    80001036:	0164e4b3          	or	s1,s1,s6
    8000103a:	0014e493          	ori	s1,s1,1
    8000103e:	e104                	sd	s1,0(a0)
    if (a == last)
    80001040:	05390863          	beq	s2,s3,80001090 <mappages+0xac>
    a += PGSIZE;
    80001044:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001046:	bfd9                	j	8000101c <mappages+0x38>
    panic("mappages: va not aligned");
    80001048:	00006517          	auipc	a0,0x6
    8000104c:	06050513          	addi	a0,a0,96 # 800070a8 <etext+0xa8>
    80001050:	fa0ff0ef          	jal	800007f0 <panic>
    panic("mappages: size not aligned");
    80001054:	00006517          	auipc	a0,0x6
    80001058:	07450513          	addi	a0,a0,116 # 800070c8 <etext+0xc8>
    8000105c:	f94ff0ef          	jal	800007f0 <panic>
    panic("mappages: size");
    80001060:	00006517          	auipc	a0,0x6
    80001064:	08850513          	addi	a0,a0,136 # 800070e8 <etext+0xe8>
    80001068:	f88ff0ef          	jal	800007f0 <panic>
      panic("mappages: remap");
    8000106c:	00006517          	auipc	a0,0x6
    80001070:	08c50513          	addi	a0,a0,140 # 800070f8 <etext+0xf8>
    80001074:	f7cff0ef          	jal	800007f0 <panic>
      return -1;
    80001078:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000107a:	60a6                	ld	ra,72(sp)
    8000107c:	6406                	ld	s0,64(sp)
    8000107e:	74e2                	ld	s1,56(sp)
    80001080:	7942                	ld	s2,48(sp)
    80001082:	79a2                	ld	s3,40(sp)
    80001084:	7a02                	ld	s4,32(sp)
    80001086:	6ae2                	ld	s5,24(sp)
    80001088:	6b42                	ld	s6,16(sp)
    8000108a:	6ba2                	ld	s7,8(sp)
    8000108c:	6161                	addi	sp,sp,80
    8000108e:	8082                	ret
  return 0;
    80001090:	4501                	li	a0,0
    80001092:	b7e5                	j	8000107a <mappages+0x96>

0000000080001094 <kvmmap>:
{
    80001094:	1141                	addi	sp,sp,-16
    80001096:	e406                	sd	ra,8(sp)
    80001098:	e022                	sd	s0,0(sp)
    8000109a:	0800                	addi	s0,sp,16
    8000109c:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000109e:	86b2                	mv	a3,a2
    800010a0:	863e                	mv	a2,a5
    800010a2:	f43ff0ef          	jal	80000fe4 <mappages>
    800010a6:	e509                	bnez	a0,800010b0 <kvmmap+0x1c>
}
    800010a8:	60a2                	ld	ra,8(sp)
    800010aa:	6402                	ld	s0,0(sp)
    800010ac:	0141                	addi	sp,sp,16
    800010ae:	8082                	ret
    panic("kvmmap");
    800010b0:	00006517          	auipc	a0,0x6
    800010b4:	05850513          	addi	a0,a0,88 # 80007108 <etext+0x108>
    800010b8:	f38ff0ef          	jal	800007f0 <panic>

00000000800010bc <kvmmake>:
{
    800010bc:	1101                	addi	sp,sp,-32
    800010be:	ec06                	sd	ra,24(sp)
    800010c0:	e822                	sd	s0,16(sp)
    800010c2:	e426                	sd	s1,8(sp)
    800010c4:	e04a                	sd	s2,0(sp)
    800010c6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800010c8:	a03ff0ef          	jal	80000aca <kalloc>
    800010cc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010ce:	6605                	lui	a2,0x1
    800010d0:	4581                	li	a1,0
    800010d2:	bc5ff0ef          	jal	80000c96 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010d6:	4719                	li	a4,6
    800010d8:	6685                	lui	a3,0x1
    800010da:	10000637          	lui	a2,0x10000
    800010de:	100005b7          	lui	a1,0x10000
    800010e2:	8526                	mv	a0,s1
    800010e4:	fb1ff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010e8:	4719                	li	a4,6
    800010ea:	6685                	lui	a3,0x1
    800010ec:	10001637          	lui	a2,0x10001
    800010f0:	100015b7          	lui	a1,0x10001
    800010f4:	8526                	mv	a0,s1
    800010f6:	f9fff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010fa:	4719                	li	a4,6
    800010fc:	040006b7          	lui	a3,0x4000
    80001100:	0c000637          	lui	a2,0xc000
    80001104:	0c0005b7          	lui	a1,0xc000
    80001108:	8526                	mv	a0,s1
    8000110a:	f8bff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000110e:	00006917          	auipc	s2,0x6
    80001112:	ef290913          	addi	s2,s2,-270 # 80007000 <etext>
    80001116:	4729                	li	a4,10
    80001118:	80006697          	auipc	a3,0x80006
    8000111c:	ee868693          	addi	a3,a3,-280 # 7000 <_entry-0x7fff9000>
    80001120:	4605                	li	a2,1
    80001122:	067e                	slli	a2,a2,0x1f
    80001124:	85b2                	mv	a1,a2
    80001126:	8526                	mv	a0,s1
    80001128:	f6dff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    8000112c:	46c5                	li	a3,17
    8000112e:	06ee                	slli	a3,a3,0x1b
    80001130:	4719                	li	a4,6
    80001132:	412686b3          	sub	a3,a3,s2
    80001136:	864a                	mv	a2,s2
    80001138:	85ca                	mv	a1,s2
    8000113a:	8526                	mv	a0,s1
    8000113c:	f59ff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001140:	4729                	li	a4,10
    80001142:	6685                	lui	a3,0x1
    80001144:	00005617          	auipc	a2,0x5
    80001148:	ebc60613          	addi	a2,a2,-324 # 80006000 <_trampoline>
    8000114c:	040005b7          	lui	a1,0x4000
    80001150:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001152:	05b2                	slli	a1,a1,0xc
    80001154:	8526                	mv	a0,s1
    80001156:	f3fff0ef          	jal	80001094 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000115a:	8526                	mv	a0,s1
    8000115c:	60e000ef          	jal	8000176a <proc_mapstacks>
}
    80001160:	8526                	mv	a0,s1
    80001162:	60e2                	ld	ra,24(sp)
    80001164:	6442                	ld	s0,16(sp)
    80001166:	64a2                	ld	s1,8(sp)
    80001168:	6902                	ld	s2,0(sp)
    8000116a:	6105                	addi	sp,sp,32
    8000116c:	8082                	ret

000000008000116e <kvminit>:
{
    8000116e:	1141                	addi	sp,sp,-16
    80001170:	e406                	sd	ra,8(sp)
    80001172:	e022                	sd	s0,0(sp)
    80001174:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001176:	f47ff0ef          	jal	800010bc <kvmmake>
    8000117a:	00009797          	auipc	a5,0x9
    8000117e:	46a7bb23          	sd	a0,1142(a5) # 8000a5f0 <kernel_pagetable>
}
    80001182:	60a2                	ld	ra,8(sp)
    80001184:	6402                	ld	s0,0(sp)
    80001186:	0141                	addi	sp,sp,16
    80001188:	8082                	ret

000000008000118a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001194:	937ff0ef          	jal	80000aca <kalloc>
    80001198:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000119a:	c509                	beqz	a0,800011a4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000119c:	6605                	lui	a2,0x1
    8000119e:	4581                	li	a1,0
    800011a0:	af7ff0ef          	jal	80000c96 <memset>
  return pagetable;
}
    800011a4:	8526                	mv	a0,s1
    800011a6:	60e2                	ld	ra,24(sp)
    800011a8:	6442                	ld	s0,16(sp)
    800011aa:	64a2                	ld	s1,8(sp)
    800011ac:	6105                	addi	sp,sp,32
    800011ae:	8082                	ret

00000000800011b0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011b0:	7139                	addi	sp,sp,-64
    800011b2:	fc06                	sd	ra,56(sp)
    800011b4:	f822                	sd	s0,48(sp)
    800011b6:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800011b8:	03459793          	slli	a5,a1,0x34
    800011bc:	e38d                	bnez	a5,800011de <uvmunmap+0x2e>
    800011be:	f04a                	sd	s2,32(sp)
    800011c0:	ec4e                	sd	s3,24(sp)
    800011c2:	e852                	sd	s4,16(sp)
    800011c4:	e456                	sd	s5,8(sp)
    800011c6:	e05a                	sd	s6,0(sp)
    800011c8:	8a2a                	mv	s4,a0
    800011ca:	892e                	mv	s2,a1
    800011cc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011ce:	0632                	slli	a2,a2,0xc
    800011d0:	00b609b3          	add	s3,a2,a1
    800011d4:	6b05                	lui	s6,0x1
    800011d6:	0535f963          	bgeu	a1,s3,80001228 <uvmunmap+0x78>
    800011da:	f426                	sd	s1,40(sp)
    800011dc:	a015                	j	80001200 <uvmunmap+0x50>
    800011de:	f426                	sd	s1,40(sp)
    800011e0:	f04a                	sd	s2,32(sp)
    800011e2:	ec4e                	sd	s3,24(sp)
    800011e4:	e852                	sd	s4,16(sp)
    800011e6:	e456                	sd	s5,8(sp)
    800011e8:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011ea:	00006517          	auipc	a0,0x6
    800011ee:	f2650513          	addi	a0,a0,-218 # 80007110 <etext+0x110>
    800011f2:	dfeff0ef          	jal	800007f0 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    800011f6:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011fa:	995a                	add	s2,s2,s6
    800011fc:	03397563          	bgeu	s2,s3,80001226 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001200:	4601                	li	a2,0
    80001202:	85ca                	mv	a1,s2
    80001204:	8552                	mv	a0,s4
    80001206:	d07ff0ef          	jal	80000f0c <walk>
    8000120a:	84aa                	mv	s1,a0
    8000120c:	d57d                	beqz	a0,800011fa <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    8000120e:	611c                	ld	a5,0(a0)
    80001210:	0017f713          	andi	a4,a5,1
    80001214:	d37d                	beqz	a4,800011fa <uvmunmap+0x4a>
    if (do_free) {
    80001216:	fe0a80e3          	beqz	s5,800011f6 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000121a:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000121c:	00c79513          	slli	a0,a5,0xc
    80001220:	fc8ff0ef          	jal	800009e8 <kfree>
    80001224:	bfc9                	j	800011f6 <uvmunmap+0x46>
    80001226:	74a2                	ld	s1,40(sp)
    80001228:	7902                	ld	s2,32(sp)
    8000122a:	69e2                	ld	s3,24(sp)
    8000122c:	6a42                	ld	s4,16(sp)
    8000122e:	6aa2                	ld	s5,8(sp)
    80001230:	6b02                	ld	s6,0(sp)
  }
}
    80001232:	70e2                	ld	ra,56(sp)
    80001234:	7442                	ld	s0,48(sp)
    80001236:	6121                	addi	sp,sp,64
    80001238:	8082                	ret

000000008000123a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000123a:	1101                	addi	sp,sp,-32
    8000123c:	ec06                	sd	ra,24(sp)
    8000123e:	e822                	sd	s0,16(sp)
    80001240:	e426                	sd	s1,8(sp)
    80001242:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001244:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001246:	00b67d63          	bgeu	a2,a1,80001260 <uvmdealloc+0x26>
    8000124a:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000124c:	6785                	lui	a5,0x1
    8000124e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001250:	00f60733          	add	a4,a2,a5
    80001254:	76fd                	lui	a3,0xfffff
    80001256:	8f75                	and	a4,a4,a3
    80001258:	97ae                	add	a5,a5,a1
    8000125a:	8ff5                	and	a5,a5,a3
    8000125c:	00f76863          	bltu	a4,a5,8000126c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001260:	8526                	mv	a0,s1
    80001262:	60e2                	ld	ra,24(sp)
    80001264:	6442                	ld	s0,16(sp)
    80001266:	64a2                	ld	s1,8(sp)
    80001268:	6105                	addi	sp,sp,32
    8000126a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000126c:	8f99                	sub	a5,a5,a4
    8000126e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001270:	4685                	li	a3,1
    80001272:	0007861b          	sext.w	a2,a5
    80001276:	85ba                	mv	a1,a4
    80001278:	f39ff0ef          	jal	800011b0 <uvmunmap>
    8000127c:	b7d5                	j	80001260 <uvmdealloc+0x26>

000000008000127e <uvmalloc>:
  if (newsz < oldsz)
    8000127e:	08b66f63          	bltu	a2,a1,8000131c <uvmalloc+0x9e>
{
    80001282:	7139                	addi	sp,sp,-64
    80001284:	fc06                	sd	ra,56(sp)
    80001286:	f822                	sd	s0,48(sp)
    80001288:	ec4e                	sd	s3,24(sp)
    8000128a:	e852                	sd	s4,16(sp)
    8000128c:	e456                	sd	s5,8(sp)
    8000128e:	0080                	addi	s0,sp,64
    80001290:	8aaa                	mv	s5,a0
    80001292:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001294:	6785                	lui	a5,0x1
    80001296:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001298:	95be                	add	a1,a1,a5
    8000129a:	77fd                	lui	a5,0xfffff
    8000129c:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012a0:	08c9f063          	bgeu	s3,a2,80001320 <uvmalloc+0xa2>
    800012a4:	f426                	sd	s1,40(sp)
    800012a6:	f04a                	sd	s2,32(sp)
    800012a8:	e05a                	sd	s6,0(sp)
    800012aa:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012ac:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012b0:	81bff0ef          	jal	80000aca <kalloc>
    800012b4:	84aa                	mv	s1,a0
    if (mem == 0) {
    800012b6:	c515                	beqz	a0,800012e2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012b8:	6605                	lui	a2,0x1
    800012ba:	4581                	li	a1,0
    800012bc:	9dbff0ef          	jal	80000c96 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012c0:	875a                	mv	a4,s6
    800012c2:	86a6                	mv	a3,s1
    800012c4:	6605                	lui	a2,0x1
    800012c6:	85ca                	mv	a1,s2
    800012c8:	8556                	mv	a0,s5
    800012ca:	d1bff0ef          	jal	80000fe4 <mappages>
    800012ce:	e915                	bnez	a0,80001302 <uvmalloc+0x84>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012d0:	6785                	lui	a5,0x1
    800012d2:	993e                	add	s2,s2,a5
    800012d4:	fd496ee3          	bltu	s2,s4,800012b0 <uvmalloc+0x32>
  return newsz;
    800012d8:	8552                	mv	a0,s4
    800012da:	74a2                	ld	s1,40(sp)
    800012dc:	7902                	ld	s2,32(sp)
    800012de:	6b02                	ld	s6,0(sp)
    800012e0:	a811                	j	800012f4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012e2:	864e                	mv	a2,s3
    800012e4:	85ca                	mv	a1,s2
    800012e6:	8556                	mv	a0,s5
    800012e8:	f53ff0ef          	jal	8000123a <uvmdealloc>
      return 0;
    800012ec:	4501                	li	a0,0
    800012ee:	74a2                	ld	s1,40(sp)
    800012f0:	7902                	ld	s2,32(sp)
    800012f2:	6b02                	ld	s6,0(sp)
}
    800012f4:	70e2                	ld	ra,56(sp)
    800012f6:	7442                	ld	s0,48(sp)
    800012f8:	69e2                	ld	s3,24(sp)
    800012fa:	6a42                	ld	s4,16(sp)
    800012fc:	6aa2                	ld	s5,8(sp)
    800012fe:	6121                	addi	sp,sp,64
    80001300:	8082                	ret
      kfree(mem);
    80001302:	8526                	mv	a0,s1
    80001304:	ee4ff0ef          	jal	800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001308:	864e                	mv	a2,s3
    8000130a:	85ca                	mv	a1,s2
    8000130c:	8556                	mv	a0,s5
    8000130e:	f2dff0ef          	jal	8000123a <uvmdealloc>
      return 0;
    80001312:	4501                	li	a0,0
    80001314:	74a2                	ld	s1,40(sp)
    80001316:	7902                	ld	s2,32(sp)
    80001318:	6b02                	ld	s6,0(sp)
    8000131a:	bfe9                	j	800012f4 <uvmalloc+0x76>
    return oldsz;
    8000131c:	852e                	mv	a0,a1
}
    8000131e:	8082                	ret
  return newsz;
    80001320:	8532                	mv	a0,a2
    80001322:	bfc9                	j	800012f4 <uvmalloc+0x76>

0000000080001324 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001324:	7179                	addi	sp,sp,-48
    80001326:	f406                	sd	ra,40(sp)
    80001328:	f022                	sd	s0,32(sp)
    8000132a:	ec26                	sd	s1,24(sp)
    8000132c:	e84a                	sd	s2,16(sp)
    8000132e:	e44e                	sd	s3,8(sp)
    80001330:	e052                	sd	s4,0(sp)
    80001332:	1800                	addi	s0,sp,48
    80001334:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001336:	84aa                	mv	s1,a0
    80001338:	6905                	lui	s2,0x1
    8000133a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000133c:	4985                	li	s3,1
    8000133e:	a819                	j	80001354 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001340:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001342:	00c79513          	slli	a0,a5,0xc
    80001346:	fdfff0ef          	jal	80001324 <freewalk>
      pagetable[i] = 0;
    8000134a:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    8000134e:	04a1                	addi	s1,s1,8
    80001350:	01248f63          	beq	s1,s2,8000136e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001354:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001356:	00f7f713          	andi	a4,a5,15
    8000135a:	ff3703e3          	beq	a4,s3,80001340 <freewalk+0x1c>
    } else if (pte & PTE_V) {
    8000135e:	8b85                	andi	a5,a5,1
    80001360:	d7fd                	beqz	a5,8000134e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001362:	00006517          	auipc	a0,0x6
    80001366:	dc650513          	addi	a0,a0,-570 # 80007128 <etext+0x128>
    8000136a:	c86ff0ef          	jal	800007f0 <panic>
    }
  }
  kfree((void *)pagetable);
    8000136e:	8552                	mv	a0,s4
    80001370:	e78ff0ef          	jal	800009e8 <kfree>
}
    80001374:	70a2                	ld	ra,40(sp)
    80001376:	7402                	ld	s0,32(sp)
    80001378:	64e2                	ld	s1,24(sp)
    8000137a:	6942                	ld	s2,16(sp)
    8000137c:	69a2                	ld	s3,8(sp)
    8000137e:	6a02                	ld	s4,0(sp)
    80001380:	6145                	addi	sp,sp,48
    80001382:	8082                	ret

0000000080001384 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001384:	1101                	addi	sp,sp,-32
    80001386:	ec06                	sd	ra,24(sp)
    80001388:	e822                	sd	s0,16(sp)
    8000138a:	e426                	sd	s1,8(sp)
    8000138c:	1000                	addi	s0,sp,32
    8000138e:	84aa                	mv	s1,a0
  if (sz > 0)
    80001390:	e989                	bnez	a1,800013a2 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001392:	8526                	mv	a0,s1
    80001394:	f91ff0ef          	jal	80001324 <freewalk>
}
    80001398:	60e2                	ld	ra,24(sp)
    8000139a:	6442                	ld	s0,16(sp)
    8000139c:	64a2                	ld	s1,8(sp)
    8000139e:	6105                	addi	sp,sp,32
    800013a0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800013a2:	6785                	lui	a5,0x1
    800013a4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013a6:	95be                	add	a1,a1,a5
    800013a8:	4685                	li	a3,1
    800013aa:	00c5d613          	srli	a2,a1,0xc
    800013ae:	4581                	li	a1,0
    800013b0:	e01ff0ef          	jal	800011b0 <uvmunmap>
    800013b4:	bff9                	j	80001392 <uvmfree+0xe>

00000000800013b6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    800013b6:	ce49                	beqz	a2,80001450 <uvmcopy+0x9a>
{
    800013b8:	715d                	addi	sp,sp,-80
    800013ba:	e486                	sd	ra,72(sp)
    800013bc:	e0a2                	sd	s0,64(sp)
    800013be:	fc26                	sd	s1,56(sp)
    800013c0:	f84a                	sd	s2,48(sp)
    800013c2:	f44e                	sd	s3,40(sp)
    800013c4:	f052                	sd	s4,32(sp)
    800013c6:	ec56                	sd	s5,24(sp)
    800013c8:	e85a                	sd	s6,16(sp)
    800013ca:	e45e                	sd	s7,8(sp)
    800013cc:	0880                	addi	s0,sp,80
    800013ce:	8aaa                	mv	s5,a0
    800013d0:	8b2e                	mv	s6,a1
    800013d2:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE) {
    800013d4:	4481                	li	s1,0
    800013d6:	a029                	j	800013e0 <uvmcopy+0x2a>
    800013d8:	6785                	lui	a5,0x1
    800013da:	94be                	add	s1,s1,a5
    800013dc:	0544fe63          	bgeu	s1,s4,80001438 <uvmcopy+0x82>
    if ((pte = walk(old, i, 0)) == 0)
    800013e0:	4601                	li	a2,0
    800013e2:	85a6                	mv	a1,s1
    800013e4:	8556                	mv	a0,s5
    800013e6:	b27ff0ef          	jal	80000f0c <walk>
    800013ea:	d57d                	beqz	a0,800013d8 <uvmcopy+0x22>
      continue; // page table entry hasn't been allocated
    if ((*pte & PTE_V) == 0)
    800013ec:	6118                	ld	a4,0(a0)
    800013ee:	00177793          	andi	a5,a4,1
    800013f2:	d3fd                	beqz	a5,800013d8 <uvmcopy+0x22>
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013f4:	00a75593          	srli	a1,a4,0xa
    800013f8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800013fc:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    80001400:	ecaff0ef          	jal	80000aca <kalloc>
    80001404:	89aa                	mv	s3,a0
    80001406:	c105                	beqz	a0,80001426 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001408:	6605                	lui	a2,0x1
    8000140a:	85de                	mv	a1,s7
    8000140c:	8e7ff0ef          	jal	80000cf2 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    80001410:	874a                	mv	a4,s2
    80001412:	86ce                	mv	a3,s3
    80001414:	6605                	lui	a2,0x1
    80001416:	85a6                	mv	a1,s1
    80001418:	855a                	mv	a0,s6
    8000141a:	bcbff0ef          	jal	80000fe4 <mappages>
    8000141e:	dd4d                	beqz	a0,800013d8 <uvmcopy+0x22>
      kfree(mem);
    80001420:	854e                	mv	a0,s3
    80001422:	dc6ff0ef          	jal	800009e8 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001426:	4685                	li	a3,1
    80001428:	00c4d613          	srli	a2,s1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	855a                	mv	a0,s6
    80001430:	d81ff0ef          	jal	800011b0 <uvmunmap>
  return -1;
    80001434:	557d                	li	a0,-1
    80001436:	a011                	j	8000143a <uvmcopy+0x84>
  return 0;
    80001438:	4501                	li	a0,0
}
    8000143a:	60a6                	ld	ra,72(sp)
    8000143c:	6406                	ld	s0,64(sp)
    8000143e:	74e2                	ld	s1,56(sp)
    80001440:	7942                	ld	s2,48(sp)
    80001442:	79a2                	ld	s3,40(sp)
    80001444:	7a02                	ld	s4,32(sp)
    80001446:	6ae2                	ld	s5,24(sp)
    80001448:	6b42                	ld	s6,16(sp)
    8000144a:	6ba2                	ld	s7,8(sp)
    8000144c:	6161                	addi	sp,sp,80
    8000144e:	8082                	ret
  return 0;
    80001450:	4501                	li	a0,0
}
    80001452:	8082                	ret

0000000080001454 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001454:	1141                	addi	sp,sp,-16
    80001456:	e406                	sd	ra,8(sp)
    80001458:	e022                	sd	s0,0(sp)
    8000145a:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000145c:	4601                	li	a2,0
    8000145e:	aafff0ef          	jal	80000f0c <walk>
  if (pte == 0)
    80001462:	c901                	beqz	a0,80001472 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001464:	611c                	ld	a5,0(a0)
    80001466:	9bbd                	andi	a5,a5,-17
    80001468:	e11c                	sd	a5,0(a0)
}
    8000146a:	60a2                	ld	ra,8(sp)
    8000146c:	6402                	ld	s0,0(sp)
    8000146e:	0141                	addi	sp,sp,16
    80001470:	8082                	ret
    panic("uvmclear");
    80001472:	00006517          	auipc	a0,0x6
    80001476:	cc650513          	addi	a0,a0,-826 # 80007138 <etext+0x138>
    8000147a:	b76ff0ef          	jal	800007f0 <panic>

000000008000147e <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000147e:	1141                	addi	sp,sp,-16
    80001480:	e406                	sd	ra,8(sp)
    80001482:	e022                	sd	s0,0(sp)
    80001484:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001486:	4601                	li	a2,0
    80001488:	a85ff0ef          	jal	80000f0c <walk>
  if (pte == 0) {
    8000148c:	c519                	beqz	a0,8000149a <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    8000148e:	6108                	ld	a0,0(a0)
    80001490:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001492:	60a2                	ld	ra,8(sp)
    80001494:	6402                	ld	s0,0(sp)
    80001496:	0141                	addi	sp,sp,16
    80001498:	8082                	ret
    return 0;
    8000149a:	4501                	li	a0,0
    8000149c:	bfdd                	j	80001492 <ismapped+0x14>

000000008000149e <vmfault>:
{
    8000149e:	7179                	addi	sp,sp,-48
    800014a0:	f406                	sd	ra,40(sp)
    800014a2:	f022                	sd	s0,32(sp)
    800014a4:	e44e                	sd	s3,8(sp)
    800014a6:	1800                	addi	s0,sp,48
    return 0;
    800014a8:	4981                	li	s3,0
  if (va >= psz)
    800014aa:	00b66863          	bltu	a2,a1,800014ba <vmfault+0x1c>
}
    800014ae:	854e                	mv	a0,s3
    800014b0:	70a2                	ld	ra,40(sp)
    800014b2:	7402                	ld	s0,32(sp)
    800014b4:	69a2                	ld	s3,8(sp)
    800014b6:	6145                	addi	sp,sp,48
    800014b8:	8082                	ret
    800014ba:	ec26                	sd	s1,24(sp)
    800014bc:	e84a                	sd	s2,16(sp)
    800014be:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    800014c0:	77fd                	lui	a5,0xfffff
    800014c2:	00f674b3          	and	s1,a2,a5
  if (ismapped(pagetable, va)) {
    800014c6:	85a6                	mv	a1,s1
    800014c8:	fb7ff0ef          	jal	8000147e <ismapped>
    return 0;
    800014cc:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    800014ce:	c501                	beqz	a0,800014d6 <vmfault+0x38>
    800014d0:	64e2                	ld	s1,24(sp)
    800014d2:	6942                	ld	s2,16(sp)
    800014d4:	bfe9                	j	800014ae <vmfault+0x10>
    800014d6:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    800014d8:	df2ff0ef          	jal	80000aca <kalloc>
    800014dc:	8a2a                	mv	s4,a0
  if (mem == 0)
    800014de:	c915                	beqz	a0,80001512 <vmfault+0x74>
  mem = (uint64)kalloc();
    800014e0:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    800014e2:	6605                	lui	a2,0x1
    800014e4:	4581                	li	a1,0
    800014e6:	fb0ff0ef          	jal	80000c96 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800014ea:	4759                	li	a4,22
    800014ec:	86d2                	mv	a3,s4
    800014ee:	6605                	lui	a2,0x1
    800014f0:	85a6                	mv	a1,s1
    800014f2:	854a                	mv	a0,s2
    800014f4:	af1ff0ef          	jal	80000fe4 <mappages>
    800014f8:	e509                	bnez	a0,80001502 <vmfault+0x64>
    800014fa:	64e2                	ld	s1,24(sp)
    800014fc:	6942                	ld	s2,16(sp)
    800014fe:	6a02                	ld	s4,0(sp)
    80001500:	b77d                	j	800014ae <vmfault+0x10>
    kfree((void *)mem);
    80001502:	8552                	mv	a0,s4
    80001504:	ce4ff0ef          	jal	800009e8 <kfree>
    return 0;
    80001508:	4981                	li	s3,0
    8000150a:	64e2                	ld	s1,24(sp)
    8000150c:	6942                	ld	s2,16(sp)
    8000150e:	6a02                	ld	s4,0(sp)
    80001510:	bf79                	j	800014ae <vmfault+0x10>
    80001512:	64e2                	ld	s1,24(sp)
    80001514:	6942                	ld	s2,16(sp)
    80001516:	6a02                	ld	s4,0(sp)
    80001518:	bf59                	j	800014ae <vmfault+0x10>

000000008000151a <copyout>:
  while (len > 0) {
    8000151a:	c745                	beqz	a4,800015c2 <copyout+0xa8>
{
    8000151c:	7159                	addi	sp,sp,-112
    8000151e:	f486                	sd	ra,104(sp)
    80001520:	f0a2                	sd	s0,96(sp)
    80001522:	eca6                	sd	s1,88(sp)
    80001524:	e0d2                	sd	s4,64(sp)
    80001526:	f85a                	sd	s6,48(sp)
    80001528:	f45e                	sd	s7,40(sp)
    8000152a:	f062                	sd	s8,32(sp)
    8000152c:	e46e                	sd	s11,8(sp)
    8000152e:	1880                	addi	s0,sp,112
    80001530:	8c2a                	mv	s8,a0
    80001532:	8dae                	mv	s11,a1
    80001534:	8b32                	mv	s6,a2
    80001536:	8bb6                	mv	s7,a3
    80001538:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(dstva);
    8000153a:	74fd                	lui	s1,0xfffff
    8000153c:	8cf1                	and	s1,s1,a2
    if (va0 >= MAXVA)
    8000153e:	57fd                	li	a5,-1
    80001540:	83e9                	srli	a5,a5,0x1a
    80001542:	0897e263          	bltu	a5,s1,800015c6 <copyout+0xac>
    80001546:	e8ca                	sd	s2,80(sp)
    80001548:	e4ce                	sd	s3,72(sp)
    8000154a:	fc56                	sd	s5,56(sp)
    8000154c:	ec66                	sd	s9,24(sp)
    8000154e:	e86a                	sd	s10,16(sp)
    80001550:	6d05                	lui	s10,0x1
    80001552:	8cbe                	mv	s9,a5
    80001554:	a015                	j	80001578 <copyout+0x5e>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001556:	409b0533          	sub	a0,s6,s1
    8000155a:	0009861b          	sext.w	a2,s3
    8000155e:	85de                	mv	a1,s7
    80001560:	954a                	add	a0,a0,s2
    80001562:	f90ff0ef          	jal	80000cf2 <memmove>
    len -= n;
    80001566:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000156a:	9bce                	add	s7,s7,s3
  while (len > 0) {
    8000156c:	040a0463          	beqz	s4,800015b4 <copyout+0x9a>
    if (va0 >= MAXVA)
    80001570:	055ced63          	bltu	s9,s5,800015ca <copyout+0xb0>
    80001574:	84d6                	mv	s1,s5
    80001576:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001578:	85a6                	mv	a1,s1
    8000157a:	8562                	mv	a0,s8
    8000157c:	a2bff0ef          	jal	80000fa6 <walkaddr>
    80001580:	892a                	mv	s2,a0
    if (pa0 == 0) {
    80001582:	e909                	bnez	a0,80001594 <copyout+0x7a>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    80001584:	4681                	li	a3,0
    80001586:	8626                	mv	a2,s1
    80001588:	85ee                	mv	a1,s11
    8000158a:	8562                	mv	a0,s8
    8000158c:	f13ff0ef          	jal	8000149e <vmfault>
    80001590:	892a                	mv	s2,a0
    80001592:	c139                	beqz	a0,800015d8 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001594:	4601                	li	a2,0
    80001596:	85a6                	mv	a1,s1
    80001598:	8562                	mv	a0,s8
    8000159a:	973ff0ef          	jal	80000f0c <walk>
    if ((*pte & PTE_W) == 0)
    8000159e:	611c                	ld	a5,0(a0)
    800015a0:	8b91                	andi	a5,a5,4
    800015a2:	c3b1                	beqz	a5,800015e6 <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    800015a4:	01a48ab3          	add	s5,s1,s10
    800015a8:	416a89b3          	sub	s3,s5,s6
    if (n > len)
    800015ac:	fb3a75e3          	bgeu	s4,s3,80001556 <copyout+0x3c>
    800015b0:	89d2                	mv	s3,s4
    800015b2:	b755                	j	80001556 <copyout+0x3c>
  return 0;
    800015b4:	4501                	li	a0,0
    800015b6:	6946                	ld	s2,80(sp)
    800015b8:	69a6                	ld	s3,72(sp)
    800015ba:	7ae2                	ld	s5,56(sp)
    800015bc:	6ce2                	ld	s9,24(sp)
    800015be:	6d42                	ld	s10,16(sp)
    800015c0:	a80d                	j	800015f2 <copyout+0xd8>
    800015c2:	4501                	li	a0,0
}
    800015c4:	8082                	ret
      return -1;
    800015c6:	557d                	li	a0,-1
    800015c8:	a02d                	j	800015f2 <copyout+0xd8>
    800015ca:	557d                	li	a0,-1
    800015cc:	6946                	ld	s2,80(sp)
    800015ce:	69a6                	ld	s3,72(sp)
    800015d0:	7ae2                	ld	s5,56(sp)
    800015d2:	6ce2                	ld	s9,24(sp)
    800015d4:	6d42                	ld	s10,16(sp)
    800015d6:	a831                	j	800015f2 <copyout+0xd8>
        return -1;
    800015d8:	557d                	li	a0,-1
    800015da:	6946                	ld	s2,80(sp)
    800015dc:	69a6                	ld	s3,72(sp)
    800015de:	7ae2                	ld	s5,56(sp)
    800015e0:	6ce2                	ld	s9,24(sp)
    800015e2:	6d42                	ld	s10,16(sp)
    800015e4:	a039                	j	800015f2 <copyout+0xd8>
      return -1;
    800015e6:	557d                	li	a0,-1
    800015e8:	6946                	ld	s2,80(sp)
    800015ea:	69a6                	ld	s3,72(sp)
    800015ec:	7ae2                	ld	s5,56(sp)
    800015ee:	6ce2                	ld	s9,24(sp)
    800015f0:	6d42                	ld	s10,16(sp)
}
    800015f2:	70a6                	ld	ra,104(sp)
    800015f4:	7406                	ld	s0,96(sp)
    800015f6:	64e6                	ld	s1,88(sp)
    800015f8:	6a06                	ld	s4,64(sp)
    800015fa:	7b42                	ld	s6,48(sp)
    800015fc:	7ba2                	ld	s7,40(sp)
    800015fe:	7c02                	ld	s8,32(sp)
    80001600:	6da2                	ld	s11,8(sp)
    80001602:	6165                	addi	sp,sp,112
    80001604:	8082                	ret

0000000080001606 <copyin>:
  while (len > 0) {
    80001606:	cb49                	beqz	a4,80001698 <copyin+0x92>
{
    80001608:	711d                	addi	sp,sp,-96
    8000160a:	ec86                	sd	ra,88(sp)
    8000160c:	e8a2                	sd	s0,80(sp)
    8000160e:	e4a6                	sd	s1,72(sp)
    80001610:	e0ca                	sd	s2,64(sp)
    80001612:	fc4e                	sd	s3,56(sp)
    80001614:	f852                	sd	s4,48(sp)
    80001616:	f456                	sd	s5,40(sp)
    80001618:	f05a                	sd	s6,32(sp)
    8000161a:	ec5e                	sd	s7,24(sp)
    8000161c:	e862                	sd	s8,16(sp)
    8000161e:	e466                	sd	s9,8(sp)
    80001620:	1080                	addi	s0,sp,96
    80001622:	8baa                	mv	s7,a0
    80001624:	8cae                	mv	s9,a1
    80001626:	8ab2                	mv	s5,a2
    80001628:	8936                	mv	s2,a3
    8000162a:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    8000162c:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000162e:	6b05                	lui	s6,0x1
    80001630:	a035                	j	8000165c <copyin+0x56>
    80001632:	412984b3          	sub	s1,s3,s2
    80001636:	94da                	add	s1,s1,s6
    if (n > len)
    80001638:	009a7363          	bgeu	s4,s1,8000163e <copyin+0x38>
    8000163c:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000163e:	413905b3          	sub	a1,s2,s3
    80001642:	0004861b          	sext.w	a2,s1
    80001646:	95aa                	add	a1,a1,a0
    80001648:	8556                	mv	a0,s5
    8000164a:	ea8ff0ef          	jal	80000cf2 <memmove>
    len -= n;
    8000164e:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001652:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001654:	01698933          	add	s2,s3,s6
  while (len > 0) {
    80001658:	020a0263          	beqz	s4,8000167c <copyin+0x76>
    va0 = PGROUNDDOWN(srcva);
    8000165c:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001660:	85ce                	mv	a1,s3
    80001662:	855e                	mv	a0,s7
    80001664:	943ff0ef          	jal	80000fa6 <walkaddr>
    if (pa0 == 0) {
    80001668:	f569                	bnez	a0,80001632 <copyin+0x2c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000166a:	4685                	li	a3,1
    8000166c:	864e                	mv	a2,s3
    8000166e:	85e6                	mv	a1,s9
    80001670:	855e                	mv	a0,s7
    80001672:	e2dff0ef          	jal	8000149e <vmfault>
    80001676:	fd55                	bnez	a0,80001632 <copyin+0x2c>
        return -1;
    80001678:	557d                	li	a0,-1
    8000167a:	a011                	j	8000167e <copyin+0x78>
  return 0;
    8000167c:	4501                	li	a0,0
}
    8000167e:	60e6                	ld	ra,88(sp)
    80001680:	6446                	ld	s0,80(sp)
    80001682:	64a6                	ld	s1,72(sp)
    80001684:	6906                	ld	s2,64(sp)
    80001686:	79e2                	ld	s3,56(sp)
    80001688:	7a42                	ld	s4,48(sp)
    8000168a:	7aa2                	ld	s5,40(sp)
    8000168c:	7b02                	ld	s6,32(sp)
    8000168e:	6be2                	ld	s7,24(sp)
    80001690:	6c42                	ld	s8,16(sp)
    80001692:	6ca2                	ld	s9,8(sp)
    80001694:	6125                	addi	sp,sp,96
    80001696:	8082                	ret
  return 0;
    80001698:	4501                	li	a0,0
}
    8000169a:	8082                	ret

000000008000169c <copyinstr>:
  while (got_null == 0 && max > 0) {
    8000169c:	c371                	beqz	a4,80001760 <copyinstr+0xc4>
{
    8000169e:	715d                	addi	sp,sp,-80
    800016a0:	e486                	sd	ra,72(sp)
    800016a2:	e0a2                	sd	s0,64(sp)
    800016a4:	fc26                	sd	s1,56(sp)
    800016a6:	f84a                	sd	s2,48(sp)
    800016a8:	f44e                	sd	s3,40(sp)
    800016aa:	f052                	sd	s4,32(sp)
    800016ac:	ec56                	sd	s5,24(sp)
    800016ae:	e85a                	sd	s6,16(sp)
    800016b0:	e45e                	sd	s7,8(sp)
    800016b2:	e062                	sd	s8,0(sp)
    800016b4:	0880                	addi	s0,sp,80
    800016b6:	8a2a                	mv	s4,a0
    800016b8:	8b2e                	mv	s6,a1
    800016ba:	8bb2                	mv	s7,a2
    800016bc:	8c36                	mv	s8,a3
    800016be:	893a                	mv	s2,a4
    va0 = PGROUNDDOWN(srcva);
    800016c0:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    800016c2:	6985                	lui	s3,0x1
    800016c4:	a0b1                	j	80001710 <copyinstr+0x74>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016c6:	4685                	li	a3,1
    800016c8:	8626                	mv	a2,s1
    800016ca:	85da                	mv	a1,s6
    800016cc:	8552                	mv	a0,s4
    800016ce:	dd1ff0ef          	jal	8000149e <vmfault>
    800016d2:	e531                	bnez	a0,8000171e <copyinstr+0x82>
        return -1;
    800016d4:	557d                	li	a0,-1
    800016d6:	a039                	j	800016e4 <copyinstr+0x48>
        *dst = '\0';
    800016d8:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb4d0>
    800016dc:	4785                	li	a5,1
  if (got_null) {
    800016de:	37fd                	addiw	a5,a5,-1
    800016e0:	0007851b          	sext.w	a0,a5
}
    800016e4:	60a6                	ld	ra,72(sp)
    800016e6:	6406                	ld	s0,64(sp)
    800016e8:	74e2                	ld	s1,56(sp)
    800016ea:	7942                	ld	s2,48(sp)
    800016ec:	79a2                	ld	s3,40(sp)
    800016ee:	7a02                	ld	s4,32(sp)
    800016f0:	6ae2                	ld	s5,24(sp)
    800016f2:	6b42                	ld	s6,16(sp)
    800016f4:	6ba2                	ld	s7,8(sp)
    800016f6:	6c02                	ld	s8,0(sp)
    800016f8:	6161                	addi	sp,sp,80
    800016fa:	8082                	ret
    800016fc:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001700:	972a                	add	a4,a4,a0
      --max;
    80001702:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001706:	01348c33          	add	s8,s1,s3
  while (got_null == 0 && max > 0) {
    8000170a:	04e58563          	beq	a1,a4,80001754 <copyinstr+0xb8>
{
    8000170e:	8bbe                	mv	s7,a5
    va0 = PGROUNDDOWN(srcva);
    80001710:	015c74b3          	and	s1,s8,s5
    pa0 = walkaddr(pagetable, va0);
    80001714:	85a6                	mv	a1,s1
    80001716:	8552                	mv	a0,s4
    80001718:	88fff0ef          	jal	80000fa6 <walkaddr>
    if (pa0 == 0) {
    8000171c:	d54d                	beqz	a0,800016c6 <copyinstr+0x2a>
    n = PGSIZE - (srcva - va0);
    8000171e:	41848633          	sub	a2,s1,s8
    80001722:	964e                	add	a2,a2,s3
    if (n > max)
    80001724:	00c97363          	bgeu	s2,a2,8000172a <copyinstr+0x8e>
    80001728:	864a                	mv	a2,s2
    char *p = (char *)(pa0 + (srcva - va0));
    8000172a:	409c0c33          	sub	s8,s8,s1
    8000172e:	9c2a                	add	s8,s8,a0
    while (n > 0) {
    80001730:	c605                	beqz	a2,80001758 <copyinstr+0xbc>
    80001732:	87de                	mv	a5,s7
    80001734:	855e                	mv	a0,s7
      if (*p == '\0') {
    80001736:	417c0733          	sub	a4,s8,s7
    while (n > 0) {
    8000173a:	965e                	add	a2,a2,s7
    8000173c:	85be                	mv	a1,a5
      if (*p == '\0') {
    8000173e:	00f706b3          	add	a3,a4,a5
    80001742:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffdb4d0>
    80001746:	dac9                	beqz	a3,800016d8 <copyinstr+0x3c>
        *dst = *p;
    80001748:	00d78023          	sb	a3,0(a5)
      dst++;
    8000174c:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000174e:	fec797e3          	bne	a5,a2,8000173c <copyinstr+0xa0>
    80001752:	b76d                	j	800016fc <copyinstr+0x60>
    80001754:	4781                	li	a5,0
    80001756:	b761                	j	800016de <copyinstr+0x42>
    srcva = va0 + PGSIZE;
    80001758:	6c05                	lui	s8,0x1
    8000175a:	9c26                	add	s8,s8,s1
    8000175c:	87de                	mv	a5,s7
    8000175e:	bf45                	j	8000170e <copyinstr+0x72>
  int got_null = 0;
    80001760:	4781                	li	a5,0
  if (got_null) {
    80001762:	37fd                	addiw	a5,a5,-1
    80001764:	0007851b          	sext.w	a0,a5
}
    80001768:	8082                	ret

000000008000176a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000176a:	7139                	addi	sp,sp,-64
    8000176c:	fc06                	sd	ra,56(sp)
    8000176e:	f822                	sd	s0,48(sp)
    80001770:	f426                	sd	s1,40(sp)
    80001772:	f04a                	sd	s2,32(sp)
    80001774:	ec4e                	sd	s3,24(sp)
    80001776:	e852                	sd	s4,16(sp)
    80001778:	e456                	sd	s5,8(sp)
    8000177a:	e05a                	sd	s6,0(sp)
    8000177c:	0080                	addi	s0,sp,64
    8000177e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001780:	00011497          	auipc	s1,0x11
    80001784:	3d048493          	addi	s1,s1,976 # 80012b50 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001788:	8b26                	mv	s6,s1
    8000178a:	ff4df937          	lui	s2,0xff4df
    8000178e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bae8d>
    80001792:	0936                	slli	s2,s2,0xd
    80001794:	6f590913          	addi	s2,s2,1781
    80001798:	0936                	slli	s2,s2,0xd
    8000179a:	bd390913          	addi	s2,s2,-1069
    8000179e:	0932                	slli	s2,s2,0xc
    800017a0:	7a790913          	addi	s2,s2,1959
    800017a4:	040009b7          	lui	s3,0x4000
    800017a8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017aa:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800017ac:	00017a97          	auipc	s5,0x17
    800017b0:	fa4a8a93          	addi	s5,s5,-92 # 80018750 <tickslock>
    char *pa = kalloc();
    800017b4:	b16ff0ef          	jal	80000aca <kalloc>
    800017b8:	862a                	mv	a2,a0
    if (pa == 0)
    800017ba:	cd15                	beqz	a0,800017f6 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    800017bc:	416485b3          	sub	a1,s1,s6
    800017c0:	8591                	srai	a1,a1,0x4
    800017c2:	032585b3          	mul	a1,a1,s2
    800017c6:	2585                	addiw	a1,a1,1
    800017c8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017cc:	4719                	li	a4,6
    800017ce:	6685                	lui	a3,0x1
    800017d0:	40b985b3          	sub	a1,s3,a1
    800017d4:	8552                	mv	a0,s4
    800017d6:	8bfff0ef          	jal	80001094 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017da:	17048493          	addi	s1,s1,368
    800017de:	fd549be3          	bne	s1,s5,800017b4 <proc_mapstacks+0x4a>
  }
}
    800017e2:	70e2                	ld	ra,56(sp)
    800017e4:	7442                	ld	s0,48(sp)
    800017e6:	74a2                	ld	s1,40(sp)
    800017e8:	7902                	ld	s2,32(sp)
    800017ea:	69e2                	ld	s3,24(sp)
    800017ec:	6a42                	ld	s4,16(sp)
    800017ee:	6aa2                	ld	s5,8(sp)
    800017f0:	6b02                	ld	s6,0(sp)
    800017f2:	6121                	addi	sp,sp,64
    800017f4:	8082                	ret
      panic("kalloc");
    800017f6:	00006517          	auipc	a0,0x6
    800017fa:	95250513          	addi	a0,a0,-1710 # 80007148 <etext+0x148>
    800017fe:	ff3fe0ef          	jal	800007f0 <panic>

0000000080001802 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001802:	7139                	addi	sp,sp,-64
    80001804:	fc06                	sd	ra,56(sp)
    80001806:	f822                	sd	s0,48(sp)
    80001808:	f426                	sd	s1,40(sp)
    8000180a:	f04a                	sd	s2,32(sp)
    8000180c:	ec4e                	sd	s3,24(sp)
    8000180e:	e852                	sd	s4,16(sp)
    80001810:	e456                	sd	s5,8(sp)
    80001812:	e05a                	sd	s6,0(sp)
    80001814:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001816:	00006597          	auipc	a1,0x6
    8000181a:	93a58593          	addi	a1,a1,-1734 # 80007150 <etext+0x150>
    8000181e:	00011517          	auipc	a0,0x11
    80001822:	f0250513          	addi	a0,a0,-254 # 80012720 <pid_lock>
    80001826:	b36ff0ef          	jal	80000b5c <initlock>
  initlock(&wait_lock, "wait_lock");
    8000182a:	00006597          	auipc	a1,0x6
    8000182e:	92e58593          	addi	a1,a1,-1746 # 80007158 <etext+0x158>
    80001832:	00011517          	auipc	a0,0x11
    80001836:	f0650513          	addi	a0,a0,-250 # 80012738 <wait_lock>
    8000183a:	b22ff0ef          	jal	80000b5c <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000183e:	00011497          	auipc	s1,0x11
    80001842:	31248493          	addi	s1,s1,786 # 80012b50 <proc>
    initlock(&p->lock, "proc");
    80001846:	00006b17          	auipc	s6,0x6
    8000184a:	922b0b13          	addi	s6,s6,-1758 # 80007168 <etext+0x168>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000184e:	8aa6                	mv	s5,s1
    80001850:	ff4df937          	lui	s2,0xff4df
    80001854:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bae8d>
    80001858:	0936                	slli	s2,s2,0xd
    8000185a:	6f590913          	addi	s2,s2,1781
    8000185e:	0936                	slli	s2,s2,0xd
    80001860:	bd390913          	addi	s2,s2,-1069
    80001864:	0932                	slli	s2,s2,0xc
    80001866:	7a790913          	addi	s2,s2,1959
    8000186a:	040009b7          	lui	s3,0x4000
    8000186e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001870:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001872:	00017a17          	auipc	s4,0x17
    80001876:	edea0a13          	addi	s4,s4,-290 # 80018750 <tickslock>
    initlock(&p->lock, "proc");
    8000187a:	85da                	mv	a1,s6
    8000187c:	8526                	mv	a0,s1
    8000187e:	adeff0ef          	jal	80000b5c <initlock>
    p->state = UNUSED;
    80001882:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001886:	415487b3          	sub	a5,s1,s5
    8000188a:	8791                	srai	a5,a5,0x4
    8000188c:	032787b3          	mul	a5,a5,s2
    80001890:	2785                	addiw	a5,a5,1
    80001892:	00d7979b          	slliw	a5,a5,0xd
    80001896:	40f987b3          	sub	a5,s3,a5
    8000189a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189c:	17048493          	addi	s1,s1,368
    800018a0:	fd449de3          	bne	s1,s4,8000187a <procinit+0x78>
  }
}
    800018a4:	70e2                	ld	ra,56(sp)
    800018a6:	7442                	ld	s0,48(sp)
    800018a8:	74a2                	ld	s1,40(sp)
    800018aa:	7902                	ld	s2,32(sp)
    800018ac:	69e2                	ld	s3,24(sp)
    800018ae:	6a42                	ld	s4,16(sp)
    800018b0:	6aa2                	ld	s5,8(sp)
    800018b2:	6b02                	ld	s6,0(sp)
    800018b4:	6121                	addi	sp,sp,64
    800018b6:	8082                	ret

00000000800018b8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b8:	1141                	addi	sp,sp,-16
    800018ba:	e422                	sd	s0,8(sp)
    800018bc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800018be:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018c0:	2501                	sext.w	a0,a0
    800018c2:	6422                	ld	s0,8(sp)
    800018c4:	0141                	addi	sp,sp,16
    800018c6:	8082                	ret

00000000800018c8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800018c8:	1141                	addi	sp,sp,-16
    800018ca:	e422                	sd	s0,8(sp)
    800018cc:	0800                	addi	s0,sp,16
    800018ce:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018d0:	2781                	sext.w	a5,a5
    800018d2:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d4:	00011517          	auipc	a0,0x11
    800018d8:	e7c50513          	addi	a0,a0,-388 # 80012750 <cpus>
    800018dc:	953e                	add	a0,a0,a5
    800018de:	6422                	ld	s0,8(sp)
    800018e0:	0141                	addi	sp,sp,16
    800018e2:	8082                	ret

00000000800018e4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018e4:	1101                	addi	sp,sp,-32
    800018e6:	ec06                	sd	ra,24(sp)
    800018e8:	e822                	sd	s0,16(sp)
    800018ea:	e426                	sd	s1,8(sp)
    800018ec:	1000                	addi	s0,sp,32
  push_off();
    800018ee:	aaeff0ef          	jal	80000b9c <push_off>
    800018f2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f4:	2781                	sext.w	a5,a5
    800018f6:	079e                	slli	a5,a5,0x7
    800018f8:	00011717          	auipc	a4,0x11
    800018fc:	e2870713          	addi	a4,a4,-472 # 80012720 <pid_lock>
    80001900:	97ba                	add	a5,a5,a4
    80001902:	7b84                	ld	s1,48(a5)
  pop_off();
    80001904:	b0eff0ef          	jal	80000c12 <pop_off>
  return p;
}
    80001908:	8526                	mv	a0,s1
    8000190a:	60e2                	ld	ra,24(sp)
    8000190c:	6442                	ld	s0,16(sp)
    8000190e:	64a2                	ld	s1,8(sp)
    80001910:	6105                	addi	sp,sp,32
    80001912:	8082                	ret

0000000080001914 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001914:	7179                	addi	sp,sp,-48
    80001916:	f406                	sd	ra,40(sp)
    80001918:	f022                	sd	s0,32(sp)
    8000191a:	ec26                	sd	s1,24(sp)
    8000191c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000191e:	fc7ff0ef          	jal	800018e4 <myproc>
    80001922:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001924:	b3aff0ef          	jal	80000c5e <release>

  if (first) {
    80001928:	00009797          	auipc	a5,0x9
    8000192c:	c887a783          	lw	a5,-888(a5) # 8000a5b0 <first.1>
    80001930:	cb9d                	beqz	a5,80001966 <forkret+0x52>
    first = 0;
    80001932:	00009797          	auipc	a5,0x9
    80001936:	c607af23          	sw	zero,-898(a5) # 8000a5b0 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000193a:	4505                	li	a0,1
    8000193c:	7bb010ef          	jal	800038f6 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001940:	00006517          	auipc	a0,0x6
    80001944:	83050513          	addi	a0,a0,-2000 # 80007170 <etext+0x170>
    80001948:	fca43823          	sd	a0,-48(s0)
    8000194c:	fc043c23          	sd	zero,-40(s0)
    80001950:	fd040593          	addi	a1,s0,-48
    80001954:	1fa030ef          	jal	80004b4e <kexec>
    80001958:	6cbc                	ld	a5,88(s1)
    8000195a:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000195c:	6cbc                	ld	a5,88(s1)
    8000195e:	7bb8                	ld	a4,112(a5)
    80001960:	57fd                	li	a5,-1
    80001962:	02f70d63          	beq	a4,a5,8000199c <forkret+0x88>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001966:	44b000ef          	jal	800025b0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000196a:	68a8                	ld	a0,80(s1)
    8000196c:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000196e:	04000737          	lui	a4,0x4000
    80001972:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001974:	0732                	slli	a4,a4,0xc
    80001976:	00004797          	auipc	a5,0x4
    8000197a:	72678793          	addi	a5,a5,1830 # 8000609c <userret>
    8000197e:	00004697          	auipc	a3,0x4
    80001982:	68268693          	addi	a3,a3,1666 # 80006000 <_trampoline>
    80001986:	8f95                	sub	a5,a5,a3
    80001988:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000198a:	577d                	li	a4,-1
    8000198c:	177e                	slli	a4,a4,0x3f
    8000198e:	8d59                	or	a0,a0,a4
    80001990:	9782                	jalr	a5
}
    80001992:	70a2                	ld	ra,40(sp)
    80001994:	7402                	ld	s0,32(sp)
    80001996:	64e2                	ld	s1,24(sp)
    80001998:	6145                	addi	sp,sp,48
    8000199a:	8082                	ret
      panic("exec");
    8000199c:	00005517          	auipc	a0,0x5
    800019a0:	7dc50513          	addi	a0,a0,2012 # 80007178 <etext+0x178>
    800019a4:	e4dfe0ef          	jal	800007f0 <panic>

00000000800019a8 <allocpid>:
{
    800019a8:	1101                	addi	sp,sp,-32
    800019aa:	ec06                	sd	ra,24(sp)
    800019ac:	e822                	sd	s0,16(sp)
    800019ae:	e426                	sd	s1,8(sp)
    800019b0:	e04a                	sd	s2,0(sp)
    800019b2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019b4:	00011917          	auipc	s2,0x11
    800019b8:	d6c90913          	addi	s2,s2,-660 # 80012720 <pid_lock>
    800019bc:	854a                	mv	a0,s2
    800019be:	a14ff0ef          	jal	80000bd2 <acquire>
  pid = nextpid;
    800019c2:	00009797          	auipc	a5,0x9
    800019c6:	bf278793          	addi	a5,a5,-1038 # 8000a5b4 <nextpid>
    800019ca:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019cc:	0014871b          	addiw	a4,s1,1
    800019d0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019d2:	854a                	mv	a0,s2
    800019d4:	a8aff0ef          	jal	80000c5e <release>
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6902                	ld	s2,0(sp)
    800019e2:	6105                	addi	sp,sp,32
    800019e4:	8082                	ret

00000000800019e6 <proc_pagetable>:
{
    800019e6:	1101                	addi	sp,sp,-32
    800019e8:	ec06                	sd	ra,24(sp)
    800019ea:	e822                	sd	s0,16(sp)
    800019ec:	e426                	sd	s1,8(sp)
    800019ee:	e04a                	sd	s2,0(sp)
    800019f0:	1000                	addi	s0,sp,32
    800019f2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019f4:	f96ff0ef          	jal	8000118a <uvmcreate>
    800019f8:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800019fa:	cd05                	beqz	a0,80001a32 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    800019fc:	4729                	li	a4,10
    800019fe:	00004697          	auipc	a3,0x4
    80001a02:	60268693          	addi	a3,a3,1538 # 80006000 <_trampoline>
    80001a06:	6605                	lui	a2,0x1
    80001a08:	040005b7          	lui	a1,0x4000
    80001a0c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a0e:	05b2                	slli	a1,a1,0xc
    80001a10:	dd4ff0ef          	jal	80000fe4 <mappages>
    80001a14:	02054663          	bltz	a0,80001a40 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a18:	4719                	li	a4,6
    80001a1a:	05893683          	ld	a3,88(s2)
    80001a1e:	6605                	lui	a2,0x1
    80001a20:	020005b7          	lui	a1,0x2000
    80001a24:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a26:	05b6                	slli	a1,a1,0xd
    80001a28:	8526                	mv	a0,s1
    80001a2a:	dbaff0ef          	jal	80000fe4 <mappages>
    80001a2e:	00054f63          	bltz	a0,80001a4c <proc_pagetable+0x66>
}
    80001a32:	8526                	mv	a0,s1
    80001a34:	60e2                	ld	ra,24(sp)
    80001a36:	6442                	ld	s0,16(sp)
    80001a38:	64a2                	ld	s1,8(sp)
    80001a3a:	6902                	ld	s2,0(sp)
    80001a3c:	6105                	addi	sp,sp,32
    80001a3e:	8082                	ret
    uvmfree(pagetable, 0);
    80001a40:	4581                	li	a1,0
    80001a42:	8526                	mv	a0,s1
    80001a44:	941ff0ef          	jal	80001384 <uvmfree>
    return 0;
    80001a48:	4481                	li	s1,0
    80001a4a:	b7e5                	j	80001a32 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a4c:	4681                	li	a3,0
    80001a4e:	4605                	li	a2,1
    80001a50:	040005b7          	lui	a1,0x4000
    80001a54:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a56:	05b2                	slli	a1,a1,0xc
    80001a58:	8526                	mv	a0,s1
    80001a5a:	f56ff0ef          	jal	800011b0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a5e:	4581                	li	a1,0
    80001a60:	8526                	mv	a0,s1
    80001a62:	923ff0ef          	jal	80001384 <uvmfree>
    return 0;
    80001a66:	4481                	li	s1,0
    80001a68:	b7e9                	j	80001a32 <proc_pagetable+0x4c>

0000000080001a6a <proc_freepagetable>:
{
    80001a6a:	1101                	addi	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	addi	s0,sp,32
    80001a76:	84aa                	mv	s1,a0
    80001a78:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a7a:	4681                	li	a3,0
    80001a7c:	4605                	li	a2,1
    80001a7e:	040005b7          	lui	a1,0x4000
    80001a82:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a84:	05b2                	slli	a1,a1,0xc
    80001a86:	f2aff0ef          	jal	800011b0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a8a:	4681                	li	a3,0
    80001a8c:	4605                	li	a2,1
    80001a8e:	020005b7          	lui	a1,0x2000
    80001a92:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a94:	05b6                	slli	a1,a1,0xd
    80001a96:	8526                	mv	a0,s1
    80001a98:	f18ff0ef          	jal	800011b0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a9c:	85ca                	mv	a1,s2
    80001a9e:	8526                	mv	a0,s1
    80001aa0:	8e5ff0ef          	jal	80001384 <uvmfree>
}
    80001aa4:	60e2                	ld	ra,24(sp)
    80001aa6:	6442                	ld	s0,16(sp)
    80001aa8:	64a2                	ld	s1,8(sp)
    80001aaa:	6902                	ld	s2,0(sp)
    80001aac:	6105                	addi	sp,sp,32
    80001aae:	8082                	ret

0000000080001ab0 <freeproc>:
{
    80001ab0:	1101                	addi	sp,sp,-32
    80001ab2:	ec06                	sd	ra,24(sp)
    80001ab4:	e822                	sd	s0,16(sp)
    80001ab6:	e426                	sd	s1,8(sp)
    80001ab8:	1000                	addi	s0,sp,32
    80001aba:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001abc:	6d28                	ld	a0,88(a0)
    80001abe:	c119                	beqz	a0,80001ac4 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001ac0:	f29fe0ef          	jal	800009e8 <kfree>
  p->trapframe = 0;
    80001ac4:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001ac8:	68a8                	ld	a0,80(s1)
    80001aca:	c501                	beqz	a0,80001ad2 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001acc:	64ac                	ld	a1,72(s1)
    80001ace:	f9dff0ef          	jal	80001a6a <proc_freepagetable>
  p->pagetable = 0;
    80001ad2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ad6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ada:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001ade:	14048e23          	sb	zero,348(s1)
  p->chan = 0;
    80001ae2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ae6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001aea:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001aee:	0004ac23          	sw	zero,24(s1)
}
    80001af2:	60e2                	ld	ra,24(sp)
    80001af4:	6442                	ld	s0,16(sp)
    80001af6:	64a2                	ld	s1,8(sp)
    80001af8:	6105                	addi	sp,sp,32
    80001afa:	8082                	ret

0000000080001afc <allocproc>:
{
    80001afc:	1101                	addi	sp,sp,-32
    80001afe:	ec06                	sd	ra,24(sp)
    80001b00:	e822                	sd	s0,16(sp)
    80001b02:	e426                	sd	s1,8(sp)
    80001b04:	e04a                	sd	s2,0(sp)
    80001b06:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b08:	00011497          	auipc	s1,0x11
    80001b0c:	04848493          	addi	s1,s1,72 # 80012b50 <proc>
    80001b10:	00017917          	auipc	s2,0x17
    80001b14:	c4090913          	addi	s2,s2,-960 # 80018750 <tickslock>
    acquire(&p->lock);
    80001b18:	8526                	mv	a0,s1
    80001b1a:	8b8ff0ef          	jal	80000bd2 <acquire>
    if (p->state == UNUSED) {
    80001b1e:	4c9c                	lw	a5,24(s1)
    80001b20:	cb91                	beqz	a5,80001b34 <allocproc+0x38>
      release(&p->lock);
    80001b22:	8526                	mv	a0,s1
    80001b24:	93aff0ef          	jal	80000c5e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b28:	17048493          	addi	s1,s1,368
    80001b2c:	ff2496e3          	bne	s1,s2,80001b18 <allocproc+0x1c>
  return 0;
    80001b30:	4481                	li	s1,0
    80001b32:	a099                	j	80001b78 <allocproc+0x7c>
  p->pid = allocpid();
    80001b34:	e75ff0ef          	jal	800019a8 <allocpid>
    80001b38:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b3a:	4785                	li	a5,1
    80001b3c:	cc9c                	sw	a5,24(s1)
  p->trace_mask = 0;
    80001b3e:	1404ac23          	sw	zero,344(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b42:	f89fe0ef          	jal	80000aca <kalloc>
    80001b46:	892a                	mv	s2,a0
    80001b48:	eca8                	sd	a0,88(s1)
    80001b4a:	cd15                	beqz	a0,80001b86 <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	e99ff0ef          	jal	800019e6 <proc_pagetable>
    80001b52:	892a                	mv	s2,a0
    80001b54:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b56:	c121                	beqz	a0,80001b96 <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001b58:	07000613          	li	a2,112
    80001b5c:	4581                	li	a1,0
    80001b5e:	06048513          	addi	a0,s1,96
    80001b62:	934ff0ef          	jal	80000c96 <memset>
  p->context.ra = (uint64)forkret;
    80001b66:	00000797          	auipc	a5,0x0
    80001b6a:	dae78793          	addi	a5,a5,-594 # 80001914 <forkret>
    80001b6e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b70:	60bc                	ld	a5,64(s1)
    80001b72:	6705                	lui	a4,0x1
    80001b74:	97ba                	add	a5,a5,a4
    80001b76:	f4bc                	sd	a5,104(s1)
}
    80001b78:	8526                	mv	a0,s1
    80001b7a:	60e2                	ld	ra,24(sp)
    80001b7c:	6442                	ld	s0,16(sp)
    80001b7e:	64a2                	ld	s1,8(sp)
    80001b80:	6902                	ld	s2,0(sp)
    80001b82:	6105                	addi	sp,sp,32
    80001b84:	8082                	ret
    freeproc(p);
    80001b86:	8526                	mv	a0,s1
    80001b88:	f29ff0ef          	jal	80001ab0 <freeproc>
    release(&p->lock);
    80001b8c:	8526                	mv	a0,s1
    80001b8e:	8d0ff0ef          	jal	80000c5e <release>
    return 0;
    80001b92:	84ca                	mv	s1,s2
    80001b94:	b7d5                	j	80001b78 <allocproc+0x7c>
    freeproc(p);
    80001b96:	8526                	mv	a0,s1
    80001b98:	f19ff0ef          	jal	80001ab0 <freeproc>
    release(&p->lock);
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	8c0ff0ef          	jal	80000c5e <release>
    return 0;
    80001ba2:	84ca                	mv	s1,s2
    80001ba4:	bfd1                	j	80001b78 <allocproc+0x7c>

0000000080001ba6 <userinit>:
{
    80001ba6:	1101                	addi	sp,sp,-32
    80001ba8:	ec06                	sd	ra,24(sp)
    80001baa:	e822                	sd	s0,16(sp)
    80001bac:	e426                	sd	s1,8(sp)
    80001bae:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bb0:	f4dff0ef          	jal	80001afc <allocproc>
    80001bb4:	84aa                	mv	s1,a0
  initproc = p;
    80001bb6:	00009797          	auipc	a5,0x9
    80001bba:	a4a7b123          	sd	a0,-1470(a5) # 8000a5f8 <initproc>
  p->cwd = namei("/");
    80001bbe:	00005517          	auipc	a0,0x5
    80001bc2:	5c250513          	addi	a0,a0,1474 # 80007180 <etext+0x180>
    80001bc6:	268020ef          	jal	80003e2e <namei>
    80001bca:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bce:	478d                	li	a5,3
    80001bd0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	88aff0ef          	jal	80000c5e <release>
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6105                	addi	sp,sp,32
    80001be0:	8082                	ret

0000000080001be2 <growproc>:
{
    80001be2:	1101                	addi	sp,sp,-32
    80001be4:	ec06                	sd	ra,24(sp)
    80001be6:	e822                	sd	s0,16(sp)
    80001be8:	e426                	sd	s1,8(sp)
    80001bea:	e04a                	sd	s2,0(sp)
    80001bec:	1000                	addi	s0,sp,32
    80001bee:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bf0:	cf5ff0ef          	jal	800018e4 <myproc>
    80001bf4:	892a                	mv	s2,a0
  sz = p->sz;
    80001bf6:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001bf8:	02905963          	blez	s1,80001c2a <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001bfc:	00b48633          	add	a2,s1,a1
    80001c00:	020007b7          	lui	a5,0x2000
    80001c04:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c06:	07b6                	slli	a5,a5,0xd
    80001c08:	02c7ea63          	bltu	a5,a2,80001c3c <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c0c:	4691                	li	a3,4
    80001c0e:	6928                	ld	a0,80(a0)
    80001c10:	e6eff0ef          	jal	8000127e <uvmalloc>
    80001c14:	85aa                	mv	a1,a0
    80001c16:	c50d                	beqz	a0,80001c40 <growproc+0x5e>
  p->sz = sz;
    80001c18:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c1c:	4501                	li	a0,0
}
    80001c1e:	60e2                	ld	ra,24(sp)
    80001c20:	6442                	ld	s0,16(sp)
    80001c22:	64a2                	ld	s1,8(sp)
    80001c24:	6902                	ld	s2,0(sp)
    80001c26:	6105                	addi	sp,sp,32
    80001c28:	8082                	ret
  } else if (n < 0) {
    80001c2a:	fe04d7e3          	bgez	s1,80001c18 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c2e:	00b48633          	add	a2,s1,a1
    80001c32:	6928                	ld	a0,80(a0)
    80001c34:	e06ff0ef          	jal	8000123a <uvmdealloc>
    80001c38:	85aa                	mv	a1,a0
    80001c3a:	bff9                	j	80001c18 <growproc+0x36>
      return -1;
    80001c3c:	557d                	li	a0,-1
    80001c3e:	b7c5                	j	80001c1e <growproc+0x3c>
      return -1;
    80001c40:	557d                	li	a0,-1
    80001c42:	bff1                	j	80001c1e <growproc+0x3c>

0000000080001c44 <kfork>:
{
    80001c44:	7139                	addi	sp,sp,-64
    80001c46:	fc06                	sd	ra,56(sp)
    80001c48:	f822                	sd	s0,48(sp)
    80001c4a:	f04a                	sd	s2,32(sp)
    80001c4c:	e456                	sd	s5,8(sp)
    80001c4e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c50:	c95ff0ef          	jal	800018e4 <myproc>
    80001c54:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c56:	ea7ff0ef          	jal	80001afc <allocproc>
    80001c5a:	0e050e63          	beqz	a0,80001d56 <kfork+0x112>
    80001c5e:	ec4e                	sd	s3,24(sp)
    80001c60:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c62:	048ab603          	ld	a2,72(s5)
    80001c66:	692c                	ld	a1,80(a0)
    80001c68:	050ab503          	ld	a0,80(s5)
    80001c6c:	f4aff0ef          	jal	800013b6 <uvmcopy>
    80001c70:	04054e63          	bltz	a0,80001ccc <kfork+0x88>
    80001c74:	f426                	sd	s1,40(sp)
    80001c76:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c78:	048ab783          	ld	a5,72(s5)
    80001c7c:	04f9b423          	sd	a5,72(s3)
  np->trace_mask = p->trace_mask; //inherit tracking
    80001c80:	158aa783          	lw	a5,344(s5)
    80001c84:	14f9ac23          	sw	a5,344(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c88:	058ab683          	ld	a3,88(s5)
    80001c8c:	87b6                	mv	a5,a3
    80001c8e:	0589b703          	ld	a4,88(s3)
    80001c92:	12068693          	addi	a3,a3,288
    80001c96:	0007b803          	ld	a6,0(a5)
    80001c9a:	6788                	ld	a0,8(a5)
    80001c9c:	6b8c                	ld	a1,16(a5)
    80001c9e:	6f90                	ld	a2,24(a5)
    80001ca0:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001ca4:	e708                	sd	a0,8(a4)
    80001ca6:	eb0c                	sd	a1,16(a4)
    80001ca8:	ef10                	sd	a2,24(a4)
    80001caa:	02078793          	addi	a5,a5,32
    80001cae:	02070713          	addi	a4,a4,32
    80001cb2:	fed792e3          	bne	a5,a3,80001c96 <kfork+0x52>
  np->trapframe->a0 = 0;
    80001cb6:	0589b783          	ld	a5,88(s3)
    80001cba:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cbe:	0d0a8493          	addi	s1,s5,208
    80001cc2:	0d098913          	addi	s2,s3,208
    80001cc6:	150a8a13          	addi	s4,s5,336
    80001cca:	a831                	j	80001ce6 <kfork+0xa2>
    freeproc(np);
    80001ccc:	854e                	mv	a0,s3
    80001cce:	de3ff0ef          	jal	80001ab0 <freeproc>
    release(&np->lock);
    80001cd2:	854e                	mv	a0,s3
    80001cd4:	f8bfe0ef          	jal	80000c5e <release>
    return -1;
    80001cd8:	597d                	li	s2,-1
    80001cda:	69e2                	ld	s3,24(sp)
    80001cdc:	a0b5                	j	80001d48 <kfork+0x104>
  for (i = 0; i < NOFILE; i++)
    80001cde:	04a1                	addi	s1,s1,8
    80001ce0:	0921                	addi	s2,s2,8
    80001ce2:	01448963          	beq	s1,s4,80001cf4 <kfork+0xb0>
    if (p->ofile[i])
    80001ce6:	6088                	ld	a0,0(s1)
    80001ce8:	d97d                	beqz	a0,80001cde <kfork+0x9a>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cea:	77e020ef          	jal	80004468 <filedup>
    80001cee:	00a93023          	sd	a0,0(s2)
    80001cf2:	b7f5                	j	80001cde <kfork+0x9a>
  np->cwd = idup(p->cwd);
    80001cf4:	150ab503          	ld	a0,336(s5)
    80001cf8:	08d010ef          	jal	80003584 <idup>
    80001cfc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d00:	4641                	li	a2,16
    80001d02:	15ca8593          	addi	a1,s5,348
    80001d06:	15c98513          	addi	a0,s3,348
    80001d0a:	8caff0ef          	jal	80000dd4 <safestrcpy>
  pid = np->pid;
    80001d0e:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001d12:	854e                	mv	a0,s3
    80001d14:	f4bfe0ef          	jal	80000c5e <release>
  acquire(&wait_lock);
    80001d18:	00011497          	auipc	s1,0x11
    80001d1c:	a2048493          	addi	s1,s1,-1504 # 80012738 <wait_lock>
    80001d20:	8526                	mv	a0,s1
    80001d22:	eb1fe0ef          	jal	80000bd2 <acquire>
  np->parent = p;
    80001d26:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	f33fe0ef          	jal	80000c5e <release>
  acquire(&np->lock);
    80001d30:	854e                	mv	a0,s3
    80001d32:	ea1fe0ef          	jal	80000bd2 <acquire>
  np->state = RUNNABLE;
    80001d36:	478d                	li	a5,3
    80001d38:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d3c:	854e                	mv	a0,s3
    80001d3e:	f21fe0ef          	jal	80000c5e <release>
  return pid;
    80001d42:	74a2                	ld	s1,40(sp)
    80001d44:	69e2                	ld	s3,24(sp)
    80001d46:	6a42                	ld	s4,16(sp)
}
    80001d48:	854a                	mv	a0,s2
    80001d4a:	70e2                	ld	ra,56(sp)
    80001d4c:	7442                	ld	s0,48(sp)
    80001d4e:	7902                	ld	s2,32(sp)
    80001d50:	6aa2                	ld	s5,8(sp)
    80001d52:	6121                	addi	sp,sp,64
    80001d54:	8082                	ret
    return -1;
    80001d56:	597d                	li	s2,-1
    80001d58:	bfc5                	j	80001d48 <kfork+0x104>

0000000080001d5a <scheduler>:
{
    80001d5a:	711d                	addi	sp,sp,-96
    80001d5c:	ec86                	sd	ra,88(sp)
    80001d5e:	e8a2                	sd	s0,80(sp)
    80001d60:	e4a6                	sd	s1,72(sp)
    80001d62:	e0ca                	sd	s2,64(sp)
    80001d64:	fc4e                	sd	s3,56(sp)
    80001d66:	f852                	sd	s4,48(sp)
    80001d68:	f456                	sd	s5,40(sp)
    80001d6a:	f05a                	sd	s6,32(sp)
    80001d6c:	ec5e                	sd	s7,24(sp)
    80001d6e:	e862                	sd	s8,16(sp)
    80001d70:	e466                	sd	s9,8(sp)
    80001d72:	1080                	addi	s0,sp,96
    80001d74:	8792                	mv	a5,tp
  int id = r_tp();
    80001d76:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d78:	00779a93          	slli	s5,a5,0x7
    80001d7c:	00011717          	auipc	a4,0x11
    80001d80:	9a470713          	addi	a4,a4,-1628 # 80012720 <pid_lock>
    80001d84:	9756                	add	a4,a4,s5
    80001d86:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d8a:	00011717          	auipc	a4,0x11
    80001d8e:	9ce70713          	addi	a4,a4,-1586 # 80012758 <cpus+0x8>
    80001d92:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001d94:	4c11                	li	s8,4
        c->proc = p;
    80001d96:	00011b17          	auipc	s6,0x11
    80001d9a:	98ab0b13          	addi	s6,s6,-1654 # 80012720 <pid_lock>
    80001d9e:	079e                	slli	a5,a5,0x7
    80001da0:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001da4:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001da6:	00017997          	auipc	s3,0x17
    80001daa:	9aa98993          	addi	s3,s3,-1622 # 80018750 <tickslock>
    80001dae:	a0a9                	j	80001df8 <scheduler+0x9e>
      release(&p->lock);
    80001db0:	8526                	mv	a0,s1
    80001db2:	eadfe0ef          	jal	80000c5e <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001db6:	17048493          	addi	s1,s1,368
    80001dba:	03348b63          	beq	s1,s3,80001df0 <scheduler+0x96>
      acquire(&p->lock);
    80001dbe:	8526                	mv	a0,s1
    80001dc0:	e13fe0ef          	jal	80000bd2 <acquire>
      if (p->state == RUNNABLE) {
    80001dc4:	4c9c                	lw	a5,24(s1)
    80001dc6:	ff2795e3          	bne	a5,s2,80001db0 <scheduler+0x56>
        p->state = RUNNING;
    80001dca:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dce:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dd2:	06048593          	addi	a1,s1,96
    80001dd6:	8556                	mv	a0,s5
    80001dd8:	732000ef          	jal	8000250a <swtch>
    80001ddc:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001dde:	2781                	sext.w	a5,a5
    80001de0:	079e                	slli	a5,a5,0x7
    80001de2:	97da                	add	a5,a5,s6
    80001de4:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001de8:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dec:	8cde                	mv	s9,s7
    80001dee:	b7c9                	j	80001db0 <scheduler+0x56>
    if (found == 0) {
    80001df0:	000c9463          	bnez	s9,80001df8 <scheduler+0x9e>
      asm volatile("wfi");
    80001df4:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001df8:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001dfc:	10017073          	csrci	sstatus,2
    int found = 0;
    80001e00:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e02:	00011497          	auipc	s1,0x11
    80001e06:	d4e48493          	addi	s1,s1,-690 # 80012b50 <proc>
      if (p->state == RUNNABLE) {
    80001e0a:	490d                	li	s2,3
    80001e0c:	bf4d                	j	80001dbe <scheduler+0x64>

0000000080001e0e <sched>:
{
    80001e0e:	7179                	addi	sp,sp,-48
    80001e10:	f406                	sd	ra,40(sp)
    80001e12:	f022                	sd	s0,32(sp)
    80001e14:	ec26                	sd	s1,24(sp)
    80001e16:	e84a                	sd	s2,16(sp)
    80001e18:	e44e                	sd	s3,8(sp)
    80001e1a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e1c:	ac9ff0ef          	jal	800018e4 <myproc>
    80001e20:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e22:	d51fe0ef          	jal	80000b72 <holding>
    80001e26:	c92d                	beqz	a0,80001e98 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e28:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e2a:	2781                	sext.w	a5,a5
    80001e2c:	079e                	slli	a5,a5,0x7
    80001e2e:	00011717          	auipc	a4,0x11
    80001e32:	8f270713          	addi	a4,a4,-1806 # 80012720 <pid_lock>
    80001e36:	97ba                	add	a5,a5,a4
    80001e38:	0a87a703          	lw	a4,168(a5)
    80001e3c:	4785                	li	a5,1
    80001e3e:	06f71363          	bne	a4,a5,80001ea4 <sched+0x96>
  if (p->state == RUNNING)
    80001e42:	4c98                	lw	a4,24(s1)
    80001e44:	4791                	li	a5,4
    80001e46:	06f70563          	beq	a4,a5,80001eb0 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e4a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e4e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e50:	e7b5                	bnez	a5,80001ebc <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e52:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e54:	00011917          	auipc	s2,0x11
    80001e58:	8cc90913          	addi	s2,s2,-1844 # 80012720 <pid_lock>
    80001e5c:	2781                	sext.w	a5,a5
    80001e5e:	079e                	slli	a5,a5,0x7
    80001e60:	97ca                	add	a5,a5,s2
    80001e62:	0ac7a983          	lw	s3,172(a5)
    80001e66:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e68:	2781                	sext.w	a5,a5
    80001e6a:	079e                	slli	a5,a5,0x7
    80001e6c:	00011597          	auipc	a1,0x11
    80001e70:	8ec58593          	addi	a1,a1,-1812 # 80012758 <cpus+0x8>
    80001e74:	95be                	add	a1,a1,a5
    80001e76:	06048513          	addi	a0,s1,96
    80001e7a:	690000ef          	jal	8000250a <swtch>
    80001e7e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
    80001e84:	993e                	add	s2,s2,a5
    80001e86:	0b392623          	sw	s3,172(s2)
}
    80001e8a:	70a2                	ld	ra,40(sp)
    80001e8c:	7402                	ld	s0,32(sp)
    80001e8e:	64e2                	ld	s1,24(sp)
    80001e90:	6942                	ld	s2,16(sp)
    80001e92:	69a2                	ld	s3,8(sp)
    80001e94:	6145                	addi	sp,sp,48
    80001e96:	8082                	ret
    panic("sched p->lock");
    80001e98:	00005517          	auipc	a0,0x5
    80001e9c:	2f050513          	addi	a0,a0,752 # 80007188 <etext+0x188>
    80001ea0:	951fe0ef          	jal	800007f0 <panic>
    panic("sched locks");
    80001ea4:	00005517          	auipc	a0,0x5
    80001ea8:	2f450513          	addi	a0,a0,756 # 80007198 <etext+0x198>
    80001eac:	945fe0ef          	jal	800007f0 <panic>
    panic("sched RUNNING");
    80001eb0:	00005517          	auipc	a0,0x5
    80001eb4:	2f850513          	addi	a0,a0,760 # 800071a8 <etext+0x1a8>
    80001eb8:	939fe0ef          	jal	800007f0 <panic>
    panic("sched interruptible");
    80001ebc:	00005517          	auipc	a0,0x5
    80001ec0:	2fc50513          	addi	a0,a0,764 # 800071b8 <etext+0x1b8>
    80001ec4:	92dfe0ef          	jal	800007f0 <panic>

0000000080001ec8 <yield>:
{
    80001ec8:	1101                	addi	sp,sp,-32
    80001eca:	ec06                	sd	ra,24(sp)
    80001ecc:	e822                	sd	s0,16(sp)
    80001ece:	e426                	sd	s1,8(sp)
    80001ed0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ed2:	a13ff0ef          	jal	800018e4 <myproc>
    80001ed6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ed8:	cfbfe0ef          	jal	80000bd2 <acquire>
  p->state = RUNNABLE;
    80001edc:	478d                	li	a5,3
    80001ede:	cc9c                	sw	a5,24(s1)
  sched();
    80001ee0:	f2fff0ef          	jal	80001e0e <sched>
  release(&p->lock);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	d79fe0ef          	jal	80000c5e <release>
}
    80001eea:	60e2                	ld	ra,24(sp)
    80001eec:	6442                	ld	s0,16(sp)
    80001eee:	64a2                	ld	s1,8(sp)
    80001ef0:	6105                	addi	sp,sp,32
    80001ef2:	8082                	ret

0000000080001ef4 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001ef4:	1101                	addi	sp,sp,-32
    80001ef6:	ec06                	sd	ra,24(sp)
    80001ef8:	e822                	sd	s0,16(sp)
    80001efa:	e426                	sd	s1,8(sp)
    80001efc:	e04a                	sd	s2,0(sp)
    80001efe:	1000                	addi	s0,sp,32
    80001f00:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f02:	9e3ff0ef          	jal	800018e4 <myproc>
    80001f06:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f08:	ccbfe0ef          	jal	80000bd2 <acquire>
  if (chan == 0)
    80001f0c:	cc81                	beqz	s1,80001f24 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f0e:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f12:	854a                	mv	a0,s2
    80001f14:	d4bfe0ef          	jal	80000c5e <release>
}
    80001f18:	60e2                	ld	ra,24(sp)
    80001f1a:	6442                	ld	s0,16(sp)
    80001f1c:	64a2                	ld	s1,8(sp)
    80001f1e:	6902                	ld	s2,0(sp)
    80001f20:	6105                	addi	sp,sp,32
    80001f22:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001f24:	00005517          	auipc	a0,0x5
    80001f28:	2ac50513          	addi	a0,a0,684 # 800071d0 <etext+0x1d0>
    80001f2c:	8c5fe0ef          	jal	800007f0 <panic>

0000000080001f30 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001f30:	1101                	addi	sp,sp,-32
    80001f32:	ec06                	sd	ra,24(sp)
    80001f34:	e822                	sd	s0,16(sp)
    80001f36:	e426                	sd	s1,8(sp)
    80001f38:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f3a:	9abff0ef          	jal	800018e4 <myproc>
    80001f3e:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001f40:	c93fe0ef          	jal	80000bd2 <acquire>
  if (p->chan != 0) {
    80001f44:	709c                	ld	a5,32(s1)
    80001f46:	c789                	beqz	a5,80001f50 <sleep+0x20>
    p->state = SLEEPING;
    80001f48:	4789                	li	a5,2
    80001f4a:	cc9c                	sw	a5,24(s1)
    sched();
    80001f4c:	ec3ff0ef          	jal	80001e0e <sched>
  }
  release(&p->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	d0dfe0ef          	jal	80000c5e <release>
}
    80001f56:	60e2                	ld	ra,24(sp)
    80001f58:	6442                	ld	s0,16(sp)
    80001f5a:	64a2                	ld	s1,8(sp)
    80001f5c:	6105                	addi	sp,sp,32
    80001f5e:	8082                	ret

0000000080001f60 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001f60:	7139                	addi	sp,sp,-64
    80001f62:	fc06                	sd	ra,56(sp)
    80001f64:	f822                	sd	s0,48(sp)
    80001f66:	f426                	sd	s1,40(sp)
    80001f68:	f04a                	sd	s2,32(sp)
    80001f6a:	ec4e                	sd	s3,24(sp)
    80001f6c:	e852                	sd	s4,16(sp)
    80001f6e:	e456                	sd	s5,8(sp)
    80001f70:	0080                	addi	s0,sp,64
    80001f72:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f74:	00011497          	auipc	s1,0x11
    80001f78:	bdc48493          	addi	s1,s1,-1060 # 80012b50 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001f7c:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001f7e:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f80:	00016997          	auipc	s3,0x16
    80001f84:	7d098993          	addi	s3,s3,2000 # 80018750 <tickslock>
    80001f88:	a801                	j	80001f98 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	cd3fe0ef          	jal	80000c5e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f90:	17048493          	addi	s1,s1,368
    80001f94:	03348063          	beq	s1,s3,80001fb4 <wakeup+0x54>
    acquire(&p->lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	c39fe0ef          	jal	80000bd2 <acquire>
    if (p->chan == chan) {
    80001f9e:	709c                	ld	a5,32(s1)
    80001fa0:	ff2795e3          	bne	a5,s2,80001f8a <wakeup+0x2a>
      p->chan = 0;
    80001fa4:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80001fa8:	4c9c                	lw	a5,24(s1)
    80001faa:	ff4790e3          	bne	a5,s4,80001f8a <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fae:	0154ac23          	sw	s5,24(s1)
    80001fb2:	bfe1                	j	80001f8a <wakeup+0x2a>
  }
}
    80001fb4:	70e2                	ld	ra,56(sp)
    80001fb6:	7442                	ld	s0,48(sp)
    80001fb8:	74a2                	ld	s1,40(sp)
    80001fba:	7902                	ld	s2,32(sp)
    80001fbc:	69e2                	ld	s3,24(sp)
    80001fbe:	6a42                	ld	s4,16(sp)
    80001fc0:	6aa2                	ld	s5,8(sp)
    80001fc2:	6121                	addi	sp,sp,64
    80001fc4:	8082                	ret

0000000080001fc6 <reparent>:
{
    80001fc6:	7179                	addi	sp,sp,-48
    80001fc8:	f406                	sd	ra,40(sp)
    80001fca:	f022                	sd	s0,32(sp)
    80001fcc:	ec26                	sd	s1,24(sp)
    80001fce:	e84a                	sd	s2,16(sp)
    80001fd0:	e44e                	sd	s3,8(sp)
    80001fd2:	e052                	sd	s4,0(sp)
    80001fd4:	1800                	addi	s0,sp,48
    80001fd6:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001fd8:	00011497          	auipc	s1,0x11
    80001fdc:	b7848493          	addi	s1,s1,-1160 # 80012b50 <proc>
      pp->parent = initproc;
    80001fe0:	00008a17          	auipc	s4,0x8
    80001fe4:	618a0a13          	addi	s4,s4,1560 # 8000a5f8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001fe8:	00016997          	auipc	s3,0x16
    80001fec:	76898993          	addi	s3,s3,1896 # 80018750 <tickslock>
    80001ff0:	a029                	j	80001ffa <reparent+0x34>
    80001ff2:	17048493          	addi	s1,s1,368
    80001ff6:	01348b63          	beq	s1,s3,8000200c <reparent+0x46>
    if (pp->parent == p) {
    80001ffa:	7c9c                	ld	a5,56(s1)
    80001ffc:	ff279be3          	bne	a5,s2,80001ff2 <reparent+0x2c>
      pp->parent = initproc;
    80002000:	000a3503          	ld	a0,0(s4)
    80002004:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002006:	f5bff0ef          	jal	80001f60 <wakeup>
    8000200a:	b7e5                	j	80001ff2 <reparent+0x2c>
}
    8000200c:	70a2                	ld	ra,40(sp)
    8000200e:	7402                	ld	s0,32(sp)
    80002010:	64e2                	ld	s1,24(sp)
    80002012:	6942                	ld	s2,16(sp)
    80002014:	69a2                	ld	s3,8(sp)
    80002016:	6a02                	ld	s4,0(sp)
    80002018:	6145                	addi	sp,sp,48
    8000201a:	8082                	ret

000000008000201c <kexit>:
{
    8000201c:	7179                	addi	sp,sp,-48
    8000201e:	f406                	sd	ra,40(sp)
    80002020:	f022                	sd	s0,32(sp)
    80002022:	ec26                	sd	s1,24(sp)
    80002024:	e84a                	sd	s2,16(sp)
    80002026:	e44e                	sd	s3,8(sp)
    80002028:	e052                	sd	s4,0(sp)
    8000202a:	1800                	addi	s0,sp,48
    8000202c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000202e:	8b7ff0ef          	jal	800018e4 <myproc>
    80002032:	89aa                	mv	s3,a0
  if (p == initproc)
    80002034:	00008797          	auipc	a5,0x8
    80002038:	5c47b783          	ld	a5,1476(a5) # 8000a5f8 <initproc>
    8000203c:	0d050493          	addi	s1,a0,208
    80002040:	15050913          	addi	s2,a0,336
    80002044:	00a79f63          	bne	a5,a0,80002062 <kexit+0x46>
    panic("init exiting");
    80002048:	00005517          	auipc	a0,0x5
    8000204c:	1a850513          	addi	a0,a0,424 # 800071f0 <etext+0x1f0>
    80002050:	fa0fe0ef          	jal	800007f0 <panic>
      fileclose(f);
    80002054:	45a020ef          	jal	800044ae <fileclose>
      p->ofile[fd] = 0;
    80002058:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    8000205c:	04a1                	addi	s1,s1,8
    8000205e:	01248563          	beq	s1,s2,80002068 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002062:	6088                	ld	a0,0(s1)
    80002064:	f965                	bnez	a0,80002054 <kexit+0x38>
    80002066:	bfdd                	j	8000205c <kexit+0x40>
  begin_op();
    80002068:	79b010ef          	jal	80004002 <begin_op>
  iput(p->cwd);
    8000206c:	1509b503          	ld	a0,336(s3)
    80002070:	6cc010ef          	jal	8000373c <iput>
  end_op();
    80002074:	014020ef          	jal	80004088 <end_op>
  p->cwd = 0;
    80002078:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000207c:	00010497          	auipc	s1,0x10
    80002080:	6bc48493          	addi	s1,s1,1724 # 80012738 <wait_lock>
    80002084:	8526                	mv	a0,s1
    80002086:	b4dfe0ef          	jal	80000bd2 <acquire>
  reparent(p);
    8000208a:	854e                	mv	a0,s3
    8000208c:	f3bff0ef          	jal	80001fc6 <reparent>
  wakeup(p->parent);
    80002090:	0389b503          	ld	a0,56(s3)
    80002094:	ecdff0ef          	jal	80001f60 <wakeup>
  acquire(&p->lock);
    80002098:	854e                	mv	a0,s3
    8000209a:	b39fe0ef          	jal	80000bd2 <acquire>
  p->xstate = status;
    8000209e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020a2:	4795                	li	a5,5
    800020a4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020a8:	8526                	mv	a0,s1
    800020aa:	bb5fe0ef          	jal	80000c5e <release>
  sched();
    800020ae:	d61ff0ef          	jal	80001e0e <sched>
  panic("zombie exit");
    800020b2:	00005517          	auipc	a0,0x5
    800020b6:	14e50513          	addi	a0,a0,334 # 80007200 <etext+0x200>
    800020ba:	f36fe0ef          	jal	800007f0 <panic>

00000000800020be <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800020be:	c525                	beqz	a0,80002126 <kkill+0x68>
{
    800020c0:	7179                	addi	sp,sp,-48
    800020c2:	f406                	sd	ra,40(sp)
    800020c4:	f022                	sd	s0,32(sp)
    800020c6:	ec26                	sd	s1,24(sp)
    800020c8:	e84a                	sd	s2,16(sp)
    800020ca:	e44e                	sd	s3,8(sp)
    800020cc:	1800                	addi	s0,sp,48
    800020ce:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020d0:	00011497          	auipc	s1,0x11
    800020d4:	a8048493          	addi	s1,s1,-1408 # 80012b50 <proc>
    800020d8:	00016997          	auipc	s3,0x16
    800020dc:	67898993          	addi	s3,s3,1656 # 80018750 <tickslock>
    acquire(&p->lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	af1fe0ef          	jal	80000bd2 <acquire>
    if (p->pid == pid) {
    800020e6:	589c                	lw	a5,48(s1)
    800020e8:	01278b63          	beq	a5,s2,800020fe <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	b71fe0ef          	jal	80000c5e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020f2:	17048493          	addi	s1,s1,368
    800020f6:	ff3495e3          	bne	s1,s3,800020e0 <kkill+0x22>
  }
  return -1;
    800020fa:	557d                	li	a0,-1
    800020fc:	a819                	j	80002112 <kkill+0x54>
      p->killed = 1;
    800020fe:	4785                	li	a5,1
    80002100:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002102:	4c98                	lw	a4,24(s1)
    80002104:	4789                	li	a5,2
    80002106:	00f70d63          	beq	a4,a5,80002120 <kkill+0x62>
      release(&p->lock);
    8000210a:	8526                	mv	a0,s1
    8000210c:	b53fe0ef          	jal	80000c5e <release>
      return 0;
    80002110:	4501                	li	a0,0
}
    80002112:	70a2                	ld	ra,40(sp)
    80002114:	7402                	ld	s0,32(sp)
    80002116:	64e2                	ld	s1,24(sp)
    80002118:	6942                	ld	s2,16(sp)
    8000211a:	69a2                	ld	s3,8(sp)
    8000211c:	6145                	addi	sp,sp,48
    8000211e:	8082                	ret
        p->state = RUNNABLE;
    80002120:	478d                	li	a5,3
    80002122:	cc9c                	sw	a5,24(s1)
    80002124:	b7dd                	j	8000210a <kkill+0x4c>
    return -1;
    80002126:	557d                	li	a0,-1
}
    80002128:	8082                	ret

000000008000212a <setkilled>:

void
setkilled(struct proc *p)
{
    8000212a:	1101                	addi	sp,sp,-32
    8000212c:	ec06                	sd	ra,24(sp)
    8000212e:	e822                	sd	s0,16(sp)
    80002130:	e426                	sd	s1,8(sp)
    80002132:	1000                	addi	s0,sp,32
    80002134:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002136:	a9dfe0ef          	jal	80000bd2 <acquire>
  p->killed = 1;
    8000213a:	4785                	li	a5,1
    8000213c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	b1ffe0ef          	jal	80000c5e <release>
}
    80002144:	60e2                	ld	ra,24(sp)
    80002146:	6442                	ld	s0,16(sp)
    80002148:	64a2                	ld	s1,8(sp)
    8000214a:	6105                	addi	sp,sp,32
    8000214c:	8082                	ret

000000008000214e <killed>:

int
killed(struct proc *p)
{
    8000214e:	1101                	addi	sp,sp,-32
    80002150:	ec06                	sd	ra,24(sp)
    80002152:	e822                	sd	s0,16(sp)
    80002154:	e426                	sd	s1,8(sp)
    80002156:	e04a                	sd	s2,0(sp)
    80002158:	1000                	addi	s0,sp,32
    8000215a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000215c:	a77fe0ef          	jal	80000bd2 <acquire>
  k = p->killed;
    80002160:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	af9fe0ef          	jal	80000c5e <release>
  return k;
}
    8000216a:	854a                	mv	a0,s2
    8000216c:	60e2                	ld	ra,24(sp)
    8000216e:	6442                	ld	s0,16(sp)
    80002170:	64a2                	ld	s1,8(sp)
    80002172:	6902                	ld	s2,0(sp)
    80002174:	6105                	addi	sp,sp,32
    80002176:	8082                	ret

0000000080002178 <kwait>:
{
    80002178:	715d                	addi	sp,sp,-80
    8000217a:	e486                	sd	ra,72(sp)
    8000217c:	e0a2                	sd	s0,64(sp)
    8000217e:	fc26                	sd	s1,56(sp)
    80002180:	f84a                	sd	s2,48(sp)
    80002182:	f44e                	sd	s3,40(sp)
    80002184:	f052                	sd	s4,32(sp)
    80002186:	ec56                	sd	s5,24(sp)
    80002188:	e85a                	sd	s6,16(sp)
    8000218a:	e45e                	sd	s7,8(sp)
    8000218c:	e062                	sd	s8,0(sp)
    8000218e:	0880                	addi	s0,sp,80
    80002190:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002192:	f52ff0ef          	jal	800018e4 <myproc>
    80002196:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002198:	00010517          	auipc	a0,0x10
    8000219c:	5a050513          	addi	a0,a0,1440 # 80012738 <wait_lock>
    800021a0:	a33fe0ef          	jal	80000bd2 <acquire>
    havekids = 0;
    800021a4:	4c01                	li	s8,0
        if (pp->state == ZOMBIE) {
    800021a6:	4a15                	li	s4,5
        havekids = 1;
    800021a8:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021aa:	00016997          	auipc	s3,0x16
    800021ae:	5a698993          	addi	s3,s3,1446 # 80018750 <tickslock>
    release(&wait_lock);
    800021b2:	00010b97          	auipc	s7,0x10
    800021b6:	586b8b93          	addi	s7,s7,1414 # 80012738 <wait_lock>
    800021ba:	a84d                	j	8000226c <kwait+0xf4>
          pid = pp->pid;
    800021bc:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800021c0:	000b0e63          	beqz	s6,800021dc <kwait+0x64>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800021c4:	4711                	li	a4,4
    800021c6:	02c48693          	addi	a3,s1,44
    800021ca:	865a                	mv	a2,s6
    800021cc:	04893583          	ld	a1,72(s2)
    800021d0:	05093503          	ld	a0,80(s2)
    800021d4:	b46ff0ef          	jal	8000151a <copyout>
          if (addr != 0 &&
    800021d8:	02054d63          	bltz	a0,80002212 <kwait+0x9a>
          pp->parent = 0;
    800021dc:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800021e0:	8526                	mv	a0,s1
    800021e2:	8cfff0ef          	jal	80001ab0 <freeproc>
          release(&pp->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	a77fe0ef          	jal	80000c5e <release>
          release(&wait_lock);
    800021ec:	00010517          	auipc	a0,0x10
    800021f0:	54c50513          	addi	a0,a0,1356 # 80012738 <wait_lock>
    800021f4:	a6bfe0ef          	jal	80000c5e <release>
}
    800021f8:	854e                	mv	a0,s3
    800021fa:	60a6                	ld	ra,72(sp)
    800021fc:	6406                	ld	s0,64(sp)
    800021fe:	74e2                	ld	s1,56(sp)
    80002200:	7942                	ld	s2,48(sp)
    80002202:	79a2                	ld	s3,40(sp)
    80002204:	7a02                	ld	s4,32(sp)
    80002206:	6ae2                	ld	s5,24(sp)
    80002208:	6b42                	ld	s6,16(sp)
    8000220a:	6ba2                	ld	s7,8(sp)
    8000220c:	6c02                	ld	s8,0(sp)
    8000220e:	6161                	addi	sp,sp,80
    80002210:	8082                	ret
            release(&pp->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	a4bfe0ef          	jal	80000c5e <release>
            release(&wait_lock);
    80002218:	00010517          	auipc	a0,0x10
    8000221c:	52050513          	addi	a0,a0,1312 # 80012738 <wait_lock>
    80002220:	a3ffe0ef          	jal	80000c5e <release>
            return -1;
    80002224:	59fd                	li	s3,-1
    80002226:	bfc9                	j	800021f8 <kwait+0x80>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002228:	17048493          	addi	s1,s1,368
    8000222c:	03348063          	beq	s1,s3,8000224c <kwait+0xd4>
      if (pp->parent == p) {
    80002230:	7c9c                	ld	a5,56(s1)
    80002232:	ff279be3          	bne	a5,s2,80002228 <kwait+0xb0>
        acquire(&pp->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	99bfe0ef          	jal	80000bd2 <acquire>
        if (pp->state == ZOMBIE) {
    8000223c:	4c9c                	lw	a5,24(s1)
    8000223e:	f7478fe3          	beq	a5,s4,800021bc <kwait+0x44>
        release(&pp->lock);
    80002242:	8526                	mv	a0,s1
    80002244:	a1bfe0ef          	jal	80000c5e <release>
        havekids = 1;
    80002248:	8756                	mv	a4,s5
    8000224a:	bff9                	j	80002228 <kwait+0xb0>
    if (!havekids || killed(p)) {
    8000224c:	c715                	beqz	a4,80002278 <kwait+0x100>
    8000224e:	854a                	mv	a0,s2
    80002250:	effff0ef          	jal	8000214e <killed>
    80002254:	e115                	bnez	a0,80002278 <kwait+0x100>
    sleep_prepare(p); //DOC: wait-sleep
    80002256:	854a                	mv	a0,s2
    80002258:	c9dff0ef          	jal	80001ef4 <sleep_prepare>
    release(&wait_lock);
    8000225c:	855e                	mv	a0,s7
    8000225e:	a01fe0ef          	jal	80000c5e <release>
    sleep();
    80002262:	ccfff0ef          	jal	80001f30 <sleep>
    acquire(&wait_lock);
    80002266:	855e                	mv	a0,s7
    80002268:	96bfe0ef          	jal	80000bd2 <acquire>
    havekids = 0;
    8000226c:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000226e:	00011497          	auipc	s1,0x11
    80002272:	8e248493          	addi	s1,s1,-1822 # 80012b50 <proc>
    80002276:	bf6d                	j	80002230 <kwait+0xb8>
      release(&wait_lock);
    80002278:	00010517          	auipc	a0,0x10
    8000227c:	4c050513          	addi	a0,a0,1216 # 80012738 <wait_lock>
    80002280:	9dffe0ef          	jal	80000c5e <release>
      return -1;
    80002284:	59fd                	li	s3,-1
    80002286:	bf8d                	j	800021f8 <kwait+0x80>

0000000080002288 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	e052                	sd	s4,0(sp)
    80002296:	1800                	addi	s0,sp,48
    80002298:	84aa                	mv	s1,a0
    8000229a:	892e                	mv	s2,a1
    8000229c:	89b2                	mv	s3,a2
    8000229e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a0:	e44ff0ef          	jal	800018e4 <myproc>
  if (user_dst) {
    800022a4:	c085                	beqz	s1,800022c4 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800022a6:	8752                	mv	a4,s4
    800022a8:	86ce                	mv	a3,s3
    800022aa:	864a                	mv	a2,s2
    800022ac:	652c                	ld	a1,72(a0)
    800022ae:	6928                	ld	a0,80(a0)
    800022b0:	a6aff0ef          	jal	8000151a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022b4:	70a2                	ld	ra,40(sp)
    800022b6:	7402                	ld	s0,32(sp)
    800022b8:	64e2                	ld	s1,24(sp)
    800022ba:	6942                	ld	s2,16(sp)
    800022bc:	69a2                	ld	s3,8(sp)
    800022be:	6a02                	ld	s4,0(sp)
    800022c0:	6145                	addi	sp,sp,48
    800022c2:	8082                	ret
    memmove((char *)dst, src, len);
    800022c4:	000a061b          	sext.w	a2,s4
    800022c8:	85ce                	mv	a1,s3
    800022ca:	854a                	mv	a0,s2
    800022cc:	a27fe0ef          	jal	80000cf2 <memmove>
    return 0;
    800022d0:	8526                	mv	a0,s1
    800022d2:	b7cd                	j	800022b4 <either_copyout+0x2c>

00000000800022d4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022d4:	7179                	addi	sp,sp,-48
    800022d6:	f406                	sd	ra,40(sp)
    800022d8:	f022                	sd	s0,32(sp)
    800022da:	ec26                	sd	s1,24(sp)
    800022dc:	e84a                	sd	s2,16(sp)
    800022de:	e44e                	sd	s3,8(sp)
    800022e0:	e052                	sd	s4,0(sp)
    800022e2:	1800                	addi	s0,sp,48
    800022e4:	892a                	mv	s2,a0
    800022e6:	84ae                	mv	s1,a1
    800022e8:	89b2                	mv	s3,a2
    800022ea:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ec:	df8ff0ef          	jal	800018e4 <myproc>
  if (user_src) {
    800022f0:	c085                	beqz	s1,80002310 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800022f2:	8752                	mv	a4,s4
    800022f4:	86ce                	mv	a3,s3
    800022f6:	864a                	mv	a2,s2
    800022f8:	652c                	ld	a1,72(a0)
    800022fa:	6928                	ld	a0,80(a0)
    800022fc:	b0aff0ef          	jal	80001606 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002300:	70a2                	ld	ra,40(sp)
    80002302:	7402                	ld	s0,32(sp)
    80002304:	64e2                	ld	s1,24(sp)
    80002306:	6942                	ld	s2,16(sp)
    80002308:	69a2                	ld	s3,8(sp)
    8000230a:	6a02                	ld	s4,0(sp)
    8000230c:	6145                	addi	sp,sp,48
    8000230e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002310:	000a061b          	sext.w	a2,s4
    80002314:	85ce                	mv	a1,s3
    80002316:	854a                	mv	a0,s2
    80002318:	9dbfe0ef          	jal	80000cf2 <memmove>
    return 0;
    8000231c:	8526                	mv	a0,s1
    8000231e:	b7cd                	j	80002300 <either_copyin+0x2c>

0000000080002320 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002320:	715d                	addi	sp,sp,-80
    80002322:	e486                	sd	ra,72(sp)
    80002324:	e0a2                	sd	s0,64(sp)
    80002326:	fc26                	sd	s1,56(sp)
    80002328:	f84a                	sd	s2,48(sp)
    8000232a:	f44e                	sd	s3,40(sp)
    8000232c:	f052                	sd	s4,32(sp)
    8000232e:	ec56                	sd	s5,24(sp)
    80002330:	e85a                	sd	s6,16(sp)
    80002332:	e45e                	sd	s7,8(sp)
    80002334:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002336:	00005517          	auipc	a0,0x5
    8000233a:	d6250513          	addi	a0,a0,-670 # 80007098 <etext+0x98>
    8000233e:	9ccfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002342:	00011497          	auipc	s1,0x11
    80002346:	96a48493          	addi	s1,s1,-1686 # 80012cac <proc+0x15c>
    8000234a:	00016917          	auipc	s2,0x16
    8000234e:	56290913          	addi	s2,s2,1378 # 800188ac <bcache+0x144>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002352:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002354:	00005997          	auipc	s3,0x5
    80002358:	ebc98993          	addi	s3,s3,-324 # 80007210 <etext+0x210>
    printk("%d %s %s", p->pid, state, p->name);
    8000235c:	00005a97          	auipc	s5,0x5
    80002360:	ebca8a93          	addi	s5,s5,-324 # 80007218 <etext+0x218>
    printk("\n");
    80002364:	00005a17          	auipc	s4,0x5
    80002368:	d34a0a13          	addi	s4,s4,-716 # 80007098 <etext+0x98>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000236c:	00005b97          	auipc	s7,0x5
    80002370:	4fcb8b93          	addi	s7,s7,1276 # 80007868 <states.0>
    80002374:	a829                	j	8000238e <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002376:	ed46a583          	lw	a1,-300(a3)
    8000237a:	8556                	mv	a0,s5
    8000237c:	98efe0ef          	jal	8000050a <printk>
    printk("\n");
    80002380:	8552                	mv	a0,s4
    80002382:	988fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002386:	17048493          	addi	s1,s1,368
    8000238a:	03248263          	beq	s1,s2,800023ae <procdump+0x8e>
    if (p->state == UNUSED)
    8000238e:	86a6                	mv	a3,s1
    80002390:	ebc4a783          	lw	a5,-324(s1)
    80002394:	dbed                	beqz	a5,80002386 <procdump+0x66>
      state = "???";
    80002396:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002398:	fcfb6fe3          	bltu	s6,a5,80002376 <procdump+0x56>
    8000239c:	02079713          	slli	a4,a5,0x20
    800023a0:	01d75793          	srli	a5,a4,0x1d
    800023a4:	97de                	add	a5,a5,s7
    800023a6:	6390                	ld	a2,0(a5)
    800023a8:	f679                	bnez	a2,80002376 <procdump+0x56>
      state = "???";
    800023aa:	864e                	mv	a2,s3
    800023ac:	b7e9                	j	80002376 <procdump+0x56>
  }
}
    800023ae:	60a6                	ld	ra,72(sp)
    800023b0:	6406                	ld	s0,64(sp)
    800023b2:	74e2                	ld	s1,56(sp)
    800023b4:	7942                	ld	s2,48(sp)
    800023b6:	79a2                	ld	s3,40(sp)
    800023b8:	7a02                	ld	s4,32(sp)
    800023ba:	6ae2                	ld	s5,24(sp)
    800023bc:	6b42                	ld	s6,16(sp)
    800023be:	6ba2                	ld	s7,8(sp)
    800023c0:	6161                	addi	sp,sp,80
    800023c2:	8082                	ret

00000000800023c4 <count_active_procs>:

uint64
count_active_procs(void)
{
    800023c4:	1141                	addi	sp,sp,-16
    800023c6:	e422                	sd	s0,8(sp)
    800023c8:	0800                	addi	s0,sp,16
  struct proc *p;
  uint64 count = 0;
    800023ca:	4501                	li	a0,0

  for(p = proc; p < &proc[NPROC]; p++) {
    800023cc:	00010797          	auipc	a5,0x10
    800023d0:	78478793          	addi	a5,a5,1924 # 80012b50 <proc>
    800023d4:	00016697          	auipc	a3,0x16
    800023d8:	37c68693          	addi	a3,a3,892 # 80018750 <tickslock>
    // No lock is strictly required for an approximate active count here,
    // but we check if the state is not UNUSED.
    if(p->state != UNUSED) {
    800023dc:	4f98                	lw	a4,24(a5)
      count++;
    800023de:	00e03733          	snez	a4,a4
    800023e2:	953a                	add	a0,a0,a4
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e4:	17078793          	addi	a5,a5,368
    800023e8:	fed79ae3          	bne	a5,a3,800023dc <count_active_procs+0x18>
    }
  }
  return count;
}
    800023ec:	6422                	ld	s0,8(sp)
    800023ee:	0141                	addi	sp,sp,16
    800023f0:	8082                	ret

00000000800023f2 <get_uprocs>:

int
get_uprocs(uint64 buf_addr, int max)
{
    800023f2:	7119                	addi	sp,sp,-128
    800023f4:	fc86                	sd	ra,120(sp)
    800023f6:	f8a2                	sd	s0,112(sp)
    800023f8:	f0ca                	sd	s2,96(sp)
    800023fa:	ecce                	sd	s3,88(sp)
    800023fc:	e4d6                	sd	s5,72(sp)
    800023fe:	0100                	addi	s0,sp,128
    80002400:	8aaa                	mv	s5,a0
    80002402:	89ae                	mv	s3,a1
  struct proc *p;
  struct proc *my_p = myproc();
    80002404:	ce0ff0ef          	jal	800018e4 <myproc>
  struct uproc uptr;
  int count = 0;

  if (max < 0) return -1;
    80002408:	0e09c863          	bltz	s3,800024f8 <get_uprocs+0x106>
    8000240c:	f4a6                	sd	s1,104(sp)
    8000240e:	e8d2                	sd	s4,80(sp)
    80002410:	e0da                	sd	s6,64(sp)
    80002412:	fc5e                	sd	s7,56(sp)
    80002414:	f862                	sd	s8,48(sp)
    80002416:	8a2a                	mv	s4,a0

  // 1. Acquire wait_lock first per instructions
  acquire(&wait_lock);
    80002418:	00010517          	auipc	a0,0x10
    8000241c:	32050513          	addi	a0,a0,800 # 80012738 <wait_lock>
    80002420:	fb2fe0ef          	jal	80000bd2 <acquire>
  int count = 0;
    80002424:	4901                	li	s2,0

  for(p = proc; p < &proc[NPROC]; p++) {
    80002426:	00010497          	auipc	s1,0x10
    8000242a:	72a48493          	addi	s1,s1,1834 # 80012b50 <proc>
    // 2. Lock the individual process state
    acquire(&p->lock);

    if(p->state != UNUSED) {
      uptr.pid = p->pid;
      uptr.ppid = p->parent ? p->parent->pid : 0;
    8000242e:	4b81                	li	s7,0
      uptr.sz = p->sz;
      safestrcpy(uptr.name, p->name, sizeof(p->name));

      // Release locks before copying data to user space
      release(&p->lock);
      release(&wait_lock);
    80002430:	00010b17          	auipc	s6,0x10
    80002434:	308b0b13          	addi	s6,s6,776 # 80012738 <wait_lock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002438:	00016c17          	auipc	s8,0x16
    8000243c:	318c0c13          	addi	s8,s8,792 # 80018750 <tickslock>
    80002440:	a839                	j	8000245e <get_uprocs+0x6c>
      if(count >= max) {
        return count; 
      }

      // Re-acquire locks to safely inspect the next process entry in the table
      acquire(&wait_lock);
    80002442:	00010517          	auipc	a0,0x10
    80002446:	2f650513          	addi	a0,a0,758 # 80012738 <wait_lock>
    8000244a:	f88fe0ef          	jal	80000bd2 <acquire>
      continue;
    8000244e:	a021                	j	80002456 <get_uprocs+0x64>
    }
    release(&p->lock);
    80002450:	8526                	mv	a0,s1
    80002452:	80dfe0ef          	jal	80000c5e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002456:	17048493          	addi	s1,s1,368
    8000245a:	09848363          	beq	s1,s8,800024e0 <get_uprocs+0xee>
    acquire(&p->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	f72fe0ef          	jal	80000bd2 <acquire>
    if(p->state != UNUSED) {
    80002464:	4c9c                	lw	a5,24(s1)
    80002466:	d7ed                	beqz	a5,80002450 <get_uprocs+0x5e>
      uptr.pid = p->pid;
    80002468:	5898                	lw	a4,48(s1)
    8000246a:	f8e42423          	sw	a4,-120(s0)
      uptr.ppid = p->parent ? p->parent->pid : 0;
    8000246e:	7c94                	ld	a3,56(s1)
    80002470:	875e                	mv	a4,s7
    80002472:	c291                	beqz	a3,80002476 <get_uprocs+0x84>
    80002474:	5a98                	lw	a4,48(a3)
    80002476:	f8e42623          	sw	a4,-116(s0)
      uptr.state = p->state;
    8000247a:	f8f42823          	sw	a5,-112(s0)
      uptr.sz = p->sz;
    8000247e:	64bc                	ld	a5,72(s1)
    80002480:	f8f43c23          	sd	a5,-104(s0)
      safestrcpy(uptr.name, p->name, sizeof(p->name));
    80002484:	4641                	li	a2,16
    80002486:	15c48593          	addi	a1,s1,348
    8000248a:	fa040513          	addi	a0,s0,-96
    8000248e:	947fe0ef          	jal	80000dd4 <safestrcpy>
      release(&p->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	fcafe0ef          	jal	80000c5e <release>
      release(&wait_lock);
    80002498:	855a                	mv	a0,s6
    8000249a:	fc4fe0ef          	jal	80000c5e <release>
      uint64 dst_element_addr = buf_addr + (count * sizeof(struct uproc));
    8000249e:	00291613          	slli	a2,s2,0x2
    800024a2:	964a                	add	a2,a2,s2
    800024a4:	060e                	slli	a2,a2,0x3
    800024a6:	015605b3          	add	a1,a2,s5
      if(copyout(my_p->pagetable, dst_element_addr, dst_element_addr, (char *)&uptr, sizeof(struct uproc)) < 0) {
    800024aa:	02800713          	li	a4,40
    800024ae:	f8840693          	addi	a3,s0,-120
    800024b2:	862e                	mv	a2,a1
    800024b4:	050a3503          	ld	a0,80(s4)
    800024b8:	862ff0ef          	jal	8000151a <copyout>
    800024bc:	04054063          	bltz	a0,800024fc <get_uprocs+0x10a>
      count++;
    800024c0:	2905                	addiw	s2,s2,1
      if(count >= max) {
    800024c2:	f93940e3          	blt	s2,s3,80002442 <get_uprocs+0x50>
    800024c6:	74a6                	ld	s1,104(sp)
    800024c8:	6a46                	ld	s4,80(sp)
    800024ca:	6b06                	ld	s6,64(sp)
    800024cc:	7be2                	ld	s7,56(sp)
    800024ce:	7c42                	ld	s8,48(sp)
  }
  
  release(&wait_lock);
  return count;
}
    800024d0:	854a                	mv	a0,s2
    800024d2:	70e6                	ld	ra,120(sp)
    800024d4:	7446                	ld	s0,112(sp)
    800024d6:	7906                	ld	s2,96(sp)
    800024d8:	69e6                	ld	s3,88(sp)
    800024da:	6aa6                	ld	s5,72(sp)
    800024dc:	6109                	addi	sp,sp,128
    800024de:	8082                	ret
  release(&wait_lock);
    800024e0:	00010517          	auipc	a0,0x10
    800024e4:	25850513          	addi	a0,a0,600 # 80012738 <wait_lock>
    800024e8:	f76fe0ef          	jal	80000c5e <release>
  return count;
    800024ec:	74a6                	ld	s1,104(sp)
    800024ee:	6a46                	ld	s4,80(sp)
    800024f0:	6b06                	ld	s6,64(sp)
    800024f2:	7be2                	ld	s7,56(sp)
    800024f4:	7c42                	ld	s8,48(sp)
    800024f6:	bfe9                	j	800024d0 <get_uprocs+0xde>
  if (max < 0) return -1;
    800024f8:	597d                	li	s2,-1
    800024fa:	bfd9                	j	800024d0 <get_uprocs+0xde>
        return -1;
    800024fc:	597d                	li	s2,-1
    800024fe:	74a6                	ld	s1,104(sp)
    80002500:	6a46                	ld	s4,80(sp)
    80002502:	6b06                	ld	s6,64(sp)
    80002504:	7be2                	ld	s7,56(sp)
    80002506:	7c42                	ld	s8,48(sp)
    80002508:	b7e1                	j	800024d0 <get_uprocs+0xde>

000000008000250a <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000250a:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000250e:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002512:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002514:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002516:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000251a:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000251e:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002522:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002526:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000252a:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000252e:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002532:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002536:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000253a:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000253e:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002542:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002546:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002548:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000254a:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000254e:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002552:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002556:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000255a:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000255e:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002562:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002566:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000256a:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000256e:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002572:	8082                	ret

0000000080002574 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002574:	1141                	addi	sp,sp,-16
    80002576:	e406                	sd	ra,8(sp)
    80002578:	e022                	sd	s0,0(sp)
    8000257a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000257c:	00005597          	auipc	a1,0x5
    80002580:	cdc58593          	addi	a1,a1,-804 # 80007258 <etext+0x258>
    80002584:	00016517          	auipc	a0,0x16
    80002588:	1cc50513          	addi	a0,a0,460 # 80018750 <tickslock>
    8000258c:	dd0fe0ef          	jal	80000b5c <initlock>
}
    80002590:	60a2                	ld	ra,8(sp)
    80002592:	6402                	ld	s0,0(sp)
    80002594:	0141                	addi	sp,sp,16
    80002596:	8082                	ret

0000000080002598 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002598:	1141                	addi	sp,sp,-16
    8000259a:	e422                	sd	s0,8(sp)
    8000259c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000259e:	00003797          	auipc	a5,0x3
    800025a2:	3a278793          	addi	a5,a5,930 # 80005940 <kernelvec>
    800025a6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800025aa:	6422                	ld	s0,8(sp)
    800025ac:	0141                	addi	sp,sp,16
    800025ae:	8082                	ret

00000000800025b0 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800025b0:	1141                	addi	sp,sp,-16
    800025b2:	e406                	sd	ra,8(sp)
    800025b4:	e022                	sd	s0,0(sp)
    800025b6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800025b8:	b2cff0ef          	jal	800018e4 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800025bc:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800025c0:	04000737          	lui	a4,0x4000
    800025c4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800025c6:	0732                	slli	a4,a4,0xc
    800025c8:	00004797          	auipc	a5,0x4
    800025cc:	a3878793          	addi	a5,a5,-1480 # 80006000 <_trampoline>
    800025d0:	00004697          	auipc	a3,0x4
    800025d4:	a3068693          	addi	a3,a3,-1488 # 80006000 <_trampoline>
    800025d8:	8f95                	sub	a5,a5,a3
    800025da:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025dc:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800025e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800025e2:	18002773          	csrr	a4,satp
    800025e6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025e8:	6d38                	ld	a4,88(a0)
    800025ea:	613c                	ld	a5,64(a0)
    800025ec:	6685                	lui	a3,0x1
    800025ee:	97b6                	add	a5,a5,a3
    800025f0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025f2:	6d3c                	ld	a5,88(a0)
    800025f4:	00000717          	auipc	a4,0x0
    800025f8:	0f870713          	addi	a4,a4,248 # 800026ec <usertrap>
    800025fc:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800025fe:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002600:	8712                	mv	a4,tp
    80002602:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002604:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002608:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000260c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002610:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002614:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002616:	6f9c                	ld	a5,24(a5)
    80002618:	14179073          	csrw	sepc,a5
}
    8000261c:	60a2                	ld	ra,8(sp)
    8000261e:	6402                	ld	s0,0(sp)
    80002620:	0141                	addi	sp,sp,16
    80002622:	8082                	ret

0000000080002624 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002624:	1101                	addi	sp,sp,-32
    80002626:	ec06                	sd	ra,24(sp)
    80002628:	e822                	sd	s0,16(sp)
    8000262a:	1000                	addi	s0,sp,32
  if (cpuid() == 0) {
    8000262c:	a8cff0ef          	jal	800018b8 <cpuid>
    80002630:	cd11                	beqz	a0,8000264c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002632:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002636:	000f4737          	lui	a4,0xf4
    8000263a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000263e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002640:	14d79073          	csrw	stimecmp,a5
}
    80002644:	60e2                	ld	ra,24(sp)
    80002646:	6442                	ld	s0,16(sp)
    80002648:	6105                	addi	sp,sp,32
    8000264a:	8082                	ret
    8000264c:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000264e:	00016497          	auipc	s1,0x16
    80002652:	10248493          	addi	s1,s1,258 # 80018750 <tickslock>
    80002656:	8526                	mv	a0,s1
    80002658:	d7afe0ef          	jal	80000bd2 <acquire>
    ticks++;
    8000265c:	00008517          	auipc	a0,0x8
    80002660:	fa450513          	addi	a0,a0,-92 # 8000a600 <ticks>
    80002664:	411c                	lw	a5,0(a0)
    80002666:	2785                	addiw	a5,a5,1
    80002668:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000266a:	8f7ff0ef          	jal	80001f60 <wakeup>
    release(&tickslock);
    8000266e:	8526                	mv	a0,s1
    80002670:	deefe0ef          	jal	80000c5e <release>
    80002674:	64a2                	ld	s1,8(sp)
    80002676:	bf75                	j	80002632 <clockintr+0xe>

0000000080002678 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002678:	1101                	addi	sp,sp,-32
    8000267a:	ec06                	sd	ra,24(sp)
    8000267c:	e822                	sd	s0,16(sp)
    8000267e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002680:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002684:	57fd                	li	a5,-1
    80002686:	17fe                	slli	a5,a5,0x3f
    80002688:	07a5                	addi	a5,a5,9
    8000268a:	00f70c63          	beq	a4,a5,800026a2 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000268e:	57fd                	li	a5,-1
    80002690:	17fe                	slli	a5,a5,0x3f
    80002692:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002694:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002696:	04f70763          	beq	a4,a5,800026e4 <devintr+0x6c>
  }
}
    8000269a:	60e2                	ld	ra,24(sp)
    8000269c:	6442                	ld	s0,16(sp)
    8000269e:	6105                	addi	sp,sp,32
    800026a0:	8082                	ret
    800026a2:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800026a4:	348030ef          	jal	800059ec <plic_claim>
    800026a8:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800026aa:	47a9                	li	a5,10
    800026ac:	00f50963          	beq	a0,a5,800026be <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    800026b0:	4785                	li	a5,1
    800026b2:	00f50963          	beq	a0,a5,800026c4 <devintr+0x4c>
    return 1;
    800026b6:	4505                	li	a0,1
    } else if (irq) {
    800026b8:	e889                	bnez	s1,800026ca <devintr+0x52>
    800026ba:	64a2                	ld	s1,8(sp)
    800026bc:	bff9                	j	8000269a <devintr+0x22>
      uartintr();
    800026be:	acefe0ef          	jal	8000098c <uartintr>
    if (irq)
    800026c2:	a819                	j	800026d8 <devintr+0x60>
      virtio_disk_intr();
    800026c4:	00d030ef          	jal	80005ed0 <virtio_disk_intr>
    if (irq)
    800026c8:	a801                	j	800026d8 <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    800026ca:	85a6                	mv	a1,s1
    800026cc:	00005517          	auipc	a0,0x5
    800026d0:	b9450513          	addi	a0,a0,-1132 # 80007260 <etext+0x260>
    800026d4:	e37fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800026d8:	8526                	mv	a0,s1
    800026da:	332030ef          	jal	80005a0c <plic_complete>
    return 1;
    800026de:	4505                	li	a0,1
    800026e0:	64a2                	ld	s1,8(sp)
    800026e2:	bf65                	j	8000269a <devintr+0x22>
    clockintr();
    800026e4:	f41ff0ef          	jal	80002624 <clockintr>
    return 2;
    800026e8:	4509                	li	a0,2
    800026ea:	bf45                	j	8000269a <devintr+0x22>

00000000800026ec <usertrap>:
{
    800026ec:	1101                	addi	sp,sp,-32
    800026ee:	ec06                	sd	ra,24(sp)
    800026f0:	e822                	sd	s0,16(sp)
    800026f2:	e426                	sd	s1,8(sp)
    800026f4:	e04a                	sd	s2,0(sp)
    800026f6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026f8:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800026fc:	1007f793          	andi	a5,a5,256
    80002700:	eba5                	bnez	a5,80002770 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002702:	00003797          	auipc	a5,0x3
    80002706:	23e78793          	addi	a5,a5,574 # 80005940 <kernelvec>
    8000270a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000270e:	9d6ff0ef          	jal	800018e4 <myproc>
    80002712:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002714:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002716:	14102773          	csrr	a4,sepc
    8000271a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000271c:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002720:	47a1                	li	a5,8
    80002722:	04f70d63          	beq	a4,a5,8000277c <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002726:	f53ff0ef          	jal	80002678 <devintr>
    8000272a:	892a                	mv	s2,a0
    8000272c:	e54d                	bnez	a0,800027d6 <usertrap+0xea>
    8000272e:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002732:	47bd                	li	a5,15
    80002734:	08f70463          	beq	a4,a5,800027bc <usertrap+0xd0>
    80002738:	14202773          	csrr	a4,scause
    8000273c:	47b5                	li	a5,13
    8000273e:	06f70f63          	beq	a4,a5,800027bc <usertrap+0xd0>
    80002742:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002746:	5890                	lw	a2,48(s1)
    80002748:	00005517          	auipc	a0,0x5
    8000274c:	b5850513          	addi	a0,a0,-1192 # 800072a0 <etext+0x2a0>
    80002750:	dbbfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002754:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002758:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000275c:	00005517          	auipc	a0,0x5
    80002760:	b7450513          	addi	a0,a0,-1164 # 800072d0 <etext+0x2d0>
    80002764:	da7fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002768:	8526                	mv	a0,s1
    8000276a:	9c1ff0ef          	jal	8000212a <setkilled>
    8000276e:	a015                	j	80002792 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002770:	00005517          	auipc	a0,0x5
    80002774:	b1050513          	addi	a0,a0,-1264 # 80007280 <etext+0x280>
    80002778:	878fe0ef          	jal	800007f0 <panic>
    if (killed(p))
    8000277c:	9d3ff0ef          	jal	8000214e <killed>
    80002780:	e915                	bnez	a0,800027b4 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002782:	6cb8                	ld	a4,88(s1)
    80002784:	6f1c                	ld	a5,24(a4)
    80002786:	0791                	addi	a5,a5,4
    80002788:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    8000278a:	10016073          	csrsi	sstatus,2
    syscall();
    8000278e:	24a000ef          	jal	800029d8 <syscall>
  if (killed(p))
    80002792:	8526                	mv	a0,s1
    80002794:	9bbff0ef          	jal	8000214e <killed>
    80002798:	e521                	bnez	a0,800027e0 <usertrap+0xf4>
  prepare_return();
    8000279a:	e17ff0ef          	jal	800025b0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000279e:	68a8                	ld	a0,80(s1)
    800027a0:	8131                	srli	a0,a0,0xc
    800027a2:	57fd                	li	a5,-1
    800027a4:	17fe                	slli	a5,a5,0x3f
    800027a6:	8d5d                	or	a0,a0,a5
}
    800027a8:	60e2                	ld	ra,24(sp)
    800027aa:	6442                	ld	s0,16(sp)
    800027ac:	64a2                	ld	s1,8(sp)
    800027ae:	6902                	ld	s2,0(sp)
    800027b0:	6105                	addi	sp,sp,32
    800027b2:	8082                	ret
      kexit(-1);
    800027b4:	557d                	li	a0,-1
    800027b6:	867ff0ef          	jal	8000201c <kexit>
    800027ba:	b7e1                	j	80002782 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    800027bc:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    800027c0:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800027c4:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800027c6:	0016b693          	seqz	a3,a3
    800027ca:	64ac                	ld	a1,72(s1)
    800027cc:	68a8                	ld	a0,80(s1)
    800027ce:	cd1fe0ef          	jal	8000149e <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800027d2:	f161                	bnez	a0,80002792 <usertrap+0xa6>
    800027d4:	b7bd                	j	80002742 <usertrap+0x56>
  if (killed(p))
    800027d6:	8526                	mv	a0,s1
    800027d8:	977ff0ef          	jal	8000214e <killed>
    800027dc:	c511                	beqz	a0,800027e8 <usertrap+0xfc>
    800027de:	a011                	j	800027e2 <usertrap+0xf6>
    800027e0:	4901                	li	s2,0
    kexit(-1);
    800027e2:	557d                	li	a0,-1
    800027e4:	839ff0ef          	jal	8000201c <kexit>
  if (which_dev == 2)
    800027e8:	4789                	li	a5,2
    800027ea:	faf918e3          	bne	s2,a5,8000279a <usertrap+0xae>
    yield();
    800027ee:	edaff0ef          	jal	80001ec8 <yield>
    800027f2:	b765                	j	8000279a <usertrap+0xae>

00000000800027f4 <kerneltrap>:
{
    800027f4:	7179                	addi	sp,sp,-48
    800027f6:	f406                	sd	ra,40(sp)
    800027f8:	f022                	sd	s0,32(sp)
    800027fa:	ec26                	sd	s1,24(sp)
    800027fc:	e84a                	sd	s2,16(sp)
    800027fe:	e44e                	sd	s3,8(sp)
    80002800:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002802:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002806:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000280a:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    8000280e:	1004f793          	andi	a5,s1,256
    80002812:	c795                	beqz	a5,8000283e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002814:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002818:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000281a:	eb85                	bnez	a5,8000284a <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    8000281c:	e5dff0ef          	jal	80002678 <devintr>
    80002820:	c91d                	beqz	a0,80002856 <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    80002822:	4789                	li	a5,2
    80002824:	04f50a63          	beq	a0,a5,80002878 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002828:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000282c:	10049073          	csrw	sstatus,s1
}
    80002830:	70a2                	ld	ra,40(sp)
    80002832:	7402                	ld	s0,32(sp)
    80002834:	64e2                	ld	s1,24(sp)
    80002836:	6942                	ld	s2,16(sp)
    80002838:	69a2                	ld	s3,8(sp)
    8000283a:	6145                	addi	sp,sp,48
    8000283c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000283e:	00005517          	auipc	a0,0x5
    80002842:	aba50513          	addi	a0,a0,-1350 # 800072f8 <etext+0x2f8>
    80002846:	fabfd0ef          	jal	800007f0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000284a:	00005517          	auipc	a0,0x5
    8000284e:	ad650513          	addi	a0,a0,-1322 # 80007320 <etext+0x320>
    80002852:	f9ffd0ef          	jal	800007f0 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002856:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000285a:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000285e:	85ce                	mv	a1,s3
    80002860:	00005517          	auipc	a0,0x5
    80002864:	ae050513          	addi	a0,a0,-1312 # 80007340 <etext+0x340>
    80002868:	ca3fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000286c:	00005517          	auipc	a0,0x5
    80002870:	afc50513          	addi	a0,a0,-1284 # 80007368 <etext+0x368>
    80002874:	f7dfd0ef          	jal	800007f0 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002878:	86cff0ef          	jal	800018e4 <myproc>
    8000287c:	d555                	beqz	a0,80002828 <kerneltrap+0x34>
    yield();
    8000287e:	e4aff0ef          	jal	80001ec8 <yield>
    80002882:	b75d                	j	80002828 <kerneltrap+0x34>

0000000080002884 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002884:	1101                	addi	sp,sp,-32
    80002886:	ec06                	sd	ra,24(sp)
    80002888:	e822                	sd	s0,16(sp)
    8000288a:	e426                	sd	s1,8(sp)
    8000288c:	1000                	addi	s0,sp,32
    8000288e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002890:	854ff0ef          	jal	800018e4 <myproc>
  switch (n) {
    80002894:	4795                	li	a5,5
    80002896:	0497e163          	bltu	a5,s1,800028d8 <argraw+0x54>
    8000289a:	048a                	slli	s1,s1,0x2
    8000289c:	00005717          	auipc	a4,0x5
    800028a0:	ffc70713          	addi	a4,a4,-4 # 80007898 <states.0+0x30>
    800028a4:	94ba                	add	s1,s1,a4
    800028a6:	409c                	lw	a5,0(s1)
    800028a8:	97ba                	add	a5,a5,a4
    800028aa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800028ac:	6d3c                	ld	a5,88(a0)
    800028ae:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800028b0:	60e2                	ld	ra,24(sp)
    800028b2:	6442                	ld	s0,16(sp)
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret
    return p->trapframe->a1;
    800028ba:	6d3c                	ld	a5,88(a0)
    800028bc:	7fa8                	ld	a0,120(a5)
    800028be:	bfcd                	j	800028b0 <argraw+0x2c>
    return p->trapframe->a2;
    800028c0:	6d3c                	ld	a5,88(a0)
    800028c2:	63c8                	ld	a0,128(a5)
    800028c4:	b7f5                	j	800028b0 <argraw+0x2c>
    return p->trapframe->a3;
    800028c6:	6d3c                	ld	a5,88(a0)
    800028c8:	67c8                	ld	a0,136(a5)
    800028ca:	b7dd                	j	800028b0 <argraw+0x2c>
    return p->trapframe->a4;
    800028cc:	6d3c                	ld	a5,88(a0)
    800028ce:	6bc8                	ld	a0,144(a5)
    800028d0:	b7c5                	j	800028b0 <argraw+0x2c>
    return p->trapframe->a5;
    800028d2:	6d3c                	ld	a5,88(a0)
    800028d4:	6fc8                	ld	a0,152(a5)
    800028d6:	bfe9                	j	800028b0 <argraw+0x2c>
  panic("argraw");
    800028d8:	00005517          	auipc	a0,0x5
    800028dc:	aa050513          	addi	a0,a0,-1376 # 80007378 <etext+0x378>
    800028e0:	f11fd0ef          	jal	800007f0 <panic>

00000000800028e4 <fetchaddr>:
{
    800028e4:	1101                	addi	sp,sp,-32
    800028e6:	ec06                	sd	ra,24(sp)
    800028e8:	e822                	sd	s0,16(sp)
    800028ea:	e426                	sd	s1,8(sp)
    800028ec:	e04a                	sd	s2,0(sp)
    800028ee:	1000                	addi	s0,sp,32
    800028f0:	84aa                	mv	s1,a0
    800028f2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028f4:	ff1fe0ef          	jal	800018e4 <myproc>
  if (addr >= p->sz ||
    800028f8:	652c                	ld	a1,72(a0)
    800028fa:	02b4f663          	bgeu	s1,a1,80002926 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028fe:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002902:	02f5e463          	bltu	a1,a5,8000292a <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002906:	4721                	li	a4,8
    80002908:	86a6                	mv	a3,s1
    8000290a:	864a                	mv	a2,s2
    8000290c:	6928                	ld	a0,80(a0)
    8000290e:	cf9fe0ef          	jal	80001606 <copyin>
    80002912:	00a03533          	snez	a0,a0
    80002916:	40a00533          	neg	a0,a0
}
    8000291a:	60e2                	ld	ra,24(sp)
    8000291c:	6442                	ld	s0,16(sp)
    8000291e:	64a2                	ld	s1,8(sp)
    80002920:	6902                	ld	s2,0(sp)
    80002922:	6105                	addi	sp,sp,32
    80002924:	8082                	ret
    return -1;
    80002926:	557d                	li	a0,-1
    80002928:	bfcd                	j	8000291a <fetchaddr+0x36>
    8000292a:	557d                	li	a0,-1
    8000292c:	b7fd                	j	8000291a <fetchaddr+0x36>

000000008000292e <fetchstr>:
{
    8000292e:	7179                	addi	sp,sp,-48
    80002930:	f406                	sd	ra,40(sp)
    80002932:	f022                	sd	s0,32(sp)
    80002934:	ec26                	sd	s1,24(sp)
    80002936:	e84a                	sd	s2,16(sp)
    80002938:	e44e                	sd	s3,8(sp)
    8000293a:	1800                	addi	s0,sp,48
    8000293c:	892a                	mv	s2,a0
    8000293e:	84ae                	mv	s1,a1
    80002940:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002942:	fa3fe0ef          	jal	800018e4 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002946:	874e                	mv	a4,s3
    80002948:	86ca                	mv	a3,s2
    8000294a:	8626                	mv	a2,s1
    8000294c:	652c                	ld	a1,72(a0)
    8000294e:	6928                	ld	a0,80(a0)
    80002950:	d4dfe0ef          	jal	8000169c <copyinstr>
    80002954:	00054c63          	bltz	a0,8000296c <fetchstr+0x3e>
  return strlen(buf);
    80002958:	8526                	mv	a0,s1
    8000295a:	cacfe0ef          	jal	80000e06 <strlen>
}
    8000295e:	70a2                	ld	ra,40(sp)
    80002960:	7402                	ld	s0,32(sp)
    80002962:	64e2                	ld	s1,24(sp)
    80002964:	6942                	ld	s2,16(sp)
    80002966:	69a2                	ld	s3,8(sp)
    80002968:	6145                	addi	sp,sp,48
    8000296a:	8082                	ret
    return -1;
    8000296c:	557d                	li	a0,-1
    8000296e:	bfc5                	j	8000295e <fetchstr+0x30>

0000000080002970 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002970:	1101                	addi	sp,sp,-32
    80002972:	ec06                	sd	ra,24(sp)
    80002974:	e822                	sd	s0,16(sp)
    80002976:	e426                	sd	s1,8(sp)
    80002978:	1000                	addi	s0,sp,32
    8000297a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000297c:	f09ff0ef          	jal	80002884 <argraw>
    80002980:	c088                	sw	a0,0(s1)
}
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	64a2                	ld	s1,8(sp)
    80002988:	6105                	addi	sp,sp,32
    8000298a:	8082                	ret

000000008000298c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000298c:	1101                	addi	sp,sp,-32
    8000298e:	ec06                	sd	ra,24(sp)
    80002990:	e822                	sd	s0,16(sp)
    80002992:	e426                	sd	s1,8(sp)
    80002994:	1000                	addi	s0,sp,32
    80002996:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002998:	eedff0ef          	jal	80002884 <argraw>
    8000299c:	e088                	sd	a0,0(s1)
}
    8000299e:	60e2                	ld	ra,24(sp)
    800029a0:	6442                	ld	s0,16(sp)
    800029a2:	64a2                	ld	s1,8(sp)
    800029a4:	6105                	addi	sp,sp,32
    800029a6:	8082                	ret

00000000800029a8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800029a8:	7179                	addi	sp,sp,-48
    800029aa:	f406                	sd	ra,40(sp)
    800029ac:	f022                	sd	s0,32(sp)
    800029ae:	ec26                	sd	s1,24(sp)
    800029b0:	e84a                	sd	s2,16(sp)
    800029b2:	1800                	addi	s0,sp,48
    800029b4:	84ae                	mv	s1,a1
    800029b6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800029b8:	fd840593          	addi	a1,s0,-40
    800029bc:	fd1ff0ef          	jal	8000298c <argaddr>
  return fetchstr(addr, buf, max);
    800029c0:	864a                	mv	a2,s2
    800029c2:	85a6                	mv	a1,s1
    800029c4:	fd843503          	ld	a0,-40(s0)
    800029c8:	f67ff0ef          	jal	8000292e <fetchstr>
}
    800029cc:	70a2                	ld	ra,40(sp)
    800029ce:	7402                	ld	s0,32(sp)
    800029d0:	64e2                	ld	s1,24(sp)
    800029d2:	6942                	ld	s2,16(sp)
    800029d4:	6145                	addi	sp,sp,48
    800029d6:	8082                	ret

00000000800029d8 <syscall>:
};


void
syscall(void)
{
    800029d8:	7119                	addi	sp,sp,-128
    800029da:	fc86                	sd	ra,120(sp)
    800029dc:	f8a2                	sd	s0,112(sp)
    800029de:	f4a6                	sd	s1,104(sp)
    800029e0:	f0ca                	sd	s2,96(sp)
    800029e2:	ecce                	sd	s3,88(sp)
    800029e4:	e8d2                	sd	s4,80(sp)
    800029e6:	0100                	addi	s0,sp,128
  int num;
  struct proc *p = myproc();
    800029e8:	efdfe0ef          	jal	800018e4 <myproc>
    800029ec:	84aa                	mv	s1,a0

  num = p->trapframe->a7; // System call number is in register a7
    800029ee:	05853a03          	ld	s4,88(a0)
    800029f2:	0a8a3983          	ld	s3,168(s4)
    800029f6:	0009891b          	sext.w	s2,s3
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029fa:	fff9871b          	addiw	a4,s3,-1
    800029fe:	47e1                	li	a5,24
    80002a00:	0ce7e863          	bltu	a5,a4,80002ad0 <syscall+0xf8>
    80002a04:	e4d6                	sd	s5,72(sp)
    80002a06:	00391713          	slli	a4,s2,0x3
    80002a0a:	00005797          	auipc	a5,0x5
    80002a0e:	ea678793          	addi	a5,a5,-346 # 800078b0 <syscalls>
    80002a12:	97ba                	add	a5,a5,a4
    80002a14:	0007ba83          	ld	s5,0(a5)
    80002a18:	0a0a8b63          	beqz	s5,80002ace <syscall+0xf6>
    80002a1c:	e0da                	sd	s6,64(sp)

    // 1. Core Constraint: Fetch string arguments BEFORE the handler overwrites them
    uint64 arg0 = p->trapframe->a0; 
    80002a1e:	070a3b03          	ld	s6,112(s4)
    char strarg[64];
    int has_str = 0;

    if ((p->trace_mask & (1 << num))) {
    80002a22:	15852783          	lw	a5,344(a0)
    80002a26:	4127d7bb          	sraw	a5,a5,s2
    80002a2a:	8b85                	andi	a5,a5,1
    80002a2c:	10078a63          	beqz	a5,80002b40 <syscall+0x168>
      // Check if this system call takes a string as its first argument
      if (num == SYS_open || num == SYS_exec || num == 4 || // chdir
    80002a30:	47d1                	li	a5,20
    80002a32:	0127ea63          	bltu	a5,s2,80002a46 <syscall+0x6e>
    80002a36:	001e87b7          	lui	a5,0x1e8
    80002a3a:	09078793          	addi	a5,a5,144 # 1e8090 <_entry-0x7fe17f70>
    80002a3e:	0127d7b3          	srl	a5,a5,s2
    80002a42:	8b85                	andi	a5,a5,1
    80002a44:	ef89                	bnez	a5,80002a5e <syscall+0x86>
        has_str = 1;
      }
    }

    // 2. Fire the underlying system call handler
    p->trapframe->a0 = syscalls[num]();
    80002a46:	9a82                	jalr	s5
    80002a48:	06aa3823          	sd	a0,112(s4)

    // 3. Print out the dynamic tracing output if tracked
    if(p->trace_mask & (1 << num)) {
    80002a4c:	1584a783          	lw	a5,344(s1)
    80002a50:	4127d7bb          	sraw	a5,a5,s2
    80002a54:	8b85                	andi	a5,a5,1
    80002a56:	e7b1                	bnez	a5,80002aa2 <syscall+0xca>
    80002a58:	6aa6                	ld	s5,72(sp)
    80002a5a:	6b06                	ld	s6,64(sp)
    80002a5c:	a079                	j	80002aea <syscall+0x112>
        if (fetchstr(arg0, strarg, sizeof(strarg)) < 0) {
    80002a5e:	04000613          	li	a2,64
    80002a62:	f8040593          	addi	a1,s0,-128
    80002a66:	855a                	mv	a0,s6
    80002a68:	ec7ff0ef          	jal	8000292e <fetchstr>
    80002a6c:	02054063          	bltz	a0,80002a8c <syscall+0xb4>
    p->trapframe->a0 = syscalls[num]();
    80002a70:	0584b983          	ld	s3,88(s1)
    80002a74:	9a82                	jalr	s5
    80002a76:	06a9b823          	sd	a0,112(s3)
    if(p->trace_mask & (1 << num)) {
    80002a7a:	1584a783          	lw	a5,344(s1)
    80002a7e:	4127d7bb          	sraw	a5,a5,s2
    80002a82:	8b85                	andi	a5,a5,1
    80002a84:	ebf1                	bnez	a5,80002b58 <syscall+0x180>
    80002a86:	6aa6                	ld	s5,72(sp)
    80002a88:	6b06                	ld	s6,64(sp)
    80002a8a:	a085                	j	80002aea <syscall+0x112>
          safestrcpy(strarg, "?", sizeof(strarg));
    80002a8c:	04000613          	li	a2,64
    80002a90:	00005597          	auipc	a1,0x5
    80002a94:	8f058593          	addi	a1,a1,-1808 # 80007380 <etext+0x380>
    80002a98:	f8040513          	addi	a0,s0,-128
    80002a9c:	b38fe0ef          	jal	80000dd4 <safestrcpy>
    80002aa0:	bfc1                	j	80002a70 <syscall+0x98>
      printk("[%d] %s(", p->pid, syscall_names[num]);
    80002aa2:	090e                	slli	s2,s2,0x3
    80002aa4:	00005797          	auipc	a5,0x5
    80002aa8:	e0c78793          	addi	a5,a5,-500 # 800078b0 <syscalls>
    80002aac:	97ca                	add	a5,a5,s2
    80002aae:	6bf0                	ld	a2,208(a5)
    80002ab0:	588c                	lw	a1,48(s1)
    80002ab2:	00005517          	auipc	a0,0x5
    80002ab6:	8d650513          	addi	a0,a0,-1834 # 80007388 <etext+0x388>
    80002aba:	a51fd0ef          	jal	8000050a <printk>

      // Custom argument format rules matching assignment spec
      if (has_str) {
    80002abe:	a8a1                	j	80002b16 <syscall+0x13e>
        if (strarg[0] == '?' && strarg[1] == '\0') {
          printk("?");
    80002ac0:	00005517          	auipc	a0,0x5
    80002ac4:	8c050513          	addi	a0,a0,-1856 # 80007380 <etext+0x380>
    80002ac8:	a43fd0ef          	jal	8000050a <printk>
    80002acc:	a0e9                	j	80002b96 <syscall+0x1be>
    80002ace:	6aa6                	ld	s5,72(sp)
      }

      printk(") -> %d\n", (int)p->trapframe->a0);
    }
  } else {
    printk("%d %s: unknown sys call %d\n",
    80002ad0:	86ca                	mv	a3,s2
    80002ad2:	15c48613          	addi	a2,s1,348
    80002ad6:	588c                	lw	a1,48(s1)
    80002ad8:	00005517          	auipc	a0,0x5
    80002adc:	8e050513          	addi	a0,a0,-1824 # 800073b8 <etext+0x3b8>
    80002ae0:	a2bfd0ef          	jal	8000050a <printk>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ae4:	6cbc                	ld	a5,88(s1)
    80002ae6:	577d                	li	a4,-1
    80002ae8:	fbb8                	sd	a4,112(a5)
  }
}
    80002aea:	70e6                	ld	ra,120(sp)
    80002aec:	7446                	ld	s0,112(sp)
    80002aee:	74a6                	ld	s1,104(sp)
    80002af0:	7906                	ld	s2,96(sp)
    80002af2:	69e6                	ld	s3,88(sp)
    80002af4:	6a46                	ld	s4,80(sp)
    80002af6:	6109                	addi	sp,sp,128
    80002af8:	8082                	ret
      printk("[%d] %s(", p->pid, syscall_names[num]);
    80002afa:	090e                	slli	s2,s2,0x3
    80002afc:	00005797          	auipc	a5,0x5
    80002b00:	db478793          	addi	a5,a5,-588 # 800078b0 <syscalls>
    80002b04:	97ca                	add	a5,a5,s2
    80002b06:	6bf0                	ld	a2,208(a5)
    80002b08:	588c                	lw	a1,48(s1)
    80002b0a:	00005517          	auipc	a0,0x5
    80002b0e:	87e50513          	addi	a0,a0,-1922 # 80007388 <etext+0x388>
    80002b12:	9f9fd0ef          	jal	8000050a <printk>
      } else if (num == 1 || num == 11 || num == 14 || num == 21) { // fork/kfork, getpid, uptime, sync
    80002b16:	2981                	sext.w	s3,s3
    80002b18:	47d5                	li	a5,21
    80002b1a:	0137ea63          	bltu	a5,s3,80002b2e <syscall+0x156>
    80002b1e:	002057b7          	lui	a5,0x205
    80002b22:	80278793          	addi	a5,a5,-2046 # 204802 <_entry-0x7fdfb7fe>
    80002b26:	0137d7b3          	srl	a5,a5,s3
    80002b2a:	8b85                	andi	a5,a5,1
    80002b2c:	e7ad                	bnez	a5,80002b96 <syscall+0x1be>
        printk("%d", (int)arg0);
    80002b2e:	000b059b          	sext.w	a1,s6
    80002b32:	00005517          	auipc	a0,0x5
    80002b36:	86e50513          	addi	a0,a0,-1938 # 800073a0 <etext+0x3a0>
    80002b3a:	9d1fd0ef          	jal	8000050a <printk>
    80002b3e:	a8a1                	j	80002b96 <syscall+0x1be>
    p->trapframe->a0 = syscalls[num]();
    80002b40:	9a82                	jalr	s5
    80002b42:	06aa3823          	sd	a0,112(s4)
    if(p->trace_mask & (1 << num)) {
    80002b46:	1584a783          	lw	a5,344(s1)
    80002b4a:	4127d7bb          	sraw	a5,a5,s2
    80002b4e:	8b85                	andi	a5,a5,1
    80002b50:	f7cd                	bnez	a5,80002afa <syscall+0x122>
    80002b52:	6aa6                	ld	s5,72(sp)
    80002b54:	6b06                	ld	s6,64(sp)
    80002b56:	bf51                	j	80002aea <syscall+0x112>
      printk("[%d] %s(", p->pid, syscall_names[num]);
    80002b58:	090e                	slli	s2,s2,0x3
    80002b5a:	00005797          	auipc	a5,0x5
    80002b5e:	d5678793          	addi	a5,a5,-682 # 800078b0 <syscalls>
    80002b62:	97ca                	add	a5,a5,s2
    80002b64:	6bf0                	ld	a2,208(a5)
    80002b66:	588c                	lw	a1,48(s1)
    80002b68:	00005517          	auipc	a0,0x5
    80002b6c:	82050513          	addi	a0,a0,-2016 # 80007388 <etext+0x388>
    80002b70:	99bfd0ef          	jal	8000050a <printk>
        if (strarg[0] == '?' && strarg[1] == '\0') {
    80002b74:	f8044703          	lbu	a4,-128(s0)
    80002b78:	03f00793          	li	a5,63
    80002b7c:	00f71563          	bne	a4,a5,80002b86 <syscall+0x1ae>
    80002b80:	f8144783          	lbu	a5,-127(s0)
    80002b84:	df95                	beqz	a5,80002ac0 <syscall+0xe8>
          printk("\"%s\"", strarg);
    80002b86:	f8040593          	addi	a1,s0,-128
    80002b8a:	00005517          	auipc	a0,0x5
    80002b8e:	80e50513          	addi	a0,a0,-2034 # 80007398 <etext+0x398>
    80002b92:	979fd0ef          	jal	8000050a <printk>
      printk(") -> %d\n", (int)p->trapframe->a0);
    80002b96:	6cbc                	ld	a5,88(s1)
    80002b98:	5bac                	lw	a1,112(a5)
    80002b9a:	00005517          	auipc	a0,0x5
    80002b9e:	80e50513          	addi	a0,a0,-2034 # 800073a8 <etext+0x3a8>
    80002ba2:	969fd0ef          	jal	8000050a <printk>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ba6:	6aa6                	ld	s5,72(sp)
    80002ba8:	6b06                	ld	s6,64(sp)
    80002baa:	b781                	j	80002aea <syscall+0x112>

0000000080002bac <sys_exit>:
#include "vm.h"
#include "kernel/sysinfo.h"

uint64
sys_exit(void)
{
    80002bac:	1101                	addi	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bb4:	fec40593          	addi	a1,s0,-20
    80002bb8:	4501                	li	a0,0
    80002bba:	db7ff0ef          	jal	80002970 <argint>
  kexit(n);
    80002bbe:	fec42503          	lw	a0,-20(s0)
    80002bc2:	c5aff0ef          	jal	8000201c <kexit>
  return 0; // not reached
}
    80002bc6:	4501                	li	a0,0
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd0:	1141                	addi	sp,sp,-16
    80002bd2:	e406                	sd	ra,8(sp)
    80002bd4:	e022                	sd	s0,0(sp)
    80002bd6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bd8:	d0dfe0ef          	jal	800018e4 <myproc>
}
    80002bdc:	5908                	lw	a0,48(a0)
    80002bde:	60a2                	ld	ra,8(sp)
    80002be0:	6402                	ld	s0,0(sp)
    80002be2:	0141                	addi	sp,sp,16
    80002be4:	8082                	ret

0000000080002be6 <sys_fork>:

uint64
sys_fork(void)
{
    80002be6:	1141                	addi	sp,sp,-16
    80002be8:	e406                	sd	ra,8(sp)
    80002bea:	e022                	sd	s0,0(sp)
    80002bec:	0800                	addi	s0,sp,16
  return kfork();
    80002bee:	856ff0ef          	jal	80001c44 <kfork>
}
    80002bf2:	60a2                	ld	ra,8(sp)
    80002bf4:	6402                	ld	s0,0(sp)
    80002bf6:	0141                	addi	sp,sp,16
    80002bf8:	8082                	ret

0000000080002bfa <sys_wait>:

uint64
sys_wait(void)
{
    80002bfa:	1101                	addi	sp,sp,-32
    80002bfc:	ec06                	sd	ra,24(sp)
    80002bfe:	e822                	sd	s0,16(sp)
    80002c00:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c02:	fe840593          	addi	a1,s0,-24
    80002c06:	4501                	li	a0,0
    80002c08:	d85ff0ef          	jal	8000298c <argaddr>
  return kwait(p);
    80002c0c:	fe843503          	ld	a0,-24(s0)
    80002c10:	d68ff0ef          	jal	80002178 <kwait>
}
    80002c14:	60e2                	ld	ra,24(sp)
    80002c16:	6442                	ld	s0,16(sp)
    80002c18:	6105                	addi	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c1c:	7179                	addi	sp,sp,-48
    80002c1e:	f406                	sd	ra,40(sp)
    80002c20:	f022                	sd	s0,32(sp)
    80002c22:	ec26                	sd	s1,24(sp)
    80002c24:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002c26:	fd840593          	addi	a1,s0,-40
    80002c2a:	4501                	li	a0,0
    80002c2c:	d45ff0ef          	jal	80002970 <argint>
  argint(1, &t);
    80002c30:	fdc40593          	addi	a1,s0,-36
    80002c34:	4505                	li	a0,1
    80002c36:	d3bff0ef          	jal	80002970 <argint>
  addr = myproc()->sz;
    80002c3a:	cabfe0ef          	jal	800018e4 <myproc>
    80002c3e:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002c40:	fdc42703          	lw	a4,-36(s0)
    80002c44:	4785                	li	a5,1
    80002c46:	02f70763          	beq	a4,a5,80002c74 <sys_sbrk+0x58>
    80002c4a:	fd842783          	lw	a5,-40(s0)
    80002c4e:	0207c363          	bltz	a5,80002c74 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002c52:	97a6                	add	a5,a5,s1
    80002c54:	0297ee63          	bltu	a5,s1,80002c90 <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    80002c58:	02000737          	lui	a4,0x2000
    80002c5c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002c5e:	0736                	slli	a4,a4,0xd
    80002c60:	02f76a63          	bltu	a4,a5,80002c94 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002c64:	c81fe0ef          	jal	800018e4 <myproc>
    80002c68:	fd842703          	lw	a4,-40(s0)
    80002c6c:	653c                	ld	a5,72(a0)
    80002c6e:	97ba                	add	a5,a5,a4
    80002c70:	e53c                	sd	a5,72(a0)
    80002c72:	a039                	j	80002c80 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002c74:	fd842503          	lw	a0,-40(s0)
    80002c78:	f6bfe0ef          	jal	80001be2 <growproc>
    80002c7c:	00054863          	bltz	a0,80002c8c <sys_sbrk+0x70>
  }
  return addr;
}
    80002c80:	8526                	mv	a0,s1
    80002c82:	70a2                	ld	ra,40(sp)
    80002c84:	7402                	ld	s0,32(sp)
    80002c86:	64e2                	ld	s1,24(sp)
    80002c88:	6145                	addi	sp,sp,48
    80002c8a:	8082                	ret
      return -1;
    80002c8c:	54fd                	li	s1,-1
    80002c8e:	bfcd                	j	80002c80 <sys_sbrk+0x64>
      return -1;
    80002c90:	54fd                	li	s1,-1
    80002c92:	b7fd                	j	80002c80 <sys_sbrk+0x64>
      return -1;
    80002c94:	54fd                	li	s1,-1
    80002c96:	b7ed                	j	80002c80 <sys_sbrk+0x64>

0000000080002c98 <sys_pause>:

uint64
sys_pause(void)
{
    80002c98:	7139                	addi	sp,sp,-64
    80002c9a:	fc06                	sd	ra,56(sp)
    80002c9c:	f822                	sd	s0,48(sp)
    80002c9e:	ec4e                	sd	s3,24(sp)
    80002ca0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ca2:	fcc40593          	addi	a1,s0,-52
    80002ca6:	4501                	li	a0,0
    80002ca8:	cc9ff0ef          	jal	80002970 <argint>
  if (n < 0)
    80002cac:	fcc42783          	lw	a5,-52(s0)
    80002cb0:	0607cf63          	bltz	a5,80002d2e <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002cb4:	00016517          	auipc	a0,0x16
    80002cb8:	a9c50513          	addi	a0,a0,-1380 # 80018750 <tickslock>
    80002cbc:	f17fd0ef          	jal	80000bd2 <acquire>
  ticks0 = ticks;
    80002cc0:	00008997          	auipc	s3,0x8
    80002cc4:	9409a983          	lw	s3,-1728(s3) # 8000a600 <ticks>
  while (ticks - ticks0 < n) {
    80002cc8:	fcc42783          	lw	a5,-52(s0)
    80002ccc:	c7a9                	beqz	a5,80002d16 <sys_pause+0x7e>
    80002cce:	f426                	sd	s1,40(sp)
    80002cd0:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002cd2:	00008917          	auipc	s2,0x8
    80002cd6:	92e90913          	addi	s2,s2,-1746 # 8000a600 <ticks>
    release(&tickslock);
    80002cda:	00016497          	auipc	s1,0x16
    80002cde:	a7648493          	addi	s1,s1,-1418 # 80018750 <tickslock>
    if (killed(myproc())) {
    80002ce2:	c03fe0ef          	jal	800018e4 <myproc>
    80002ce6:	c68ff0ef          	jal	8000214e <killed>
    80002cea:	e529                	bnez	a0,80002d34 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002cec:	854a                	mv	a0,s2
    80002cee:	a06ff0ef          	jal	80001ef4 <sleep_prepare>
    release(&tickslock);
    80002cf2:	8526                	mv	a0,s1
    80002cf4:	f6bfd0ef          	jal	80000c5e <release>
    sleep();
    80002cf8:	a38ff0ef          	jal	80001f30 <sleep>
    acquire(&tickslock);
    80002cfc:	8526                	mv	a0,s1
    80002cfe:	ed5fd0ef          	jal	80000bd2 <acquire>
  while (ticks - ticks0 < n) {
    80002d02:	00092783          	lw	a5,0(s2)
    80002d06:	413787bb          	subw	a5,a5,s3
    80002d0a:	fcc42703          	lw	a4,-52(s0)
    80002d0e:	fce7eae3          	bltu	a5,a4,80002ce2 <sys_pause+0x4a>
    80002d12:	74a2                	ld	s1,40(sp)
    80002d14:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002d16:	00016517          	auipc	a0,0x16
    80002d1a:	a3a50513          	addi	a0,a0,-1478 # 80018750 <tickslock>
    80002d1e:	f41fd0ef          	jal	80000c5e <release>
  return 0;
    80002d22:	4501                	li	a0,0
}
    80002d24:	70e2                	ld	ra,56(sp)
    80002d26:	7442                	ld	s0,48(sp)
    80002d28:	69e2                	ld	s3,24(sp)
    80002d2a:	6121                	addi	sp,sp,64
    80002d2c:	8082                	ret
    n = 0;
    80002d2e:	fc042623          	sw	zero,-52(s0)
    80002d32:	b749                	j	80002cb4 <sys_pause+0x1c>
      release(&tickslock);
    80002d34:	00016517          	auipc	a0,0x16
    80002d38:	a1c50513          	addi	a0,a0,-1508 # 80018750 <tickslock>
    80002d3c:	f23fd0ef          	jal	80000c5e <release>
      return -1;
    80002d40:	557d                	li	a0,-1
    80002d42:	74a2                	ld	s1,40(sp)
    80002d44:	7902                	ld	s2,32(sp)
    80002d46:	bff9                	j	80002d24 <sys_pause+0x8c>

0000000080002d48 <sys_kill>:

uint64
sys_kill(void)
{
    80002d48:	1101                	addi	sp,sp,-32
    80002d4a:	ec06                	sd	ra,24(sp)
    80002d4c:	e822                	sd	s0,16(sp)
    80002d4e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d50:	fec40593          	addi	a1,s0,-20
    80002d54:	4501                	li	a0,0
    80002d56:	c1bff0ef          	jal	80002970 <argint>
  return kkill(pid);
    80002d5a:	fec42503          	lw	a0,-20(s0)
    80002d5e:	b60ff0ef          	jal	800020be <kkill>
}
    80002d62:	60e2                	ld	ra,24(sp)
    80002d64:	6442                	ld	s0,16(sp)
    80002d66:	6105                	addi	sp,sp,32
    80002d68:	8082                	ret

0000000080002d6a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d74:	00016517          	auipc	a0,0x16
    80002d78:	9dc50513          	addi	a0,a0,-1572 # 80018750 <tickslock>
    80002d7c:	e57fd0ef          	jal	80000bd2 <acquire>
  xticks = ticks;
    80002d80:	00008497          	auipc	s1,0x8
    80002d84:	8804a483          	lw	s1,-1920(s1) # 8000a600 <ticks>
  release(&tickslock);
    80002d88:	00016517          	auipc	a0,0x16
    80002d8c:	9c850513          	addi	a0,a0,-1592 # 80018750 <tickslock>
    80002d90:	ecffd0ef          	jal	80000c5e <release>
  return xticks;
}
    80002d94:	02049513          	slli	a0,s1,0x20
    80002d98:	9101                	srli	a0,a0,0x20
    80002d9a:	60e2                	ld	ra,24(sp)
    80002d9c:	6442                	ld	s0,16(sp)
    80002d9e:	64a2                	ld	s1,8(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <sys_trace>:

uint64
sys_trace(void)
{
    80002da4:	1101                	addi	sp,sp,-32
    80002da6:	ec06                	sd	ra,24(sp)
    80002da8:	e822                	sd	s0,16(sp)
    80002daa:	1000                	addi	s0,sp,32
  int mask;

  //Grab first integer argument from register a0
  argint(0, &mask);
    80002dac:	fec40593          	addi	a1,s0,-20
    80002db0:	4501                	li	a0,0
    80002db2:	bbfff0ef          	jal	80002970 <argint>

  myproc()->trace_mask = mask;
    80002db6:	b2ffe0ef          	jal	800018e4 <myproc>
    80002dba:	fec42783          	lw	a5,-20(s0)
    80002dbe:	14f52c23          	sw	a5,344(a0)
  return 0;
}
    80002dc2:	4501                	li	a0,0
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret

0000000080002dcc <sys_sysinfo>:

uint64
sys_sysinfo(void)
{
    80002dcc:	7139                	addi	sp,sp,-64
    80002dce:	fc06                	sd	ra,56(sp)
    80002dd0:	f822                	sd	s0,48(sp)
    80002dd2:	f426                	sd	s1,40(sp)
    80002dd4:	0080                	addi	s0,sp,64
  uint64 addr;
  struct sysinfo info;
  struct proc *p = myproc();
    80002dd6:	b0ffe0ef          	jal	800018e4 <myproc>
    80002dda:	84aa                	mv	s1,a0

  // Fetch the user space pointer address passed as an argument
  argaddr(0, &addr);
    80002ddc:	fd840593          	addi	a1,s0,-40
    80002de0:	4501                	li	a0,0
    80002de2:	babff0ef          	jal	8000298c <argaddr>

  // Populate our structure fields
  info.freemem = count_free_mem();
    80002de6:	d35fd0ef          	jal	80000b1a <count_free_mem>
    80002dea:	fca43023          	sd	a0,-64(s0)
  info.nproc = count_active_procs();
    80002dee:	dd6ff0ef          	jal	800023c4 <count_active_procs>
    80002df2:	fca43423          	sd	a0,-56(s0)
  info.nopenfile = count_open_files();
    80002df6:	1d9010ef          	jal	800047ce <count_open_files>
    80002dfa:	fca43823          	sd	a0,-48(s0)

  // Pass all 5 arguments to match your kernel's copyout signature:
if(copyout(p->pagetable, addr, addr, (char *)&info, sizeof(info)) < 0){
    80002dfe:	fd843583          	ld	a1,-40(s0)
    80002e02:	4761                	li	a4,24
    80002e04:	fc040693          	addi	a3,s0,-64
    80002e08:	862e                	mv	a2,a1
    80002e0a:	68a8                	ld	a0,80(s1)
    80002e0c:	f0efe0ef          	jal	8000151a <copyout>
    // If it fails, print a kernel log to console to pinpoint exactly why
    printk("sysinfo kernel alert: copyout failed for pid %d at addr 0x%lx\n", p->pid, addr);
    return -1;
  }

  return 0;
    80002e10:	4781                	li	a5,0
if(copyout(p->pagetable, addr, addr, (char *)&info, sizeof(info)) < 0){
    80002e12:	00054863          	bltz	a0,80002e22 <sys_sysinfo+0x56>
}
    80002e16:	853e                	mv	a0,a5
    80002e18:	70e2                	ld	ra,56(sp)
    80002e1a:	7442                	ld	s0,48(sp)
    80002e1c:	74a2                	ld	s1,40(sp)
    80002e1e:	6121                	addi	sp,sp,64
    80002e20:	8082                	ret
    printk("sysinfo kernel alert: copyout failed for pid %d at addr 0x%lx\n", p->pid, addr);
    80002e22:	fd843603          	ld	a2,-40(s0)
    80002e26:	588c                	lw	a1,48(s1)
    80002e28:	00004517          	auipc	a0,0x4
    80002e2c:	67050513          	addi	a0,a0,1648 # 80007498 <etext+0x498>
    80002e30:	edafd0ef          	jal	8000050a <printk>
    return -1;
    80002e34:	57fd                	li	a5,-1
    80002e36:	b7c5                	j	80002e16 <sys_sysinfo+0x4a>

0000000080002e38 <sys_getprocs>:

uint64
sys_getprocs(void)
{
    80002e38:	1101                	addi	sp,sp,-32
    80002e3a:	ec06                	sd	ra,24(sp)
    80002e3c:	e822                	sd	s0,16(sp)
    80002e3e:	1000                	addi	s0,sp,32
  uint64 buf;
  int max;

  argaddr(0, &buf);
    80002e40:	fe840593          	addi	a1,s0,-24
    80002e44:	4501                	li	a0,0
    80002e46:	b47ff0ef          	jal	8000298c <argaddr>
  argint(1, &max);
    80002e4a:	fe440593          	addi	a1,s0,-28
    80002e4e:	4505                	li	a0,1
    80002e50:	b21ff0ef          	jal	80002970 <argint>

  return get_uprocs(buf, max);
    80002e54:	fe442583          	lw	a1,-28(s0)
    80002e58:	fe843503          	ld	a0,-24(s0)
    80002e5c:	d96ff0ef          	jal	800023f2 <get_uprocs>
}
    80002e60:	60e2                	ld	ra,24(sp)
    80002e62:	6442                	ld	s0,16(sp)
    80002e64:	6105                	addi	sp,sp,32
    80002e66:	8082                	ret

0000000080002e68 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e68:	7179                	addi	sp,sp,-48
    80002e6a:	f406                	sd	ra,40(sp)
    80002e6c:	f022                	sd	s0,32(sp)
    80002e6e:	ec26                	sd	s1,24(sp)
    80002e70:	e84a                	sd	s2,16(sp)
    80002e72:	e44e                	sd	s3,8(sp)
    80002e74:	e052                	sd	s4,0(sp)
    80002e76:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e78:	00004597          	auipc	a1,0x4
    80002e7c:	66058593          	addi	a1,a1,1632 # 800074d8 <etext+0x4d8>
    80002e80:	00016517          	auipc	a0,0x16
    80002e84:	8e850513          	addi	a0,a0,-1816 # 80018768 <bcache>
    80002e88:	cd5fd0ef          	jal	80000b5c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e8c:	0001e797          	auipc	a5,0x1e
    80002e90:	8dc78793          	addi	a5,a5,-1828 # 80020768 <bcache+0x8000>
    80002e94:	0001e717          	auipc	a4,0x1e
    80002e98:	b3c70713          	addi	a4,a4,-1220 # 800209d0 <bcache+0x8268>
    80002e9c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ea0:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ea4:	00016497          	auipc	s1,0x16
    80002ea8:	8dc48493          	addi	s1,s1,-1828 # 80018780 <bcache+0x18>
    b->next = bcache.head.next;
    80002eac:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002eae:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002eb0:	00004a17          	auipc	s4,0x4
    80002eb4:	630a0a13          	addi	s4,s4,1584 # 800074e0 <etext+0x4e0>
    b->next = bcache.head.next;
    80002eb8:	2b893783          	ld	a5,696(s2)
    80002ebc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ebe:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ec2:	85d2                	mv	a1,s4
    80002ec4:	01048513          	addi	a0,s1,16
    80002ec8:	412010ef          	jal	800042da <initsleeplock>
    bcache.head.next->prev = b;
    80002ecc:	2b893783          	ld	a5,696(s2)
    80002ed0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ed2:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ed6:	45848493          	addi	s1,s1,1112
    80002eda:	fd349fe3          	bne	s1,s3,80002eb8 <binit+0x50>
  }
}
    80002ede:	70a2                	ld	ra,40(sp)
    80002ee0:	7402                	ld	s0,32(sp)
    80002ee2:	64e2                	ld	s1,24(sp)
    80002ee4:	6942                	ld	s2,16(sp)
    80002ee6:	69a2                	ld	s3,8(sp)
    80002ee8:	6a02                	ld	s4,0(sp)
    80002eea:	6145                	addi	sp,sp,48
    80002eec:	8082                	ret

0000000080002eee <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002eee:	7179                	addi	sp,sp,-48
    80002ef0:	f406                	sd	ra,40(sp)
    80002ef2:	f022                	sd	s0,32(sp)
    80002ef4:	ec26                	sd	s1,24(sp)
    80002ef6:	e84a                	sd	s2,16(sp)
    80002ef8:	e44e                	sd	s3,8(sp)
    80002efa:	1800                	addi	s0,sp,48
    80002efc:	892a                	mv	s2,a0
    80002efe:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f00:	00016517          	auipc	a0,0x16
    80002f04:	86850513          	addi	a0,a0,-1944 # 80018768 <bcache>
    80002f08:	ccbfd0ef          	jal	80000bd2 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002f0c:	0001e497          	auipc	s1,0x1e
    80002f10:	b144b483          	ld	s1,-1260(s1) # 80020a20 <bcache+0x82b8>
    80002f14:	0001e797          	auipc	a5,0x1e
    80002f18:	abc78793          	addi	a5,a5,-1348 # 800209d0 <bcache+0x8268>
    80002f1c:	02f48b63          	beq	s1,a5,80002f52 <bread+0x64>
    80002f20:	873e                	mv	a4,a5
    80002f22:	a021                	j	80002f2a <bread+0x3c>
    80002f24:	68a4                	ld	s1,80(s1)
    80002f26:	02e48663          	beq	s1,a4,80002f52 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002f2a:	449c                	lw	a5,8(s1)
    80002f2c:	ff279ce3          	bne	a5,s2,80002f24 <bread+0x36>
    80002f30:	44dc                	lw	a5,12(s1)
    80002f32:	ff3799e3          	bne	a5,s3,80002f24 <bread+0x36>
      b->refcnt++;
    80002f36:	40bc                	lw	a5,64(s1)
    80002f38:	2785                	addiw	a5,a5,1
    80002f3a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f3c:	00016517          	auipc	a0,0x16
    80002f40:	82c50513          	addi	a0,a0,-2004 # 80018768 <bcache>
    80002f44:	d1bfd0ef          	jal	80000c5e <release>
      acquiresleep(&b->lock);
    80002f48:	01048513          	addi	a0,s1,16
    80002f4c:	3c4010ef          	jal	80004310 <acquiresleep>
      return b;
    80002f50:	a889                	j	80002fa2 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002f52:	0001e497          	auipc	s1,0x1e
    80002f56:	ac64b483          	ld	s1,-1338(s1) # 80020a18 <bcache+0x82b0>
    80002f5a:	0001e797          	auipc	a5,0x1e
    80002f5e:	a7678793          	addi	a5,a5,-1418 # 800209d0 <bcache+0x8268>
    80002f62:	00f48863          	beq	s1,a5,80002f72 <bread+0x84>
    80002f66:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002f68:	40bc                	lw	a5,64(s1)
    80002f6a:	cb91                	beqz	a5,80002f7e <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002f6c:	64a4                	ld	s1,72(s1)
    80002f6e:	fee49de3          	bne	s1,a4,80002f68 <bread+0x7a>
  panic("bget: no buffers");
    80002f72:	00004517          	auipc	a0,0x4
    80002f76:	57650513          	addi	a0,a0,1398 # 800074e8 <etext+0x4e8>
    80002f7a:	877fd0ef          	jal	800007f0 <panic>
      b->dev = dev;
    80002f7e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f82:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f86:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f8a:	4785                	li	a5,1
    80002f8c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f8e:	00015517          	auipc	a0,0x15
    80002f92:	7da50513          	addi	a0,a0,2010 # 80018768 <bcache>
    80002f96:	cc9fd0ef          	jal	80000c5e <release>
      acquiresleep(&b->lock);
    80002f9a:	01048513          	addi	a0,s1,16
    80002f9e:	372010ef          	jal	80004310 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002fa2:	409c                	lw	a5,0(s1)
    80002fa4:	cb89                	beqz	a5,80002fb6 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fa6:	8526                	mv	a0,s1
    80002fa8:	70a2                	ld	ra,40(sp)
    80002faa:	7402                	ld	s0,32(sp)
    80002fac:	64e2                	ld	s1,24(sp)
    80002fae:	6942                	ld	s2,16(sp)
    80002fb0:	69a2                	ld	s3,8(sp)
    80002fb2:	6145                	addi	sp,sp,48
    80002fb4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fb6:	4581                	li	a1,0
    80002fb8:	8526                	mv	a0,s1
    80002fba:	4e7020ef          	jal	80005ca0 <virtio_disk_rw>
    b->valid = 1;
    80002fbe:	4785                	li	a5,1
    80002fc0:	c09c                	sw	a5,0(s1)
  return b;
    80002fc2:	b7d5                	j	80002fa6 <bread+0xb8>

0000000080002fc4 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	e426                	sd	s1,8(sp)
    80002fcc:	1000                	addi	s0,sp,32
    80002fce:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002fd0:	0541                	addi	a0,a0,16
    80002fd2:	3ca010ef          	jal	8000439c <holdingsleep>
    80002fd6:	c911                	beqz	a0,80002fea <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fd8:	4585                	li	a1,1
    80002fda:	8526                	mv	a0,s1
    80002fdc:	4c5020ef          	jal	80005ca0 <virtio_disk_rw>
}
    80002fe0:	60e2                	ld	ra,24(sp)
    80002fe2:	6442                	ld	s0,16(sp)
    80002fe4:	64a2                	ld	s1,8(sp)
    80002fe6:	6105                	addi	sp,sp,32
    80002fe8:	8082                	ret
    panic("bwrite");
    80002fea:	00004517          	auipc	a0,0x4
    80002fee:	51650513          	addi	a0,a0,1302 # 80007500 <etext+0x500>
    80002ff2:	ffefd0ef          	jal	800007f0 <panic>

0000000080002ff6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ff6:	1101                	addi	sp,sp,-32
    80002ff8:	ec06                	sd	ra,24(sp)
    80002ffa:	e822                	sd	s0,16(sp)
    80002ffc:	e426                	sd	s1,8(sp)
    80002ffe:	e04a                	sd	s2,0(sp)
    80003000:	1000                	addi	s0,sp,32
    80003002:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003004:	01050913          	addi	s2,a0,16
    80003008:	854a                	mv	a0,s2
    8000300a:	392010ef          	jal	8000439c <holdingsleep>
    8000300e:	c135                	beqz	a0,80003072 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003010:	854a                	mv	a0,s2
    80003012:	352010ef          	jal	80004364 <releasesleep>

  acquire(&bcache.lock);
    80003016:	00015517          	auipc	a0,0x15
    8000301a:	75250513          	addi	a0,a0,1874 # 80018768 <bcache>
    8000301e:	bb5fd0ef          	jal	80000bd2 <acquire>
  b->refcnt--;
    80003022:	40bc                	lw	a5,64(s1)
    80003024:	37fd                	addiw	a5,a5,-1
    80003026:	0007871b          	sext.w	a4,a5
    8000302a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000302c:	e71d                	bnez	a4,8000305a <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000302e:	68b8                	ld	a4,80(s1)
    80003030:	64bc                	ld	a5,72(s1)
    80003032:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003034:	68b8                	ld	a4,80(s1)
    80003036:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003038:	0001d797          	auipc	a5,0x1d
    8000303c:	73078793          	addi	a5,a5,1840 # 80020768 <bcache+0x8000>
    80003040:	2b87b703          	ld	a4,696(a5)
    80003044:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003046:	0001e717          	auipc	a4,0x1e
    8000304a:	98a70713          	addi	a4,a4,-1654 # 800209d0 <bcache+0x8268>
    8000304e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003050:	2b87b703          	ld	a4,696(a5)
    80003054:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003056:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    8000305a:	00015517          	auipc	a0,0x15
    8000305e:	70e50513          	addi	a0,a0,1806 # 80018768 <bcache>
    80003062:	bfdfd0ef          	jal	80000c5e <release>
}
    80003066:	60e2                	ld	ra,24(sp)
    80003068:	6442                	ld	s0,16(sp)
    8000306a:	64a2                	ld	s1,8(sp)
    8000306c:	6902                	ld	s2,0(sp)
    8000306e:	6105                	addi	sp,sp,32
    80003070:	8082                	ret
    panic("brelse");
    80003072:	00004517          	auipc	a0,0x4
    80003076:	49650513          	addi	a0,a0,1174 # 80007508 <etext+0x508>
    8000307a:	f76fd0ef          	jal	800007f0 <panic>

000000008000307e <bpin>:

void
bpin(struct buf *b)
{
    8000307e:	1101                	addi	sp,sp,-32
    80003080:	ec06                	sd	ra,24(sp)
    80003082:	e822                	sd	s0,16(sp)
    80003084:	e426                	sd	s1,8(sp)
    80003086:	1000                	addi	s0,sp,32
    80003088:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000308a:	00015517          	auipc	a0,0x15
    8000308e:	6de50513          	addi	a0,a0,1758 # 80018768 <bcache>
    80003092:	b41fd0ef          	jal	80000bd2 <acquire>
  b->refcnt++;
    80003096:	40bc                	lw	a5,64(s1)
    80003098:	2785                	addiw	a5,a5,1
    8000309a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000309c:	00015517          	auipc	a0,0x15
    800030a0:	6cc50513          	addi	a0,a0,1740 # 80018768 <bcache>
    800030a4:	bbbfd0ef          	jal	80000c5e <release>
}
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	64a2                	ld	s1,8(sp)
    800030ae:	6105                	addi	sp,sp,32
    800030b0:	8082                	ret

00000000800030b2 <bunpin>:

void
bunpin(struct buf *b)
{
    800030b2:	1101                	addi	sp,sp,-32
    800030b4:	ec06                	sd	ra,24(sp)
    800030b6:	e822                	sd	s0,16(sp)
    800030b8:	e426                	sd	s1,8(sp)
    800030ba:	1000                	addi	s0,sp,32
    800030bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030be:	00015517          	auipc	a0,0x15
    800030c2:	6aa50513          	addi	a0,a0,1706 # 80018768 <bcache>
    800030c6:	b0dfd0ef          	jal	80000bd2 <acquire>
  b->refcnt--;
    800030ca:	40bc                	lw	a5,64(s1)
    800030cc:	37fd                	addiw	a5,a5,-1
    800030ce:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030d0:	00015517          	auipc	a0,0x15
    800030d4:	69850513          	addi	a0,a0,1688 # 80018768 <bcache>
    800030d8:	b87fd0ef          	jal	80000c5e <release>
}
    800030dc:	60e2                	ld	ra,24(sp)
    800030de:	6442                	ld	s0,16(sp)
    800030e0:	64a2                	ld	s1,8(sp)
    800030e2:	6105                	addi	sp,sp,32
    800030e4:	8082                	ret

00000000800030e6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030e6:	1101                	addi	sp,sp,-32
    800030e8:	ec06                	sd	ra,24(sp)
    800030ea:	e822                	sd	s0,16(sp)
    800030ec:	e426                	sd	s1,8(sp)
    800030ee:	e04a                	sd	s2,0(sp)
    800030f0:	1000                	addi	s0,sp,32
    800030f2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030f4:	00d5d59b          	srliw	a1,a1,0xd
    800030f8:	0001e797          	auipc	a5,0x1e
    800030fc:	d4c7a783          	lw	a5,-692(a5) # 80020e44 <sb+0x1c>
    80003100:	9dbd                	addw	a1,a1,a5
    80003102:	dedff0ef          	jal	80002eee <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003106:	0074f713          	andi	a4,s1,7
    8000310a:	4785                	li	a5,1
    8000310c:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80003110:	14ce                	slli	s1,s1,0x33
    80003112:	90d9                	srli	s1,s1,0x36
    80003114:	00950733          	add	a4,a0,s1
    80003118:	05874703          	lbu	a4,88(a4)
    8000311c:	00e7f6b3          	and	a3,a5,a4
    80003120:	c29d                	beqz	a3,80003146 <bfree+0x60>
    80003122:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80003124:	94aa                	add	s1,s1,a0
    80003126:	fff7c793          	not	a5,a5
    8000312a:	8f7d                	and	a4,a4,a5
    8000312c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003130:	078010ef          	jal	800041a8 <log_write>
  brelse(bp);
    80003134:	854a                	mv	a0,s2
    80003136:	ec1ff0ef          	jal	80002ff6 <brelse>
}
    8000313a:	60e2                	ld	ra,24(sp)
    8000313c:	6442                	ld	s0,16(sp)
    8000313e:	64a2                	ld	s1,8(sp)
    80003140:	6902                	ld	s2,0(sp)
    80003142:	6105                	addi	sp,sp,32
    80003144:	8082                	ret
    panic("freeing free block");
    80003146:	00004517          	auipc	a0,0x4
    8000314a:	3ca50513          	addi	a0,a0,970 # 80007510 <etext+0x510>
    8000314e:	ea2fd0ef          	jal	800007f0 <panic>

0000000080003152 <balloc>:
{
    80003152:	711d                	addi	sp,sp,-96
    80003154:	ec86                	sd	ra,88(sp)
    80003156:	e8a2                	sd	s0,80(sp)
    80003158:	e4a6                	sd	s1,72(sp)
    8000315a:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    8000315c:	0001e797          	auipc	a5,0x1e
    80003160:	cd07a783          	lw	a5,-816(a5) # 80020e2c <sb+0x4>
    80003164:	0e078f63          	beqz	a5,80003262 <balloc+0x110>
    80003168:	e0ca                	sd	s2,64(sp)
    8000316a:	fc4e                	sd	s3,56(sp)
    8000316c:	f852                	sd	s4,48(sp)
    8000316e:	f456                	sd	s5,40(sp)
    80003170:	f05a                	sd	s6,32(sp)
    80003172:	ec5e                	sd	s7,24(sp)
    80003174:	e862                	sd	s8,16(sp)
    80003176:	e466                	sd	s9,8(sp)
    80003178:	8baa                	mv	s7,a0
    8000317a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000317c:	0001eb17          	auipc	s6,0x1e
    80003180:	cacb0b13          	addi	s6,s6,-852 # 80020e28 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003184:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003186:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003188:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    8000318a:	6c89                	lui	s9,0x2
    8000318c:	a0b5                	j	800031f8 <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    8000318e:	97ca                	add	a5,a5,s2
    80003190:	8e55                	or	a2,a2,a3
    80003192:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003196:	854a                	mv	a0,s2
    80003198:	010010ef          	jal	800041a8 <log_write>
        brelse(bp);
    8000319c:	854a                	mv	a0,s2
    8000319e:	e59ff0ef          	jal	80002ff6 <brelse>
  bp = bread(dev, bno);
    800031a2:	85a6                	mv	a1,s1
    800031a4:	855e                	mv	a0,s7
    800031a6:	d49ff0ef          	jal	80002eee <bread>
    800031aa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031ac:	40000613          	li	a2,1024
    800031b0:	4581                	li	a1,0
    800031b2:	05850513          	addi	a0,a0,88
    800031b6:	ae1fd0ef          	jal	80000c96 <memset>
  log_write(bp);
    800031ba:	854a                	mv	a0,s2
    800031bc:	7ed000ef          	jal	800041a8 <log_write>
  brelse(bp);
    800031c0:	854a                	mv	a0,s2
    800031c2:	e35ff0ef          	jal	80002ff6 <brelse>
}
    800031c6:	6906                	ld	s2,64(sp)
    800031c8:	79e2                	ld	s3,56(sp)
    800031ca:	7a42                	ld	s4,48(sp)
    800031cc:	7aa2                	ld	s5,40(sp)
    800031ce:	7b02                	ld	s6,32(sp)
    800031d0:	6be2                	ld	s7,24(sp)
    800031d2:	6c42                	ld	s8,16(sp)
    800031d4:	6ca2                	ld	s9,8(sp)
}
    800031d6:	8526                	mv	a0,s1
    800031d8:	60e6                	ld	ra,88(sp)
    800031da:	6446                	ld	s0,80(sp)
    800031dc:	64a6                	ld	s1,72(sp)
    800031de:	6125                	addi	sp,sp,96
    800031e0:	8082                	ret
    brelse(bp);
    800031e2:	854a                	mv	a0,s2
    800031e4:	e13ff0ef          	jal	80002ff6 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    800031e8:	015c87bb          	addw	a5,s9,s5
    800031ec:	00078a9b          	sext.w	s5,a5
    800031f0:	004b2703          	lw	a4,4(s6)
    800031f4:	04eaff63          	bgeu	s5,a4,80003252 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800031f8:	41fad79b          	sraiw	a5,s5,0x1f
    800031fc:	0137d79b          	srliw	a5,a5,0x13
    80003200:	015787bb          	addw	a5,a5,s5
    80003204:	40d7d79b          	sraiw	a5,a5,0xd
    80003208:	01cb2583          	lw	a1,28(s6)
    8000320c:	9dbd                	addw	a1,a1,a5
    8000320e:	855e                	mv	a0,s7
    80003210:	cdfff0ef          	jal	80002eee <bread>
    80003214:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003216:	004b2503          	lw	a0,4(s6)
    8000321a:	000a849b          	sext.w	s1,s5
    8000321e:	8762                	mv	a4,s8
    80003220:	fca4f1e3          	bgeu	s1,a0,800031e2 <balloc+0x90>
      m = 1 << (bi % 8);
    80003224:	00777693          	andi	a3,a4,7
    80003228:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    8000322c:	41f7579b          	sraiw	a5,a4,0x1f
    80003230:	01d7d79b          	srliw	a5,a5,0x1d
    80003234:	9fb9                	addw	a5,a5,a4
    80003236:	4037d79b          	sraiw	a5,a5,0x3
    8000323a:	00f90633          	add	a2,s2,a5
    8000323e:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003242:	00c6f5b3          	and	a1,a3,a2
    80003246:	d5a1                	beqz	a1,8000318e <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003248:	2705                	addiw	a4,a4,1
    8000324a:	2485                	addiw	s1,s1,1
    8000324c:	fd471ae3          	bne	a4,s4,80003220 <balloc+0xce>
    80003250:	bf49                	j	800031e2 <balloc+0x90>
    80003252:	6906                	ld	s2,64(sp)
    80003254:	79e2                	ld	s3,56(sp)
    80003256:	7a42                	ld	s4,48(sp)
    80003258:	7aa2                	ld	s5,40(sp)
    8000325a:	7b02                	ld	s6,32(sp)
    8000325c:	6be2                	ld	s7,24(sp)
    8000325e:	6c42                	ld	s8,16(sp)
    80003260:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    80003262:	00004517          	auipc	a0,0x4
    80003266:	2c650513          	addi	a0,a0,710 # 80007528 <etext+0x528>
    8000326a:	aa0fd0ef          	jal	8000050a <printk>
  return 0;
    8000326e:	4481                	li	s1,0
    80003270:	b79d                	j	800031d6 <balloc+0x84>

0000000080003272 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003272:	7179                	addi	sp,sp,-48
    80003274:	f406                	sd	ra,40(sp)
    80003276:	f022                	sd	s0,32(sp)
    80003278:	ec26                	sd	s1,24(sp)
    8000327a:	e84a                	sd	s2,16(sp)
    8000327c:	e44e                	sd	s3,8(sp)
    8000327e:	1800                	addi	s0,sp,48
    80003280:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80003282:	47ad                	li	a5,11
    80003284:	02b7e663          	bltu	a5,a1,800032b0 <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    80003288:	02059793          	slli	a5,a1,0x20
    8000328c:	01e7d593          	srli	a1,a5,0x1e
    80003290:	00b504b3          	add	s1,a0,a1
    80003294:	0504a903          	lw	s2,80(s1)
    80003298:	06091a63          	bnez	s2,8000330c <bmap+0x9a>
      addr = balloc(ip->dev);
    8000329c:	4108                	lw	a0,0(a0)
    8000329e:	eb5ff0ef          	jal	80003152 <balloc>
    800032a2:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800032a6:	06090363          	beqz	s2,8000330c <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800032aa:	0524a823          	sw	s2,80(s1)
    800032ae:	a8b9                	j	8000330c <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032b0:	ff45849b          	addiw	s1,a1,-12
    800032b4:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    800032b8:	0ff00793          	li	a5,255
    800032bc:	06e7ee63          	bltu	a5,a4,80003338 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800032c0:	08052903          	lw	s2,128(a0)
    800032c4:	00091d63          	bnez	s2,800032de <bmap+0x6c>
      addr = balloc(ip->dev);
    800032c8:	4108                	lw	a0,0(a0)
    800032ca:	e89ff0ef          	jal	80003152 <balloc>
    800032ce:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800032d2:	02090d63          	beqz	s2,8000330c <bmap+0x9a>
    800032d6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032d8:	0929a023          	sw	s2,128(s3)
    800032dc:	a011                	j	800032e0 <bmap+0x6e>
    800032de:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800032e0:	85ca                	mv	a1,s2
    800032e2:	0009a503          	lw	a0,0(s3)
    800032e6:	c09ff0ef          	jal	80002eee <bread>
    800032ea:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800032ec:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800032f0:	02049713          	slli	a4,s1,0x20
    800032f4:	01e75593          	srli	a1,a4,0x1e
    800032f8:	00b784b3          	add	s1,a5,a1
    800032fc:	0004a903          	lw	s2,0(s1)
    80003300:	00090e63          	beqz	s2,8000331c <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003304:	8552                	mv	a0,s4
    80003306:	cf1ff0ef          	jal	80002ff6 <brelse>
    return addr;
    8000330a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000330c:	854a                	mv	a0,s2
    8000330e:	70a2                	ld	ra,40(sp)
    80003310:	7402                	ld	s0,32(sp)
    80003312:	64e2                	ld	s1,24(sp)
    80003314:	6942                	ld	s2,16(sp)
    80003316:	69a2                	ld	s3,8(sp)
    80003318:	6145                	addi	sp,sp,48
    8000331a:	8082                	ret
      addr = balloc(ip->dev);
    8000331c:	0009a503          	lw	a0,0(s3)
    80003320:	e33ff0ef          	jal	80003152 <balloc>
    80003324:	0005091b          	sext.w	s2,a0
      if (addr) {
    80003328:	fc090ee3          	beqz	s2,80003304 <bmap+0x92>
        a[bn] = addr;
    8000332c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003330:	8552                	mv	a0,s4
    80003332:	677000ef          	jal	800041a8 <log_write>
    80003336:	b7f9                	j	80003304 <bmap+0x92>
    80003338:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000333a:	00004517          	auipc	a0,0x4
    8000333e:	20650513          	addi	a0,a0,518 # 80007540 <etext+0x540>
    80003342:	caefd0ef          	jal	800007f0 <panic>

0000000080003346 <iget>:
{
    80003346:	7179                	addi	sp,sp,-48
    80003348:	f406                	sd	ra,40(sp)
    8000334a:	f022                	sd	s0,32(sp)
    8000334c:	ec26                	sd	s1,24(sp)
    8000334e:	e84a                	sd	s2,16(sp)
    80003350:	e44e                	sd	s3,8(sp)
    80003352:	e052                	sd	s4,0(sp)
    80003354:	1800                	addi	s0,sp,48
    80003356:	89aa                	mv	s3,a0
    80003358:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000335a:	0001e517          	auipc	a0,0x1e
    8000335e:	aee50513          	addi	a0,a0,-1298 # 80020e48 <itable>
    80003362:	871fd0ef          	jal	80000bd2 <acquire>
  empty = 0;
    80003366:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003368:	0001e497          	auipc	s1,0x1e
    8000336c:	af848493          	addi	s1,s1,-1288 # 80020e60 <itable+0x18>
    80003370:	0001f697          	auipc	a3,0x1f
    80003374:	58068693          	addi	a3,a3,1408 # 800228f0 <log>
    80003378:	a039                	j	80003386 <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000337a:	02090963          	beqz	s2,800033ac <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000337e:	08848493          	addi	s1,s1,136
    80003382:	02d48863          	beq	s1,a3,800033b2 <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003386:	449c                	lw	a5,8(s1)
    80003388:	fef059e3          	blez	a5,8000337a <iget+0x34>
    8000338c:	4098                	lw	a4,0(s1)
    8000338e:	ff3716e3          	bne	a4,s3,8000337a <iget+0x34>
    80003392:	40d8                	lw	a4,4(s1)
    80003394:	ff4713e3          	bne	a4,s4,8000337a <iget+0x34>
      ip->ref++;
    80003398:	2785                	addiw	a5,a5,1
    8000339a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000339c:	0001e517          	auipc	a0,0x1e
    800033a0:	aac50513          	addi	a0,a0,-1364 # 80020e48 <itable>
    800033a4:	8bbfd0ef          	jal	80000c5e <release>
      return ip;
    800033a8:	8926                	mv	s2,s1
    800033aa:	a02d                	j	800033d4 <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800033ac:	fbe9                	bnez	a5,8000337e <iget+0x38>
      empty = ip;
    800033ae:	8926                	mv	s2,s1
    800033b0:	b7f9                	j	8000337e <iget+0x38>
  if (empty == 0)
    800033b2:	02090a63          	beqz	s2,800033e6 <iget+0xa0>
  ip->dev = dev;
    800033b6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033ba:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033be:	4785                	li	a5,1
    800033c0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033c4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033c8:	0001e517          	auipc	a0,0x1e
    800033cc:	a8050513          	addi	a0,a0,-1408 # 80020e48 <itable>
    800033d0:	88ffd0ef          	jal	80000c5e <release>
}
    800033d4:	854a                	mv	a0,s2
    800033d6:	70a2                	ld	ra,40(sp)
    800033d8:	7402                	ld	s0,32(sp)
    800033da:	64e2                	ld	s1,24(sp)
    800033dc:	6942                	ld	s2,16(sp)
    800033de:	69a2                	ld	s3,8(sp)
    800033e0:	6a02                	ld	s4,0(sp)
    800033e2:	6145                	addi	sp,sp,48
    800033e4:	8082                	ret
    panic("iget: no inodes");
    800033e6:	00004517          	auipc	a0,0x4
    800033ea:	17250513          	addi	a0,a0,370 # 80007558 <etext+0x558>
    800033ee:	c02fd0ef          	jal	800007f0 <panic>

00000000800033f2 <iinit>:
{
    800033f2:	7179                	addi	sp,sp,-48
    800033f4:	f406                	sd	ra,40(sp)
    800033f6:	f022                	sd	s0,32(sp)
    800033f8:	ec26                	sd	s1,24(sp)
    800033fa:	e84a                	sd	s2,16(sp)
    800033fc:	e44e                	sd	s3,8(sp)
    800033fe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003400:	00004597          	auipc	a1,0x4
    80003404:	16858593          	addi	a1,a1,360 # 80007568 <etext+0x568>
    80003408:	0001e517          	auipc	a0,0x1e
    8000340c:	a4050513          	addi	a0,a0,-1472 # 80020e48 <itable>
    80003410:	f4cfd0ef          	jal	80000b5c <initlock>
  for (i = 0; i < NINODE; i++) {
    80003414:	0001e497          	auipc	s1,0x1e
    80003418:	a5c48493          	addi	s1,s1,-1444 # 80020e70 <itable+0x28>
    8000341c:	0001f997          	auipc	s3,0x1f
    80003420:	4e498993          	addi	s3,s3,1252 # 80022900 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003424:	00004917          	auipc	s2,0x4
    80003428:	14c90913          	addi	s2,s2,332 # 80007570 <etext+0x570>
    8000342c:	85ca                	mv	a1,s2
    8000342e:	8526                	mv	a0,s1
    80003430:	6ab000ef          	jal	800042da <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003434:	08848493          	addi	s1,s1,136
    80003438:	ff349ae3          	bne	s1,s3,8000342c <iinit+0x3a>
}
    8000343c:	70a2                	ld	ra,40(sp)
    8000343e:	7402                	ld	s0,32(sp)
    80003440:	64e2                	ld	s1,24(sp)
    80003442:	6942                	ld	s2,16(sp)
    80003444:	69a2                	ld	s3,8(sp)
    80003446:	6145                	addi	sp,sp,48
    80003448:	8082                	ret

000000008000344a <ialloc>:
{
    8000344a:	7139                	addi	sp,sp,-64
    8000344c:	fc06                	sd	ra,56(sp)
    8000344e:	f822                	sd	s0,48(sp)
    80003450:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003452:	0001e717          	auipc	a4,0x1e
    80003456:	9e272703          	lw	a4,-1566(a4) # 80020e34 <sb+0xc>
    8000345a:	4785                	li	a5,1
    8000345c:	06e7f063          	bgeu	a5,a4,800034bc <ialloc+0x72>
    80003460:	f426                	sd	s1,40(sp)
    80003462:	f04a                	sd	s2,32(sp)
    80003464:	ec4e                	sd	s3,24(sp)
    80003466:	e852                	sd	s4,16(sp)
    80003468:	e456                	sd	s5,8(sp)
    8000346a:	e05a                	sd	s6,0(sp)
    8000346c:	8aaa                	mv	s5,a0
    8000346e:	8b2e                	mv	s6,a1
    80003470:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003472:	0001ea17          	auipc	s4,0x1e
    80003476:	9b6a0a13          	addi	s4,s4,-1610 # 80020e28 <sb>
    8000347a:	00495593          	srli	a1,s2,0x4
    8000347e:	018a2783          	lw	a5,24(s4)
    80003482:	9dbd                	addw	a1,a1,a5
    80003484:	8556                	mv	a0,s5
    80003486:	a69ff0ef          	jal	80002eee <bread>
    8000348a:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000348c:	05850993          	addi	s3,a0,88
    80003490:	00f97793          	andi	a5,s2,15
    80003494:	079a                	slli	a5,a5,0x6
    80003496:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003498:	00099783          	lh	a5,0(s3)
    8000349c:	cb9d                	beqz	a5,800034d2 <ialloc+0x88>
    brelse(bp);
    8000349e:	b59ff0ef          	jal	80002ff6 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800034a2:	0905                	addi	s2,s2,1
    800034a4:	00ca2703          	lw	a4,12(s4)
    800034a8:	0009079b          	sext.w	a5,s2
    800034ac:	fce7e7e3          	bltu	a5,a4,8000347a <ialloc+0x30>
    800034b0:	74a2                	ld	s1,40(sp)
    800034b2:	7902                	ld	s2,32(sp)
    800034b4:	69e2                	ld	s3,24(sp)
    800034b6:	6a42                	ld	s4,16(sp)
    800034b8:	6aa2                	ld	s5,8(sp)
    800034ba:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800034bc:	00004517          	auipc	a0,0x4
    800034c0:	0bc50513          	addi	a0,a0,188 # 80007578 <etext+0x578>
    800034c4:	846fd0ef          	jal	8000050a <printk>
  return 0;
    800034c8:	4501                	li	a0,0
}
    800034ca:	70e2                	ld	ra,56(sp)
    800034cc:	7442                	ld	s0,48(sp)
    800034ce:	6121                	addi	sp,sp,64
    800034d0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800034d2:	04000613          	li	a2,64
    800034d6:	4581                	li	a1,0
    800034d8:	854e                	mv	a0,s3
    800034da:	fbcfd0ef          	jal	80000c96 <memset>
      dip->type = type;
    800034de:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800034e2:	8526                	mv	a0,s1
    800034e4:	4c5000ef          	jal	800041a8 <log_write>
      brelse(bp);
    800034e8:	8526                	mv	a0,s1
    800034ea:	b0dff0ef          	jal	80002ff6 <brelse>
      return iget(dev, inum);
    800034ee:	0009059b          	sext.w	a1,s2
    800034f2:	8556                	mv	a0,s5
    800034f4:	e53ff0ef          	jal	80003346 <iget>
    800034f8:	74a2                	ld	s1,40(sp)
    800034fa:	7902                	ld	s2,32(sp)
    800034fc:	69e2                	ld	s3,24(sp)
    800034fe:	6a42                	ld	s4,16(sp)
    80003500:	6aa2                	ld	s5,8(sp)
    80003502:	6b02                	ld	s6,0(sp)
    80003504:	b7d9                	j	800034ca <ialloc+0x80>

0000000080003506 <iupdate>:
{
    80003506:	1101                	addi	sp,sp,-32
    80003508:	ec06                	sd	ra,24(sp)
    8000350a:	e822                	sd	s0,16(sp)
    8000350c:	e426                	sd	s1,8(sp)
    8000350e:	e04a                	sd	s2,0(sp)
    80003510:	1000                	addi	s0,sp,32
    80003512:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003514:	415c                	lw	a5,4(a0)
    80003516:	0047d79b          	srliw	a5,a5,0x4
    8000351a:	0001e597          	auipc	a1,0x1e
    8000351e:	9265a583          	lw	a1,-1754(a1) # 80020e40 <sb+0x18>
    80003522:	9dbd                	addw	a1,a1,a5
    80003524:	4108                	lw	a0,0(a0)
    80003526:	9c9ff0ef          	jal	80002eee <bread>
    8000352a:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000352c:	05850793          	addi	a5,a0,88
    80003530:	40d8                	lw	a4,4(s1)
    80003532:	8b3d                	andi	a4,a4,15
    80003534:	071a                	slli	a4,a4,0x6
    80003536:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003538:	04449703          	lh	a4,68(s1)
    8000353c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003540:	04649703          	lh	a4,70(s1)
    80003544:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003548:	04849703          	lh	a4,72(s1)
    8000354c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003550:	04a49703          	lh	a4,74(s1)
    80003554:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003558:	44f8                	lw	a4,76(s1)
    8000355a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000355c:	03400613          	li	a2,52
    80003560:	05048593          	addi	a1,s1,80
    80003564:	00c78513          	addi	a0,a5,12
    80003568:	f8afd0ef          	jal	80000cf2 <memmove>
  log_write(bp);
    8000356c:	854a                	mv	a0,s2
    8000356e:	43b000ef          	jal	800041a8 <log_write>
  brelse(bp);
    80003572:	854a                	mv	a0,s2
    80003574:	a83ff0ef          	jal	80002ff6 <brelse>
}
    80003578:	60e2                	ld	ra,24(sp)
    8000357a:	6442                	ld	s0,16(sp)
    8000357c:	64a2                	ld	s1,8(sp)
    8000357e:	6902                	ld	s2,0(sp)
    80003580:	6105                	addi	sp,sp,32
    80003582:	8082                	ret

0000000080003584 <idup>:
{
    80003584:	1101                	addi	sp,sp,-32
    80003586:	ec06                	sd	ra,24(sp)
    80003588:	e822                	sd	s0,16(sp)
    8000358a:	e426                	sd	s1,8(sp)
    8000358c:	1000                	addi	s0,sp,32
    8000358e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003590:	0001e517          	auipc	a0,0x1e
    80003594:	8b850513          	addi	a0,a0,-1864 # 80020e48 <itable>
    80003598:	e3afd0ef          	jal	80000bd2 <acquire>
  ip->ref++;
    8000359c:	449c                	lw	a5,8(s1)
    8000359e:	2785                	addiw	a5,a5,1
    800035a0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035a2:	0001e517          	auipc	a0,0x1e
    800035a6:	8a650513          	addi	a0,a0,-1882 # 80020e48 <itable>
    800035aa:	eb4fd0ef          	jal	80000c5e <release>
}
    800035ae:	8526                	mv	a0,s1
    800035b0:	60e2                	ld	ra,24(sp)
    800035b2:	6442                	ld	s0,16(sp)
    800035b4:	64a2                	ld	s1,8(sp)
    800035b6:	6105                	addi	sp,sp,32
    800035b8:	8082                	ret

00000000800035ba <ilock>:
{
    800035ba:	1101                	addi	sp,sp,-32
    800035bc:	ec06                	sd	ra,24(sp)
    800035be:	e822                	sd	s0,16(sp)
    800035c0:	e426                	sd	s1,8(sp)
    800035c2:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800035c4:	cd19                	beqz	a0,800035e2 <ilock+0x28>
    800035c6:	84aa                	mv	s1,a0
    800035c8:	451c                	lw	a5,8(a0)
    800035ca:	00f05c63          	blez	a5,800035e2 <ilock+0x28>
  acquiresleep(&ip->lock);
    800035ce:	0541                	addi	a0,a0,16
    800035d0:	541000ef          	jal	80004310 <acquiresleep>
  if (ip->valid == 0) {
    800035d4:	40bc                	lw	a5,64(s1)
    800035d6:	cf89                	beqz	a5,800035f0 <ilock+0x36>
}
    800035d8:	60e2                	ld	ra,24(sp)
    800035da:	6442                	ld	s0,16(sp)
    800035dc:	64a2                	ld	s1,8(sp)
    800035de:	6105                	addi	sp,sp,32
    800035e0:	8082                	ret
    800035e2:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035e4:	00004517          	auipc	a0,0x4
    800035e8:	fac50513          	addi	a0,a0,-84 # 80007590 <etext+0x590>
    800035ec:	a04fd0ef          	jal	800007f0 <panic>
    800035f0:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035f2:	40dc                	lw	a5,4(s1)
    800035f4:	0047d79b          	srliw	a5,a5,0x4
    800035f8:	0001e597          	auipc	a1,0x1e
    800035fc:	8485a583          	lw	a1,-1976(a1) # 80020e40 <sb+0x18>
    80003600:	9dbd                	addw	a1,a1,a5
    80003602:	4088                	lw	a0,0(s1)
    80003604:	8ebff0ef          	jal	80002eee <bread>
    80003608:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000360a:	05850593          	addi	a1,a0,88
    8000360e:	40dc                	lw	a5,4(s1)
    80003610:	8bbd                	andi	a5,a5,15
    80003612:	079a                	slli	a5,a5,0x6
    80003614:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003616:	00059783          	lh	a5,0(a1)
    8000361a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000361e:	00259783          	lh	a5,2(a1)
    80003622:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003626:	00459783          	lh	a5,4(a1)
    8000362a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000362e:	00659783          	lh	a5,6(a1)
    80003632:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003636:	459c                	lw	a5,8(a1)
    80003638:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000363a:	03400613          	li	a2,52
    8000363e:	05b1                	addi	a1,a1,12
    80003640:	05048513          	addi	a0,s1,80
    80003644:	eaefd0ef          	jal	80000cf2 <memmove>
    brelse(bp);
    80003648:	854a                	mv	a0,s2
    8000364a:	9adff0ef          	jal	80002ff6 <brelse>
    ip->valid = 1;
    8000364e:	4785                	li	a5,1
    80003650:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003652:	04449783          	lh	a5,68(s1)
    80003656:	c399                	beqz	a5,8000365c <ilock+0xa2>
    80003658:	6902                	ld	s2,0(sp)
    8000365a:	bfbd                	j	800035d8 <ilock+0x1e>
      panic("ilock: no type");
    8000365c:	00004517          	auipc	a0,0x4
    80003660:	f3c50513          	addi	a0,a0,-196 # 80007598 <etext+0x598>
    80003664:	98cfd0ef          	jal	800007f0 <panic>

0000000080003668 <iunlock>:
{
    80003668:	1101                	addi	sp,sp,-32
    8000366a:	ec06                	sd	ra,24(sp)
    8000366c:	e822                	sd	s0,16(sp)
    8000366e:	e426                	sd	s1,8(sp)
    80003670:	e04a                	sd	s2,0(sp)
    80003672:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003674:	c505                	beqz	a0,8000369c <iunlock+0x34>
    80003676:	84aa                	mv	s1,a0
    80003678:	01050913          	addi	s2,a0,16
    8000367c:	854a                	mv	a0,s2
    8000367e:	51f000ef          	jal	8000439c <holdingsleep>
    80003682:	cd09                	beqz	a0,8000369c <iunlock+0x34>
    80003684:	449c                	lw	a5,8(s1)
    80003686:	00f05b63          	blez	a5,8000369c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000368a:	854a                	mv	a0,s2
    8000368c:	4d9000ef          	jal	80004364 <releasesleep>
}
    80003690:	60e2                	ld	ra,24(sp)
    80003692:	6442                	ld	s0,16(sp)
    80003694:	64a2                	ld	s1,8(sp)
    80003696:	6902                	ld	s2,0(sp)
    80003698:	6105                	addi	sp,sp,32
    8000369a:	8082                	ret
    panic("iunlock");
    8000369c:	00004517          	auipc	a0,0x4
    800036a0:	f0c50513          	addi	a0,a0,-244 # 800075a8 <etext+0x5a8>
    800036a4:	94cfd0ef          	jal	800007f0 <panic>

00000000800036a8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800036a8:	7179                	addi	sp,sp,-48
    800036aa:	f406                	sd	ra,40(sp)
    800036ac:	f022                	sd	s0,32(sp)
    800036ae:	ec26                	sd	s1,24(sp)
    800036b0:	e84a                	sd	s2,16(sp)
    800036b2:	e44e                	sd	s3,8(sp)
    800036b4:	1800                	addi	s0,sp,48
    800036b6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800036b8:	05050493          	addi	s1,a0,80
    800036bc:	08050913          	addi	s2,a0,128
    800036c0:	a021                	j	800036c8 <itrunc+0x20>
    800036c2:	0491                	addi	s1,s1,4
    800036c4:	01248b63          	beq	s1,s2,800036da <itrunc+0x32>
    if (ip->addrs[i]) {
    800036c8:	408c                	lw	a1,0(s1)
    800036ca:	dde5                	beqz	a1,800036c2 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800036cc:	0009a503          	lw	a0,0(s3)
    800036d0:	a17ff0ef          	jal	800030e6 <bfree>
      ip->addrs[i] = 0;
    800036d4:	0004a023          	sw	zero,0(s1)
    800036d8:	b7ed                	j	800036c2 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800036da:	0809a583          	lw	a1,128(s3)
    800036de:	ed89                	bnez	a1,800036f8 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036e0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036e4:	854e                	mv	a0,s3
    800036e6:	e21ff0ef          	jal	80003506 <iupdate>
}
    800036ea:	70a2                	ld	ra,40(sp)
    800036ec:	7402                	ld	s0,32(sp)
    800036ee:	64e2                	ld	s1,24(sp)
    800036f0:	6942                	ld	s2,16(sp)
    800036f2:	69a2                	ld	s3,8(sp)
    800036f4:	6145                	addi	sp,sp,48
    800036f6:	8082                	ret
    800036f8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800036fa:	0009a503          	lw	a0,0(s3)
    800036fe:	ff0ff0ef          	jal	80002eee <bread>
    80003702:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003704:	05850493          	addi	s1,a0,88
    80003708:	45850913          	addi	s2,a0,1112
    8000370c:	a021                	j	80003714 <itrunc+0x6c>
    8000370e:	0491                	addi	s1,s1,4
    80003710:	01248963          	beq	s1,s2,80003722 <itrunc+0x7a>
      if (a[j])
    80003714:	408c                	lw	a1,0(s1)
    80003716:	dde5                	beqz	a1,8000370e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003718:	0009a503          	lw	a0,0(s3)
    8000371c:	9cbff0ef          	jal	800030e6 <bfree>
    80003720:	b7fd                	j	8000370e <itrunc+0x66>
    brelse(bp);
    80003722:	8552                	mv	a0,s4
    80003724:	8d3ff0ef          	jal	80002ff6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003728:	0809a583          	lw	a1,128(s3)
    8000372c:	0009a503          	lw	a0,0(s3)
    80003730:	9b7ff0ef          	jal	800030e6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003734:	0809a023          	sw	zero,128(s3)
    80003738:	6a02                	ld	s4,0(sp)
    8000373a:	b75d                	j	800036e0 <itrunc+0x38>

000000008000373c <iput>:
{
    8000373c:	7179                	addi	sp,sp,-48
    8000373e:	f406                	sd	ra,40(sp)
    80003740:	f022                	sd	s0,32(sp)
    80003742:	ec26                	sd	s1,24(sp)
    80003744:	1800                	addi	s0,sp,48
    80003746:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003748:	0001d517          	auipc	a0,0x1d
    8000374c:	70050513          	addi	a0,a0,1792 # 80020e48 <itable>
    80003750:	c82fd0ef          	jal	80000bd2 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003754:	449c                	lw	a5,8(s1)
    80003756:	4705                	li	a4,1
    80003758:	00e78f63          	beq	a5,a4,80003776 <iput+0x3a>
  ip->ref--;
    8000375c:	37fd                	addiw	a5,a5,-1
    8000375e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003760:	0001d517          	auipc	a0,0x1d
    80003764:	6e850513          	addi	a0,a0,1768 # 80020e48 <itable>
    80003768:	cf6fd0ef          	jal	80000c5e <release>
}
    8000376c:	70a2                	ld	ra,40(sp)
    8000376e:	7402                	ld	s0,32(sp)
    80003770:	64e2                	ld	s1,24(sp)
    80003772:	6145                	addi	sp,sp,48
    80003774:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003776:	40b8                	lw	a4,64(s1)
    80003778:	d375                	beqz	a4,8000375c <iput+0x20>
    8000377a:	e84a                	sd	s2,16(sp)
    8000377c:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    8000377e:	0004aa03          	lw	s4,0(s1)
    80003782:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003786:	04a49703          	lh	a4,74(s1)
    8000378a:	ef35                	bnez	a4,80003806 <iput+0xca>
    8000378c:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    8000378e:	01048993          	addi	s3,s1,16
    80003792:	854e                	mv	a0,s3
    80003794:	37d000ef          	jal	80004310 <acquiresleep>
    release(&itable.lock);
    80003798:	0001d517          	auipc	a0,0x1d
    8000379c:	6b050513          	addi	a0,a0,1712 # 80020e48 <itable>
    800037a0:	cbefd0ef          	jal	80000c5e <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800037a4:	8526                	mv	a0,s1
    800037a6:	f03ff0ef          	jal	800036a8 <itrunc>
    ip->valid = 0;
    800037aa:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037ae:	854e                	mv	a0,s3
    800037b0:	3b5000ef          	jal	80004364 <releasesleep>
    acquire(&itable.lock);
    800037b4:	0001d517          	auipc	a0,0x1d
    800037b8:	69450513          	addi	a0,a0,1684 # 80020e48 <itable>
    800037bc:	c16fd0ef          	jal	80000bd2 <acquire>
  ip->ref--;
    800037c0:	449c                	lw	a5,8(s1)
    800037c2:	37fd                	addiw	a5,a5,-1
    800037c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037c6:	0001d517          	auipc	a0,0x1d
    800037ca:	68250513          	addi	a0,a0,1666 # 80020e48 <itable>
    800037ce:	c90fd0ef          	jal	80000c5e <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800037d2:	0049559b          	srliw	a1,s2,0x4
    800037d6:	0001d797          	auipc	a5,0x1d
    800037da:	66a7a783          	lw	a5,1642(a5) # 80020e40 <sb+0x18>
    800037de:	9dbd                	addw	a1,a1,a5
    800037e0:	8552                	mv	a0,s4
    800037e2:	f0cff0ef          	jal	80002eee <bread>
    800037e6:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037e8:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    800037ec:	091a                	slli	s2,s2,0x6
    800037ee:	992a                	add	s2,s2,a0
    800037f0:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    800037f4:	1b5000ef          	jal	800041a8 <log_write>
  brelse(bp);
    800037f8:	8526                	mv	a0,s1
    800037fa:	ffcff0ef          	jal	80002ff6 <brelse>
}
    800037fe:	6942                	ld	s2,16(sp)
    80003800:	69a2                	ld	s3,8(sp)
    80003802:	6a02                	ld	s4,0(sp)
    80003804:	b7a5                	j	8000376c <iput+0x30>
    80003806:	6942                	ld	s2,16(sp)
    80003808:	6a02                	ld	s4,0(sp)
    8000380a:	bf89                	j	8000375c <iput+0x20>

000000008000380c <iunlockput>:
{
    8000380c:	1101                	addi	sp,sp,-32
    8000380e:	ec06                	sd	ra,24(sp)
    80003810:	e822                	sd	s0,16(sp)
    80003812:	e426                	sd	s1,8(sp)
    80003814:	1000                	addi	s0,sp,32
    80003816:	84aa                	mv	s1,a0
  iunlock(ip);
    80003818:	e51ff0ef          	jal	80003668 <iunlock>
  iput(ip);
    8000381c:	8526                	mv	a0,s1
    8000381e:	f1fff0ef          	jal	8000373c <iput>
}
    80003822:	60e2                	ld	ra,24(sp)
    80003824:	6442                	ld	s0,16(sp)
    80003826:	64a2                	ld	s1,8(sp)
    80003828:	6105                	addi	sp,sp,32
    8000382a:	8082                	ret

000000008000382c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000382c:	0001d717          	auipc	a4,0x1d
    80003830:	60872703          	lw	a4,1544(a4) # 80020e34 <sb+0xc>
    80003834:	4785                	li	a5,1
    80003836:	0ae7ff63          	bgeu	a5,a4,800038f4 <ireclaim+0xc8>
{
    8000383a:	7139                	addi	sp,sp,-64
    8000383c:	fc06                	sd	ra,56(sp)
    8000383e:	f822                	sd	s0,48(sp)
    80003840:	f426                	sd	s1,40(sp)
    80003842:	f04a                	sd	s2,32(sp)
    80003844:	ec4e                	sd	s3,24(sp)
    80003846:	e852                	sd	s4,16(sp)
    80003848:	e456                	sd	s5,8(sp)
    8000384a:	e05a                	sd	s6,0(sp)
    8000384c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000384e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003850:	00050a1b          	sext.w	s4,a0
    80003854:	0001da97          	auipc	s5,0x1d
    80003858:	5d4a8a93          	addi	s5,s5,1492 # 80020e28 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000385c:	00004b17          	auipc	s6,0x4
    80003860:	d54b0b13          	addi	s6,s6,-684 # 800075b0 <etext+0x5b0>
    80003864:	a099                	j	800038aa <ireclaim+0x7e>
    80003866:	85ce                	mv	a1,s3
    80003868:	855a                	mv	a0,s6
    8000386a:	ca1fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    8000386e:	85ce                	mv	a1,s3
    80003870:	8552                	mv	a0,s4
    80003872:	ad5ff0ef          	jal	80003346 <iget>
    80003876:	89aa                	mv	s3,a0
    brelse(bp);
    80003878:	854a                	mv	a0,s2
    8000387a:	f7cff0ef          	jal	80002ff6 <brelse>
    if (ip) {
    8000387e:	00098f63          	beqz	s3,8000389c <ireclaim+0x70>
      begin_op();
    80003882:	780000ef          	jal	80004002 <begin_op>
      ilock(ip);
    80003886:	854e                	mv	a0,s3
    80003888:	d33ff0ef          	jal	800035ba <ilock>
      iunlock(ip);
    8000388c:	854e                	mv	a0,s3
    8000388e:	ddbff0ef          	jal	80003668 <iunlock>
      iput(ip);
    80003892:	854e                	mv	a0,s3
    80003894:	ea9ff0ef          	jal	8000373c <iput>
      end_op();
    80003898:	7f0000ef          	jal	80004088 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000389c:	0485                	addi	s1,s1,1
    8000389e:	00caa703          	lw	a4,12(s5)
    800038a2:	0004879b          	sext.w	a5,s1
    800038a6:	02e7fd63          	bgeu	a5,a4,800038e0 <ireclaim+0xb4>
    800038aa:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800038ae:	0044d593          	srli	a1,s1,0x4
    800038b2:	018aa783          	lw	a5,24(s5)
    800038b6:	9dbd                	addw	a1,a1,a5
    800038b8:	8552                	mv	a0,s4
    800038ba:	e34ff0ef          	jal	80002eee <bread>
    800038be:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800038c0:	05850793          	addi	a5,a0,88
    800038c4:	00f9f713          	andi	a4,s3,15
    800038c8:	071a                	slli	a4,a4,0x6
    800038ca:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800038cc:	00079703          	lh	a4,0(a5)
    800038d0:	c701                	beqz	a4,800038d8 <ireclaim+0xac>
    800038d2:	00679783          	lh	a5,6(a5)
    800038d6:	dbc1                	beqz	a5,80003866 <ireclaim+0x3a>
    brelse(bp);
    800038d8:	854a                	mv	a0,s2
    800038da:	f1cff0ef          	jal	80002ff6 <brelse>
    if (ip) {
    800038de:	bf7d                	j	8000389c <ireclaim+0x70>
}
    800038e0:	70e2                	ld	ra,56(sp)
    800038e2:	7442                	ld	s0,48(sp)
    800038e4:	74a2                	ld	s1,40(sp)
    800038e6:	7902                	ld	s2,32(sp)
    800038e8:	69e2                	ld	s3,24(sp)
    800038ea:	6a42                	ld	s4,16(sp)
    800038ec:	6aa2                	ld	s5,8(sp)
    800038ee:	6b02                	ld	s6,0(sp)
    800038f0:	6121                	addi	sp,sp,64
    800038f2:	8082                	ret
    800038f4:	8082                	ret

00000000800038f6 <fsinit>:
{
    800038f6:	7179                	addi	sp,sp,-48
    800038f8:	f406                	sd	ra,40(sp)
    800038fa:	f022                	sd	s0,32(sp)
    800038fc:	ec26                	sd	s1,24(sp)
    800038fe:	e84a                	sd	s2,16(sp)
    80003900:	e44e                	sd	s3,8(sp)
    80003902:	1800                	addi	s0,sp,48
    80003904:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003906:	4585                	li	a1,1
    80003908:	de6ff0ef          	jal	80002eee <bread>
    8000390c:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000390e:	0001d997          	auipc	s3,0x1d
    80003912:	51a98993          	addi	s3,s3,1306 # 80020e28 <sb>
    80003916:	02000613          	li	a2,32
    8000391a:	05850593          	addi	a1,a0,88
    8000391e:	854e                	mv	a0,s3
    80003920:	bd2fd0ef          	jal	80000cf2 <memmove>
  brelse(bp);
    80003924:	854a                	mv	a0,s2
    80003926:	ed0ff0ef          	jal	80002ff6 <brelse>
  if (sb.magic != FSMAGIC)
    8000392a:	0009a703          	lw	a4,0(s3)
    8000392e:	102037b7          	lui	a5,0x10203
    80003932:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003936:	02f71363          	bne	a4,a5,8000395c <fsinit+0x66>
  initlog(dev, &sb);
    8000393a:	0001d597          	auipc	a1,0x1d
    8000393e:	4ee58593          	addi	a1,a1,1262 # 80020e28 <sb>
    80003942:	8526                	mv	a0,s1
    80003944:	640000ef          	jal	80003f84 <initlog>
  ireclaim(dev);
    80003948:	8526                	mv	a0,s1
    8000394a:	ee3ff0ef          	jal	8000382c <ireclaim>
}
    8000394e:	70a2                	ld	ra,40(sp)
    80003950:	7402                	ld	s0,32(sp)
    80003952:	64e2                	ld	s1,24(sp)
    80003954:	6942                	ld	s2,16(sp)
    80003956:	69a2                	ld	s3,8(sp)
    80003958:	6145                	addi	sp,sp,48
    8000395a:	8082                	ret
    panic("invalid file system");
    8000395c:	00004517          	auipc	a0,0x4
    80003960:	c7450513          	addi	a0,a0,-908 # 800075d0 <etext+0x5d0>
    80003964:	e8dfc0ef          	jal	800007f0 <panic>

0000000080003968 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003968:	1141                	addi	sp,sp,-16
    8000396a:	e422                	sd	s0,8(sp)
    8000396c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000396e:	411c                	lw	a5,0(a0)
    80003970:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003972:	415c                	lw	a5,4(a0)
    80003974:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003976:	04451783          	lh	a5,68(a0)
    8000397a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000397e:	04a51783          	lh	a5,74(a0)
    80003982:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003986:	04c56783          	lwu	a5,76(a0)
    8000398a:	e99c                	sd	a5,16(a1)
}
    8000398c:	6422                	ld	s0,8(sp)
    8000398e:	0141                	addi	sp,sp,16
    80003990:	8082                	ret

0000000080003992 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003992:	457c                	lw	a5,76(a0)
    80003994:	0ed7eb63          	bltu	a5,a3,80003a8a <readi+0xf8>
{
    80003998:	7159                	addi	sp,sp,-112
    8000399a:	f486                	sd	ra,104(sp)
    8000399c:	f0a2                	sd	s0,96(sp)
    8000399e:	eca6                	sd	s1,88(sp)
    800039a0:	e0d2                	sd	s4,64(sp)
    800039a2:	fc56                	sd	s5,56(sp)
    800039a4:	f85a                	sd	s6,48(sp)
    800039a6:	f45e                	sd	s7,40(sp)
    800039a8:	1880                	addi	s0,sp,112
    800039aa:	8b2a                	mv	s6,a0
    800039ac:	8bae                	mv	s7,a1
    800039ae:	8a32                	mv	s4,a2
    800039b0:	84b6                	mv	s1,a3
    800039b2:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800039b4:	9f35                	addw	a4,a4,a3
    return 0;
    800039b6:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800039b8:	0cd76063          	bltu	a4,a3,80003a78 <readi+0xe6>
    800039bc:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800039be:	00e7f463          	bgeu	a5,a4,800039c6 <readi+0x34>
    n = ip->size - off;
    800039c2:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800039c6:	080a8f63          	beqz	s5,80003a64 <readi+0xd2>
    800039ca:	e8ca                	sd	s2,80(sp)
    800039cc:	f062                	sd	s8,32(sp)
    800039ce:	ec66                	sd	s9,24(sp)
    800039d0:	e86a                	sd	s10,16(sp)
    800039d2:	e46e                	sd	s11,8(sp)
    800039d4:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800039d6:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039da:	5c7d                	li	s8,-1
    800039dc:	a80d                	j	80003a0e <readi+0x7c>
    800039de:	020d1d93          	slli	s11,s10,0x20
    800039e2:	020ddd93          	srli	s11,s11,0x20
    800039e6:	05890613          	addi	a2,s2,88
    800039ea:	86ee                	mv	a3,s11
    800039ec:	963a                	add	a2,a2,a4
    800039ee:	85d2                	mv	a1,s4
    800039f0:	855e                	mv	a0,s7
    800039f2:	897fe0ef          	jal	80002288 <either_copyout>
    800039f6:	05850763          	beq	a0,s8,80003a44 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039fa:	854a                	mv	a0,s2
    800039fc:	dfaff0ef          	jal	80002ff6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003a00:	013d09bb          	addw	s3,s10,s3
    80003a04:	009d04bb          	addw	s1,s10,s1
    80003a08:	9a6e                	add	s4,s4,s11
    80003a0a:	0559f763          	bgeu	s3,s5,80003a58 <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    80003a0e:	00a4d59b          	srliw	a1,s1,0xa
    80003a12:	855a                	mv	a0,s6
    80003a14:	85fff0ef          	jal	80003272 <bmap>
    80003a18:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003a1c:	c5b1                	beqz	a1,80003a68 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003a1e:	000b2503          	lw	a0,0(s6)
    80003a22:	cccff0ef          	jal	80002eee <bread>
    80003a26:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003a28:	3ff4f713          	andi	a4,s1,1023
    80003a2c:	40ec87bb          	subw	a5,s9,a4
    80003a30:	413a86bb          	subw	a3,s5,s3
    80003a34:	8d3e                	mv	s10,a5
    80003a36:	2781                	sext.w	a5,a5
    80003a38:	0006861b          	sext.w	a2,a3
    80003a3c:	faf671e3          	bgeu	a2,a5,800039de <readi+0x4c>
    80003a40:	8d36                	mv	s10,a3
    80003a42:	bf71                	j	800039de <readi+0x4c>
      brelse(bp);
    80003a44:	854a                	mv	a0,s2
    80003a46:	db0ff0ef          	jal	80002ff6 <brelse>
      tot = -1;
    80003a4a:	59fd                	li	s3,-1
      break;
    80003a4c:	6946                	ld	s2,80(sp)
    80003a4e:	7c02                	ld	s8,32(sp)
    80003a50:	6ce2                	ld	s9,24(sp)
    80003a52:	6d42                	ld	s10,16(sp)
    80003a54:	6da2                	ld	s11,8(sp)
    80003a56:	a831                	j	80003a72 <readi+0xe0>
    80003a58:	6946                	ld	s2,80(sp)
    80003a5a:	7c02                	ld	s8,32(sp)
    80003a5c:	6ce2                	ld	s9,24(sp)
    80003a5e:	6d42                	ld	s10,16(sp)
    80003a60:	6da2                	ld	s11,8(sp)
    80003a62:	a801                	j	80003a72 <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003a64:	89d6                	mv	s3,s5
    80003a66:	a031                	j	80003a72 <readi+0xe0>
    80003a68:	6946                	ld	s2,80(sp)
    80003a6a:	7c02                	ld	s8,32(sp)
    80003a6c:	6ce2                	ld	s9,24(sp)
    80003a6e:	6d42                	ld	s10,16(sp)
    80003a70:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003a72:	0009851b          	sext.w	a0,s3
    80003a76:	69a6                	ld	s3,72(sp)
}
    80003a78:	70a6                	ld	ra,104(sp)
    80003a7a:	7406                	ld	s0,96(sp)
    80003a7c:	64e6                	ld	s1,88(sp)
    80003a7e:	6a06                	ld	s4,64(sp)
    80003a80:	7ae2                	ld	s5,56(sp)
    80003a82:	7b42                	ld	s6,48(sp)
    80003a84:	7ba2                	ld	s7,40(sp)
    80003a86:	6165                	addi	sp,sp,112
    80003a88:	8082                	ret
    return 0;
    80003a8a:	4501                	li	a0,0
}
    80003a8c:	8082                	ret

0000000080003a8e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003a8e:	457c                	lw	a5,76(a0)
    80003a90:	10d7e363          	bltu	a5,a3,80003b96 <writei+0x108>
{
    80003a94:	7159                	addi	sp,sp,-112
    80003a96:	f486                	sd	ra,104(sp)
    80003a98:	f0a2                	sd	s0,96(sp)
    80003a9a:	e8ca                	sd	s2,80(sp)
    80003a9c:	e0d2                	sd	s4,64(sp)
    80003a9e:	fc56                	sd	s5,56(sp)
    80003aa0:	f85a                	sd	s6,48(sp)
    80003aa2:	f45e                	sd	s7,40(sp)
    80003aa4:	1880                	addi	s0,sp,112
    80003aa6:	8aaa                	mv	s5,a0
    80003aa8:	8bae                	mv	s7,a1
    80003aaa:	8a32                	mv	s4,a2
    80003aac:	8936                	mv	s2,a3
    80003aae:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003ab0:	00e687bb          	addw	a5,a3,a4
    80003ab4:	0ed7e363          	bltu	a5,a3,80003b9a <writei+0x10c>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003ab8:	00043737          	lui	a4,0x43
    80003abc:	0ef76163          	bltu	a4,a5,80003b9e <writei+0x110>
    80003ac0:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003ac2:	0c0b0263          	beqz	s6,80003b86 <writei+0xf8>
    80003ac6:	eca6                	sd	s1,88(sp)
    80003ac8:	f062                	sd	s8,32(sp)
    80003aca:	ec66                	sd	s9,24(sp)
    80003acc:	e86a                	sd	s10,16(sp)
    80003ace:	e46e                	sd	s11,8(sp)
    80003ad0:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003ad2:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ad6:	5c7d                	li	s8,-1
    80003ad8:	a825                	j	80003b10 <writei+0x82>
    80003ada:	020d1d93          	slli	s11,s10,0x20
    80003ade:	020ddd93          	srli	s11,s11,0x20
    80003ae2:	05848513          	addi	a0,s1,88
    80003ae6:	86ee                	mv	a3,s11
    80003ae8:	8652                	mv	a2,s4
    80003aea:	85de                	mv	a1,s7
    80003aec:	953a                	add	a0,a0,a4
    80003aee:	fe6fe0ef          	jal	800022d4 <either_copyin>
    80003af2:	05850a63          	beq	a0,s8,80003b46 <writei+0xb8>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003af6:	8526                	mv	a0,s1
    80003af8:	6b0000ef          	jal	800041a8 <log_write>
    brelse(bp);
    80003afc:	8526                	mv	a0,s1
    80003afe:	cf8ff0ef          	jal	80002ff6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003b02:	013d09bb          	addw	s3,s10,s3
    80003b06:	012d093b          	addw	s2,s10,s2
    80003b0a:	9a6e                	add	s4,s4,s11
    80003b0c:	0569f363          	bgeu	s3,s6,80003b52 <writei+0xc4>
    uint addr = bmap(ip, off / BSIZE);
    80003b10:	00a9559b          	srliw	a1,s2,0xa
    80003b14:	8556                	mv	a0,s5
    80003b16:	f5cff0ef          	jal	80003272 <bmap>
    80003b1a:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003b1e:	c995                	beqz	a1,80003b52 <writei+0xc4>
    bp = bread(ip->dev, addr);
    80003b20:	000aa503          	lw	a0,0(s5)
    80003b24:	bcaff0ef          	jal	80002eee <bread>
    80003b28:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003b2a:	3ff97713          	andi	a4,s2,1023
    80003b2e:	40ec87bb          	subw	a5,s9,a4
    80003b32:	413b06bb          	subw	a3,s6,s3
    80003b36:	8d3e                	mv	s10,a5
    80003b38:	2781                	sext.w	a5,a5
    80003b3a:	0006861b          	sext.w	a2,a3
    80003b3e:	f8f67ee3          	bgeu	a2,a5,80003ada <writei+0x4c>
    80003b42:	8d36                	mv	s10,a3
    80003b44:	bf59                	j	80003ada <writei+0x4c>
      log_write(bp);
    80003b46:	8526                	mv	a0,s1
    80003b48:	660000ef          	jal	800041a8 <log_write>
      brelse(bp);
    80003b4c:	8526                	mv	a0,s1
    80003b4e:	ca8ff0ef          	jal	80002ff6 <brelse>
  }

  if (off > ip->size)
    80003b52:	04caa783          	lw	a5,76(s5)
    80003b56:	0327fa63          	bgeu	a5,s2,80003b8a <writei+0xfc>
    ip->size = off;
    80003b5a:	052aa623          	sw	s2,76(s5)
    80003b5e:	64e6                	ld	s1,88(sp)
    80003b60:	7c02                	ld	s8,32(sp)
    80003b62:	6ce2                	ld	s9,24(sp)
    80003b64:	6d42                	ld	s10,16(sp)
    80003b66:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b68:	8556                	mv	a0,s5
    80003b6a:	99dff0ef          	jal	80003506 <iupdate>

  return tot;
    80003b6e:	0009851b          	sext.w	a0,s3
    80003b72:	69a6                	ld	s3,72(sp)
}
    80003b74:	70a6                	ld	ra,104(sp)
    80003b76:	7406                	ld	s0,96(sp)
    80003b78:	6946                	ld	s2,80(sp)
    80003b7a:	6a06                	ld	s4,64(sp)
    80003b7c:	7ae2                	ld	s5,56(sp)
    80003b7e:	7b42                	ld	s6,48(sp)
    80003b80:	7ba2                	ld	s7,40(sp)
    80003b82:	6165                	addi	sp,sp,112
    80003b84:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003b86:	89da                	mv	s3,s6
    80003b88:	b7c5                	j	80003b68 <writei+0xda>
    80003b8a:	64e6                	ld	s1,88(sp)
    80003b8c:	7c02                	ld	s8,32(sp)
    80003b8e:	6ce2                	ld	s9,24(sp)
    80003b90:	6d42                	ld	s10,16(sp)
    80003b92:	6da2                	ld	s11,8(sp)
    80003b94:	bfd1                	j	80003b68 <writei+0xda>
    return -1;
    80003b96:	557d                	li	a0,-1
}
    80003b98:	8082                	ret
    return -1;
    80003b9a:	557d                	li	a0,-1
    80003b9c:	bfe1                	j	80003b74 <writei+0xe6>
    return -1;
    80003b9e:	557d                	li	a0,-1
    80003ba0:	bfd1                	j	80003b74 <writei+0xe6>

0000000080003ba2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ba2:	1141                	addi	sp,sp,-16
    80003ba4:	e406                	sd	ra,8(sp)
    80003ba6:	e022                	sd	s0,0(sp)
    80003ba8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003baa:	4639                	li	a2,14
    80003bac:	9b6fd0ef          	jal	80000d62 <strncmp>
}
    80003bb0:	60a2                	ld	ra,8(sp)
    80003bb2:	6402                	ld	s0,0(sp)
    80003bb4:	0141                	addi	sp,sp,16
    80003bb6:	8082                	ret

0000000080003bb8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bb8:	7139                	addi	sp,sp,-64
    80003bba:	fc06                	sd	ra,56(sp)
    80003bbc:	f822                	sd	s0,48(sp)
    80003bbe:	f426                	sd	s1,40(sp)
    80003bc0:	f04a                	sd	s2,32(sp)
    80003bc2:	ec4e                	sd	s3,24(sp)
    80003bc4:	e852                	sd	s4,16(sp)
    80003bc6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003bc8:	04451703          	lh	a4,68(a0)
    80003bcc:	4785                	li	a5,1
    80003bce:	00f71a63          	bne	a4,a5,80003be2 <dirlookup+0x2a>
    80003bd2:	892a                	mv	s2,a0
    80003bd4:	89ae                	mv	s3,a1
    80003bd6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bd8:	457c                	lw	a5,76(a0)
    80003bda:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bdc:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bde:	e39d                	bnez	a5,80003c04 <dirlookup+0x4c>
    80003be0:	a095                	j	80003c44 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003be2:	00004517          	auipc	a0,0x4
    80003be6:	a0650513          	addi	a0,a0,-1530 # 800075e8 <etext+0x5e8>
    80003bea:	c07fc0ef          	jal	800007f0 <panic>
      panic("dirlookup read");
    80003bee:	00004517          	auipc	a0,0x4
    80003bf2:	a1250513          	addi	a0,a0,-1518 # 80007600 <etext+0x600>
    80003bf6:	bfbfc0ef          	jal	800007f0 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bfa:	24c1                	addiw	s1,s1,16
    80003bfc:	04c92783          	lw	a5,76(s2)
    80003c00:	04f4f163          	bgeu	s1,a5,80003c42 <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c04:	4741                	li	a4,16
    80003c06:	86a6                	mv	a3,s1
    80003c08:	fc040613          	addi	a2,s0,-64
    80003c0c:	4581                	li	a1,0
    80003c0e:	854a                	mv	a0,s2
    80003c10:	d83ff0ef          	jal	80003992 <readi>
    80003c14:	47c1                	li	a5,16
    80003c16:	fcf51ce3          	bne	a0,a5,80003bee <dirlookup+0x36>
    if (de.inum == 0)
    80003c1a:	fc045783          	lhu	a5,-64(s0)
    80003c1e:	dff1                	beqz	a5,80003bfa <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    80003c20:	fc240593          	addi	a1,s0,-62
    80003c24:	854e                	mv	a0,s3
    80003c26:	f7dff0ef          	jal	80003ba2 <namecmp>
    80003c2a:	f961                	bnez	a0,80003bfa <dirlookup+0x42>
      if (poff)
    80003c2c:	000a0463          	beqz	s4,80003c34 <dirlookup+0x7c>
        *poff = off;
    80003c30:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c34:	fc045583          	lhu	a1,-64(s0)
    80003c38:	00092503          	lw	a0,0(s2)
    80003c3c:	f0aff0ef          	jal	80003346 <iget>
    80003c40:	a011                	j	80003c44 <dirlookup+0x8c>
  return 0;
    80003c42:	4501                	li	a0,0
}
    80003c44:	70e2                	ld	ra,56(sp)
    80003c46:	7442                	ld	s0,48(sp)
    80003c48:	74a2                	ld	s1,40(sp)
    80003c4a:	7902                	ld	s2,32(sp)
    80003c4c:	69e2                	ld	s3,24(sp)
    80003c4e:	6a42                	ld	s4,16(sp)
    80003c50:	6121                	addi	sp,sp,64
    80003c52:	8082                	ret

0000000080003c54 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003c54:	711d                	addi	sp,sp,-96
    80003c56:	ec86                	sd	ra,88(sp)
    80003c58:	e8a2                	sd	s0,80(sp)
    80003c5a:	e4a6                	sd	s1,72(sp)
    80003c5c:	e0ca                	sd	s2,64(sp)
    80003c5e:	fc4e                	sd	s3,56(sp)
    80003c60:	f852                	sd	s4,48(sp)
    80003c62:	f456                	sd	s5,40(sp)
    80003c64:	f05a                	sd	s6,32(sp)
    80003c66:	ec5e                	sd	s7,24(sp)
    80003c68:	e862                	sd	s8,16(sp)
    80003c6a:	e466                	sd	s9,8(sp)
    80003c6c:	1080                	addi	s0,sp,96
    80003c6e:	84aa                	mv	s1,a0
    80003c70:	8b2e                	mv	s6,a1
    80003c72:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003c74:	00054703          	lbu	a4,0(a0)
    80003c78:	02f00793          	li	a5,47
    80003c7c:	00f70e63          	beq	a4,a5,80003c98 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c80:	c65fd0ef          	jal	800018e4 <myproc>
    80003c84:	15053503          	ld	a0,336(a0)
    80003c88:	8fdff0ef          	jal	80003584 <idup>
    80003c8c:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003c8e:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003c92:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003c94:	4b85                	li	s7,1
    80003c96:	a075                	j	80003d42 <namex+0xee>
    ip = iget(ROOTDEV, ROOTINO);
    80003c98:	4585                	li	a1,1
    80003c9a:	4505                	li	a0,1
    80003c9c:	eaaff0ef          	jal	80003346 <iget>
    80003ca0:	8a2a                	mv	s4,a0
    80003ca2:	b7f5                	j	80003c8e <namex+0x3a>
      iunlockput(ip);
    80003ca4:	8552                	mv	a0,s4
    80003ca6:	b67ff0ef          	jal	8000380c <iunlockput>
      return 0;
    80003caa:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cac:	8552                	mv	a0,s4
    80003cae:	60e6                	ld	ra,88(sp)
    80003cb0:	6446                	ld	s0,80(sp)
    80003cb2:	64a6                	ld	s1,72(sp)
    80003cb4:	6906                	ld	s2,64(sp)
    80003cb6:	79e2                	ld	s3,56(sp)
    80003cb8:	7a42                	ld	s4,48(sp)
    80003cba:	7aa2                	ld	s5,40(sp)
    80003cbc:	7b02                	ld	s6,32(sp)
    80003cbe:	6be2                	ld	s7,24(sp)
    80003cc0:	6c42                	ld	s8,16(sp)
    80003cc2:	6ca2                	ld	s9,8(sp)
    80003cc4:	6125                	addi	sp,sp,96
    80003cc6:	8082                	ret
      iunlockput(ip);
    80003cc8:	8552                	mv	a0,s4
    80003cca:	b43ff0ef          	jal	8000380c <iunlockput>
      return 0;
    80003cce:	4a01                	li	s4,0
    80003cd0:	bff1                	j	80003cac <namex+0x58>
      iunlock(ip);
    80003cd2:	8552                	mv	a0,s4
    80003cd4:	995ff0ef          	jal	80003668 <iunlock>
      return ip;
    80003cd8:	bfd1                	j	80003cac <namex+0x58>
      iunlockput(ip);
    80003cda:	8552                	mv	a0,s4
    80003cdc:	b31ff0ef          	jal	8000380c <iunlockput>
      return 0;
    80003ce0:	8a4e                	mv	s4,s3
    80003ce2:	b7e9                	j	80003cac <namex+0x58>
  len = path - s;
    80003ce4:	40998633          	sub	a2,s3,s1
    80003ce8:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    80003cec:	099c5363          	bge	s8,s9,80003d72 <namex+0x11e>
    memmove(name, s, DIRSIZ);
    80003cf0:	4639                	li	a2,14
    80003cf2:	85a6                	mv	a1,s1
    80003cf4:	8556                	mv	a0,s5
    80003cf6:	ffdfc0ef          	jal	80000cf2 <memmove>
    80003cfa:	84ce                	mv	s1,s3
  while (*path == '/')
    80003cfc:	0004c783          	lbu	a5,0(s1)
    80003d00:	01279763          	bne	a5,s2,80003d0e <namex+0xba>
    path++;
    80003d04:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003d06:	0004c783          	lbu	a5,0(s1)
    80003d0a:	ff278de3          	beq	a5,s2,80003d04 <namex+0xb0>
    ilock(ip);
    80003d0e:	8552                	mv	a0,s4
    80003d10:	8abff0ef          	jal	800035ba <ilock>
    if (ip->type != T_DIR) {
    80003d14:	044a1783          	lh	a5,68(s4)
    80003d18:	f97796e3          	bne	a5,s7,80003ca4 <namex+0x50>
    if (ip->nlink == 0) {
    80003d1c:	04aa1783          	lh	a5,74(s4)
    80003d20:	d7c5                	beqz	a5,80003cc8 <namex+0x74>
    if (nameiparent && *path == '\0') {
    80003d22:	000b0563          	beqz	s6,80003d2c <namex+0xd8>
    80003d26:	0004c783          	lbu	a5,0(s1)
    80003d2a:	d7c5                	beqz	a5,80003cd2 <namex+0x7e>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003d2c:	4601                	li	a2,0
    80003d2e:	85d6                	mv	a1,s5
    80003d30:	8552                	mv	a0,s4
    80003d32:	e87ff0ef          	jal	80003bb8 <dirlookup>
    80003d36:	89aa                	mv	s3,a0
    80003d38:	d14d                	beqz	a0,80003cda <namex+0x86>
    iunlockput(ip);
    80003d3a:	8552                	mv	a0,s4
    80003d3c:	ad1ff0ef          	jal	8000380c <iunlockput>
    ip = next;
    80003d40:	8a4e                	mv	s4,s3
  while (*path == '/')
    80003d42:	0004c783          	lbu	a5,0(s1)
    80003d46:	01279763          	bne	a5,s2,80003d54 <namex+0x100>
    path++;
    80003d4a:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	ff278de3          	beq	a5,s2,80003d4a <namex+0xf6>
  if (*path == 0)
    80003d54:	cb8d                	beqz	a5,80003d86 <namex+0x132>
  while (*path != '/' && *path != 0)
    80003d56:	0004c783          	lbu	a5,0(s1)
    80003d5a:	89a6                	mv	s3,s1
  len = path - s;
    80003d5c:	4c81                	li	s9,0
    80003d5e:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    80003d60:	01278963          	beq	a5,s2,80003d72 <namex+0x11e>
    80003d64:	d3c1                	beqz	a5,80003ce4 <namex+0x90>
    path++;
    80003d66:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80003d68:	0009c783          	lbu	a5,0(s3)
    80003d6c:	ff279ce3          	bne	a5,s2,80003d64 <namex+0x110>
    80003d70:	bf95                	j	80003ce4 <namex+0x90>
    memmove(name, s, len);
    80003d72:	2601                	sext.w	a2,a2
    80003d74:	85a6                	mv	a1,s1
    80003d76:	8556                	mv	a0,s5
    80003d78:	f7bfc0ef          	jal	80000cf2 <memmove>
    name[len] = 0;
    80003d7c:	9cd6                	add	s9,s9,s5
    80003d7e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d82:	84ce                	mv	s1,s3
    80003d84:	bfa5                	j	80003cfc <namex+0xa8>
  if (nameiparent) {
    80003d86:	f20b03e3          	beqz	s6,80003cac <namex+0x58>
    iput(ip);
    80003d8a:	8552                	mv	a0,s4
    80003d8c:	9b1ff0ef          	jal	8000373c <iput>
    return 0;
    80003d90:	4a01                	li	s4,0
    80003d92:	bf29                	j	80003cac <namex+0x58>

0000000080003d94 <dirlink>:
{
    80003d94:	7139                	addi	sp,sp,-64
    80003d96:	fc06                	sd	ra,56(sp)
    80003d98:	f822                	sd	s0,48(sp)
    80003d9a:	f04a                	sd	s2,32(sp)
    80003d9c:	ec4e                	sd	s3,24(sp)
    80003d9e:	e852                	sd	s4,16(sp)
    80003da0:	0080                	addi	s0,sp,64
    80003da2:	892a                	mv	s2,a0
    80003da4:	8a2e                	mv	s4,a1
    80003da6:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003da8:	4601                	li	a2,0
    80003daa:	e0fff0ef          	jal	80003bb8 <dirlookup>
    80003dae:	e535                	bnez	a0,80003e1a <dirlink+0x86>
    80003db0:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003db2:	04c92483          	lw	s1,76(s2)
    80003db6:	c48d                	beqz	s1,80003de0 <dirlink+0x4c>
    80003db8:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dba:	4741                	li	a4,16
    80003dbc:	86a6                	mv	a3,s1
    80003dbe:	fc040613          	addi	a2,s0,-64
    80003dc2:	4581                	li	a1,0
    80003dc4:	854a                	mv	a0,s2
    80003dc6:	bcdff0ef          	jal	80003992 <readi>
    80003dca:	47c1                	li	a5,16
    80003dcc:	04f51b63          	bne	a0,a5,80003e22 <dirlink+0x8e>
    if (de.inum == 0)
    80003dd0:	fc045783          	lhu	a5,-64(s0)
    80003dd4:	c791                	beqz	a5,80003de0 <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003dd6:	24c1                	addiw	s1,s1,16
    80003dd8:	04c92783          	lw	a5,76(s2)
    80003ddc:	fcf4efe3          	bltu	s1,a5,80003dba <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003de0:	4639                	li	a2,14
    80003de2:	85d2                	mv	a1,s4
    80003de4:	fc240513          	addi	a0,s0,-62
    80003de8:	fb1fc0ef          	jal	80000d98 <strncpy>
  de.inum = inum;
    80003dec:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df0:	4741                	li	a4,16
    80003df2:	86a6                	mv	a3,s1
    80003df4:	fc040613          	addi	a2,s0,-64
    80003df8:	4581                	li	a1,0
    80003dfa:	854a                	mv	a0,s2
    80003dfc:	c93ff0ef          	jal	80003a8e <writei>
    80003e00:	1541                	addi	a0,a0,-16
    80003e02:	00a03533          	snez	a0,a0
    80003e06:	40a00533          	neg	a0,a0
    80003e0a:	74a2                	ld	s1,40(sp)
}
    80003e0c:	70e2                	ld	ra,56(sp)
    80003e0e:	7442                	ld	s0,48(sp)
    80003e10:	7902                	ld	s2,32(sp)
    80003e12:	69e2                	ld	s3,24(sp)
    80003e14:	6a42                	ld	s4,16(sp)
    80003e16:	6121                	addi	sp,sp,64
    80003e18:	8082                	ret
    iput(ip);
    80003e1a:	923ff0ef          	jal	8000373c <iput>
    return -1;
    80003e1e:	557d                	li	a0,-1
    80003e20:	b7f5                	j	80003e0c <dirlink+0x78>
      panic("dirlink read");
    80003e22:	00003517          	auipc	a0,0x3
    80003e26:	7ee50513          	addi	a0,a0,2030 # 80007610 <etext+0x610>
    80003e2a:	9c7fc0ef          	jal	800007f0 <panic>

0000000080003e2e <namei>:

struct inode *
namei(char *path)
{
    80003e2e:	1101                	addi	sp,sp,-32
    80003e30:	ec06                	sd	ra,24(sp)
    80003e32:	e822                	sd	s0,16(sp)
    80003e34:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e36:	fe040613          	addi	a2,s0,-32
    80003e3a:	4581                	li	a1,0
    80003e3c:	e19ff0ef          	jal	80003c54 <namex>
}
    80003e40:	60e2                	ld	ra,24(sp)
    80003e42:	6442                	ld	s0,16(sp)
    80003e44:	6105                	addi	sp,sp,32
    80003e46:	8082                	ret

0000000080003e48 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003e48:	1141                	addi	sp,sp,-16
    80003e4a:	e406                	sd	ra,8(sp)
    80003e4c:	e022                	sd	s0,0(sp)
    80003e4e:	0800                	addi	s0,sp,16
    80003e50:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e52:	4585                	li	a1,1
    80003e54:	e01ff0ef          	jal	80003c54 <namex>
}
    80003e58:	60a2                	ld	ra,8(sp)
    80003e5a:	6402                	ld	s0,0(sp)
    80003e5c:	0141                	addi	sp,sp,16
    80003e5e:	8082                	ret

0000000080003e60 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e60:	1101                	addi	sp,sp,-32
    80003e62:	ec06                	sd	ra,24(sp)
    80003e64:	e822                	sd	s0,16(sp)
    80003e66:	e426                	sd	s1,8(sp)
    80003e68:	e04a                	sd	s2,0(sp)
    80003e6a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e6c:	0001f917          	auipc	s2,0x1f
    80003e70:	a8490913          	addi	s2,s2,-1404 # 800228f0 <log>
    80003e74:	01892583          	lw	a1,24(s2)
    80003e78:	02492503          	lw	a0,36(s2)
    80003e7c:	872ff0ef          	jal	80002eee <bread>
    80003e80:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003e82:	02c92603          	lw	a2,44(s2)
    80003e86:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e88:	00c05f63          	blez	a2,80003ea6 <write_head+0x46>
    80003e8c:	0001f717          	auipc	a4,0x1f
    80003e90:	a9470713          	addi	a4,a4,-1388 # 80022920 <log+0x30>
    80003e94:	87aa                	mv	a5,a0
    80003e96:	060a                	slli	a2,a2,0x2
    80003e98:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e9a:	4314                	lw	a3,0(a4)
    80003e9c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e9e:	0711                	addi	a4,a4,4
    80003ea0:	0791                	addi	a5,a5,4
    80003ea2:	fec79ce3          	bne	a5,a2,80003e9a <write_head+0x3a>
  }
  bwrite(buf);
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	91cff0ef          	jal	80002fc4 <bwrite>
  brelse(buf);
    80003eac:	8526                	mv	a0,s1
    80003eae:	948ff0ef          	jal	80002ff6 <brelse>
}
    80003eb2:	60e2                	ld	ra,24(sp)
    80003eb4:	6442                	ld	s0,16(sp)
    80003eb6:	64a2                	ld	s1,8(sp)
    80003eb8:	6902                	ld	s2,0(sp)
    80003eba:	6105                	addi	sp,sp,32
    80003ebc:	8082                	ret

0000000080003ebe <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ebe:	0001f797          	auipc	a5,0x1f
    80003ec2:	a5e7a783          	lw	a5,-1442(a5) # 8002291c <log+0x2c>
    80003ec6:	0af05e63          	blez	a5,80003f82 <install_trans+0xc4>
{
    80003eca:	715d                	addi	sp,sp,-80
    80003ecc:	e486                	sd	ra,72(sp)
    80003ece:	e0a2                	sd	s0,64(sp)
    80003ed0:	fc26                	sd	s1,56(sp)
    80003ed2:	f84a                	sd	s2,48(sp)
    80003ed4:	f44e                	sd	s3,40(sp)
    80003ed6:	f052                	sd	s4,32(sp)
    80003ed8:	ec56                	sd	s5,24(sp)
    80003eda:	e85a                	sd	s6,16(sp)
    80003edc:	e45e                	sd	s7,8(sp)
    80003ede:	0880                	addi	s0,sp,80
    80003ee0:	8b2a                	mv	s6,a0
    80003ee2:	0001fa97          	auipc	s5,0x1f
    80003ee6:	a3ea8a93          	addi	s5,s5,-1474 # 80022920 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eea:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003eec:	00003b97          	auipc	s7,0x3
    80003ef0:	734b8b93          	addi	s7,s7,1844 # 80007620 <etext+0x620>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003ef4:	0001fa17          	auipc	s4,0x1f
    80003ef8:	9fca0a13          	addi	s4,s4,-1540 # 800228f0 <log>
    80003efc:	a025                	j	80003f24 <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003efe:	000aa603          	lw	a2,0(s5)
    80003f02:	85ce                	mv	a1,s3
    80003f04:	855e                	mv	a0,s7
    80003f06:	e04fc0ef          	jal	8000050a <printk>
    80003f0a:	a839                	j	80003f28 <install_trans+0x6a>
    brelse(lbuf);
    80003f0c:	854a                	mv	a0,s2
    80003f0e:	8e8ff0ef          	jal	80002ff6 <brelse>
    brelse(dbuf);
    80003f12:	8526                	mv	a0,s1
    80003f14:	8e2ff0ef          	jal	80002ff6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f18:	2985                	addiw	s3,s3,1
    80003f1a:	0a91                	addi	s5,s5,4
    80003f1c:	02ca2783          	lw	a5,44(s4)
    80003f20:	04f9d663          	bge	s3,a5,80003f6c <install_trans+0xae>
    if (recovering) {
    80003f24:	fc0b1de3          	bnez	s6,80003efe <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003f28:	018a2583          	lw	a1,24(s4)
    80003f2c:	013585bb          	addw	a1,a1,s3
    80003f30:	2585                	addiw	a1,a1,1
    80003f32:	024a2503          	lw	a0,36(s4)
    80003f36:	fb9fe0ef          	jal	80002eee <bread>
    80003f3a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003f3c:	000aa583          	lw	a1,0(s5)
    80003f40:	024a2503          	lw	a0,36(s4)
    80003f44:	fabfe0ef          	jal	80002eee <bread>
    80003f48:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003f4a:	40000613          	li	a2,1024
    80003f4e:	05890593          	addi	a1,s2,88
    80003f52:	05850513          	addi	a0,a0,88
    80003f56:	d9dfc0ef          	jal	80000cf2 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	868ff0ef          	jal	80002fc4 <bwrite>
    if (recovering == 0)
    80003f60:	fa0b16e3          	bnez	s6,80003f0c <install_trans+0x4e>
      bunpin(dbuf);
    80003f64:	8526                	mv	a0,s1
    80003f66:	94cff0ef          	jal	800030b2 <bunpin>
    80003f6a:	b74d                	j	80003f0c <install_trans+0x4e>
}
    80003f6c:	60a6                	ld	ra,72(sp)
    80003f6e:	6406                	ld	s0,64(sp)
    80003f70:	74e2                	ld	s1,56(sp)
    80003f72:	7942                	ld	s2,48(sp)
    80003f74:	79a2                	ld	s3,40(sp)
    80003f76:	7a02                	ld	s4,32(sp)
    80003f78:	6ae2                	ld	s5,24(sp)
    80003f7a:	6b42                	ld	s6,16(sp)
    80003f7c:	6ba2                	ld	s7,8(sp)
    80003f7e:	6161                	addi	sp,sp,80
    80003f80:	8082                	ret
    80003f82:	8082                	ret

0000000080003f84 <initlog>:
{
    80003f84:	7179                	addi	sp,sp,-48
    80003f86:	f406                	sd	ra,40(sp)
    80003f88:	f022                	sd	s0,32(sp)
    80003f8a:	ec26                	sd	s1,24(sp)
    80003f8c:	e84a                	sd	s2,16(sp)
    80003f8e:	e44e                	sd	s3,8(sp)
    80003f90:	1800                	addi	s0,sp,48
    80003f92:	892a                	mv	s2,a0
    80003f94:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f96:	0001f497          	auipc	s1,0x1f
    80003f9a:	95a48493          	addi	s1,s1,-1702 # 800228f0 <log>
    80003f9e:	00003597          	auipc	a1,0x3
    80003fa2:	6a258593          	addi	a1,a1,1698 # 80007640 <etext+0x640>
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	bb5fc0ef          	jal	80000b5c <initlock>
  log.start = sb->logstart;
    80003fac:	0149a583          	lw	a1,20(s3)
    80003fb0:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003fb2:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fb6:	854a                	mv	a0,s2
    80003fb8:	f37fe0ef          	jal	80002eee <bread>
  log.lh.n = lh->n;
    80003fbc:	4d30                	lw	a2,88(a0)
    80003fbe:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fc0:	00c05f63          	blez	a2,80003fde <initlog+0x5a>
    80003fc4:	87aa                	mv	a5,a0
    80003fc6:	0001f717          	auipc	a4,0x1f
    80003fca:	95a70713          	addi	a4,a4,-1702 # 80022920 <log+0x30>
    80003fce:	060a                	slli	a2,a2,0x2
    80003fd0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003fd2:	4ff4                	lw	a3,92(a5)
    80003fd4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fd6:	0791                	addi	a5,a5,4
    80003fd8:	0711                	addi	a4,a4,4
    80003fda:	fec79ce3          	bne	a5,a2,80003fd2 <initlog+0x4e>
  brelse(buf);
    80003fde:	818ff0ef          	jal	80002ff6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fe2:	4505                	li	a0,1
    80003fe4:	edbff0ef          	jal	80003ebe <install_trans>
  log.lh.n = 0;
    80003fe8:	0001f797          	auipc	a5,0x1f
    80003fec:	9207aa23          	sw	zero,-1740(a5) # 8002291c <log+0x2c>
  write_head(); // clear the log
    80003ff0:	e71ff0ef          	jal	80003e60 <write_head>
}
    80003ff4:	70a2                	ld	ra,40(sp)
    80003ff6:	7402                	ld	s0,32(sp)
    80003ff8:	64e2                	ld	s1,24(sp)
    80003ffa:	6942                	ld	s2,16(sp)
    80003ffc:	69a2                	ld	s3,8(sp)
    80003ffe:	6145                	addi	sp,sp,48
    80004000:	8082                	ret

0000000080004002 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004002:	1101                	addi	sp,sp,-32
    80004004:	ec06                	sd	ra,24(sp)
    80004006:	e822                	sd	s0,16(sp)
    80004008:	e426                	sd	s1,8(sp)
    8000400a:	e04a                	sd	s2,0(sp)
    8000400c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000400e:	0001f517          	auipc	a0,0x1f
    80004012:	8e250513          	addi	a0,a0,-1822 # 800228f0 <log>
    80004016:	bbdfc0ef          	jal	80000bd2 <acquire>
  while (1) {
    if (log.committing) {
    8000401a:	0001f497          	auipc	s1,0x1f
    8000401e:	8d648493          	addi	s1,s1,-1834 # 800228f0 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004022:	4979                	li	s2,30
    80004024:	a821                	j	8000403c <begin_op+0x3a>
      sleep_prepare(&log);
    80004026:	8526                	mv	a0,s1
    80004028:	ecdfd0ef          	jal	80001ef4 <sleep_prepare>
      release(&log.lock);
    8000402c:	8526                	mv	a0,s1
    8000402e:	c31fc0ef          	jal	80000c5e <release>
      sleep();
    80004032:	efffd0ef          	jal	80001f30 <sleep>
      acquire(&log.lock);
    80004036:	8526                	mv	a0,s1
    80004038:	b9bfc0ef          	jal	80000bd2 <acquire>
    if (log.committing) {
    8000403c:	509c                	lw	a5,32(s1)
    8000403e:	f7e5                	bnez	a5,80004026 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004040:	4cd8                	lw	a4,28(s1)
    80004042:	2705                	addiw	a4,a4,1
    80004044:	0027179b          	slliw	a5,a4,0x2
    80004048:	9fb9                	addw	a5,a5,a4
    8000404a:	0017979b          	slliw	a5,a5,0x1
    8000404e:	54d4                	lw	a3,44(s1)
    80004050:	9fb5                	addw	a5,a5,a3
    80004052:	00f95e63          	bge	s2,a5,8000406e <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80004056:	8526                	mv	a0,s1
    80004058:	e9dfd0ef          	jal	80001ef4 <sleep_prepare>
      release(&log.lock);
    8000405c:	8526                	mv	a0,s1
    8000405e:	c01fc0ef          	jal	80000c5e <release>
      sleep();
    80004062:	ecffd0ef          	jal	80001f30 <sleep>
      acquire(&log.lock);
    80004066:	8526                	mv	a0,s1
    80004068:	b6bfc0ef          	jal	80000bd2 <acquire>
    8000406c:	bfc1                	j	8000403c <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    8000406e:	0001f517          	auipc	a0,0x1f
    80004072:	88250513          	addi	a0,a0,-1918 # 800228f0 <log>
    80004076:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004078:	be7fc0ef          	jal	80000c5e <release>
      break;
    }
  }
}
    8000407c:	60e2                	ld	ra,24(sp)
    8000407e:	6442                	ld	s0,16(sp)
    80004080:	64a2                	ld	s1,8(sp)
    80004082:	6902                	ld	s2,0(sp)
    80004084:	6105                	addi	sp,sp,32
    80004086:	8082                	ret

0000000080004088 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004088:	7139                	addi	sp,sp,-64
    8000408a:	fc06                	sd	ra,56(sp)
    8000408c:	f822                	sd	s0,48(sp)
    8000408e:	f426                	sd	s1,40(sp)
    80004090:	f04a                	sd	s2,32(sp)
    80004092:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004094:	0001f497          	auipc	s1,0x1f
    80004098:	85c48493          	addi	s1,s1,-1956 # 800228f0 <log>
    8000409c:	8526                	mv	a0,s1
    8000409e:	b35fc0ef          	jal	80000bd2 <acquire>
  log.outstanding -= 1;
    800040a2:	4cdc                	lw	a5,28(s1)
    800040a4:	37fd                	addiw	a5,a5,-1
    800040a6:	0007891b          	sext.w	s2,a5
    800040aa:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    800040ac:	509c                	lw	a5,32(s1)
    800040ae:	e3b1                	bnez	a5,800040f2 <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    800040b0:	04091a63          	bnez	s2,80004104 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    800040b4:	0001f497          	auipc	s1,0x1f
    800040b8:	83c48493          	addi	s1,s1,-1988 # 800228f0 <log>
    800040bc:	4785                	li	a5,1
    800040be:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040c0:	8526                	mv	a0,s1
    800040c2:	b9dfc0ef          	jal	80000c5e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040c6:	54dc                	lw	a5,44(s1)
    800040c8:	04f04e63          	bgtz	a5,80004124 <end_op+0x9c>
    acquire(&log.lock);
    800040cc:	0001f497          	auipc	s1,0x1f
    800040d0:	82448493          	addi	s1,s1,-2012 # 800228f0 <log>
    800040d4:	8526                	mv	a0,s1
    800040d6:	afdfc0ef          	jal	80000bd2 <acquire>
    log.committing = 0;
    800040da:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    800040de:	549c                	lw	a5,40(s1)
    800040e0:	2785                	addiw	a5,a5,1
    800040e2:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    800040e4:	8526                	mv	a0,s1
    800040e6:	e7bfd0ef          	jal	80001f60 <wakeup>
    release(&log.lock);
    800040ea:	8526                	mv	a0,s1
    800040ec:	b73fc0ef          	jal	80000c5e <release>
}
    800040f0:	a025                	j	80004118 <end_op+0x90>
    800040f2:	ec4e                	sd	s3,24(sp)
    800040f4:	e852                	sd	s4,16(sp)
    800040f6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800040f8:	00003517          	auipc	a0,0x3
    800040fc:	55050513          	addi	a0,a0,1360 # 80007648 <etext+0x648>
    80004100:	ef0fc0ef          	jal	800007f0 <panic>
    wakeup(&log);
    80004104:	0001e497          	auipc	s1,0x1e
    80004108:	7ec48493          	addi	s1,s1,2028 # 800228f0 <log>
    8000410c:	8526                	mv	a0,s1
    8000410e:	e53fd0ef          	jal	80001f60 <wakeup>
  release(&log.lock);
    80004112:	8526                	mv	a0,s1
    80004114:	b4bfc0ef          	jal	80000c5e <release>
}
    80004118:	70e2                	ld	ra,56(sp)
    8000411a:	7442                	ld	s0,48(sp)
    8000411c:	74a2                	ld	s1,40(sp)
    8000411e:	7902                	ld	s2,32(sp)
    80004120:	6121                	addi	sp,sp,64
    80004122:	8082                	ret
    80004124:	ec4e                	sd	s3,24(sp)
    80004126:	e852                	sd	s4,16(sp)
    80004128:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000412a:	0001ea97          	auipc	s5,0x1e
    8000412e:	7f6a8a93          	addi	s5,s5,2038 # 80022920 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004132:	0001ea17          	auipc	s4,0x1e
    80004136:	7bea0a13          	addi	s4,s4,1982 # 800228f0 <log>
    8000413a:	018a2583          	lw	a1,24(s4)
    8000413e:	012585bb          	addw	a1,a1,s2
    80004142:	2585                	addiw	a1,a1,1
    80004144:	024a2503          	lw	a0,36(s4)
    80004148:	da7fe0ef          	jal	80002eee <bread>
    8000414c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000414e:	000aa583          	lw	a1,0(s5)
    80004152:	024a2503          	lw	a0,36(s4)
    80004156:	d99fe0ef          	jal	80002eee <bread>
    8000415a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000415c:	40000613          	li	a2,1024
    80004160:	05850593          	addi	a1,a0,88
    80004164:	05848513          	addi	a0,s1,88
    80004168:	b8bfc0ef          	jal	80000cf2 <memmove>
    bwrite(to); // write the log
    8000416c:	8526                	mv	a0,s1
    8000416e:	e57fe0ef          	jal	80002fc4 <bwrite>
    brelse(from);
    80004172:	854e                	mv	a0,s3
    80004174:	e83fe0ef          	jal	80002ff6 <brelse>
    brelse(to);
    80004178:	8526                	mv	a0,s1
    8000417a:	e7dfe0ef          	jal	80002ff6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000417e:	2905                	addiw	s2,s2,1
    80004180:	0a91                	addi	s5,s5,4
    80004182:	02ca2783          	lw	a5,44(s4)
    80004186:	faf94ae3          	blt	s2,a5,8000413a <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    8000418a:	cd7ff0ef          	jal	80003e60 <write_head>
    install_trans(0); // Now install writes to home locations
    8000418e:	4501                	li	a0,0
    80004190:	d2fff0ef          	jal	80003ebe <install_trans>
    log.lh.n = 0;
    80004194:	0001e797          	auipc	a5,0x1e
    80004198:	7807a423          	sw	zero,1928(a5) # 8002291c <log+0x2c>
    write_head(); // Erase the transaction from the log
    8000419c:	cc5ff0ef          	jal	80003e60 <write_head>
    800041a0:	69e2                	ld	s3,24(sp)
    800041a2:	6a42                	ld	s4,16(sp)
    800041a4:	6aa2                	ld	s5,8(sp)
    800041a6:	b71d                	j	800040cc <end_op+0x44>

00000000800041a8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041a8:	1101                	addi	sp,sp,-32
    800041aa:	ec06                	sd	ra,24(sp)
    800041ac:	e822                	sd	s0,16(sp)
    800041ae:	e426                	sd	s1,8(sp)
    800041b0:	e04a                	sd	s2,0(sp)
    800041b2:	1000                	addi	s0,sp,32
    800041b4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041b6:	0001e917          	auipc	s2,0x1e
    800041ba:	73a90913          	addi	s2,s2,1850 # 800228f0 <log>
    800041be:	854a                	mv	a0,s2
    800041c0:	a13fc0ef          	jal	80000bd2 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800041c4:	02c92603          	lw	a2,44(s2)
    800041c8:	47f5                	li	a5,29
    800041ca:	04c7cc63          	blt	a5,a2,80004222 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041ce:	0001e797          	auipc	a5,0x1e
    800041d2:	73e7a783          	lw	a5,1854(a5) # 8002290c <log+0x1c>
    800041d6:	04f05c63          	blez	a5,8000422e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800041da:	4781                	li	a5,0
    800041dc:	04c05f63          	blez	a2,8000423a <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    800041e0:	44cc                	lw	a1,12(s1)
    800041e2:	0001e717          	auipc	a4,0x1e
    800041e6:	73e70713          	addi	a4,a4,1854 # 80022920 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041ea:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800041ec:	4314                	lw	a3,0(a4)
    800041ee:	04b68663          	beq	a3,a1,8000423a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800041f2:	2785                	addiw	a5,a5,1
    800041f4:	0711                	addi	a4,a4,4
    800041f6:	fef61be3          	bne	a2,a5,800041ec <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041fa:	0621                	addi	a2,a2,8
    800041fc:	060a                	slli	a2,a2,0x2
    800041fe:	0001e797          	auipc	a5,0x1e
    80004202:	6f278793          	addi	a5,a5,1778 # 800228f0 <log>
    80004206:	97b2                	add	a5,a5,a2
    80004208:	44d8                	lw	a4,12(s1)
    8000420a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    8000420c:	8526                	mv	a0,s1
    8000420e:	e71fe0ef          	jal	8000307e <bpin>
    log.lh.n++;
    80004212:	0001e717          	auipc	a4,0x1e
    80004216:	6de70713          	addi	a4,a4,1758 # 800228f0 <log>
    8000421a:	575c                	lw	a5,44(a4)
    8000421c:	2785                	addiw	a5,a5,1
    8000421e:	d75c                	sw	a5,44(a4)
    80004220:	a80d                	j	80004252 <log_write+0xaa>
    panic("too big a transaction");
    80004222:	00003517          	auipc	a0,0x3
    80004226:	43650513          	addi	a0,a0,1078 # 80007658 <etext+0x658>
    8000422a:	dc6fc0ef          	jal	800007f0 <panic>
    panic("log_write outside of trans");
    8000422e:	00003517          	auipc	a0,0x3
    80004232:	44250513          	addi	a0,a0,1090 # 80007670 <etext+0x670>
    80004236:	dbafc0ef          	jal	800007f0 <panic>
  log.lh.block[i] = b->blockno;
    8000423a:	00878693          	addi	a3,a5,8
    8000423e:	068a                	slli	a3,a3,0x2
    80004240:	0001e717          	auipc	a4,0x1e
    80004244:	6b070713          	addi	a4,a4,1712 # 800228f0 <log>
    80004248:	9736                	add	a4,a4,a3
    8000424a:	44d4                	lw	a3,12(s1)
    8000424c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    8000424e:	faf60fe3          	beq	a2,a5,8000420c <log_write+0x64>
  }
  release(&log.lock);
    80004252:	0001e517          	auipc	a0,0x1e
    80004256:	69e50513          	addi	a0,a0,1694 # 800228f0 <log>
    8000425a:	a05fc0ef          	jal	80000c5e <release>
}
    8000425e:	60e2                	ld	ra,24(sp)
    80004260:	6442                	ld	s0,16(sp)
    80004262:	64a2                	ld	s1,8(sp)
    80004264:	6902                	ld	s2,0(sp)
    80004266:	6105                	addi	sp,sp,32
    80004268:	8082                	ret

000000008000426a <sys_sync>:

uint64
sys_sync(void)
{
    8000426a:	1101                	addi	sp,sp,-32
    8000426c:	ec06                	sd	ra,24(sp)
    8000426e:	e822                	sd	s0,16(sp)
    80004270:	e426                	sd	s1,8(sp)
    80004272:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004274:	0001e497          	auipc	s1,0x1e
    80004278:	67c48493          	addi	s1,s1,1660 # 800228f0 <log>
    8000427c:	8526                	mv	a0,s1
    8000427e:	955fc0ef          	jal	80000bd2 <acquire>
  if (log.committing || log.outstanding > 0) {
    80004282:	509c                	lw	a5,32(s1)
    80004284:	e799                	bnez	a5,80004292 <sys_sync+0x28>
    80004286:	0001e797          	auipc	a5,0x1e
    8000428a:	6867a783          	lw	a5,1670(a5) # 8002290c <log+0x1c>
    8000428e:	02f05a63          	blez	a5,800042c2 <sys_sync+0x58>
    80004292:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004294:	0001e917          	auipc	s2,0x1e
    80004298:	68492903          	lw	s2,1668(s2) # 80022918 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    8000429c:	0001e497          	auipc	s1,0x1e
    800042a0:	65448493          	addi	s1,s1,1620 # 800228f0 <log>
    800042a4:	8526                	mv	a0,s1
    800042a6:	c4ffd0ef          	jal	80001ef4 <sleep_prepare>
      release(&log.lock);
    800042aa:	8526                	mv	a0,s1
    800042ac:	9b3fc0ef          	jal	80000c5e <release>
      sleep();
    800042b0:	c81fd0ef          	jal	80001f30 <sleep>
      acquire(&log.lock);
    800042b4:	8526                	mv	a0,s1
    800042b6:	91dfc0ef          	jal	80000bd2 <acquire>
    while (log.ncommit < n) {
    800042ba:	549c                	lw	a5,40(s1)
    800042bc:	fef954e3          	bge	s2,a5,800042a4 <sys_sync+0x3a>
    800042c0:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800042c2:	0001e517          	auipc	a0,0x1e
    800042c6:	62e50513          	addi	a0,a0,1582 # 800228f0 <log>
    800042ca:	995fc0ef          	jal	80000c5e <release>
  return 0;
}
    800042ce:	4501                	li	a0,0
    800042d0:	60e2                	ld	ra,24(sp)
    800042d2:	6442                	ld	s0,16(sp)
    800042d4:	64a2                	ld	s1,8(sp)
    800042d6:	6105                	addi	sp,sp,32
    800042d8:	8082                	ret

00000000800042da <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042da:	1101                	addi	sp,sp,-32
    800042dc:	ec06                	sd	ra,24(sp)
    800042de:	e822                	sd	s0,16(sp)
    800042e0:	e426                	sd	s1,8(sp)
    800042e2:	e04a                	sd	s2,0(sp)
    800042e4:	1000                	addi	s0,sp,32
    800042e6:	84aa                	mv	s1,a0
    800042e8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042ea:	00003597          	auipc	a1,0x3
    800042ee:	3a658593          	addi	a1,a1,934 # 80007690 <etext+0x690>
    800042f2:	0521                	addi	a0,a0,8
    800042f4:	869fc0ef          	jal	80000b5c <initlock>
  lk->name = name;
    800042f8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004300:	0204a423          	sw	zero,40(s1)
}
    80004304:	60e2                	ld	ra,24(sp)
    80004306:	6442                	ld	s0,16(sp)
    80004308:	64a2                	ld	s1,8(sp)
    8000430a:	6902                	ld	s2,0(sp)
    8000430c:	6105                	addi	sp,sp,32
    8000430e:	8082                	ret

0000000080004310 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004310:	1101                	addi	sp,sp,-32
    80004312:	ec06                	sd	ra,24(sp)
    80004314:	e822                	sd	s0,16(sp)
    80004316:	e426                	sd	s1,8(sp)
    80004318:	e04a                	sd	s2,0(sp)
    8000431a:	1000                	addi	s0,sp,32
    8000431c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000431e:	00850913          	addi	s2,a0,8
    80004322:	854a                	mv	a0,s2
    80004324:	8affc0ef          	jal	80000bd2 <acquire>
  while (lk->locked) {
    80004328:	409c                	lw	a5,0(s1)
    8000432a:	cf91                	beqz	a5,80004346 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000432c:	8526                	mv	a0,s1
    8000432e:	bc7fd0ef          	jal	80001ef4 <sleep_prepare>
    release(&lk->lk);
    80004332:	854a                	mv	a0,s2
    80004334:	92bfc0ef          	jal	80000c5e <release>
    sleep();
    80004338:	bf9fd0ef          	jal	80001f30 <sleep>
    acquire(&lk->lk);
    8000433c:	854a                	mv	a0,s2
    8000433e:	895fc0ef          	jal	80000bd2 <acquire>
  while (lk->locked) {
    80004342:	409c                	lw	a5,0(s1)
    80004344:	f7e5                	bnez	a5,8000432c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004346:	4785                	li	a5,1
    80004348:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000434a:	d9afd0ef          	jal	800018e4 <myproc>
    8000434e:	591c                	lw	a5,48(a0)
    80004350:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004352:	854a                	mv	a0,s2
    80004354:	90bfc0ef          	jal	80000c5e <release>
}
    80004358:	60e2                	ld	ra,24(sp)
    8000435a:	6442                	ld	s0,16(sp)
    8000435c:	64a2                	ld	s1,8(sp)
    8000435e:	6902                	ld	s2,0(sp)
    80004360:	6105                	addi	sp,sp,32
    80004362:	8082                	ret

0000000080004364 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004364:	1101                	addi	sp,sp,-32
    80004366:	ec06                	sd	ra,24(sp)
    80004368:	e822                	sd	s0,16(sp)
    8000436a:	e426                	sd	s1,8(sp)
    8000436c:	e04a                	sd	s2,0(sp)
    8000436e:	1000                	addi	s0,sp,32
    80004370:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004372:	00850913          	addi	s2,a0,8
    80004376:	854a                	mv	a0,s2
    80004378:	85bfc0ef          	jal	80000bd2 <acquire>
  lk->locked = 0;
    8000437c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004380:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004384:	8526                	mv	a0,s1
    80004386:	bdbfd0ef          	jal	80001f60 <wakeup>
  release(&lk->lk);
    8000438a:	854a                	mv	a0,s2
    8000438c:	8d3fc0ef          	jal	80000c5e <release>
}
    80004390:	60e2                	ld	ra,24(sp)
    80004392:	6442                	ld	s0,16(sp)
    80004394:	64a2                	ld	s1,8(sp)
    80004396:	6902                	ld	s2,0(sp)
    80004398:	6105                	addi	sp,sp,32
    8000439a:	8082                	ret

000000008000439c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000439c:	7179                	addi	sp,sp,-48
    8000439e:	f406                	sd	ra,40(sp)
    800043a0:	f022                	sd	s0,32(sp)
    800043a2:	ec26                	sd	s1,24(sp)
    800043a4:	e84a                	sd	s2,16(sp)
    800043a6:	1800                	addi	s0,sp,48
    800043a8:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800043aa:	00850913          	addi	s2,a0,8
    800043ae:	854a                	mv	a0,s2
    800043b0:	823fc0ef          	jal	80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043b4:	409c                	lw	a5,0(s1)
    800043b6:	ef81                	bnez	a5,800043ce <holdingsleep+0x32>
    800043b8:	4481                	li	s1,0
  release(&lk->lk);
    800043ba:	854a                	mv	a0,s2
    800043bc:	8a3fc0ef          	jal	80000c5e <release>
  return r;
}
    800043c0:	8526                	mv	a0,s1
    800043c2:	70a2                	ld	ra,40(sp)
    800043c4:	7402                	ld	s0,32(sp)
    800043c6:	64e2                	ld	s1,24(sp)
    800043c8:	6942                	ld	s2,16(sp)
    800043ca:	6145                	addi	sp,sp,48
    800043cc:	8082                	ret
    800043ce:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800043d0:	0284a983          	lw	s3,40(s1)
    800043d4:	d10fd0ef          	jal	800018e4 <myproc>
    800043d8:	5904                	lw	s1,48(a0)
    800043da:	413484b3          	sub	s1,s1,s3
    800043de:	0014b493          	seqz	s1,s1
    800043e2:	69a2                	ld	s3,8(sp)
    800043e4:	bfd9                	j	800043ba <holdingsleep+0x1e>

00000000800043e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043e6:	1141                	addi	sp,sp,-16
    800043e8:	e406                	sd	ra,8(sp)
    800043ea:	e022                	sd	s0,0(sp)
    800043ec:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043ee:	00003597          	auipc	a1,0x3
    800043f2:	2b258593          	addi	a1,a1,690 # 800076a0 <etext+0x6a0>
    800043f6:	0001e517          	auipc	a0,0x1e
    800043fa:	64250513          	addi	a0,a0,1602 # 80022a38 <ftable>
    800043fe:	f5efc0ef          	jal	80000b5c <initlock>
}
    80004402:	60a2                	ld	ra,8(sp)
    80004404:	6402                	ld	s0,0(sp)
    80004406:	0141                	addi	sp,sp,16
    80004408:	8082                	ret

000000008000440a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000440a:	1101                	addi	sp,sp,-32
    8000440c:	ec06                	sd	ra,24(sp)
    8000440e:	e822                	sd	s0,16(sp)
    80004410:	e426                	sd	s1,8(sp)
    80004412:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004414:	0001e517          	auipc	a0,0x1e
    80004418:	62450513          	addi	a0,a0,1572 # 80022a38 <ftable>
    8000441c:	fb6fc0ef          	jal	80000bd2 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004420:	0001e497          	auipc	s1,0x1e
    80004424:	63048493          	addi	s1,s1,1584 # 80022a50 <ftable+0x18>
    80004428:	0001f717          	auipc	a4,0x1f
    8000442c:	5c870713          	addi	a4,a4,1480 # 800239f0 <disk>
    if (f->ref == 0) {
    80004430:	40dc                	lw	a5,4(s1)
    80004432:	cf89                	beqz	a5,8000444c <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004434:	02848493          	addi	s1,s1,40
    80004438:	fee49ce3          	bne	s1,a4,80004430 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000443c:	0001e517          	auipc	a0,0x1e
    80004440:	5fc50513          	addi	a0,a0,1532 # 80022a38 <ftable>
    80004444:	81bfc0ef          	jal	80000c5e <release>
  return 0;
    80004448:	4481                	li	s1,0
    8000444a:	a809                	j	8000445c <filealloc+0x52>
      f->ref = 1;
    8000444c:	4785                	li	a5,1
    8000444e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004450:	0001e517          	auipc	a0,0x1e
    80004454:	5e850513          	addi	a0,a0,1512 # 80022a38 <ftable>
    80004458:	807fc0ef          	jal	80000c5e <release>
}
    8000445c:	8526                	mv	a0,s1
    8000445e:	60e2                	ld	ra,24(sp)
    80004460:	6442                	ld	s0,16(sp)
    80004462:	64a2                	ld	s1,8(sp)
    80004464:	6105                	addi	sp,sp,32
    80004466:	8082                	ret

0000000080004468 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004468:	1101                	addi	sp,sp,-32
    8000446a:	ec06                	sd	ra,24(sp)
    8000446c:	e822                	sd	s0,16(sp)
    8000446e:	e426                	sd	s1,8(sp)
    80004470:	1000                	addi	s0,sp,32
    80004472:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004474:	0001e517          	auipc	a0,0x1e
    80004478:	5c450513          	addi	a0,a0,1476 # 80022a38 <ftable>
    8000447c:	f56fc0ef          	jal	80000bd2 <acquire>
  if (f->ref < 1)
    80004480:	40dc                	lw	a5,4(s1)
    80004482:	02f05063          	blez	a5,800044a2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004486:	2785                	addiw	a5,a5,1
    80004488:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000448a:	0001e517          	auipc	a0,0x1e
    8000448e:	5ae50513          	addi	a0,a0,1454 # 80022a38 <ftable>
    80004492:	fccfc0ef          	jal	80000c5e <release>
  return f;
}
    80004496:	8526                	mv	a0,s1
    80004498:	60e2                	ld	ra,24(sp)
    8000449a:	6442                	ld	s0,16(sp)
    8000449c:	64a2                	ld	s1,8(sp)
    8000449e:	6105                	addi	sp,sp,32
    800044a0:	8082                	ret
    panic("filedup");
    800044a2:	00003517          	auipc	a0,0x3
    800044a6:	20650513          	addi	a0,a0,518 # 800076a8 <etext+0x6a8>
    800044aa:	b46fc0ef          	jal	800007f0 <panic>

00000000800044ae <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044ae:	7139                	addi	sp,sp,-64
    800044b0:	fc06                	sd	ra,56(sp)
    800044b2:	f822                	sd	s0,48(sp)
    800044b4:	f426                	sd	s1,40(sp)
    800044b6:	0080                	addi	s0,sp,64
    800044b8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044ba:	0001e517          	auipc	a0,0x1e
    800044be:	57e50513          	addi	a0,a0,1406 # 80022a38 <ftable>
    800044c2:	f10fc0ef          	jal	80000bd2 <acquire>
  if (f->ref < 1)
    800044c6:	40dc                	lw	a5,4(s1)
    800044c8:	04f05a63          	blez	a5,8000451c <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800044cc:	37fd                	addiw	a5,a5,-1
    800044ce:	0007871b          	sext.w	a4,a5
    800044d2:	c0dc                	sw	a5,4(s1)
    800044d4:	04e04e63          	bgtz	a4,80004530 <fileclose+0x82>
    800044d8:	f04a                	sd	s2,32(sp)
    800044da:	ec4e                	sd	s3,24(sp)
    800044dc:	e852                	sd	s4,16(sp)
    800044de:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044e0:	0004a903          	lw	s2,0(s1)
    800044e4:	0094ca83          	lbu	s5,9(s1)
    800044e8:	0104ba03          	ld	s4,16(s1)
    800044ec:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044f0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044f4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044f8:	0001e517          	auipc	a0,0x1e
    800044fc:	54050513          	addi	a0,a0,1344 # 80022a38 <ftable>
    80004500:	f5efc0ef          	jal	80000c5e <release>

  if (ff.type == FD_PIPE) {
    80004504:	4785                	li	a5,1
    80004506:	04f90063          	beq	s2,a5,80004546 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000450a:	3979                	addiw	s2,s2,-2
    8000450c:	4785                	li	a5,1
    8000450e:	0527f563          	bgeu	a5,s2,80004558 <fileclose+0xaa>
    80004512:	7902                	ld	s2,32(sp)
    80004514:	69e2                	ld	s3,24(sp)
    80004516:	6a42                	ld	s4,16(sp)
    80004518:	6aa2                	ld	s5,8(sp)
    8000451a:	a00d                	j	8000453c <fileclose+0x8e>
    8000451c:	f04a                	sd	s2,32(sp)
    8000451e:	ec4e                	sd	s3,24(sp)
    80004520:	e852                	sd	s4,16(sp)
    80004522:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004524:	00003517          	auipc	a0,0x3
    80004528:	18c50513          	addi	a0,a0,396 # 800076b0 <etext+0x6b0>
    8000452c:	ac4fc0ef          	jal	800007f0 <panic>
    release(&ftable.lock);
    80004530:	0001e517          	auipc	a0,0x1e
    80004534:	50850513          	addi	a0,a0,1288 # 80022a38 <ftable>
    80004538:	f26fc0ef          	jal	80000c5e <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000453c:	70e2                	ld	ra,56(sp)
    8000453e:	7442                	ld	s0,48(sp)
    80004540:	74a2                	ld	s1,40(sp)
    80004542:	6121                	addi	sp,sp,64
    80004544:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004546:	85d6                	mv	a1,s5
    80004548:	8552                	mv	a0,s4
    8000454a:	39c000ef          	jal	800048e6 <pipeclose>
    8000454e:	7902                	ld	s2,32(sp)
    80004550:	69e2                	ld	s3,24(sp)
    80004552:	6a42                	ld	s4,16(sp)
    80004554:	6aa2                	ld	s5,8(sp)
    80004556:	b7dd                	j	8000453c <fileclose+0x8e>
    begin_op();
    80004558:	aabff0ef          	jal	80004002 <begin_op>
    iput(ff.ip);
    8000455c:	854e                	mv	a0,s3
    8000455e:	9deff0ef          	jal	8000373c <iput>
    end_op();
    80004562:	b27ff0ef          	jal	80004088 <end_op>
    80004566:	7902                	ld	s2,32(sp)
    80004568:	69e2                	ld	s3,24(sp)
    8000456a:	6a42                	ld	s4,16(sp)
    8000456c:	6aa2                	ld	s5,8(sp)
    8000456e:	b7f9                	j	8000453c <fileclose+0x8e>

0000000080004570 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004570:	715d                	addi	sp,sp,-80
    80004572:	e486                	sd	ra,72(sp)
    80004574:	e0a2                	sd	s0,64(sp)
    80004576:	fc26                	sd	s1,56(sp)
    80004578:	f44e                	sd	s3,40(sp)
    8000457a:	0880                	addi	s0,sp,80
    8000457c:	84aa                	mv	s1,a0
    8000457e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004580:	b64fd0ef          	jal	800018e4 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004584:	409c                	lw	a5,0(s1)
    80004586:	37f9                	addiw	a5,a5,-2
    80004588:	4705                	li	a4,1
    8000458a:	04f76263          	bltu	a4,a5,800045ce <filestat+0x5e>
    8000458e:	f84a                	sd	s2,48(sp)
    80004590:	892a                	mv	s2,a0
    ilock(f->ip);
    80004592:	6c88                	ld	a0,24(s1)
    80004594:	826ff0ef          	jal	800035ba <ilock>
    stati(f->ip, &st);
    80004598:	fb840593          	addi	a1,s0,-72
    8000459c:	6c88                	ld	a0,24(s1)
    8000459e:	bcaff0ef          	jal	80003968 <stati>
    iunlock(f->ip);
    800045a2:	6c88                	ld	a0,24(s1)
    800045a4:	8c4ff0ef          	jal	80003668 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800045a8:	4761                	li	a4,24
    800045aa:	fb840693          	addi	a3,s0,-72
    800045ae:	864e                	mv	a2,s3
    800045b0:	04893583          	ld	a1,72(s2)
    800045b4:	05093503          	ld	a0,80(s2)
    800045b8:	f63fc0ef          	jal	8000151a <copyout>
    800045bc:	41f5551b          	sraiw	a0,a0,0x1f
    800045c0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800045c2:	60a6                	ld	ra,72(sp)
    800045c4:	6406                	ld	s0,64(sp)
    800045c6:	74e2                	ld	s1,56(sp)
    800045c8:	79a2                	ld	s3,40(sp)
    800045ca:	6161                	addi	sp,sp,80
    800045cc:	8082                	ret
  return -1;
    800045ce:	557d                	li	a0,-1
    800045d0:	bfcd                	j	800045c2 <filestat+0x52>

00000000800045d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045d2:	7179                	addi	sp,sp,-48
    800045d4:	f406                	sd	ra,40(sp)
    800045d6:	f022                	sd	s0,32(sp)
    800045d8:	e84a                	sd	s2,16(sp)
    800045da:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800045dc:	00854783          	lbu	a5,8(a0)
    800045e0:	c3c5                	beqz	a5,80004680 <fileread+0xae>
    800045e2:	ec26                	sd	s1,24(sp)
    800045e4:	e44e                	sd	s3,8(sp)
    800045e6:	84aa                	mv	s1,a0
    800045e8:	89ae                	mv	s3,a1
    800045ea:	8932                	mv	s2,a2
    800045ec:	08064c63          	bltz	a2,80004684 <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    800045f0:	411c                	lw	a5,0(a0)
    800045f2:	4705                	li	a4,1
    800045f4:	04e78363          	beq	a5,a4,8000463a <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800045f8:	470d                	li	a4,3
    800045fa:	04e78763          	beq	a5,a4,80004648 <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800045fe:	4709                	li	a4,2
    80004600:	06e79a63          	bne	a5,a4,80004674 <fileread+0xa2>
    ilock(f->ip);
    80004604:	6d08                	ld	a0,24(a0)
    80004606:	fb5fe0ef          	jal	800035ba <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000460a:	874a                	mv	a4,s2
    8000460c:	5094                	lw	a3,32(s1)
    8000460e:	864e                	mv	a2,s3
    80004610:	4585                	li	a1,1
    80004612:	6c88                	ld	a0,24(s1)
    80004614:	b7eff0ef          	jal	80003992 <readi>
    80004618:	892a                	mv	s2,a0
    8000461a:	00a05563          	blez	a0,80004624 <fileread+0x52>
      f->off += r;
    8000461e:	509c                	lw	a5,32(s1)
    80004620:	9fa9                	addw	a5,a5,a0
    80004622:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004624:	6c88                	ld	a0,24(s1)
    80004626:	842ff0ef          	jal	80003668 <iunlock>
    8000462a:	64e2                	ld	s1,24(sp)
    8000462c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000462e:	854a                	mv	a0,s2
    80004630:	70a2                	ld	ra,40(sp)
    80004632:	7402                	ld	s0,32(sp)
    80004634:	6942                	ld	s2,16(sp)
    80004636:	6145                	addi	sp,sp,48
    80004638:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000463a:	6908                	ld	a0,16(a0)
    8000463c:	406000ef          	jal	80004a42 <piperead>
    80004640:	892a                	mv	s2,a0
    80004642:	64e2                	ld	s1,24(sp)
    80004644:	69a2                	ld	s3,8(sp)
    80004646:	b7e5                	j	8000462e <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004648:	02451783          	lh	a5,36(a0)
    8000464c:	03079693          	slli	a3,a5,0x30
    80004650:	92c1                	srli	a3,a3,0x30
    80004652:	4725                	li	a4,9
    80004654:	02d76c63          	bltu	a4,a3,8000468c <fileread+0xba>
    80004658:	0792                	slli	a5,a5,0x4
    8000465a:	0001e717          	auipc	a4,0x1e
    8000465e:	33e70713          	addi	a4,a4,830 # 80022998 <devsw>
    80004662:	97ba                	add	a5,a5,a4
    80004664:	639c                	ld	a5,0(a5)
    80004666:	c79d                	beqz	a5,80004694 <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    80004668:	4505                	li	a0,1
    8000466a:	9782                	jalr	a5
    8000466c:	892a                	mv	s2,a0
    8000466e:	64e2                	ld	s1,24(sp)
    80004670:	69a2                	ld	s3,8(sp)
    80004672:	bf75                	j	8000462e <fileread+0x5c>
    panic("fileread");
    80004674:	00003517          	auipc	a0,0x3
    80004678:	04c50513          	addi	a0,a0,76 # 800076c0 <etext+0x6c0>
    8000467c:	974fc0ef          	jal	800007f0 <panic>
    return -1;
    80004680:	597d                	li	s2,-1
    80004682:	b775                	j	8000462e <fileread+0x5c>
    80004684:	597d                	li	s2,-1
    80004686:	64e2                	ld	s1,24(sp)
    80004688:	69a2                	ld	s3,8(sp)
    8000468a:	b755                	j	8000462e <fileread+0x5c>
      return -1;
    8000468c:	597d                	li	s2,-1
    8000468e:	64e2                	ld	s1,24(sp)
    80004690:	69a2                	ld	s3,8(sp)
    80004692:	bf71                	j	8000462e <fileread+0x5c>
    80004694:	597d                	li	s2,-1
    80004696:	64e2                	ld	s1,24(sp)
    80004698:	69a2                	ld	s3,8(sp)
    8000469a:	bf51                	j	8000462e <fileread+0x5c>

000000008000469c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    8000469c:	00954783          	lbu	a5,9(a0)
    800046a0:	10078663          	beqz	a5,800047ac <filewrite+0x110>
{
    800046a4:	715d                	addi	sp,sp,-80
    800046a6:	e486                	sd	ra,72(sp)
    800046a8:	e0a2                	sd	s0,64(sp)
    800046aa:	f84a                	sd	s2,48(sp)
    800046ac:	f052                	sd	s4,32(sp)
    800046ae:	e85a                	sd	s6,16(sp)
    800046b0:	0880                	addi	s0,sp,80
    800046b2:	892a                	mv	s2,a0
    800046b4:	8b2e                	mv	s6,a1
    800046b6:	8a32                	mv	s4,a2
  if (f->writable == 0 || n < 0)
    800046b8:	0e064c63          	bltz	a2,800047b0 <filewrite+0x114>
    return -1;

  if (f->type == FD_PIPE) {
    800046bc:	411c                	lw	a5,0(a0)
    800046be:	4705                	li	a4,1
    800046c0:	02e78763          	beq	a5,a4,800046ee <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800046c4:	470d                	li	a4,3
    800046c6:	02e78863          	beq	a5,a4,800046f6 <filewrite+0x5a>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800046ca:	4709                	li	a4,2
    800046cc:	0ce79563          	bne	a5,a4,80004796 <filewrite+0xfa>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800046d0:	0ec05663          	blez	a2,800047bc <filewrite+0x120>
    800046d4:	fc26                	sd	s1,56(sp)
    800046d6:	f44e                	sd	s3,40(sp)
    800046d8:	ec56                	sd	s5,24(sp)
    800046da:	e45e                	sd	s7,8(sp)
    800046dc:	e062                	sd	s8,0(sp)
    int i = 0;
    800046de:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    800046e0:	6b85                	lui	s7,0x1
    800046e2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800046e6:	6c05                	lui	s8,0x1
    800046e8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800046ec:	a8b5                	j	80004768 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800046ee:	6908                	ld	a0,16(a0)
    800046f0:	24e000ef          	jal	8000493e <pipewrite>
    800046f4:	a851                	j	80004788 <filewrite+0xec>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046f6:	02451783          	lh	a5,36(a0)
    800046fa:	03079693          	slli	a3,a5,0x30
    800046fe:	92c1                	srli	a3,a3,0x30
    80004700:	4725                	li	a4,9
    80004702:	0ad76963          	bltu	a4,a3,800047b4 <filewrite+0x118>
    80004706:	0792                	slli	a5,a5,0x4
    80004708:	0001e717          	auipc	a4,0x1e
    8000470c:	29070713          	addi	a4,a4,656 # 80022998 <devsw>
    80004710:	97ba                	add	a5,a5,a4
    80004712:	679c                	ld	a5,8(a5)
    80004714:	c3d5                	beqz	a5,800047b8 <filewrite+0x11c>
    ret = devsw[f->major].write(1, addr, n);
    80004716:	4505                	li	a0,1
    80004718:	9782                	jalr	a5
    8000471a:	a0bd                	j	80004788 <filewrite+0xec>
      if (n1 > max)
    8000471c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004720:	8e3ff0ef          	jal	80004002 <begin_op>
      ilock(f->ip);
    80004724:	01893503          	ld	a0,24(s2)
    80004728:	e93fe0ef          	jal	800035ba <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000472c:	8756                	mv	a4,s5
    8000472e:	02092683          	lw	a3,32(s2)
    80004732:	01698633          	add	a2,s3,s6
    80004736:	4585                	li	a1,1
    80004738:	01893503          	ld	a0,24(s2)
    8000473c:	b52ff0ef          	jal	80003a8e <writei>
    80004740:	84aa                	mv	s1,a0
    80004742:	00a05763          	blez	a0,80004750 <filewrite+0xb4>
        f->off += r;
    80004746:	02092783          	lw	a5,32(s2)
    8000474a:	9fa9                	addw	a5,a5,a0
    8000474c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004750:	01893503          	ld	a0,24(s2)
    80004754:	f15fe0ef          	jal	80003668 <iunlock>
      end_op();
    80004758:	931ff0ef          	jal	80004088 <end_op>

      if (r != n1) {
    8000475c:	009a9e63          	bne	s5,s1,80004778 <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    80004760:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    80004764:	0149da63          	bge	s3,s4,80004778 <filewrite+0xdc>
      int n1 = n - i;
    80004768:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    8000476c:	0004879b          	sext.w	a5,s1
    80004770:	fafbd6e3          	bge	s7,a5,8000471c <filewrite+0x80>
    80004774:	84e2                	mv	s1,s8
    80004776:	b75d                	j	8000471c <filewrite+0x80>
    }
    ret = (i == n ? n : -1);
    80004778:	053a1463          	bne	s4,s3,800047c0 <filewrite+0x124>
    8000477c:	8552                	mv	a0,s4
    8000477e:	74e2                	ld	s1,56(sp)
    80004780:	79a2                	ld	s3,40(sp)
    80004782:	6ae2                	ld	s5,24(sp)
    80004784:	6ba2                	ld	s7,8(sp)
    80004786:	6c02                	ld	s8,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004788:	60a6                	ld	ra,72(sp)
    8000478a:	6406                	ld	s0,64(sp)
    8000478c:	7942                	ld	s2,48(sp)
    8000478e:	7a02                	ld	s4,32(sp)
    80004790:	6b42                	ld	s6,16(sp)
    80004792:	6161                	addi	sp,sp,80
    80004794:	8082                	ret
    80004796:	fc26                	sd	s1,56(sp)
    80004798:	f44e                	sd	s3,40(sp)
    8000479a:	ec56                	sd	s5,24(sp)
    8000479c:	e45e                	sd	s7,8(sp)
    8000479e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800047a0:	00003517          	auipc	a0,0x3
    800047a4:	f3050513          	addi	a0,a0,-208 # 800076d0 <etext+0x6d0>
    800047a8:	848fc0ef          	jal	800007f0 <panic>
    return -1;
    800047ac:	557d                	li	a0,-1
}
    800047ae:	8082                	ret
    return -1;
    800047b0:	557d                	li	a0,-1
    800047b2:	bfd9                	j	80004788 <filewrite+0xec>
      return -1;
    800047b4:	557d                	li	a0,-1
    800047b6:	bfc9                	j	80004788 <filewrite+0xec>
    800047b8:	557d                	li	a0,-1
    800047ba:	b7f9                	j	80004788 <filewrite+0xec>
    ret = (i == n ? n : -1);
    800047bc:	8532                	mv	a0,a2
    800047be:	b7e9                	j	80004788 <filewrite+0xec>
    800047c0:	557d                	li	a0,-1
    800047c2:	74e2                	ld	s1,56(sp)
    800047c4:	79a2                	ld	s3,40(sp)
    800047c6:	6ae2                	ld	s5,24(sp)
    800047c8:	6ba2                	ld	s7,8(sp)
    800047ca:	6c02                	ld	s8,0(sp)
    800047cc:	bf75                	j	80004788 <filewrite+0xec>

00000000800047ce <count_open_files>:

uint64
count_open_files(void)
{
    800047ce:	1101                	addi	sp,sp,-32
    800047d0:	ec06                	sd	ra,24(sp)
    800047d2:	e822                	sd	s0,16(sp)
    800047d4:	e426                	sd	s1,8(sp)
    800047d6:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 count = 0;

  // Read ftable.lock to securely count open entries
  acquire(&ftable.lock);
    800047d8:	0001e517          	auipc	a0,0x1e
    800047dc:	26050513          	addi	a0,a0,608 # 80022a38 <ftable>
    800047e0:	bf2fc0ef          	jal	80000bd2 <acquire>
  uint64 count = 0;
    800047e4:	4481                	li	s1,0
  for(f = ftable.file; f < &ftable.file[NFILE]; f++) {
    800047e6:	0001e797          	auipc	a5,0x1e
    800047ea:	26a78793          	addi	a5,a5,618 # 80022a50 <ftable+0x18>
    800047ee:	0001f697          	auipc	a3,0x1f
    800047f2:	20268693          	addi	a3,a3,514 # 800239f0 <disk>
    if(f->ref > 0) {
    800047f6:	43d8                	lw	a4,4(a5)
      count++;
    800047f8:	00e02733          	sgtz	a4,a4
    800047fc:	94ba                	add	s1,s1,a4
  for(f = ftable.file; f < &ftable.file[NFILE]; f++) {
    800047fe:	02878793          	addi	a5,a5,40
    80004802:	fed79ae3          	bne	a5,a3,800047f6 <count_open_files+0x28>
    }
  }
  release(&ftable.lock);
    80004806:	0001e517          	auipc	a0,0x1e
    8000480a:	23250513          	addi	a0,a0,562 # 80022a38 <ftable>
    8000480e:	c50fc0ef          	jal	80000c5e <release>
  return count;
}
    80004812:	8526                	mv	a0,s1
    80004814:	60e2                	ld	ra,24(sp)
    80004816:	6442                	ld	s0,16(sp)
    80004818:	64a2                	ld	s1,8(sp)
    8000481a:	6105                	addi	sp,sp,32
    8000481c:	8082                	ret

000000008000481e <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000481e:	7179                	addi	sp,sp,-48
    80004820:	f406                	sd	ra,40(sp)
    80004822:	f022                	sd	s0,32(sp)
    80004824:	ec26                	sd	s1,24(sp)
    80004826:	e052                	sd	s4,0(sp)
    80004828:	1800                	addi	s0,sp,48
    8000482a:	84aa                	mv	s1,a0
    8000482c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000482e:	0005b023          	sd	zero,0(a1)
    80004832:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004836:	bd5ff0ef          	jal	8000440a <filealloc>
    8000483a:	e088                	sd	a0,0(s1)
    8000483c:	c549                	beqz	a0,800048c6 <pipealloc+0xa8>
    8000483e:	bcdff0ef          	jal	8000440a <filealloc>
    80004842:	00aa3023          	sd	a0,0(s4)
    80004846:	cd25                	beqz	a0,800048be <pipealloc+0xa0>
    80004848:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000484a:	a80fc0ef          	jal	80000aca <kalloc>
    8000484e:	892a                	mv	s2,a0
    80004850:	c12d                	beqz	a0,800048b2 <pipealloc+0x94>
    80004852:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004854:	4985                	li	s3,1
    80004856:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000485a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000485e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004862:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004866:	00003597          	auipc	a1,0x3
    8000486a:	b8a58593          	addi	a1,a1,-1142 # 800073f0 <etext+0x3f0>
    8000486e:	aeefc0ef          	jal	80000b5c <initlock>
  (*f0)->type = FD_PIPE;
    80004872:	609c                	ld	a5,0(s1)
    80004874:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004878:	609c                	ld	a5,0(s1)
    8000487a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000487e:	609c                	ld	a5,0(s1)
    80004880:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004884:	609c                	ld	a5,0(s1)
    80004886:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000488a:	000a3783          	ld	a5,0(s4)
    8000488e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004892:	000a3783          	ld	a5,0(s4)
    80004896:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000489a:	000a3783          	ld	a5,0(s4)
    8000489e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048a2:	000a3783          	ld	a5,0(s4)
    800048a6:	0127b823          	sd	s2,16(a5)
  return 0;
    800048aa:	4501                	li	a0,0
    800048ac:	6942                	ld	s2,16(sp)
    800048ae:	69a2                	ld	s3,8(sp)
    800048b0:	a01d                	j	800048d6 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800048b2:	6088                	ld	a0,0(s1)
    800048b4:	c119                	beqz	a0,800048ba <pipealloc+0x9c>
    800048b6:	6942                	ld	s2,16(sp)
    800048b8:	a029                	j	800048c2 <pipealloc+0xa4>
    800048ba:	6942                	ld	s2,16(sp)
    800048bc:	a029                	j	800048c6 <pipealloc+0xa8>
    800048be:	6088                	ld	a0,0(s1)
    800048c0:	c10d                	beqz	a0,800048e2 <pipealloc+0xc4>
    fileclose(*f0);
    800048c2:	bedff0ef          	jal	800044ae <fileclose>
  if (*f1)
    800048c6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048ca:	557d                	li	a0,-1
  if (*f1)
    800048cc:	c789                	beqz	a5,800048d6 <pipealloc+0xb8>
    fileclose(*f1);
    800048ce:	853e                	mv	a0,a5
    800048d0:	bdfff0ef          	jal	800044ae <fileclose>
  return -1;
    800048d4:	557d                	li	a0,-1
}
    800048d6:	70a2                	ld	ra,40(sp)
    800048d8:	7402                	ld	s0,32(sp)
    800048da:	64e2                	ld	s1,24(sp)
    800048dc:	6a02                	ld	s4,0(sp)
    800048de:	6145                	addi	sp,sp,48
    800048e0:	8082                	ret
  return -1;
    800048e2:	557d                	li	a0,-1
    800048e4:	bfcd                	j	800048d6 <pipealloc+0xb8>

00000000800048e6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048e6:	1101                	addi	sp,sp,-32
    800048e8:	ec06                	sd	ra,24(sp)
    800048ea:	e822                	sd	s0,16(sp)
    800048ec:	e426                	sd	s1,8(sp)
    800048ee:	e04a                	sd	s2,0(sp)
    800048f0:	1000                	addi	s0,sp,32
    800048f2:	84aa                	mv	s1,a0
    800048f4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048f6:	adcfc0ef          	jal	80000bd2 <acquire>
  if (writable) {
    800048fa:	02090763          	beqz	s2,80004928 <pipeclose+0x42>
    pi->writeopen = 0;
    800048fe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004902:	21848513          	addi	a0,s1,536
    80004906:	e5afd0ef          	jal	80001f60 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000490a:	2204b783          	ld	a5,544(s1)
    8000490e:	e785                	bnez	a5,80004936 <pipeclose+0x50>
    release(&pi->lock);
    80004910:	8526                	mv	a0,s1
    80004912:	b4cfc0ef          	jal	80000c5e <release>
    kfree((char *)pi);
    80004916:	8526                	mv	a0,s1
    80004918:	8d0fc0ef          	jal	800009e8 <kfree>
  } else
    release(&pi->lock);
}
    8000491c:	60e2                	ld	ra,24(sp)
    8000491e:	6442                	ld	s0,16(sp)
    80004920:	64a2                	ld	s1,8(sp)
    80004922:	6902                	ld	s2,0(sp)
    80004924:	6105                	addi	sp,sp,32
    80004926:	8082                	ret
    pi->readopen = 0;
    80004928:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000492c:	21c48513          	addi	a0,s1,540
    80004930:	e30fd0ef          	jal	80001f60 <wakeup>
    80004934:	bfd9                	j	8000490a <pipeclose+0x24>
    release(&pi->lock);
    80004936:	8526                	mv	a0,s1
    80004938:	b26fc0ef          	jal	80000c5e <release>
}
    8000493c:	b7c5                	j	8000491c <pipeclose+0x36>

000000008000493e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000493e:	711d                	addi	sp,sp,-96
    80004940:	ec86                	sd	ra,88(sp)
    80004942:	e8a2                	sd	s0,80(sp)
    80004944:	e4a6                	sd	s1,72(sp)
    80004946:	e0ca                	sd	s2,64(sp)
    80004948:	fc4e                	sd	s3,56(sp)
    8000494a:	f852                	sd	s4,48(sp)
    8000494c:	f456                	sd	s5,40(sp)
    8000494e:	1080                	addi	s0,sp,96
    80004950:	84aa                	mv	s1,a0
    80004952:	8aae                	mv	s5,a1
    80004954:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004956:	f8ffc0ef          	jal	800018e4 <myproc>
    8000495a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000495c:	8526                	mv	a0,s1
    8000495e:	a74fc0ef          	jal	80000bd2 <acquire>
  while (i < n) {
    80004962:	0d405e63          	blez	s4,80004a3e <pipewrite+0x100>
    80004966:	f05a                	sd	s6,32(sp)
    80004968:	ec5e                	sd	s7,24(sp)
    8000496a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000496c:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000496e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004970:	21848c13          	addi	s8,s1,536
      sleep_prepare(&pi->nwrite);
    80004974:	21c48b93          	addi	s7,s1,540
    80004978:	a091                	j	800049bc <pipewrite+0x7e>
      release(&pi->lock);
    8000497a:	8526                	mv	a0,s1
    8000497c:	ae2fc0ef          	jal	80000c5e <release>
      return -1;
    80004980:	597d                	li	s2,-1
    80004982:	7b02                	ld	s6,32(sp)
    80004984:	6be2                	ld	s7,24(sp)
    80004986:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004988:	854a                	mv	a0,s2
    8000498a:	60e6                	ld	ra,88(sp)
    8000498c:	6446                	ld	s0,80(sp)
    8000498e:	64a6                	ld	s1,72(sp)
    80004990:	6906                	ld	s2,64(sp)
    80004992:	79e2                	ld	s3,56(sp)
    80004994:	7a42                	ld	s4,48(sp)
    80004996:	7aa2                	ld	s5,40(sp)
    80004998:	6125                	addi	sp,sp,96
    8000499a:	8082                	ret
      wakeup(&pi->nread);
    8000499c:	8562                	mv	a0,s8
    8000499e:	dc2fd0ef          	jal	80001f60 <wakeup>
      sleep_prepare(&pi->nwrite);
    800049a2:	855e                	mv	a0,s7
    800049a4:	d50fd0ef          	jal	80001ef4 <sleep_prepare>
      release(&pi->lock);
    800049a8:	8526                	mv	a0,s1
    800049aa:	ab4fc0ef          	jal	80000c5e <release>
      sleep();
    800049ae:	d82fd0ef          	jal	80001f30 <sleep>
      acquire(&pi->lock);
    800049b2:	8526                	mv	a0,s1
    800049b4:	a1efc0ef          	jal	80000bd2 <acquire>
  while (i < n) {
    800049b8:	07495863          	bge	s2,s4,80004a28 <pipewrite+0xea>
    if (pi->readopen == 0 || killed(pr)) {
    800049bc:	2204a783          	lw	a5,544(s1)
    800049c0:	dfcd                	beqz	a5,8000497a <pipewrite+0x3c>
    800049c2:	854e                	mv	a0,s3
    800049c4:	f8afd0ef          	jal	8000214e <killed>
    800049c8:	f94d                	bnez	a0,8000497a <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800049ca:	2184a783          	lw	a5,536(s1)
    800049ce:	21c4a703          	lw	a4,540(s1)
    800049d2:	2007879b          	addiw	a5,a5,512
    800049d6:	fcf703e3          	beq	a4,a5,8000499c <pipewrite+0x5e>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800049da:	4705                	li	a4,1
    800049dc:	015906b3          	add	a3,s2,s5
    800049e0:	faf40613          	addi	a2,s0,-81
    800049e4:	0489b583          	ld	a1,72(s3)
    800049e8:	0509b503          	ld	a0,80(s3)
    800049ec:	c1bfc0ef          	jal	80001606 <copyin>
    800049f0:	03650163          	beq	a0,s6,80004a12 <pipewrite+0xd4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049f4:	21c4a783          	lw	a5,540(s1)
    800049f8:	0017871b          	addiw	a4,a5,1
    800049fc:	20e4ae23          	sw	a4,540(s1)
    80004a00:	1ff7f793          	andi	a5,a5,511
    80004a04:	97a6                	add	a5,a5,s1
    80004a06:	faf44703          	lbu	a4,-81(s0)
    80004a0a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a0e:	2905                	addiw	s2,s2,1
    80004a10:	b765                	j	800049b8 <pipewrite+0x7a>
        if (i == 0)
    80004a12:	00090663          	beqz	s2,80004a1e <pipewrite+0xe0>
    80004a16:	7b02                	ld	s6,32(sp)
    80004a18:	6be2                	ld	s7,24(sp)
    80004a1a:	6c42                	ld	s8,16(sp)
    80004a1c:	a809                	j	80004a2e <pipewrite+0xf0>
          i = -1;
    80004a1e:	892a                	mv	s2,a0
        break;
    80004a20:	7b02                	ld	s6,32(sp)
    80004a22:	6be2                	ld	s7,24(sp)
    80004a24:	6c42                	ld	s8,16(sp)
    80004a26:	a021                	j	80004a2e <pipewrite+0xf0>
    80004a28:	7b02                	ld	s6,32(sp)
    80004a2a:	6be2                	ld	s7,24(sp)
    80004a2c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004a2e:	21848513          	addi	a0,s1,536
    80004a32:	d2efd0ef          	jal	80001f60 <wakeup>
  release(&pi->lock);
    80004a36:	8526                	mv	a0,s1
    80004a38:	a26fc0ef          	jal	80000c5e <release>
  return i;
    80004a3c:	b7b1                	j	80004988 <pipewrite+0x4a>
  int i = 0;
    80004a3e:	4901                	li	s2,0
    80004a40:	b7fd                	j	80004a2e <pipewrite+0xf0>

0000000080004a42 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a42:	715d                	addi	sp,sp,-80
    80004a44:	e486                	sd	ra,72(sp)
    80004a46:	e0a2                	sd	s0,64(sp)
    80004a48:	fc26                	sd	s1,56(sp)
    80004a4a:	f84a                	sd	s2,48(sp)
    80004a4c:	f44e                	sd	s3,40(sp)
    80004a4e:	f052                	sd	s4,32(sp)
    80004a50:	ec56                	sd	s5,24(sp)
    80004a52:	0880                	addi	s0,sp,80
    80004a54:	84aa                	mv	s1,a0
    80004a56:	89ae                	mv	s3,a1
    80004a58:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a5a:	e8bfc0ef          	jal	800018e4 <myproc>
    80004a5e:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004a60:	8526                	mv	a0,s1
    80004a62:	970fc0ef          	jal	80000bd2 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a66:	2184a703          	lw	a4,536(s1)
    80004a6a:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004a6e:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a72:	02f71c63          	bne	a4,a5,80004aaa <piperead+0x68>
    80004a76:	2244a783          	lw	a5,548(s1)
    80004a7a:	cf9d                	beqz	a5,80004ab8 <piperead+0x76>
    if (killed(pr)) {
    80004a7c:	854a                	mv	a0,s2
    80004a7e:	ed0fd0ef          	jal	8000214e <killed>
    80004a82:	e515                	bnez	a0,80004aae <piperead+0x6c>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004a84:	8552                	mv	a0,s4
    80004a86:	c6efd0ef          	jal	80001ef4 <sleep_prepare>
    release(&pi->lock);
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	9d2fc0ef          	jal	80000c5e <release>
    sleep();
    80004a90:	ca0fd0ef          	jal	80001f30 <sleep>
    acquire(&pi->lock);
    80004a94:	8526                	mv	a0,s1
    80004a96:	93cfc0ef          	jal	80000bd2 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004a9a:	2184a703          	lw	a4,536(s1)
    80004a9e:	21c4a783          	lw	a5,540(s1)
    80004aa2:	fcf70ae3          	beq	a4,a5,80004a76 <piperead+0x34>
    80004aa6:	e85a                	sd	s6,16(sp)
    80004aa8:	a809                	j	80004aba <piperead+0x78>
    80004aaa:	e85a                	sd	s6,16(sp)
    80004aac:	a039                	j	80004aba <piperead+0x78>
      release(&pi->lock);
    80004aae:	8526                	mv	a0,s1
    80004ab0:	9aefc0ef          	jal	80000c5e <release>
      return -1;
    80004ab4:	5a7d                	li	s4,-1
    80004ab6:	a08d                	j	80004b18 <piperead+0xd6>
    80004ab8:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004aba:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004abc:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004abe:	05505563          	blez	s5,80004b08 <piperead+0xc6>
    if (pi->nread == pi->nwrite)
    80004ac2:	2184a783          	lw	a5,536(s1)
    80004ac6:	21c4a703          	lw	a4,540(s1)
    80004aca:	02f70f63          	beq	a4,a5,80004b08 <piperead+0xc6>
    ch = pi->data[pi->nread % PIPESIZE];
    80004ace:	1ff7f793          	andi	a5,a5,511
    80004ad2:	97a6                	add	a5,a5,s1
    80004ad4:	0187c783          	lbu	a5,24(a5)
    80004ad8:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004adc:	4705                	li	a4,1
    80004ade:	fbf40693          	addi	a3,s0,-65
    80004ae2:	864e                	mv	a2,s3
    80004ae4:	04893583          	ld	a1,72(s2)
    80004ae8:	05093503          	ld	a0,80(s2)
    80004aec:	a2ffc0ef          	jal	8000151a <copyout>
    80004af0:	03650e63          	beq	a0,s6,80004b2c <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004af4:	2184a783          	lw	a5,536(s1)
    80004af8:	2785                	addiw	a5,a5,1
    80004afa:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004afe:	2a05                	addiw	s4,s4,1
    80004b00:	0985                	addi	s3,s3,1
    80004b02:	fd4a90e3          	bne	s5,s4,80004ac2 <piperead+0x80>
    80004b06:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004b08:	21c48513          	addi	a0,s1,540
    80004b0c:	c54fd0ef          	jal	80001f60 <wakeup>
  release(&pi->lock);
    80004b10:	8526                	mv	a0,s1
    80004b12:	94cfc0ef          	jal	80000c5e <release>
    80004b16:	6b42                	ld	s6,16(sp)
  return i;
}
    80004b18:	8552                	mv	a0,s4
    80004b1a:	60a6                	ld	ra,72(sp)
    80004b1c:	6406                	ld	s0,64(sp)
    80004b1e:	74e2                	ld	s1,56(sp)
    80004b20:	7942                	ld	s2,48(sp)
    80004b22:	79a2                	ld	s3,40(sp)
    80004b24:	7a02                	ld	s4,32(sp)
    80004b26:	6ae2                	ld	s5,24(sp)
    80004b28:	6161                	addi	sp,sp,80
    80004b2a:	8082                	ret
      if (i == 0)
    80004b2c:	fc0a1ee3          	bnez	s4,80004b08 <piperead+0xc6>
        i = -1;
    80004b30:	8a2a                	mv	s4,a0
    80004b32:	bfd9                	j	80004b08 <piperead+0xc6>

0000000080004b34 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004b34:	1141                	addi	sp,sp,-16
    80004b36:	e422                	sd	s0,8(sp)
    80004b38:	0800                	addi	s0,sp,16
    80004b3a:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004b3c:	8905                	andi	a0,a0,1
    80004b3e:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004b40:	8b89                	andi	a5,a5,2
    80004b42:	c399                	beqz	a5,80004b48 <flags2perm+0x14>
    perm |= PTE_W;
    80004b44:	00456513          	ori	a0,a0,4
  return perm;
}
    80004b48:	6422                	ld	s0,8(sp)
    80004b4a:	0141                	addi	sp,sp,16
    80004b4c:	8082                	ret

0000000080004b4e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004b4e:	df010113          	addi	sp,sp,-528
    80004b52:	20113423          	sd	ra,520(sp)
    80004b56:	20813023          	sd	s0,512(sp)
    80004b5a:	ffa6                	sd	s1,504(sp)
    80004b5c:	fbca                	sd	s2,496(sp)
    80004b5e:	0c00                	addi	s0,sp,528
    80004b60:	892a                	mv	s2,a0
    80004b62:	dea43c23          	sd	a0,-520(s0)
    80004b66:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b6a:	d7bfc0ef          	jal	800018e4 <myproc>
    80004b6e:	84aa                	mv	s1,a0

  begin_op();
    80004b70:	c92ff0ef          	jal	80004002 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004b74:	854a                	mv	a0,s2
    80004b76:	ab8ff0ef          	jal	80003e2e <namei>
    80004b7a:	c931                	beqz	a0,80004bce <kexec+0x80>
    80004b7c:	f3d2                	sd	s4,480(sp)
    80004b7e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b80:	a3bfe0ef          	jal	800035ba <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b84:	04000713          	li	a4,64
    80004b88:	4681                	li	a3,0
    80004b8a:	e5040613          	addi	a2,s0,-432
    80004b8e:	4581                	li	a1,0
    80004b90:	8552                	mv	a0,s4
    80004b92:	e01fe0ef          	jal	80003992 <readi>
    80004b96:	04000793          	li	a5,64
    80004b9a:	00f51a63          	bne	a0,a5,80004bae <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004b9e:	e5042703          	lw	a4,-432(s0)
    80004ba2:	464c47b7          	lui	a5,0x464c4
    80004ba6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004baa:	02f70663          	beq	a4,a5,80004bd6 <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004bae:	8552                	mv	a0,s4
    80004bb0:	c5dfe0ef          	jal	8000380c <iunlockput>
    end_op();
    80004bb4:	cd4ff0ef          	jal	80004088 <end_op>
  }
  return -1;
    80004bb8:	557d                	li	a0,-1
    80004bba:	7a1e                	ld	s4,480(sp)
}
    80004bbc:	20813083          	ld	ra,520(sp)
    80004bc0:	20013403          	ld	s0,512(sp)
    80004bc4:	74fe                	ld	s1,504(sp)
    80004bc6:	795e                	ld	s2,496(sp)
    80004bc8:	21010113          	addi	sp,sp,528
    80004bcc:	8082                	ret
    end_op();
    80004bce:	cbaff0ef          	jal	80004088 <end_op>
    return -1;
    80004bd2:	557d                	li	a0,-1
    80004bd4:	b7e5                	j	80004bbc <kexec+0x6e>
    80004bd6:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004bd8:	8526                	mv	a0,s1
    80004bda:	e0dfc0ef          	jal	800019e6 <proc_pagetable>
    80004bde:	8b2a                	mv	s6,a0
    80004be0:	2c050963          	beqz	a0,80004eb2 <kexec+0x364>
    80004be4:	f7ce                	sd	s3,488(sp)
    80004be6:	efd6                	sd	s5,472(sp)
    80004be8:	e7de                	sd	s7,456(sp)
    80004bea:	e3e2                	sd	s8,448(sp)
    80004bec:	ff66                	sd	s9,440(sp)
    80004bee:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004bf0:	e7042d03          	lw	s10,-400(s0)
    80004bf4:	e8845783          	lhu	a5,-376(s0)
    80004bf8:	12078863          	beqz	a5,80004d28 <kexec+0x1da>
    80004bfc:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bfe:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c00:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    80004c02:	6c85                	lui	s9,0x1
    80004c04:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c08:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004c0c:	6a85                	lui	s5,0x1
    80004c0e:	a085                	j	80004c6e <kexec+0x120>
      panic("loadseg: address should exist");
    80004c10:	00003517          	auipc	a0,0x3
    80004c14:	ad050513          	addi	a0,a0,-1328 # 800076e0 <etext+0x6e0>
    80004c18:	bd9fb0ef          	jal	800007f0 <panic>
    if (sz - i < PGSIZE)
    80004c1c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004c1e:	8726                	mv	a4,s1
    80004c20:	012c06bb          	addw	a3,s8,s2
    80004c24:	4581                	li	a1,0
    80004c26:	8552                	mv	a0,s4
    80004c28:	d6bfe0ef          	jal	80003992 <readi>
    80004c2c:	2501                	sext.w	a0,a0
    80004c2e:	24a49863          	bne	s1,a0,80004e7e <kexec+0x330>
  for (i = 0; i < sz; i += PGSIZE) {
    80004c32:	012a893b          	addw	s2,s5,s2
    80004c36:	03397363          	bgeu	s2,s3,80004c5c <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004c3a:	02091593          	slli	a1,s2,0x20
    80004c3e:	9181                	srli	a1,a1,0x20
    80004c40:	95de                	add	a1,a1,s7
    80004c42:	855a                	mv	a0,s6
    80004c44:	b62fc0ef          	jal	80000fa6 <walkaddr>
    80004c48:	862a                	mv	a2,a0
    if (pa == 0)
    80004c4a:	d179                	beqz	a0,80004c10 <kexec+0xc2>
    if (sz - i < PGSIZE)
    80004c4c:	412984bb          	subw	s1,s3,s2
    80004c50:	0004879b          	sext.w	a5,s1
    80004c54:	fcfcf4e3          	bgeu	s9,a5,80004c1c <kexec+0xce>
    80004c58:	84d6                	mv	s1,s5
    80004c5a:	b7c9                	j	80004c1c <kexec+0xce>
    sz = sz1;
    80004c5c:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004c60:	2d85                	addiw	s11,s11,1
    80004c62:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004c66:	e8845783          	lhu	a5,-376(s0)
    80004c6a:	08fdd063          	bge	s11,a5,80004cea <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c6e:	2d01                	sext.w	s10,s10
    80004c70:	03800713          	li	a4,56
    80004c74:	86ea                	mv	a3,s10
    80004c76:	e1840613          	addi	a2,s0,-488
    80004c7a:	4581                	li	a1,0
    80004c7c:	8552                	mv	a0,s4
    80004c7e:	d15fe0ef          	jal	80003992 <readi>
    80004c82:	03800793          	li	a5,56
    80004c86:	1cf51463          	bne	a0,a5,80004e4e <kexec+0x300>
    if (ph.type != ELF_PROG_LOAD)
    80004c8a:	e1842783          	lw	a5,-488(s0)
    80004c8e:	4705                	li	a4,1
    80004c90:	fce798e3          	bne	a5,a4,80004c60 <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004c94:	e4043483          	ld	s1,-448(s0)
    80004c98:	e3843783          	ld	a5,-456(s0)
    80004c9c:	1af4ed63          	bltu	s1,a5,80004e56 <kexec+0x308>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004ca0:	e2843783          	ld	a5,-472(s0)
    80004ca4:	94be                	add	s1,s1,a5
    80004ca6:	1af4ec63          	bltu	s1,a5,80004e5e <kexec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    80004caa:	df043703          	ld	a4,-528(s0)
    80004cae:	8ff9                	and	a5,a5,a4
    80004cb0:	1a079b63          	bnez	a5,80004e66 <kexec+0x318>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004cb4:	e1c42503          	lw	a0,-484(s0)
    80004cb8:	e7dff0ef          	jal	80004b34 <flags2perm>
    80004cbc:	86aa                	mv	a3,a0
    80004cbe:	8626                	mv	a2,s1
    80004cc0:	85ca                	mv	a1,s2
    80004cc2:	855a                	mv	a0,s6
    80004cc4:	dbafc0ef          	jal	8000127e <uvmalloc>
    80004cc8:	e0a43423          	sd	a0,-504(s0)
    80004ccc:	1a050163          	beqz	a0,80004e6e <kexec+0x320>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004cd0:	e2843b83          	ld	s7,-472(s0)
    80004cd4:	e2042c03          	lw	s8,-480(s0)
    80004cd8:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004cdc:	00098463          	beqz	s3,80004ce4 <kexec+0x196>
    80004ce0:	4901                	li	s2,0
    80004ce2:	bfa1                	j	80004c3a <kexec+0xec>
    sz = sz1;
    80004ce4:	e0843903          	ld	s2,-504(s0)
    80004ce8:	bfa5                	j	80004c60 <kexec+0x112>
    80004cea:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004cec:	8552                	mv	a0,s4
    80004cee:	b1ffe0ef          	jal	8000380c <iunlockput>
  end_op();
    80004cf2:	b96ff0ef          	jal	80004088 <end_op>
  p = myproc();
    80004cf6:	beffc0ef          	jal	800018e4 <myproc>
    80004cfa:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004cfc:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    80004d00:	6b85                	lui	s7,0x1
    80004d02:	1bfd                	addi	s7,s7,-1 # fff <_entry-0x7ffff001>
    80004d04:	9bca                	add	s7,s7,s2
    80004d06:	77fd                	lui	a5,0xfffff
    80004d08:	00fbfbb3          	and	s7,s7,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004d0c:	4691                	li	a3,4
    80004d0e:	6609                	lui	a2,0x2
    80004d10:	965e                	add	a2,a2,s7
    80004d12:	85de                	mv	a1,s7
    80004d14:	855a                	mv	a0,s6
    80004d16:	d68fc0ef          	jal	8000127e <uvmalloc>
    80004d1a:	e0a43423          	sd	a0,-504(s0)
    80004d1e:	e519                	bnez	a0,80004d2c <kexec+0x1de>
  if (pagetable)
    80004d20:	e1743423          	sd	s7,-504(s0)
    80004d24:	4a01                	li	s4,0
    80004d26:	aaa9                	j	80004e80 <kexec+0x332>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d28:	4901                	li	s2,0
    80004d2a:	b7c9                	j	80004cec <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004d2c:	75f9                	lui	a1,0xffffe
    80004d2e:	8baa                	mv	s7,a0
    80004d30:	95aa                	add	a1,a1,a0
    80004d32:	855a                	mv	a0,s6
    80004d34:	f20fc0ef          	jal	80001454 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004d38:	7afd                	lui	s5,0xfffff
    80004d3a:	9ade                	add	s5,s5,s7
  for (argc = 0; argv[argc]; argc++) {
    80004d3c:	e0043783          	ld	a5,-512(s0)
    80004d40:	6388                	ld	a0,0(a5)
    80004d42:	c15d                	beqz	a0,80004de8 <kexec+0x29a>
    80004d44:	e9040913          	addi	s2,s0,-368
    80004d48:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d4a:	8bcfc0ef          	jal	80000e06 <strlen>
    80004d4e:	0015079b          	addiw	a5,a0,1
    80004d52:	40fb87b3          	sub	a5,s7,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d56:	ff07fb93          	andi	s7,a5,-16
    if (sp < stackbase)
    80004d5a:	115bee63          	bltu	s7,s5,80004e76 <kexec+0x328>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d5e:	e0043c83          	ld	s9,-512(s0)
    80004d62:	000cbc03          	ld	s8,0(s9)
    80004d66:	8562                	mv	a0,s8
    80004d68:	89efc0ef          	jal	80000e06 <strlen>
    80004d6c:	0015071b          	addiw	a4,a0,1
    80004d70:	86e2                	mv	a3,s8
    80004d72:	865e                	mv	a2,s7
    80004d74:	e0843583          	ld	a1,-504(s0)
    80004d78:	855a                	mv	a0,s6
    80004d7a:	fa0fc0ef          	jal	8000151a <copyout>
    80004d7e:	0e054e63          	bltz	a0,80004e7a <kexec+0x32c>
    ustack[argc] = sp;
    80004d82:	01793023          	sd	s7,0(s2)
  for (argc = 0; argv[argc]; argc++) {
    80004d86:	0485                	addi	s1,s1,1
    80004d88:	008c8793          	addi	a5,s9,8
    80004d8c:	e0f43023          	sd	a5,-512(s0)
    80004d90:	008cb503          	ld	a0,8(s9)
    80004d94:	0921                	addi	s2,s2,8
    80004d96:	f955                	bnez	a0,80004d4a <kexec+0x1fc>
  ustack[argc] = 0;
    80004d98:	00349793          	slli	a5,s1,0x3
    80004d9c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb460>
    80004da0:	97a2                	add	a5,a5,s0
    80004da2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004da6:	00148713          	addi	a4,s1,1
    80004daa:	070e                	slli	a4,a4,0x3
    80004dac:	40eb8933          	sub	s2,s7,a4
  sp -= sp % 16;
    80004db0:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004db4:	e0843583          	ld	a1,-504(s0)
    80004db8:	8bae                	mv	s7,a1
  if (sp < stackbase)
    80004dba:	f75963e3          	bltu	s2,s5,80004d20 <kexec+0x1d2>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004dbe:	e9040693          	addi	a3,s0,-368
    80004dc2:	864a                	mv	a2,s2
    80004dc4:	855a                	mv	a0,s6
    80004dc6:	f54fc0ef          	jal	8000151a <copyout>
    80004dca:	0e054663          	bltz	a0,80004eb6 <kexec+0x368>
  p->trapframe->a1 = sp;
    80004dce:	0589b783          	ld	a5,88(s3)
    80004dd2:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80004dd6:	df843783          	ld	a5,-520(s0)
    80004dda:	0007c703          	lbu	a4,0(a5)
    80004dde:	c315                	beqz	a4,80004e02 <kexec+0x2b4>
    80004de0:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004de2:	02f00693          	li	a3,47
    80004de6:	a809                	j	80004df8 <kexec+0x2aa>
  sp = sz;
    80004de8:	e0843b83          	ld	s7,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    80004dec:	4481                	li	s1,0
    80004dee:	b76d                	j	80004d98 <kexec+0x24a>
  for (last = s = path; *s; s++)
    80004df0:	0785                	addi	a5,a5,1
    80004df2:	fff7c703          	lbu	a4,-1(a5)
    80004df6:	c711                	beqz	a4,80004e02 <kexec+0x2b4>
    if (*s == '/')
    80004df8:	fed71ce3          	bne	a4,a3,80004df0 <kexec+0x2a2>
      last = s + 1;
    80004dfc:	def43c23          	sd	a5,-520(s0)
    80004e00:	bfc5                	j	80004df0 <kexec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e02:	4641                	li	a2,16
    80004e04:	df843583          	ld	a1,-520(s0)
    80004e08:	15c98513          	addi	a0,s3,348
    80004e0c:	fc9fb0ef          	jal	80000dd4 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e10:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004e14:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004e18:	e0843783          	ld	a5,-504(s0)
    80004e1c:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004e20:	0589b783          	ld	a5,88(s3)
    80004e24:	e6843703          	ld	a4,-408(s0)
    80004e28:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004e2a:	0589b783          	ld	a5,88(s3)
    80004e2e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e32:	85d2                	mv	a1,s4
    80004e34:	c37fc0ef          	jal	80001a6a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e38:	0004851b          	sext.w	a0,s1
    80004e3c:	79be                	ld	s3,488(sp)
    80004e3e:	7a1e                	ld	s4,480(sp)
    80004e40:	6afe                	ld	s5,472(sp)
    80004e42:	6b5e                	ld	s6,464(sp)
    80004e44:	6bbe                	ld	s7,456(sp)
    80004e46:	6c1e                	ld	s8,448(sp)
    80004e48:	7cfa                	ld	s9,440(sp)
    80004e4a:	7d5a                	ld	s10,432(sp)
    80004e4c:	bb85                	j	80004bbc <kexec+0x6e>
    80004e4e:	e1243423          	sd	s2,-504(s0)
    80004e52:	7dba                	ld	s11,424(sp)
    80004e54:	a035                	j	80004e80 <kexec+0x332>
    80004e56:	e1243423          	sd	s2,-504(s0)
    80004e5a:	7dba                	ld	s11,424(sp)
    80004e5c:	a015                	j	80004e80 <kexec+0x332>
    80004e5e:	e1243423          	sd	s2,-504(s0)
    80004e62:	7dba                	ld	s11,424(sp)
    80004e64:	a831                	j	80004e80 <kexec+0x332>
    80004e66:	e1243423          	sd	s2,-504(s0)
    80004e6a:	7dba                	ld	s11,424(sp)
    80004e6c:	a811                	j	80004e80 <kexec+0x332>
    80004e6e:	e1243423          	sd	s2,-504(s0)
    80004e72:	7dba                	ld	s11,424(sp)
    80004e74:	a031                	j	80004e80 <kexec+0x332>
  ip = 0;
    80004e76:	4a01                	li	s4,0
    80004e78:	a021                	j	80004e80 <kexec+0x332>
    80004e7a:	4a01                	li	s4,0
  if (pagetable)
    80004e7c:	a011                	j	80004e80 <kexec+0x332>
    80004e7e:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004e80:	e0843583          	ld	a1,-504(s0)
    80004e84:	855a                	mv	a0,s6
    80004e86:	be5fc0ef          	jal	80001a6a <proc_freepagetable>
  return -1;
    80004e8a:	557d                	li	a0,-1
  if (ip) {
    80004e8c:	000a1b63          	bnez	s4,80004ea2 <kexec+0x354>
    80004e90:	79be                	ld	s3,488(sp)
    80004e92:	7a1e                	ld	s4,480(sp)
    80004e94:	6afe                	ld	s5,472(sp)
    80004e96:	6b5e                	ld	s6,464(sp)
    80004e98:	6bbe                	ld	s7,456(sp)
    80004e9a:	6c1e                	ld	s8,448(sp)
    80004e9c:	7cfa                	ld	s9,440(sp)
    80004e9e:	7d5a                	ld	s10,432(sp)
    80004ea0:	bb31                	j	80004bbc <kexec+0x6e>
    80004ea2:	79be                	ld	s3,488(sp)
    80004ea4:	6afe                	ld	s5,472(sp)
    80004ea6:	6b5e                	ld	s6,464(sp)
    80004ea8:	6bbe                	ld	s7,456(sp)
    80004eaa:	6c1e                	ld	s8,448(sp)
    80004eac:	7cfa                	ld	s9,440(sp)
    80004eae:	7d5a                	ld	s10,432(sp)
    80004eb0:	b9fd                	j	80004bae <kexec+0x60>
    80004eb2:	6b5e                	ld	s6,464(sp)
    80004eb4:	b9ed                	j	80004bae <kexec+0x60>
  sz = sz1;
    80004eb6:	e0843b83          	ld	s7,-504(s0)
    80004eba:	b59d                	j	80004d20 <kexec+0x1d2>

0000000080004ebc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ebc:	7179                	addi	sp,sp,-48
    80004ebe:	f406                	sd	ra,40(sp)
    80004ec0:	f022                	sd	s0,32(sp)
    80004ec2:	ec26                	sd	s1,24(sp)
    80004ec4:	e84a                	sd	s2,16(sp)
    80004ec6:	1800                	addi	s0,sp,48
    80004ec8:	892e                	mv	s2,a1
    80004eca:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ecc:	fdc40593          	addi	a1,s0,-36
    80004ed0:	aa1fd0ef          	jal	80002970 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004ed4:	fdc42703          	lw	a4,-36(s0)
    80004ed8:	47bd                	li	a5,15
    80004eda:	02e7e963          	bltu	a5,a4,80004f0c <argfd+0x50>
    80004ede:	a07fc0ef          	jal	800018e4 <myproc>
    80004ee2:	fdc42703          	lw	a4,-36(s0)
    80004ee6:	01a70793          	addi	a5,a4,26
    80004eea:	078e                	slli	a5,a5,0x3
    80004eec:	953e                	add	a0,a0,a5
    80004eee:	611c                	ld	a5,0(a0)
    80004ef0:	c385                	beqz	a5,80004f10 <argfd+0x54>
    return -1;
  if (pfd)
    80004ef2:	00090463          	beqz	s2,80004efa <argfd+0x3e>
    *pfd = fd;
    80004ef6:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004efa:	4501                	li	a0,0
  if (pf)
    80004efc:	c091                	beqz	s1,80004f00 <argfd+0x44>
    *pf = f;
    80004efe:	e09c                	sd	a5,0(s1)
}
    80004f00:	70a2                	ld	ra,40(sp)
    80004f02:	7402                	ld	s0,32(sp)
    80004f04:	64e2                	ld	s1,24(sp)
    80004f06:	6942                	ld	s2,16(sp)
    80004f08:	6145                	addi	sp,sp,48
    80004f0a:	8082                	ret
    return -1;
    80004f0c:	557d                	li	a0,-1
    80004f0e:	bfcd                	j	80004f00 <argfd+0x44>
    80004f10:	557d                	li	a0,-1
    80004f12:	b7fd                	j	80004f00 <argfd+0x44>

0000000080004f14 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f14:	1101                	addi	sp,sp,-32
    80004f16:	ec06                	sd	ra,24(sp)
    80004f18:	e822                	sd	s0,16(sp)
    80004f1a:	e426                	sd	s1,8(sp)
    80004f1c:	1000                	addi	s0,sp,32
    80004f1e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f20:	9c5fc0ef          	jal	800018e4 <myproc>
    80004f24:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004f26:	0d050793          	addi	a5,a0,208
    80004f2a:	4501                	li	a0,0
    80004f2c:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004f2e:	6398                	ld	a4,0(a5)
    80004f30:	cb19                	beqz	a4,80004f46 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004f32:	2505                	addiw	a0,a0,1
    80004f34:	07a1                	addi	a5,a5,8
    80004f36:	fed51ce3          	bne	a0,a3,80004f2e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f3a:	557d                	li	a0,-1
}
    80004f3c:	60e2                	ld	ra,24(sp)
    80004f3e:	6442                	ld	s0,16(sp)
    80004f40:	64a2                	ld	s1,8(sp)
    80004f42:	6105                	addi	sp,sp,32
    80004f44:	8082                	ret
      p->ofile[fd] = f;
    80004f46:	01a50793          	addi	a5,a0,26
    80004f4a:	078e                	slli	a5,a5,0x3
    80004f4c:	963e                	add	a2,a2,a5
    80004f4e:	e204                	sd	s1,0(a2)
      return fd;
    80004f50:	b7f5                	j	80004f3c <fdalloc+0x28>

0000000080004f52 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004f52:	715d                	addi	sp,sp,-80
    80004f54:	e486                	sd	ra,72(sp)
    80004f56:	e0a2                	sd	s0,64(sp)
    80004f58:	fc26                	sd	s1,56(sp)
    80004f5a:	f84a                	sd	s2,48(sp)
    80004f5c:	f44e                	sd	s3,40(sp)
    80004f5e:	f052                	sd	s4,32(sp)
    80004f60:	ec56                	sd	s5,24(sp)
    80004f62:	0880                	addi	s0,sp,80
    80004f64:	892e                	mv	s2,a1
    80004f66:	89b2                	mv	s3,a2
    80004f68:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004f6a:	fb040593          	addi	a1,s0,-80
    80004f6e:	edbfe0ef          	jal	80003e48 <nameiparent>
    80004f72:	8aaa                	mv	s5,a0
    80004f74:	cd45                	beqz	a0,8000502c <create+0xda>
    return 0;

  ilock(dp);
    80004f76:	e44fe0ef          	jal	800035ba <ilock>

  if (dp->nlink == 0) {
    80004f7a:	04aa9783          	lh	a5,74(s5) # fffffffffffff04a <end+0xffffffff7ffdb51a>
    80004f7e:	cf8d                	beqz	a5,80004fb8 <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004f80:	4705                	li	a4,1
    80004f82:	04e91563          	bne	s2,a4,80004fcc <create+0x7a>
    80004f86:	6721                	lui	a4,0x8
    80004f88:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004f8a:	02e78c63          	beq	a5,a4,80004fc2 <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004f8e:	4601                	li	a2,0
    80004f90:	fb040593          	addi	a1,s0,-80
    80004f94:	8556                	mv	a0,s5
    80004f96:	c23fe0ef          	jal	80003bb8 <dirlookup>
    80004f9a:	84aa                	mv	s1,a0
    80004f9c:	e951                	bnez	a0,80005030 <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004f9e:	85ca                	mv	a1,s2
    80004fa0:	000aa503          	lw	a0,0(s5)
    80004fa4:	ca6fe0ef          	jal	8000344a <ialloc>
    80004fa8:	84aa                	mv	s1,a0
    80004faa:	0c051e63          	bnez	a0,80005086 <create+0x134>
    iunlockput(dp);
    80004fae:	8556                	mv	a0,s5
    80004fb0:	85dfe0ef          	jal	8000380c <iunlockput>
    return 0;
    80004fb4:	4481                	li	s1,0
    80004fb6:	a0a1                	j	80004ffe <create+0xac>
    iunlockput(dp);
    80004fb8:	8556                	mv	a0,s5
    80004fba:	853fe0ef          	jal	8000380c <iunlockput>
    return 0;
    80004fbe:	4481                	li	s1,0
    80004fc0:	a83d                	j	80004ffe <create+0xac>
    iunlockput(dp);
    80004fc2:	8556                	mv	a0,s5
    80004fc4:	849fe0ef          	jal	8000380c <iunlockput>
    return 0;
    80004fc8:	4481                	li	s1,0
    80004fca:	a815                	j	80004ffe <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004fcc:	4601                	li	a2,0
    80004fce:	fb040593          	addi	a1,s0,-80
    80004fd2:	8556                	mv	a0,s5
    80004fd4:	be5fe0ef          	jal	80003bb8 <dirlookup>
    80004fd8:	84aa                	mv	s1,a0
    80004fda:	c535                	beqz	a0,80005046 <create+0xf4>
    iunlockput(dp);
    80004fdc:	8556                	mv	a0,s5
    80004fde:	82ffe0ef          	jal	8000380c <iunlockput>
    ilock(ip);
    80004fe2:	8526                	mv	a0,s1
    80004fe4:	dd6fe0ef          	jal	800035ba <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fe8:	4789                	li	a5,2
    80004fea:	04f91963          	bne	s2,a5,8000503c <create+0xea>
    80004fee:	0444d783          	lhu	a5,68(s1)
    80004ff2:	37f9                	addiw	a5,a5,-2
    80004ff4:	17c2                	slli	a5,a5,0x30
    80004ff6:	93c1                	srli	a5,a5,0x30
    80004ff8:	4705                	li	a4,1
    80004ffa:	04f76163          	bltu	a4,a5,8000503c <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ffe:	8526                	mv	a0,s1
    80005000:	60a6                	ld	ra,72(sp)
    80005002:	6406                	ld	s0,64(sp)
    80005004:	74e2                	ld	s1,56(sp)
    80005006:	7942                	ld	s2,48(sp)
    80005008:	79a2                	ld	s3,40(sp)
    8000500a:	7a02                	ld	s4,32(sp)
    8000500c:	6ae2                	ld	s5,24(sp)
    8000500e:	6161                	addi	sp,sp,80
    80005010:	8082                	ret
  ip->nlink = 0;
    80005012:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    80005016:	8526                	mv	a0,s1
    80005018:	ceefe0ef          	jal	80003506 <iupdate>
  iunlockput(ip);
    8000501c:	8526                	mv	a0,s1
    8000501e:	feefe0ef          	jal	8000380c <iunlockput>
  iunlockput(dp);
    80005022:	8556                	mv	a0,s5
    80005024:	fe8fe0ef          	jal	8000380c <iunlockput>
  return 0;
    80005028:	4481                	li	s1,0
    8000502a:	bfd1                	j	80004ffe <create+0xac>
    return 0;
    8000502c:	84aa                	mv	s1,a0
    8000502e:	bfc1                	j	80004ffe <create+0xac>
    iunlockput(dp);
    80005030:	8556                	mv	a0,s5
    80005032:	fdafe0ef          	jal	8000380c <iunlockput>
    ilock(ip);
    80005036:	8526                	mv	a0,s1
    80005038:	d82fe0ef          	jal	800035ba <ilock>
    iunlockput(ip);
    8000503c:	8526                	mv	a0,s1
    8000503e:	fcefe0ef          	jal	8000380c <iunlockput>
    return 0;
    80005042:	4481                	li	s1,0
    80005044:	bf6d                	j	80004ffe <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80005046:	85ca                	mv	a1,s2
    80005048:	000aa503          	lw	a0,0(s5)
    8000504c:	bfefe0ef          	jal	8000344a <ialloc>
    80005050:	84aa                	mv	s1,a0
    80005052:	dd31                	beqz	a0,80004fae <create+0x5c>
  ilock(ip);
    80005054:	8526                	mv	a0,s1
    80005056:	d64fe0ef          	jal	800035ba <ilock>
  ip->major = major;
    8000505a:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    8000505e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005062:	4785                	li	a5,1
    80005064:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005068:	8526                	mv	a0,s1
    8000506a:	c9cfe0ef          	jal	80003506 <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    8000506e:	40d0                	lw	a2,4(s1)
    80005070:	fb040593          	addi	a1,s0,-80
    80005074:	8556                	mv	a0,s5
    80005076:	d1ffe0ef          	jal	80003d94 <dirlink>
    8000507a:	f8054ce3          	bltz	a0,80005012 <create+0xc0>
  iunlockput(dp);
    8000507e:	8556                	mv	a0,s5
    80005080:	f8cfe0ef          	jal	8000380c <iunlockput>
  return ip;
    80005084:	bfad                	j	80004ffe <create+0xac>
  ilock(ip);
    80005086:	8526                	mv	a0,s1
    80005088:	d32fe0ef          	jal	800035ba <ilock>
  ip->major = major;
    8000508c:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80005090:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005094:	4785                	li	a5,1
    80005096:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000509a:	8526                	mv	a0,s1
    8000509c:	c6afe0ef          	jal	80003506 <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050a0:	40d0                	lw	a2,4(s1)
    800050a2:	00002597          	auipc	a1,0x2
    800050a6:	66658593          	addi	a1,a1,1638 # 80007708 <etext+0x708>
    800050aa:	8526                	mv	a0,s1
    800050ac:	ce9fe0ef          	jal	80003d94 <dirlink>
    800050b0:	f60541e3          	bltz	a0,80005012 <create+0xc0>
    800050b4:	004aa603          	lw	a2,4(s5)
    800050b8:	00002597          	auipc	a1,0x2
    800050bc:	64858593          	addi	a1,a1,1608 # 80007700 <etext+0x700>
    800050c0:	8526                	mv	a0,s1
    800050c2:	cd3fe0ef          	jal	80003d94 <dirlink>
    800050c6:	f40546e3          	bltz	a0,80005012 <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    800050ca:	40d0                	lw	a2,4(s1)
    800050cc:	fb040593          	addi	a1,s0,-80
    800050d0:	8556                	mv	a0,s5
    800050d2:	cc3fe0ef          	jal	80003d94 <dirlink>
    800050d6:	f2054ee3          	bltz	a0,80005012 <create+0xc0>
    dp->nlink++; // for ".."
    800050da:	04aad783          	lhu	a5,74(s5)
    800050de:	2785                	addiw	a5,a5,1
    800050e0:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    800050e4:	8556                	mv	a0,s5
    800050e6:	c20fe0ef          	jal	80003506 <iupdate>
    800050ea:	bf51                	j	8000507e <create+0x12c>

00000000800050ec <sys_dup>:
{
    800050ec:	7179                	addi	sp,sp,-48
    800050ee:	f406                	sd	ra,40(sp)
    800050f0:	f022                	sd	s0,32(sp)
    800050f2:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800050f4:	fd840613          	addi	a2,s0,-40
    800050f8:	4581                	li	a1,0
    800050fa:	4501                	li	a0,0
    800050fc:	dc1ff0ef          	jal	80004ebc <argfd>
    return -1;
    80005100:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80005102:	02054363          	bltz	a0,80005128 <sys_dup+0x3c>
    80005106:	ec26                	sd	s1,24(sp)
    80005108:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    8000510a:	fd843903          	ld	s2,-40(s0)
    8000510e:	854a                	mv	a0,s2
    80005110:	e05ff0ef          	jal	80004f14 <fdalloc>
    80005114:	84aa                	mv	s1,a0
    return -1;
    80005116:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005118:	00054d63          	bltz	a0,80005132 <sys_dup+0x46>
  filedup(f);
    8000511c:	854a                	mv	a0,s2
    8000511e:	b4aff0ef          	jal	80004468 <filedup>
  return fd;
    80005122:	87a6                	mv	a5,s1
    80005124:	64e2                	ld	s1,24(sp)
    80005126:	6942                	ld	s2,16(sp)
}
    80005128:	853e                	mv	a0,a5
    8000512a:	70a2                	ld	ra,40(sp)
    8000512c:	7402                	ld	s0,32(sp)
    8000512e:	6145                	addi	sp,sp,48
    80005130:	8082                	ret
    80005132:	64e2                	ld	s1,24(sp)
    80005134:	6942                	ld	s2,16(sp)
    80005136:	bfcd                	j	80005128 <sys_dup+0x3c>

0000000080005138 <sys_read>:
{
    80005138:	7179                	addi	sp,sp,-48
    8000513a:	f406                	sd	ra,40(sp)
    8000513c:	f022                	sd	s0,32(sp)
    8000513e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005140:	fd840593          	addi	a1,s0,-40
    80005144:	4505                	li	a0,1
    80005146:	847fd0ef          	jal	8000298c <argaddr>
  argint(2, &n);
    8000514a:	fe440593          	addi	a1,s0,-28
    8000514e:	4509                	li	a0,2
    80005150:	821fd0ef          	jal	80002970 <argint>
  if (argfd(0, 0, &f) < 0)
    80005154:	fe840613          	addi	a2,s0,-24
    80005158:	4581                	li	a1,0
    8000515a:	4501                	li	a0,0
    8000515c:	d61ff0ef          	jal	80004ebc <argfd>
    80005160:	87aa                	mv	a5,a0
    return -1;
    80005162:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005164:	0007ca63          	bltz	a5,80005178 <sys_read+0x40>
  return fileread(f, p, n);
    80005168:	fe442603          	lw	a2,-28(s0)
    8000516c:	fd843583          	ld	a1,-40(s0)
    80005170:	fe843503          	ld	a0,-24(s0)
    80005174:	c5eff0ef          	jal	800045d2 <fileread>
}
    80005178:	70a2                	ld	ra,40(sp)
    8000517a:	7402                	ld	s0,32(sp)
    8000517c:	6145                	addi	sp,sp,48
    8000517e:	8082                	ret

0000000080005180 <sys_write>:
{
    80005180:	7179                	addi	sp,sp,-48
    80005182:	f406                	sd	ra,40(sp)
    80005184:	f022                	sd	s0,32(sp)
    80005186:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005188:	fd840593          	addi	a1,s0,-40
    8000518c:	4505                	li	a0,1
    8000518e:	ffefd0ef          	jal	8000298c <argaddr>
  argint(2, &n);
    80005192:	fe440593          	addi	a1,s0,-28
    80005196:	4509                	li	a0,2
    80005198:	fd8fd0ef          	jal	80002970 <argint>
  if (argfd(0, 0, &f) < 0)
    8000519c:	fe840613          	addi	a2,s0,-24
    800051a0:	4581                	li	a1,0
    800051a2:	4501                	li	a0,0
    800051a4:	d19ff0ef          	jal	80004ebc <argfd>
    800051a8:	87aa                	mv	a5,a0
    return -1;
    800051aa:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    800051ac:	0007ca63          	bltz	a5,800051c0 <sys_write+0x40>
  return filewrite(f, p, n);
    800051b0:	fe442603          	lw	a2,-28(s0)
    800051b4:	fd843583          	ld	a1,-40(s0)
    800051b8:	fe843503          	ld	a0,-24(s0)
    800051bc:	ce0ff0ef          	jal	8000469c <filewrite>
}
    800051c0:	70a2                	ld	ra,40(sp)
    800051c2:	7402                	ld	s0,32(sp)
    800051c4:	6145                	addi	sp,sp,48
    800051c6:	8082                	ret

00000000800051c8 <sys_close>:
{
    800051c8:	1101                	addi	sp,sp,-32
    800051ca:	ec06                	sd	ra,24(sp)
    800051cc:	e822                	sd	s0,16(sp)
    800051ce:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800051d0:	fe040613          	addi	a2,s0,-32
    800051d4:	fec40593          	addi	a1,s0,-20
    800051d8:	4501                	li	a0,0
    800051da:	ce3ff0ef          	jal	80004ebc <argfd>
    return -1;
    800051de:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800051e0:	02054063          	bltz	a0,80005200 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800051e4:	f00fc0ef          	jal	800018e4 <myproc>
    800051e8:	fec42783          	lw	a5,-20(s0)
    800051ec:	07e9                	addi	a5,a5,26
    800051ee:	078e                	slli	a5,a5,0x3
    800051f0:	953e                	add	a0,a0,a5
    800051f2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800051f6:	fe043503          	ld	a0,-32(s0)
    800051fa:	ab4ff0ef          	jal	800044ae <fileclose>
  return 0;
    800051fe:	4781                	li	a5,0
}
    80005200:	853e                	mv	a0,a5
    80005202:	60e2                	ld	ra,24(sp)
    80005204:	6442                	ld	s0,16(sp)
    80005206:	6105                	addi	sp,sp,32
    80005208:	8082                	ret

000000008000520a <sys_fstat>:
{
    8000520a:	1101                	addi	sp,sp,-32
    8000520c:	ec06                	sd	ra,24(sp)
    8000520e:	e822                	sd	s0,16(sp)
    80005210:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005212:	fe040593          	addi	a1,s0,-32
    80005216:	4505                	li	a0,1
    80005218:	f74fd0ef          	jal	8000298c <argaddr>
  if (argfd(0, 0, &f) < 0)
    8000521c:	fe840613          	addi	a2,s0,-24
    80005220:	4581                	li	a1,0
    80005222:	4501                	li	a0,0
    80005224:	c99ff0ef          	jal	80004ebc <argfd>
    80005228:	87aa                	mv	a5,a0
    return -1;
    8000522a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    8000522c:	0007c863          	bltz	a5,8000523c <sys_fstat+0x32>
  return filestat(f, st);
    80005230:	fe043583          	ld	a1,-32(s0)
    80005234:	fe843503          	ld	a0,-24(s0)
    80005238:	b38ff0ef          	jal	80004570 <filestat>
}
    8000523c:	60e2                	ld	ra,24(sp)
    8000523e:	6442                	ld	s0,16(sp)
    80005240:	6105                	addi	sp,sp,32
    80005242:	8082                	ret

0000000080005244 <sys_link>:
{
    80005244:	7169                	addi	sp,sp,-304
    80005246:	f606                	sd	ra,296(sp)
    80005248:	f222                	sd	s0,288(sp)
    8000524a:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000524c:	08000613          	li	a2,128
    80005250:	ed040593          	addi	a1,s0,-304
    80005254:	4501                	li	a0,0
    80005256:	f52fd0ef          	jal	800029a8 <argstr>
    return -1;
    8000525a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000525c:	10054163          	bltz	a0,8000535e <sys_link+0x11a>
    80005260:	08000613          	li	a2,128
    80005264:	f5040593          	addi	a1,s0,-176
    80005268:	4505                	li	a0,1
    8000526a:	f3efd0ef          	jal	800029a8 <argstr>
    return -1;
    8000526e:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005270:	0e054763          	bltz	a0,8000535e <sys_link+0x11a>
    80005274:	ee26                	sd	s1,280(sp)
  begin_op();
    80005276:	d8dfe0ef          	jal	80004002 <begin_op>
  if ((ip = namei(old)) == 0) {
    8000527a:	ed040513          	addi	a0,s0,-304
    8000527e:	bb1fe0ef          	jal	80003e2e <namei>
    80005282:	84aa                	mv	s1,a0
    80005284:	cd35                	beqz	a0,80005300 <sys_link+0xbc>
  ilock(ip);
    80005286:	b34fe0ef          	jal	800035ba <ilock>
  if (ip->type == T_DIR) {
    8000528a:	04449703          	lh	a4,68(s1)
    8000528e:	4785                	li	a5,1
    80005290:	06f70d63          	beq	a4,a5,8000530a <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005294:	04a49783          	lh	a5,74(s1)
    80005298:	6721                	lui	a4,0x8
    8000529a:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    8000529c:	06e78f63          	beq	a5,a4,8000531a <sys_link+0xd6>
    800052a0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800052a2:	2785                	addiw	a5,a5,1
    800052a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052a8:	8526                	mv	a0,s1
    800052aa:	a5cfe0ef          	jal	80003506 <iupdate>
  iunlock(ip);
    800052ae:	8526                	mv	a0,s1
    800052b0:	bb8fe0ef          	jal	80003668 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800052b4:	fd040593          	addi	a1,s0,-48
    800052b8:	f5040513          	addi	a0,s0,-176
    800052bc:	b8dfe0ef          	jal	80003e48 <nameiparent>
    800052c0:	892a                	mv	s2,a0
    800052c2:	c93d                	beqz	a0,80005338 <sys_link+0xf4>
  ilock(dp);
    800052c4:	af6fe0ef          	jal	800035ba <ilock>
  if (dp->nlink == 0) {
    800052c8:	04a91783          	lh	a5,74(s2)
    800052cc:	cfb9                	beqz	a5,8000532a <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800052ce:	00092703          	lw	a4,0(s2)
    800052d2:	409c                	lw	a5,0(s1)
    800052d4:	04f71f63          	bne	a4,a5,80005332 <sys_link+0xee>
    800052d8:	40d0                	lw	a2,4(s1)
    800052da:	fd040593          	addi	a1,s0,-48
    800052de:	854a                	mv	a0,s2
    800052e0:	ab5fe0ef          	jal	80003d94 <dirlink>
    800052e4:	04054763          	bltz	a0,80005332 <sys_link+0xee>
  iunlockput(dp);
    800052e8:	854a                	mv	a0,s2
    800052ea:	d22fe0ef          	jal	8000380c <iunlockput>
  iput(ip);
    800052ee:	8526                	mv	a0,s1
    800052f0:	c4cfe0ef          	jal	8000373c <iput>
  end_op();
    800052f4:	d95fe0ef          	jal	80004088 <end_op>
  return 0;
    800052f8:	4781                	li	a5,0
    800052fa:	64f2                	ld	s1,280(sp)
    800052fc:	6952                	ld	s2,272(sp)
    800052fe:	a085                	j	8000535e <sys_link+0x11a>
    end_op();
    80005300:	d89fe0ef          	jal	80004088 <end_op>
    return -1;
    80005304:	57fd                	li	a5,-1
    80005306:	64f2                	ld	s1,280(sp)
    80005308:	a899                	j	8000535e <sys_link+0x11a>
    iunlockput(ip);
    8000530a:	8526                	mv	a0,s1
    8000530c:	d00fe0ef          	jal	8000380c <iunlockput>
    end_op();
    80005310:	d79fe0ef          	jal	80004088 <end_op>
    return -1;
    80005314:	57fd                	li	a5,-1
    80005316:	64f2                	ld	s1,280(sp)
    80005318:	a099                	j	8000535e <sys_link+0x11a>
    iunlockput(ip);
    8000531a:	8526                	mv	a0,s1
    8000531c:	cf0fe0ef          	jal	8000380c <iunlockput>
    end_op();
    80005320:	d69fe0ef          	jal	80004088 <end_op>
    return -1;
    80005324:	57fd                	li	a5,-1
    80005326:	64f2                	ld	s1,280(sp)
    80005328:	a81d                	j	8000535e <sys_link+0x11a>
    iunlockput(dp);
    8000532a:	854a                	mv	a0,s2
    8000532c:	ce0fe0ef          	jal	8000380c <iunlockput>
    goto bad;
    80005330:	a021                	j	80005338 <sys_link+0xf4>
    iunlockput(dp);
    80005332:	854a                	mv	a0,s2
    80005334:	cd8fe0ef          	jal	8000380c <iunlockput>
  ilock(ip);
    80005338:	8526                	mv	a0,s1
    8000533a:	a80fe0ef          	jal	800035ba <ilock>
  ip->nlink--;
    8000533e:	04a4d783          	lhu	a5,74(s1)
    80005342:	37fd                	addiw	a5,a5,-1
    80005344:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005348:	8526                	mv	a0,s1
    8000534a:	9bcfe0ef          	jal	80003506 <iupdate>
  iunlockput(ip);
    8000534e:	8526                	mv	a0,s1
    80005350:	cbcfe0ef          	jal	8000380c <iunlockput>
  end_op();
    80005354:	d35fe0ef          	jal	80004088 <end_op>
  return -1;
    80005358:	57fd                	li	a5,-1
    8000535a:	64f2                	ld	s1,280(sp)
    8000535c:	6952                	ld	s2,272(sp)
}
    8000535e:	853e                	mv	a0,a5
    80005360:	70b2                	ld	ra,296(sp)
    80005362:	7412                	ld	s0,288(sp)
    80005364:	6155                	addi	sp,sp,304
    80005366:	8082                	ret

0000000080005368 <sys_unlink>:
{
    80005368:	7151                	addi	sp,sp,-240
    8000536a:	f586                	sd	ra,232(sp)
    8000536c:	f1a2                	sd	s0,224(sp)
    8000536e:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005370:	08000613          	li	a2,128
    80005374:	f3040593          	addi	a1,s0,-208
    80005378:	4501                	li	a0,0
    8000537a:	e2efd0ef          	jal	800029a8 <argstr>
    8000537e:	16054063          	bltz	a0,800054de <sys_unlink+0x176>
    80005382:	eda6                	sd	s1,216(sp)
  begin_op();
    80005384:	c7ffe0ef          	jal	80004002 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005388:	fb040593          	addi	a1,s0,-80
    8000538c:	f3040513          	addi	a0,s0,-208
    80005390:	ab9fe0ef          	jal	80003e48 <nameiparent>
    80005394:	84aa                	mv	s1,a0
    80005396:	c945                	beqz	a0,80005446 <sys_unlink+0xde>
  ilock(dp);
    80005398:	a22fe0ef          	jal	800035ba <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000539c:	00002597          	auipc	a1,0x2
    800053a0:	36c58593          	addi	a1,a1,876 # 80007708 <etext+0x708>
    800053a4:	fb040513          	addi	a0,s0,-80
    800053a8:	ffafe0ef          	jal	80003ba2 <namecmp>
    800053ac:	10050e63          	beqz	a0,800054c8 <sys_unlink+0x160>
    800053b0:	00002597          	auipc	a1,0x2
    800053b4:	35058593          	addi	a1,a1,848 # 80007700 <etext+0x700>
    800053b8:	fb040513          	addi	a0,s0,-80
    800053bc:	fe6fe0ef          	jal	80003ba2 <namecmp>
    800053c0:	10050463          	beqz	a0,800054c8 <sys_unlink+0x160>
    800053c4:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800053c6:	f2c40613          	addi	a2,s0,-212
    800053ca:	fb040593          	addi	a1,s0,-80
    800053ce:	8526                	mv	a0,s1
    800053d0:	fe8fe0ef          	jal	80003bb8 <dirlookup>
    800053d4:	892a                	mv	s2,a0
    800053d6:	0e050863          	beqz	a0,800054c6 <sys_unlink+0x15e>
  ilock(ip);
    800053da:	9e0fe0ef          	jal	800035ba <ilock>
  if (ip->nlink < 1)
    800053de:	04a91783          	lh	a5,74(s2)
    800053e2:	06f05763          	blez	a5,80005450 <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800053e6:	04491703          	lh	a4,68(s2)
    800053ea:	4785                	li	a5,1
    800053ec:	06f70963          	beq	a4,a5,8000545e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800053f0:	4641                	li	a2,16
    800053f2:	4581                	li	a1,0
    800053f4:	fc040513          	addi	a0,s0,-64
    800053f8:	89ffb0ef          	jal	80000c96 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800053fc:	4741                	li	a4,16
    800053fe:	f2c42683          	lw	a3,-212(s0)
    80005402:	fc040613          	addi	a2,s0,-64
    80005406:	4581                	li	a1,0
    80005408:	8526                	mv	a0,s1
    8000540a:	e84fe0ef          	jal	80003a8e <writei>
    8000540e:	47c1                	li	a5,16
    80005410:	08f51b63          	bne	a0,a5,800054a6 <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    80005414:	04491703          	lh	a4,68(s2)
    80005418:	4785                	li	a5,1
    8000541a:	08f70d63          	beq	a4,a5,800054b4 <sys_unlink+0x14c>
  iunlockput(dp);
    8000541e:	8526                	mv	a0,s1
    80005420:	becfe0ef          	jal	8000380c <iunlockput>
  ip->nlink--;
    80005424:	04a95783          	lhu	a5,74(s2)
    80005428:	37fd                	addiw	a5,a5,-1
    8000542a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000542e:	854a                	mv	a0,s2
    80005430:	8d6fe0ef          	jal	80003506 <iupdate>
  iunlockput(ip);
    80005434:	854a                	mv	a0,s2
    80005436:	bd6fe0ef          	jal	8000380c <iunlockput>
  end_op();
    8000543a:	c4ffe0ef          	jal	80004088 <end_op>
  return 0;
    8000543e:	4501                	li	a0,0
    80005440:	64ee                	ld	s1,216(sp)
    80005442:	694e                	ld	s2,208(sp)
    80005444:	a849                	j	800054d6 <sys_unlink+0x16e>
    end_op();
    80005446:	c43fe0ef          	jal	80004088 <end_op>
    return -1;
    8000544a:	557d                	li	a0,-1
    8000544c:	64ee                	ld	s1,216(sp)
    8000544e:	a061                	j	800054d6 <sys_unlink+0x16e>
    80005450:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005452:	00002517          	auipc	a0,0x2
    80005456:	2be50513          	addi	a0,a0,702 # 80007710 <etext+0x710>
    8000545a:	b96fb0ef          	jal	800007f0 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000545e:	04c92703          	lw	a4,76(s2)
    80005462:	02000793          	li	a5,32
    80005466:	f8e7f5e3          	bgeu	a5,a4,800053f0 <sys_unlink+0x88>
    8000546a:	e5ce                	sd	s3,200(sp)
    8000546c:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005470:	4741                	li	a4,16
    80005472:	86ce                	mv	a3,s3
    80005474:	f1840613          	addi	a2,s0,-232
    80005478:	4581                	li	a1,0
    8000547a:	854a                	mv	a0,s2
    8000547c:	d16fe0ef          	jal	80003992 <readi>
    80005480:	47c1                	li	a5,16
    80005482:	00f51c63          	bne	a0,a5,8000549a <sys_unlink+0x132>
    if (de.inum != 0)
    80005486:	f1845783          	lhu	a5,-232(s0)
    8000548a:	efa1                	bnez	a5,800054e2 <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000548c:	29c1                	addiw	s3,s3,16
    8000548e:	04c92783          	lw	a5,76(s2)
    80005492:	fcf9efe3          	bltu	s3,a5,80005470 <sys_unlink+0x108>
    80005496:	69ae                	ld	s3,200(sp)
    80005498:	bfa1                	j	800053f0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000549a:	00002517          	auipc	a0,0x2
    8000549e:	28e50513          	addi	a0,a0,654 # 80007728 <etext+0x728>
    800054a2:	b4efb0ef          	jal	800007f0 <panic>
    800054a6:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800054a8:	00002517          	auipc	a0,0x2
    800054ac:	29850513          	addi	a0,a0,664 # 80007740 <etext+0x740>
    800054b0:	b40fb0ef          	jal	800007f0 <panic>
    dp->nlink--;
    800054b4:	04a4d783          	lhu	a5,74(s1)
    800054b8:	37fd                	addiw	a5,a5,-1
    800054ba:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054be:	8526                	mv	a0,s1
    800054c0:	846fe0ef          	jal	80003506 <iupdate>
    800054c4:	bfa9                	j	8000541e <sys_unlink+0xb6>
    800054c6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800054c8:	8526                	mv	a0,s1
    800054ca:	b42fe0ef          	jal	8000380c <iunlockput>
  end_op();
    800054ce:	bbbfe0ef          	jal	80004088 <end_op>
  return -1;
    800054d2:	557d                	li	a0,-1
    800054d4:	64ee                	ld	s1,216(sp)
}
    800054d6:	70ae                	ld	ra,232(sp)
    800054d8:	740e                	ld	s0,224(sp)
    800054da:	616d                	addi	sp,sp,240
    800054dc:	8082                	ret
    return -1;
    800054de:	557d                	li	a0,-1
    800054e0:	bfdd                	j	800054d6 <sys_unlink+0x16e>
    iunlockput(ip);
    800054e2:	854a                	mv	a0,s2
    800054e4:	b28fe0ef          	jal	8000380c <iunlockput>
    goto bad;
    800054e8:	694e                	ld	s2,208(sp)
    800054ea:	69ae                	ld	s3,200(sp)
    800054ec:	bff1                	j	800054c8 <sys_unlink+0x160>

00000000800054ee <sys_open>:

uint64
sys_open(void)
{
    800054ee:	7131                	addi	sp,sp,-192
    800054f0:	fd06                	sd	ra,184(sp)
    800054f2:	f922                	sd	s0,176(sp)
    800054f4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800054f6:	f4c40593          	addi	a1,s0,-180
    800054fa:	4505                	li	a0,1
    800054fc:	c74fd0ef          	jal	80002970 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005500:	08000613          	li	a2,128
    80005504:	f5040593          	addi	a1,s0,-176
    80005508:	4501                	li	a0,0
    8000550a:	c9efd0ef          	jal	800029a8 <argstr>
    8000550e:	87aa                	mv	a5,a0
    return -1;
    80005510:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005512:	0a07c263          	bltz	a5,800055b6 <sys_open+0xc8>
    80005516:	f526                	sd	s1,168(sp)

  begin_op();
    80005518:	aebfe0ef          	jal	80004002 <begin_op>

  if (omode & O_CREATE) {
    8000551c:	f4c42783          	lw	a5,-180(s0)
    80005520:	2007f793          	andi	a5,a5,512
    80005524:	c3d5                	beqz	a5,800055c8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005526:	4681                	li	a3,0
    80005528:	4601                	li	a2,0
    8000552a:	4589                	li	a1,2
    8000552c:	f5040513          	addi	a0,s0,-176
    80005530:	a23ff0ef          	jal	80004f52 <create>
    80005534:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005536:	c541                	beqz	a0,800055be <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005538:	04449703          	lh	a4,68(s1)
    8000553c:	478d                	li	a5,3
    8000553e:	00f71763          	bne	a4,a5,8000554c <sys_open+0x5e>
    80005542:	0464d703          	lhu	a4,70(s1)
    80005546:	47a5                	li	a5,9
    80005548:	0ae7ed63          	bltu	a5,a4,80005602 <sys_open+0x114>
    8000554c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000554e:	ebdfe0ef          	jal	8000440a <filealloc>
    80005552:	892a                	mv	s2,a0
    80005554:	c179                	beqz	a0,8000561a <sys_open+0x12c>
    80005556:	ed4e                	sd	s3,152(sp)
    80005558:	9bdff0ef          	jal	80004f14 <fdalloc>
    8000555c:	89aa                	mv	s3,a0
    8000555e:	0a054a63          	bltz	a0,80005612 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005562:	04449703          	lh	a4,68(s1)
    80005566:	478d                	li	a5,3
    80005568:	0cf70263          	beq	a4,a5,8000562c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000556c:	4789                	li	a5,2
    8000556e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005572:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005576:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000557a:	f4c42783          	lw	a5,-180(s0)
    8000557e:	0017c713          	xori	a4,a5,1
    80005582:	8b05                	andi	a4,a4,1
    80005584:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005588:	0037f713          	andi	a4,a5,3
    8000558c:	00e03733          	snez	a4,a4
    80005590:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005594:	4007f793          	andi	a5,a5,1024
    80005598:	c791                	beqz	a5,800055a4 <sys_open+0xb6>
    8000559a:	04449703          	lh	a4,68(s1)
    8000559e:	4789                	li	a5,2
    800055a0:	08f70d63          	beq	a4,a5,8000563a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800055a4:	8526                	mv	a0,s1
    800055a6:	8c2fe0ef          	jal	80003668 <iunlock>
  end_op();
    800055aa:	adffe0ef          	jal	80004088 <end_op>

  return fd;
    800055ae:	854e                	mv	a0,s3
    800055b0:	74aa                	ld	s1,168(sp)
    800055b2:	790a                	ld	s2,160(sp)
    800055b4:	69ea                	ld	s3,152(sp)
}
    800055b6:	70ea                	ld	ra,184(sp)
    800055b8:	744a                	ld	s0,176(sp)
    800055ba:	6129                	addi	sp,sp,192
    800055bc:	8082                	ret
      end_op();
    800055be:	acbfe0ef          	jal	80004088 <end_op>
      return -1;
    800055c2:	557d                	li	a0,-1
    800055c4:	74aa                	ld	s1,168(sp)
    800055c6:	bfc5                	j	800055b6 <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    800055c8:	f5040513          	addi	a0,s0,-176
    800055cc:	863fe0ef          	jal	80003e2e <namei>
    800055d0:	84aa                	mv	s1,a0
    800055d2:	c11d                	beqz	a0,800055f8 <sys_open+0x10a>
    ilock(ip);
    800055d4:	fe7fd0ef          	jal	800035ba <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800055d8:	04449703          	lh	a4,68(s1)
    800055dc:	4785                	li	a5,1
    800055de:	f4f71de3          	bne	a4,a5,80005538 <sys_open+0x4a>
    800055e2:	f4c42783          	lw	a5,-180(s0)
    800055e6:	d3bd                	beqz	a5,8000554c <sys_open+0x5e>
      iunlockput(ip);
    800055e8:	8526                	mv	a0,s1
    800055ea:	a22fe0ef          	jal	8000380c <iunlockput>
      end_op();
    800055ee:	a9bfe0ef          	jal	80004088 <end_op>
      return -1;
    800055f2:	557d                	li	a0,-1
    800055f4:	74aa                	ld	s1,168(sp)
    800055f6:	b7c1                	j	800055b6 <sys_open+0xc8>
      end_op();
    800055f8:	a91fe0ef          	jal	80004088 <end_op>
      return -1;
    800055fc:	557d                	li	a0,-1
    800055fe:	74aa                	ld	s1,168(sp)
    80005600:	bf5d                	j	800055b6 <sys_open+0xc8>
    iunlockput(ip);
    80005602:	8526                	mv	a0,s1
    80005604:	a08fe0ef          	jal	8000380c <iunlockput>
    end_op();
    80005608:	a81fe0ef          	jal	80004088 <end_op>
    return -1;
    8000560c:	557d                	li	a0,-1
    8000560e:	74aa                	ld	s1,168(sp)
    80005610:	b75d                	j	800055b6 <sys_open+0xc8>
      fileclose(f);
    80005612:	854a                	mv	a0,s2
    80005614:	e9bfe0ef          	jal	800044ae <fileclose>
    80005618:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000561a:	8526                	mv	a0,s1
    8000561c:	9f0fe0ef          	jal	8000380c <iunlockput>
    end_op();
    80005620:	a69fe0ef          	jal	80004088 <end_op>
    return -1;
    80005624:	557d                	li	a0,-1
    80005626:	74aa                	ld	s1,168(sp)
    80005628:	790a                	ld	s2,160(sp)
    8000562a:	b771                	j	800055b6 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000562c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005630:	04649783          	lh	a5,70(s1)
    80005634:	02f91223          	sh	a5,36(s2)
    80005638:	bf3d                	j	80005576 <sys_open+0x88>
    itrunc(ip);
    8000563a:	8526                	mv	a0,s1
    8000563c:	86cfe0ef          	jal	800036a8 <itrunc>
    80005640:	b795                	j	800055a4 <sys_open+0xb6>

0000000080005642 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005642:	7175                	addi	sp,sp,-144
    80005644:	e506                	sd	ra,136(sp)
    80005646:	e122                	sd	s0,128(sp)
    80005648:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000564a:	9b9fe0ef          	jal	80004002 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    8000564e:	08000613          	li	a2,128
    80005652:	f7040593          	addi	a1,s0,-144
    80005656:	4501                	li	a0,0
    80005658:	b50fd0ef          	jal	800029a8 <argstr>
    8000565c:	02054363          	bltz	a0,80005682 <sys_mkdir+0x40>
    80005660:	4681                	li	a3,0
    80005662:	4601                	li	a2,0
    80005664:	4585                	li	a1,1
    80005666:	f7040513          	addi	a0,s0,-144
    8000566a:	8e9ff0ef          	jal	80004f52 <create>
    8000566e:	c911                	beqz	a0,80005682 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005670:	99cfe0ef          	jal	8000380c <iunlockput>
  end_op();
    80005674:	a15fe0ef          	jal	80004088 <end_op>
  return 0;
    80005678:	4501                	li	a0,0
}
    8000567a:	60aa                	ld	ra,136(sp)
    8000567c:	640a                	ld	s0,128(sp)
    8000567e:	6149                	addi	sp,sp,144
    80005680:	8082                	ret
    end_op();
    80005682:	a07fe0ef          	jal	80004088 <end_op>
    return -1;
    80005686:	557d                	li	a0,-1
    80005688:	bfcd                	j	8000567a <sys_mkdir+0x38>

000000008000568a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000568a:	7135                	addi	sp,sp,-160
    8000568c:	ed06                	sd	ra,152(sp)
    8000568e:	e922                	sd	s0,144(sp)
    80005690:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005692:	971fe0ef          	jal	80004002 <begin_op>
  argint(1, &major);
    80005696:	f6c40593          	addi	a1,s0,-148
    8000569a:	4505                	li	a0,1
    8000569c:	ad4fd0ef          	jal	80002970 <argint>
  argint(2, &minor);
    800056a0:	f6840593          	addi	a1,s0,-152
    800056a4:	4509                	li	a0,2
    800056a6:	acafd0ef          	jal	80002970 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800056aa:	08000613          	li	a2,128
    800056ae:	f7040593          	addi	a1,s0,-144
    800056b2:	4501                	li	a0,0
    800056b4:	af4fd0ef          	jal	800029a8 <argstr>
    800056b8:	02054563          	bltz	a0,800056e2 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800056bc:	f6841683          	lh	a3,-152(s0)
    800056c0:	f6c41603          	lh	a2,-148(s0)
    800056c4:	458d                	li	a1,3
    800056c6:	f7040513          	addi	a0,s0,-144
    800056ca:	889ff0ef          	jal	80004f52 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800056ce:	c911                	beqz	a0,800056e2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056d0:	93cfe0ef          	jal	8000380c <iunlockput>
  end_op();
    800056d4:	9b5fe0ef          	jal	80004088 <end_op>
  return 0;
    800056d8:	4501                	li	a0,0
}
    800056da:	60ea                	ld	ra,152(sp)
    800056dc:	644a                	ld	s0,144(sp)
    800056de:	610d                	addi	sp,sp,160
    800056e0:	8082                	ret
    end_op();
    800056e2:	9a7fe0ef          	jal	80004088 <end_op>
    return -1;
    800056e6:	557d                	li	a0,-1
    800056e8:	bfcd                	j	800056da <sys_mknod+0x50>

00000000800056ea <sys_chdir>:

uint64
sys_chdir(void)
{
    800056ea:	7135                	addi	sp,sp,-160
    800056ec:	ed06                	sd	ra,152(sp)
    800056ee:	e922                	sd	s0,144(sp)
    800056f0:	e14a                	sd	s2,128(sp)
    800056f2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800056f4:	9f0fc0ef          	jal	800018e4 <myproc>
    800056f8:	892a                	mv	s2,a0

  begin_op();
    800056fa:	909fe0ef          	jal	80004002 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800056fe:	08000613          	li	a2,128
    80005702:	f6040593          	addi	a1,s0,-160
    80005706:	4501                	li	a0,0
    80005708:	aa0fd0ef          	jal	800029a8 <argstr>
    8000570c:	04054363          	bltz	a0,80005752 <sys_chdir+0x68>
    80005710:	e526                	sd	s1,136(sp)
    80005712:	f6040513          	addi	a0,s0,-160
    80005716:	f18fe0ef          	jal	80003e2e <namei>
    8000571a:	84aa                	mv	s1,a0
    8000571c:	c915                	beqz	a0,80005750 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000571e:	e9dfd0ef          	jal	800035ba <ilock>
  if (ip->type != T_DIR) {
    80005722:	04449703          	lh	a4,68(s1)
    80005726:	4785                	li	a5,1
    80005728:	02f71963          	bne	a4,a5,8000575a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000572c:	8526                	mv	a0,s1
    8000572e:	f3bfd0ef          	jal	80003668 <iunlock>
  iput(p->cwd);
    80005732:	15093503          	ld	a0,336(s2)
    80005736:	806fe0ef          	jal	8000373c <iput>
  end_op();
    8000573a:	94ffe0ef          	jal	80004088 <end_op>
  p->cwd = ip;
    8000573e:	14993823          	sd	s1,336(s2)
  return 0;
    80005742:	4501                	li	a0,0
    80005744:	64aa                	ld	s1,136(sp)
}
    80005746:	60ea                	ld	ra,152(sp)
    80005748:	644a                	ld	s0,144(sp)
    8000574a:	690a                	ld	s2,128(sp)
    8000574c:	610d                	addi	sp,sp,160
    8000574e:	8082                	ret
    80005750:	64aa                	ld	s1,136(sp)
    end_op();
    80005752:	937fe0ef          	jal	80004088 <end_op>
    return -1;
    80005756:	557d                	li	a0,-1
    80005758:	b7fd                	j	80005746 <sys_chdir+0x5c>
    iunlockput(ip);
    8000575a:	8526                	mv	a0,s1
    8000575c:	8b0fe0ef          	jal	8000380c <iunlockput>
    end_op();
    80005760:	929fe0ef          	jal	80004088 <end_op>
    return -1;
    80005764:	557d                	li	a0,-1
    80005766:	64aa                	ld	s1,136(sp)
    80005768:	bff9                	j	80005746 <sys_chdir+0x5c>

000000008000576a <sys_exec>:

uint64
sys_exec(void)
{
    8000576a:	7121                	addi	sp,sp,-448
    8000576c:	ff06                	sd	ra,440(sp)
    8000576e:	fb22                	sd	s0,432(sp)
    80005770:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005772:	e4840593          	addi	a1,s0,-440
    80005776:	4505                	li	a0,1
    80005778:	a14fd0ef          	jal	8000298c <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000577c:	08000613          	li	a2,128
    80005780:	f5040593          	addi	a1,s0,-176
    80005784:	4501                	li	a0,0
    80005786:	a22fd0ef          	jal	800029a8 <argstr>
    8000578a:	87aa                	mv	a5,a0
    return -1;
    8000578c:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    8000578e:	0c07c463          	bltz	a5,80005856 <sys_exec+0xec>
    80005792:	f726                	sd	s1,424(sp)
    80005794:	f34a                	sd	s2,416(sp)
    80005796:	ef4e                	sd	s3,408(sp)
    80005798:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000579a:	10000613          	li	a2,256
    8000579e:	4581                	li	a1,0
    800057a0:	e5040513          	addi	a0,s0,-432
    800057a4:	cf2fb0ef          	jal	80000c96 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800057a8:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800057ac:	89a6                	mv	s3,s1
    800057ae:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    800057b0:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800057b4:	00391513          	slli	a0,s2,0x3
    800057b8:	e4040593          	addi	a1,s0,-448
    800057bc:	e4843783          	ld	a5,-440(s0)
    800057c0:	953e                	add	a0,a0,a5
    800057c2:	922fd0ef          	jal	800028e4 <fetchaddr>
    800057c6:	02054663          	bltz	a0,800057f2 <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    800057ca:	e4043783          	ld	a5,-448(s0)
    800057ce:	c3a9                	beqz	a5,80005810 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800057d0:	afafb0ef          	jal	80000aca <kalloc>
    800057d4:	85aa                	mv	a1,a0
    800057d6:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800057da:	cd01                	beqz	a0,800057f2 <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057dc:	6605                	lui	a2,0x1
    800057de:	e4043503          	ld	a0,-448(s0)
    800057e2:	94cfd0ef          	jal	8000292e <fetchstr>
    800057e6:	00054663          	bltz	a0,800057f2 <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    800057ea:	0905                	addi	s2,s2,1
    800057ec:	09a1                	addi	s3,s3,8
    800057ee:	fd4913e3          	bne	s2,s4,800057b4 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057f2:	f5040913          	addi	s2,s0,-176
    800057f6:	6088                	ld	a0,0(s1)
    800057f8:	c931                	beqz	a0,8000584c <sys_exec+0xe2>
    kfree(argv[i]);
    800057fa:	9eefb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057fe:	04a1                	addi	s1,s1,8
    80005800:	ff249be3          	bne	s1,s2,800057f6 <sys_exec+0x8c>
  return -1;
    80005804:	557d                	li	a0,-1
    80005806:	74ba                	ld	s1,424(sp)
    80005808:	791a                	ld	s2,416(sp)
    8000580a:	69fa                	ld	s3,408(sp)
    8000580c:	6a5a                	ld	s4,400(sp)
    8000580e:	a0a1                	j	80005856 <sys_exec+0xec>
      argv[i] = 0;
    80005810:	0009079b          	sext.w	a5,s2
    80005814:	078e                	slli	a5,a5,0x3
    80005816:	fd078793          	addi	a5,a5,-48
    8000581a:	97a2                	add	a5,a5,s0
    8000581c:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005820:	e5040593          	addi	a1,s0,-432
    80005824:	f5040513          	addi	a0,s0,-176
    80005828:	b26ff0ef          	jal	80004b4e <kexec>
    8000582c:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000582e:	f5040993          	addi	s3,s0,-176
    80005832:	6088                	ld	a0,0(s1)
    80005834:	c511                	beqz	a0,80005840 <sys_exec+0xd6>
    kfree(argv[i]);
    80005836:	9b2fb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000583a:	04a1                	addi	s1,s1,8
    8000583c:	ff349be3          	bne	s1,s3,80005832 <sys_exec+0xc8>
  return ret;
    80005840:	854a                	mv	a0,s2
    80005842:	74ba                	ld	s1,424(sp)
    80005844:	791a                	ld	s2,416(sp)
    80005846:	69fa                	ld	s3,408(sp)
    80005848:	6a5a                	ld	s4,400(sp)
    8000584a:	a031                	j	80005856 <sys_exec+0xec>
  return -1;
    8000584c:	557d                	li	a0,-1
    8000584e:	74ba                	ld	s1,424(sp)
    80005850:	791a                	ld	s2,416(sp)
    80005852:	69fa                	ld	s3,408(sp)
    80005854:	6a5a                	ld	s4,400(sp)
}
    80005856:	70fa                	ld	ra,440(sp)
    80005858:	745a                	ld	s0,432(sp)
    8000585a:	6139                	addi	sp,sp,448
    8000585c:	8082                	ret

000000008000585e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000585e:	7139                	addi	sp,sp,-64
    80005860:	fc06                	sd	ra,56(sp)
    80005862:	f822                	sd	s0,48(sp)
    80005864:	f426                	sd	s1,40(sp)
    80005866:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005868:	87cfc0ef          	jal	800018e4 <myproc>
    8000586c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000586e:	fd840593          	addi	a1,s0,-40
    80005872:	4501                	li	a0,0
    80005874:	918fd0ef          	jal	8000298c <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005878:	fc840593          	addi	a1,s0,-56
    8000587c:	fd040513          	addi	a0,s0,-48
    80005880:	f9ffe0ef          	jal	8000481e <pipealloc>
    return -1;
    80005884:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005886:	0a054663          	bltz	a0,80005932 <sys_pipe+0xd4>
  fd0 = -1;
    8000588a:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000588e:	fd043503          	ld	a0,-48(s0)
    80005892:	e82ff0ef          	jal	80004f14 <fdalloc>
    80005896:	fca42223          	sw	a0,-60(s0)
    8000589a:	08054363          	bltz	a0,80005920 <sys_pipe+0xc2>
    8000589e:	fc843503          	ld	a0,-56(s0)
    800058a2:	e72ff0ef          	jal	80004f14 <fdalloc>
    800058a6:	fca42023          	sw	a0,-64(s0)
    800058aa:	06054263          	bltz	a0,8000590e <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800058ae:	4711                	li	a4,4
    800058b0:	fc440693          	addi	a3,s0,-60
    800058b4:	fd843603          	ld	a2,-40(s0)
    800058b8:	64ac                	ld	a1,72(s1)
    800058ba:	68a8                	ld	a0,80(s1)
    800058bc:	c5ffb0ef          	jal	8000151a <copyout>
    800058c0:	00054f63          	bltz	a0,800058de <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800058c4:	4711                	li	a4,4
    800058c6:	fc040693          	addi	a3,s0,-64
    800058ca:	fd843603          	ld	a2,-40(s0)
    800058ce:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800058d0:	64ac                	ld	a1,72(s1)
    800058d2:	68a8                	ld	a0,80(s1)
    800058d4:	c47fb0ef          	jal	8000151a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800058d8:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800058da:	04055c63          	bgez	a0,80005932 <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    800058de:	fc442783          	lw	a5,-60(s0)
    800058e2:	07e9                	addi	a5,a5,26
    800058e4:	078e                	slli	a5,a5,0x3
    800058e6:	97a6                	add	a5,a5,s1
    800058e8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800058ec:	fc042783          	lw	a5,-64(s0)
    800058f0:	07e9                	addi	a5,a5,26
    800058f2:	078e                	slli	a5,a5,0x3
    800058f4:	94be                	add	s1,s1,a5
    800058f6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800058fa:	fd043503          	ld	a0,-48(s0)
    800058fe:	bb1fe0ef          	jal	800044ae <fileclose>
    fileclose(wf);
    80005902:	fc843503          	ld	a0,-56(s0)
    80005906:	ba9fe0ef          	jal	800044ae <fileclose>
    return -1;
    8000590a:	57fd                	li	a5,-1
    8000590c:	a01d                	j	80005932 <sys_pipe+0xd4>
    if (fd0 >= 0)
    8000590e:	fc442783          	lw	a5,-60(s0)
    80005912:	0007c763          	bltz	a5,80005920 <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    80005916:	07e9                	addi	a5,a5,26
    80005918:	078e                	slli	a5,a5,0x3
    8000591a:	97a6                	add	a5,a5,s1
    8000591c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005920:	fd043503          	ld	a0,-48(s0)
    80005924:	b8bfe0ef          	jal	800044ae <fileclose>
    fileclose(wf);
    80005928:	fc843503          	ld	a0,-56(s0)
    8000592c:	b83fe0ef          	jal	800044ae <fileclose>
    return -1;
    80005930:	57fd                	li	a5,-1
}
    80005932:	853e                	mv	a0,a5
    80005934:	70e2                	ld	ra,56(sp)
    80005936:	7442                	ld	s0,48(sp)
    80005938:	74a2                	ld	s1,40(sp)
    8000593a:	6121                	addi	sp,sp,64
    8000593c:	8082                	ret
	...

0000000080005940 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005940:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005942:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005944:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005946:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005948:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000594a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000594c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000594e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005950:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005952:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005954:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005956:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005958:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000595a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000595c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000595e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005960:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005962:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005964:	e91fc0ef          	jal	800027f4 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005968:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000596a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000596c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000596e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005970:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005972:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005974:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005976:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005978:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000597a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000597c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000597e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005980:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005982:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005984:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005986:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005988:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000598a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000598c:	10200073          	sret
	...

000000008000599e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000599e:	1141                	addi	sp,sp,-16
    800059a0:	e422                	sd	s0,8(sp)
    800059a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800059a4:	0c0007b7          	lui	a5,0xc000
    800059a8:	4705                	li	a4,1
    800059aa:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800059ac:	0c0007b7          	lui	a5,0xc000
    800059b0:	c3d8                	sw	a4,4(a5)
}
    800059b2:	6422                	ld	s0,8(sp)
    800059b4:	0141                	addi	sp,sp,16
    800059b6:	8082                	ret

00000000800059b8 <plicinithart>:

void
plicinithart(void)
{
    800059b8:	1141                	addi	sp,sp,-16
    800059ba:	e406                	sd	ra,8(sp)
    800059bc:	e022                	sd	s0,0(sp)
    800059be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059c0:	ef9fb0ef          	jal	800018b8 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800059c4:	0085171b          	slliw	a4,a0,0x8
    800059c8:	0c0027b7          	lui	a5,0xc002
    800059cc:	97ba                	add	a5,a5,a4
    800059ce:	40200713          	li	a4,1026
    800059d2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800059d6:	00d5151b          	slliw	a0,a0,0xd
    800059da:	0c2017b7          	lui	a5,0xc201
    800059de:	97aa                	add	a5,a5,a0
    800059e0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800059e4:	60a2                	ld	ra,8(sp)
    800059e6:	6402                	ld	s0,0(sp)
    800059e8:	0141                	addi	sp,sp,16
    800059ea:	8082                	ret

00000000800059ec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800059ec:	1141                	addi	sp,sp,-16
    800059ee:	e406                	sd	ra,8(sp)
    800059f0:	e022                	sd	s0,0(sp)
    800059f2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059f4:	ec5fb0ef          	jal	800018b8 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    800059f8:	00d5151b          	slliw	a0,a0,0xd
    800059fc:	0c2017b7          	lui	a5,0xc201
    80005a00:	97aa                	add	a5,a5,a0
  return irq;
}
    80005a02:	43c8                	lw	a0,4(a5)
    80005a04:	60a2                	ld	ra,8(sp)
    80005a06:	6402                	ld	s0,0(sp)
    80005a08:	0141                	addi	sp,sp,16
    80005a0a:	8082                	ret

0000000080005a0c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a0c:	1101                	addi	sp,sp,-32
    80005a0e:	ec06                	sd	ra,24(sp)
    80005a10:	e822                	sd	s0,16(sp)
    80005a12:	e426                	sd	s1,8(sp)
    80005a14:	1000                	addi	s0,sp,32
    80005a16:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a18:	ea1fb0ef          	jal	800018b8 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80005a1c:	00d5151b          	slliw	a0,a0,0xd
    80005a20:	0c2017b7          	lui	a5,0xc201
    80005a24:	97aa                	add	a5,a5,a0
    80005a26:	c3c4                	sw	s1,4(a5)
}
    80005a28:	60e2                	ld	ra,24(sp)
    80005a2a:	6442                	ld	s0,16(sp)
    80005a2c:	64a2                	ld	s1,8(sp)
    80005a2e:	6105                	addi	sp,sp,32
    80005a30:	8082                	ret

0000000080005a32 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a32:	1141                	addi	sp,sp,-16
    80005a34:	e406                	sd	ra,8(sp)
    80005a36:	e022                	sd	s0,0(sp)
    80005a38:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005a3a:	479d                	li	a5,7
    80005a3c:	04a7ca63          	blt	a5,a0,80005a90 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005a40:	0001e797          	auipc	a5,0x1e
    80005a44:	fb078793          	addi	a5,a5,-80 # 800239f0 <disk>
    80005a48:	97aa                	add	a5,a5,a0
    80005a4a:	0187c783          	lbu	a5,24(a5)
    80005a4e:	e7b9                	bnez	a5,80005a9c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a50:	00451693          	slli	a3,a0,0x4
    80005a54:	0001e797          	auipc	a5,0x1e
    80005a58:	f9c78793          	addi	a5,a5,-100 # 800239f0 <disk>
    80005a5c:	6398                	ld	a4,0(a5)
    80005a5e:	9736                	add	a4,a4,a3
    80005a60:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005a64:	6398                	ld	a4,0(a5)
    80005a66:	9736                	add	a4,a4,a3
    80005a68:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005a6c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005a70:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005a74:	97aa                	add	a5,a5,a0
    80005a76:	4705                	li	a4,1
    80005a78:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005a7c:	0001e517          	auipc	a0,0x1e
    80005a80:	f8c50513          	addi	a0,a0,-116 # 80023a08 <disk+0x18>
    80005a84:	cdcfc0ef          	jal	80001f60 <wakeup>
}
    80005a88:	60a2                	ld	ra,8(sp)
    80005a8a:	6402                	ld	s0,0(sp)
    80005a8c:	0141                	addi	sp,sp,16
    80005a8e:	8082                	ret
    panic("free_desc 1");
    80005a90:	00002517          	auipc	a0,0x2
    80005a94:	cc050513          	addi	a0,a0,-832 # 80007750 <etext+0x750>
    80005a98:	d59fa0ef          	jal	800007f0 <panic>
    panic("free_desc 2");
    80005a9c:	00002517          	auipc	a0,0x2
    80005aa0:	cc450513          	addi	a0,a0,-828 # 80007760 <etext+0x760>
    80005aa4:	d4dfa0ef          	jal	800007f0 <panic>

0000000080005aa8 <virtio_disk_init>:
{
    80005aa8:	1101                	addi	sp,sp,-32
    80005aaa:	ec06                	sd	ra,24(sp)
    80005aac:	e822                	sd	s0,16(sp)
    80005aae:	e426                	sd	s1,8(sp)
    80005ab0:	e04a                	sd	s2,0(sp)
    80005ab2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ab4:	00002597          	auipc	a1,0x2
    80005ab8:	cbc58593          	addi	a1,a1,-836 # 80007770 <etext+0x770>
    80005abc:	0001e517          	auipc	a0,0x1e
    80005ac0:	05c50513          	addi	a0,a0,92 # 80023b18 <disk+0x128>
    80005ac4:	898fb0ef          	jal	80000b5c <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ac8:	100017b7          	lui	a5,0x10001
    80005acc:	4398                	lw	a4,0(a5)
    80005ace:	2701                	sext.w	a4,a4
    80005ad0:	747277b7          	lui	a5,0x74727
    80005ad4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ad8:	18f71063          	bne	a4,a5,80005c58 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005adc:	100017b7          	lui	a5,0x10001
    80005ae0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005ae2:	439c                	lw	a5,0(a5)
    80005ae4:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ae6:	4709                	li	a4,2
    80005ae8:	16e79863          	bne	a5,a4,80005c58 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005aec:	100017b7          	lui	a5,0x10001
    80005af0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005af2:	439c                	lw	a5,0(a5)
    80005af4:	2781                	sext.w	a5,a5
    80005af6:	16e79163          	bne	a5,a4,80005c58 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005afa:	100017b7          	lui	a5,0x10001
    80005afe:	47d8                	lw	a4,12(a5)
    80005b00:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b02:	554d47b7          	lui	a5,0x554d4
    80005b06:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b0a:	14f71763          	bne	a4,a5,80005c58 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b0e:	100017b7          	lui	a5,0x10001
    80005b12:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b16:	4705                	li	a4,1
    80005b18:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b1a:	470d                	li	a4,3
    80005b1c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b1e:	10001737          	lui	a4,0x10001
    80005b22:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b24:	c7ffe737          	lui	a4,0xc7ffe
    80005b28:	55f70713          	addi	a4,a4,1375 # ffffffffc7ffe55f <end+0xffffffff47fdaa2f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b2c:	8ef9                	and	a3,a3,a4
    80005b2e:	10001737          	lui	a4,0x10001
    80005b32:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b34:	472d                	li	a4,11
    80005b36:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b38:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b3c:	439c                	lw	a5,0(a5)
    80005b3e:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b42:	8ba1                	andi	a5,a5,8
    80005b44:	12078063          	beqz	a5,80005c64 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b48:	100017b7          	lui	a5,0x10001
    80005b4c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005b50:	100017b7          	lui	a5,0x10001
    80005b54:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005b58:	439c                	lw	a5,0(a5)
    80005b5a:	2781                	sext.w	a5,a5
    80005b5c:	10079a63          	bnez	a5,80005c70 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b60:	100017b7          	lui	a5,0x10001
    80005b64:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005b68:	439c                	lw	a5,0(a5)
    80005b6a:	2781                	sext.w	a5,a5
  if (max == 0)
    80005b6c:	10078863          	beqz	a5,80005c7c <virtio_disk_init+0x1d4>
  if (max < NUM)
    80005b70:	471d                	li	a4,7
    80005b72:	10f77b63          	bgeu	a4,a5,80005c88 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005b76:	f55fa0ef          	jal	80000aca <kalloc>
    80005b7a:	0001e497          	auipc	s1,0x1e
    80005b7e:	e7648493          	addi	s1,s1,-394 # 800239f0 <disk>
    80005b82:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005b84:	f47fa0ef          	jal	80000aca <kalloc>
    80005b88:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005b8a:	f41fa0ef          	jal	80000aca <kalloc>
    80005b8e:	87aa                	mv	a5,a0
    80005b90:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005b92:	6088                	ld	a0,0(s1)
    80005b94:	10050063          	beqz	a0,80005c94 <virtio_disk_init+0x1ec>
    80005b98:	0001e717          	auipc	a4,0x1e
    80005b9c:	e6073703          	ld	a4,-416(a4) # 800239f8 <disk+0x8>
    80005ba0:	0e070a63          	beqz	a4,80005c94 <virtio_disk_init+0x1ec>
    80005ba4:	0e078863          	beqz	a5,80005c94 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005ba8:	6605                	lui	a2,0x1
    80005baa:	4581                	li	a1,0
    80005bac:	8eafb0ef          	jal	80000c96 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005bb0:	0001e497          	auipc	s1,0x1e
    80005bb4:	e4048493          	addi	s1,s1,-448 # 800239f0 <disk>
    80005bb8:	6605                	lui	a2,0x1
    80005bba:	4581                	li	a1,0
    80005bbc:	6488                	ld	a0,8(s1)
    80005bbe:	8d8fb0ef          	jal	80000c96 <memset>
  memset(disk.used, 0, PGSIZE);
    80005bc2:	6605                	lui	a2,0x1
    80005bc4:	4581                	li	a1,0
    80005bc6:	6888                	ld	a0,16(s1)
    80005bc8:	8cefb0ef          	jal	80000c96 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005bcc:	100017b7          	lui	a5,0x10001
    80005bd0:	4721                	li	a4,8
    80005bd2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005bd4:	4098                	lw	a4,0(s1)
    80005bd6:	100017b7          	lui	a5,0x10001
    80005bda:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005bde:	40d8                	lw	a4,4(s1)
    80005be0:	100017b7          	lui	a5,0x10001
    80005be4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005be8:	649c                	ld	a5,8(s1)
    80005bea:	0007869b          	sext.w	a3,a5
    80005bee:	10001737          	lui	a4,0x10001
    80005bf2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005bf6:	9781                	srai	a5,a5,0x20
    80005bf8:	10001737          	lui	a4,0x10001
    80005bfc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c00:	689c                	ld	a5,16(s1)
    80005c02:	0007869b          	sext.w	a3,a5
    80005c06:	10001737          	lui	a4,0x10001
    80005c0a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c0e:	9781                	srai	a5,a5,0x20
    80005c10:	10001737          	lui	a4,0x10001
    80005c14:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c18:	10001737          	lui	a4,0x10001
    80005c1c:	4785                	li	a5,1
    80005c1e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c20:	00f48c23          	sb	a5,24(s1)
    80005c24:	00f48ca3          	sb	a5,25(s1)
    80005c28:	00f48d23          	sb	a5,26(s1)
    80005c2c:	00f48da3          	sb	a5,27(s1)
    80005c30:	00f48e23          	sb	a5,28(s1)
    80005c34:	00f48ea3          	sb	a5,29(s1)
    80005c38:	00f48f23          	sb	a5,30(s1)
    80005c3c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c40:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c44:	100017b7          	lui	a5,0x10001
    80005c48:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005c4c:	60e2                	ld	ra,24(sp)
    80005c4e:	6442                	ld	s0,16(sp)
    80005c50:	64a2                	ld	s1,8(sp)
    80005c52:	6902                	ld	s2,0(sp)
    80005c54:	6105                	addi	sp,sp,32
    80005c56:	8082                	ret
    panic("could not find virtio disk");
    80005c58:	00002517          	auipc	a0,0x2
    80005c5c:	b2850513          	addi	a0,a0,-1240 # 80007780 <etext+0x780>
    80005c60:	b91fa0ef          	jal	800007f0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c64:	00002517          	auipc	a0,0x2
    80005c68:	b3c50513          	addi	a0,a0,-1220 # 800077a0 <etext+0x7a0>
    80005c6c:	b85fa0ef          	jal	800007f0 <panic>
    panic("virtio disk should not be ready");
    80005c70:	00002517          	auipc	a0,0x2
    80005c74:	b5050513          	addi	a0,a0,-1200 # 800077c0 <etext+0x7c0>
    80005c78:	b79fa0ef          	jal	800007f0 <panic>
    panic("virtio disk has no queue 0");
    80005c7c:	00002517          	auipc	a0,0x2
    80005c80:	b6450513          	addi	a0,a0,-1180 # 800077e0 <etext+0x7e0>
    80005c84:	b6dfa0ef          	jal	800007f0 <panic>
    panic("virtio disk max queue too short");
    80005c88:	00002517          	auipc	a0,0x2
    80005c8c:	b7850513          	addi	a0,a0,-1160 # 80007800 <etext+0x800>
    80005c90:	b61fa0ef          	jal	800007f0 <panic>
    panic("virtio disk kalloc");
    80005c94:	00002517          	auipc	a0,0x2
    80005c98:	b8c50513          	addi	a0,a0,-1140 # 80007820 <etext+0x820>
    80005c9c:	b55fa0ef          	jal	800007f0 <panic>

0000000080005ca0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ca0:	7159                	addi	sp,sp,-112
    80005ca2:	f486                	sd	ra,104(sp)
    80005ca4:	f0a2                	sd	s0,96(sp)
    80005ca6:	eca6                	sd	s1,88(sp)
    80005ca8:	e8ca                	sd	s2,80(sp)
    80005caa:	e4ce                	sd	s3,72(sp)
    80005cac:	e0d2                	sd	s4,64(sp)
    80005cae:	fc56                	sd	s5,56(sp)
    80005cb0:	f85a                	sd	s6,48(sp)
    80005cb2:	f45e                	sd	s7,40(sp)
    80005cb4:	f062                	sd	s8,32(sp)
    80005cb6:	ec66                	sd	s9,24(sp)
    80005cb8:	1880                	addi	s0,sp,112
    80005cba:	8a2a                	mv	s4,a0
    80005cbc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005cbe:	00c52c83          	lw	s9,12(a0)
    80005cc2:	001c9c9b          	slliw	s9,s9,0x1
    80005cc6:	1c82                	slli	s9,s9,0x20
    80005cc8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ccc:	0001e517          	auipc	a0,0x1e
    80005cd0:	e4c50513          	addi	a0,a0,-436 # 80023b18 <disk+0x128>
    80005cd4:	efffa0ef          	jal	80000bd2 <acquire>
  for (int i = 0; i < 3; i++) {
    80005cd8:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    80005cda:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005cdc:	0001eb17          	auipc	s6,0x1e
    80005ce0:	d14b0b13          	addi	s6,s6,-748 # 800239f0 <disk>
  for (int i = 0; i < 3; i++) {
    80005ce4:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005ce6:	0001ec17          	auipc	s8,0x1e
    80005cea:	d22c0c13          	addi	s8,s8,-734 # 80023a08 <disk+0x18>
    80005cee:	a0bd                	j	80005d5c <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005cf0:	00fb0733          	add	a4,s6,a5
    80005cf4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005cf8:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005cfa:	0207c563          	bltz	a5,80005d24 <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    80005cfe:	2905                	addiw	s2,s2,1
    80005d00:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d02:	07590163          	beq	s2,s5,80005d64 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005d06:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005d08:	0001e717          	auipc	a4,0x1e
    80005d0c:	ce870713          	addi	a4,a4,-792 # 800239f0 <disk>
    80005d10:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    80005d12:	01874683          	lbu	a3,24(a4)
    80005d16:	fee9                	bnez	a3,80005cf0 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    80005d18:	2785                	addiw	a5,a5,1
    80005d1a:	0705                	addi	a4,a4,1
    80005d1c:	fe979be3          	bne	a5,s1,80005d12 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005d20:	57fd                	li	a5,-1
    80005d22:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80005d24:	01205d63          	blez	s2,80005d3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005d28:	f9042503          	lw	a0,-112(s0)
    80005d2c:	d07ff0ef          	jal	80005a32 <free_desc>
      for (int j = 0; j < i; j++)
    80005d30:	4785                	li	a5,1
    80005d32:	0127d663          	bge	a5,s2,80005d3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005d36:	f9442503          	lw	a0,-108(s0)
    80005d3a:	cf9ff0ef          	jal	80005a32 <free_desc>
    sleep_prepare(&disk.free[0]);
    80005d3e:	8562                	mv	a0,s8
    80005d40:	9b4fc0ef          	jal	80001ef4 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005d44:	0001e917          	auipc	s2,0x1e
    80005d48:	dd490913          	addi	s2,s2,-556 # 80023b18 <disk+0x128>
    80005d4c:	854a                	mv	a0,s2
    80005d4e:	f11fa0ef          	jal	80000c5e <release>
    sleep();
    80005d52:	9defc0ef          	jal	80001f30 <sleep>
    acquire(&disk.vdisk_lock);
    80005d56:	854a                	mv	a0,s2
    80005d58:	e7bfa0ef          	jal	80000bd2 <acquire>
  for (int i = 0; i < 3; i++) {
    80005d5c:	f9040613          	addi	a2,s0,-112
    80005d60:	894e                	mv	s2,s3
    80005d62:	b755                	j	80005d06 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d64:	f9042503          	lw	a0,-112(s0)
    80005d68:	00451693          	slli	a3,a0,0x4

  if (write)
    80005d6c:	0001e797          	auipc	a5,0x1e
    80005d70:	c8478793          	addi	a5,a5,-892 # 800239f0 <disk>
    80005d74:	00a50713          	addi	a4,a0,10
    80005d78:	0712                	slli	a4,a4,0x4
    80005d7a:	973e                	add	a4,a4,a5
    80005d7c:	01703633          	snez	a2,s7
    80005d80:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005d82:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005d86:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005d8a:	6398                	ld	a4,0(a5)
    80005d8c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d8e:	0a868613          	addi	a2,a3,168
    80005d92:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005d94:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005d96:	6390                	ld	a2,0(a5)
    80005d98:	00d605b3          	add	a1,a2,a3
    80005d9c:	4741                	li	a4,16
    80005d9e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005da0:	4805                	li	a6,1
    80005da2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005da6:	f9442703          	lw	a4,-108(s0)
    80005daa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005dae:	0712                	slli	a4,a4,0x4
    80005db0:	963a                	add	a2,a2,a4
    80005db2:	058a0593          	addi	a1,s4,88
    80005db6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005db8:	0007b883          	ld	a7,0(a5)
    80005dbc:	9746                	add	a4,a4,a7
    80005dbe:	40000613          	li	a2,1024
    80005dc2:	c710                	sw	a2,8(a4)
  if (write)
    80005dc4:	001bb613          	seqz	a2,s7
    80005dc8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005dcc:	00166613          	ori	a2,a2,1
    80005dd0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005dd4:	f9842583          	lw	a1,-104(s0)
    80005dd8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005ddc:	00250613          	addi	a2,a0,2
    80005de0:	0612                	slli	a2,a2,0x4
    80005de2:	963e                	add	a2,a2,a5
    80005de4:	577d                	li	a4,-1
    80005de6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005dea:	0592                	slli	a1,a1,0x4
    80005dec:	98ae                	add	a7,a7,a1
    80005dee:	03068713          	addi	a4,a3,48
    80005df2:	973e                	add	a4,a4,a5
    80005df4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005df8:	6398                	ld	a4,0(a5)
    80005dfa:	972e                	add	a4,a4,a1
    80005dfc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e00:	4689                	li	a3,2
    80005e02:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e06:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e0a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005e0e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e12:	6794                	ld	a3,8(a5)
    80005e14:	0026d703          	lhu	a4,2(a3)
    80005e18:	8b1d                	andi	a4,a4,7
    80005e1a:	0706                	slli	a4,a4,0x1
    80005e1c:	96ba                	add	a3,a3,a4
    80005e1e:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005e22:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e26:	6798                	ld	a4,8(a5)
    80005e28:	00275783          	lhu	a5,2(a4)
    80005e2c:	2785                	addiw	a5,a5,1
    80005e2e:	00f71123          	sh	a5,2(a4)
    80005e32:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e36:	100017b7          	lui	a5,0x10001
    80005e3a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005e3e:	004a2783          	lw	a5,4(s4)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005e42:	0001e497          	auipc	s1,0x1e
    80005e46:	cd648493          	addi	s1,s1,-810 # 80023b18 <disk+0x128>
  while (b->disk == 1) {
    80005e4a:	4905                	li	s2,1
    80005e4c:	03079163          	bne	a5,a6,80005e6e <virtio_disk_rw+0x1ce>
    sleep_prepare(b);
    80005e50:	8552                	mv	a0,s4
    80005e52:	8a2fc0ef          	jal	80001ef4 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005e56:	8526                	mv	a0,s1
    80005e58:	e07fa0ef          	jal	80000c5e <release>
    sleep();
    80005e5c:	8d4fc0ef          	jal	80001f30 <sleep>
    acquire(&disk.vdisk_lock);
    80005e60:	8526                	mv	a0,s1
    80005e62:	d71fa0ef          	jal	80000bd2 <acquire>
  while (b->disk == 1) {
    80005e66:	004a2783          	lw	a5,4(s4)
    80005e6a:	ff2783e3          	beq	a5,s2,80005e50 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005e6e:	f9042903          	lw	s2,-112(s0)
    80005e72:	00290713          	addi	a4,s2,2
    80005e76:	0712                	slli	a4,a4,0x4
    80005e78:	0001e797          	auipc	a5,0x1e
    80005e7c:	b7878793          	addi	a5,a5,-1160 # 800239f0 <disk>
    80005e80:	97ba                	add	a5,a5,a4
    80005e82:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e86:	0001e997          	auipc	s3,0x1e
    80005e8a:	b6a98993          	addi	s3,s3,-1174 # 800239f0 <disk>
    80005e8e:	00491713          	slli	a4,s2,0x4
    80005e92:	0009b783          	ld	a5,0(s3)
    80005e96:	97ba                	add	a5,a5,a4
    80005e98:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005e9c:	854a                	mv	a0,s2
    80005e9e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005ea2:	b91ff0ef          	jal	80005a32 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005ea6:	8885                	andi	s1,s1,1
    80005ea8:	f0fd                	bnez	s1,80005e8e <virtio_disk_rw+0x1ee>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005eaa:	0001e517          	auipc	a0,0x1e
    80005eae:	c6e50513          	addi	a0,a0,-914 # 80023b18 <disk+0x128>
    80005eb2:	dadfa0ef          	jal	80000c5e <release>
}
    80005eb6:	70a6                	ld	ra,104(sp)
    80005eb8:	7406                	ld	s0,96(sp)
    80005eba:	64e6                	ld	s1,88(sp)
    80005ebc:	6946                	ld	s2,80(sp)
    80005ebe:	69a6                	ld	s3,72(sp)
    80005ec0:	6a06                	ld	s4,64(sp)
    80005ec2:	7ae2                	ld	s5,56(sp)
    80005ec4:	7b42                	ld	s6,48(sp)
    80005ec6:	7ba2                	ld	s7,40(sp)
    80005ec8:	7c02                	ld	s8,32(sp)
    80005eca:	6ce2                	ld	s9,24(sp)
    80005ecc:	6165                	addi	sp,sp,112
    80005ece:	8082                	ret

0000000080005ed0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ed0:	1101                	addi	sp,sp,-32
    80005ed2:	ec06                	sd	ra,24(sp)
    80005ed4:	e822                	sd	s0,16(sp)
    80005ed6:	e426                	sd	s1,8(sp)
    80005ed8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005eda:	0001e497          	auipc	s1,0x1e
    80005ede:	b1648493          	addi	s1,s1,-1258 # 800239f0 <disk>
    80005ee2:	0001e517          	auipc	a0,0x1e
    80005ee6:	c3650513          	addi	a0,a0,-970 # 80023b18 <disk+0x128>
    80005eea:	ce9fa0ef          	jal	80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005eee:	100017b7          	lui	a5,0x10001
    80005ef2:	53b8                	lw	a4,96(a5)
    80005ef4:	8b0d                	andi	a4,a4,3
    80005ef6:	100017b7          	lui	a5,0x10001
    80005efa:	d3f8                	sw	a4,100(a5)
    80005efc:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005f00:	689c                	ld	a5,16(s1)
    80005f02:	0204d703          	lhu	a4,32(s1)
    80005f06:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f0a:	04f70663          	beq	a4,a5,80005f56 <virtio_disk_intr+0x86>
    80005f0e:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f12:	6898                	ld	a4,16(s1)
    80005f14:	0204d783          	lhu	a5,32(s1)
    80005f18:	8b9d                	andi	a5,a5,7
    80005f1a:	078e                	slli	a5,a5,0x3
    80005f1c:	97ba                	add	a5,a5,a4
    80005f1e:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005f20:	00278713          	addi	a4,a5,2
    80005f24:	0712                	slli	a4,a4,0x4
    80005f26:	9726                	add	a4,a4,s1
    80005f28:	01074703          	lbu	a4,16(a4)
    80005f2c:	e321                	bnez	a4,80005f6c <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f2e:	0789                	addi	a5,a5,2
    80005f30:	0792                	slli	a5,a5,0x4
    80005f32:	97a6                	add	a5,a5,s1
    80005f34:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005f36:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f3a:	826fc0ef          	jal	80001f60 <wakeup>

    disk.used_idx += 1;
    80005f3e:	0204d783          	lhu	a5,32(s1)
    80005f42:	2785                	addiw	a5,a5,1
    80005f44:	17c2                	slli	a5,a5,0x30
    80005f46:	93c1                	srli	a5,a5,0x30
    80005f48:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005f4c:	6898                	ld	a4,16(s1)
    80005f4e:	00275703          	lhu	a4,2(a4)
    80005f52:	faf71ee3          	bne	a4,a5,80005f0e <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f56:	0001e517          	auipc	a0,0x1e
    80005f5a:	bc250513          	addi	a0,a0,-1086 # 80023b18 <disk+0x128>
    80005f5e:	d01fa0ef          	jal	80000c5e <release>
}
    80005f62:	60e2                	ld	ra,24(sp)
    80005f64:	6442                	ld	s0,16(sp)
    80005f66:	64a2                	ld	s1,8(sp)
    80005f68:	6105                	addi	sp,sp,32
    80005f6a:	8082                	ret
      panic("virtio_disk_intr status");
    80005f6c:	00002517          	auipc	a0,0x2
    80005f70:	8cc50513          	addi	a0,a0,-1844 # 80007838 <etext+0x838>
    80005f74:	87dfa0ef          	jal	800007f0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
