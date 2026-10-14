package main

import (
	"context"
	"io"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

const examplePlan = `{
  "format_version": "1.2",
  "terraform_version": "1.13.0",
  "resource_changes": [
    {"address":"aws_instance.unchanged","change":{"actions":["no-op"]}},
    {"address":"aws_instance.web[0]","change":{"actions":["delete","create"]}},
    {"address":"aws_instance.web[0]","deposed":"1234","change":{"actions":["delete"]}},
    {"address":"aws_s3_bucket.logs[\"prod\"]","change":{"actions":["create"]}},
    {"address":"data.aws_ami.latest","mode":"data","change":{"actions":["read"]}},
    {"address":"aws_s3_bucket.imported","change":{"actions":["no-op"],"importing":{"id":"example"}}},
    {"address":"module.new.aws_instance.moved","previous_address":"aws_instance.old","change":{"actions":["no-op"]}},
    {"address":"aws_instance.incomplete"},
    null
  ]
}`

func TestPlanTargets(t *testing.T) {
	plan, err := readPlan(context.Background(), "-", strings.NewReader(examplePlan), io.Discard)
	if err != nil {
		t.Fatal(err)
	}
	want := []target{
		{"aws_instance.web[0]", "replace+delete"},
		{"aws_s3_bucket.imported", "import"},
		{`aws_s3_bucket.logs["prod"]`, "create"},
		{"data.aws_ami.latest", "read"},
		{"module.new.aws_instance.moved", "move"},
	}
	if got := planTargets(plan); !reflect.DeepEqual(got, want) {
		t.Fatalf("targets = %#v; want %#v", got, want)
	}
}

func TestReadPlan(t *testing.T) {
	for _, tc := range []struct {
		name, input string
		valid       bool
	}{
		{"changes", examplePlan, true},
		{"empty plan", `{"format_version":"1.2","planned_values":{}}`, true},
		{"output only", `{"format_version":"1.2","output_changes":{"count":{"actions":["update"],"after":9007199254740993}}}`, true},
		{"empty input", "", false},
		{"truncated", `{"format_version":`, false},
		{"unsupported version", `{"format_version":"2.0","planned_values":{}}`, false},
		{"state", `{"format_version":"1.0","values":{}}`, false},
		{"streaming UI JSON", `{"type":"planned_change"}`, false},
		{"trailing JSON", examplePlan + `{}`, false},
		{"binary stdin", "PK\x03\x04archive", false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			_, err := readPlan(context.Background(), "-", strings.NewReader(tc.input), io.Discard)
			if (err == nil) != tc.valid {
				t.Fatalf("readPlan error = %v; valid = %v", err, tc.valid)
			}
		})
	}
}

func TestReadPlanJSONFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "plan.json")
	if err := os.WriteFile(path, []byte(examplePlan), 0o600); err != nil {
		t.Fatal(err)
	}
	// Reading JSON files must not require Terraform on PATH.
	t.Setenv("PATH", t.TempDir())
	plan, err := readPlan(context.Background(), path, strings.NewReader("unused"), io.Discard)
	if err != nil || len(planTargets(plan)) != 5 {
		t.Fatalf("readPlan: %v", err)
	}
}

func TestReadPlanBinaryFile(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "-plan with spaces")
	if err := os.WriteFile(path, []byte("PK\x03\x04archive"), 0o600); err != nil {
		t.Fatal(err)
	}
	// Verify the read-only subprocess contract without needing a provider or
	// contacting a backend. The plan is passed as one absolute-path argument.
	stub := "#!/bin/sh\n[ \"$#\" = 3 ] && [ \"$1\" = show ] && [ \"$2\" = -json ] && [ \"$3\" = \"$EXPECTED_PLAN\" ] || exit 42\nprintf '%s' \"$PLAN_JSON\"\n"
	terraform := filepath.Join(dir, "terraform")
	if err := os.WriteFile(terraform, []byte(stub), 0o700); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", dir)
	t.Setenv("EXPECTED_PLAN", path)
	t.Setenv("PLAN_JSON", examplePlan)
	if _, err := readPlan(context.Background(), path, nil, io.Discard); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(terraform, []byte("#!/bin/sh\nexit 17\n"), 0o700); err != nil {
		t.Fatal(err)
	}
	if _, err := readPlan(context.Background(), path, nil, io.Discard); err == nil {
		t.Fatal("expected terraform show failure")
	}
}
