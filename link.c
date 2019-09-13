#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

FILE *f;
FILE *fout;

typedef struct Block Block;
struct Block {
	uint16_t len;
	uint8_t *data;
};

typedef struct Symbol Symbol;
struct Symbol {
	uint32_t name;
	uint8_t type;
	uint8_t flags;
	uint16_t value;
	Symbol *next;

	uint8_t *data;
	uint16_t len;
	uint16_t start;
};
Symbol *syms, **symp = &syms;

typedef struct Reloc Reloc;
struct Reloc {
	uint32_t name;
	Symbol *psect;
	uint16_t addr;
	Reloc *next;
};
Reloc *relocs, **relocp = &relocs;

Symbol *cursect;
uint16_t curloc;

Symbol *
getsym(uint32_t name, int type)
{
	Symbol *s;;

	for(s = syms; s != NULL; s = s->next)
		if(s->name == name && s->type == type)
			return s;
	errx(1, "symbol not found: %#.8x", name);
	return NULL;
}

uint8_t *
sectptr(Symbol *s, uint16_t off, uint16_t len)
{
	int d;

	if(s->data == NULL){
		s->data = malloc(len);
		s->start = off;
		s->len = len;
		return s->data;
	}
	if(off < s->start){
		d = s->start - off;
		s->data = realloc(s->data, s->len + d);
		memmove(s->data + d, s->data, s->len);
		memset(s->data, 0, d);
		s->len += d;
		s->start = off;
	}
	if(off + len > s->start + s->len){
		s->data = realloc(s->data, off + len - s->start);
		memset(s->data + s->len, 0, off + len - s->start - s->len);
		s->len = off + len - s->start;
	}
	return s->data + (off - s->start);
}

void
relocate(uint32_t name, Symbol *psect, uint16_t addr)
{
	Reloc *r;
	
	printf("%d: @%.8x\n", addr, name);
	r = malloc(sizeof(Reloc));
	r->name = name;
	r->psect = psect;
	r->addr = addr;
	r->next = NULL;
	*relocp = r;
	relocp = &r->next;
}

uint8_t *
unpack(uint8_t *p, uint8_t *e, char *s, ...)
{
	va_list va;
	uint32_t v;

	va_start(va, s);
	for(; *s != 0; s++)
		switch(*s){
		case 'b':
			if(p + 1 > e) goto err;
			*va_arg(va, uint8_t *) = *p++;
			break;
		case 'w':
			if(p + 2 > e) goto err;
			*va_arg(va, uint16_t *) = p[0] | p[1] << 8;
			p += 2;
			break;
		case 'd':
			if(p + 4 > e) goto err;
			*va_arg(va, uint32_t *) = p[0] | p[1] << 8 | p[2] << 16 | p[3] << 24;
			p += 4;
			break;
		default: errx(1, "unpack: unknown %c", *s);
		}
	return p;
err:	errx(1, "overrun");
}

void
gsd(Block *b)
{
	uint8_t *p, *e;
	Symbol *s;

	p = b->data + 2;
	e = b->data + b->len;
	while(p < e){
		s = malloc(sizeof(Symbol));
		s->next = NULL;
		p = unpack(p, e, "dbbw", &s->name, &s->flags, &s->type, &s->value);
		if(s->type == 5 || s->type == 4 && (s->flags & 8) != 0){
			*symp = s;
			symp = &s->next;
			printf("%.8x %.2x %.2x %.6o\n", s->name, s->type, s->flags, s->value);
		}
	}
}

void
rld(Block *b)
{
	uint8_t *p, *e;
	uint16_t addr;
	uint16_t *targ;
	uint32_t name;
	uint8_t disp;
	uint16_t cons;

	p = b->data + 2;
	e = b->data + b->len;
	for(; p < e; ){
		switch(*p & 0x7f){
		case 0x02:
			p = unpack(p + 1, e, "bd", &disp, &name);
			addr = curloc + disp - 4;
			relocate(name, cursect, addr);
			break;
		case 0x03:
			p = unpack(p + 1, e, "bw", &disp, &cons);
			addr = curloc + disp - 4;
			targ = (uint16_t*) sectptr(cursect, addr, 2);
			*targ = cons - addr - 2;
			printf("%o: %o\n", addr, *targ);
			break;
		case 0x07:
			p = unpack(p + 2, e, "dw", &name, &curloc);
			cursect = getsym(name, 5);
			break;
		default: errx(1, "RLD: unknown cmd %#.2x", *p);
		}
	}
}

void
txt(Block *b)
{
	uint16_t off;

	unpack(b->data + 2, b->data + b->len, "w", &off);
	curloc = off;
	memmove(sectptr(cursect, off, b->len - 4), b->data + 4, b->len - 4);
}

int
block(void)
{
	Block *b;
	int ch;

	b = malloc(sizeof(Block));
	for(;;){
		ch = fgetc(f);
		if(ch == 1) break;
		if(ch == 0) continue;
		if(ch < 0) return 0;
		errx(1, "invalid block");
	}
	if(fgetc(f) != 0) errx(1, "invalid block");
	b->len = fgetc(f);
	b->len |= fgetc(f) << 8;
	b->len -= 4;
	b->data = malloc(b->len);
	fread(b->data, b->len, 1, f);
	fgetc(f);
	switch(*b->data){
	case 1: gsd(b); break;
	case 2: break;
	case 3: txt(b); break;
	case 4: rld(b); break;
	case 6: break;
	default: errx(1, "unknown block type %d", *b->data);
	}
	return 1;
}

void
fix(void)
{
	Reloc *r;
	Symbol *s;
	
	for(r = relocs; r != NULL; r = r->next){
		s = getsym(r->name, 4);
		*sectptr(r->psect, r->addr, 2) = s->value;
		printf("%o: %o\n", r->addr, s->value);
	}
}

void
dump(Symbol *s)
{
	fputc(s->start, fout);
	fputc(s->start >> 8, fout);
	fputc(s->len, fout);
	fputc(s->len >> 8, fout);
	fwrite(s->data, s->len, 1, fout);
}

int
main(int argc, char **argv)
{
	int i;

	if(argc < 4 || strcmp(argv[1], "-o") != 0) errx(1, "usage: %s -o out in ...", argv[0]);
	for(i = 3; i < argc; i++){
		f = fopen(argv[i], "rb");
		if(f == NULL) err(1, "fopen");
		while(block());
		fclose(f);
	}
	fix();
	fout = fopen(argv[2], "wb");
	if(fout == NULL) err(1, "fopen");
	dump(getsym(0x0f94af01, 5));
	return 0;
}
