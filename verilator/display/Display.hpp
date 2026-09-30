////////////////////////////////////////////////////////////////////////////////
//
// Display
// Copyright (C) 2020 Ryan Clarke <kj6msg@icloud.com>
//
////////////////////////////////////////////////////////////////////////////////

#ifndef DISPLAY_HPP
#define DISPLAY_HPP


#include <iostream>
#include <Nexys4DDR/Clock.hpp>
#include <Nexys4DDR/TestBench.hpp>
#include <string>
#include <utility>
#include "Vdisplay.h"
#include <verilated.h>


class Display : public Nexys4DDR::TestBench<Vdisplay>
{
public:
    enum class sync_state
    {
        no_sync,
        pulse,
        line,
        frame,
        sync
    };
    
    Display(bool trace_enable = false,
            const std::string& filename = "trace.vcd")
            : TestBench(trace_enable, filename), m_clk(10) {};
    
    void tick() override;
    void cycle(unsigned int cycles = 1);
    
    std::pair<sync_state, sync_state> sync_states() const;
    
    unsigned int cycles() const;
    unsigned int frame_size() const;

private:    
    const unsigned int m_hsync_total{840};
    const unsigned int m_hsync_pulse{64};
    const unsigned int m_vsync_total{500};
    const unsigned int m_vsync_pulse{3};

    Nexys4DDR::Clock m_clk;
    unsigned int m_cycles{0};

    sync_state m_hsync_state{sync_state::no_sync};
    sync_state m_vsync_state{sync_state::no_sync};
    vluint8_t m_prev_hsync{1};
    vluint8_t m_prev_vsync{1};

    unsigned int m_hpixels{0};
    unsigned int m_lines{0};

    void evaluate_sync();
};


std::ostream& operator<<(std::ostream& out, Display::sync_state s);


#endif  // KIT3_HPP
