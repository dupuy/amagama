
.PHONY: all help

all: help

help:
	@echo "Help"
	@echo "----"
	@echo
	@echo "  requirements - (re)generate pinned and minimum requirements"
	@echo "  clean - remove generated and temporary files"


.PHONY: requirements requirements.txt requirements/*

requirements:
	$(MAKE) -C requirements

requirements.txt requirements/*:
	$(MAKE) -C requirements $@


.PHONY: clean

clean:
	@if git clean -ndX | grep .; then                               \
	   printf 'Remove these files? (y/N) '; read ANS;               \
	   case $$ANS in [yY]*) git clean -fdX;; *) exit 1;; esac       \
	 fi
