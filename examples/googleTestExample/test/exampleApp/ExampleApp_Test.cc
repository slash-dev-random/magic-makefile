
#include <limits.h>

#include "gtest/gtest.h"

int my_xor(int a, int b);

class XORTest : public ::testing::Test
{
protected:
    virtual void SetUp() {}
    virtual void TearDown()
    {
        // Code here will be called immediately after each test
        // (right before the destructor).
    }
};

TEST_F(XORTest, my_xor)
{
    const int x = 0;
    const int y = 0xFFFF;

    EXPECT_EQ(y, my_xor(x, y));
    EXPECT_EQ(308, my_xor(123, 335));
}
