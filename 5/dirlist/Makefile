CC = gcc
INCLUDES = -I./include
CFLAGS = -Wall -Wextra -std=c11 $(INCLUDES)
TARGET = dirlist
PREFIX = /usr/local

all: $(TARGET)

$(TARGET): dirlist.o main.o
	$(CC) $(CFLAGS) -o $(TARGET) dirlist.o main.o

dirlist.o: src/dirlist.c include/dirlist.h
	$(CC) $(CFLAGS) -c src/dirlist.c

main.o: src/main.c include/dirlist.h
	$(CC) $(CFLAGS) -c src/main.c

install: $(TARGET)
	install -m 0755 $(TARGET) $(PREFIX)/bin/$(TARGET)

clean:
	rm -f $(TARGET) *.o

.PHONY: all install clean

# following practice with https://github.com/Qalculate/libqalculate
