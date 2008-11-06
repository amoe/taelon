//#include <windows.h>
#include <stdio.h>
//#include <io.h>
#include <string.h>
#include <stdlib.h>

// FIXME: What is the equivalent type to DWORD?
// must be compiled in C99 mode
#define DWORD unsigned long

// packfile id
#define PACKFILEID (*((int*)"BOTG"))

typedef char PACKENTRYNAME[28];

// packfile header (disk)
typedef struct
{
  DWORD id;                  // packfile id
  DWORD dirofs;              // directory offset
  DWORD entries;             // number of entries in packfile
} PACKHEADER;

// packfile entry (disk)
typedef struct
{
  PACKENTRYNAME name;         // file name, asciiz
  DWORD ofs;                 // file offset within packfile
  DWORD size;                // file size within packfile
} PACKENTRY;


#define MAXFILES 10000


PACKENTRY Entries[MAXFILES];
PACKHEADER Header;

FILE *packfile;



void                      Read(FILE *fp, void *Buffer, unsigned long size)
{
  if (fread(Buffer, size, 1, fp) != 1)
  {
    printf("error reading %ld bytes", size);
    exit(1);
  }
}

void                      ReadDir()
{
  Read(packfile, &Header, sizeof(Header));
  fseek(packfile, Header.dirofs, SEEK_SET);
  Read(packfile, &Entries, sizeof(PACKENTRY) * Header.entries);
}


void                      ListDir()
{
    int i;

  for (i = 0; i < Header.entries; i++)
  {
    printf("%-30.30s %8ld %8ld\n", Entries[i].name, Entries[i].size, Entries[i].ofs);
  }
}




int main(int argc, char *argv[])
{
  if (argc == 1)
  {
    printf("usage: %s <packfile>\n", "paklist");
    return EXIT_SUCCESS;
  }

  if (argc > 1)
  {
    packfile = fopen(argv[1], "rb");
    if (packfile == NULL)
      return EXIT_FAILURE;
  }

  ReadDir();
  ListDir();

  fclose(packfile);

  return EXIT_SUCCESS;
}
