package main

import (
	"bytes"
	"encoding/base64"
	"errors"
	"os/exec"
	"strings"
	"testing"
)

func TestTargetFlagsShellRoundTrip(t *testing.T) {
	addresses := []string{
		"aws_instance.web",
		"module.app[0].aws_instance.web[1]",
		`aws_s3_bucket.logs["prod"]`,
		"aws_s3_bucket.logs[\"it's $(printf unsafe) `printf unsafe` $HOME; *\"]",
	}
	for _, shell := range []string{"sh", "bash", "zsh"} {
		t.Run(shell, func(t *testing.T) {
			path, err := exec.LookPath(shell)
			if err != nil {
				t.Skip(err)
			}
			// Only synthetic addresses are evaluated; no Terraform is executed.
			cmd := exec.Command(path, "-c", "set -- "+targetFlags(addresses)+"; printf '%s\\0' \"$@\"")
			got, err := cmd.Output()
			if err != nil {
				t.Fatal(err)
			}
			var want strings.Builder
			for _, address := range addresses {
				want.WriteString("-target=" + address + "\x00")
			}
			if string(got) != want.String() {
				t.Fatalf("shell args = %q; want %q", got, want.String())
			}
		})
	}
}

func TestWriteTargets(t *testing.T) {
	addresses := []string{`module.app.aws_instance.web["prod"]`, "aws_s3_bucket.logs"}
	flags := targetFlags(addresses)
	for _, output := range []string{"stdout", "clipboard", "both"} {
		t.Run(output, func(t *testing.T) {
			var stdout, tty bytes.Buffer
			if err := writeTargets(&stdout, &tty, addresses, output, false); err != nil {
				t.Fatal(err)
			}
			wantStdout, wantTTY := "", ""
			if output != "clipboard" {
				wantStdout = flags + "\n"
			}
			if output != "stdout" {
				wantTTY = "\x1b]52;c;" + base64.StdEncoding.EncodeToString([]byte(flags)) + "\x07"
			}
			if stdout.String() != wantStdout || tty.String() != wantTTY {
				t.Fatalf("stdout = %q; tty = %q", stdout.String(), tty.String())
			}
		})
	}
	var stdout, tty bytes.Buffer
	if err := writeTargets(&stdout, &tty, addresses, "clipboard", true); err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(tty.String(), "\x1bPtmux;\x1b\x1b]52;c;") || !strings.HasSuffix(tty.String(), "\x1b\\") {
		t.Fatalf("tmux sequence = %q", tty.String())
	}
	stdout.Reset()
	tty.Reset()
	if err := writeTargets(&stdout, &tty, nil, "both", false); err != nil || stdout.Len() != 0 || tty.Len() != 0 {
		t.Fatalf("empty selection produced output or error: %v", err)
	}
}

type failingWriter struct{}

func (failingWriter) Write([]byte) (int, error) { return 0, errors.New("write failed") }

func TestWriteTargetsFailure(t *testing.T) {
	var tty bytes.Buffer
	if err := writeTargets(failingWriter{}, &tty, []string{"aws_instance.web"}, "both", false); err == nil || tty.Len() != 0 {
		t.Fatal("stdout failure should stop before changing the clipboard")
	}
	if err := writeTargets(&bytes.Buffer{}, failingWriter{}, []string{"aws_instance.web"}, "clipboard", false); err == nil {
		t.Fatal("clipboard write failure should be reported")
	}
}

func TestCommandValidationAndNoChanges(t *testing.T) {
	for _, tc := range []struct {
		name  string
		args  []string
		input string
		valid bool
	}{
		{"default stdin", nil, `{"format_version":"1.2","planned_values":{}}`, true},
		{"explicit stdin", []string{"-"}, `{"format_version":"1.2","planned_values":{}}`, true},
		{"invalid output", []string{"--output", "bad"}, "", false},
		{"extra argument", []string{"one", "two"}, "", false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			cmd := newCommand()
			var stdout, stderr bytes.Buffer
			cmd.SetArgs(tc.args)
			cmd.SetIn(strings.NewReader(tc.input))
			cmd.SetOut(&stdout)
			cmd.SetErr(&stderr)
			cmd.SilenceUsage = true
			err := cmd.Execute()
			if (err == nil) != tc.valid || stdout.Len() != 0 {
				t.Fatalf("error = %v; stdout = %q", err, stdout.String())
			}
		})
	}
}
