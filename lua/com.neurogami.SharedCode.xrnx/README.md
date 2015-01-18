# Shared Code 


This is part of an ongoing experiment in sharing common files across multiple Renoise tools.


See ["Sharing Lua files in Renoise"](http://neurogami.com/blog/neurogami-sharing-lua-files-in-renoise.html).


The basic idea is that tools can find other tools because they are installed in a known location.  

A special tool can be created thta is no moren than a place to store files to be used by other tools.

Those other tool scan load the shared tools files by altering the Lua load path.

The intended goal is to have  single version of reusabel code shared among many tools.
