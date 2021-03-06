#1 - APP NAME
#2 - ADD DIR (relative to src)
#3 - UNIT TEST (GTEST, CPPUNIT, NONE)
#4 - MY EXTERNALS
#5 - EXTRA INCLUDE DIRECTORIES (outside app dir)
#6 - APP SPECIFIC LD FLAGS

$(eval $(call app, add_person,                            \
                   add_person,                            \
                   NONE,                                  \
                   $(TARGET_DIR)libprotobufprotocol.a ,   \
                   -I $(SRC_BASE_DIR)protobufProtocolLib, \
                   $(shell pkg-config  --libs protobuf)))

