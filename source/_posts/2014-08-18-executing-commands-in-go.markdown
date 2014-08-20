---
layout: post
title: "Command Execution in Go"
date: 2014-08-18 09:00:00 +0100
comments: true
categories: golang
---

The ability to execute external commands from within an application is something I often feel is a bit *hackish* and I haven't yet discovered a language that handles it as well as I would like. That was until I learned to love how Go tackles the challenge. This post will show you how to make the most of `os/exec`.

<!-- more -->

I tend to feel that there are three different types of command execution within applications.

- Plain output. For when you always expect the command to execute but all you want from it is the output.
- Exit codes. These perform some cleanup, setup or check and you want to discard any output but assert the exit code.
- Long running processes. This case is rarer but there are times when I want to spawn sub-processes. Maybe even starting up another server to proxy to for instance.

So how do I handle these in Go? The magic all comes from the wonderful [os/exec][1] which is part of the Go standard library. Using this library, commands become a first class citizen within your application.

*For all examples I am only going to include the primary logic but I will keep a link to a full copy in the Go Playgroud. The copies won't execute within the Playground due to the restrictions Google have in place but they should run fine locally.*

I have defined the following functions to keep the examples short:

```go
func printCommand(cmd *exec.Cmd) {
  fmt.Printf("==> Executing: %s\n", strings.Join(cmd.Args, " "))
}

func printError(err error) {
  if err != nil {
    os.Stderr.WriteString(fmt.Sprintf("==> Error: %s\n", err.Error()))
  }
}

func printOutput(outs []byte) {
  if len(outs) > 0 {
    fmt.Printf("==> Output: %s\n", string(outs))
  }
}
```

## Collecting output

The first and most obvious use is to collect output from an external command. An easy way to do that is to use the `CombinedOutput` function.

```go combined_output.go
// Create an *exec.Cmd
cmd := exec.Command("echo", "Called from Go!")

// Combine stdout and stderr
printCommand(cmd)
output, err := cmd.CombinedOutput()
printError(err)
printOutput(output) // => go version go1.3 darwin/amd64

// http://play.golang.org/p/-7PWDpt6zS
```

This works well if you also want to check for any error messages output but if you want finer control over the output of a command then we can route it into different buffers giving us control over both standard output and standard error.

```go individual_buffers.go
// Create an *exec.Cmd
cmd := exec.Command("go", "version")

// Stdout buffer
cmdOutput := &bytes.Buffer{}
// Attach buffer to command
cmd.Stdout = cmdOutput

// Execute command
printCommand(cmd)
err := cmd.Run() // will wait for command to return
printError(err)
// Only output the commands stdout
printOutput(cmdOutput.Bytes()) // => go version go1.3 darwin/amd64

// http://play.golang.org/p/_6xke11GMp
```

In the above example we manually connect our own buffer to capture the commands stdout stream. We can do the same for stderr and even stdin so long as it adheres to the `io.Reader` interface.

So far we've seen how easy it is to capture command output across multiple file descriptors. It's more verbose then other languages but it gives us lots of flexibility.

## Exit codes

Retrieving the exit code of a command is easy with Go. You may have already noticed in the previous examples that when executing the command Go can return an error. These errors occur if there is an issue with IO or of the command doesn't return a successful exit code (0).

The following code will output the exit code of a command.

```go exit_code.go
cmd := exec.Command("ls", "/imaginary/directory")
var waitStatus syscall.WaitStatus
if err := cmd.Run(); err != nil {
  printError(err)
  // Did the command fail because of an unsuccessful exit code
  if exitError, ok := err.(*exec.ExitError); ok {
    waitStatus = exitError.Sys().(syscall.WaitStatus)
    printOutput([]byte(fmt.Sprintf("%d", waitStatus.ExitStatus())))
  }
} else {
  // Command was successful
  waitStatus = cmd.ProcessState.Sys().(syscall.WaitStatus)
  printOutput([]byte(fmt.Sprintf("%d", waitStatus.ExitStatus())))
}

// http://play.golang.org/p/m2A17UWSOL
```
The above code looks more complicated but in traditional Go fashion it handles many situations.

- Create an `*exec.Cmd`
- Execute and test for any errors
- If we received an error then check it was because of the commands exit
- If no error then check the commands `*os.ProcessState` for the exit code (pretty much guaranteed to be 0 but in here for completion)

A caveat to take note of is that if Go failed to locate the command in your `$PATH` then it won't ever execute the command and thus you will have no exit code. This is why it is important to assert the type of error returned.

## Long running processes

All our above examples are synchronous. They wait for the command to complete before continuing the execution of our application. If we wanted to execute a long running task however it is likely that we want it to happen asynchronously. Once again this is trivially easy.

```go long_running.go
cmd := exec.Command("cat", "/dev/random")
randomBytes := &bytes.Buffer{}
cmd.Stdout = randomBytes

// Start command asynchronously
err := cmd.Start()
printError(err)

// Create a ticker that outputs elapsed time
ticker := time.NewTicker(time.Second)
go func(ticker *time.Ticker) {
  now := time.Now()
  for _ = range ticker.C {
    printOutput(
      []byte(fmt.Sprintf("%s", time.Since(now))),
    )
  }
}(ticker)

// Create a timer that will kill the process
timer := time.NewTimer(time.Second * 4)
go func(timer *time.Timer, ticker *time.Ticker, cmd *exec.Cmd) {
  for _ = range timer.C {
    err := cmd.Process.Signal(os.Kill)
    printError(err)
    ticker.Stop()
  }
}(timer, ticker, cmd)

// Only proceed once the process has finished
cmd.Wait()
printOutput(
  []byte(fmt.Sprintf("%d bytes generated!", len(randomBytes.Bytes()))),
)

// http://play.golang.org/p/tQRk1xJOqW
```

Now that was a lot more work but it all makes good sense. I started a computationaly difficult task of generating a collection of random bytes. Next I start that command asynchronously and then begin a ticker to show the elapsed time and a timer to kill the process after 4 seconds. Once the process has been killed then we output the total number of generated bytes.

*A small disclaimer. I don't claim that this is the best way to do this but it demonstrates asynchronous commands and the ability to send signals to the process within our application.*

## Closing comments

This has been quite a technical post but we have covered lots of ground with the flexibility of `os/exec`. I have tested all the examples on my Mac using go1.3. Any suggestions/improvements are welcomed.

I hope I've been able to get across why I'm beginning to really enjoy working with Go.

[1]: http://godoc.org/os/exec "GoDoc: os/exec"
