COQBIN?=$(dir $(shell which coqtop))
COQMAKEFILE?=$(COQBIN)coq_makefile
COQMAKEOPTIONS?=
COQMAKEFILEOPTIONS?=

all: Makefile-all.coq
	+$(MAKE) -f $< $(COQMAKEOPTIONS)

%: Makefile-%.coq
	+$(MAKE) -f $< $(COQMAKEOPTIONS)

Makefile-%.coq: Make.%
	$(COQMAKEFILE) $(COQMAKEFILEOPTIONS) -f $< -o $@

install: Makefile-all.coq
	+$(MAKE) -f $< $(COQMAKEOPTIONS) install

install-%: Makefile-%.coq
	+$(MAKE) -f $< $(COQMAKEOPTIONS) install

# Make of individual .vo
%.vo: Makefile-all.coq
	+$(MAKE) -f $< $(COQMAKEOPTIONS) $@
