//#include <windows.h>
#include <stdio.h>
//#include <io.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <glob.h>
#include <sys/stat.h>
#include <ctype.h>

char *strlwr(char *str);

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
char *mask = "*.*";
char *outfile = NULL;
char packname[256];

unsigned long Offset = 0;
unsigned long Count = 0;


void                      Read(FILE *fp, void *Buffer, unsigned long size)
{
  if (fread(Buffer, size, 1, fp) != 1)
  {
    printf("error reading %ld bytes", size);
    exit(1);
  }
}

void                      Write(FILE *fp, void *Buffer, unsigned long size)
{
  if (fwrite(Buffer, size, 1, fp) != 1)
  {
    printf("error writing %ld bytes", size);
    exit(1);
  }
}


void                      Add(char *fname, unsigned long size)
{
  static char buffer[32768];
  unsigned int count = 0, c;

  // store directory entry
  strncpy(Entries[Count].name, fname, sizeof(PACKENTRYNAME));
  strlwr(Entries[Count].name);
  Entries[Count].ofs = Offset;
  Entries[Count].size = size;

  // copy file
  FILE *in = fopen(fname, "rb");

  if (in == NULL)
  {
    printf("cant open [%s]\n", fname);
    exit(1);
  }

  do
  {
    c = fread(buffer, 1, sizeof(buffer), in);
    if (c)
    {
      Write(packfile, buffer, c);
      count += c;
    }
  } while (c);

  fclose(in);

  if (count != size)
  {
    printf("expected %ld got %d", size, count);
    exit(1);
  }

  // update counters
  Offset += size;
  Count++;
}


void                      WriteHeader()
{
  Header.id = PACKFILEID;
  Header.dirofs = 0;
  Header.entries = 0;

  Write(packfile, &Header, sizeof(Header));

  Offset = sizeof(Header);
}

int cmp(const void *elem1, const void *elem2)
{
  PACKENTRY *p1 = (PACKENTRY *)elem1;
  PACKENTRY *p2 = (PACKENTRY *)elem2;

  return strcasecmp(p1->name, p2->name);
}

void                      WriteFinish()
{
  Header.dirofs = Offset;
  Header.entries = Count;

  qsort(Entries, Count, sizeof(Entries[0]), cmp);

  //printf("writing dir at %ld [filepos=%ld]\n", Offset, ftell(packfile));

  Write(packfile, Entries, sizeof(PACKENTRY) * Count);
  
  fseek(packfile, 0, SEEK_SET);
  Write(packfile, &Header, sizeof(Header));  
}


// mask is a char* naming the files to glob
// findfirst always searches in the current dir
void                      AddFiles()
{
  glob_t pglob;
  int i;

  glob(mask, 0, NULL, &pglob);

  for (i = 0; i < pglob.gl_pathc; i++) {
      struct stat buf;

      stat(pglob.gl_pathv[i], &buf);
      
      if (!S_ISDIR(buf.st_mode)) {
          if (strcasecmp(pglob.gl_pathv[i], outfile) != 0) {
              printf("adding '%s'\n", pglob.gl_pathv[i]);
              Add(pglob.gl_pathv[i], buf.st_size);
          }
      }
  }
}

// Implementation of Windows function strlwr() modified from Wine source
char *strlwr(char *str) {
    char *ret = str;
    for ( ; *str; str++) *str = tolower(*str);
    return ret;
}


int main(int argc, char *argv[])
{
  if (argc == 1)
  {
    printf("usage: %s <outfile> [infiles]\n", "pak");
    return EXIT_SUCCESS;
  }

  if (argc > 1)
  {
    outfile = argv[1];
    packfile = fopen(outfile, "wb");
    if (packfile == NULL)
      return EXIT_FAILURE;
  }
  if (argc > 2)
  {
    mask = argv[2];
  }

  WriteHeader();
  AddFiles();
  WriteFinish();

  fclose(packfile);

  return EXIT_SUCCESS;
}
