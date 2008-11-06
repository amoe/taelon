# Makefile for taelon

# POSIX.1 make(1):
# "The first non-empty line that does not begin with a <tab> or '#' shall begin
# a new entry. An empty or blank line, or a line beginning with '#', may begin a
# new entry. ... The algorithm for determining a new entry for target rules is
# partially unspecified. Some historical makes allow blank, empty, or comment
# lines within the collection of commands marked by leading <tab>s. A conforming
# makefile must ensure that each command starts with a <tab>, but
# implementations are free to ignore blank, empty, and comment lines without
# triggering the start of a new entry."

# 3.75 Blank Line:
# A line consisting solely of zero or more <blank>s terminated by a <newline>;
# 3.74 Blank Character (<blank>):
# One of the characters that belong to the blank character class as defined via
# the LC_CTYPE category in the current locale. In the POSIX locale, a <blank>
# is either a <tab> or a <space>.
# 3.144 Empty Line:
# A line consisting of only a <newline>

# So the only way to put space is through comment lines :(

prefix = /usr/local

all: unpack pak paklist

unpack: unpack.c
	cc -o unpack -Wall unpack.c

pak: pak.c
	cc -o pak -Wall pak.c

paklist: paklist.c
	cc -o paklist -Wall paklist.c

clean:
	rm -f unpack pak paklist

install: taelon.sh terr.sh unpack pak paklist
	cp taelon.sh $(prefix)/bin/taelon
	chmod +x $(prefix)/bin/taelon
	mkdir -p $(prefix)/lib/taelon
	cp terr.sh $(prefix)/lib/taelon/terr
	chmod +x $(prefix)/lib/taelon/terr
	cp unit.sh $(prefix)/lib/taelon/unit
	chmod +x $(prefix)/lib/taelon/unit
	cp pak unpack paklist $(prefix)/lib/taelon
