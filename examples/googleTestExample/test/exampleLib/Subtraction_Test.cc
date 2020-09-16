#include "Subtraction.h"

#include <limits.h>

#include "gtest/gtest.h"

class SubtractionTest : public ::testing::Test
{
protected:
    virtual void SetUp() {}
    virtual void TearDown() {}
};

TEST_F(SubtractionTest, twoValues)
{
    const int x = 10;
    const int y = 3;
    Subtraction subtraction;
    EXPECT_EQ(7, subtraction.twoValues(x, y));
    EXPECT_EQ(5, subtraction.twoValues(8, 3));
}
