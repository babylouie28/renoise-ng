# com.neurogami.Utils

This is not really a tool.  It's a step towards having a single place for code used in a multiple other tools.

There are various functions , such as `clamp_value`  `trim`, and `base_file_name` that were using in different tools.

At first such functions were placed into a `Utils.lua` file, and each tool had its own version.

When the number of helper functions and tools was small the maintenance overhead was not too big a deal.

But as each grew it became silly to have different versions of `Utils.lua` for each tool, and in some cases different versions or calling semantics for what amounted to the same function.

Two approaches came to mind.  One was to create a tool that would exist solely to provide a source file to be loaded by hacking the Lua load path.  This would mean remving the `Utils.lua` file from each tool, and make each tool dependant on this other shared utils tool.

The other approach was to create this common file but use a build script to copy it into all other tools that used it.

This has the advantage of allowing an end user to install just the tool they are interested in.  

This created another question: Include the copies in the git repo, or omit them and require people to run a `rake` task to add it.

For now the copies are also included in the repo.  It breaks a sensible rule of not checking in things that are generated. Sue me.


