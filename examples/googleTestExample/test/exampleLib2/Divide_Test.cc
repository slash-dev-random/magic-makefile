#include "Divide.h"

#include <limits.h>

#include "gtest/gtest.h"

class DivideTest : public ::testing::Test
{
protected:
    virtual void SetUp() {}
    virtual void TearDown()
    {
        // Code here will be called immediately after each test
        // (right before the destructor).
    }
};

TEST_F(DivideTest, twoValues)
{
    const int x = 4;
    const int y = 2;
    Divide divide;
    EXPECT_EQ(2, divide.twoValues(x, y));
    EXPECT_EQ(3, divide.twoValues(7, 2));
}
