YAOP -- Yet Another Options Parser
==================================

**YAOP** parses the command-line for both named (*arguments*) and 
unnamed (*parameters*) options and returns them in hash and array.
It's intended to be feature-less, simple and lightweight one. It uses
declarative approach. See example:

    require "yaop"
    
    options = YAOP::get do
        option "--strip"          # simple presency is enough
        
        options "-l", "--level"   # both of them
        type Integer, 7           # first part, default value 7
        type Integer, 8           # second part, default value 8
        type Integer, 9           # third part, default value 9
    end
    
If command line will be `script.rb -l 1 2 --strip "file1.txt" "file2.txt"`,
result will be:

    p options.arguments
    # will print { "--strip" => true, "-l" => [1, 2, 9], "--level" => [1, 2, 9] }
    
    p options.parameters
    # will print ["file1.txt", "file2.txt"]
    
Be warn, classic syntax like `-sl 1` isn't supported.


Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-change`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-change`).
5. Create an [Issue][2] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.

Copyright
---------

Copyright &copy; 2011-2012 [Martin Kozák][3]. See `LICENSE.txt` for
further details.

[2]: http://github.com/martinkozak/yaop/issues
[3]: http://www.martinkozak.net/
