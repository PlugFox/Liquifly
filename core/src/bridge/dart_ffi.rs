// FFI bindings for Dart Native API
// This replaces the `allo-isolate` dependency with direct C API usage

use std::os::raw::{c_char, c_int, c_void};

/// Dart port identifier (SendPort)
pub type DartPort = i64;

/// Dart C API types
#[repr(C)]
#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum DartCObjectType {
    Null = 0,
    Bool = 1,
    Int32 = 2,
    Int64 = 3,
    Double = 4,
    String = 5,
    Array = 6,
    TypedData = 7,
    ExternalTypedData = 8,
    SendPort = 9,
    Capability = 10,
    Unsupported = 11,
}

/// Dart typed data types
#[repr(C)]
#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum DartTypedDataType {
    ByteData = 0,
    Int8 = 1,
    Uint8 = 2,
    Uint8Clamped = 3,
    Int16 = 4,
    Uint16 = 5,
    Int32 = 6,
    Uint32 = 7,
    Int64 = 8,
    Uint64 = 9,
    Float32 = 10,
    Float64 = 11,
    Float32x4 = 12,
    Invalid = 13,
}

/// Dart C Object value union
#[repr(C)]
pub union DartCObjectValue {
    pub as_bool: bool,
    pub as_int32: i32,
    pub as_int64: i64,
    pub as_double: f64,
    pub as_string: *mut c_char,
    pub as_send_port: DartNativeSendPort,
    pub as_array: DartNativeArray,
    pub as_typed_data: DartNativeTypedData,
    pub as_external_typed_data: DartNativeExternalTypedData,
}

/// Dart C Object
#[repr(C)]
pub struct DartCObject {
    pub type_: DartCObjectType,
    pub value: DartCObjectValue,
}

#[repr(C)]
pub struct DartNativeSendPort {
    pub id: DartPort,
    pub origin_id: DartPort,
}

#[repr(C)]
pub struct DartNativeArray {
    pub length: isize,
    pub values: *mut *mut DartCObject,
}

#[repr(C)]
pub struct DartNativeTypedData {
    pub type_: DartTypedDataType,
    pub length: isize,
    pub values: *mut u8,
}

#[repr(C)]
pub struct DartNativeExternalTypedData {
    pub type_: DartTypedDataType,
    pub length: isize,
    pub data: *mut u8,
    pub peer: *mut c_void,
    pub callback: Option<extern "C" fn(*mut c_void)>,
}

/// Function pointer type for Dart_PostCObject
pub type DartPostCObjectFn =
    unsafe extern "C" fn(port_id: DartPort, message: *mut DartCObject) -> bool;

/// Global function pointer to Dart_PostCObject
static mut DART_POST_C_OBJECT: Option<DartPostCObjectFn> = None;

/// Initialize Dart API
///
/// Must be called once from Dart via FFI with NativeApi.postCObject address
#[no_mangle]
pub unsafe extern "C" fn init_dart_api(dart_post_c_object: DartPostCObjectFn) -> c_int {
    DART_POST_C_OBJECT = Some(dart_post_c_object);
    1 // Success
}

/// Post a message to Dart isolate
///
/// # Safety
/// Must be called after `init_dart_api`
pub unsafe fn post_message_to_dart(port: DartPort, message: *mut DartCObject) -> bool {
    match DART_POST_C_OBJECT {
        Some(post_fn) => post_fn(port, message),
        None => {
            eprintln!("ERROR: Dart API not initialized. Call init_dart_api first!");
            false
        },
    }
}

/// Helper: Send integer to Dart
pub unsafe fn post_int_to_dart(port: DartPort, value: i64) -> bool {
    let mut message = DartCObject {
        type_: DartCObjectType::Int64,
        value: DartCObjectValue { as_int64: value },
    };
    post_message_to_dart(port, &mut message)
}

/// Helper: Send boolean to Dart
pub unsafe fn post_bool_to_dart(port: DartPort, value: bool) -> bool {
    let mut message = DartCObject {
        type_: DartCObjectType::Bool,
        value: DartCObjectValue { as_bool: value },
    };
    post_message_to_dart(port, &mut message)
}

/// Helper: Send null to Dart
pub unsafe fn post_null_to_dart(port: DartPort) -> bool {
    let mut message = DartCObject {
        type_: DartCObjectType::Null,
        value: DartCObjectValue { as_int64: 0 },
    };
    post_message_to_dart(port, &mut message)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_struct_sizes() {
        // Ensure struct sizes match C ABI
        assert_eq!(std::mem::size_of::<DartCObject>(), 16);
    }
}
