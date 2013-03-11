//
//  pkgtools
// 
//  Copyright (c) 2000-2005 Per Liden
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, 
//  USA.
//

#include "pkgadd.hpp"
#include <fstream>
#include <iterator>
#include <cstdio>
#include <regex.h>
#include <unistd.h>

#include <libgen.h>

void pkgadd::run(int argc, char** argv)
{
	//
	// Check command line options
	//
	string o_root;
	string o_package;
  char package_name[64];
  char *suffix;
  string o_name;
	bool o_upgrade = false;
	bool o_force = false;
  bool o_noscripts = false;
  bool o_nokeep = false;

	for (int i = 1; i < argc; i++) {
		string option(argv[i]);
		if (option == "-r" || option == "--root") {
			assert_argument(argv, argc, i);
			o_root = argv[i + 1];
			i++;
    } else if (option == "-n" || option == "--no-scripts") {
      o_noscripts = true;
		} else if (option == "-u" || option == "--upgrade") {
			o_upgrade = true;
		} else if (option == "-f" || option == "--force") {
			o_force = true;
		} else if (option == "-K" || option == "--no-keep") {
			o_nokeep = true;
		} else if (option[0] == '-' || !o_package.empty()) {
			throw runtime_error("invalid option " + option);
		} else {
			o_package = option;
		}
	}

	if (o_package.empty())
		throw runtime_error("option missing");

	//
	// Check UID
	//
#if !(defined(WIN32) || defined(__CYGWIN__))
	if (getuid())
		throw runtime_error("only root can install/upgrade packages");
#endif /* WIN32 || __CYGWIN__ */

	//
	// Install/upgrade package
	//
	{
//    m_db->lock().engage(true);
    m_db->open(o_root,true);
//		db_lock lock(o_root, true);
//		open(o_root);
    root = o_root + "/";

		pair<string, pkgdb::pkginfo_t> package = pkg_open(o_package);
		vector<rule_t> config_rules = read_config();

		bool installed = m_db->find_pkg(package.first);
		if (installed && !o_upgrade)
			throw runtime_error("package " + package.first + " already installed (use -u to upgrade)");
		else if (!installed && o_upgrade)
			throw runtime_error("package " + package.first + " not previously installed (skip -u to install)");
      
		set<string> conflicting_files = m_db->find_conflicts(package.first, package.second);
      
		if (!conflicting_files.empty()) {
			if (o_force) {
				set<string> keep_list;
				if (o_upgrade && !o_nokeep) // Don't remove files matching the rules in configuration
					keep_list = make_keep_list(conflicting_files, config_rules);
				m_db->rm_files(conflicting_files, keep_list); // Remove unwanted conflicts
			} else {
				copy(conflicting_files.begin(), conflicting_files.end(), ostream_iterator<string>(cerr, "\n"));
				throw runtime_error("listed file(s) already installed (use -f to ignore and overwrite)");
			}
		}
   
		set<string> keep_list;

		if (o_upgrade) {
			keep_list = make_keep_list(package.second.files, config_rules);
			m_db->rm_pkg(package.first, keep_list);
		}
   
		m_db->add_pkg(package.first, package.second);
		m_db->commit();
    
    /* dirty dirty hack */
    if(o_noscripts == false)
    {
      strcpy(package_name, LIBDIR"/pkgadd/");
      strncat(package_name, static_cast<char *>(basename((char *)(o_package.c_str()))), sizeof(package_name) - sizeof(LIBDIR"/pkgadd/"));
      package_name[sizeof(package_name) - 1] = '\0';
      if((suffix = strchr(package_name, '#')))
        strcpy(suffix, ".pre");
      
      script(o_package, &package_name[1]);
    }
    
		pkg_install(o_package, keep_list);
    
    if(o_noscripts == false)
    {
      if(suffix)
        strcpy(suffix, ".post");

      script(o_package, &package_name[1]);
    }

    ldconfig();
	}
}

void pkgadd::print_help() const
{
	cout << "usage: " << utilname << " [options] <file>" << endl
	     << "options:" << endl
	     << "  -u, --upgrade       upgrade package with the same name" << endl
	     << "  -f, --force         force install, overwrite conflicting files" << endl
	     << "  -r, --root <path>   specify alternative installation root" << endl
	     << "  -n, --noscripts     do not execute pre-/postmerge scripts" << endl
	     << "  -K, --no-keep       ignore the keep list" << endl
	     << "  -v, --version       print version and exit" << endl
	     << "  -h, --help          print help and exit" << endl;
}

vector<rule_t> pkgadd::read_config() const
{
	vector<rule_t> rules;
	unsigned int linecount = 0;
	const string filename = root + PKGADD_CONF;
	ifstream in(filename.c_str());

	if (in) {
		while (!in.eof()) {
			string line;
			getline(in, line);
			linecount++;
			if (!line.empty() && line[0] != '#') {
				if (line.length() >= PKGADD_CONF_MAXLINE)
					throw runtime_error(filename + ":" + itos(linecount) + ": line too long, aborting");

				char event[PKGADD_CONF_MAXLINE];
				char pattern[PKGADD_CONF_MAXLINE];
				char action[PKGADD_CONF_MAXLINE];
				char dummy[PKGADD_CONF_MAXLINE];
				if (sscanf(line.c_str(), "%s %s %s %s", event, pattern, action, dummy) != 3)
					throw runtime_error(filename + ":" + itos(linecount) + ": wrong number of arguments, aborting");

				if (!strcmp(event, "UPGRADE")) {
					rule_t rule;
					rule.event = rule_t::UPGRADE;
					rule.pattern = pattern;
					if (!strcmp(action, "YES")) {
						rule.action = true;
					} else if (!strcmp(action, "NO")) {
						rule.action = false;
					} else
						throw runtime_error(filename + ":" + itos(linecount) + ": '" +
								    string(action) + "' unknown action, should be YES or NO, aborting");

					rules.push_back(rule);
				} else
					throw runtime_error(filename + ":" + itos(linecount) + ": '" +
							    string(event) + "' unknown event, aborting");
			}
		}
		in.close();
	}

#ifdef DEBUG
	cerr << "Configuration:" << endl;
	for (vector<rule_t>::const_iterator j = rules.begin(); j != rules.end(); j++) {
		cerr << "\t" << (*j).pattern << "\t" << ((*j).action ? "YES" : "NO") << endl;
	}
	cerr << endl;
#endif

	return rules;
}

set<string> pkgadd::make_keep_list(const set<string>& files, const vector<rule_t>& rules) const
{
	set<string> keep_list;

	for (set<string>::const_iterator i = files.begin(); i != files.end(); i++) {
		for (vector<rule_t>::const_reverse_iterator j = rules.rbegin(); j != rules.rend(); j++) {
			if ((*j).event == rule_t::UPGRADE) {
				regex_t preg;
				if (regcomp(&preg, (*j).pattern.c_str(), REG_EXTENDED | REG_NOSUB))
					throw runtime_error("error compiling regular expression '" + (*j).pattern + "', aborting");

				if (!regexec(&preg, (*i).c_str(), 0, 0, 0)) {
					if (!(*j).action)
						keep_list.insert(keep_list.end(), *i);
					regfree(&preg);
					break;
				}
				regfree(&preg);
			}
		}
	}

#ifdef DEBUG
	cerr << "Keep list:" << endl;
	for (set<string>::const_iterator j = keep_list.begin(); j != keep_list.end(); j++) {
		cerr << "   " << (*j) << endl;
	}
	cerr << endl;
#endif

	return keep_list;
}
