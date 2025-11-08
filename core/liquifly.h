/*
 * Liquifly FFI Header
 *
 * C header file for Dart FFI bindings generation
 */

#ifndef LIQUIFLY_H
#define LIQUIFLY_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ========================================================================
 * Dart FFI Types
 * ======================================================================== */

typedef int64_t DartPort;

/* Function pointer type for Dart_PostCObject */
typedef bool (*DartPostCObjectFn)(DartPort port_id, void* message);

/* Store the Dart_PostCObject function pointer */
void store_dart_post_cobject(DartPostCObjectFn ptr);

/* ========================================================================
 * Counter API
 * ======================================================================== */

/* Create a new counter and return its ID */
int64_t create_counter(void);

/* Increment the counter by 1 */
bool increment_counter(int64_t id);

/* Get the current value of the counter */
int64_t get_counter_value(int64_t id);

/* Destroy the counter and free resources */
bool destroy_counter(int64_t id);

#ifdef __cplusplus
}
#endif

#endif /* LIQUIFLY_H */
