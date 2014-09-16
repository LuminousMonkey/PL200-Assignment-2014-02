PROG := pl-assignment
LIBS =

CFLAGS = -MMD -Wall -Wextra

CC := gcc
LEX := flex
YACC := bison

OUTDIRS := obj

SRCFILES := src/parser.y src/lexical.y
OBJFILES := obj/parser.o obj/lexical.o
DEPFILES := $(patsubst obj/%.o,obj/%.d,$(OBJFILES))

.PHONY: clean dirs

all: dirs $(PROG)

dirs:
	@mkdir -p $(OUTDIRS)

$(PROG): $(OBJFILES)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

obj/%.o: src/%.c
	$(CC) $(CFLAGS) -MF $(patsubst obj/%.o, obj/%.d, $@) -c $< -o $@

src/lexical.c: src/lexical.l
	$(LEX) -o$@ $<

src/parser.c: src/parser.y
	bison -o$@ $<

clean:
	rm -f $(OBJFILES) $(DEPFILES) $(PROG)

# Let GCC work out the dependencies.
-include $(DEPFILES)
