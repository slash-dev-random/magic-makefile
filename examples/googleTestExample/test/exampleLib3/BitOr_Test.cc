#include "BitOr.h"

#include <limits.h>

#include "gtest/gtest.h"

class BitOrTest : public ::testing::Test
{
protected:
    virtual void SetUp() {}
    virtual void TearDown() {}
};

TEST_F(BitOrTest, twoValues)
{
    const int x = 0x1;
    const int y = 0x2;
    BitOr bitOr;
    EXPECT_EQ(0x3, bitOr.twoValues(x, y));
    EXPECT_EQ(0xFF, bitOr.twoValues(0xF0, 0xF));
}
