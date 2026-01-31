
#include "ram.h"
#include <iostream>
using namespace std;


int c_RAM::get_adr(int level, int offset) {
	int p = ram[0];
	for (int i = 0; i < level; i++)
		p = ram[p];
	return p - 2 - offset;
}

void c_RAM::print() {
	int tof = ram[0];
	printf("--------------------------\n");
	do {
		printf("%2d: %10d SL\n", tof, ram[tof]);
		printf("%2d: %10d DL\n", tof - 1, ram[tof-1]);
		for (int i = tof - 2; i > ram[tof-1]; i--)
			printf("%2d: %10d\n", i, ram[i]);
		tof = ram[tof-1];
	} while (tof);
	printf("%2d: %10d ToS\n", 0, ram[0]);
	printf("--------------------------\n");
}


void c_RAM::tikz() {
	cout << "\\documentclass{standalone}\n\\usepackage{tikz}\n\\begin{document}\n";
	cout << "\\begin{tikzpicture}[node/.style={align=center,draw,top color=white, bottom color=blue!20,minimum width=1.2cm,,minimum height=.5cm}]\n";

	int tof = ram[0];
	do {
		double y = tof / 2.0;
		printf("\\node at (0,%lf) {%d};\n", y, tof);
		printf("\\node(%d)[node] at (1,%lf) {%d};\n", tof, y, ram[tof]);
		printf("\\node at (2,%lf) {SL};\n", y);
		printf("\\node at (0,%lf) {%d};\n", y - .5, tof - 1);
		printf("\\node(%d)[node] at (1,%lf) {%d};\n", tof - 1, y-.5, ram[tof-1]);
		printf("\\node at (2,%lf) {DL};\n", y-.5);
		printf("\\draw([xshift=-12.5mm]%d.north) -- ([xshift=12.5mm]%d.north);\n", tof, tof);
		for (int i = tof - 2; i > ram[tof-1]; i--) {
			printf("\\node at (0,%lf) {%d};\n", i / 2.0, i);
			printf("\\node(%d)[node] at (1,%lf) {%d};\n", i, i / 2.0, ram[i]);
		}

		tof = ram[tof-1];
	} while (tof);
	printf("\\node at (0,0) {0};\n");
	printf("\\node(0) [node] at (1,0) {%d};\n", ram[0]);
	printf("\\node at (2,0) {Tos};\n");

	tof = ram[0];
	do {
		printf("\\draw[->,thick,red]([yshift=-1mm]%d.east) to[out=-60,in=60] ([yshift=1mm]%d.east);\n", tof, ram[tof]);
		printf("\\draw[->,thick,red]([yshift=-1mm]%d.west) to[out=-120,in=120] ([yshift=1mm]%d.west);\n", tof-1, ram[tof-1]);
		tof = ram[tof-1];
	} while (tof);
	
	// Besser: \draw[->,thick,red, rounded corners]([yshift=-1.5mm]0.west) -|([xshift=-6mm,yshift=5mm]0.west)  |-  ([yshift=1.5mm]16.west);
	printf("\\draw[->,thick,red, rounded corners]([yshift=-1.5mm]0.west) -|([xshift=-6mm,yshift=5mm]0.west)  |-  ([yshift=1.5mm]%d.west);\n", ram[0]);
	printf("\\draw([xshift=-12.5mm]0.north) -- ([xshift=12.5mm]0.north);\n");

	
	cout << "\\end{tikzpicture}\n\\end{document}" << endl;
	
}



c_RAM::c_RAM() {
	ram[0] = 0;  // TOS
}

void c_RAM::level_up(int n, int level) {
	int i, p=ram[0];
	for (i = 0; i < level; i++)
		p = ram[p];
	ram[ram[0] + n + 2] = p; // SL-Link setzen
	ram[ram[0] + n + 1] = ram[0]; // DL-Link setzen
	ram[0] += (n + 2);
}
	
void c_RAM::level_down() {
	ram[0] = ram[ram[0] - 1];
}

int c_RAM::read(int level, int offset) {
	return ram[get_adr(level, offset)];
}
	
void c_RAM::write(int level, int offset, int val) {
	ram[get_adr(level, offset)] = val;
}
	

