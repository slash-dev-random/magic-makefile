################################################################################
#                                                                              #
# Basic C/C++ Workspace Makefile for Linux                                     #
# Author: Benjamin Cox                                                         #
# Version 1.1                                                                  #
#                                                                              #
################################################################################

#Default Configuration is Debug
CONFIG?=Debug

#Make sure our compiler and linker are set
CC:=gcc
CXX:=g++
LD:=gcc
LDXX:=g++
AS:=as
AR:=ar
RANLIB:=ranlib
OBJCOPY:=objcopy

LEX:=flex
YACC:=bison

ifeq ($(CONFIG),)
    CONFIG:=Debug
endif

.PHONY: default default1 all test run-tests analyze format clean help
.SUFFIXES: 

default: default1

DEFAULT_TARGETS:= 
TEST_TARGETS:= 
DOCS_TARGETS:= 
CLEAN_DOCS_TARGETS:= 
ANALYZE_TARGETS:=
FORMAT_TARGETS:=

#Include makefile rules/settings
include rules.mk

CUSTOM_MAKE_DIR:=make/

define module_setup =

MODULE:=$(1)
MOD_DIR:=$$(dir $$(MODULE))
BASE_MOD_DIR:=$$(subst $$(CUSTOM_MAKE_DIR),,$$(MOD_DIR))
#Our base directories
SRC_BASE_DIR:=$$(BASE_MOD_DIR)src/
TEST_BASE_DIR:=$$(BASE_MOD_DIR)test/
EXT_LIB_DIR:=$$(BASE_MOD_DIR)libs/
CONFIG_DIR:=$$(BASE_MOD_DIR)config/
DOCS_DIR:=$$(BASE_MOD_DIR)docs/
BUILD_BASE_DIR:=build/
#Set Up Build Directory Structure
BUILD_DIR:=$$(BUILD_BASE_DIR)$$(CONFIG)/
TARGET_DIR:=$$(BUILD_DIR)$$(shell uname -s)-$$(shell arch)/
OBJS_BASE_DIR:=$$(TARGET_DIR)objs/

#Configure Flags and Directories per Configuration
include $$(CONFIG_DIR)$$(CONFIG).mk

include $$(MODULE)

endef


MODULES=$(wildcard */$(CUSTOM_MAKE_DIR)*.mk)

$(foreach module,$(MODULES),$(eval $(call module_setup,$(module))))

#If none of the includes added any default targets add help
ifeq ($(strip $(DEFAULT_TARGETS)),)
DEFAULT_TARGETS = help
endif

default1: $(DEFAULT_TARGETS)

all: default test docs

test: $(TEST_TARGETS)

run-tests: $(TEST_TARGETS)
	@for test in $^ ; do                                               \
	    echo "Running test $$(basename $$test)"; echo ;                \
	    $$test ;                                                       \
	    echo "------------------------------------------------------"; \
	    echo ;                                                         \
	done

docs: $(DOCS_TARGETS)

analyze: $(ANALYZE_TARGETS)

format: $(FORMAT_TARGETS)

help:
	@cat README.txt

clean: $(CLEAN_TARGETS)
	@echo "CLEANING BUILD DIRECTORY"
	@rm -rf $(BUILD_BASE_DIR)

clean-docs: $(CLEAN_DOCS_TARGETS)

clean-all: clean clean-docs
