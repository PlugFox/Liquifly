/// Simple counter implementation for FFI example
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

/// Global counter storage
static COUNTERS: Mutex<Option<HashMap<i64, Arc<Mutex<Counter>>>>> = Mutex::new(None);

/// Counter structure
#[derive(Debug)]
struct Counter {
    value: i64,
}

impl Counter {
    fn new() -> Self {
        Self { value: 0 }
    }

    fn increment(&mut self) {
        self.value += 1;
    }

    fn get_value(&self) -> i64 {
        self.value
    }
}

/// Initialize the counters storage
fn ensure_initialized() {
    let mut storage = COUNTERS.lock().unwrap();
    if storage.is_none() {
        *storage = Some(HashMap::new());
    }
}

/// Create a new counter and return its ID
#[unsafe(no_mangle)]
pub extern "C" fn create_counter() -> i64 {
    ensure_initialized();

    let counter = Arc::new(Mutex::new(Counter::new()));
    let id = counter.as_ref() as *const _ as i64;

    let mut storage = COUNTERS.lock().unwrap();
    if let Some(ref mut map) = *storage {
        map.insert(id, counter);
    }

    id
}

/// Increment the counter
#[unsafe(no_mangle)]
pub extern "C" fn increment_counter(id: i64) -> bool {
    let storage = COUNTERS.lock().unwrap();
    if let Some(ref map) = *storage {
        if let Some(counter) = map.get(&id) {
            if let Ok(mut c) = counter.lock() {
                c.increment();
                return true;
            }
        }
    }
    false
}

/// Get the current value of the counter
#[unsafe(no_mangle)]
pub extern "C" fn get_counter_value(id: i64) -> i64 {
    let storage = COUNTERS.lock().unwrap();
    if let Some(ref map) = *storage {
        if let Some(counter) = map.get(&id) {
            if let Ok(c) = counter.lock() {
                return c.get_value();
            }
        }
    }
    -1
}

/// Destroy the counter and free resources
#[unsafe(no_mangle)]
pub extern "C" fn destroy_counter(id: i64) -> bool {
    let mut storage = COUNTERS.lock().unwrap();
    if let Some(ref mut map) = *storage {
        return map.remove(&id).is_some();
    }
    false
}
