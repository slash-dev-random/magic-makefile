#1 - LIBRARY NAME
#2 - ADD DIR (relative to src)
#3 - VERSION (CURRENT.REVISION.AGE)
#4 - UNIT TEST (GTEST, CPPUNIT, NONE)
#5 - EXTERNAL LIBRARIES
#6 - LIBRARY COMPILER FLAGS (e.g. EXTRA INCLUDE DIRECTORIES)
#7 - APP SPECIFIC LD FLAGS

$(eval $(call static_library, libexample2,  \
                              exampleLib2,  \
                              1.0.0,       \
                              GTEST,       \
                              ,            \
                              ,            \
                              ))
