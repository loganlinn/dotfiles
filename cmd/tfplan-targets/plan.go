package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"sort"
	"strings"

	tfjson "github.com/hashicorp/terraform-json"
)

type target struct {
	address string
	action  string
}

func readPlan(ctx context.Context, path string, stdin io.Reader, stderr io.Writer) (*tfjson.Plan, error) {
	var data []byte
	var err error
	if path == "-" {
		data, err = io.ReadAll(stdin)
	} else {
		data, err = os.ReadFile(path)
	}
	if err != nil {
		return nil, fmt.Errorf("read plan: %w", err)
	}
	// Saved Terraform plans are ZIP archives. JSON files can be read directly,
	// without Terraform or the original providers being installed.
	if bytes.HasPrefix(data, []byte("PK\x03\x04")) {
		if path == "-" {
			return nil, fmt.Errorf("stdin requires plan JSON; use terraform show -json <plan> | tfplan-targets")
		}
		absolutePath, err := filepath.Abs(path)
		if err != nil {
			return nil, fmt.Errorf("resolve plan path: %w", err)
		}
		show := exec.CommandContext(ctx, "terraform", "show", "-json", absolutePath)
		show.Stderr = stderr
		data, err = show.Output()
		if err != nil {
			return nil, fmt.Errorf("terraform show -json: %w", err)
		}
	}
	var plan tfjson.Plan
	plan.UseJSONNumber(true)
	if err := json.Unmarshal(data, &plan); err != nil {
		return nil, fmt.Errorf("decode plan JSON (expected terraform show -json output): %w", err)
	}
	// State JSON shares the format_version field with plan JSON. Do not report
	// a state snapshot as a successful plan with no changes.
	if plan.PlannedValues == nil && plan.ResourceChanges == nil && plan.OutputChanges == nil {
		return nil, fmt.Errorf("input is not plan JSON: expected planned_values, resource_changes, or output_changes")
	}
	return &plan, nil
}

func planTargets(plan *tfjson.Plan) []target {
	byAddress := make(map[string][]string)
	for _, resource := range plan.ResourceChanges {
		if resource == nil || resource.Address == "" || resource.Change == nil {
			continue
		}
		change := resource.Change
		var actions []string
		if resource.PreviousAddress != "" && resource.PreviousAddress != resource.Address {
			actions = append(actions, "move")
		}
		if change.Importing != nil {
			actions = append(actions, "import")
		}
		if change.Actions.Replace() {
			actions = append(actions, "replace")
		} else {
			for _, action := range change.Actions {
				if action != tfjson.ActionNoop {
					actions = append(actions, string(action))
				}
			}
		}
		if len(actions) == 0 {
			continue
		}
		// Deposed instances may repeat an address. Preserve their action labels
		// but emit only one target for the resource instance.
		for _, action := range actions {
			if !slices.Contains(byAddress[resource.Address], action) {
				byAddress[resource.Address] = append(byAddress[resource.Address], action)
			}
		}
	}
	result := make([]target, 0, len(byAddress))
	for address, actions := range byAddress {
		result = append(result, target{address: address, action: strings.Join(actions, "+")})
	}
	sort.Slice(result, func(i, j int) bool { return result[i].address < result[j].address })
	return result
}
