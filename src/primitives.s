## Basic assembly primitives for Flush+Reload
##
## The Flush+Reload attack, being a micro-architectural side-channel, relies on
## architecture-specific code. For instance, it has to flush the cache and read
## the cycle counters. This code implements the low-level primitives needed by
## the code.


.global rdtsc
rdtsc:
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
  ## See: [2], Volume 2, Chapter 4.3, RDTSC - Read Time-Stamp Counter
  ## See: [2], Volume 2, Chapter 4.3, MFENCE - Memory Fence
  ## See: [2], Volume 2, Chapter 3.2, LFENCE - Load Fence

  # Since %rdx is caller-saved and %rax is the return value, we don't need to
  # save any registers

  # Use the manual's suggestion for fences before the rdtsc [2]
  # We don't need the second lfence since we don't need the rdtsc to time the
  # instructions afterward
  mfence
  lfence
  rdtsc

  ret


.global probe
probe:
  ## Probe the time it takes to access an address
  ##
  ## This code access the address passed to it as the first parameter. It times
  ## how long it takes the processor to access it, then flushes it from the
  ## cache.
  ##
  ## Only the least significant 32 bits are used in timing. The timer will
  ## overflow after 1.43s at 3.0GHz. However, memory accesses should be much
  ## faster than that.
  ##
  ## See: [1]
  ## See: proc rdtsc(): uint32

  # The %rdi, %rsi, and %rdx registers are caller-saved, and %rax contains the
  # result. We don't need to save any registers

  # Use the manual's suggestion for fences before the rdtsc [2]
  # This way, all instructions have retired and written to memory before we
  # start the clock
  mfence
  lfence
  rdtsc
  # Save the old timestamp, then fence
  # This way, we don't dispatch the load until we have the current time
  movl %eax, %esi
  lfence

  # Do the load
  # Put the load into a register we don't care about. Again, we don't care about
  # the contents, just how long it took.
  movq (%rdi), %rdx

  # Get the time after the above instruction finishes
  # We only need an lfence since this core didn't execute any stores
  lfence
  rdtsc

  # Compute the time difference
  subl %esi, %eax

  # Flush the line from the cache
  clflush (%rdi)

  ret
