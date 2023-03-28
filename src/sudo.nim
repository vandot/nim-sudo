import os, osproc, posix, strtabs, sequtils

proc checkRoot(): bool =
  if getuid() == 0:
    return true
  return false

proc checkSudo(): bool =
  if findExe("sudo") != "":
    return true
  echo "Warning: sudo is not available, and command is not running as root. The operation might fail! ⚠️"
  return false

proc sudoCmd*(command: string): int {.gcsafe, extern: "nosp$1", tags: [
    ExecIOEffect, ReadIOEffect, RootEffect].} =
  ## Executes a command using osproc.execCmd with sudo if the user is not root and sudo is available.
  if checkRoot() or not checkSudo():
    return execCmd(command)
  return execCmd("sudo --prompt='Sudo password: ' -- " & command)

proc sudoCmdEx*(command: string;
               options: set[ProcessOption] = {poStdErrToStdOut, poUsePath};
               env: StringTableRef = nil; workingDir = ""; input = ""): tuple[
    output: string; exitCode: int] {.tags: [ExecIOEffect, ReadIOEffect,
    RootEffect], gcsafe.} =
  ## Executes a command using osproc.execCmdEx with sudo if the user is not root and sudo is available.
  if checkRoot() or not checkSudo():
    return execCmdEx(command, options, env, workingDir, input)
  return execCmdEx("sudo --prompt='Sudo password: ' -- " & command, options,
      env, workingDir, input)

proc sudoProcess*(command: string; workingDir: string = "";
                 args: openArray[string] = []; env: StringTableRef = nil;
    options: set[ProcessOption] = {poStdErrToStdOut, poUsePath,
        poEvalCommand}): string {.
    gcsafe, extern: "nosp$1", tags: [ExecIOEffect, ReadIOEffect, RootEffect].} =
  ## Executes a command using osproc.execProcess with sudo if the user is not root and sudo is available.
  if checkRoot() or not checkSudo():
    return execProcess(command, workingDir, args, env, options)
  return execProcess("sudo --prompt='Sudo password: ' -- " & command,
      workingDir, args, env, options)

proc sudoProcesses*(cmds: openArray[string];
                   options = {poStdErrToStdOut, poParentStreams};
                   n = countProcessors(); beforeRunEvent: proc (idx: int) = nil;
                   afterRunEvent: proc (idx: int; p: Process) = nil): int {.
    gcsafe, extern: "nosp$1",
    tags: [ExecIOEffect, TimeEffect, ReadEnvEffect, RootEffect],
    effectsOf: [beforeRunEvent, afterRunEvent].} =
  ## Executes a commands using osproc.execProcesses with sudo if the user is not root and sudo is available.
  if checkRoot() or not checkSudo():
    return execProcesses(cmds, options, n, beforeRunEvent, afterRunEvent)
  return execProcesses(cmds.mapIt("sudo --prompt='Sudo password: ' -- " & it),
      options, n, beforeRunEvent, afterRunEvent)
