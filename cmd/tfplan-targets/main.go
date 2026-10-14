package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/aymanbagabas/go-osc52/v2"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/fang"
	"github.com/charmbracelet/huh"
	"github.com/charmbracelet/x/term"
	"github.com/spf13/cobra"
)

func main() {
	err := fang.Execute(context.Background(), newCommand(), fang.WithErrorHandler(func(w io.Writer, styles fang.Styles, err error) {
		if !errors.Is(err, huh.ErrUserAborted) {
			fang.DefaultErrorHandler(w, styles, err)
		}
	}))
	if errors.Is(err, huh.ErrUserAborted) {
		os.Exit(130)
	}
	if err != nil {
		os.Exit(1)
	}
}

func newCommand() *cobra.Command {
	output := "both"
	cmd := &cobra.Command{
		Use:   "tfplan-targets [plan|-]",
		Short: "Fuzzy-select Terraform changes and emit shell-quoted -target flags",
		Long: `Select resource changes from a saved Terraform plan or plan JSON file.
Read terraform show -json output from stdin when the path is omitted or '-'.
Saved binary plans are converted with terraform show -json in the current directory.

Type to fuzzy-filter; arrows move; Space/Tab toggles; Ctrl+A toggles all matches;
Enter submits; Esc clears the filter or cancels; Ctrl+C cancels.
Selections persist across filters. At least one selection is required.

By default, flags go to stdout and to the clipboard via OSC 52 on /dev/tty.
The interactive UI also uses /dev/tty, leaving stdout safe to redirect.
Paste the flags into a new terraform plan command to narrow its scope.`,
		Example: `  tfplan-targets tfplan
  tfplan-targets plan.json --output stdout
  terraform show -json tfplan | tfplan-targets -
  tfplan-targets tfplan --output clipboard`,
		Args: cobra.MaximumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			switch output {
			case "stdout", "clipboard", "both":
			default:
				return fmt.Errorf("invalid output %q: choose stdout, clipboard, or both", output)
			}
			path := "-"
			if len(args) == 1 {
				path = args[0]
			}
			if input, ok := cmd.InOrStdin().(*os.File); path == "-" && ok && term.IsTerminal(input.Fd()) {
				return errors.New("provide a plan path or pipe terraform show -json output into stdin")
			}
			plan, err := readPlan(cmd.Context(), path, cmd.InOrStdin(), cmd.ErrOrStderr())
			if err != nil {
				return err
			}
			targets := planTargets(plan)
			if len(targets) == 0 {
				_, err := fmt.Fprintln(cmd.ErrOrStderr(), "No resource changes to target.")
				return err
			}
			tty, err := os.OpenFile("/dev/tty", os.O_RDWR, 0)
			if err != nil {
				return fmt.Errorf("interactive selection requires a controlling terminal: %w", err)
			}
			defer tty.Close()
			picker := newPicker(targets)
			_, err = tea.NewProgram(picker, tea.WithInput(tty), tea.WithOutput(tty), tea.WithAltScreen(), tea.WithContext(cmd.Context())).Run()
			if err != nil {
				return fmt.Errorf("select targets: %w", err)
			}
			if !picker.submitted {
				return huh.ErrUserAborted
			}
			return writeTargets(cmd.OutOrStdout(), tty, picker.addresses(), output, os.Getenv("TMUX") != "")
		},
	}
	cmd.Flags().StringVarP(&output, "output", "o", output, "Output destination: stdout, clipboard, or both")
	return cmd
}

func targetFlags(addresses []string) string {
	flags := make([]string, len(addresses))
	for i, address := range addresses {
		// POSIX shell quoting preserves brackets, double quotes, and arbitrary
		// for_each keys without allowing shell expansion when pasted.
		flags[i] = "-target='" + strings.ReplaceAll(address, "'", "'\"'\"'") + "'"
	}
	return strings.Join(flags, " ")
}

func writeTargets(stdout, tty io.Writer, addresses []string, output string, tmux bool) error {
	if len(addresses) == 0 {
		return nil
	}
	flags := targetFlags(addresses)
	if output == "stdout" || output == "both" {
		if _, err := fmt.Fprintln(stdout, flags); err != nil {
			return fmt.Errorf("write targets: %w", err)
		}
	}
	if output == "clipboard" || output == "both" {
		sequence := osc52.New(flags)
		if tmux {
			sequence = sequence.Tmux()
		}
		if _, err := sequence.WriteTo(tty); err != nil {
			return fmt.Errorf("write OSC 52 clipboard sequence: %w", err)
		}
	}
	return nil
}
