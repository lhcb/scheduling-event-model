#include "stlab/future.hpp"
#include "task_system.h"
#include <iostream>
#include <vector>
#include <thread>
#include <functional>
#include <chrono>
using namespace std::literals;

// create a simple pipeline which conserves the type passed along, 
// i.e. it chains together T->T operations...
template <typename Executor, typename T>
auto make_future(Executor&& executor, const std::vector<std::function<T(T)>>& c, T in ) {
   // if (c.empty()) return  make_ready_future(in);
   auto first = std::begin(c);
   auto fut = stlab::async( executor, *first, in ) ;
   while ( ++first != std::end(c) ) fut = fut.then( *first ) ;
   return fut;
}

// executors -- pick one!
auto thr_exec = [](auto f) { std::thread(std::move(f)).detach(); };
auto seq_exec = [](auto f) { f(); };
task_system _system;  auto task_exec = [](auto f) { _system.async(std::move(f)); };

// binary and trinary transforms
auto sum(double x, double y) { return x+y; }
auto prod(double x, double y, double z) { return x*y*z; }

// create unary transforms
template <typename T> auto times(T par) { return [=](auto x) { return par*x; }; }
template <typename T> auto plus(T par)  { return [=](auto x) { return par+x; }; }
template <typename T> auto sleep(T par) { return [=](auto x) { std::this_thread::sleep_for( par ) ; return x; }; }
template <typename T> auto print(T par) { return [=](auto x) { std::cout << par << x << std::endl; return x; }; }

int main() {
   // auto exec = seq_exec;
   // auto exec = thr_exec;
   auto exec = task_exec;
   auto fut1 = make_future( exec,
                            { print("start1: "), times(2.), sleep(2s), print("middle1: "), plus(3.), times(4.), print("end1: ") },
                            2. );
   auto fut2 = make_future( exec,
                            { print("start2: "), plus(12), print("middle2: "), sleep(500ms), print("end2: ") },
                            9 );
   auto fut3 = stlab::when_all( exec, sum,  fut1, fut2 );
   auto fut  = stlab::when_all( exec, prod, fut1, fut2, fut3 );

   auto result = fut.get_try(); // no fut.wait(), so we just poll...
   while (!result) { std::this_thread::sleep_for(500us); result = fut.get_try(); }
   std::cout << *result << std::endl;
}
