(use posix-semaphore uuid posix)

;; Just in case some other proc has 'test-semaphore', I've tacked on a random number.
;; This shouldn't ever be necessary, or you could use the pid instead.
;; But for testing it came in handy.
(define name (format "/test-semaphore-~S" (uuid-v4)))

;; create-sem handles the name linking and sem-failed? check, as well as setting a finalizer to clean up the semaphore.
(define mutex (create-sem name 1))
(when (not mutex)
      (printf "Failed to open semaphore\n")
      (exit))

;; Using sem-getvalue is sort of dangerous. It gets the value of the semaphore at the time it is called, but you cannot expect that value to be consistent.
;; If you have a semaphore with an initial value greater than 1 then even calling sem-getvalue after a successful sem-post cannot assure a consistent value.
(printf "Semaphore value before post is: ~S\n" (sem-getvalue mutex))

;; with-sem and its alternates use dynamic-wind to ensure that the semaphore is posted even if the body breaks during operation.
;; Think of it as lock(){..} in C#, or a lock object in C++
(with-sem mutex
          (printf "Semaphore value after wait is: ~S\n" (sem-getvalue mutex)))

(printf "Semaphore value after post is: ~S\n" (sem-getvalue mutex))

(process-fork (lambda ()
                (with-sem mutex
                          (printf "Child process locked the mutex, value: ~S\n" (sem-getvalue mutex))
                          (sleep 2))
                (printf "Child process unlocked the mutex, value: ~S\n" (sem-getvalue mutex))))

(sleep 1)

(with-sem mutex
          (printf "Parent process locked the mutex, value: ~S\n" (sem-getvalue mutex))
          (sleep 1))

(printf "Parent process unlocked the mutex, value: ~S\n" (sem-getvalue mutex))
