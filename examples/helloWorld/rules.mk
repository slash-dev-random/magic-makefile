################################################################################
#                                                                              #
# Basic C/C++ Makefile Rules for Linux                                         #
# Author: Benjamin Cox                                                         #
# License: CC0 1.0 Universal Licence                                           #
# Version 1.3                                                                  #
#                                                                              #
################################################################################
MAGIC_MAKEFILE_RULES_VERSION=1.3

ifneq ($(MAGIC_MAKEFILE_VERSION),$(MAGIC_MAKEFILE_RULES_VERSION))
$(error rules.mk version ($(MAGIC_MAKEFILE_RULES_VERSION)) does not match Makefile version $(MAGIC_MAKEFILE_VERSION))
endif

#1 - DEST OBJECT FILE
#2 - SRC OBJECT FILE
#3 - OBJCOPY OPTIONS
define objcopy_rules =
$(1): $(2)
	@echo "OBJCOPY  $$(notdir $$@)"
	@$$(OBJCOPY) $(3) $$^ $$@ 
endef

#1 - APP_NAME
#2 - MY_CPPCHECK_FLAGS
#3 - SRC_DIR
define cppcheck_rules =
.PHONY: $(1)-cppcheck
ANALYZE_TARGETS:=$$(ANALYZE_TARGETS) $(1)-cppcheck
$(1)-cppcheck:
	@echo "CPP CHECK FOR $(1)"
	@cppcheck $(2) $(3)

endef

#1 - APP_NAME
#2 - SRC_FILES
#3 - CXX_FLAGS
define clang_check_rules =
.PHONY: $(1)-clang-check
ANALYZE_TARGETS:=$$(ANALYZE_TARGETS) $(1)-clang-check
$(1)-clang-check:
	@echo "CLANG CHECK FOR $(1)"
	@for src in $(2) ; do                                                                       \
	    echo "-----------------------Checking: $$$$(basename $$$$src)-----------------------";  \
	    clang-check -analyze $(patsubst %,-extra-arg=%,$(subst -I ,-I,$(3))) "$$$$src" -- ;     \
	done
endef

#1 - APP_NAME
#2 - SRC_FILES
define clang_format_rules =
.PHONY: $(1)-clang-format
FORMAT_TARGETS:=$$(FORMAT_TARGETS) $(1)-clang-format
$(1)-clang-format:
	@echo "CLANG-FORMAT FOR $(1)"
	@for src in $(2) ; do                               \
	    echo "    Formatting: $$$$(basename $$$$src)";  \
	    clang-format -i "$$$$src";                      \
	done

endef

#1 - Dircetory
#2 - Product
#3 - Dependencies
#4 - Flags
define std_link_rules =
.PHONY: $(2)
$(2): $(1)$(2)
DEFAULT_TARGETS:=$$(DEFAULT_TARGETS) $(1)$(2)
$(1)$(2): $(3)
	@echo "LD       $$(notdir $$@)"
	@$$(LD) -o $$@ $$^ $(4)
endef

#1 - Dircetory
#2 - Product
#3 - Dependencies
#4 - Flags
define lib_link_rules =
.PHONY: $(2)
$(2): $(1)$(2)
DEFAULT_TARGETS:=$$(DEFAULT_TARGETS) $(1)$(2)
$(1)$(2): $(3)
	@$$(RM) -f $$@
	@echo "AR       $$(notdir $$@)"
	@$$(AR) $(4) -o $$@ $$^ 2>&1 | sed "s|^|             |g"    \
	                             | sed "s| - .*/\(.*\)| - \1|"  \
	                             | sed  "s|creating .*/\(.*\)|creating \1|"
	@echo "RANLIB   $$(notdir $$@)"
	@$$(RANLIB) $$@

endef

#1 - Dircetory
#2 - Product
#3 - Dependencies
#4 - Flags
define test_link_rules =
.PHONY: $(2)
$(2): $(1)$(2)
TEST_TARGETS:=$$(TEST_TARGETS) $(1)$(2)
$(1)$(2): $(3)
	@echo "LD       $$(notdir $$@)"
	@$$(LD) -o $$@ $$^ $(4)
endef

#1 -- SRC_BASE_DIR
#2 -- GENERATED FILES
define clean_generated_files_rule =

.PHONY: $(1)clean_generated
CLEAN_TARGETS:=$$(CLEAN_TARGETS) $(1)clean_generated

$(1)clean_generated:
	@echo "CLEANING GENERATED FILES IN$(1)"
	@rm -f $(2)

endef

################################################################################
#                                COMPILE RULES                                 #
################################################################################
#1 - OBJCET BASE DIR
#2 - SOURCE DIR
#3 - CXX FLAGS
define cpp_directory_rules =
$(1)$(2)%.o: $(2)%.cc
	@echo "CXX      $$<"
	@$$(CXX) $(3) -c -o $$@ $$<

$(1)$(2)%.o: $(2)%.cp
	@echo "CXX      $$<"
	@$$(CXX) $(3) -c -o $$@ $$<

$(1)$(2)%.o: $(2)%.cxx
	@echo "CXX      $$<"
	@$$(CXX) $(3) -c -o $$@ $$<

$(1)$(2)%.o: $(2)%.cpp
	@echo "CXX      $$<"
	@$$(CXX) $(3) -c -o $$@ $$<

$(1)$(2)%.o: $(2)%.CPP
	@echo "CXX      $$<"
	@$$(CXX) $(3) -c -o $$@ $$<

$(1)$(2)%.o: $(2)%.c++
	@echo "CXX      $$<"
	@$$(CXX) $(3) -c -o $$@ $$<

$(1)$(2)%.o: $(2)%.C
	@echo "CXX      $$<"
	@$$(CXX) $(3) -c -o $$@ $$<

endef


#1 - OBJCET BASE DIR
#2 - SOURCE DIR
#3 - C FLAGS
define c_directory_rules = 

$(1)$(2)%.o: $(2)%.c
	@echo "CC       $$<"
	@$$(CC) $(3) -c -o $$@ $$<

endef

################################################################################
#                            CODE GENERATION RULES                             #
################################################################################

#1 - SOURCE DIR
#2 - LEX_FLAGS
define lex_directory_rules =

$(1)%.l.c: $(1)%.l
	@echo "LEX      $$<"
	@$$(LEX) $(2) -o $$@ --header-file=$$(@:.c=.h) $$<

$(1)%.l.h: $(1)%.l
	@echo "LEX      $$<"
	@$$(LEX) $(2) -o $$(@:.h=.c) --header-file=$$@ $$<

$(1)%.lex.c: $(1)%.lex
	@echo "LEX      $$<"
	@$$(LEX) $(2) -o $$@ --header-file=$$(@:.c=.h) $$<

$(1)%.lex.h: $(1)%.lex
	@echo "LEX      $$<"
	@$$(LEX) $(2) -o $$(@:.h=.c) --header-file=$$@ $$<

$(1)%.flex.c: $(1)%.flex
	@echo "LEX      $$<"
	@$$(LEX) $(2) -o $$@ --header-file=$$(@:.c=.h) $$<

$(1)%.flex.h: $(1)%.flex
	@echo "LEX      $$<"
	@$$(LEX) $(2) -o $$(@:.h=.c) --header-file=$$@ $$<

$(1)%.ll.cc: $(1)%.ll
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$@ --header-file=$$(@:.cc=.h) $$<

$(1)%.ll.h: $(1)%.ll
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$(@:.h=.cc) --header-file=$$@ $$<

$(1)%.l++.cc: $(1)%.l++
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$@ --header-file=$$(@:.cc=.h) $$<

$(1)%.l++.h: $(1)%.l++
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$(@:.h=.cc) --header-file=$$@ $$<

$(1)%.lex++.cc: $(1)%.lex++
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$@ --header-file=$$(@:.cc=.h) $$<

$(1)%.lex++.h: $(1)%.lex++
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$(@:.h=.cc) --header-file=$$@ $$<

$(1)%.flex++.cc: $(1)%.flex++
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$@ --header-file=$$(@:.cc=.h) $$<

$(1)%.flex++.h: $(1)%.flex++
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$(@:.h=.cc) --header-file=$$@ $$<

$(1)%.lpp.cc: $(1)%.lpp
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$@ --header-file=$$(@:.cc=.h) $$<

$(1)%.lpp.h: $(1)%.lpp
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$(@:.h=.cc) --header-file=$$@ $$<

$(1)%.lexpp.cc: $(1)%.lexpp
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$@ --header-file=$$(@:.cc=.h) $$<

$(1)%.lexpp.h: $(1)%.lexpp
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$(@:.h=.cc) --header-file=$$@ $$<

$(1)%.flexpp.cc: $(1)%.flexpp
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$@ --header-file=$$(@:.cc=.h) $$<

$(1)%.flexpp.h: $(1)%.flexpp
	@echo "LEX      $$<"
	@$$(LEX) $(2) --c++ -o $$(@:.h=.cc) --header-file=$$@ $$<

endef

#1 - SOURCE DIR
#2 - YACC_FLAGS
define yacc_directory_rules =

$(1)%.y.c: $(1)%.y
	@echo "YACC     $$<"
	@$$(YACC) $(2) --defines=$$(@:.c=.h) -o $$@ $$<

$(1)%.y.h: $(1)%.y
	@echo "YACC     $$<"
	@$$(YACC) $(2) --defines=$$@ -o $$(@:.h=.c) $$<

$(1)%.Y.c: $(1)%.Y
	@echo "YACC     $$<"
	@$$(YACC) $(2) --defines=$$(@:.c=.h) -o $$@ $$<

$(1)%.Y.h: $(1)%.Y
	@echo "YACC     $$<"
	@$$(YACC) $(2) --defines=$$@ -o $$(@:.h=.c) $$<

$(1)%.yy.cc: $(1)%.yy
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$(@:.cc=.h) -o $$@ $$<

$(1)%.yy.h: $(1)%.yy
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$@ -o $$(@:.h=.cc) $$<

$(1)%.YY.cc: $(1)%.YY
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$(@:.cc=.h) -o $$@ $$<

$(1)%.YY.h: $(1)%.YY
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$@ -o $$(@:.h=.cc) $$<

$(1)%.ypp.cc: $(1)%.ypp
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$(@:.cc=.h) -o $$@ $$<

$(1)%.ypp.h: $(1)%.ypp
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$@ -o $$(@:.h=.cc) $$<

$(1)%.YPP.cc: $(1)%.YPP
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$(@:.cc=.h) -o $$@ $$<

$(1)%.YPP.h: $(1)%.YPP
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$@ -o $$(@:.h=.cc) $$<

$(1)%.y++.cc: $(1)%.y++
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$(@:.cc=.h) -o $$@ $$<

$(1)%.y++.h: $(1)%.y++
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$@ -o $$(@:.h=.cc) $$<

$(1)%.Y++.cc: $(1)%.Y++
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$(@:.cc=.h) -o $$@ $$<

$(1)%.Y++.h: $(1)%.Y++
	@echo "YACC     $$<"
	@$$(YACC) -L c++ $(2) --defines=$$@ -o $$(@:.h=.cc) $$<

endef


#1 - OBJCET BASE DIR
#2 - SOURCE DIR
#3 - PROTOBUF_FLAGS
define protobuf_directory_rules =

#PROTOBUF OUTPUTS CC, H & DEPENDENCIES FILES SIMULANEOUSLY
$(2)%.pb.cc $(2)%.pb.h: $(2)%.proto
	@echo "PROTOC   $$<"
	@$$(PROTOC) $(3) -I=$(2) -I=$$(SRC_DIR) --cpp_out=$$(dir $$@) --dependency_out=$(1)$$<.d $$<

endef

################################################################################
#                               DEPENDENCY  RULES                              #
################################################################################

#1 - OBJCET BASE DIR
#2 - SOURCE DIR
#3 - CXX FLAGS
define cpp_dependency_rules =

$(1)$(2)%.d: $(2)%.cc $$(GENERATED_TARGETS)
	@$$(CXX) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

$(1)$(2)%.d: $(2)%.cp $$(GENERATED_TARGETS)
	@$$(CXX) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

$(1)$(2)%.d: $(2)%.cxx $$(GENERATED_TARGETS)
	@$$(CXX) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

$(1)$(2)%.d: $(2)%.cpp $$(GENERATED_TARGETS)
	@$$(CXX) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

$(1)$(2)%.d: $(2)%.CPP $$(GENERATED_TARGETS)
	@$$(CXX) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

$(1)$(2)%.d: $(2)%.c++ $$(GENERATED_TARGETS)
	@$$(CXX) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

$(1)$(2)%.d: $(2)%.C $$(GENERATED_TARGETS)
	@$$(CXX) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

endef


#1 - OBJCET BASE DIR
#2 - SOURCE DIR
#3 - C FLAGS
define c_dependency_rules =

$(1)$(2)%.d: $(2)%.c $$(GENERATED_TARGETS)
	@$$(CC) -M -MT "$$(@:.d=.o) $$@" -MF $$@ $(3) $$<

endef


################################################################################
#                                DOXYGEN  RULES                                #
################################################################################

#1 - DOCS_DIR
#2 - SRC_BASE_DIR
#3 - PROJECT
#4 - PROJECT NUMBER
#5 - PROJECT BRIEF
define doxygen_rules = 

.PHONY: $(1)doxygen/clean_docs $(1)doxygen/doxygen

CLEAN_DOCS_TARGETS := $$(CLEAN_DOCS_TARGETS) $(1)doxygen/clean_docs
DOCS_TARGETS:= $$(DOCS_TARGETS) $(1)doxygen/doxygen

$(1)doxygen/doxygen: $(1)doxygen/doxygen.cfg
	@echo "DOXYGEN $(1)doxygen/doxygen.cfg"
	@(cat $(1)doxygen/doxygen.cfg;                          \
	  echo "OUTPUT_DIRECTORY = \"$$(strip $(1))doxygen/\""; \
	  echo "INPUT  = \"$$(strip $(2))\"" ) | doxygen - > $(1)doxygen/doxygen.log

$(1)doxygen/clean_docs:
	@echo "Cleaning Doxygen $(1)doxygen"
	@rm -rf $(1)doxygen/html
	@rm -rf $(1)doxygen/latex
	@rm -f $(1)doxygen/doxygen.log

$(1)doxygen/doxygen.cfg:
	@echo "Generating Doxygen Configuration $$@"
	@mkdir -p "$$(dir $$@)"
	@doxygen -g $$@ > /dev/null
	@sed -i "s|^PROJECT_NAME .*|PROJECT_NAME           = \"$$(strip $(3))\"|g" $$@
	@sed -i "s|^PROJECT_NUMBER .*|PROJECT_NUMBER         = \"$$(strip $(4))\"|g" $$@
	@sed -i "s|^PROJECT_BRIEF .*|PROJECT_BRIEF          = \"$$(strip $(5))\"|g" $$@
	@sed -i "s|^OUTPUT_DIRECTORY .*|OUTPUT_DIRECTORY       = \"$$(strip $(1))doxygen/\"|g" $$@
	@sed -i "s|^INPUT .*|INPUT                  = \"$$(strip $(2))\"|g" $$@
	@sed -i "s|^RECURSIVE .*|RECURSIVE              = YES|g" $$@
	@sed -i "s|^EXTRACT_ALL .*|EXTRACT_ALL            = YES|g" $$@
	@sed -i "s|^EXTRACT_PRIV_VIRTUAL.*|EXTRACT_PRIV_VIRTUAL   = YES|g" $$@
	@sed -i "s|^GENERATE_TREEVIEW.*|GENERATE_TREEVIEW      = YES|g" $$@
	@sed -i "s|^TOC_INCLUDE_HEADINGS.*|TOC_INCLUDE_HEADINGS   = 5|g" $$@
	@sed -i "s|^CASE_SENSE_NAMES.*|CASE_SENSE_NAMES       = YES|g" $$@

endef

#1 - PROJECT
#2 - PROJECT NUMBER
#3 - PROJECT BRIEF
define doxygen = 

$$(eval $$(call doxygen_rules, $$(DOCS_DIR), $$(SRC_BASE_DIR), $(1), $(2), $(3) ) )

endef


#1 - DESTINATION VARIALBE NAME
#2 - OBJECT BASE DIRECTORY
#3 - SOURCE FILES
define srcToObj =

$(1):=$$(addprefix $(2), $$(patsubst %.cc,%.o,        \
                         $$(patsubst %.cp,%.o,        \
                         $$(patsubst %.cxx,%.o,       \
                         $$(patsubst %.cpp,%.o,       \
                         $$(patsubst %.CPP,%.o,       \
                         $$(patsubst %.c++,%.o,       \
                         $$(patsubst %.C,%.o,         \
                         $$(patsubst %.c,%.o, $(3))))))))))

endef


#GET ALL THE RELATED SOURCE FILES UNDER THE SOURCE AND TEST DIRECTORIES
#
# REQUIRES THE FOLLOWING VARIALBE TO BE SET (THEY ARE NOT PARAMETERS)
#    SRC_DIR
#    TEST_SRC_DIR
#    UNIT TEST (GTEST, CPPUNIT, NONE)
#
#SETS THE FOLLOWING VARIABLES:
#    SRC_DIRS -- ALL SUB DIRECTORIES UNDER SRC_DIR
#    SRC_CXX_FILES 
#    SRC_C_FILES
#    SRC_FILES
#    
#    GEN_SRC_C_FILES -- GENERATED C FILES
#    GEN_SRC_CXX_FILES -- GENERATED CXX FILES
#    GEN_SRC_HEADER_FILES -- GENERATED HEADER FILES
#    
#    TEST_SRC_DIR
#    TEST_DIRS
#    TEST_C_FILES
#    TEST_CXX_FILES
#    TEST_SRC_FILES
define getSourceFiles =

$$(shell mkdir -p "$$(SRC_DIR)")

SRC_DIRS := $$(shell find $$(SRC_DIR) -type d)

SRC_CXX_FILES := $$(shell find $$(SRC_DIR) -name *.cc -o  -name *.cp  \
                                        -o -name *.cxx -o -name *.cpp \
                                        -o -name *.CPP -o -name *.c++ \
                                        -o -name *.C)

SRC_C_FILES := $$(shell find $$(SRC_DIR) -name *.c)

GEN_SRC_C_FILES:=
GEN_SRC_CXX_FILES:=
GEN_SRC_HEADER_FILES:=

#YOU SHOULD REALLY ONLY USE .l AND .y FOR C APPLICATIONS AND
# .ll and .yy FOR CPP APPLICATIONS -- I'M TRYING TO ACCOMMODATE ALL
#THE FILE EXTENSION VARIATIONS FOUND FOR LEX/YACC WHILE SEARCHING THE WEB
LEX_YACC_C_FILES:=$$(shell find $$(SRC_DIR) -name *.l      -o -name *.lex    \
                                         -o -name *.flex   -o -name *.y      \
                                         -o -name *.Y)

LEX_YACC_CXX_FILES:=$$(shell find $$(SRC_DIR) -name *.ll     -o -name *.l++     \
                                           -o -name *.lex++  -o -name *.flex++  \
                                           -o -name *.lpp    -o -name *.lexpp   \
                                           -o -name *.flexpp -o -name *.yy      \
                                           -o -name *.YY     -o -name *.ypp     \
                                           -o -name *.YPP    -o -name *.y++     \
                                           -o -name *.Y++   )

GEN_LEX_YACC_C_FILES:=$$(LEX_YACC_C_FILES)
GEN_LEX_YACC_C_FILES:=$$(GEN_LEX_YACC_C_FILES:.l=.l.c)
GEN_LEX_YACC_C_FILES:=$$(GEN_LEX_YACC_C_FILES:.lex=.lex.c)
GEN_LEX_YACC_C_FILES:=$$(GEN_LEX_YACC_C_FILES:.flex=.flex.c)
GEN_LEX_YACC_C_FILES:=$$(GEN_LEX_YACC_C_FILES:.y=.y.c)
GEN_LEX_YACC_C_FILES:=$$(GEN_LEX_YACC_C_FILES:.Y=.Y.c)

GEN_LEX_YACC_CXX_FILES:=$$(LEX_YACC_CXX_FILES:.ll=.ll.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.l++=.l++.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.lex++=.lex++.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.flex++=.flex++.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.lpp=.lpp.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.lexpp=.lexpp.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.flexpp=.flexpp.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.yy=.yy.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.YY=.YY.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.y++=.y++.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.Y++=.Y++.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.ypp=.ypp.cc)
GEN_LEX_YACC_CXX_FILES:=$$(GEN_LEX_YACC_CXX_FILES:.YPP=.YPP.cc)

GEN_LEX_YACC_HEADER_FILES:=$$(GEN_LEX_YACC_C_FILES:.c=.h) $$(GEN_LEX_YACC_CXX_FILES:.cc=.h)

#ADD LEX/YACC FILES TO THE MAIN GENERATED FILE LIST
GEN_SRC_C_FILES:=$$(GEN_SRC_C_FILES) $$(GEN_LEX_YACC_C_FILES)
GEN_SRC_CXX_FILES:=$$(GEN_SRC_CXX_FILES) $$(GEN_LEX_YACC_CXX_FILES)
GEN_SRC_HEADER_FILES:=$$(GEN_SRC_HEADER_FILES) $$(GEN_LEX_YACC_HEADER_FILES)

PROTOBUF_FILES:=$$(shell find $$(SRC_DIR) -name *.proto)
GEN_PROTOBUF_FILES:=$$(PROTOBUF_FILES:.proto=.pb.cc)
GEN_PROTOBUF_HEADER_FILES:=$$(PROTOBUF_FILES:.proto=.pb.h)

#ADD PROTOBUF FILES TO MAIL GENERATED FILE LIST
GEN_SRC_CXX_FILES:=$$(GEN_SRC_CXX_FILES) $$(GEN_PROTOBUF_FILES)
GEN_SRC_HEADER_FILES:=$$(GEN_SRC_HEADER_FILES) $$(GEN_PROTOBUF_HEADER_FILES)

#GENERATED_TARGETS SPANS ALL BUILD UNITS
GENERATED_TARGETS:=$$(GENERATED_TARGETS) $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES) $$(GEN_SRC_HEADER_FILES)
.PRECIOUS: $$(GENERATED_TARGETS)

#REMOVE GEN_SRC_CXX_FILES AND GEN_SRC_C_FILES FROM SRC_FILES
SRC_CXX_FILES:=$$(filter-out $$(GEN_SRC_CXX_FILES), $$(SRC_CXX_FILES))
SRC_C_FILES:=$$(filter-out $$(GEN_SRC_C_FILES), $$(SRC_C_FILES))


SRC_FILES:=$$(SRC_CXX_FILES) $$(SRC_C_FILES)


ifneq ($$(UNIT_TEST),NONE)

$$(shell mkdir -p "$$(TEST_SRC_DIR)")

TEST_DIRS:= $$(shell find $$(TEST_SRC_DIR) -type d)
TEST_CXX_FILES := $$(shell find $$(TEST_SRC_DIR) -name *.cc  -o -name *.cp  \
                                              -o -name *.cxx -o -name *.cpp \
                                              -o -name *.CPP -o -name *.c++ \
                                              -o -name *.C)

TEST_C_FILES := $$(shell find $$(TEST_SRC_DIR) -name *.c)
TEST_SRC_FILES := $$(TEST_CXX_FILES) $$(TEST_C_FILES)

endif


endef


################################################################################
#                            APPLICATION TEMPLATE                              #
################################################################################

# VARIABLE PRECONDITIONS
# SRC_BASE_DIR
# TEST_BASE_DIR
# OBJ_BASE_DIR

#1 - APP NAME
#2 - ADD DIR (relative to src)
#3 - UNIT TEST (GTEST, CPPUNIT, NONE)
#4 - EXTERNAL LIBRARIES
#5 - APP COMPILER FLAGS (e.g. EXTRA INCLUDE DIRECTORIES)
#6 - APP SPECIFIC LD FLAGS
define app =

APP_NAME:=$(1)
APP_DIR:=$(2)
UNIT_TEST:=$(3)
MY_EXTERNALS:=$(4)
MY_COMPILE_FLAGS:=$(5)
MY_LDFLAGS:=$(6)

SRC_MAIN_FUNC_SRC_FILE:=$$(APP_NAME).cpp

ifneq ($$(strip $$(APP_DIR)),)
APP_DIR:=$$(APP_DIR)/
endif


################################################################################

#BASE DIRECTORIES DEFINED IN MAIN MAKEFILE
#SRC_BASE_DIR = src/
#TEST_BASE_DIR = test/
#LIB_DIR = libs/
#CUSTOM_MAKE_DIR = make/
#CONFIG_DIR = config/
#BUILD_BASE_DIR = build/

#BUILD_DIR = $(BUILD_BASE_DIR)$(CONFIG)/
#TARGET_DIR = $(BUILD_DIR)$(shell uname -s)-$(shell arch)/
#OBJ_BASE_DIR = $(TARGET_DIR)objs/


SRC_DIR:=$$(SRC_BASE_DIR)$$(APP_DIR)
TEST_SRC_DIR:=$$(TEST_BASE_DIR)$$(APP_DIR)

$$(eval $$(call getSourceFiles))

MY_CFLAGS:=$$(CFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS)
MY_CXXFLAGS:=$$(CXXFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS)

MY_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS)

MY_LEX_FLAGS:=$$(LEX_FLAGS) $$(MY_LEX_FLAGS)

MY_CPPCHECK_FLAGS:= -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS)                   \
                    --enable=warning --enable=style --enable=performance  \
                    --enable=portability --suppress=unusedFunction  -q 

ifeq ($$(UNIT_TEST),GTEST)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l gtest -l gtest_main -l pthread 
endif

ifeq ($$(UNIT_TEST),CPPUNIT)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l cppunit 
endif

#USE g++ to link if there are C++ files present
ifneq ($$(strip $$(SRC_CXX_FILES) $$(GEN_SRC_CXX_FILES)),)
LD=$$(LDXX)
endif

ifneq ($$(strip $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)),)
$$(eval $$(call clean_generated_files_rule, $$(SRC_DIR), $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES) $$(GEN_SRC_HEADER_FILES)) )
endif

ifneq ($$(MAKECMDGOALS),clean)
ifneq ($$(MAKECMDGOALS),clean-docs)
ifneq ($$(MAKECMDGOALS),clean-all)
ifneq ($$(MAKECMDGOALS),docs)

################################################################################
#                                CPP CHECK TARGET                              #
################################################################################

$$(eval $$(call cppcheck_rules, $$(APP_NAME),          \
                                $$(MY_CPPCHECK_FLAGS), \
                                $$(SRC_DIR)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call cppcheck_rules, $$(APP_NAME)-test,     \
                                $$(MY_CPPCHECK_FLAGS), \
                                $$(TEST_SRC_DIR)))
endif

################################################################################
#                               CLANG-CHECK TARGET                             #
################################################################################

$$(eval $$(call clang_check_rules, $$(APP_NAME),      \
                                   $$(SRC_FILES),     \
                                   $$(MY_CXXFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_check_rules, $$(APP_NAME)-test,  \
                                   $$(TEST_SRC_FILES), \
                                   $$(MY_CXXFLAGS)))
endif

ifneq ($$(MAKECMDGOALS),analyze)

################################################################################
#                               CLANG-FORMAT TARGET                            #
################################################################################

$$(eval $$(call clang_format_rules, $$(APP_NAME),  \
                                    $$(SRC_FILES)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_format_rules, $$(APP_NAME)-test,  \
                                    $$(TEST_SRC_FILES)))
endif


ifneq ($$(MAKECMDGOALS),format)

################################################################################
#                            SETUP BUILD DIRECTORY                             #
################################################################################

SRC_OBJ_DIRS:=$$(addprefix $$(OBJ_BASE_DIR),$$(SRC_DIRS))
$$(shell mkdir -p $$(SRC_OBJ_DIRS))

#Identify all object files that need to be created based on the source files
$$(eval $$(call srcToObj, SRC_OBJ_FILES,    \
                          $$(OBJ_BASE_DIR), \
						  $$(SRC_FILES) $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)))


#IF UNIT_TEST
ifneq ($$(UNIT_TEST),NONE)

#SETUP TEST BUILD DIRECTORY
TEST_OBJ_DIRS:= $$(addprefix $$(OBJ_BASE_DIR),$$(TEST_DIRS))
$$(shell mkdir -p $$(TEST_OBJ_DIRS))

$$(eval $$(call srcToObj, TEST_OBJ_FILES, $$(OBJ_BASE_DIR),$$(TEST_SRC_FILES)))

TEST_SRC_OBJ_FILES := $$(SRC_OBJ_FILES)

#GENERATE MODIFIED OBJECT FILE THAT CONTAINING THE MAIN() FUNCTION TO PREVENT 
#THE TEST MAIN AND THE PROGRAM MAIN FROM CONFLICTING
SRC_MAIN_FUNC_SRC_FILE := $$(SRC_BASE_DIR)$$(APP_DIR)$$(SRC_MAIN_FUNC_SRC_FILE)
$$(eval $$(call srcToObj, SRC_MAIN_FUNC_OBJ_FILE, $$(OBJ_BASE_DIR),$$(SRC_MAIN_FUNC_SRC_FILE)))

#FILTER OUT THE OBJECT FILE CONTAINING THE PROGRAM'S MAIN FUNCTION FROM THE OBJECTS TO LINK THE UNIT TEST WITH
TEST_SRC_OBJ_FILES := $$(filter-out $$(SRC_MAIN_FUNC_OBJ_FILE), \
                                    $$(TEST_SRC_OBJ_FILES))

#ADD MODIFIED MAIN FUNCTION OBJECT FILE TO THE OBJECTS TO LINK THE UNIT TEST WITH
TEST_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.o=-app_main.o)
TEST_SRC_OBJ_FILES := $$(TEST_SRC_OBJ_FILES) $$(TEST_MAIN_FUNC_OBJ_FILE)

#CREATE RULE TO GENERATE THE MODIFIED MAIN FUNCTION OBJECT FILE FROM THE ORIGINAL MAIN FUNCTION OBJECT FILE
$$(eval $$(call objcopy_rules,$$(TEST_MAIN_FUNC_OBJ_FILE),    \
                              $$(SRC_MAIN_FUNC_OBJ_FILE),     \
                              --redefine-sym main=app_main))

endif

################################################################################
#                            CODE GENERATION RULES                             #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call lex_directory_rules,$$(bdir),$$(MY_LEX_FLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call yacc_directory_rules,$$(bdir),$$(MY_YACC_FLAGS))))

#PROTOBUF GENERATION ALSO GENERATES DEPENDENCIES SO WE NEED OBJ_BASE_DIR
$$(foreach bdir,$$(SRC_DIRS),                                      \
    $$(eval $$(call protobuf_directory_rules,$$(OBJ_BASE_DIR),     \
	                                         $$(bdir),             \
											 $$(MY_PROTOC_FLAGS))))


ifneq ($$(MAKECMDGOALS),generate-code)

################################################################################
#                                 LINK RULES                                   #
################################################################################

$$(eval $$(call std_link_rules,$$(TARGET_DIR),$$(APP_NAME),        \
                               $$(SRC_OBJ_FILES) $$(MY_EXTERNALS), \
                               $$(MY_LDFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call test_link_rules,$$(TARGET_DIR),$$(APP_NAME)-test,                           \
                                $$(TEST_SRC_OBJ_FILES) $$(TEST_OBJ_FILES) $$(MY_EXTERNALS), \
                                $$(MY_TEST_LDFLAGS)))
endif

################################################################################
#                                COMPILE RULES                                 #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))


ifneq ($$(UNIT_TEST),NONE)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))
endif

################################################################################
#                       AUTOMATIC DEPENDENCY GENERATION                        #
################################################################################

-include $$(addprefix $$(OBJ_BASE_DIR),$$(PROTOBUF_FILES:.proto=.proto.d))

-include $$(SRC_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)
-include $$(TEST_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))
endif


endif
endif
endif
endif
endif
endif
endif

endef


################################################################################
#         LIBRARY TEMPLATE  (GENERATE BOTH STATIC AND DYNAMIC VERSIONS)        #
################################################################################

# VARIABLE PRECONDITIONS
# SRC_BASE_DIR
# TEST_BASE_DIR
# OBJ_BASE_DIR

#1 - LIBRARY NAME
#2 - ADD DIR (relative to src)
#3 - VERSION (CURRENT.REVISION.AGE)
#4 - UNIT TEST (GTEST, CPPUNIT, NONE)
#5 - EXTERNAL LIBRARIES
#6 - LIBRARY COMPILER FLAGS (e.g. EXTRA INCLUDE DIRECTORIES)
#7 - LIBRARY SPECIFIC LD FLAGS
define library =

MY_LIB_NAME:=$(1)
MY_LIB_DIR:=$(2)
VERSION:=$(3)
UNIT_TEST:=$(4)
MY_EXTERNALS:=$(5)
MY_COMPILE_FLAGS:=$(6)
MY_LDFLAGS:=$(7)

ifneq ($$(strip $$(MY_LIB_DIR)),)
MY_LIB_DIR:=$$(MY_LIB_DIR)/
endif

################################################################################

#BASE DIRECTORIES DEFINED IN MAIN MAKEFILE
#SRC_BASE_DIR = src/
#TEST_BASE_DIR = test/
#LIB_DIR = libs/
#CUSTOM_MAKE_DIR = make/
#CONFIG_DIR = config/
#BUILD_BASE_DIR = build/

SRC_DIR:=$$(SRC_BASE_DIR)$$(MY_LIB_DIR)
TEST_SRC_DIR:=$$(TEST_BASE_DIR)$$(MY_LIB_DIR)

$$(eval $$(call getSourceFiles))

MY_CFLAGS := $$(CFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS)
MY_CXXFLAGS := $$(CXXFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS)
MY_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS)
MY_ARFLAGS:=$$(ARFLAGS)

MY_SO_CFLAGS:=$$(MY_CFLAGS) -fPIC
MY_SO_CXXFLAGS:=$$(MY_CXXFLAGS) -fPIC
MY_SO_LDFLAGS:= $$(MY_LDFLAGS) -shared -Wl,-soname,$$(MY_LIB_NAME).so -ldl


MY_CPPCHECK_FLAGS:= -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS) -q               \
                    --enable=warning --enable=style --enable=performance \
                    --enable=portability --suppress=unusedFunction 

#USE g++ to link if there are C++ files present
ifeq ($$(UNIT_TEST),GTEST)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l gtest -l gtest_main -l pthread
endif

ifeq ($$(UNIT_TEST),CPPUNIT)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l cppunit
endif

ifneq ($$(strip $$(SRC_CXX_FILES) $$(GEN_SRC_CXX_FILES)),)
LD=$$(LDXX)
endif

ifneq ($$(strip $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)),)
$$(eval $$(call clean_generated_files_rule, $$(SRC_DIR), $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES) $$(GEN_SRC_HEADER_FILES)) )
endif

ifneq ($$(MAKECMDGOALS),clean)
ifneq ($$(MAKECMDGOALS),clean-docs)
ifneq ($$(MAKECMDGOALS),clean-all)
ifneq ($$(MAKECMDGOALS),docs)

################################################################################
#                                CPP CHECK TARGET                              #
################################################################################

$$(eval $$(call cppcheck_rules,$$(MY_LIB_NAME),        \
                               $$(MY_CPPCHECK_FLAGS),  \
                               $$(SRC_DIR)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call cppcheck_rules, $$(MY_LIB_NAME)-test,  \
                                $$(MY_CPPCHECK_FLAGS), \
                                $$(TEST_SRC_DIR)))
endif


################################################################################
#                               CLANG-CHECK TARGET                             #
################################################################################

$$(eval $$(call clang_check_rules, $$(MY_LIB_NAME),  \
                                   $$(SRC_FILES),    \
                                   $$(MY_CXXFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_check_rules, $$(MY_LIB_NAME)-test,   \
                                   $$(TEST_SRC_FILES),     \
                                   $$(MY_CXXFLAGS)))
endif

ifneq ($$(MAKECMDGOALS),analyze)

################################################################################
#                               CLANG-FORMAT TARGET                            #
################################################################################

$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME), \
                                    $$(SRC_FILES)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME)-test, \
                                    $$(TEST_SRC_FILES)))
endif


ifneq ($$(MAKECMDGOALS),format)


################################################################################
#                            SETUP BUILD DIRECTORY                             #
################################################################################

LIB_OBJ_BASE_DIR:= $$(OBJ_BASE_DIR)lib/
SO_OBJ_BASE_DIR:= $$(OBJ_BASE_DIR)so/

LIB_OBJ_DIRS:= $$(addprefix $$(LIB_OBJ_BASE_DIR),$$(SRC_DIRS))
SO_OBJ_DIRS:= $$(addprefix $$(SO_OBJ_BASE_DIR),$$(SRC_DIRS))

$$(shell mkdir -p $$(LIB_OBJ_DIRS))
$$(shell mkdir -p $$(SO_OBJ_DIRS))

#Identify all object files that need to be created based on the source files
$$(eval $$(call srcToObj, SRC_LIB_OBJ_FILES, $$(LIB_OBJ_BASE_DIR),$$(SRC_FILES) $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)))
$$(eval $$(call srcToObj, SRC_SO_OBJ_FILES, $$(SO_OBJ_BASE_DIR),$$(SRC_FILES) $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)))


ifneq ($$(UNIT_TEST),NONE)

$$(shell mkdir -p "$$(TEST_SRC_DIR)")

TEST_OBJ_DIRS:= $$(addprefix $$(OBJ_BASE_DIR),$$(TEST_DIRS))
$$(shell mkdir -p $$(TEST_OBJ_DIRS))

$$(eval $$(call srcToObj, TEST_OBJ_FILES, $$(OBJ_BASE_DIR),$$(TEST_SRC_FILES)))

endif

################################################################################
#                            CODE GENERATION RULES                             #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call lex_directory_rules,$$(bdir),$$(MY_LEX_FLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call yacc_directory_rules,$$(bdir),$$(MY_YACC_FLAGS))))

#PROTOBUF GENERATION ALSO GENERATES DEPENDENCIES SO WE NEED OBJ_BASE_DIR
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call protobuf_directory_rules,$$(LIB_OBJ_BASE_DIR),$$(bdir),$$(MY_PROTOC_FLAGS))))

ifneq ($$(MAKECMDGOALS),generate-code)

################################################################################
#                                 LINK RULES                                   #
################################################################################

$$(eval $$(call lib_link_rules, $$(TARGET_DIR),$$(MY_LIB_NAME).a,       \
                                $$(SRC_LIB_OBJ_FILES) $$(MY_EXTERNALS), \
                                $$(MY_ARFLAGS)))

$$(eval $$(call std_link_rules, $$(TARGET_DIR),$$(MY_LIB_NAME).so.$$(VERSION), \
                                $$(SRC_SO_OBJ_FILES) $$(MY_EXTERNALS),         \
                                $$(MY_SO_LDFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call test_link_rules, $$(TARGET_DIR),$$(MY_LIB_NAME)-test,  \
            $$(TEST_OBJ_FILES) $$(SRC_LIB_OBJ_FILES) $$(MY_EXTERNALS), \
            $$(MY_TEST_LDFLAGS)))
endif

################################################################################
#                                COMPILE RULES                                 #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_directory_rules,$$(LIB_OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_directory_rules,$$(LIB_OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_directory_rules,$$(SO_OBJ_BASE_DIR),$$(bdir),$$(MY_SO_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_directory_rules,$$(SO_OBJ_BASE_DIR),$$(bdir),$$(MY_SO_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))
endif

################################################################################
#                       AUTOMATIC DEPENDENCY GENERATION                        #
################################################################################

#PROTO DEPENDENCIES ONLY EXIST IN LIB_OBJ_BASE_DIR -- IT DOESN'T NEED TO EXIST
#IN BOTH PLACES BECASE IT'S DEPENDENCEIS TO CREATE THE SOURCE FILE -- NOT OBJECT FILE
-include $$(addprefix $$(LIB_OBJ_BASE_DIR),$$(PROTOBUF_FILES:.proto=.proto.d))

-include $$(SRC_LIB_OBJ_FILES:.o=.d)
-include $$(SRC_SO_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_dependency_rules,$$(LIB_OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_dependency_rules,$$(LIB_OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_dependency_rules, $$(SO_OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_dependency_rules, $$(SO_OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)

-include $$(TEST_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

endif

endif
endif
endif
endif
endif
endif
endif

endef



################################################################################
#                          STATIC LIBRARY TEMPLATE                             #
################################################################################

# VARIABLE PRECONDITIONS
# SRC_BASE_DIR
# TEST_BASE_DIR
# OBJ_BASE_DIR

#1 - LIBRARY NAME
#2 - ADD DIR (relative to src)
#3 - VERSION (CURRENT.REVISION.AGE)
#4 - UNIT TEST (GTEST, CPPUNIT, NONE)
#5 - EXTERNAL LIBRARIES
#6 - LIBRARY COMPILER FLAGS (e.g. EXTRA INCLUDE DIRECTORIES)
#7 - LIBRARY SPECIFIC LD FLAGS
define static_library =

MY_LIB_NAME:=$(1)
MY_LIB_DIR:=$(2)
VERSION:=$(3)
UNIT_TEST:=$(4)
MY_EXTERNALS:=$(5)
MY_COMPILE_FLAGS:=$(6)
MY_LDFLAGS:=$(7)

ifneq ($$(strip $$(MY_LIB_DIR)),)
MY_LIB_DIR:=$$(MY_LIB_DIR)/
endif

################################################################################

#BASE DIRECTORIES DEFINED IN MAIN MAKEFILE
#SRC_BASE_DIR = src/
#TEST_BASE_DIR = test/
#LIB_DIR = libs/
#CUSTOM_MAKE_DIR = make/
#CONFIG_DIR = config/
#BUILD_BASE_DIR = build/

SRC_DIR:=$$(SRC_BASE_DIR)$$(MY_LIB_DIR)
TEST_SRC_DIR:=$$(TEST_BASE_DIR)$$(MY_LIB_DIR)

$$(eval $$(call getSourceFiles))

MY_CFLAGS := $$(CFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS)
MY_CXXFLAGS := $$(CXXFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS)
MY_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS)
MY_ARFLAGS:=$$(ARFLAGS)


MY_CPPCHECK_FLAGS:= -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS) -q                \
                    --enable=warning --enable=style --enable=performance  \
                    --enable=portability --suppress=unusedFunction 

#USE g++ to link if there are C++ files present
ifeq ($$(UNIT_TEST),GTEST)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l gtest -l gtest_main -l pthread
endif

ifeq ($$(UNIT_TEST),CPPUNIT)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l cppunit
endif

ifneq ($$(strip $$(SRC_CXX_FILES) $$(GEN_SRC_CXX_FILES)),)
LD=$$(LDXX)
endif

ifneq ($$(strip $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)),)
$$(eval $$(call clean_generated_files_rule, $$(SRC_DIR), $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES) $$(GEN_SRC_HEADER_FILES)) )
endif

ifneq ($$(MAKECMDGOALS),clean)
ifneq ($$(MAKECMDGOALS),clean-docs)
ifneq ($$(MAKECMDGOALS),clean-all)
ifneq ($$(MAKECMDGOALS),docs)

################################################################################
#                                CPP CHECK TARGET                              #
################################################################################

$$(eval $$(call cppcheck_rules,$$(MY_LIB_NAME),        \
                               $$(MY_CPPCHECK_FLAGS),  \
                               $$(SRC_DIR)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call cppcheck_rules, $$(MY_LIB_NAME)-test,  \
                                $$(MY_CPPCHECK_FLAGS), \
                                $$(TEST_SRC_DIR)))
endif


################################################################################
#                               CLANG-CHECK TARGET                             #
################################################################################

$$(eval $$(call clang_check_rules, $$(MY_LIB_NAME),  \
                                   $$(SRC_FILES),    \
                                   $$(MY_CXXFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_check_rules, $$(MY_LIB_NAME)-test,   \
                                   $$(TEST_SRC_FILES),     \
                                   $$(MY_CXXFLAGS)))
endif

ifneq ($$(MAKECMDGOALS),analyze)

################################################################################
#                               CLANG-FORMAT TARGET                            #
################################################################################

$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME), \
                                    $$(SRC_FILES)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME)-test, \
                                    $$(TEST_SRC_FILES)))
endif


ifneq ($$(MAKECMDGOALS),format)


################################################################################
#                            SETUP BUILD DIRECTORY                             #
################################################################################

SRC_OBJ_DIRS:= $$(addprefix $$(OBJ_BASE_DIR),$$(SRC_DIRS))

$$(shell mkdir -p $$(SRC_OBJ_DIRS))

#Identify all object files that need to be created based on the source files
$$(eval $$(call srcToObj, SRC_OBJ_FILES, $$(OBJ_BASE_DIR),$$(SRC_FILES) $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)))


ifneq ($$(UNIT_TEST),NONE)

$$(shell mkdir -p "$$(TEST_SRC_DIR)")

TEST_OBJ_DIRS:= $$(addprefix $$(OBJ_BASE_DIR),$$(TEST_DIRS))
$$(shell mkdir -p $$(TEST_OBJ_DIRS))

$$(eval $$(call srcToObj, TEST_OBJ_FILES, $$(OBJ_BASE_DIR),$$(TEST_SRC_FILES)))

endif

################################################################################
#                            CODE GENERATION RULES                             #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call lex_directory_rules,$$(bdir),$$(MY_LEX_FLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call yacc_directory_rules,$$(bdir),$$(MY_YACC_FLAGS))))

#PROTOBUF GENERATION ALSO GENERATES DEPENDENCIES SO WE NEED OBJ_BASE_DIR
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call protobuf_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_PROTOC_FLAGS))))

ifneq ($$(MAKECMDGOALS),generate-code)

################################################################################
#                                 LINK RULES                                   #
################################################################################

$$(eval $$(call lib_link_rules, $$(TARGET_DIR),$$(MY_LIB_NAME).a,   \
                                $$(SRC_OBJ_FILES) $$(MY_EXTERNALS), \
                                $$(MY_ARFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call test_link_rules, $$(TARGET_DIR),$$(MY_LIB_NAME)-test,  \
            $$(TEST_OBJ_FILES) $$(SRC_OBJ_FILES) $$(MY_EXTERNALS),     \
            $$(MY_TEST_LDFLAGS)))
endif

################################################################################
#                                COMPILE RULES                                 #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))
endif

################################################################################
#                       AUTOMATIC DEPENDENCY GENERATION                        #
################################################################################

-include $$(addprefix $$(OBJ_BASE_DIR),$$(PROTOBUF_FILES:.proto=.proto.d))

-include $$(SRC_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)

-include $$(TEST_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

endif

endif
endif
endif
endif
endif
endif
endif

endef


################################################################################
#                         DYNAMIC LIBRARY (SO) TEMPLATE                        #
################################################################################

# VARIABLE PRECONDITIONS
# SRC_BASE_DIR
# TEST_BASE_DIR
# OBJ_BASE_DIR

#1 - LIBRARY NAME
#2 - ADD DIR (relative to src)
#3 - VERSION (CURRENT.REVISION.AGE)
#4 - UNIT TEST (GTEST, CPPUNIT, NONE)
#5 - EXTERNAL LIBRARIES
#6 - LIBRARY COMPILER FLAGS (e.g. EXTRA INCLUDE DIRECTORIES)
#7 - LIBRARY SPECIFIC LD FLAGS
define so_library =

MY_LIB_NAME:=$(1)
MY_LIB_DIR:=$(2)
VERSION:=$(3)
UNIT_TEST:=$(4)
MY_EXTERNALS:=$(5)
MY_COMPILE_FLAGS:=$(6)
MY_LDFLAGS:=$(7)

ifneq ($$(strip $$(MY_LIB_DIR)),)
MY_LIB_DIR:=$$(MY_LIB_DIR)/
endif

################################################################################

#BASE DIRECTORIES DEFINED IN MAIN MAKEFILE
#SRC_BASE_DIR = src/
#TEST_BASE_DIR = test/
#LIB_DIR = libs/
#CUSTOM_MAKE_DIR = make/
#CONFIG_DIR = config/
#BUILD_BASE_DIR = build/

SRC_DIR:=$$(SRC_BASE_DIR)$$(MY_LIB_DIR)
TEST_SRC_DIR:=$$(TEST_BASE_DIR)$$(MY_LIB_DIR)

$$(eval $$(call getSourceFiles))


ifeq ($$(UNIT_TEST),GTEST)
MY_TEST_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS) -l gtest -l gtest_main -l pthread
endif

ifeq ($$(UNIT_TEST),CPPUNIT)
MY_TEST_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS) -l cppunit
endif

MY_CFLAGS := $$(CFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS) -fPIC
MY_CXXFLAGS := $$(CXXFLAGS) -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS) -fPIC
MY_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS) -shared -Wl,-soname,$$(MY_LIB_NAME).so -ldl
MY_ARFLAGS:=$$(ARFLAGS)

MY_CPPCHECK_FLAGS:= -I $$(SRC_DIR) $$(MY_COMPILE_FLAGS) -q               \
                    --enable=warning --enable=style --enable=performance \
                    --enable=portability --suppress=unusedFunction 



#USE g++ to link if there are C++ files present
ifneq ($$(strip $$(SRC_CXX_FILES) $$(GEN_SRC_CXX_FILES)),)
LD=$$(LDXX)
endif

ifneq ($$(strip $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)),)
$$(eval $$(call clean_generated_files_rule, $$(SRC_DIR), $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES) $$(GEN_SRC_HEADER_FILES)) )
endif

ifneq ($$(MAKECMDGOALS),clean)
ifneq ($$(MAKECMDGOALS),clean-docs)
ifneq ($$(MAKECMDGOALS),clean-all)
ifneq ($$(MAKECMDGOALS),docs)

################################################################################
#                                CPP CHECK TARGET                              #
################################################################################

$$(eval $$(call cppcheck_rules,$$(MY_LIB_NAME),        \
                               $$(MY_CPPCHECK_FLAGS),  \
                               $$(SRC_DIR)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call cppcheck_rules, $$(MY_LIB_NAME)-test,  \
                                $$(MY_CPPCHECK_FLAGS), \
                                $$(TEST_SRC_DIR)))
endif


################################################################################
#                               CLANG-CHECK TARGET                             #
################################################################################

$$(eval $$(call clang_check_rules, $$(MY_LIB_NAME),  \
                                   $$(SRC_FILES),    \
                                   $$(MY_CXXFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_check_rules, $$(MY_LIB_NAME)-test,   \
                                   $$(TEST_SRC_FILES),     \
                                   $$(MY_CXXFLAGS)))
endif

ifneq ($$(MAKECMDGOALS),analyze)

################################################################################
#                               CLANG-FORMAT TARGET                            #
################################################################################

$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME), \
                                    $$(SRC_FILES)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME)-test, \
                                    $$(TEST_SRC_FILES)))
endif


ifneq ($$(MAKECMDGOALS),format)


################################################################################
#                            SETUP BUILD DIRECTORY                             #
################################################################################

SRC_OBJ_DIRS:= $$(addprefix $$(OBJ_BASE_DIR),$$(SRC_DIRS))

$$(shell mkdir -p $$(SRC_OBJ_DIRS))

#Identify all object files that need to be created based on the source files
$$(eval $$(call srcToObj, SRC_OBJ_FILES, $$(OBJ_BASE_DIR),$$(SRC_FILES) $$(GEN_SRC_C_FILES) $$(GEN_SRC_CXX_FILES)))


ifneq ($$(UNIT_TEST),NONE)

$$(shell mkdir -p "$$(TEST_SRC_DIR)")

TEST_OBJ_DIRS:= $$(addprefix $$(OBJ_BASE_DIR),$$(TEST_DIRS))
$$(shell mkdir -p $$(TEST_OBJ_DIRS))

$$(eval $$(call srcToObj, TEST_OBJ_FILES, $$(OBJ_BASE_DIR),$$(TEST_SRC_FILES)))

endif

################################################################################
#                            CODE GENERATION RULES                             #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call lex_directory_rules,$$(bdir),$$(MY_LEX_FLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call yacc_directory_rules,$$(bdir),$$(MY_YACC_FLAGS))))

#PROTOBUF GENERATION ALSO GENERATES DEPENDENCIES SO WE NEED OBJ_BASE_DIR
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call protobuf_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_PROTOC_FLAGS))))

ifneq ($$(MAKECMDGOALS),generate-code)

################################################################################
#                                 LINK RULES                                   #
################################################################################


$$(eval $$(call std_link_rules, $$(TARGET_DIR),$$(MY_LIB_NAME).so.$$(VERSION), \
                                $$(SRC_OBJ_FILES) $$(MY_EXTERNALS),            \
                                $$(MY_LDFLAGS)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call test_link_rules, $$(TARGET_DIR),$$(MY_LIB_NAME)-test,  \
            $$(TEST_OBJ_FILES) $$(SRC_OBJ_FILES) $$(MY_EXTERNALS),     \
            $$(MY_TEST_LDFLAGS)))
endif

################################################################################
#                                COMPILE RULES                                 #
################################################################################

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_directory_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))
endif

################################################################################
#                       AUTOMATIC DEPENDENCY GENERATION                        #
################################################################################

-include $$(addprefix $$(OBJ_BASE_DIR),$$(PROTOBUF_FILES:.proto=.proto.d))

-include $$(SRC_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call cpp_dependency_rules, $$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call c_dependency_rules, $$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)

-include $$(TEST_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call cpp_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS))))
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call c_dependency_rules,$$(OBJ_BASE_DIR),$$(bdir),$$(MY_CFLAGS))))

endif

endif
endif
endif
endif
endif
endif
endif

endef
