////////////////////////////////////////////////////////////////////////////////
//
// Kit3
// Copyright (C) 2020 Ryan Clarke <kj6msg@icloud.com>
//
////////////////////////////////////////////////////////////////////////////////


#include "Kit3.hpp"
#include <Nexys4DDR/Clock.hpp>
#include <Nexys4DDR/TestBench.hpp>
#include <Nexys4DDR/VGA.hpp>
#include <string>
#include <verilated_vcd_c.h>
#include "Vkit3.h"


////////////////////////////////////////////////////////////////////////////////
void Kit3::tick()
{
    m_module.eval();

    auto next_edge = m_core_clk.next_edge();

    if(m_pixel_clk.next_edge() < next_edge)
        next_edge = m_pixel_clk.next_edge();
    
    m_module.i_clk_sys = m_core_clk.advance(next_edge);
    m_module.i_clk_pixel = m_pixel_clk.advance(next_edge);
    m_module.eval();

    m_sim_time += next_edge;

    if(m_trace_enable && m_trace_on)
    {
        m_tracer.dump(m_sim_time);
        m_tracer.flush();
    }
}


////////////////////////////////////////////////////////////////////////////////
void Kit3::cycle(unsigned int cycles)
{
    while(cycles)
    {
        tick();

        if(m_pixel_clk.falling_edge())
            m_display.tick(m_module.o_rgb, m_module.o_vblank);

        if(m_core_clk.falling_edge())
            --cycles;
    }
}


////////////////////////////////////////////////////////////////////////////////
const Nexys4DDR::VGA& Kit3::display() const
{
    return m_display;
}


////////////////////////////////////////////////////////////////////////////////
void Kit3::reset()
{
    m_module.i_reset = 1;
    cycle(2);
    m_module.i_reset = 0;
}


////////////////////////////////////////////////////////////////////////////////
void Kit3::screenshot(const std::string& filename) const
{
    m_display.screenshot(filename);
}
