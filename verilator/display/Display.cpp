////////////////////////////////////////////////////////////////////////////////
//
// Display
// Copyright (C) 2020 Ryan Clarke <kj6msg@icloud.com>
//
////////////////////////////////////////////////////////////////////////////////


#include "Display.hpp"
#include <iostream>
#include <Nexys4DDR/Clock.hpp>
#include <Nexys4DDR/TestBench.hpp>
#include <utility>
#include "Vdisplay.h"
#include <verilated_vcd_c.h>


////////////////////////////////////////////////////////////////////////////////
void Display::tick()
{
    m_module.eval();

    auto next_edge = m_clk.next_edge();
    m_module.i_clk_pixel = m_clk.advance(next_edge);
    m_module.eval();

    m_sim_time += next_edge;

    if(m_clk.falling_edge())
    {
        ++m_cycles;
        ++m_hpixels;
        evaluate_sync();
    }

    if(m_trace_enable && m_trace_on)
    {
        m_tracer.dump(m_sim_time);
        m_tracer.flush();
    }
}


////////////////////////////////////////////////////////////////////////////////
void Display::cycle(unsigned int cycles)
{
    while(cycles)
    {
        tick();

        if(m_clk.falling_edge())
            --cycles;
    }
}


////////////////////////////////////////////////////////////////////////////////
unsigned int Display::cycles() const
{
    return m_cycles;
}


////////////////////////////////////////////////////////////////////////////////
std::pair<Display::sync_state, Display::sync_state> Display::sync_states() const
{
    return std::make_pair(m_hsync_state, m_vsync_state);
}


////////////////////////////////////////////////////////////////////////////////
unsigned int Display::frame_size() const
{
    return m_hsync_total * m_vsync_total;
}


////////////////////////////////////////////////////////////////////////////////
void Display::evaluate_sync()
{
    // Evaluate HSYNC signal first.
    switch(m_hsync_state)
    {
        // Wait for HSYNC pulse.
        case sync_state::no_sync:
            // HSYNC falling edge.
            if(m_prev_hsync && !m_module.o_hsync)
            {
                m_hpixels = 0;
                m_lines = 0;
                m_hsync_state = sync_state::pulse;
            }
            break;
        
        // Verify HSYNC pulse is correct length.
        case sync_state::pulse:
            // HSYNC rising edge.
            if(!m_prev_hsync && m_module.o_hsync)
            {
                if(m_hpixels == m_hsync_pulse)
                {
                    m_hpixels = 0;
                    m_hsync_state = sync_state::line;
                }
                else
                {
                    m_hsync_state = sync_state::no_sync;
                }
            }
            break;
        
        // Verify line is correct length.
        case sync_state::line:
            // HSYNC rising edge.
            if(!m_prev_hsync && m_module.o_hsync)
            {
                if(m_hpixels == m_hsync_total)
                {
                    m_hpixels = 0;
                    ++m_lines;
                    m_hsync_state = sync_state::sync;
                }
                else
                {
                    m_hsync_state = sync_state::no_sync;
                }
            }
            break;
        
        // Sync'd!
        case sync_state::sync:
            if(m_hpixels == m_hsync_total)
            {
                m_hpixels = 0;
                ++m_lines;
            }
            break;

        default:
            m_hsync_state = sync_state::no_sync;
            break;
    }
    
    // Only process VSYNC if HSYNC is sync'd.
    if(m_hsync_state == sync_state::sync)
    {
        switch(m_vsync_state)
        {
            // Wait for VSYNC pulse.
            case sync_state::no_sync:
                // VSYNC falling edge.
                if(m_prev_vsync && !m_module.o_vsync)
                {
                    m_lines = 0;
                    m_vsync_state = sync_state::pulse;
                }
                break;
            
            // Verify VSYNC pulse is correct length.
            case sync_state::pulse:
                if(!m_prev_vsync && m_module.o_vsync)
                {
                    if(m_lines == m_vsync_pulse)
                    {
                        m_lines = 0;
                        m_vsync_state = sync_state::frame;
                    }
                    else
                    {
                        m_vsync_state = sync_state::no_sync;
                    }
                }
                break;
            
            // Verify frame is correct length.
            case sync_state::frame:
                if(!m_prev_vsync && m_module.o_vsync)
                {
                    if(m_lines == m_vsync_total)
                    {
                        m_lines = 0;
                        m_vsync_state = sync_state::sync;
                    }
                    else
                    {
                        m_vsync_state = sync_state::no_sync;
                    }
                }
                break;
            
            // Sync'd!
            case sync_state::sync:
                if(m_lines == m_vsync_total)
                    m_lines = 0;
                
                break;
            
            default:
                m_vsync_state = sync_state::no_sync;
                break;
        }
    }
    else
    {
        m_vsync_state = sync_state::no_sync;
    }

    m_prev_hsync = m_module.o_hsync;
    m_prev_vsync = m_module.o_vsync;
}


////////////////////////////////////////////////////////////////////////////////
std::ostream& operator<<(std::ostream& os, Display::sync_state s)
{
    switch(s)
    {
        case Display::sync_state::no_sync:
            os << "no_sync";
            break;
        
        case Display::sync_state::pulse:
            os << "pulse";
            break;
        
        case Display::sync_state::line:
            os << "line";
            break;
        
        case Display::sync_state::frame:
            os << "frame";
            break;
        
        case Display::sync_state::sync:
            os << "sync";
            break;

        default:
            os << int(s);
            break;
    }

    return os;
}
