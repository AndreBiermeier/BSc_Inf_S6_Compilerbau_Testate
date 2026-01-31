#pragma once
class c_RAM  {
public:
	void print();
	void print_frame(int);
	void tikz();
	void tikz_frame(int);
	c_RAM();
	void level_up(int n, int sl_length);
	void level_down();
	int read(int level, int offset);
	void write(int level, int offset, int val);
protected:
	int get_adr(int level, int offset);
	int ram[1024];
};
