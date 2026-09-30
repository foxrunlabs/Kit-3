////////////////////////////////////////////////////////////////////////////////
//
// Simple VGA Test
// Copyright (C) 2020 Ryan Clarke <kj6msg@icloud.com>
//
////////////////////////////////////////////////////////////////////////////////


#include "Kit3.hpp"
#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>
#include <verilated.h>


int main(int argc, char *argv[])
{
    Verilated::commandArgs(argc, argv);

    sf::RenderWindow window(sf::VideoMode(640, 480), "Kit-3 Test");
    sf::Event event;

    Kit3 tb;
    tb.reset();

    while(window.isOpen())
    {
        tb.cycle();

        while(window.pollEvent(event))
        {
            if(event.type == sf::Event::Closed)
                window.close();
        }
        
        window.clear();
        window.draw(tb.display());
        window.display();
    }
}
