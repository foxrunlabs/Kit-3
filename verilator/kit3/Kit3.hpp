////////////////////////////////////////////////////////////////////////////////
//
// Kit3
// Copyright (C) 2020 Ryan Clarke <kj6msg@icloud.com>
//
////////////////////////////////////////////////////////////////////////////////

#ifndef KIT3_HPP
#define KIT3_HPP


#include <Nexys4DDR/Clock.hpp>
#include <Nexys4DDR/TestBench.hpp>
#include <Nexys4DDR/VGA.hpp>
#include <string>
#include "Vkit3.h"


class Kit3 : public Nexys4DDR::TestBench<Vkit3>
{
public:
    Kit3(bool trace_enable = false, const std::string& filename = "trace.vcd")
        : TestBench(trace_enable, filename), m_core_clk(2048),
          m_pixel_clk(2), m_display(840, 500, 4) {};
    
    void tick() override;
    void cycle(unsigned int cycles = 1);

    void reset();
    
    const Nexys4DDR::VGA& display() const;
    void screenshot(const std::string& filename) const;

private:
    Nexys4DDR::Clock m_core_clk;
    Nexys4DDR::Clock m_pixel_clk;
    Nexys4DDR::VGA m_display;
};


#endif  // KIT3_HPP
