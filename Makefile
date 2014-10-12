PROG := PL2014_check
LIBS =

CC ?= gcc
LEX ?= flex
YACC ?= bison

YACCVERSION := $(shell expr `$(YACC) --version | grep ^bison | sed 's/^.* //g'` \> 2.5)

CFLAGS = -MMD -Wall -Wextra --std=c99 -D_GNU_SOURCE
YFLAGS = -d
LEXFLAGS =

ifeq "$(YACCVERSION)" "1"
YFLAGS += -Werror --report=all --report-file=bison.report
endif

OUTDIRS := obj

SRCFILES := src/parser.y src/lexical.l
OBJFILES := obj/parser.o obj/lexical.o obj/node.o
DEPFILES := $(patsubst obj/%.o,obj/%.d,$(OBJFILES))

.PHONY: clean dirs

all: dirs $(PROG)

dirs:
	@mkdir -p $(OUTDIRS)

$(PROG): $(OBJFILES)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

obj/%.o: src/%.c
	$(CC) $(CFLAGS) -MF $(patsubst obj/%.o, obj/%.d, $@) -c $< -o $@

src/lexical.h src/lexical.c: src/lexical.l
	$(LEX) $(LEXFLAGS) -osrc/lexical.c $<

src/parser.c: src/parser.y src/lexical.h
	$(YACC) $(YFLAGS) -o$@ $<

clean:
	rm -f $(OBJFILES) $(DEPFILES) src/parser.c src/parser.h \
	    src/lexical.c src/lexical.h bison.report $(PROG)

test: $(PROG)
	cd test && ./runTests.sh

# Let GCC work out the dependencies.
-include $(DEPFILES)
