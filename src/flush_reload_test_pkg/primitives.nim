## Primitves for Flush+Reload
##
## The Flush+Reload attack, being a micro-architectural side-channel, relies on
## architecture-specific code. For instance, it has to flush the cache and read
## the cycle counters. This code implements the low-level primitives needed by
## the code.
##
## This module also implements the primitive of spinning for a certain number of
## cycles. That's not implemented in assembly since testing shows that it
## doesn't make much of a difference to performance.

{.compile: "./primitives.s".}


proc rdtsc*(): uint32 {.importc.}
  ## Read the timestamp counter
  ##
  ## Only the least significant 32 bits are reported. This overflows after 1.43s
  ## at 3.0GHz, which should be enough for what we're trying to do.
  ##
  ## As suggested by the manual, we add fences before the command. This way, we
  ## know all the commands before it have been executed, and that all the stores
  ## before it have been flushed to memory. Similarly, we have a fence after the
  ## command to ensure it completes before new commands are dispatched.
  ##
  ## See:
  ## * Intel SDM, Volume 2, Chapter 4.3, RDTSC - Read Time-Stamp Counter
  ## * Intel SDM, Volume 2, Chapter 4.3, MFENCE - Memory Fence
  ## * Intel SDM, Volume 2, Chapter 3.2, LFENCE - Load Fence

proc probe*[T](a: ptr T): uint32 {.importc.}
  ## See: `probe <#probe,pointer>`_
proc probe*[T](a: ref T): uint32 {.importc.}
  ## See: `probe <#probe,pointer>`_
proc probe*(a: pointer): uint32 {.importc.}
  ## Probe the time it takes to access an address
  ##
  ## This code accesses the address passed to it as the first parameter. It
  ## times how long it takes the processor to access it, then flushes it from
  ## the cache. Only the least significant 32 bits are used in timing. The timer
  ## will overflow after 1.43s at 3.0GHz. However, memory accesses should be
  ## much faster than that.
  ##
  ## Note: The code assumes that `ref`s are treated the same way `ptr`s are in
  ## function calls. Specifically, it expects a raw pointer to the object to be
  ## passed in register `%rax`. If Nim's calling convention changes, this
  ## function will likely have to be fixed.
  ##
  ## See:
  ##  * FLUSH+RELOAD Paper
  ##  * `rdtsc <#rdtsc>`_

proc spin*(n: uint32, start_time: uint32) =
  ## Spinlock until a certain number of cycles have passed since `start_time`
  ##
  ## This code continuously reads the timestamp counter until it reads at least
  ## `n` more than the value specified as the parameter. In other words, it
  ## spins for at least `n` cycles.
  ##
  ## Note: The value for `n` should not be too close to `high(uint32)`.
  ## Otherwise, the timer could overflow, causing the code to miss the fact that
  ## `n` cycles have elapsed.
  while rdtsc() - start_time < n:
    continue

proc spin*(n: uint32) =
  ## Spinlock until a certain number of cycles have passed
  ##
  ## Calls the overloaded version of this method, with the `start_time` set to
  ## the time read by `rdtsc <#rdtsc>`_. See: `spin <#spin,uint32,uint32>`_.
  spin(n, rdtsc())
