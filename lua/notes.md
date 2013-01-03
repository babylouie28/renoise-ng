The `GlobalOscActions.lua` file is based on the one that comes with Renoise.

If you want to add or modify the set of OSC handlers available to Renoise the suggested process is to copy the default file to `Script` difrectory of your local Renoise config directory:

`~/.renoise/[version-number]/Scripts`

and then make your changes to that copy.

If you alter the file in the actual Renoise installation you run the risk of losing your changes if you upgrade.

As the file name indicates the language used is [Lua](http://www.lua.org/).

If you have some experience with another "scripting" or interpreted language, such as Ruby, Python, or JavaScript, then picking up Lua should be fairly easy, albeit at times annoying. "Annoying" because a) you will find your self using syntax and conventions from other languages, and b) it has it's own quirks.  In other words, it will just like when you learned Ruby, Python, or JavaScript.

Something to note: Lua is big on what it calls [tables](http://lua-users.org/wiki/TablesTutorial).  They're like arrays in some other languages, or (maybe more so) like associative arrays in JavaScript.  Here's the kicker: indexing starts at 1, not 0, like in a Real Programming Language.  I know, right? Facepalm city!  

If you want to learn about the Renoise Lua API (and you should if you're poking about in `GlobalOscActions.lua`) see the [xrnx
Renoise Lua Scripting](http://code.google.com/p/xrnx/) page.




