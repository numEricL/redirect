# Redirect
Redirect is a simple vim tool to redirect output into a scratch buffer.

## Usage
There are two methods of redirection, the command method or the toggle method.
**Command method**
Call the `Redirect` command with a vim command to redirect its output
**Toggle method**
Turn on the toggle (default `<leader>r`) to begin capturing all output. When the
toggle is turned off all captured output is printed to buffer.

## Hints
The command method can be used with shell commands, e.g.
```
:Redirect !ls
```
but is difficult to use when strings are passed. For example, to capture
the output of `echo "hello world"` you must escape the quotes: `echo \"hello
world\"` In this situation it is easier to use the toggle method.
