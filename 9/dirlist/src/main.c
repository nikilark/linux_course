#include <stdio.h>
#include <stdlib.h>
#include <dirlist.h>
#include <string.h>

void print_help() {
    printf("Usage: dirlist [OPTION] [DIRECTORY]\n");
    printf("List information about the files in a directory.\n\n");
    printf("Options:\n");
    printf("  -h, --help    display this help and exit\n");
}

int main(int argc, char *argv[]) {
    const char *path = ".";
    int show_help = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            show_help = 1;
            break;
        } else {
            path = argv[i];
        }
    }

    if (show_help) {
        print_help();
    } else {
        list_directory(path);
    }

    return 0;
}
