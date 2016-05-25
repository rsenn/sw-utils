#include "config.h"

#include <fstream>
#include <iostream>

using namespace std;

//-----------------------------------------------------------------------------
Section::Section(const string &n)
{

}

//-----------------------------------------------------------------------------
Section::~Section()
{
}

//-----------------------------------------------------------------------------
Config::Config()
{
}

//-----------------------------------------------------------------------------
Config::Config(const string &fname)
{
  load(fname);
}

//-----------------------------------------------------------------------------
Config::~Config()
{
}

//-----------------------------------------------------------------------------
bool Config::load(const string &fname)
{
  ifstream input(fname.c_str());
  
  if(!input.is_open())
    return false;
  
  char buffer[4096];
  
  while(!input.eof())
  {
    input.getline(buffer, sizeof(buffer), '\n');
    
    cout << buffer << std::endl;
  }
}

