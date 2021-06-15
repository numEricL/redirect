# Redirect
Redirect is a simple vim tool to redirect output into a scratch buffer.

## Usage
There are two ways to use Redirect, the command method or the toggle method.

**Command method**
Call the `Redirect[!]` command with a vim command to redirect its output. if `!`
is provided and the `hidden` option is set, the redirect buffer stays in the
background.

**Toggle method**
Turn on the toggle (default `<leader>r`) to begin capturing all output. When the
toggle is turned off all captured output is printed to buffer.

## Scratch Buffer
By default, a `[sratch]` buffer (like you get with `:new`) is used for the
redirection. A named buffer can be used instead by chaning the value of
`g:Redirect_buffer`.

## Hints
The command method can be used with shell commands, e.g.
```
:Redirect !ls
```
but is difficult to use when strings are passed. For example, to capture
the output of `echo "hello world"` you must escape the quotes: `echo \"hello
world\"` In this situation it is easier to use the toggle method.

## Defaults
```
let g:Redirect_map_toggle = '<leader>r'
let g:Redirect_buffer = 'default'
```
