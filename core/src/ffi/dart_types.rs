/// Dart FFI types for interacting with Dart VM
/// Based on dart_native_api.h
use std::os::raw::c_char;

pub type DartPort = i64;

/// Function pointer type for Dart_PostCObject
pub type DartPostCObjectFn =
    unsafe extern "C" fn(port_id: DartPort, message: *mut DartCObject) -> bool;

/// Dart C Object types
#[repr(C)]
#[derive(Debug, Copy, Clone, PartialEq)]
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
}

/// Dart C Object value union
#[repr(C)]
#[derive(Copy, Clone)]
pub union DartCObjectValue {
    pub as_bool: bool,
    pub as_int32: i32,
    pub as_int64: i64,
    pub as_double: f64,
    pub as_string: *mut c_char,
}

/// Dart C Object structure
#[repr(C)]
#[derive(Copy, Clone)]
pub struct DartCObject {
    pub ty: DartCObjectType,
    pub value: DartCObjectValue,
}

impl DartCObject {
    pub fn null() -> Self {
        Self {
            ty: DartCObjectType::Null,
            value: DartCObjectValue { as_bool: false },
        }
    }

    pub fn bool(value: bool) -> Self {
        Self {
            ty: DartCObjectType::Bool,
            value: DartCObjectValue { as_bool: value },
        }
    }

    pub fn int32(value: i32) -> Self {
        Self {
            ty: DartCObjectType::Int32,
            value: DartCObjectValue { as_int32: value },
        }
    }

    pub fn int64(value: i64) -> Self {
        Self {
            ty: DartCObjectType::Int64,
            value: DartCObjectValue { as_int64: value },
        }
    }

    pub fn double(value: f64) -> Self {
        Self {
            ty: DartCObjectType::Double,
            value: DartCObjectValue { as_double: value },
        }
    }
}
