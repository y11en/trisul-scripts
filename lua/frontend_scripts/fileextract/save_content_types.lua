-- save_content-types.lua
--
-- Working  script that saves all files matching a Content-Type REGEX (google RE2 format)
-- into /tmp/saved_content
-- 
-- The regex we are using is (shockwave|msdownload|dosexec|pdf) to save common malware files
--
TrisulPlugin = {

  id = {
    name = "Save Content Types 1",
    description = "How to save based on http content type",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },


  -- make sure the output directory is present 
  onload = function()
    os.execute("mkdir -p /tmp/savedfiles")
  end,


  -- Table filex_monitor contains functions in this module 
  filex_monitor  = {

    -- 
    -- filter :  return true for all Request headers (we dont knwo content-type yet)
    --       return true for all Response headers when content type is shockwave,msdownload,etcc
    --       return false for all responses with a unmatched content-type 
      --
    filter = function( engine,  timestamp, flowkey, header)
      if header:is_request() or 
         (header:is_response() and header:match_value("Content-Type", "(shockwave|msdownload|dosexec|pdf|octet)"))  then 
        return true
      else 
        return false
      end
    end,


    -- save all content to /tmp/savedfiles  
    -- notice we use T.async:copy instead of copying file directly using Linux 'cp'
    -- this is because we are in the fast packet path when executing this method so we
    -- do all I/O out in a separate thread 
    --
    onfile_http  = function ( engine, timestamp, flowkey, path, req_header, resp_header, length )

      -- separate the path (which is in ramfs) from the synthesized file name
      -- 
      local fn = path:match("^.+/(.+)$")
      T.async:copy( path, "/tmp/savedfiles/"..fn)

    end,


 }
}
