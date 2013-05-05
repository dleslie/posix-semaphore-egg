(use posix-semaphore)

(define name (format "test-semaphore-~S" (random 100000)))

(define mutex (sem-open/mode name o/creat 0644 10))
(when (sem-failed? mutex)
      (sem-unlink name)
      (display "Failed to open semaphore")
      (newline)
      (exit))

(sem-wait mutex)
(display (format "Semaphore value after wait is: ~S" (sem-getvalue mutex))) (newline)
(sem-post mutex)

(sem-close mutex)
(sem-unlink name)
