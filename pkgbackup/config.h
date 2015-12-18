#ifndef CONFIG_H
#define CONFIG_H

#include <string>
#include <map>

//-----------------------------------------------------------------------------
class Section
{
  std::string name;
  
public:
  Section(const std::string &n);
  ~Section();
  
};

//-----------------------------------------------------------------------------
class Config
{
  std::string name;
  std::map<std::string, Section *> sections;
  
public:
  Config();
  Config(const std::string &fname);
  ~Config();

  bool load(const std::string &fname);
};

#endif /* CONFIG_H */
