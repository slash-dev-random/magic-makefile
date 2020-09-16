#1 - APP NAME
#2 - ADD DIR (relative to src)
#3 - UNIT TEST (GTEST, CPPUNIT, NONE)
#4 - MY EXTERNALS
#5 - EXTRA INCLUDE DIRECTORIES (outside app dir)
#6 - APP SPECIFIC LD FLAGS

$(eval $(call app, ExampleApp,                                                 \
                   exampleApp,                                                 \
                   GTEST,                                                      \
                   $(TARGET_DIR)libexample.a $(TARGET_DIR)libexample2.a,       \
                   -I $(SRC_BASE_DIR)exampleLib -I $(SRC_BASE_DIR)exampleLib2, \
                    ))
