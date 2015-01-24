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
Each line has exactly three numbers, separated by spaces.

For example:

      1 2 2
      4 4 1
      3 4 2
      1 1 2
      4 5 1
      1 1 1
      5 5 1

The first two numbers are the start and end patterns for a loop.

The third number is how many times that loop should run before moving on to the next loop.

Blank lines are (or should be) ignored.  The code does not try hard to catch or fix possible mistakes.

Once you have created a composition, click the "Save" button.

Navigate back to the `LoopComposer` menu and click "Run" to start your composition.



# Author

Copyright James Britt / Neurogami - james@neurogami.com

## Licence

[MIT License.](http://opensource.org/licenses/MIT)


Feed your head

Hack your world

Live curious



