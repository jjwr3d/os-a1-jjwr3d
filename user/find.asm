
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <match>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

// Recursive wildcard matcher matching instructions
int match(char *pattern, char *str) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e04a                	sd	s2,0(sp)
   8:	1000                	addi	s0,sp,32
   a:	892e                	mv	s2,a1
    if (*pattern == '\0' && *str == '\0') return 1;
   c:	00054783          	lbu	a5,0(a0)
  10:	eb91                	bnez	a5,24 <match+0x24>
  12:	0005c503          	lbu	a0,0(a1)
  16:	00153513          	seqz	a0,a0
        if (*str != '\0' && match(pattern, str + 1)) return 1;
        return 0;
    }
    if (*pattern == *str) return match(pattern + 1, str + 1);
    return 0;
}
  1a:	60e2                	ld	ra,24(sp)
  1c:	6442                	ld	s0,16(sp)
  1e:	6902                	ld	s2,0(sp)
  20:	6105                	addi	sp,sp,32
  22:	8082                	ret
  24:	e426                	sd	s1,8(sp)
  26:	84aa                	mv	s1,a0
    if (*pattern == '*') {
  28:	02a00713          	li	a4,42
  2c:	00e78963          	beq	a5,a4,3e <match+0x3e>
    if (*pattern == *str) return match(pattern + 1, str + 1);
  30:	0005c703          	lbu	a4,0(a1)
    return 0;
  34:	4501                	li	a0,0
    if (*pattern == *str) return match(pattern + 1, str + 1);
  36:	02f70663          	beq	a4,a5,62 <match+0x62>
  3a:	64a2                	ld	s1,8(sp)
  3c:	bff9                	j	1a <match+0x1a>
        if (match(pattern + 1, str)) return 1;
  3e:	0505                	addi	a0,a0,1
  40:	fc1ff0ef          	jal	0 <match>
  44:	e515                	bnez	a0,70 <match+0x70>
        if (*str != '\0' && match(pattern, str + 1)) return 1;
  46:	00094783          	lbu	a5,0(s2)
  4a:	e399                	bnez	a5,50 <match+0x50>
  4c:	64a2                	ld	s1,8(sp)
  4e:	b7f1                	j	1a <match+0x1a>
  50:	00190593          	addi	a1,s2,1
  54:	8526                	mv	a0,s1
  56:	fabff0ef          	jal	0 <match>
  5a:	00a03533          	snez	a0,a0
  5e:	64a2                	ld	s1,8(sp)
  60:	bf6d                	j	1a <match+0x1a>
    if (*pattern == *str) return match(pattern + 1, str + 1);
  62:	0585                	addi	a1,a1,1
  64:	00148513          	addi	a0,s1,1
  68:	f99ff0ef          	jal	0 <match>
  6c:	64a2                	ld	s1,8(sp)
  6e:	b775                	j	1a <match+0x1a>
        if (match(pattern + 1, str)) return 1;
  70:	4505                	li	a0,1
  72:	64a2                	ld	s1,8(sp)
  74:	b75d                	j	1a <match+0x1a>

0000000000000076 <find>:

void find(char *path, char *pattern, char type_filter) {
  76:	d9010113          	addi	sp,sp,-624
  7a:	26113423          	sd	ra,616(sp)
  7e:	26813023          	sd	s0,608(sp)
  82:	25213823          	sd	s2,592(sp)
  86:	25313423          	sd	s3,584(sp)
  8a:	25413023          	sd	s4,576(sp)
  8e:	1c80                	addi	s0,sp,624
  90:	892a                	mv	s2,a0
  92:	8a2e                	mv	s4,a1
  94:	89b2                	mv	s3,a2
    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;

    if ((fd = open(path, 0)) < 0) {
  96:	4581                	li	a1,0
  98:	552000ef          	jal	5ea <open>
  9c:	04054263          	bltz	a0,e0 <find+0x6a>
  a0:	24913c23          	sd	s1,600(sp)
  a4:	84aa                	mv	s1,a0
        fprintf(2, "find: cannot open %s\n", path);
        exit(1);
    }

    if (fstat(fd, &st) < 0) {
  a6:	d9840593          	addi	a1,s0,-616
  aa:	558000ef          	jal	602 <fstat>
  ae:	04054a63          	bltz	a0,102 <find+0x8c>
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        exit(1);
    }

    if (st.type != T_DIR) {
  b2:	da041703          	lh	a4,-608(s0)
  b6:	4785                	li	a5,1
  b8:	06f70763          	beq	a4,a5,126 <find+0xb0>
        close(fd);
  bc:	8526                	mv	a0,s1
  be:	514000ef          	jal	5d2 <close>
        return;
  c2:	25813483          	ld	s1,600(sp)
        if (st.type == T_DIR) {
            find(buf, pattern, type_filter);
        }
    }
    close(fd);
}
  c6:	26813083          	ld	ra,616(sp)
  ca:	26013403          	ld	s0,608(sp)
  ce:	25013903          	ld	s2,592(sp)
  d2:	24813983          	ld	s3,584(sp)
  d6:	24013a03          	ld	s4,576(sp)
  da:	27010113          	addi	sp,sp,624
  de:	8082                	ret
  e0:	24913c23          	sd	s1,600(sp)
  e4:	23513c23          	sd	s5,568(sp)
  e8:	23613823          	sd	s6,560(sp)
        fprintf(2, "find: cannot open %s\n", path);
  ec:	864a                	mv	a2,s2
  ee:	00001597          	auipc	a1,0x1
  f2:	ab258593          	addi	a1,a1,-1358 # ba0 <malloc+0xfa>
  f6:	4509                	li	a0,2
  f8:	0d1000ef          	jal	9c8 <fprintf>
        exit(1);
  fc:	4505                	li	a0,1
  fe:	4ac000ef          	jal	5aa <exit>
 102:	23513c23          	sd	s5,568(sp)
 106:	23613823          	sd	s6,560(sp)
        fprintf(2, "find: cannot stat %s\n", path);
 10a:	864a                	mv	a2,s2
 10c:	00001597          	auipc	a1,0x1
 110:	aac58593          	addi	a1,a1,-1364 # bb8 <malloc+0x112>
 114:	4509                	li	a0,2
 116:	0b3000ef          	jal	9c8 <fprintf>
        close(fd);
 11a:	8526                	mv	a0,s1
 11c:	4b6000ef          	jal	5d2 <close>
        exit(1);
 120:	4505                	li	a0,1
 122:	488000ef          	jal	5aa <exit>
    if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
 126:	854a                	mv	a0,s2
 128:	246000ef          	jal	36e <strlen>
 12c:	2541                	addiw	a0,a0,16
 12e:	20000793          	li	a5,512
 132:	0aa7ee63          	bltu	a5,a0,1ee <find+0x178>
 136:	23513c23          	sd	s5,568(sp)
 13a:	23613823          	sd	s6,560(sp)
    strcpy(buf, path);
 13e:	85ca                	mv	a1,s2
 140:	dc040513          	addi	a0,s0,-576
 144:	1e2000ef          	jal	326 <strcpy>
    p = buf + strlen(buf);
 148:	dc040513          	addi	a0,s0,-576
 14c:	222000ef          	jal	36e <strlen>
 150:	1502                	slli	a0,a0,0x20
 152:	9101                	srli	a0,a0,0x20
 154:	dc040793          	addi	a5,s0,-576
 158:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 15c:	00190b13          	addi	s6,s2,1
 160:	02f00793          	li	a5,47
 164:	00f90023          	sb	a5,0(s2)
        if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) continue;
 168:	00001a97          	auipc	s5,0x1
 16c:	a68a8a93          	addi	s5,s5,-1432 # bd0 <malloc+0x12a>
    while (read(fd, &de, sizeof(de)) == sizeof(de)) {
 170:	4641                	li	a2,16
 172:	db040593          	addi	a1,s0,-592
 176:	8526                	mv	a0,s1
 178:	44a000ef          	jal	5c2 <read>
 17c:	47c1                	li	a5,16
 17e:	0af51163          	bne	a0,a5,220 <find+0x1aa>
        if (de.inum == 0) continue;
 182:	db045783          	lhu	a5,-592(s0)
 186:	d7ed                	beqz	a5,170 <find+0xfa>
        if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) continue;
 188:	85d6                	mv	a1,s5
 18a:	db240513          	addi	a0,s0,-590
 18e:	1b4000ef          	jal	342 <strcmp>
 192:	dd79                	beqz	a0,170 <find+0xfa>
 194:	00001597          	auipc	a1,0x1
 198:	a4458593          	addi	a1,a1,-1468 # bd8 <malloc+0x132>
 19c:	db240513          	addi	a0,s0,-590
 1a0:	1a2000ef          	jal	342 <strcmp>
 1a4:	d571                	beqz	a0,170 <find+0xfa>
        memmove(p, de.name, DIRSIZ);
 1a6:	4639                	li	a2,14
 1a8:	db240593          	addi	a1,s0,-590
 1ac:	855a                	mv	a0,s6
 1ae:	322000ef          	jal	4d0 <memmove>
        p[DIRSIZ] = 0;
 1b2:	000907a3          	sb	zero,15(s2)
        if (stat(buf, &st) < 0) continue;
 1b6:	d9840593          	addi	a1,s0,-616
 1ba:	dc040513          	addi	a0,s0,-576
 1be:	290000ef          	jal	44e <stat>
 1c2:	fa0547e3          	bltz	a0,170 <find+0xfa>
        int name_matches = match(pattern, de.name);
 1c6:	db240593          	addi	a1,s0,-590
 1ca:	8552                	mv	a0,s4
 1cc:	e35ff0ef          	jal	0 <match>
        if (type_filter == 'f' && (st.type != T_FILE && st.type != T_DEVICE)) type_matches = 0;
 1d0:	06600793          	li	a5,102
 1d4:	02f98163          	beq	s3,a5,1f6 <find+0x180>
        if (type_filter == 'd' && st.type != T_DIR) type_matches = 0;
 1d8:	06400793          	li	a5,100
 1dc:	04f99a63          	bne	s3,a5,230 <find+0x1ba>
 1e0:	da041703          	lh	a4,-608(s0)
 1e4:	4785                	li	a5,1
 1e6:	f8f715e3          	bne	a4,a5,170 <find+0xfa>
        if (name_matches && type_matches) {
 1ea:	c505                	beqz	a0,212 <find+0x19c>
 1ec:	a099                	j	232 <find+0x1bc>
        close(fd);
 1ee:	8526                	mv	a0,s1
 1f0:	3e2000ef          	jal	5d2 <close>
        return;
 1f4:	b5f9                	j	c2 <find+0x4c>
        if (name_matches && type_matches) {
 1f6:	c909                	beqz	a0,208 <find+0x192>
        if (type_filter == 'f' && (st.type != T_FILE && st.type != T_DEVICE)) type_matches = 0;
 1f8:	da045783          	lhu	a5,-608(s0)
 1fc:	37f9                	addiw	a5,a5,-2
        if (name_matches && type_matches) {
 1fe:	17c2                	slli	a5,a5,0x30
 200:	93c1                	srli	a5,a5,0x30
 202:	4705                	li	a4,1
 204:	02f77763          	bgeu	a4,a5,232 <find+0x1bc>
        if (st.type == T_DIR) {
 208:	da041703          	lh	a4,-608(s0)
 20c:	4785                	li	a5,1
 20e:	f6f711e3          	bne	a4,a5,170 <find+0xfa>
            find(buf, pattern, type_filter);
 212:	864e                	mv	a2,s3
 214:	85d2                	mv	a1,s4
 216:	dc040513          	addi	a0,s0,-576
 21a:	e5dff0ef          	jal	76 <find>
 21e:	bf89                	j	170 <find+0xfa>
    close(fd);
 220:	8526                	mv	a0,s1
 222:	3b0000ef          	jal	5d2 <close>
 226:	23813a83          	ld	s5,568(sp)
 22a:	23013b03          	ld	s6,560(sp)
 22e:	bd51                	j	c2 <find+0x4c>
        if (name_matches && type_matches) {
 230:	dd61                	beqz	a0,208 <find+0x192>
            printf("%s\n", buf);
 232:	dc040593          	addi	a1,s0,-576
 236:	00001517          	auipc	a0,0x1
 23a:	9aa50513          	addi	a0,a0,-1622 # be0 <malloc+0x13a>
 23e:	7b4000ef          	jal	9f2 <printf>
 242:	b7d9                	j	208 <find+0x192>

0000000000000244 <main>:

int main(int argc, char *argv[]) {
 244:	711d                	addi	sp,sp,-96
 246:	ec86                	sd	ra,88(sp)
 248:	e8a2                	sd	s0,80(sp)
 24a:	1080                	addi	s0,sp,96
    if (argc < 3) {
 24c:	4789                	li	a5,2
 24e:	04a7d263          	bge	a5,a0,292 <main+0x4e>
 252:	e4a6                	sd	s1,72(sp)
 254:	e0ca                	sd	s2,64(sp)
 256:	fc4e                	sd	s3,56(sp)
 258:	f852                	sd	s4,48(sp)
 25a:	f456                	sd	s5,40(sp)
 25c:	f05a                	sd	s6,32(sp)
 25e:	ec5e                	sd	s7,24(sp)
 260:	e862                	sd	s8,16(sp)
 262:	e466                	sd	s9,8(sp)
 264:	e06a                	sd	s10,0(sp)
 266:	89aa                	mv	s3,a0
 268:	8a2e                	mv	s4,a1
        fprintf(2, "usage: find <dir> <pattern> [-type f|d]\n");
        exit(1);
    }

    char *dir = argv[1];
 26a:	0085bc03          	ld	s8,8(a1)
    char *pattern = argv[2];
 26e:	0105bc83          	ld	s9,16(a1)
    char type_filter = 0; // 0 means no filter

    for (int i = 3; i < argc; i++) {
 272:	478d                	li	a5,3
 274:	08a7df63          	bge	a5,a0,312 <main+0xce>
 278:	448d                	li	s1,3
    char type_filter = 0; // 0 means no filter
 27a:	4b01                	li	s6,0
        if (strcmp(argv[i], "-type") == 0 && i + 1 < argc) {
 27c:	00001a97          	auipc	s5,0x1
 280:	99ca8a93          	addi	s5,s5,-1636 # c18 <malloc+0x172>
            if (strcmp(argv[i+1], "f") == 0) type_filter = 'f';
 284:	00001b97          	auipc	s7,0x1
 288:	99cb8b93          	addi	s7,s7,-1636 # c20 <malloc+0x17a>
 28c:	06600d13          	li	s10,102
 290:	a089                	j	2d2 <main+0x8e>
 292:	e4a6                	sd	s1,72(sp)
 294:	e0ca                	sd	s2,64(sp)
 296:	fc4e                	sd	s3,56(sp)
 298:	f852                	sd	s4,48(sp)
 29a:	f456                	sd	s5,40(sp)
 29c:	f05a                	sd	s6,32(sp)
 29e:	ec5e                	sd	s7,24(sp)
 2a0:	e862                	sd	s8,16(sp)
 2a2:	e466                	sd	s9,8(sp)
 2a4:	e06a                	sd	s10,0(sp)
        fprintf(2, "usage: find <dir> <pattern> [-type f|d]\n");
 2a6:	00001597          	auipc	a1,0x1
 2aa:	94258593          	addi	a1,a1,-1726 # be8 <malloc+0x142>
 2ae:	4509                	li	a0,2
 2b0:	718000ef          	jal	9c8 <fprintf>
        exit(1);
 2b4:	4505                	li	a0,1
 2b6:	2f4000ef          	jal	5aa <exit>
            if (strcmp(argv[i+1], "f") == 0) type_filter = 'f';
 2ba:	0921                	addi	s2,s2,8
 2bc:	9952                	add	s2,s2,s4
 2be:	85de                	mv	a1,s7
 2c0:	00093503          	ld	a0,0(s2)
 2c4:	07e000ef          	jal	342 <strcmp>
 2c8:	e90d                	bnez	a0,2fa <main+0xb6>
 2ca:	8b6a                	mv	s6,s10
    for (int i = 3; i < argc; i++) {
 2cc:	2485                	addiw	s1,s1,1
 2ce:	0134de63          	bge	s1,s3,2ea <main+0xa6>
        if (strcmp(argv[i], "-type") == 0 && i + 1 < argc) {
 2d2:	00349913          	slli	s2,s1,0x3
 2d6:	012a07b3          	add	a5,s4,s2
 2da:	85d6                	mv	a1,s5
 2dc:	6388                	ld	a0,0(a5)
 2de:	064000ef          	jal	342 <strcmp>
 2e2:	f56d                	bnez	a0,2cc <main+0x88>
 2e4:	2485                	addiw	s1,s1,1
 2e6:	fd34cae3          	blt	s1,s3,2ba <main+0x76>
            else if (strcmp(argv[i+1], "d") == 0) type_filter = 'd';
            i++;
        }
    }

    find(dir, pattern, type_filter);
 2ea:	865a                	mv	a2,s6
 2ec:	85e6                	mv	a1,s9
 2ee:	8562                	mv	a0,s8
 2f0:	d87ff0ef          	jal	76 <find>
    exit(0);
 2f4:	4501                	li	a0,0
 2f6:	2b4000ef          	jal	5aa <exit>
            else if (strcmp(argv[i+1], "d") == 0) type_filter = 'd';
 2fa:	00001597          	auipc	a1,0x1
 2fe:	92e58593          	addi	a1,a1,-1746 # c28 <malloc+0x182>
 302:	00093503          	ld	a0,0(s2)
 306:	03c000ef          	jal	342 <strcmp>
 30a:	f169                	bnez	a0,2cc <main+0x88>
 30c:	06400b13          	li	s6,100
 310:	bf75                	j	2cc <main+0x88>
    char type_filter = 0; // 0 means no filter
 312:	4b01                	li	s6,0
 314:	bfd9                	j	2ea <main+0xa6>

0000000000000316 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 31e:	f27ff0ef          	jal	244 <main>
  exit(r);
 322:	288000ef          	jal	5aa <exit>

0000000000000326 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 32c:	87aa                	mv	a5,a0
 32e:	0585                	addi	a1,a1,1
 330:	0785                	addi	a5,a5,1
 332:	fff5c703          	lbu	a4,-1(a1)
 336:	fee78fa3          	sb	a4,-1(a5)
 33a:	fb75                	bnez	a4,32e <strcpy+0x8>
    ;
  return os;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret

0000000000000342 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 348:	00054783          	lbu	a5,0(a0)
 34c:	cb91                	beqz	a5,360 <strcmp+0x1e>
 34e:	0005c703          	lbu	a4,0(a1)
 352:	00f71763          	bne	a4,a5,360 <strcmp+0x1e>
    p++, q++;
 356:	0505                	addi	a0,a0,1
 358:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 35a:	00054783          	lbu	a5,0(a0)
 35e:	fbe5                	bnez	a5,34e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 360:	0005c503          	lbu	a0,0(a1)
}
 364:	40a7853b          	subw	a0,a5,a0
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret

000000000000036e <strlen>:

uint
strlen(const char *s)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 374:	00054783          	lbu	a5,0(a0)
 378:	cf91                	beqz	a5,394 <strlen+0x26>
 37a:	0505                	addi	a0,a0,1
 37c:	87aa                	mv	a5,a0
 37e:	86be                	mv	a3,a5
 380:	0785                	addi	a5,a5,1
 382:	fff7c703          	lbu	a4,-1(a5)
 386:	ff65                	bnez	a4,37e <strlen+0x10>
 388:	40a6853b          	subw	a0,a3,a0
 38c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret
  for (n = 0; s[n]; n++)
 394:	4501                	li	a0,0
 396:	bfe5                	j	38e <strlen+0x20>

0000000000000398 <memset>:

void *
memset(void *dst, int c, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 39e:	ca19                	beqz	a2,3b4 <memset+0x1c>
 3a0:	87aa                	mv	a5,a0
 3a2:	1602                	slli	a2,a2,0x20
 3a4:	9201                	srli	a2,a2,0x20
 3a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3aa:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 3ae:	0785                	addi	a5,a5,1
 3b0:	fee79de3          	bne	a5,a4,3aa <memset+0x12>
  }
  return dst;
}
 3b4:	6422                	ld	s0,8(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret

00000000000003ba <strchr>:

char *
strchr(const char *s, char c)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  for (; *s; s++)
 3c0:	00054783          	lbu	a5,0(a0)
 3c4:	cb99                	beqz	a5,3da <strchr+0x20>
    if (*s == c)
 3c6:	00f58763          	beq	a1,a5,3d4 <strchr+0x1a>
  for (; *s; s++)
 3ca:	0505                	addi	a0,a0,1
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	fbfd                	bnez	a5,3c6 <strchr+0xc>
      return (char *)s;
  return 0;
 3d2:	4501                	li	a0,0
}
 3d4:	6422                	ld	s0,8(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret
  return 0;
 3da:	4501                	li	a0,0
 3dc:	bfe5                	j	3d4 <strchr+0x1a>

00000000000003de <gets>:

char *
gets(char *buf, int max)
{
 3de:	711d                	addi	sp,sp,-96
 3e0:	ec86                	sd	ra,88(sp)
 3e2:	e8a2                	sd	s0,80(sp)
 3e4:	e4a6                	sd	s1,72(sp)
 3e6:	e0ca                	sd	s2,64(sp)
 3e8:	fc4e                	sd	s3,56(sp)
 3ea:	f852                	sd	s4,48(sp)
 3ec:	f456                	sd	s5,40(sp)
 3ee:	f05a                	sd	s6,32(sp)
 3f0:	ec5e                	sd	s7,24(sp)
 3f2:	1080                	addi	s0,sp,96
 3f4:	8baa                	mv	s7,a0
 3f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 3f8:	892a                	mv	s2,a0
 3fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 3fc:	4aa9                	li	s5,10
 3fe:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 400:	89a6                	mv	s3,s1
 402:	2485                	addiw	s1,s1,1
 404:	0344d663          	bge	s1,s4,430 <gets+0x52>
    cc = read(0, &c, 1);
 408:	4605                	li	a2,1
 40a:	faf40593          	addi	a1,s0,-81
 40e:	4501                	li	a0,0
 410:	1b2000ef          	jal	5c2 <read>
    if (cc < 1)
 414:	00a05e63          	blez	a0,430 <gets+0x52>
    buf[i++] = c;
 418:	faf44783          	lbu	a5,-81(s0)
 41c:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 420:	01578763          	beq	a5,s5,42e <gets+0x50>
 424:	0905                	addi	s2,s2,1
 426:	fd679de3          	bne	a5,s6,400 <gets+0x22>
    buf[i++] = c;
 42a:	89a6                	mv	s3,s1
 42c:	a011                	j	430 <gets+0x52>
 42e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 430:	99de                	add	s3,s3,s7
 432:	00098023          	sb	zero,0(s3)
  return buf;
}
 436:	855e                	mv	a0,s7
 438:	60e6                	ld	ra,88(sp)
 43a:	6446                	ld	s0,80(sp)
 43c:	64a6                	ld	s1,72(sp)
 43e:	6906                	ld	s2,64(sp)
 440:	79e2                	ld	s3,56(sp)
 442:	7a42                	ld	s4,48(sp)
 444:	7aa2                	ld	s5,40(sp)
 446:	7b02                	ld	s6,32(sp)
 448:	6be2                	ld	s7,24(sp)
 44a:	6125                	addi	sp,sp,96
 44c:	8082                	ret

000000000000044e <stat>:

int
stat(const char *n, struct stat *st)
{
 44e:	1101                	addi	sp,sp,-32
 450:	ec06                	sd	ra,24(sp)
 452:	e822                	sd	s0,16(sp)
 454:	e04a                	sd	s2,0(sp)
 456:	1000                	addi	s0,sp,32
 458:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 45a:	4581                	li	a1,0
 45c:	18e000ef          	jal	5ea <open>
  if (fd < 0)
 460:	02054263          	bltz	a0,484 <stat+0x36>
 464:	e426                	sd	s1,8(sp)
 466:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 468:	85ca                	mv	a1,s2
 46a:	198000ef          	jal	602 <fstat>
 46e:	892a                	mv	s2,a0
  close(fd);
 470:	8526                	mv	a0,s1
 472:	160000ef          	jal	5d2 <close>
  return r;
 476:	64a2                	ld	s1,8(sp)
}
 478:	854a                	mv	a0,s2
 47a:	60e2                	ld	ra,24(sp)
 47c:	6442                	ld	s0,16(sp)
 47e:	6902                	ld	s2,0(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret
    return -1;
 484:	597d                	li	s2,-1
 486:	bfcd                	j	478 <stat+0x2a>

0000000000000488 <atoi>:

int
atoi(const char *s)
{
 488:	1141                	addi	sp,sp,-16
 48a:	e422                	sd	s0,8(sp)
 48c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 48e:	00054683          	lbu	a3,0(a0)
 492:	fd06879b          	addiw	a5,a3,-48
 496:	0ff7f793          	zext.b	a5,a5
 49a:	4625                	li	a2,9
 49c:	02f66863          	bltu	a2,a5,4cc <atoi+0x44>
 4a0:	872a                	mv	a4,a0
  n = 0;
 4a2:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 4a4:	0705                	addi	a4,a4,1
 4a6:	0025179b          	slliw	a5,a0,0x2
 4aa:	9fa9                	addw	a5,a5,a0
 4ac:	0017979b          	slliw	a5,a5,0x1
 4b0:	9fb5                	addw	a5,a5,a3
 4b2:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 4b6:	00074683          	lbu	a3,0(a4)
 4ba:	fd06879b          	addiw	a5,a3,-48
 4be:	0ff7f793          	zext.b	a5,a5
 4c2:	fef671e3          	bgeu	a2,a5,4a4 <atoi+0x1c>
  return n;
}
 4c6:	6422                	ld	s0,8(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret
  n = 0;
 4cc:	4501                	li	a0,0
 4ce:	bfe5                	j	4c6 <atoi+0x3e>

00000000000004d0 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 4d0:	1141                	addi	sp,sp,-16
 4d2:	e422                	sd	s0,8(sp)
 4d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4d6:	02b57463          	bgeu	a0,a1,4fe <memmove+0x2e>
    while (n-- > 0)
 4da:	00c05f63          	blez	a2,4f8 <memmove+0x28>
 4de:	1602                	slli	a2,a2,0x20
 4e0:	9201                	srli	a2,a2,0x20
 4e2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 4e8:	0585                	addi	a1,a1,1
 4ea:	0705                	addi	a4,a4,1
 4ec:	fff5c683          	lbu	a3,-1(a1)
 4f0:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 4f4:	fef71ae3          	bne	a4,a5,4e8 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4f8:	6422                	ld	s0,8(sp)
 4fa:	0141                	addi	sp,sp,16
 4fc:	8082                	ret
    dst += n;
 4fe:	00c50733          	add	a4,a0,a2
    src += n;
 502:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 504:	fec05ae3          	blez	a2,4f8 <memmove+0x28>
 508:	fff6079b          	addiw	a5,a2,-1
 50c:	1782                	slli	a5,a5,0x20
 50e:	9381                	srli	a5,a5,0x20
 510:	fff7c793          	not	a5,a5
 514:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 516:	15fd                	addi	a1,a1,-1
 518:	177d                	addi	a4,a4,-1
 51a:	0005c683          	lbu	a3,0(a1)
 51e:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 522:	fee79ae3          	bne	a5,a4,516 <memmove+0x46>
 526:	bfc9                	j	4f8 <memmove+0x28>

0000000000000528 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 528:	1141                	addi	sp,sp,-16
 52a:	e422                	sd	s0,8(sp)
 52c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 52e:	ca05                	beqz	a2,55e <memcmp+0x36>
 530:	fff6069b          	addiw	a3,a2,-1
 534:	1682                	slli	a3,a3,0x20
 536:	9281                	srli	a3,a3,0x20
 538:	0685                	addi	a3,a3,1
 53a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 53c:	00054783          	lbu	a5,0(a0)
 540:	0005c703          	lbu	a4,0(a1)
 544:	00e79863          	bne	a5,a4,554 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 548:	0505                	addi	a0,a0,1
    p2++;
 54a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 54c:	fed518e3          	bne	a0,a3,53c <memcmp+0x14>
  }
  return 0;
 550:	4501                	li	a0,0
 552:	a019                	j	558 <memcmp+0x30>
      return *p1 - *p2;
 554:	40e7853b          	subw	a0,a5,a4
}
 558:	6422                	ld	s0,8(sp)
 55a:	0141                	addi	sp,sp,16
 55c:	8082                	ret
  return 0;
 55e:	4501                	li	a0,0
 560:	bfe5                	j	558 <memcmp+0x30>

0000000000000562 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 562:	1141                	addi	sp,sp,-16
 564:	e406                	sd	ra,8(sp)
 566:	e022                	sd	s0,0(sp)
 568:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 56a:	f67ff0ef          	jal	4d0 <memmove>
}
 56e:	60a2                	ld	ra,8(sp)
 570:	6402                	ld	s0,0(sp)
 572:	0141                	addi	sp,sp,16
 574:	8082                	ret

0000000000000576 <sbrk>:

char *
sbrk(int n)
{
 576:	1141                	addi	sp,sp,-16
 578:	e406                	sd	ra,8(sp)
 57a:	e022                	sd	s0,0(sp)
 57c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 57e:	4585                	li	a1,1
 580:	0b2000ef          	jal	632 <sys_sbrk>
}
 584:	60a2                	ld	ra,8(sp)
 586:	6402                	ld	s0,0(sp)
 588:	0141                	addi	sp,sp,16
 58a:	8082                	ret

000000000000058c <sbrklazy>:

char *
sbrklazy(int n)
{
 58c:	1141                	addi	sp,sp,-16
 58e:	e406                	sd	ra,8(sp)
 590:	e022                	sd	s0,0(sp)
 592:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 594:	4589                	li	a1,2
 596:	09c000ef          	jal	632 <sys_sbrk>
}
 59a:	60a2                	ld	ra,8(sp)
 59c:	6402                	ld	s0,0(sp)
 59e:	0141                	addi	sp,sp,16
 5a0:	8082                	ret

00000000000005a2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5a2:	4885                	li	a7,1
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <exit>:
.global exit
exit:
 li a7, SYS_exit
 5aa:	4889                	li	a7,2
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b2:	488d                	li	a7,3
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ba:	4891                	li	a7,4
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <read>:
.global read
read:
 li a7, SYS_read
 5c2:	4895                	li	a7,5
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <write>:
.global write
write:
 li a7, SYS_write
 5ca:	48c1                	li	a7,16
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <close>:
.global close
close:
 li a7, SYS_close
 5d2:	48d5                	li	a7,21
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <kill>:
.global kill
kill:
 li a7, SYS_kill
 5da:	4899                	li	a7,6
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e2:	489d                	li	a7,7
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <open>:
.global open
open:
 li a7, SYS_open
 5ea:	48bd                	li	a7,15
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f2:	48c5                	li	a7,17
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5fa:	48c9                	li	a7,18
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 602:	48a1                	li	a7,8
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <link>:
.global link
link:
 li a7, SYS_link
 60a:	48cd                	li	a7,19
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 612:	48d1                	li	a7,20
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 61a:	48a5                	li	a7,9
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <dup>:
.global dup
dup:
 li a7, SYS_dup
 622:	48a9                	li	a7,10
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 62a:	48ad                	li	a7,11
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 632:	48b1                	li	a7,12
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <pause>:
.global pause
pause:
 li a7, SYS_pause
 63a:	48b5                	li	a7,13
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 642:	48b9                	li	a7,14
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <sync>:
.global sync
sync:
 li a7, SYS_sync
 64a:	48d9                	li	a7,22
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <trace>:
.global trace
trace:
 li a7, SYS_trace
 652:	48dd                	li	a7,23
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 65a:	48e1                	li	a7,24
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 662:	48e5                	li	a7,25
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 66a:	1101                	addi	sp,sp,-32
 66c:	ec06                	sd	ra,24(sp)
 66e:	e822                	sd	s0,16(sp)
 670:	1000                	addi	s0,sp,32
 672:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 676:	4605                	li	a2,1
 678:	fef40593          	addi	a1,s0,-17
 67c:	f4fff0ef          	jal	5ca <write>
}
 680:	60e2                	ld	ra,24(sp)
 682:	6442                	ld	s0,16(sp)
 684:	6105                	addi	sp,sp,32
 686:	8082                	ret

0000000000000688 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 688:	715d                	addi	sp,sp,-80
 68a:	e486                	sd	ra,72(sp)
 68c:	e0a2                	sd	s0,64(sp)
 68e:	f84a                	sd	s2,48(sp)
 690:	0880                	addi	s0,sp,80
 692:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 694:	c299                	beqz	a3,69a <printint+0x12>
 696:	0805c363          	bltz	a1,71c <printint+0x94>
  neg = 0;
 69a:	4881                	li	a7,0
 69c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6a0:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 6a2:	00000517          	auipc	a0,0x0
 6a6:	59650513          	addi	a0,a0,1430 # c38 <digits>
 6aa:	883e                	mv	a6,a5
 6ac:	2785                	addiw	a5,a5,1
 6ae:	02c5f733          	remu	a4,a1,a2
 6b2:	972a                	add	a4,a4,a0
 6b4:	00074703          	lbu	a4,0(a4)
 6b8:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 6bc:	872e                	mv	a4,a1
 6be:	02c5d5b3          	divu	a1,a1,a2
 6c2:	0685                	addi	a3,a3,1
 6c4:	fec773e3          	bgeu	a4,a2,6aa <printint+0x22>
  if (neg)
 6c8:	00088b63          	beqz	a7,6de <printint+0x56>
    buf[i++] = '-';
 6cc:	fd078793          	addi	a5,a5,-48
 6d0:	97a2                	add	a5,a5,s0
 6d2:	02d00713          	li	a4,45
 6d6:	fee78423          	sb	a4,-24(a5)
 6da:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 6de:	02f05a63          	blez	a5,712 <printint+0x8a>
 6e2:	fc26                	sd	s1,56(sp)
 6e4:	f44e                	sd	s3,40(sp)
 6e6:	fb840713          	addi	a4,s0,-72
 6ea:	00f704b3          	add	s1,a4,a5
 6ee:	fff70993          	addi	s3,a4,-1
 6f2:	99be                	add	s3,s3,a5
 6f4:	37fd                	addiw	a5,a5,-1
 6f6:	1782                	slli	a5,a5,0x20
 6f8:	9381                	srli	a5,a5,0x20
 6fa:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 6fe:	fff4c583          	lbu	a1,-1(s1)
 702:	854a                	mv	a0,s2
 704:	f67ff0ef          	jal	66a <putc>
  while (--i >= 0)
 708:	14fd                	addi	s1,s1,-1
 70a:	ff349ae3          	bne	s1,s3,6fe <printint+0x76>
 70e:	74e2                	ld	s1,56(sp)
 710:	79a2                	ld	s3,40(sp)
}
 712:	60a6                	ld	ra,72(sp)
 714:	6406                	ld	s0,64(sp)
 716:	7942                	ld	s2,48(sp)
 718:	6161                	addi	sp,sp,80
 71a:	8082                	ret
    x = -xx;
 71c:	40b005b3          	neg	a1,a1
    neg = 1;
 720:	4885                	li	a7,1
    x = -xx;
 722:	bfad                	j	69c <printint+0x14>

0000000000000724 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 724:	711d                	addi	sp,sp,-96
 726:	ec86                	sd	ra,88(sp)
 728:	e8a2                	sd	s0,80(sp)
 72a:	e0ca                	sd	s2,64(sp)
 72c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 72e:	0005c903          	lbu	s2,0(a1)
 732:	28090663          	beqz	s2,9be <vprintf+0x29a>
 736:	e4a6                	sd	s1,72(sp)
 738:	fc4e                	sd	s3,56(sp)
 73a:	f852                	sd	s4,48(sp)
 73c:	f456                	sd	s5,40(sp)
 73e:	f05a                	sd	s6,32(sp)
 740:	ec5e                	sd	s7,24(sp)
 742:	e862                	sd	s8,16(sp)
 744:	e466                	sd	s9,8(sp)
 746:	8b2a                	mv	s6,a0
 748:	8a2e                	mv	s4,a1
 74a:	8bb2                	mv	s7,a2
  state = 0;
 74c:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 74e:	4481                	li	s1,0
 750:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 752:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 756:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 75a:	06c00c93          	li	s9,108
 75e:	a005                	j	77e <vprintf+0x5a>
        putc(fd, c0);
 760:	85ca                	mv	a1,s2
 762:	855a                	mv	a0,s6
 764:	f07ff0ef          	jal	66a <putc>
 768:	a019                	j	76e <vprintf+0x4a>
    } else if (state == '%') {
 76a:	03598263          	beq	s3,s5,78e <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 76e:	2485                	addiw	s1,s1,1
 770:	8726                	mv	a4,s1
 772:	009a07b3          	add	a5,s4,s1
 776:	0007c903          	lbu	s2,0(a5)
 77a:	22090a63          	beqz	s2,9ae <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 77e:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 782:	fe0994e3          	bnez	s3,76a <vprintf+0x46>
      if (c0 == '%') {
 786:	fd579de3          	bne	a5,s5,760 <vprintf+0x3c>
        state = '%';
 78a:	89be                	mv	s3,a5
 78c:	b7cd                	j	76e <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 78e:	00ea06b3          	add	a3,s4,a4
 792:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 796:	8636                	mv	a2,a3
      if (c1)
 798:	c681                	beqz	a3,7a0 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 79a:	9752                	add	a4,a4,s4
 79c:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 7a0:	05878363          	beq	a5,s8,7e6 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 7a4:	05978d63          	beq	a5,s9,7fe <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 7a8:	07500713          	li	a4,117
 7ac:	0ee78763          	beq	a5,a4,89a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 7b0:	07800713          	li	a4,120
 7b4:	12e78963          	beq	a5,a4,8e6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 7b8:	07000713          	li	a4,112
 7bc:	14e78e63          	beq	a5,a4,918 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 7c0:	06300713          	li	a4,99
 7c4:	18e78e63          	beq	a5,a4,960 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 7c8:	07300713          	li	a4,115
 7cc:	1ae78463          	beq	a5,a4,974 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 7d0:	02500713          	li	a4,37
 7d4:	04e79563          	bne	a5,a4,81e <vprintf+0xfa>
        putc(fd, '%');
 7d8:	02500593          	li	a1,37
 7dc:	855a                	mv	a0,s6
 7de:	e8dff0ef          	jal	66a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	b769                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 7e6:	008b8913          	addi	s2,s7,8
 7ea:	4685                	li	a3,1
 7ec:	4629                	li	a2,10
 7ee:	000ba583          	lw	a1,0(s7)
 7f2:	855a                	mv	a0,s6
 7f4:	e95ff0ef          	jal	688 <printint>
 7f8:	8bca                	mv	s7,s2
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	bf8d                	j	76e <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 7fe:	06400793          	li	a5,100
 802:	02f68963          	beq	a3,a5,834 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 806:	06c00793          	li	a5,108
 80a:	04f68263          	beq	a3,a5,84e <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 80e:	07500793          	li	a5,117
 812:	0af68063          	beq	a3,a5,8b2 <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 816:	07800793          	li	a5,120
 81a:	0ef68263          	beq	a3,a5,8fe <vprintf+0x1da>
        putc(fd, '%');
 81e:	02500593          	li	a1,37
 822:	855a                	mv	a0,s6
 824:	e47ff0ef          	jal	66a <putc>
        putc(fd, c0);
 828:	85ca                	mv	a1,s2
 82a:	855a                	mv	a0,s6
 82c:	e3fff0ef          	jal	66a <putc>
      state = 0;
 830:	4981                	li	s3,0
 832:	bf35                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 834:	008b8913          	addi	s2,s7,8
 838:	4685                	li	a3,1
 83a:	4629                	li	a2,10
 83c:	000bb583          	ld	a1,0(s7)
 840:	855a                	mv	a0,s6
 842:	e47ff0ef          	jal	688 <printint>
        i += 1;
 846:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 848:	8bca                	mv	s7,s2
      state = 0;
 84a:	4981                	li	s3,0
        i += 1;
 84c:	b70d                	j	76e <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 84e:	06400793          	li	a5,100
 852:	02f60763          	beq	a2,a5,880 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 856:	07500793          	li	a5,117
 85a:	06f60963          	beq	a2,a5,8cc <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 85e:	07800793          	li	a5,120
 862:	faf61ee3          	bne	a2,a5,81e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 866:	008b8913          	addi	s2,s7,8
 86a:	4681                	li	a3,0
 86c:	4641                	li	a2,16
 86e:	000bb583          	ld	a1,0(s7)
 872:	855a                	mv	a0,s6
 874:	e15ff0ef          	jal	688 <printint>
        i += 2;
 878:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 87a:	8bca                	mv	s7,s2
      state = 0;
 87c:	4981                	li	s3,0
        i += 2;
 87e:	bdc5                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 880:	008b8913          	addi	s2,s7,8
 884:	4685                	li	a3,1
 886:	4629                	li	a2,10
 888:	000bb583          	ld	a1,0(s7)
 88c:	855a                	mv	a0,s6
 88e:	dfbff0ef          	jal	688 <printint>
        i += 2;
 892:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 894:	8bca                	mv	s7,s2
      state = 0;
 896:	4981                	li	s3,0
        i += 2;
 898:	bdd9                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 89a:	008b8913          	addi	s2,s7,8
 89e:	4681                	li	a3,0
 8a0:	4629                	li	a2,10
 8a2:	000be583          	lwu	a1,0(s7)
 8a6:	855a                	mv	a0,s6
 8a8:	de1ff0ef          	jal	688 <printint>
 8ac:	8bca                	mv	s7,s2
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bd7d                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b2:	008b8913          	addi	s2,s7,8
 8b6:	4681                	li	a3,0
 8b8:	4629                	li	a2,10
 8ba:	000bb583          	ld	a1,0(s7)
 8be:	855a                	mv	a0,s6
 8c0:	dc9ff0ef          	jal	688 <printint>
        i += 1;
 8c4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8c6:	8bca                	mv	s7,s2
      state = 0;
 8c8:	4981                	li	s3,0
        i += 1;
 8ca:	b555                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8cc:	008b8913          	addi	s2,s7,8
 8d0:	4681                	li	a3,0
 8d2:	4629                	li	a2,10
 8d4:	000bb583          	ld	a1,0(s7)
 8d8:	855a                	mv	a0,s6
 8da:	dafff0ef          	jal	688 <printint>
        i += 2;
 8de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8e0:	8bca                	mv	s7,s2
      state = 0;
 8e2:	4981                	li	s3,0
        i += 2;
 8e4:	b569                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8e6:	008b8913          	addi	s2,s7,8
 8ea:	4681                	li	a3,0
 8ec:	4641                	li	a2,16
 8ee:	000be583          	lwu	a1,0(s7)
 8f2:	855a                	mv	a0,s6
 8f4:	d95ff0ef          	jal	688 <printint>
 8f8:	8bca                	mv	s7,s2
      state = 0;
 8fa:	4981                	li	s3,0
 8fc:	bd8d                	j	76e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8fe:	008b8913          	addi	s2,s7,8
 902:	4681                	li	a3,0
 904:	4641                	li	a2,16
 906:	000bb583          	ld	a1,0(s7)
 90a:	855a                	mv	a0,s6
 90c:	d7dff0ef          	jal	688 <printint>
        i += 1;
 910:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 912:	8bca                	mv	s7,s2
      state = 0;
 914:	4981                	li	s3,0
        i += 1;
 916:	bda1                	j	76e <vprintf+0x4a>
 918:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 91a:	008b8d13          	addi	s10,s7,8
 91e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 922:	03000593          	li	a1,48
 926:	855a                	mv	a0,s6
 928:	d43ff0ef          	jal	66a <putc>
  putc(fd, 'x');
 92c:	07800593          	li	a1,120
 930:	855a                	mv	a0,s6
 932:	d39ff0ef          	jal	66a <putc>
 936:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 938:	00000b97          	auipc	s7,0x0
 93c:	300b8b93          	addi	s7,s7,768 # c38 <digits>
 940:	03c9d793          	srli	a5,s3,0x3c
 944:	97de                	add	a5,a5,s7
 946:	0007c583          	lbu	a1,0(a5)
 94a:	855a                	mv	a0,s6
 94c:	d1fff0ef          	jal	66a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 950:	0992                	slli	s3,s3,0x4
 952:	397d                	addiw	s2,s2,-1
 954:	fe0916e3          	bnez	s2,940 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 958:	8bea                	mv	s7,s10
      state = 0;
 95a:	4981                	li	s3,0
 95c:	6d02                	ld	s10,0(sp)
 95e:	bd01                	j	76e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 960:	008b8913          	addi	s2,s7,8
 964:	000bc583          	lbu	a1,0(s7)
 968:	855a                	mv	a0,s6
 96a:	d01ff0ef          	jal	66a <putc>
 96e:	8bca                	mv	s7,s2
      state = 0;
 970:	4981                	li	s3,0
 972:	bbf5                	j	76e <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 974:	008b8993          	addi	s3,s7,8
 978:	000bb903          	ld	s2,0(s7)
 97c:	00090f63          	beqz	s2,99a <vprintf+0x276>
        for (; *s; s++)
 980:	00094583          	lbu	a1,0(s2)
 984:	c195                	beqz	a1,9a8 <vprintf+0x284>
          putc(fd, *s);
 986:	855a                	mv	a0,s6
 988:	ce3ff0ef          	jal	66a <putc>
        for (; *s; s++)
 98c:	0905                	addi	s2,s2,1
 98e:	00094583          	lbu	a1,0(s2)
 992:	f9f5                	bnez	a1,986 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 994:	8bce                	mv	s7,s3
      state = 0;
 996:	4981                	li	s3,0
 998:	bbd9                	j	76e <vprintf+0x4a>
          s = "(null)";
 99a:	00000917          	auipc	s2,0x0
 99e:	29690913          	addi	s2,s2,662 # c30 <malloc+0x18a>
        for (; *s; s++)
 9a2:	02800593          	li	a1,40
 9a6:	b7c5                	j	986 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 9a8:	8bce                	mv	s7,s3
      state = 0;
 9aa:	4981                	li	s3,0
 9ac:	b3c9                	j	76e <vprintf+0x4a>
 9ae:	64a6                	ld	s1,72(sp)
 9b0:	79e2                	ld	s3,56(sp)
 9b2:	7a42                	ld	s4,48(sp)
 9b4:	7aa2                	ld	s5,40(sp)
 9b6:	7b02                	ld	s6,32(sp)
 9b8:	6be2                	ld	s7,24(sp)
 9ba:	6c42                	ld	s8,16(sp)
 9bc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9be:	60e6                	ld	ra,88(sp)
 9c0:	6446                	ld	s0,80(sp)
 9c2:	6906                	ld	s2,64(sp)
 9c4:	6125                	addi	sp,sp,96
 9c6:	8082                	ret

00000000000009c8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9c8:	715d                	addi	sp,sp,-80
 9ca:	ec06                	sd	ra,24(sp)
 9cc:	e822                	sd	s0,16(sp)
 9ce:	1000                	addi	s0,sp,32
 9d0:	e010                	sd	a2,0(s0)
 9d2:	e414                	sd	a3,8(s0)
 9d4:	e818                	sd	a4,16(s0)
 9d6:	ec1c                	sd	a5,24(s0)
 9d8:	03043023          	sd	a6,32(s0)
 9dc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9e4:	8622                	mv	a2,s0
 9e6:	d3fff0ef          	jal	724 <vprintf>
}
 9ea:	60e2                	ld	ra,24(sp)
 9ec:	6442                	ld	s0,16(sp)
 9ee:	6161                	addi	sp,sp,80
 9f0:	8082                	ret

00000000000009f2 <printf>:

void
printf(const char *fmt, ...)
{
 9f2:	711d                	addi	sp,sp,-96
 9f4:	ec06                	sd	ra,24(sp)
 9f6:	e822                	sd	s0,16(sp)
 9f8:	1000                	addi	s0,sp,32
 9fa:	e40c                	sd	a1,8(s0)
 9fc:	e810                	sd	a2,16(s0)
 9fe:	ec14                	sd	a3,24(s0)
 a00:	f018                	sd	a4,32(s0)
 a02:	f41c                	sd	a5,40(s0)
 a04:	03043823          	sd	a6,48(s0)
 a08:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a0c:	00840613          	addi	a2,s0,8
 a10:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a14:	85aa                	mv	a1,a0
 a16:	4505                	li	a0,1
 a18:	d0dff0ef          	jal	724 <vprintf>
}
 a1c:	60e2                	ld	ra,24(sp)
 a1e:	6442                	ld	s0,16(sp)
 a20:	6125                	addi	sp,sp,96
 a22:	8082                	ret

0000000000000a24 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a24:	1141                	addi	sp,sp,-16
 a26:	e422                	sd	s0,8(sp)
 a28:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 a2a:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a2e:	00001797          	auipc	a5,0x1
 a32:	5d27b783          	ld	a5,1490(a5) # 2000 <freep>
 a36:	a02d                	j	a60 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 a38:	4618                	lw	a4,8(a2)
 a3a:	9f2d                	addw	a4,a4,a1
 a3c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a40:	6398                	ld	a4,0(a5)
 a42:	6310                	ld	a2,0(a4)
 a44:	a83d                	j	a82 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 a46:	ff852703          	lw	a4,-8(a0)
 a4a:	9f31                	addw	a4,a4,a2
 a4c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a4e:	ff053683          	ld	a3,-16(a0)
 a52:	a091                	j	a96 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a54:	6398                	ld	a4,0(a5)
 a56:	00e7e463          	bltu	a5,a4,a5e <free+0x3a>
 a5a:	00e6ea63          	bltu	a3,a4,a6e <free+0x4a>
{
 a5e:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a60:	fed7fae3          	bgeu	a5,a3,a54 <free+0x30>
 a64:	6398                	ld	a4,0(a5)
 a66:	00e6e463          	bltu	a3,a4,a6e <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a6a:	fee7eae3          	bltu	a5,a4,a5e <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 a6e:	ff852583          	lw	a1,-8(a0)
 a72:	6390                	ld	a2,0(a5)
 a74:	02059813          	slli	a6,a1,0x20
 a78:	01c85713          	srli	a4,a6,0x1c
 a7c:	9736                	add	a4,a4,a3
 a7e:	fae60de3          	beq	a2,a4,a38 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a82:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 a86:	4790                	lw	a2,8(a5)
 a88:	02061593          	slli	a1,a2,0x20
 a8c:	01c5d713          	srli	a4,a1,0x1c
 a90:	973e                	add	a4,a4,a5
 a92:	fae68ae3          	beq	a3,a4,a46 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a96:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a98:	00001717          	auipc	a4,0x1
 a9c:	56f73423          	sd	a5,1384(a4) # 2000 <freep>
}
 aa0:	6422                	ld	s0,8(sp)
 aa2:	0141                	addi	sp,sp,16
 aa4:	8082                	ret

0000000000000aa6 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 aa6:	7139                	addi	sp,sp,-64
 aa8:	fc06                	sd	ra,56(sp)
 aaa:	f822                	sd	s0,48(sp)
 aac:	f426                	sd	s1,40(sp)
 aae:	ec4e                	sd	s3,24(sp)
 ab0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 ab2:	02051493          	slli	s1,a0,0x20
 ab6:	9081                	srli	s1,s1,0x20
 ab8:	04bd                	addi	s1,s1,15
 aba:	8091                	srli	s1,s1,0x4
 abc:	0014899b          	addiw	s3,s1,1
 ac0:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 ac2:	00001517          	auipc	a0,0x1
 ac6:	53e53503          	ld	a0,1342(a0) # 2000 <freep>
 aca:	c915                	beqz	a0,afe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 acc:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 ace:	4798                	lw	a4,8(a5)
 ad0:	08977a63          	bgeu	a4,s1,b64 <malloc+0xbe>
 ad4:	f04a                	sd	s2,32(sp)
 ad6:	e852                	sd	s4,16(sp)
 ad8:	e456                	sd	s5,8(sp)
 ada:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 adc:	8a4e                	mv	s4,s3
 ade:	0009871b          	sext.w	a4,s3
 ae2:	6685                	lui	a3,0x1
 ae4:	00d77363          	bgeu	a4,a3,aea <malloc+0x44>
 ae8:	6a05                	lui	s4,0x1
 aea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 aee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 af2:	00001917          	auipc	s2,0x1
 af6:	50e90913          	addi	s2,s2,1294 # 2000 <freep>
  if (p == SBRK_ERROR)
 afa:	5afd                	li	s5,-1
 afc:	a081                	j	b3c <malloc+0x96>
 afe:	f04a                	sd	s2,32(sp)
 b00:	e852                	sd	s4,16(sp)
 b02:	e456                	sd	s5,8(sp)
 b04:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b06:	00001797          	auipc	a5,0x1
 b0a:	50a78793          	addi	a5,a5,1290 # 2010 <base>
 b0e:	00001717          	auipc	a4,0x1
 b12:	4ef73923          	sd	a5,1266(a4) # 2000 <freep>
 b16:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b18:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 b1c:	b7c1                	j	adc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b1e:	6398                	ld	a4,0(a5)
 b20:	e118                	sd	a4,0(a0)
 b22:	a8a9                	j	b7c <malloc+0xd6>
  hp->s.size = nu;
 b24:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 b28:	0541                	addi	a0,a0,16
 b2a:	efbff0ef          	jal	a24 <free>
  return freep;
 b2e:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 b32:	c12d                	beqz	a0,b94 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 b34:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 b36:	4798                	lw	a4,8(a5)
 b38:	02977263          	bgeu	a4,s1,b5c <malloc+0xb6>
    if (p == freep)
 b3c:	00093703          	ld	a4,0(s2)
 b40:	853e                	mv	a0,a5
 b42:	fef719e3          	bne	a4,a5,b34 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b46:	8552                	mv	a0,s4
 b48:	a2fff0ef          	jal	576 <sbrk>
  if (p == SBRK_ERROR)
 b4c:	fd551ce3          	bne	a0,s5,b24 <malloc+0x7e>
        return 0;
 b50:	4501                	li	a0,0
 b52:	7902                	ld	s2,32(sp)
 b54:	6a42                	ld	s4,16(sp)
 b56:	6aa2                	ld	s5,8(sp)
 b58:	6b02                	ld	s6,0(sp)
 b5a:	a03d                	j	b88 <malloc+0xe2>
 b5c:	7902                	ld	s2,32(sp)
 b5e:	6a42                	ld	s4,16(sp)
 b60:	6aa2                	ld	s5,8(sp)
 b62:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 b64:	fae48de3          	beq	s1,a4,b1e <malloc+0x78>
        p->s.size -= nunits;
 b68:	4137073b          	subw	a4,a4,s3
 b6c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b6e:	02071693          	slli	a3,a4,0x20
 b72:	01c6d713          	srli	a4,a3,0x1c
 b76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b7c:	00001717          	auipc	a4,0x1
 b80:	48a73223          	sd	a0,1156(a4) # 2000 <freep>
      return (void *)(p + 1);
 b84:	01078513          	addi	a0,a5,16
  }
}
 b88:	70e2                	ld	ra,56(sp)
 b8a:	7442                	ld	s0,48(sp)
 b8c:	74a2                	ld	s1,40(sp)
 b8e:	69e2                	ld	s3,24(sp)
 b90:	6121                	addi	sp,sp,64
 b92:	8082                	ret
 b94:	7902                	ld	s2,32(sp)
 b96:	6a42                	ld	s4,16(sp)
 b98:	6aa2                	ld	s5,8(sp)
 b9a:	6b02                	ld	s6,0(sp)
 b9c:	b7f5                	j	b88 <malloc+0xe2>
