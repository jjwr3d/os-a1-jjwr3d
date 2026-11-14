
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	96010113          	addi	sp,sp,-1696
   4:	68113c23          	sd	ra,1688(sp)
   8:	68813823          	sd	s0,1680(sp)
   c:	68913423          	sd	s1,1672(sp)
  10:	69213023          	sd	s2,1664(sp)
  14:	67313c23          	sd	s3,1656(sp)
  18:	6a010413          	addi	s0,sp,1696
  1c:	84ae                	mv	s1,a1
    int n_limit = -1;
    int cmd_idx = 1;

    if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  1e:	4785                	li	a5,1
  20:	00a7c963          	blt	a5,a0,32 <main+0x32>
            exit(1);
        }
        cmd_idx = 3;
    }

    char *cmd = argv[cmd_idx];
  24:	659c                	ld	a5,8(a1)
  26:	96f43023          	sd	a5,-1696(s0)
    int n_limit = -1;
  2a:	597d                	li	s2,-1
    char *xargv[MAXARG];
    int base_argc = 0;
  2c:	96043423          	sd	zero,-1688(s0)
  30:	a475                	j	2dc <main+0x2dc>
  32:	89aa                	mv	s3,a0
    if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  34:	00001597          	auipc	a1,0x1
  38:	b7c58593          	addi	a1,a1,-1156 # bb0 <malloc+0x100>
  3c:	6488                	ld	a0,8(s1)
  3e:	30e000ef          	jal	34c <strcmp>
  42:	26051163          	bnez	a0,2a4 <main+0x2a4>
        if (argc < 4) {
  46:	478d                	li	a5,3
  48:	0337cc63          	blt	a5,s3,80 <main+0x80>
  4c:	67413823          	sd	s4,1648(sp)
  50:	67513423          	sd	s5,1640(sp)
  54:	67613023          	sd	s6,1632(sp)
  58:	65713c23          	sd	s7,1624(sp)
  5c:	65813823          	sd	s8,1616(sp)
  60:	65913423          	sd	s9,1608(sp)
  64:	65a13023          	sd	s10,1600(sp)
  68:	63b13c23          	sd	s11,1592(sp)
            fprintf(2, "usage: xargs [-n N] cmd [args...]\n");
  6c:	00001597          	auipc	a1,0x1
  70:	b4c58593          	addi	a1,a1,-1204 # bb8 <malloc+0x108>
  74:	4509                	li	a0,2
  76:	15d000ef          	jal	9d2 <fprintf>
            exit(1);
  7a:	4505                	li	a0,1
  7c:	538000ef          	jal	5b4 <exit>
        n_limit = atoi(argv[2]);
  80:	6888                	ld	a0,16(s1)
  82:	410000ef          	jal	492 <atoi>
  86:	892a                	mv	s2,a0
        cmd_idx = 3;
  88:	468d                	li	a3,3
        if (n_limit < 1) {
  8a:	20a04f63          	bgtz	a0,2a8 <main+0x2a8>
  8e:	67413823          	sd	s4,1648(sp)
  92:	67513423          	sd	s5,1640(sp)
  96:	67613023          	sd	s6,1632(sp)
  9a:	65713c23          	sd	s7,1624(sp)
  9e:	65813823          	sd	s8,1616(sp)
  a2:	65913423          	sd	s9,1608(sp)
  a6:	65a13023          	sd	s10,1600(sp)
  aa:	63b13c23          	sd	s11,1592(sp)
            fprintf(2, "usage: xargs [-n N] cmd [args...]\n");
  ae:	00001597          	auipc	a1,0x1
  b2:	b0a58593          	addi	a1,a1,-1270 # bb8 <malloc+0x108>
  b6:	4509                	li	a0,2
  b8:	11b000ef          	jal	9d2 <fprintf>
            exit(1);
  bc:	4505                	li	a0,1
  be:	4f6000ef          	jal	5b4 <exit>
        char *last_processed = buf;

        while (*p) {
            // Check if character is a delimiter
            if (*p == ' ' || *p == '\t' || *p == '\n') {
                if (word_start) {
  c2:	ce9d                	beqz	a3,100 <main+0x100>
                    *p = '\0';
  c4:	00048023          	sb	zero,0(s1)
                    words[word_count++] = word_start;
  c8:	0017079b          	addiw	a5,a4,1
  cc:	070e                	slli	a4,a4,0x3
  ce:	f9070713          	addi	a4,a4,-112
  d2:	9722                	add	a4,a4,s0
  d4:	a0d73023          	sd	a3,-1536(a4)
  d8:	873e                	mv	a4,a5
                    word_start = 0;
                }
                
                // Trigger condition
                int should_run = 0;
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
  da:	0b590363          	beq	s2,s5,180 <main+0x180>
                    should_run = 1; // Run once per non-empty line
                } else if (n_limit > 0 && word_count == n_limit) {
  de:	86d2                	mv	a3,s4
  e0:	02e90863          	beq	s2,a4,110 <main+0x110>
                    last_processed = p + 1;
                }
            } else {
                if (!word_start) word_start = p;
            }
            p++;
  e4:	0485                	addi	s1,s1,1
        while (*p) {
  e6:	0004c783          	lbu	a5,0(s1)
  ea:	cfc9                	beqz	a5,184 <main+0x184>
            if (*p == ' ' || *p == '\t' || *p == '\n') {
  ec:	fd378be3          	beq	a5,s3,c2 <main+0xc2>
  f0:	37dd                	addiw	a5,a5,-9
  f2:	0ff7f793          	zext.b	a5,a5
  f6:	fcfb76e3          	bgeu	s6,a5,c2 <main+0xc2>
                if (!word_start) word_start = p;
  fa:	f6ed                	bnez	a3,e4 <main+0xe4>
  fc:	86a6                	mv	a3,s1
  fe:	b7dd                	j	e4 <main+0xe4>
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 100:	fd591fe3          	bne	s2,s5,de <main+0xde>
 104:	0004c783          	lbu	a5,0(s1)
 108:	fda79ee3          	bne	a5,s10,e4 <main+0xe4>
 10c:	fce05ce3          	blez	a4,e4 <main+0xe4>
 110:	99040613          	addi	a2,s0,-1648
                    words[word_count++] = word_start;
 114:	97843683          	ld	a3,-1672(s0)
 118:	87d2                	mv	a5,s4
                        xargv[curr_argc++] = words[i];
 11a:	620c                	ld	a1,0(a2)
 11c:	e28c                	sd	a1,0(a3)
                    for (int i = 0; i < word_count; i++) {
 11e:	2785                	addiw	a5,a5,1
 120:	0621                	addi	a2,a2,8
 122:	06a1                	addi	a3,a3,8
 124:	fee7cbe3          	blt	a5,a4,11a <main+0x11a>
                    xargv[curr_argc] = 0;
 128:	fff7079b          	addiw	a5,a4,-1
 12c:	00fd87bb          	addw	a5,s11,a5
 130:	078e                	slli	a5,a5,0x3
 132:	f9078793          	addi	a5,a5,-112
 136:	97a2                	add	a5,a5,s0
 138:	f007b023          	sd	zero,-256(a5)
                    int pid = fork();
 13c:	470000ef          	jal	5ac <fork>
                    if (pid == 0) {
 140:	c105                	beqz	a0,160 <main+0x160>
                        wait(&status);
 142:	98c40513          	addi	a0,s0,-1652
 146:	476000ef          	jal	5bc <wait>
                        if (status != 0) global_status = 1;
 14a:	98c42783          	lw	a5,-1652(s0)
 14e:	c781                	beqz	a5,156 <main+0x156>
 150:	4785                	li	a5,1
 152:	96f43823          	sd	a5,-1680(s0)
                    last_processed = p + 1;
 156:	00148593          	addi	a1,s1,1
 15a:	86d2                	mv	a3,s4
                    word_count = 0;
 15c:	8752                	mv	a4,s4
 15e:	b759                	j	e4 <main+0xe4>
                        exec(cmd, xargv);
 160:	e9040593          	addi	a1,s0,-368
 164:	96043503          	ld	a0,-1696(s0)
 168:	484000ef          	jal	5ec <exec>
                        fprintf(2, "xargs: exec failed\n");
 16c:	00001597          	auipc	a1,0x1
 170:	a7458593          	addi	a1,a1,-1420 # be0 <malloc+0x130>
 174:	4509                	li	a0,2
 176:	05d000ef          	jal	9d2 <fprintf>
                        exit(1);
 17a:	4505                	li	a0,1
 17c:	438000ef          	jal	5b4 <exit>
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 180:	86d2                	mv	a3,s4
 182:	b78d                	j	e4 <main+0xe4>
        }

        // Shift unprocessed partial chunks back to buffer head
        int processed_bytes = last_processed - buf;
 184:	419587bb          	subw	a5,a1,s9
        if (processed_bytes > 0) {
 188:	04f04463          	bgtz	a5,1d0 <main+0x1d0>
    while ((n = read(0, buf + buf_len, sizeof(buf) - buf_len - 1)) > 0) {
 18c:	018c84b3          	add	s1,s9,s8
 190:	3ff00793          	li	a5,1023
 194:	4187863b          	subw	a2,a5,s8
 198:	85a6                	mv	a1,s1
 19a:	4501                	li	a0,0
 19c:	430000ef          	jal	5cc <read>
 1a0:	02a05f63          	blez	a0,1de <main+0x1de>
        buf_len += n;
 1a4:	00ac0bbb          	addw	s7,s8,a0
 1a8:	000b8c1b          	sext.w	s8,s7
        buf[buf_len] = '\0';
 1ac:	f90c0793          	addi	a5,s8,-112
 1b0:	97a2                	add	a5,a5,s0
 1b2:	b0078023          	sb	zero,-1280(a5)
        while (*p) {
 1b6:	a9044783          	lbu	a5,-1392(s0)
 1ba:	dbe9                	beqz	a5,18c <main+0x18c>
        char *last_processed = buf;
 1bc:	85e6                	mv	a1,s9
        char *word_start = 0;
 1be:	4681                	li	a3,0
        char *p = buf;
 1c0:	84e6                	mv	s1,s9
        int word_count = 0;
 1c2:	4701                	li	a4,0
            if (*p == ' ' || *p == '\t' || *p == '\n') {
 1c4:	02000993          	li	s3,32
                    words[word_count++] = word_start;
 1c8:	4a01                	li	s4,0
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 1ca:	4d29                	li	s10,10
            if (*p == ' ' || *p == '\t' || *p == '\n') {
 1cc:	4b05                	li	s6,1
 1ce:	bf39                	j	ec <main+0xec>
            memmove(buf, last_processed, buf_len - processed_bytes);
 1d0:	40fb8c3b          	subw	s8,s7,a5
 1d4:	8662                	mv	a2,s8
 1d6:	8566                	mv	a0,s9
 1d8:	302000ef          	jal	4da <memmove>
            buf_len -= processed_bytes;
 1dc:	bf45                	j	18c <main+0x18c>
        }
    }

    // Handle any trailing words if -n N was used and stdin ended without filling a final batch
    if (n_limit > 0 && buf_len > 0) {
 1de:	0b205f63          	blez	s2,29c <main+0x29c>
 1e2:	0b805d63          	blez	s8,29c <main+0x29c>
        char *words[MAXARG];
        int word_count = 0;
        char *p = buf;
        char *word_start = 0;
        while (p < buf + buf_len) {
 1e6:	a9040793          	addi	a5,s0,-1392
 1ea:	0a97f963          	bgeu	a5,s1,29c <main+0x29c>
        char *word_start = 0;
 1ee:	4601                	li	a2,0
        char *p = buf;
 1f0:	873e                	mv	a4,a5
        int word_count = 0;
 1f2:	4681                	li	a3,0
 1f4:	02000513          	li	a0,32
 1f8:	4585                	li	a1,1
 1fa:	1582                	slli	a1,a1,0x20
 1fc:	60158593          	addi	a1,a1,1537
            if (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\0') {
                if (word_start) {
                    *p = '\0';
                    words[word_count++] = word_start;
                    word_start = 0;
 200:	4801                	li	a6,0
 202:	a029                	j	20c <main+0x20c>
                }
            } else {
                if (!word_start) word_start = p;
 204:	ca0d                	beqz	a2,236 <main+0x236>
            }
            p++;
 206:	0705                	addi	a4,a4,1
        while (p < buf + buf_len) {
 208:	02e48963          	beq	s1,a4,23a <main+0x23a>
            if (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\0') {
 20c:	00074783          	lbu	a5,0(a4)
 210:	fef56ae3          	bltu	a0,a5,204 <main+0x204>
 214:	00f5d7b3          	srl	a5,a1,a5
 218:	8b85                	andi	a5,a5,1
 21a:	d7ed                	beqz	a5,204 <main+0x204>
                if (word_start) {
 21c:	d66d                	beqz	a2,206 <main+0x206>
                    *p = '\0';
 21e:	00070023          	sb	zero,0(a4)
                    words[word_count++] = word_start;
 222:	00369793          	slli	a5,a3,0x3
 226:	f9078793          	addi	a5,a5,-112
 22a:	97a2                	add	a5,a5,s0
 22c:	a0c7b023          	sd	a2,-1536(a5)
 230:	2685                	addiw	a3,a3,1
                    word_start = 0;
 232:	8642                	mv	a2,a6
 234:	bfc9                	j	206 <main+0x206>
                if (!word_start) word_start = p;
 236:	863a                	mv	a2,a4
 238:	b7f9                	j	206 <main+0x206>
        }
        if (word_count > 0) {
 23a:	06d05163          	blez	a3,29c <main+0x29c>
 23e:	99040793          	addi	a5,s0,-1648
 242:	00369613          	slli	a2,a3,0x3
 246:	963e                	add	a2,a2,a5
            int curr_argc = base_argc;
            for (int i = 0; i < word_count; i++) {
                xargv[curr_argc++] = words[i];
 248:	6398                	ld	a4,0(a5)
 24a:	97843583          	ld	a1,-1672(s0)
 24e:	e198                	sd	a4,0(a1)
            for (int i = 0; i < word_count; i++) {
 250:	07a1                	addi	a5,a5,8
 252:	00858713          	addi	a4,a1,8
 256:	96e43c23          	sd	a4,-1672(s0)
 25a:	fec797e3          	bne	a5,a2,248 <main+0x248>
            }
            xargv[curr_argc] = 0;
 25e:	96843783          	ld	a5,-1688(s0)
 262:	9fb5                	addw	a5,a5,a3
 264:	078e                	slli	a5,a5,0x3
 266:	f9078793          	addi	a5,a5,-112
 26a:	97a2                	add	a5,a5,s0
 26c:	f007b023          	sd	zero,-256(a5)
            int pid = fork();
 270:	33c000ef          	jal	5ac <fork>
            if (pid == 0) {
 274:	e911                	bnez	a0,288 <main+0x288>
                exec(cmd, xargv);
 276:	e9040593          	addi	a1,s0,-368
 27a:	96043503          	ld	a0,-1696(s0)
 27e:	36e000ef          	jal	5ec <exec>
                exit(1);
 282:	4505                	li	a0,1
 284:	330000ef          	jal	5b4 <exit>
            } else {
                int status;
                wait(&status);
 288:	98c40513          	addi	a0,s0,-1652
 28c:	330000ef          	jal	5bc <wait>
                if (status != 0) global_status = 1;
 290:	98c42783          	lw	a5,-1652(s0)
 294:	c781                	beqz	a5,29c <main+0x29c>
 296:	4785                	li	a5,1
 298:	96f43823          	sd	a5,-1680(s0)
            }
        }
    }

    exit(global_status);
 29c:	97043503          	ld	a0,-1680(s0)
 2a0:	314000ef          	jal	5b4 <exit>
    int cmd_idx = 1;
 2a4:	4685                	li	a3,1
    int n_limit = -1;
 2a6:	597d                	li	s2,-1
    char *cmd = argv[cmd_idx];
 2a8:	00369793          	slli	a5,a3,0x3
 2ac:	00f48733          	add	a4,s1,a5
 2b0:	631c                	ld	a5,0(a4)
 2b2:	96f43023          	sd	a5,-1696(s0)
    for (int i = cmd_idx; i < argc; i++) {
 2b6:	e9040793          	addi	a5,s0,-368
 2ba:	40d989bb          	subw	s3,s3,a3
 2be:	02099693          	slli	a3,s3,0x20
 2c2:	01d6d613          	srli	a2,a3,0x1d
 2c6:	963e                	add	a2,a2,a5
        xargv[base_argc++] = argv[i];
 2c8:	6314                	ld	a3,0(a4)
 2ca:	e394                	sd	a3,0(a5)
    for (int i = cmd_idx; i < argc; i++) {
 2cc:	0721                	addi	a4,a4,8
 2ce:	07a1                	addi	a5,a5,8
 2d0:	fec79ce3          	bne	a5,a2,2c8 <main+0x2c8>
 2d4:	0009879b          	sext.w	a5,s3
 2d8:	96f43423          	sd	a5,-1688(s0)
 2dc:	67413823          	sd	s4,1648(sp)
 2e0:	67513423          	sd	s5,1640(sp)
 2e4:	67613023          	sd	s6,1632(sp)
 2e8:	65713c23          	sd	s7,1624(sp)
 2ec:	65813823          	sd	s8,1616(sp)
 2f0:	65913423          	sd	s9,1608(sp)
 2f4:	65a13023          	sd	s10,1600(sp)
 2f8:	63b13c23          	sd	s11,1592(sp)
 2fc:	96843703          	ld	a4,-1688(s0)
 300:	00371793          	slli	a5,a4,0x3
 304:	e9040693          	addi	a3,s0,-368
 308:	97b6                	add	a5,a5,a3
 30a:	96f43c23          	sd	a5,-1672(s0)
    int global_status = 0;
 30e:	96043823          	sd	zero,-1680(s0)
    int n, buf_len = 0;
 312:	4c01                	li	s8,0
    while ((n = read(0, buf + buf_len, sizeof(buf) - buf_len - 1)) > 0) {
 314:	a9040c93          	addi	s9,s0,-1392
                    xargv[curr_argc] = 0;
 318:	00170d9b          	addiw	s11,a4,1
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 31c:	5afd                	li	s5,-1
 31e:	b5bd                	j	18c <main+0x18c>

0000000000000320 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 328:	cd9ff0ef          	jal	0 <main>
  exit(r);
 32c:	288000ef          	jal	5b4 <exit>

0000000000000330 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 330:	1141                	addi	sp,sp,-16
 332:	e422                	sd	s0,8(sp)
 334:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 336:	87aa                	mv	a5,a0
 338:	0585                	addi	a1,a1,1
 33a:	0785                	addi	a5,a5,1
 33c:	fff5c703          	lbu	a4,-1(a1)
 340:	fee78fa3          	sb	a4,-1(a5)
 344:	fb75                	bnez	a4,338 <strcpy+0x8>
    ;
  return os;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret

000000000000034c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 352:	00054783          	lbu	a5,0(a0)
 356:	cb91                	beqz	a5,36a <strcmp+0x1e>
 358:	0005c703          	lbu	a4,0(a1)
 35c:	00f71763          	bne	a4,a5,36a <strcmp+0x1e>
    p++, q++;
 360:	0505                	addi	a0,a0,1
 362:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 364:	00054783          	lbu	a5,0(a0)
 368:	fbe5                	bnez	a5,358 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 36a:	0005c503          	lbu	a0,0(a1)
}
 36e:	40a7853b          	subw	a0,a5,a0
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <strlen>:

uint
strlen(const char *s)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e422                	sd	s0,8(sp)
 37c:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 37e:	00054783          	lbu	a5,0(a0)
 382:	cf91                	beqz	a5,39e <strlen+0x26>
 384:	0505                	addi	a0,a0,1
 386:	87aa                	mv	a5,a0
 388:	86be                	mv	a3,a5
 38a:	0785                	addi	a5,a5,1
 38c:	fff7c703          	lbu	a4,-1(a5)
 390:	ff65                	bnez	a4,388 <strlen+0x10>
 392:	40a6853b          	subw	a0,a3,a0
 396:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret
  for (n = 0; s[n]; n++)
 39e:	4501                	li	a0,0
 3a0:	bfe5                	j	398 <strlen+0x20>

00000000000003a2 <memset>:

void *
memset(void *dst, int c, uint n)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e422                	sd	s0,8(sp)
 3a6:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 3a8:	ca19                	beqz	a2,3be <memset+0x1c>
 3aa:	87aa                	mv	a5,a0
 3ac:	1602                	slli	a2,a2,0x20
 3ae:	9201                	srli	a2,a2,0x20
 3b0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3b4:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 3b8:	0785                	addi	a5,a5,1
 3ba:	fee79de3          	bne	a5,a4,3b4 <memset+0x12>
  }
  return dst;
}
 3be:	6422                	ld	s0,8(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <strchr>:

char *
strchr(const char *s, char c)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e422                	sd	s0,8(sp)
 3c8:	0800                	addi	s0,sp,16
  for (; *s; s++)
 3ca:	00054783          	lbu	a5,0(a0)
 3ce:	cb99                	beqz	a5,3e4 <strchr+0x20>
    if (*s == c)
 3d0:	00f58763          	beq	a1,a5,3de <strchr+0x1a>
  for (; *s; s++)
 3d4:	0505                	addi	a0,a0,1
 3d6:	00054783          	lbu	a5,0(a0)
 3da:	fbfd                	bnez	a5,3d0 <strchr+0xc>
      return (char *)s;
  return 0;
 3dc:	4501                	li	a0,0
}
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
  return 0;
 3e4:	4501                	li	a0,0
 3e6:	bfe5                	j	3de <strchr+0x1a>

00000000000003e8 <gets>:

char *
gets(char *buf, int max)
{
 3e8:	711d                	addi	sp,sp,-96
 3ea:	ec86                	sd	ra,88(sp)
 3ec:	e8a2                	sd	s0,80(sp)
 3ee:	e4a6                	sd	s1,72(sp)
 3f0:	e0ca                	sd	s2,64(sp)
 3f2:	fc4e                	sd	s3,56(sp)
 3f4:	f852                	sd	s4,48(sp)
 3f6:	f456                	sd	s5,40(sp)
 3f8:	f05a                	sd	s6,32(sp)
 3fa:	ec5e                	sd	s7,24(sp)
 3fc:	1080                	addi	s0,sp,96
 3fe:	8baa                	mv	s7,a0
 400:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 402:	892a                	mv	s2,a0
 404:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 406:	4aa9                	li	s5,10
 408:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 40a:	89a6                	mv	s3,s1
 40c:	2485                	addiw	s1,s1,1
 40e:	0344d663          	bge	s1,s4,43a <gets+0x52>
    cc = read(0, &c, 1);
 412:	4605                	li	a2,1
 414:	faf40593          	addi	a1,s0,-81
 418:	4501                	li	a0,0
 41a:	1b2000ef          	jal	5cc <read>
    if (cc < 1)
 41e:	00a05e63          	blez	a0,43a <gets+0x52>
    buf[i++] = c;
 422:	faf44783          	lbu	a5,-81(s0)
 426:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 42a:	01578763          	beq	a5,s5,438 <gets+0x50>
 42e:	0905                	addi	s2,s2,1
 430:	fd679de3          	bne	a5,s6,40a <gets+0x22>
    buf[i++] = c;
 434:	89a6                	mv	s3,s1
 436:	a011                	j	43a <gets+0x52>
 438:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 43a:	99de                	add	s3,s3,s7
 43c:	00098023          	sb	zero,0(s3)
  return buf;
}
 440:	855e                	mv	a0,s7
 442:	60e6                	ld	ra,88(sp)
 444:	6446                	ld	s0,80(sp)
 446:	64a6                	ld	s1,72(sp)
 448:	6906                	ld	s2,64(sp)
 44a:	79e2                	ld	s3,56(sp)
 44c:	7a42                	ld	s4,48(sp)
 44e:	7aa2                	ld	s5,40(sp)
 450:	7b02                	ld	s6,32(sp)
 452:	6be2                	ld	s7,24(sp)
 454:	6125                	addi	sp,sp,96
 456:	8082                	ret

0000000000000458 <stat>:

int
stat(const char *n, struct stat *st)
{
 458:	1101                	addi	sp,sp,-32
 45a:	ec06                	sd	ra,24(sp)
 45c:	e822                	sd	s0,16(sp)
 45e:	e04a                	sd	s2,0(sp)
 460:	1000                	addi	s0,sp,32
 462:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 464:	4581                	li	a1,0
 466:	18e000ef          	jal	5f4 <open>
  if (fd < 0)
 46a:	02054263          	bltz	a0,48e <stat+0x36>
 46e:	e426                	sd	s1,8(sp)
 470:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 472:	85ca                	mv	a1,s2
 474:	198000ef          	jal	60c <fstat>
 478:	892a                	mv	s2,a0
  close(fd);
 47a:	8526                	mv	a0,s1
 47c:	160000ef          	jal	5dc <close>
  return r;
 480:	64a2                	ld	s1,8(sp)
}
 482:	854a                	mv	a0,s2
 484:	60e2                	ld	ra,24(sp)
 486:	6442                	ld	s0,16(sp)
 488:	6902                	ld	s2,0(sp)
 48a:	6105                	addi	sp,sp,32
 48c:	8082                	ret
    return -1;
 48e:	597d                	li	s2,-1
 490:	bfcd                	j	482 <stat+0x2a>

0000000000000492 <atoi>:

int
atoi(const char *s)
{
 492:	1141                	addi	sp,sp,-16
 494:	e422                	sd	s0,8(sp)
 496:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 498:	00054683          	lbu	a3,0(a0)
 49c:	fd06879b          	addiw	a5,a3,-48
 4a0:	0ff7f793          	zext.b	a5,a5
 4a4:	4625                	li	a2,9
 4a6:	02f66863          	bltu	a2,a5,4d6 <atoi+0x44>
 4aa:	872a                	mv	a4,a0
  n = 0;
 4ac:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 4ae:	0705                	addi	a4,a4,1
 4b0:	0025179b          	slliw	a5,a0,0x2
 4b4:	9fa9                	addw	a5,a5,a0
 4b6:	0017979b          	slliw	a5,a5,0x1
 4ba:	9fb5                	addw	a5,a5,a3
 4bc:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 4c0:	00074683          	lbu	a3,0(a4)
 4c4:	fd06879b          	addiw	a5,a3,-48
 4c8:	0ff7f793          	zext.b	a5,a5
 4cc:	fef671e3          	bgeu	a2,a5,4ae <atoi+0x1c>
  return n;
}
 4d0:	6422                	ld	s0,8(sp)
 4d2:	0141                	addi	sp,sp,16
 4d4:	8082                	ret
  n = 0;
 4d6:	4501                	li	a0,0
 4d8:	bfe5                	j	4d0 <atoi+0x3e>

00000000000004da <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 4da:	1141                	addi	sp,sp,-16
 4dc:	e422                	sd	s0,8(sp)
 4de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4e0:	02b57463          	bgeu	a0,a1,508 <memmove+0x2e>
    while (n-- > 0)
 4e4:	00c05f63          	blez	a2,502 <memmove+0x28>
 4e8:	1602                	slli	a2,a2,0x20
 4ea:	9201                	srli	a2,a2,0x20
 4ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 4f2:	0585                	addi	a1,a1,1
 4f4:	0705                	addi	a4,a4,1
 4f6:	fff5c683          	lbu	a3,-1(a1)
 4fa:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 4fe:	fef71ae3          	bne	a4,a5,4f2 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 502:	6422                	ld	s0,8(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret
    dst += n;
 508:	00c50733          	add	a4,a0,a2
    src += n;
 50c:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 50e:	fec05ae3          	blez	a2,502 <memmove+0x28>
 512:	fff6079b          	addiw	a5,a2,-1
 516:	1782                	slli	a5,a5,0x20
 518:	9381                	srli	a5,a5,0x20
 51a:	fff7c793          	not	a5,a5
 51e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 520:	15fd                	addi	a1,a1,-1
 522:	177d                	addi	a4,a4,-1
 524:	0005c683          	lbu	a3,0(a1)
 528:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 52c:	fee79ae3          	bne	a5,a4,520 <memmove+0x46>
 530:	bfc9                	j	502 <memmove+0x28>

0000000000000532 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 532:	1141                	addi	sp,sp,-16
 534:	e422                	sd	s0,8(sp)
 536:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 538:	ca05                	beqz	a2,568 <memcmp+0x36>
 53a:	fff6069b          	addiw	a3,a2,-1
 53e:	1682                	slli	a3,a3,0x20
 540:	9281                	srli	a3,a3,0x20
 542:	0685                	addi	a3,a3,1
 544:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 546:	00054783          	lbu	a5,0(a0)
 54a:	0005c703          	lbu	a4,0(a1)
 54e:	00e79863          	bne	a5,a4,55e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 552:	0505                	addi	a0,a0,1
    p2++;
 554:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 556:	fed518e3          	bne	a0,a3,546 <memcmp+0x14>
  }
  return 0;
 55a:	4501                	li	a0,0
 55c:	a019                	j	562 <memcmp+0x30>
      return *p1 - *p2;
 55e:	40e7853b          	subw	a0,a5,a4
}
 562:	6422                	ld	s0,8(sp)
 564:	0141                	addi	sp,sp,16
 566:	8082                	ret
  return 0;
 568:	4501                	li	a0,0
 56a:	bfe5                	j	562 <memcmp+0x30>

000000000000056c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 56c:	1141                	addi	sp,sp,-16
 56e:	e406                	sd	ra,8(sp)
 570:	e022                	sd	s0,0(sp)
 572:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 574:	f67ff0ef          	jal	4da <memmove>
}
 578:	60a2                	ld	ra,8(sp)
 57a:	6402                	ld	s0,0(sp)
 57c:	0141                	addi	sp,sp,16
 57e:	8082                	ret

0000000000000580 <sbrk>:

char *
sbrk(int n)
{
 580:	1141                	addi	sp,sp,-16
 582:	e406                	sd	ra,8(sp)
 584:	e022                	sd	s0,0(sp)
 586:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 588:	4585                	li	a1,1
 58a:	0b2000ef          	jal	63c <sys_sbrk>
}
 58e:	60a2                	ld	ra,8(sp)
 590:	6402                	ld	s0,0(sp)
 592:	0141                	addi	sp,sp,16
 594:	8082                	ret

0000000000000596 <sbrklazy>:

char *
sbrklazy(int n)
{
 596:	1141                	addi	sp,sp,-16
 598:	e406                	sd	ra,8(sp)
 59a:	e022                	sd	s0,0(sp)
 59c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 59e:	4589                	li	a1,2
 5a0:	09c000ef          	jal	63c <sys_sbrk>
}
 5a4:	60a2                	ld	ra,8(sp)
 5a6:	6402                	ld	s0,0(sp)
 5a8:	0141                	addi	sp,sp,16
 5aa:	8082                	ret

00000000000005ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5ac:	4885                	li	a7,1
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5b4:	4889                	li	a7,2
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 5bc:	488d                	li	a7,3
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5c4:	4891                	li	a7,4
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <read>:
.global read
read:
 li a7, SYS_read
 5cc:	4895                	li	a7,5
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <write>:
.global write
write:
 li a7, SYS_write
 5d4:	48c1                	li	a7,16
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <close>:
.global close
close:
 li a7, SYS_close
 5dc:	48d5                	li	a7,21
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5e4:	4899                	li	a7,6
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 5ec:	489d                	li	a7,7
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <open>:
.global open
open:
 li a7, SYS_open
 5f4:	48bd                	li	a7,15
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5fc:	48c5                	li	a7,17
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 604:	48c9                	li	a7,18
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 60c:	48a1                	li	a7,8
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <link>:
.global link
link:
 li a7, SYS_link
 614:	48cd                	li	a7,19
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 61c:	48d1                	li	a7,20
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 624:	48a5                	li	a7,9
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <dup>:
.global dup
dup:
 li a7, SYS_dup
 62c:	48a9                	li	a7,10
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 634:	48ad                	li	a7,11
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 63c:	48b1                	li	a7,12
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <pause>:
.global pause
pause:
 li a7, SYS_pause
 644:	48b5                	li	a7,13
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 64c:	48b9                	li	a7,14
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <sync>:
.global sync
sync:
 li a7, SYS_sync
 654:	48d9                	li	a7,22
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <trace>:
.global trace
trace:
 li a7, SYS_trace
 65c:	48dd                	li	a7,23
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 664:	48e1                	li	a7,24
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 66c:	48e5                	li	a7,25
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 674:	1101                	addi	sp,sp,-32
 676:	ec06                	sd	ra,24(sp)
 678:	e822                	sd	s0,16(sp)
 67a:	1000                	addi	s0,sp,32
 67c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 680:	4605                	li	a2,1
 682:	fef40593          	addi	a1,s0,-17
 686:	f4fff0ef          	jal	5d4 <write>
}
 68a:	60e2                	ld	ra,24(sp)
 68c:	6442                	ld	s0,16(sp)
 68e:	6105                	addi	sp,sp,32
 690:	8082                	ret

0000000000000692 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 692:	715d                	addi	sp,sp,-80
 694:	e486                	sd	ra,72(sp)
 696:	e0a2                	sd	s0,64(sp)
 698:	f84a                	sd	s2,48(sp)
 69a:	0880                	addi	s0,sp,80
 69c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 69e:	c299                	beqz	a3,6a4 <printint+0x12>
 6a0:	0805c363          	bltz	a1,726 <printint+0x94>
  neg = 0;
 6a4:	4881                	li	a7,0
 6a6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6aa:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 6ac:	00000517          	auipc	a0,0x0
 6b0:	55450513          	addi	a0,a0,1364 # c00 <digits>
 6b4:	883e                	mv	a6,a5
 6b6:	2785                	addiw	a5,a5,1
 6b8:	02c5f733          	remu	a4,a1,a2
 6bc:	972a                	add	a4,a4,a0
 6be:	00074703          	lbu	a4,0(a4)
 6c2:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 6c6:	872e                	mv	a4,a1
 6c8:	02c5d5b3          	divu	a1,a1,a2
 6cc:	0685                	addi	a3,a3,1
 6ce:	fec773e3          	bgeu	a4,a2,6b4 <printint+0x22>
  if (neg)
 6d2:	00088b63          	beqz	a7,6e8 <printint+0x56>
    buf[i++] = '-';
 6d6:	fd078793          	addi	a5,a5,-48
 6da:	97a2                	add	a5,a5,s0
 6dc:	02d00713          	li	a4,45
 6e0:	fee78423          	sb	a4,-24(a5)
 6e4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 6e8:	02f05a63          	blez	a5,71c <printint+0x8a>
 6ec:	fc26                	sd	s1,56(sp)
 6ee:	f44e                	sd	s3,40(sp)
 6f0:	fb840713          	addi	a4,s0,-72
 6f4:	00f704b3          	add	s1,a4,a5
 6f8:	fff70993          	addi	s3,a4,-1
 6fc:	99be                	add	s3,s3,a5
 6fe:	37fd                	addiw	a5,a5,-1
 700:	1782                	slli	a5,a5,0x20
 702:	9381                	srli	a5,a5,0x20
 704:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 708:	fff4c583          	lbu	a1,-1(s1)
 70c:	854a                	mv	a0,s2
 70e:	f67ff0ef          	jal	674 <putc>
  while (--i >= 0)
 712:	14fd                	addi	s1,s1,-1
 714:	ff349ae3          	bne	s1,s3,708 <printint+0x76>
 718:	74e2                	ld	s1,56(sp)
 71a:	79a2                	ld	s3,40(sp)
}
 71c:	60a6                	ld	ra,72(sp)
 71e:	6406                	ld	s0,64(sp)
 720:	7942                	ld	s2,48(sp)
 722:	6161                	addi	sp,sp,80
 724:	8082                	ret
    x = -xx;
 726:	40b005b3          	neg	a1,a1
    neg = 1;
 72a:	4885                	li	a7,1
    x = -xx;
 72c:	bfad                	j	6a6 <printint+0x14>

000000000000072e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 72e:	711d                	addi	sp,sp,-96
 730:	ec86                	sd	ra,88(sp)
 732:	e8a2                	sd	s0,80(sp)
 734:	e0ca                	sd	s2,64(sp)
 736:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 738:	0005c903          	lbu	s2,0(a1)
 73c:	28090663          	beqz	s2,9c8 <vprintf+0x29a>
 740:	e4a6                	sd	s1,72(sp)
 742:	fc4e                	sd	s3,56(sp)
 744:	f852                	sd	s4,48(sp)
 746:	f456                	sd	s5,40(sp)
 748:	f05a                	sd	s6,32(sp)
 74a:	ec5e                	sd	s7,24(sp)
 74c:	e862                	sd	s8,16(sp)
 74e:	e466                	sd	s9,8(sp)
 750:	8b2a                	mv	s6,a0
 752:	8a2e                	mv	s4,a1
 754:	8bb2                	mv	s7,a2
  state = 0;
 756:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 758:	4481                	li	s1,0
 75a:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 75c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 760:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 764:	06c00c93          	li	s9,108
 768:	a005                	j	788 <vprintf+0x5a>
        putc(fd, c0);
 76a:	85ca                	mv	a1,s2
 76c:	855a                	mv	a0,s6
 76e:	f07ff0ef          	jal	674 <putc>
 772:	a019                	j	778 <vprintf+0x4a>
    } else if (state == '%') {
 774:	03598263          	beq	s3,s5,798 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 778:	2485                	addiw	s1,s1,1
 77a:	8726                	mv	a4,s1
 77c:	009a07b3          	add	a5,s4,s1
 780:	0007c903          	lbu	s2,0(a5)
 784:	22090a63          	beqz	s2,9b8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 788:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 78c:	fe0994e3          	bnez	s3,774 <vprintf+0x46>
      if (c0 == '%') {
 790:	fd579de3          	bne	a5,s5,76a <vprintf+0x3c>
        state = '%';
 794:	89be                	mv	s3,a5
 796:	b7cd                	j	778 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 798:	00ea06b3          	add	a3,s4,a4
 79c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7a0:	8636                	mv	a2,a3
      if (c1)
 7a2:	c681                	beqz	a3,7aa <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 7a4:	9752                	add	a4,a4,s4
 7a6:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 7aa:	05878363          	beq	a5,s8,7f0 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 7ae:	05978d63          	beq	a5,s9,808 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 7b2:	07500713          	li	a4,117
 7b6:	0ee78763          	beq	a5,a4,8a4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 7ba:	07800713          	li	a4,120
 7be:	12e78963          	beq	a5,a4,8f0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 7c2:	07000713          	li	a4,112
 7c6:	14e78e63          	beq	a5,a4,922 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 7ca:	06300713          	li	a4,99
 7ce:	18e78e63          	beq	a5,a4,96a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 7d2:	07300713          	li	a4,115
 7d6:	1ae78463          	beq	a5,a4,97e <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 7da:	02500713          	li	a4,37
 7de:	04e79563          	bne	a5,a4,828 <vprintf+0xfa>
        putc(fd, '%');
 7e2:	02500593          	li	a1,37
 7e6:	855a                	mv	a0,s6
 7e8:	e8dff0ef          	jal	674 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b769                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 7f0:	008b8913          	addi	s2,s7,8
 7f4:	4685                	li	a3,1
 7f6:	4629                	li	a2,10
 7f8:	000ba583          	lw	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	e95ff0ef          	jal	692 <printint>
 802:	8bca                	mv	s7,s2
      state = 0;
 804:	4981                	li	s3,0
 806:	bf8d                	j	778 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 808:	06400793          	li	a5,100
 80c:	02f68963          	beq	a3,a5,83e <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 810:	06c00793          	li	a5,108
 814:	04f68263          	beq	a3,a5,858 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 818:	07500793          	li	a5,117
 81c:	0af68063          	beq	a3,a5,8bc <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 820:	07800793          	li	a5,120
 824:	0ef68263          	beq	a3,a5,908 <vprintf+0x1da>
        putc(fd, '%');
 828:	02500593          	li	a1,37
 82c:	855a                	mv	a0,s6
 82e:	e47ff0ef          	jal	674 <putc>
        putc(fd, c0);
 832:	85ca                	mv	a1,s2
 834:	855a                	mv	a0,s6
 836:	e3fff0ef          	jal	674 <putc>
      state = 0;
 83a:	4981                	li	s3,0
 83c:	bf35                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 83e:	008b8913          	addi	s2,s7,8
 842:	4685                	li	a3,1
 844:	4629                	li	a2,10
 846:	000bb583          	ld	a1,0(s7)
 84a:	855a                	mv	a0,s6
 84c:	e47ff0ef          	jal	692 <printint>
        i += 1;
 850:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 852:	8bca                	mv	s7,s2
      state = 0;
 854:	4981                	li	s3,0
        i += 1;
 856:	b70d                	j	778 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 858:	06400793          	li	a5,100
 85c:	02f60763          	beq	a2,a5,88a <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 860:	07500793          	li	a5,117
 864:	06f60963          	beq	a2,a5,8d6 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 868:	07800793          	li	a5,120
 86c:	faf61ee3          	bne	a2,a5,828 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 870:	008b8913          	addi	s2,s7,8
 874:	4681                	li	a3,0
 876:	4641                	li	a2,16
 878:	000bb583          	ld	a1,0(s7)
 87c:	855a                	mv	a0,s6
 87e:	e15ff0ef          	jal	692 <printint>
        i += 2;
 882:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 884:	8bca                	mv	s7,s2
      state = 0;
 886:	4981                	li	s3,0
        i += 2;
 888:	bdc5                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 88a:	008b8913          	addi	s2,s7,8
 88e:	4685                	li	a3,1
 890:	4629                	li	a2,10
 892:	000bb583          	ld	a1,0(s7)
 896:	855a                	mv	a0,s6
 898:	dfbff0ef          	jal	692 <printint>
        i += 2;
 89c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 89e:	8bca                	mv	s7,s2
      state = 0;
 8a0:	4981                	li	s3,0
        i += 2;
 8a2:	bdd9                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8a4:	008b8913          	addi	s2,s7,8
 8a8:	4681                	li	a3,0
 8aa:	4629                	li	a2,10
 8ac:	000be583          	lwu	a1,0(s7)
 8b0:	855a                	mv	a0,s6
 8b2:	de1ff0ef          	jal	692 <printint>
 8b6:	8bca                	mv	s7,s2
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	bd7d                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8bc:	008b8913          	addi	s2,s7,8
 8c0:	4681                	li	a3,0
 8c2:	4629                	li	a2,10
 8c4:	000bb583          	ld	a1,0(s7)
 8c8:	855a                	mv	a0,s6
 8ca:	dc9ff0ef          	jal	692 <printint>
        i += 1;
 8ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d0:	8bca                	mv	s7,s2
      state = 0;
 8d2:	4981                	li	s3,0
        i += 1;
 8d4:	b555                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d6:	008b8913          	addi	s2,s7,8
 8da:	4681                	li	a3,0
 8dc:	4629                	li	a2,10
 8de:	000bb583          	ld	a1,0(s7)
 8e2:	855a                	mv	a0,s6
 8e4:	dafff0ef          	jal	692 <printint>
        i += 2;
 8e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ea:	8bca                	mv	s7,s2
      state = 0;
 8ec:	4981                	li	s3,0
        i += 2;
 8ee:	b569                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8f0:	008b8913          	addi	s2,s7,8
 8f4:	4681                	li	a3,0
 8f6:	4641                	li	a2,16
 8f8:	000be583          	lwu	a1,0(s7)
 8fc:	855a                	mv	a0,s6
 8fe:	d95ff0ef          	jal	692 <printint>
 902:	8bca                	mv	s7,s2
      state = 0;
 904:	4981                	li	s3,0
 906:	bd8d                	j	778 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 908:	008b8913          	addi	s2,s7,8
 90c:	4681                	li	a3,0
 90e:	4641                	li	a2,16
 910:	000bb583          	ld	a1,0(s7)
 914:	855a                	mv	a0,s6
 916:	d7dff0ef          	jal	692 <printint>
        i += 1;
 91a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 91c:	8bca                	mv	s7,s2
      state = 0;
 91e:	4981                	li	s3,0
        i += 1;
 920:	bda1                	j	778 <vprintf+0x4a>
 922:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 924:	008b8d13          	addi	s10,s7,8
 928:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 92c:	03000593          	li	a1,48
 930:	855a                	mv	a0,s6
 932:	d43ff0ef          	jal	674 <putc>
  putc(fd, 'x');
 936:	07800593          	li	a1,120
 93a:	855a                	mv	a0,s6
 93c:	d39ff0ef          	jal	674 <putc>
 940:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 942:	00000b97          	auipc	s7,0x0
 946:	2beb8b93          	addi	s7,s7,702 # c00 <digits>
 94a:	03c9d793          	srli	a5,s3,0x3c
 94e:	97de                	add	a5,a5,s7
 950:	0007c583          	lbu	a1,0(a5)
 954:	855a                	mv	a0,s6
 956:	d1fff0ef          	jal	674 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 95a:	0992                	slli	s3,s3,0x4
 95c:	397d                	addiw	s2,s2,-1
 95e:	fe0916e3          	bnez	s2,94a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 962:	8bea                	mv	s7,s10
      state = 0;
 964:	4981                	li	s3,0
 966:	6d02                	ld	s10,0(sp)
 968:	bd01                	j	778 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 96a:	008b8913          	addi	s2,s7,8
 96e:	000bc583          	lbu	a1,0(s7)
 972:	855a                	mv	a0,s6
 974:	d01ff0ef          	jal	674 <putc>
 978:	8bca                	mv	s7,s2
      state = 0;
 97a:	4981                	li	s3,0
 97c:	bbf5                	j	778 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 97e:	008b8993          	addi	s3,s7,8
 982:	000bb903          	ld	s2,0(s7)
 986:	00090f63          	beqz	s2,9a4 <vprintf+0x276>
        for (; *s; s++)
 98a:	00094583          	lbu	a1,0(s2)
 98e:	c195                	beqz	a1,9b2 <vprintf+0x284>
          putc(fd, *s);
 990:	855a                	mv	a0,s6
 992:	ce3ff0ef          	jal	674 <putc>
        for (; *s; s++)
 996:	0905                	addi	s2,s2,1
 998:	00094583          	lbu	a1,0(s2)
 99c:	f9f5                	bnez	a1,990 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 99e:	8bce                	mv	s7,s3
      state = 0;
 9a0:	4981                	li	s3,0
 9a2:	bbd9                	j	778 <vprintf+0x4a>
          s = "(null)";
 9a4:	00000917          	auipc	s2,0x0
 9a8:	25490913          	addi	s2,s2,596 # bf8 <malloc+0x148>
        for (; *s; s++)
 9ac:	02800593          	li	a1,40
 9b0:	b7c5                	j	990 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 9b2:	8bce                	mv	s7,s3
      state = 0;
 9b4:	4981                	li	s3,0
 9b6:	b3c9                	j	778 <vprintf+0x4a>
 9b8:	64a6                	ld	s1,72(sp)
 9ba:	79e2                	ld	s3,56(sp)
 9bc:	7a42                	ld	s4,48(sp)
 9be:	7aa2                	ld	s5,40(sp)
 9c0:	7b02                	ld	s6,32(sp)
 9c2:	6be2                	ld	s7,24(sp)
 9c4:	6c42                	ld	s8,16(sp)
 9c6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9c8:	60e6                	ld	ra,88(sp)
 9ca:	6446                	ld	s0,80(sp)
 9cc:	6906                	ld	s2,64(sp)
 9ce:	6125                	addi	sp,sp,96
 9d0:	8082                	ret

00000000000009d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9d2:	715d                	addi	sp,sp,-80
 9d4:	ec06                	sd	ra,24(sp)
 9d6:	e822                	sd	s0,16(sp)
 9d8:	1000                	addi	s0,sp,32
 9da:	e010                	sd	a2,0(s0)
 9dc:	e414                	sd	a3,8(s0)
 9de:	e818                	sd	a4,16(s0)
 9e0:	ec1c                	sd	a5,24(s0)
 9e2:	03043023          	sd	a6,32(s0)
 9e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ee:	8622                	mv	a2,s0
 9f0:	d3fff0ef          	jal	72e <vprintf>
}
 9f4:	60e2                	ld	ra,24(sp)
 9f6:	6442                	ld	s0,16(sp)
 9f8:	6161                	addi	sp,sp,80
 9fa:	8082                	ret

00000000000009fc <printf>:

void
printf(const char *fmt, ...)
{
 9fc:	711d                	addi	sp,sp,-96
 9fe:	ec06                	sd	ra,24(sp)
 a00:	e822                	sd	s0,16(sp)
 a02:	1000                	addi	s0,sp,32
 a04:	e40c                	sd	a1,8(s0)
 a06:	e810                	sd	a2,16(s0)
 a08:	ec14                	sd	a3,24(s0)
 a0a:	f018                	sd	a4,32(s0)
 a0c:	f41c                	sd	a5,40(s0)
 a0e:	03043823          	sd	a6,48(s0)
 a12:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a16:	00840613          	addi	a2,s0,8
 a1a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a1e:	85aa                	mv	a1,a0
 a20:	4505                	li	a0,1
 a22:	d0dff0ef          	jal	72e <vprintf>
}
 a26:	60e2                	ld	ra,24(sp)
 a28:	6442                	ld	s0,16(sp)
 a2a:	6125                	addi	sp,sp,96
 a2c:	8082                	ret

0000000000000a2e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a2e:	1141                	addi	sp,sp,-16
 a30:	e422                	sd	s0,8(sp)
 a32:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 a34:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a38:	00001797          	auipc	a5,0x1
 a3c:	5c87b783          	ld	a5,1480(a5) # 2000 <freep>
 a40:	a02d                	j	a6a <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 a42:	4618                	lw	a4,8(a2)
 a44:	9f2d                	addw	a4,a4,a1
 a46:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a4a:	6398                	ld	a4,0(a5)
 a4c:	6310                	ld	a2,0(a4)
 a4e:	a83d                	j	a8c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 a50:	ff852703          	lw	a4,-8(a0)
 a54:	9f31                	addw	a4,a4,a2
 a56:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a58:	ff053683          	ld	a3,-16(a0)
 a5c:	a091                	j	aa0 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a5e:	6398                	ld	a4,0(a5)
 a60:	00e7e463          	bltu	a5,a4,a68 <free+0x3a>
 a64:	00e6ea63          	bltu	a3,a4,a78 <free+0x4a>
{
 a68:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a6a:	fed7fae3          	bgeu	a5,a3,a5e <free+0x30>
 a6e:	6398                	ld	a4,0(a5)
 a70:	00e6e463          	bltu	a3,a4,a78 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a74:	fee7eae3          	bltu	a5,a4,a68 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 a78:	ff852583          	lw	a1,-8(a0)
 a7c:	6390                	ld	a2,0(a5)
 a7e:	02059813          	slli	a6,a1,0x20
 a82:	01c85713          	srli	a4,a6,0x1c
 a86:	9736                	add	a4,a4,a3
 a88:	fae60de3          	beq	a2,a4,a42 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a8c:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 a90:	4790                	lw	a2,8(a5)
 a92:	02061593          	slli	a1,a2,0x20
 a96:	01c5d713          	srli	a4,a1,0x1c
 a9a:	973e                	add	a4,a4,a5
 a9c:	fae68ae3          	beq	a3,a4,a50 <free+0x22>
    p->s.ptr = bp->s.ptr;
 aa0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 aa2:	00001717          	auipc	a4,0x1
 aa6:	54f73f23          	sd	a5,1374(a4) # 2000 <freep>
}
 aaa:	6422                	ld	s0,8(sp)
 aac:	0141                	addi	sp,sp,16
 aae:	8082                	ret

0000000000000ab0 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 ab0:	7139                	addi	sp,sp,-64
 ab2:	fc06                	sd	ra,56(sp)
 ab4:	f822                	sd	s0,48(sp)
 ab6:	f426                	sd	s1,40(sp)
 ab8:	ec4e                	sd	s3,24(sp)
 aba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 abc:	02051493          	slli	s1,a0,0x20
 ac0:	9081                	srli	s1,s1,0x20
 ac2:	04bd                	addi	s1,s1,15
 ac4:	8091                	srli	s1,s1,0x4
 ac6:	0014899b          	addiw	s3,s1,1
 aca:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 acc:	00001517          	auipc	a0,0x1
 ad0:	53453503          	ld	a0,1332(a0) # 2000 <freep>
 ad4:	c915                	beqz	a0,b08 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 ad6:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 ad8:	4798                	lw	a4,8(a5)
 ada:	08977a63          	bgeu	a4,s1,b6e <malloc+0xbe>
 ade:	f04a                	sd	s2,32(sp)
 ae0:	e852                	sd	s4,16(sp)
 ae2:	e456                	sd	s5,8(sp)
 ae4:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 ae6:	8a4e                	mv	s4,s3
 ae8:	0009871b          	sext.w	a4,s3
 aec:	6685                	lui	a3,0x1
 aee:	00d77363          	bgeu	a4,a3,af4 <malloc+0x44>
 af2:	6a05                	lui	s4,0x1
 af4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 af8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 afc:	00001917          	auipc	s2,0x1
 b00:	50490913          	addi	s2,s2,1284 # 2000 <freep>
  if (p == SBRK_ERROR)
 b04:	5afd                	li	s5,-1
 b06:	a081                	j	b46 <malloc+0x96>
 b08:	f04a                	sd	s2,32(sp)
 b0a:	e852                	sd	s4,16(sp)
 b0c:	e456                	sd	s5,8(sp)
 b0e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b10:	00001797          	auipc	a5,0x1
 b14:	50078793          	addi	a5,a5,1280 # 2010 <base>
 b18:	00001717          	auipc	a4,0x1
 b1c:	4ef73423          	sd	a5,1256(a4) # 2000 <freep>
 b20:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b22:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 b26:	b7c1                	j	ae6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b28:	6398                	ld	a4,0(a5)
 b2a:	e118                	sd	a4,0(a0)
 b2c:	a8a9                	j	b86 <malloc+0xd6>
  hp->s.size = nu;
 b2e:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 b32:	0541                	addi	a0,a0,16
 b34:	efbff0ef          	jal	a2e <free>
  return freep;
 b38:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 b3c:	c12d                	beqz	a0,b9e <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 b3e:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 b40:	4798                	lw	a4,8(a5)
 b42:	02977263          	bgeu	a4,s1,b66 <malloc+0xb6>
    if (p == freep)
 b46:	00093703          	ld	a4,0(s2)
 b4a:	853e                	mv	a0,a5
 b4c:	fef719e3          	bne	a4,a5,b3e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b50:	8552                	mv	a0,s4
 b52:	a2fff0ef          	jal	580 <sbrk>
  if (p == SBRK_ERROR)
 b56:	fd551ce3          	bne	a0,s5,b2e <malloc+0x7e>
        return 0;
 b5a:	4501                	li	a0,0
 b5c:	7902                	ld	s2,32(sp)
 b5e:	6a42                	ld	s4,16(sp)
 b60:	6aa2                	ld	s5,8(sp)
 b62:	6b02                	ld	s6,0(sp)
 b64:	a03d                	j	b92 <malloc+0xe2>
 b66:	7902                	ld	s2,32(sp)
 b68:	6a42                	ld	s4,16(sp)
 b6a:	6aa2                	ld	s5,8(sp)
 b6c:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 b6e:	fae48de3          	beq	s1,a4,b28 <malloc+0x78>
        p->s.size -= nunits;
 b72:	4137073b          	subw	a4,a4,s3
 b76:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b78:	02071693          	slli	a3,a4,0x20
 b7c:	01c6d713          	srli	a4,a3,0x1c
 b80:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b82:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b86:	00001717          	auipc	a4,0x1
 b8a:	46a73d23          	sd	a0,1146(a4) # 2000 <freep>
      return (void *)(p + 1);
 b8e:	01078513          	addi	a0,a5,16
  }
}
 b92:	70e2                	ld	ra,56(sp)
 b94:	7442                	ld	s0,48(sp)
 b96:	74a2                	ld	s1,40(sp)
 b98:	69e2                	ld	s3,24(sp)
 b9a:	6121                	addi	sp,sp,64
 b9c:	8082                	ret
 b9e:	7902                	ld	s2,32(sp)
 ba0:	6a42                	ld	s4,16(sp)
 ba2:	6aa2                	ld	s5,8(sp)
 ba4:	6b02                	ld	s6,0(sp)
 ba6:	b7f5                	j	b92 <malloc+0xe2>
