pub type File

@external(javascript, "./file_ffi.mjs", "read")
pub fn read(path: String) -> Result(String, String)
