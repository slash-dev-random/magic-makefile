// mutex example
#include <iostream>  // std::cout
#include <mutex>     // std::mutex
#include <thread>    // std::thread

std::mutex mtx;  // mutex for critical section

void print_block(int n, char c)
{
    // critical section (exclusive access to std::cout signaled by locking mtx):

    for(int i = 0; i < n; ++i)
    {
        mtx.lock();
        std::cout << c;
        mtx.unlock();
    }

    mtx.lock();
    std::cout << '\n';
    mtx.unlock();
}

int main(int argc, char** argv)
{
    std::thread th1(print_block, 500000, '*');
    std::thread th2(print_block, 500000, '$');

    th1.join();
    th2.join();

    return 0;
}