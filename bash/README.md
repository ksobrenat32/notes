# Bash use notes

## Compatibility

```bash
#!/usr/bin/env bash
```

## Useful parameters

```bash
set -e (exit on error)
set -u (exit when undeclared variables)
set -x (trace what gets executed)
```

## Recomendations

Use variables like: "${var}" to avoid confusion

## Send to background

End commands with `&` to execute on background

When the command is already running, use `ctrl+z` to turn
 it into zombie (in background but not executing)

With `jobs` you can print already running processes

With `fg` you can bring back zombies processes from background
 to foreground and they start executing, with `bg` you can
 let zombie processes execute in the background.

> Remember you can use `kill -9 PID` to kill a proccess
> To obtain the PID, use `ps ax`
> Use `renice` to adjust priority of processes
