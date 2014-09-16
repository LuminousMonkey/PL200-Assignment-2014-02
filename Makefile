PROG := pl-assignment
LIBS =

CFLAGS = -MMD -Wall -Wextra

CC := gcc
LEX := flex
YACC := bison

OUTDIRS := obj

SRCFILES := $(wildcard src/*.c)

OBJFILES := $(patsubst src/%.c,obj/%.o,$(SRCFILES))
DEPFILES := $(patsubst src/%.c,obj/%.d,$(SRCFILES))

.PHONY: clean dirs

dirs:
	@mkdir -p $(OUTDIRS)

$(PROG): $(OBJFILES)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

obj/%.o: src/%.c
	$(CC) ($CFLAGS) -MF $(patsubst obj/%.o, obj/%.d, $@) -c $< -o $@

obj/lexical.o: src/lexical.l
	$(LEX) $< -o $@

obj/parser.o: src/parser.y
	bison $< -o $@

clean:
	rm -f $(OBJFILES) $(DEPFILES) $(PROG)

# Let GCC work out the dependencies.
-include $(DEPFILES)
