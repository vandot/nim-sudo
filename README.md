# sudo

Simple wrapper to execute osproc.exec* commands with sudo. 
Useful when CLI program is executed as a normal user and only couple of operations inside program need elevated privileges to run.
It wraps following osproc procs:
- execCmd
- execCmdEx
- execProcess
- execProcesses

```
var result = sudoCmdEx("ls -la")
if result.exitCode != 0:
    echo "listing folder content failed with code " &
    $result.exitCode & " and message " & result.output
    quit(1)
echo $result
```

## License

BSD 3-Clause License
