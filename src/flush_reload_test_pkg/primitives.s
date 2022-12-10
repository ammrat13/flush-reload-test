## Primitives for Flush+Reload
##
## See the corresponding `.nim` file for documentation.


.global rdtsc
rdtsc:

  # Since %rdx is caller-saved and %rax is the return value, we don't need to
  # save any registers

  # Use the SDM's suggestion for fences before the rdtsc
  # We don't need the second lfence since we don't need the rdtsc to time the
  # instructions afterward
  lfence
  rdtsc

  ret


.global probe
probe:

  # The %rdi, %rsi, and %rdx registers are caller-saved, and %rax contains the
  # result. We don't need to save any registers

  # Use the SDM's suggestion for fences before the rdtsc
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
