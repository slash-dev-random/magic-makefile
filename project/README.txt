Basic C/C++ Makefile Template for Linux GCC Projects
Author: Benjamin Cox


This is a generic makefile for C/C++ projects in a Linux environment.  It is 
designed to do automatic dependency generation and linking -- it includes rules
to make applications as well as static and dynamic libraries.  The overall 
project settings are in the top-level makefile, and the build rules for the 
applications and libraries are in Makefile rules.mk.  Module instatiations 
should be places in the make/ directory.  Make sure the filename has the .mk
file extension.

The top-level makefile is designed to use the following build targets:
   * default - Build application(s) and/or library(ies) in project
   * test - Build unit-tests
   * docs - Generate doxygen documents
   * all - Build application(s) and/or library(ies) plus unit tests and docs
   * run-tests - Run all unit tests
   * analyze - Runs static analysis tools on the project
   * format - Calls clang-format on all source files.
   * clean - Cleans intermendiate files and complied applications and tests
   * clean-docs - Cleans generated documents
   * clean-all - Cleans all - docs and build files

Define your build apps & libraries in the make/ directory using the pre-defined
definitions provided by the makefile.  The makefile provides and app module and
a library module.  Both modules behave as follows:
   * The base source directory where the makefile looks for source files is the
     src/ directory
   * The base test directory where the makefile looks for the unit test source
     files is test/ directory
   * External libraries that are not part of the build system should be put
     in the libs/ folder.
   * The final exectables/libraries/unit tests are put in the
     build/$(CONFIG)/$(OS)-$(ARCH)/ directory.
   * The intermediate object files and dependencies are put in the
     build/$(CONFIG)/$(OS)-$(ARCH)/objs
   * The configuration is specified by setting CONFIG variable (Debug
     is the default) (e.g. make CONFIG=Release)

The app module takes 6 parameters:
    1. App Name
    2. App Dir (relative to the src/ dirctory) - Necessary when a project 
       contains multiple build items.
    3. Unit Test Framework (GTEST, CPPUNIT, NONE).  All test source files should
       reside under the test/ directory.
    4. External build items needed to pass to the linker.  When item is within
       project be sure to use the TARGET_DIR variable (see examples below). When
       a library that is outside the build system is used, place it in the libs/
       directory and use the EXT_LIB_DIR variable (see example below)
    5. Extra include directories not under the app's directory, whether its a 
       library within the project or an external libary's header file in the
       libs/ directory.  (See examples below)
    6. Extra linker flags specific to this build item (e.g. -l pthread)

The library module takes 7 parameters.  The library module will build a static
library (.a) as well as a dynamic library (.so):
    1. Library Name
    2. Library Dir (relative to the src/ dirctory) - Necessary when a project 
       contains multiple build items.
    3. Version (<Current>.<Revision>.<Age>)
    4. Unit Test Framework (GTEST, CPPUNIT, NONE).  All test source files should
       reside under the test/ directory.
    5. External build items needed to pass to the linker.  When item is within
       project be sure to use the TARGET_DIR variable (see examples below). When
       a library that is outside the build system is used, place it in the libs/
       directory and use the EXT_LIB_DIR variable (see example below)
    6. Extra include directories not under the app's directory, whether its a 
       library within the project or an external libary's header file in the
       libs/ directory.  (See examples below)
    7. Extra linker flags specific to this build item

Below are examples of different projects with different build setups:

* A project with asingle app with no exteral build dependencies within the app
  itself:

$(eval $(call app, helloWorld,  \
                   ,            \
                   NONE,        \
                   ,            \
                   ,            \
                   ))

* A project with an app and a library that is used by the app

$(eval $(call app, ExampleApp,                    \
                   exampleAppDir,                 \
                   NONE,                          \
                   $(TARGET_DIR)libexample.a  ,   \
                   -I $(SRC_BASE_DIR)exampleLib,  \
                    ))

$(eval $(call library, libexample,     \
                       exampleLibDir,  \
                       1.0.0,          \
                       NONE,           \
                       ,               \
                       ,               \
                        ))


* A project that uses an system intalled library (pthread in this case)

$(eval $(call app, threadApp,     \
                   threadAppDir,  \
                   NONE,          \
                   ,              \
                   ,              \
                   -l pthread))

* A project that uses a external library placed in the $(EXT_LIB_DIR).

$(eval $(call app, ExtLibApp,                            \
                   extLibAppDir,                         \
                   NONE,                                 \
                   $(EXT_LIB_DIR)libexample.a            \
                   -I $(EXT_LIB_DIR)include/exampleLib  \
                    ))

Flex/Bison (Lex/Yacc):
   The makefile automatically supports flex and bison generated code.  The
makefile uses the lex extension to determine whether to generate a C or C++
lexer/parser.  Lex extensions .l .lex and .flex generate a C lexer while
extensions .ll .lex++ .flex++ .lexpp and .flexpp genrate a C++ lexer. Bison
extension .y is generated into a C parser while .yy .y++ and .ypp extensions
are generated into a C++ parser.

IMPORTANT:
   Generated file name deviate from the standard naming convention and instead
are output as the lex/yacc file name with the .c(c) and .h extentions appended.
I.E. parser.l --> lexer.l.{c,h} and lexer.ll --> lexer.ll.{cc,h}
     parser.y --> parser.y.{c,h} and parcer.yy --> parser.yy.{cc,h}


Future Development:
   * Add support for more code generation tools (e.g. protoBuf, ...)
   * Add support for building RPM and DEB packages
   * Add configuration to llow profiling using gprof and/or gcov

