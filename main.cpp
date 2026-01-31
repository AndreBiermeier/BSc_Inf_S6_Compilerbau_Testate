#include <iostream>
#include <string>
#include <cstdio>
#include <filesystem>

/*
 * This main.cpp accepts two arguments.
 * 1. arg: The input pl0 program (e.g. "program.pl0")
 * 2. arg: The output directory (e.g. "../output/")
 */

extern int yyparse();
extern FILE* yyin;

// Global variable to set the output location.
extern std::string g_out_base;

int main(int argc, char **argv)
{
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0]
                  << " input.pl0 [output_dir]\n";
        return 1;
    }

    namespace fs = std::filesystem;

    // -----------------------
    // Input file
    // -----------------------
    fs::path input_path(argv[1]);
    yyin = fopen(input_path.c_str(), "r");
    if (!yyin) {
        std::cerr << "Cannot open file: " << input_path << std::endl;
        return 1;
    }

    // -----------------------
    // Determine output directory
    // -----------------------
    fs::path out_dir;
    if (argc >= 3) {
        out_dir = fs::path(argv[2]);
    } else {
        out_dir = input_path.parent_path();
    }

    // Just in case
    if (out_dir.empty())
        out_dir = ".";

    fs::create_directories(out_dir);

    // -----------------------
    // Set global output base (without .asm)
    // -----------------------
    fs::path out_base = out_dir / input_path.stem();
    g_out_base = out_base.string();

    // -----------------------
    // Run parser (AST to ASM code generation is done in the grammar action)
    // -----------------------
    int result = yyparse();
    fclose(yyin);

    if (result != 0) {
        std::cerr << "Parsing failed\n";
        return result;
    }

    std::cerr << "Generated: " << g_out_base << ".asm\n";
    return 0;
}
