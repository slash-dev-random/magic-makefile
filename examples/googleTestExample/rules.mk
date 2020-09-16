
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
	@for src in $(2) ; do  \
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
	@$$(LD) $(4) -o $$@ $$^
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
	@$$(RM) $$@
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
	@$$(LD) $(4) -o $$@ $$^
endef

################################################################################
#                                COMPILE RULES                                 #
################################################################################
#1 - OBJCET BASE DIR
#2 - SOURCE DIR
#3 - CXX FLAGS
#4 - C FLAGS
define directory_rules =
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

$(1)$(2)%.o: $(2)%.c
	@echo "CC       $$<"
	@$$(CC) $(4) -c -o $$@ $$<

endef

#1 - OBJCET BASE DIR
#2 - SOURCE DIR
#3 - CXX FLAGS
#4 - C FLAGS
define dependency_rules =
$(1)$(2)%.d: $(2)%.cc
	@set -e; rm -f $$@; \
	$$(CXX) -M $(3) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

$(1)$(2)%.d: $(2)%.cp
	@set -e; rm -f $$@; \
	$$(CXX) -M $(3) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

$(1)$(2)%.d: $(2)%.cxx
	@set -e; rm -f $$@; \
	$$(CXX) -M $(3) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

$(1)$(2)%.d: $(2)%.cpp
	@set -e; rm -f $$@; \
	$$(CXX) -M $(3) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

$(1)$(2)%.d: $(2)%.CPP
	@set -e; rm -f $$@; \
	$$(CXX) -M $(3) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

$(1)$(2)%.d: $(2)%.c++
	@set -e; rm -f $$@; \
	$$(CXX) -M $(3) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

$(1)$(2)%.d: $(2)%.C
	@set -e; rm -f $$@; \
	$$(CXX) -M $(3) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

$(1)$(2)%.d: $(2)%.c
	@set -e; rm -f $$@; \
	$$(CC) -M $(4) $$< > $$@; \
	sed -i 's|.*:|$(1)$(2)$$*.o $$@:|g' $$@;

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

################################################################################
#                            APPLICATION TEMPLATE                              #
################################################################################

# VARIABLE PRECONDITIONS
# SRC_BASE_DIR
# TEST_BASE_DIR
# OBJS_BASE_DIR

#1 - APP NAME
#2 - ADD DIR (relative to src)
#3 - UNIT TEST (GTEST, CPPUNIT, NONE)
#4 - MY EXTERNALS
#5 - EXTRA INCLUDE DIRECTORIES (outside app dir)
#6 - APP SPECIFIC LD FLAGS
define app =

APP_NAME:=$(1)
APP_DIR:=$(2)
UNIT_TEST:=$(3)
MY_EXTERNALS:=$(4)
MY_INCLUDE_DIRS:=$(5)
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
#OBJS_BASE_DIR = $(TARGET_DIR)objs/

SRC_DIR:=$$(SRC_BASE_DIR)$$(APP_DIR)
TEST_SRC_DIR:=$$(TEST_BASE_DIR)$$(APP_DIR)

MY_CFLAGS:=$$(CFLAGS) -Wall -I $$(SRC_DIR) $$(MY_INCLUDE_DIRS)
MY_CXXFLAGS:=$$(CXXFLAGS) -Wall -I $$(SRC_DIR) $$(MY_INCLUDE_DIRS)

MY_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS)

MY_CPPCHECK_FLAGS:= -I $$(SRC_DIR) $$(MY_INCLUDE_DIRS)                   \
                    --enable=warning --enable=style --enable=performance \
                    --enable=portability --suppress=unusedFunction  -q 

ifeq ($$(UNIT_TEST),GTEST)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l gtest -l gtest_main -l pthread 
endif

ifeq ($$(UNIT_TEST),CPPUNIT)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l cppunit 
endif

$$(shell mkdir -p "$$(SRC_DIR)")

SRC_DIRS:= $$(shell find $$(SRC_DIR) -type d)
OBJ_DIRS:=$$(addprefix $$(OBJS_BASE_DIR),$$(SRC_DIRS))

$$(shell mkdir -p $$(OBJ_DIRS))


SRC_CXX_FILES:=$$(shell find $$(SRC_DIR) -name *.cc -o  -name *.cp  \
                                      -o -name *.cxx -o -name *.cpp \
                                      -o -name *.CPP -o -name *.c++ \
                                      -o -name *.C)

SRC_C_FILES:=$$(shell find $$(SRC_DIR) -name *.c)

SRC_FILES:=$$(SRC_CXX_FILES) $$(SRC_C_FILES)

#Identify all object files that need to be created based on the source files
SRC_OBJ_FILES := $$(addprefix $$(OBJS_BASE_DIR),$$(SRC_FILES))
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cc=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cp=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cxx=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cpp=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.CPP=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.c++=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.C=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.c=.o)

#USE g++ to link if there are C++ files present
ifneq ($$(strip $$(SRC_CXX_FILES)),)
LD=$$(LDXX)
endif


##IF UNIT_TEST
ifneq ($$(UNIT_TEST),NONE)

$$(shell mkdir -p "$$(TEST_SRC_DIR)")

TEST_DIRS:= $$(shell find $$(TEST_SRC_DIR) -type d)
TEST_OBJS_DIRS:= $$(addprefix $$(OBJS_BASE_DIR),$$(TEST_DIRS))

$$(shell mkdir -p $$(TEST_OBJS_DIRS))

TEST_CXX_FILES := $$(shell find $$(TEST_SRC_DIR) -name *.cc -o  -name *.cp  \
                                              -o -name *.cxx -o -name *.cpp \
                                              -o -name *.CPP -o -name *.c++ \
                                              -o -name *.C)

TEST_C_FILES := $$(shell find $$(TEST_SRC_DIR) -name *.c)

TEST_SRC_FILES := $$(TEST_CXX_FILES) $$(TEST_C_FILES)

TEST_OBJ_FILES := $$(addprefix $$(OBJS_BASE_DIR),$$(TEST_SRC_FILES))
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cc=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cp=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cxx=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cpp=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.CPP=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.c++=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.C=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.c=.o)

TEST_SRC_OBJ_FILES := $$(SRC_OBJ_FILES)

SRC_MAIN_FUNC_SRC_FILE := $$(SRC_BASE_DIR)$$(APP_DIR)$$(SRC_MAIN_FUNC_SRC_FILE)
SRC_MAIN_FUNC_OBJ_FILE := $$(OBJS_BASE_DIR)$$(SRC_MAIN_FUNC_SRC_FILE)

SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.cc=.o)
SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.cp=.o)
SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.cxx=.o)
SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.cpp=.o)
SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.CPP=.o)
SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.c++=.o)
SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.C=.o)
SRC_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.c=.o)

TEST_SRC_OBJ_FILES := $$(filter-out $$(SRC_MAIN_FUNC_OBJ_FILE), \
                                    $$(TEST_SRC_OBJ_FILES))

TEST_MAIN_FUNC_OBJ_FILE := $$(SRC_MAIN_FUNC_OBJ_FILE:.o=-app_main.o)
TEST_SRC_OBJ_FILES := $$(TEST_SRC_OBJ_FILES) $$(TEST_MAIN_FUNC_OBJ_FILE)

$$(eval $$(call objcopy_rules,$$(TEST_MAIN_FUNC_OBJ_FILE),    \
                              $$(SRC_MAIN_FUNC_OBJ_FILE),     \
                              --redefine-sym main=app_main))

endif

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
$$(eval $$(call clang_check_rules, $$(APP_NAME)-test,      \
                                   $$(TEST_SRC_FILES),     \
                                   $$(MY_CXXFLAGS)))
endif

################################################################################
#                               CLANG-FORMAT TARGET                            #
################################################################################

$$(eval $$(call clang_format_rules, $$(APP_NAME),  \
                                    $$(SRC_FILES)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_format_rules, $$(APP_NAME)-test,  \
                                    $$(TEST_SRC_FILES)))
endif

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

$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call directory_rules,$$(OBJS_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call directory_rules,$$(OBJS_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))
endif

################################################################################
#                       AUTOMATIC DEPENDENCY GENERATION                        #
################################################################################

-include $$(SRC_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call dependency_rules,$$(OBJS_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)
-include $$(TEST_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call dependency_rules,$$(OBJS_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))
endif

endef


################################################################################
#                              LIBRARY TEMPLATE                                #
################################################################################

# VARIABLE PRECONDITIONS
# SRC_BASE_DIR
# TEST_BASE_DIR
# OBJS_BASE_DIR

#1 - LIBRARY NAME
#2 - ADD DIR (relative to src)
#3 - VERSION (CURRENT.REVISION.AGE)
#4 - UNIT TEST (GTEST, CPPUNIT, NONE)
#5 - MY EXTERNALS
#6 - EXTRA INCLUDE DIRECTORIES (outside library dir)
#7 - APP SPECIFIC LD FLAGS
define library =

MY_LIB_NAME:=$(1)
MY_LIB_DIR:=$(2)
VERSION:=$(3)
UNIT_TEST:=$(4)
MY_EXTERNALS:=$(5)
MY_INCLUDE_DIRS:=$(6)
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

MY_CFLAGS := $$(CFLAGS) -Wall -I $$(SRC_DIR) $$(MY_INCLUDE_DIRS)
MY_CXXFLAGS := $$(CXXFLAGS) -Wall -I $$(SRC_DIR) $$(MY_INCLUDE_DIRS)
MY_LDFLAGS:=$$(LDFLAGS) $$(MY_LDFLAGS)
MY_ARFLAGS:=$$(ARFLAGS)

MY_SO_CFLAGS:=$$(MY_CFLAGS) -fPIC
MY_SO_CXXFLAGS:=$$(MY_CXX_FLAGS) -fPIC
MY_SO_LDFLAGS:= $$(LDFLAGS) -shared -Wl,-soname,$$(MY_LIB_NAME).so -ldl


MY_CPPCHECK_FLAGS:= -I $$(SRC_DIR) $$(MY_INCLUDE_DIRS) -q                \
                    --enable=warning --enable=style --enable=performance \
                    --enable=portability --suppress=unusedFunction 

ifeq ($$(UNIT_TEST),GTEST)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l gtest -l gtest_main -l pthread
endif

ifeq ($$(UNIT_TEST),CPPUNIT)
MY_TEST_LDFLAGS:=$$(MY_LDFLAGS) -l cppunit
endif

$$(shell mkdir -p "$$(SRC_DIR)")

SRC_DIRS := $$(shell find $$(SRC_DIR) -type d)

LIB_OBJ_BASE_DIR:= $$(OBJS_BASE_DIR)lib/
SO_OBJ_BASE_DIR:= $$(OBJS_BASE_DIR)so/

SRC_LIB_OBJ_DIRS:= $$(addprefix $$(LIB_OBJ_BASE_DIR),$$(SRC_DIRS))
SRC_SO_OBJ_DIRS:= $$(addprefix $$(SO_OBJ_BASE_DIR),$$(SRC_DIRS))

$$(shell mkdir -p $$(SRC_LIB_OBJ_DIRS))
$$(shell mkdir -p $$(SRC_SO_OBJ_DIRS))

SRC_CXX_FILES := $$(shell find $$(SRC_DIR) -name *.cc -o  -name *.cp  \
                                        -o -name *.cxx -o -name *.cpp \
                                        -o -name *.CPP -o -name *.c++ \
                                        -o -name *.C)

SRC_C_FILES := $$(shell find $$(SRC_DIR) -name *.c)

SRC_FILES := $$(SRC_CXX_FILES) $$(SRC_C_FILES)


#Identify all object files that need to be created based on the source files
SRC_OBJ_FILES := $$(SRC_FILES)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cc=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cp=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cxx=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.cpp=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.CPP=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.c++=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.C=.o)
SRC_OBJ_FILES := $$(SRC_OBJ_FILES:.c=.o)


SRC_LIB_OBJ_FILES := $$(addprefix $$(LIB_OBJ_BASE_DIR),$$(SRC_OBJ_FILES))
SRC_SO_OBJ_FILES := $$(addprefix $$(SO_OBJ_BASE_DIR),$$(SRC_OBJ_FILES))

#USE g++ to link if there are C++ files present
ifneq ($$(strip $$(SRC_CXX_FILES)),)
LD=$$(LDXX)
endif

ifneq ($$(UNIT_TEST),NONE)

$$(shell mkdir -p "$$(TEST_SRC_DIR)")

TEST_DIRS:= $$(shell find $$(TEST_SRC_DIR) -type d)
TEST_OBJS_DIRS:= $$(addprefix $$(OBJS_BASE_DIR),$$(TEST_DIRS))

$$(shell mkdir -p $$(TEST_OBJS_DIRS))

TEST_CXX_FILES := $$(shell find $$(TEST_SRC_DIR) -name *.cc  -o -name *.cp  \
                                              -o -name *.cxx -o -name *.cpp \
                                              -o -name *.CPP -o -name *.c++ \
                                              -o -name *.C)

TEST_C_FILES := $$(shell find $$(TEST_SRC_DIR) -name *.c)

TEST_SRC_FILES := $$(TEST_CXX_FILES) $$(TEST_C_FILES)

TEST_OBJ_FILES := $$(addprefix $$(OBJS_BASE_DIR),$$(TEST_SRC_FILES))
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cc=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cp=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cxx=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.cpp=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.CPP=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.c++=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.C=.o)
TEST_OBJ_FILES := $$(TEST_OBJ_FILES:.c=.o)

endif


################################################################################
#                                CCP CHECK TARGET                              #
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

################################################################################
#                               CLANG-FORMAT TARGET                            #
################################################################################

$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME), \
                                    $$(SRC_FILES)))

ifneq ($$(UNIT_TEST),NONE)
$$(eval $$(call clang_format_rules, $$(MY_LIB_NAME)-test, \
                                    $$(TEST_SRC_FILES)))
endif

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


$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call directory_rules,$$(LIB_OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call directory_rules,$$(SO_OBJ_BASE_DIR),$$(bdir),$$(MY_SO_CXXFLAGS),$$(MY_SO_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call directory_rules,$$(OBJS_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))
endif

################################################################################
#                       AUTOMATIC DEPENDENCY GENERATION                        #
################################################################################


-include $$(SRC_LIB_OBJ_FILES:.o=.d)
-include $$(SRC_SO_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call dependency_rules,$$(LIB_OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))
$$(foreach bdir,$$(SRC_DIRS),$$(eval $$(call dependency_rules, $$(SO_OBJ_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))

ifneq ($$(UNIT_TEST),NONE)

-include $$(TEST_OBJ_FILES:.o=.d)
$$(foreach bdir,$$(TEST_DIRS),$$(eval $$(call dependency_rules,$$(OBJS_BASE_DIR),$$(bdir),$$(MY_CXXFLAGS),$$(MY_CFLAGS))))

endif


endef