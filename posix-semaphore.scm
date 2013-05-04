#>
#include <semaphore.h>
#include <fcntl.h>

#define CHECK(err,val)                        \
  if (err != 0)                               \
    C_return(C_SCHEME_FALSE);                 \
  else                                        \
    C_return(C_fixnum(val));             

#define CHECK2(op)                              \
  if (op == 0)                                  \
    C_return(C_SCHEME_TRUE);                    \
  else                                          \
    C_return(C_SCHEME_FALSE);

<#

(module
 posix-semaphore *

 (import chicken scheme foreign)

 (define-foreign-type sem_t c-pointer)
 (define-foreign-type mode_t unsigned-integer)

 (define sem-failed (foreign-value "SEM_FAILED" sem_t))
 (define o/accmode (foreign-value "O_ACCMODE" unsigned-integer))
 (define o/rdonly (foreign-value "O_RDONLY" unsigned-integer))
 (define o/wronly (foreign-value "O_WRONLY" unsigned-integer))
 (define o/rdwr (foreign-value "O_RDWR" unsigned-integer))
 (define o/creat (foreign-value "O_CREAT" unsigned-integer))
 (define o/noctty (foreign-value "O_NOCTTY" unsigned-integer))
 (define o/trunc (foreign-value "O_TRUNC" unsigned-integer))
 (define o/append (foreign-value "O_APPEND" unsigned-integer))
 (define o/nonblock (foreign-value "O_NONBLOCK" unsigned-integer))
 (define o/ndelay (foreign-value "O_NDELAY" unsigned-integer))
 (define o/sync (foreign-value "O_SYNC" unsigned-integer))
 (define o/fsync (foreign-value "O_FSYNC" unsigned-integer))
 (define o/async (foreign-value "O_ASYNC" unsigned-integer))

 (define s/isuid (foreign-value "S_ISUID" mode_t))
 (define s/isgid (foreign-value "S_ISGID" mode_t))
 (define s/irusr (foreign-value "S_IRUSR" mode_t))
 (define s/iwusr (foreign-value "S_IWUSR" mode_t))
 (define s/ixusr (foreign-value "S_IXUSR" mode_t))
 (define s/irwxu (foreign-value "S_IRWXU" mode_t))
 (define s/irgrp (foreign-value "S_IRGRP" mode_t))	
 (define s/iwgrp (foreign-value "S_IWGRP" mode_t))	
 (define s/ixgrp (foreign-value "S_IXGRP" mode_t))	
 (define s/irwxg (foreign-value "S_IRWXG" mode_t))
 (define s/iroth (foreign-value "S_IROTH" mode_t))	
 (define s/iwoth (foreign-value "S_IWOTH" mode_t))
 (define s/ixoth (foreign-value "S_IXOTH" mode_t))
 (define s/irwxo (foreign-value "S_IRWXO" mode_t))

 (define sem-init (foreign-lambda* integer ((sem_t sem) (bool shared) (unsigned-integer value)) "C_return(sem_init(sem, shared, value));"))
 (define sem-destroy (foreign-lambda* scheme-object ((sem_t sem)) "CHECK2(sem_destroy(sem))"))

 (define sem-open (foreign-lambda* sem_t ((c-string name) (unsigned-integer oflag)) "C_return(sem_open(name, oflag));"))
 (define sem-open/mode (foreign-lambda* sem_t ((c-string name) (unsigned-integer oflag) (mode_t mode) (unsigned-integer value)) "C_return(sem_open(name, oflag, mode, value));"))

 (define sem-close (foreign-lambda* scheme-object ((sem_t sem)) "CHECK2(sem_close(sem))"))

 (define sem-unlink (foreign-lambda* scheme-object ((c-string name)) "CHECK2(sem_unlink(name))"))

 (define sem-wait (foreign-lambda* scheme-object ((sem_t sem)) "CHECK2(sem_wait(sem))"))

 (define sem-trywait (foreign-lambda* scheme-object ((sem_t sem)) "CHECK2(sem_trywait(sem))"))

 (define sem-timedwait (foreign-lambda* scheme-object ((sem_t sem) (unsigned-integer seconds) (unsigned-integer nanoseconds)) "
struct timespec tm;
clock_gettime(CLOCK_REALTIME, &tm);
tm.tv_sec += seconds;
tm.tv_nsec += nanoseconds;
CHECK2(sem_timedwait(sem, &tm))
"))

 (define sem-post (foreign-lambda* scheme-object ((sem_t sem)) "CHECK2(sem_post(sem))"))

 (define sem-getvalue (foreign-lambda* scheme-object ((sem_t sem)) "
int val = 0;
int err = sem_getvalue(sem, &val);
CHECK(err, val);
"))
 )
