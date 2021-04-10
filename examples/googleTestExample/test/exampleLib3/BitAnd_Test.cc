#include "BitAnd.h"

#include <limits.h>

#include "gtest/gtest.h"

class BitAndTest : public ::testing::Test
{
protected:
    virtual void SetUp() {}
    virtual void TearDown()
    {
        // Code here will be called immediately after each test
        // (right before the destructor).
    }
};

TEST_F(BitAndTest, twoValues)
{
    const int x = 0x1;
    const int y = 0x3;
    BitAnd bitAnd;
    EXPECT_EQ(0x1, bitAnd.twoValues(x, y));
    EXPECT_EQ(0xF0, bitAnd.twoValues(0xFF, 0xF0));
}
