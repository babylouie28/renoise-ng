# Loop Composer

Loop Composer lets you define a sequence of pattern-range loops.

Stuff is still shaping up.

Download a packaged version from [the Neurogami software page](http://neurogami.com/code) when it's suitable for general use.


# Usage

Install the tool.

Create a song with multiple patterns

![Example song](../../images/ng-lc001.png "Example song with multiple patterns")

Navigate the Tool menu to `Tools:Neurogami:LoopComposer:Compose`

![Example song](../../images/ng-lc002_menu.png "LoopComposer menu")

This brings up the composition editor.

![Example song](../../images/ng-lc003_compose_window.png "LoopComposer compostion editor")


It's super basic.

It's a single text field.

A composition is a series of lines.
Each line has three numbers, separated by spaces.

You may add an optional fourth item: the name of a function.

For example:

      1 2 2
      4 4 1 rand_looping
      3 4 2
      1 1 2
      4 5 1
      1 1 1
      5 5 1 restart

The first two numbers are the start and end patterns for a loop.

The third number is how many times that loop should run before moving on to the next loop.

The optional function name will get called after the loop has run the given number of times.  

Blank lines are (or should be) ignored.  The code does not try hard to catch or fix possible mistakes.

Once you have created a composition, click the "Save" button.

Navigate back to the `LoopComposer` menu and click "Run" to start your composition.


### Built-in helper functions


These are the helper functions defined so far:

 `restart`: Resets the loop pointer back to the first loop defininition in your compostion.

 `rand_looping`:  Defines a 50/50 change of resetting the loop pointer back to the current loop definition

 `rand_jump`: Sets the loop pointer to a random loop in your composition






# Author

Copyright James Britt / Neurogami - james@neurogami.com

## Licence

[MIT License.](http://opensource.org/licenses/MIT)


Feed your head

Hack your world

Live curious



