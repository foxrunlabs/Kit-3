////////////////////////////////////////////////////////////////////////////////
//
// Display Test
// Copyright (C) 2020 Ryan Clarke <kj6msg@icloud.com>
//
////////////////////////////////////////////////////////////////////////////////


#include "Display.hpp"
#include <iomanip>
#include <iostream>
#include <utility>
#include <verilated.h>


int main(int argc, char *argv[])
{
    Verilated::commandArgs(argc, argv);

    Display tb(true);

    auto prev_cycles{0U};
    auto prev_sync_states = std::make_pair(Display::sync_state::no_sync,
                                           Display::sync_state::no_sync);

    std::cout << std::left
              << std::setw(10)
              << "Cycles"
              << std::setw(10)
              << "Delta"
              << std::setw(10)
              << "HSYNC"
              << std::setw(10)
              << "VSYNC"
              << '\n'
              << "--------------------------------------------------\n";
    
    std::cout << std::left
              << std::setw(10)
              << tb.cycles()
              << std::setw(10)
              << tb.cycles() - prev_cycles
              << std::setw(10)
              << prev_sync_states.first
              << std::setw(10)
              << prev_sync_states.second
              << '\n';

    // tb.trace_on();
    
    for(auto i = 0U; i != tb.frame_size() * 2; ++i)
    {
        tb.cycle();
        auto sync_states = tb.sync_states();

        if((sync_states.first != prev_sync_states.first) ||
           (sync_states.second != prev_sync_states.second))
        {
            std::cout << std::left
                      << std::setw(10)
                      << tb.cycles()
                      << std::setw(10)
                      << tb.cycles() - prev_cycles
                      << std::setw(10)
                      << sync_states.first
                      << std::setw(10)
                      << sync_states.second
                      << '\n';
            
            prev_sync_states = sync_states;
            prev_cycles = tb.cycles();
        }
    }

    // tb.trace_off();
}
