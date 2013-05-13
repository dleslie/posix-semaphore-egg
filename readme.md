Constants
===

Open Flags
----

>  o/accmode

>  o/rdonly

>  o/wronly

>  o/rdwr

>  o/creat

>  o/noctty

>  o/trunc

>  o/append

>  o/nonblock

>  o/ndelay

>  o/sync

>  o/fsync

>  o/async

Valid mode_t Flags
----

>  s/isuid

>  s/isgid

>  s/irusr

>  s/iwusr

>  s/ixusr

>  s/irwxu

>  s/irgrp

>  s/iwgrp

>  s/ixgrp

>  s/irwxg

>  s/iroth

>  s/iwoth

>  s/ixoth

>  s/irwxo

Core Functions
====

>  (make-sem)

Allocates memory for a semaphore.

>  (free-sem semaphore)

Frees memory allocated for a semaphore.

>  (sem-init semaphore shared? value)

Initializes a semaphore. If `shared?` is true then the semaphore will be shared with processes which are not its children, and so must reside in a POSIX shared memory range. `value` is an integer.

>  (sem-destroy semaphore)

Destroys an un-named semaphore.

>  (sem-failed? semaphore)

Returns true if `semaphore` is a pointer to the special failed semaphore, indicating that `sem-open` failed to operate as desired.

>  (sem-open name open-flags)

Given a string `name` and an integer mask of `open-flags`, attempts to open a semaphore using the given flags. Returns a semaphore, or false if the operation failed.

>  (sem-open/mode name open-flags mode_t value)

Given a string `name` and an integer mask of `open-flags`, attempts to open a semaphore using the given flags. If `open-flags` is o/creat, then it will attempt to allocate a new semaphore with the given `mode_t` and a particular integer value. Returns a semaphore, or false if the operation failed.

>  (sem-close semaphore)

Given a semaphore, attempts to close the semaphore. Returns true if successful, false otherwise.

>  (sem-unlink name)

Unlinks a semaphore by the given name. Returns true if successful, false otherwise.

>  (sem-wait semaphore)

Attempts to decrement a semaphore. It will block until doing so is possible.

>  (sem-trywait semaphore)

Attempts to decrement a semaphore. It will not block if it is not possible to do so, and will return true if the semaphore was decremented and false otherwise.

>  (sem-timedwait semaphore seconds nano-seconds)

Attempts to decrement a semaphore. It will block for a maximum of `seconds + nanoseconds`, and will return true if the semaphore was decremented and false otherwise.

>  (sem-post semaphore)

Increments a semaphore.

>  (sem-getvalue semaphore)

Gets the value of the semaphore. This command is non-blocking and non-deterministic.

Utility Procedures
====

>  (create-sem name value #!key (open-flags o/creat) (mode 0644))

Uses sem-open/mode to open or create a new semaphore, defaulting to creating. If doing so failed then it will unlink the name and return false. If doing so succeeded then it sets a finalizer that closes and unlinks the semaphore, and returns the new semaphore.

>  (with-sem/try semaphore . body)

Macro that uses dynamic-wind to ensure that the semaphore is properly posted regardless of the outcome of `body ...`.

>  (with-sem/try semaphore body-success body-fail)

Macro that uses dynamic-wind to ensure that the semaphore is properly posted regardless of the outcome of `body-success` and `body-fail`. `body-success` is called if the semaphore could be decremented, otherwise `body-fail` is called.

>  (with-sem/timed semaphore seconds nano-seconds body-success body-fail)

Macro that uses dynamic-wind to ensure that the semaphore is properly posted regardless of the outcome of `body-success` and `body-fail`. `body-success` is called if the semaphore was able to be decremented in `seconds + nano-seconds`, otherwise `body-fail` is called.

Example
====

```scheme
(use posix-semaphore)

;; Just in case some other proc has 'test-semaphore', I've tacked on a random number.
;; This shouldn't ever be necessary, or you could use the pid instead.
;; But for testing it came in handy.
(define name (format "test-semaphore-~S" (random 100000)))

;; create-sem handles the name linking and sem-failed? check, as well as setting a finalizer to clean up the semaphore.
(define mutex (create-sem name 1))
(when (not mutex)
      (display "Failed to open semaphore\n")
      (exit))

;; Using sem-getvalue is sort of dangerous. It gets the value of the semaphore at the time it is called, but you cannot expect that value to be consistent.
;; If you have a semaphore with an initial value greater than 1 then even calling sem-getvalue after a successful sem-post cannot assure a consistent value.
(display (format "Semaphore value before post is: ~S\n" (sem-getvalue mutex)))

;; with-sem and its alternates use dynamic-wind to ensure that the semaphore is posted even if the body breaks during operation.
;; Think of it as lock(){..} in C#, or a lock object in C++
(with-sem mutex
          (display (format "Semaphore value after wait is: ~S\n" (sem-getvalue mutex))))

(display (format "Semaphore value after post is: ~S\n" (sem-getvalue mutex)))
```

Author
====

Dan Leslie (dan@ironoxide.ca)

License
====

Copyright 2013 Daniel J. Leslie. All rights reserved.

The contact email address for Daniel J. Leslie is dan@ironoxide.ca

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY DANIEL J. LESLIE ''AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DANIEL J. LESLIE OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Daniel J. Leslie.
