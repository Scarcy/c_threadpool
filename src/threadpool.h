// Just for testing Zig Test integration
#include <stdint.h>
int32_t add(int32_t a, int32_t b);

void tpool_submit();

void tpool_shutdown();

// Forced quit immedietly
void tpool_shutdownNow();

void tpool_newFixedThreadPool();

/*
while (task != null || (task = getTask()) != null) {
        task.run();
    task = null;
}
*/
