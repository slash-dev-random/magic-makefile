#1 - LIBRARY NAME
#2 - ADD DIR (relative to src)
#3 - VERSION (CURRENT.REVISION.AGE)
#4 - UNIT TEST (GTEST, CPPUNIT, NONE)
#5 - MY EXTERNALS
#6 - EXTRA INCLUDE DIRECTORIES (outside library dir)
#7 - LIBRARY SPECIFIC LD FLAGS

$(eval $(call library, libprotobufprotocol,  \
                       protobufProtocolLib,  \
                       1.0.0,                \
                       NONE,                 \
                       ,                     \
                       ,                     \
                        ))

