#1 - APP NAME
#2 - ADD DIR (relative to src)
#3 - UNIT TEST (GTEST, CPPUNIT, NONE)
#4 - EXTERNAL LIBRARIES
#5 - APP COMPILER FLAGS (e.g. EXTRA INCLUDE DIRECTORIES)
#6 - APP SPECIFIC LD FLAGS

$(eval $(call app, ExtLibApp,  \
                   extLibApp,  \
                   NONE,         \
                   $(EXT_LIB_DIR)libexample.a $(EXT_LIB_DIR)libexample2.a,                      \
                   -I $(EXT_LIB_DIR)/include/exampleLib -I $(EXT_LIB_DIR)/include/exampleLib2,  \
                    ))
