//
// Unpack.c
//
// Pack unpacker. Simple. Stupid.

char Usage[] = "Usage: unpack <pack_file> [<unpack_dir>]\n";

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <errno.h>
//#include <direct.h>
//#include <io.h>
#include <stdlib.h>
#include <assert.h>
#include <limits.h>

typedef unsigned char UBYTE;
typedef unsigned int UDWORD;

typedef char PATHNAME[PATH_MAX];

//
// On-disk structures -- if these change change them in pack.c in the game too
//

// packfile id
#define PACKFILEID (*((int*)"BOTG"))

// pack file entry name
typedef char PACKENTRYNAME[28];

// packfile header (disk)
typedef struct
{
  UDWORD id;                  // packfile id
  UDWORD dirofs;              // directory offset
  UDWORD entries;             // number of entries in packfile
} PACKHEADER;

// packfile entry (disk)
typedef struct
{
  PACKENTRYNAME name;         // file name, asciiz
  UDWORD ofs;                 // file offset within packfile
  UDWORD size;                // file size within packfile
} PACKENTRY;


//
// In-memory structures
//

typedef struct
{
  PATHNAME path;              // path name of packfile
  FILE *f;                    // file pointer
  UDWORD dirofs;              // directory offset
  UDWORD entries;             // number of directory entries
  PACKENTRY entry[1];         // directory entries
} PACKFILE;



//
// Utility functions
//

// show message and quit
void fatalerror(const char *fmt, ...)
{
  va_list argptr;

  va_start(argptr, fmt);
  vfprintf(stdout, fmt, argptr); fflush(stdout);
  va_end(argptr);
  exit(1);
}

// show a message
void message(const char *fmt, ...)
{
  va_list argptr;

  va_start(argptr, fmt);
  vfprintf(stdout, fmt, argptr); fflush(stdout);
  va_end(argptr);
}


//
// Pack functions
//

// close pack file, delete structure
void Pack_Close(PACKFILE *pack)
{
  fclose(pack->f);
  free(pack);
}

// load a pack file, allow reading
PACKFILE *Pack_Open(const char *path)
{
  FILE *f;
  int id;
  UDWORD dirofs, entries;
  PACKFILE *pack;

  if (!(f = fopen(path,"rb")))
  {
    // couldn't find pack file
    return NULL;
  }

  // read id
  if (fread(&id,1,4,f) != 4)
  {
    // couldn't read id from pack file
    fclose(f);
    fatalerror("file '%s' not a packfile : no id\n", path);
  }

  // validate id
  if (id != PACKFILEID)
  {
    // not a packfile id
    fclose(f);
    fatalerror("file '%s' not a packfile : bad id\n", path);
  }

  // read directory offset and number of entries
  fread(&dirofs,1,4,f);
  fread(&entries,1,4,f);

  // alloc packfile
  pack = (PACKFILE*)malloc(sizeof(PACKFILE) + (entries-1)*sizeof(PACKENTRY));
  if (!pack)
    fatalerror("internal error allocing packfile structure\n");

  // setup packfile info
  strcpy(pack->path, path);
  pack->f = f;
  pack->entries = entries;
  pack->dirofs = dirofs;

  // read entries
  fseek(f,dirofs,SEEK_SET);
  if (fread(&pack->entry[0],sizeof(PACKENTRY),entries,f) != entries)
  {
    // couldn't read entries from pack file
    fclose(f);
    fatalerror("packfile '%s' has bad directory\n", path);
  }

  // note: packfile deliberately left open

  // return alloced packfile
  return pack;
}

// copy buffer for copying to output file
UBYTE copybuf[1024*1024];
#define COPYBUFSIZE (sizeof(copybuf))

int main(int argc, char **argv)
{
  PACKFILE *pack;
  char *packname;
  char *outdir = ".";
  UDWORD i;

  if (argc < 2 || argc > 3)
    fatalerror(Usage);

  // get pack name
  packname = argv[1];

  // open pack file
  pack = Pack_Open(packname);
  if (!pack)
    fatalerror("error opening packfile '%s' : %s\n", packname, strerror(errno));

  // get output directory name
  if (argc > 2)
    outdir = argv[2];

  // write out each entry
  for (i=0; i<pack->entries; i++)
  {
    FILE *outf;
    char outpath[PATH_MAX];
    UDWORD size;

    // copy directory name into outpath
    strncpy(outpath, outdir, sizeof(outpath)); 
    outpath[sizeof(outpath)-1] = '\0';
    
    // append backslash if missing
    if (outpath[0] && outpath[strlen(outpath)-1] != '/')
      strncat(outpath,"/",sizeof(outpath));
    outpath[sizeof(outpath)-1] = '\0';

    // append entry name
    strncat(outpath,pack->entry[i].name,sizeof(outpath));
    outpath[sizeof(outpath)-1] = '\0';

    // show user what's going on
    message("extracting '%s' to '%s'\n", pack->entry[i].name, outpath);

    // open output file
    outf = fopen(outpath,"wb");
    if (!outf)
      fatalerror("error opening outfile '%s' : %s\n", outpath, strerror(errno));

    // seek to start of entry
    fseek(pack->f, pack->entry[i].ofs, SEEK_SET);

    size = pack->entry[i].size;
    while (size)
    {
      UDWORD chunksize = (size > COPYBUFSIZE) ? COPYBUFSIZE : size;

      // read in a chunk
      if (fread(copybuf,1,chunksize,pack->f) != chunksize)
        fatalerror("error reading %d bytes from '%s' : %s\n", chunksize, pack->path, strerror(errno));

      // write out a chunk
      if (fwrite(copybuf,1,chunksize,outf) != chunksize)
        fatalerror("error writing %d bytes to '%s' : %s\n", chunksize, outpath, strerror(errno));

      size -= chunksize;
    }

    // close output file
    fclose(outf);
  }

  // close pack file
  Pack_Close(pack);

  return 0;
}
