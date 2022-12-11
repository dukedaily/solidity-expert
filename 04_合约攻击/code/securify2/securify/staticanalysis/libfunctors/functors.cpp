#include <cstdint>

#include <algorithm>
#include <iostream>
#include <sstream>
#include <map>
#include <vector>
#include <cstring>

using namespace std;

struct cmp_str
{
   bool operator()(char const *a, char const *b) const
   {
	  return std::strcmp(a, b) < 0;
   }
};

map<const char *, map<const char *, int, cmp_str>, cmp_str> counters;

extern "C" {

	int32_t enumerate(const char *id, const char *element) {
		auto it = counters.find(id);
		if (it == counters.end()) {
			counters[id] = map<const char *, int, cmp_str>();
		}

		auto &map = counters.find(id)->second;

		auto it2 = map.find(element);
		if (it2 == map.end()) {
			map[element] = map.size();
		}

		return map.find(element)->second;
	}

	void decode(const char *input, vector<int32_t> &data) {
		stringstream s;
		s << input;

		while (!s.eof()) {
			int32_t i;
        	if (s >> i) {
				data.push_back(i);
        	}
		}
	}

	const char* empty() {
		return "";
	}

	const char* encode(vector<int32_t> &data) {
		stringstream s;

		for(std::size_t i=0; i < data.size(); ++i) {
			if (i > 0)
				s << ' ';

		  	s << data[i];
		}

		const std::string tmp = s.str();
		char *cstr = new char[tmp.size() + 1];

		strcpy(cstr, tmp.c_str());

		return cstr;
	}

	bool contains(vector<int32_t> &set, int32_t elem) {
		auto it = lower_bound(
			set.begin(),
			set.end(),
			elem);

    	return it != set.end() && *it == elem;
	}

	const char* add(const char *input, int32_t elem) {
		vector<int32_t> set;
		decode(input, set);

		if (contains(set, elem))
			return input;

		set.insert
        (
            upper_bound(set.begin(), set.end(), elem),
            elem
        );

		return encode(set);
	}

	int32_t isSubset(const char *inputA, const char *inputB) {
		vector<int32_t> setA;
		vector<int32_t> setB;
		decode(inputA, setA);
		decode(inputB, setB);

		for (auto i: setA)
			if (!contains(setB, i))
				return 0;

		return 1;
	}

	int32_t size(const char *input) {
		vector<int32_t> data;
		decode(input, data);

		return data.size();
	}


	int32_t isElement(int32_t elem, const char *input) {
		vector<int32_t> set;
		decode(input, set);

		if (contains(set, elem))
			return 1;

		return 0;
	}


}

int main(int ac, char** av) {
	vector<int32_t> data;

	decode("1 2 5 6 8 10 60 70", data);
	for (auto i: data)
	  cout << i << ' ';

  	cout << "\n";
  	cout << encode(data);
  	cout << "\n";
}
