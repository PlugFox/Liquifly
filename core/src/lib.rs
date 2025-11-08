/// Liquifly - High-performance fluid simulation library
pub mod counter;
pub mod ffi;

// Re-export main FFI function
pub use ffi::store_dart_post_cobject;
