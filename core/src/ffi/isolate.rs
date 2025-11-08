/// Isolate wrapper for sending messages to Dart
use super::dart_types::{DartCObject, DartPort, DartPostCObjectFn};
use std::sync::atomic::{AtomicPtr, Ordering};

/// Global pointer to Dart_PostCObject function
static DART_POST_COBJECT: AtomicPtr<()> = AtomicPtr::new(std::ptr::null_mut());

/// Store the Dart_PostCObject function pointer
/// This should be called once from Dart side during initialization
#[unsafe(no_mangle)]
pub unsafe extern "C" fn store_dart_post_cobject(ptr: DartPostCObjectFn) {
    DART_POST_COBJECT.store(ptr as *mut (), Ordering::Release);
}

/// Isolate represents a Dart isolate port
#[derive(Debug, Copy, Clone)]
pub struct Isolate {
    port: DartPort,
}

impl Isolate {
    /// Create a new Isolate with the given port
    pub fn new(port: DartPort) -> Self {
        Self { port }
    }

    /// Post a message to the isolate
    /// Returns true if successful, false otherwise
    pub fn post(&self, message: DartCObject) -> bool {
        let func_ptr = DART_POST_COBJECT.load(Ordering::Acquire);
        if func_ptr.is_null() {
            return false;
        }

        unsafe {
            let func: DartPostCObjectFn = std::mem::transmute(func_ptr);
            let mut msg = message;
            func(self.port, &mut msg)
        }
    }

    /// Post an i64 value to the isolate
    pub fn post_int(&self, value: i64) -> bool {
        self.post(DartCObject::int64(value))
    }

    /// Post a bool value to the isolate
    pub fn post_bool(&self, value: bool) -> bool {
        self.post(DartCObject::bool(value))
    }

    /// Post a f64 value to the isolate
    pub fn post_double(&self, value: f64) -> bool {
        self.post(DartCObject::double(value))
    }
}
