package main

import (
	"reflect"
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
)

func typeQuery(p *picker, query string) {
	p.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune(query)})
}

func press(p *picker, key tea.KeyType) {
	p.Update(tea.KeyMsg{Type: key})
}

func TestPickerPreservesSelectionsAcrossFuzzyFilters(t *testing.T) {
	p := newPicker([]target{{"aws_instance.web", "create"}, {"aws_s3_bucket.logs", "update"}})
	p.Init()
	typeQuery(p, "AINWEB") // Case-insensitive, non-contiguous match.
	if len(p.visible) != 1 || p.visible[0].address != "aws_instance.web" {
		t.Fatalf("fuzzy matches = %#v", p.visible)
	}
	press(p, tea.KeyTab)
	press(p, tea.KeyEsc)
	typeQuery(p, "s3log")
	press(p, tea.KeyTab)
	press(p, tea.KeyEnter)
	want := []string{"aws_instance.web", "aws_s3_bucket.logs"}
	if !p.submitted || !reflect.DeepEqual(p.addresses(), want) {
		t.Fatalf("submitted = %v; selected = %#v", p.submitted, p.addresses())
	}
}

func TestPickerToggleAllOnlyAffectsMatches(t *testing.T) {
	p := newPicker([]target{{"aws_instance.web", "create"}, {"aws_s3_bucket.logs", "update"}, {"aws_s3_bucket.data", "create"}})
	p.Init()
	typeQuery(p, "web")
	press(p, tea.KeyTab)
	press(p, tea.KeyEsc)
	typeQuery(p, "s3")
	press(p, tea.KeyCtrlA)
	if len(p.addresses()) != 3 {
		t.Fatalf("selected = %#v", p.addresses())
	}
	press(p, tea.KeyCtrlA)
	if got := p.addresses(); !reflect.DeepEqual(got, []string{"aws_instance.web"}) {
		t.Fatalf("selected after deselecting matches = %#v", got)
	}
	press(p, tea.KeyEsc)
	typeQuery(p, "web")
	press(p, tea.KeyTab)
	if len(p.addresses()) != 0 {
		t.Fatalf("revisited selection could not be toggled off: %#v", p.addresses())
	}
}

func TestPickerEmptyFilterResultsAndCancellation(t *testing.T) {
	p := newPicker([]target{{"aws_instance.web", "create"}})
	p.Init()
	press(p, tea.KeyEnter)
	if p.submitted || p.message == "" {
		t.Fatal("empty selection should remain in the menu")
	}
	typeQuery(p, "zzzz")
	for _, key := range []tea.KeyType{tea.KeyTab, tea.KeyDown, tea.KeyUp, tea.KeyCtrlA} {
		press(p, key)
	}
	if !strings.Contains(p.View(), "No matching resources") || len(p.addresses()) != 0 {
		t.Fatal("no-match filter should be safe and empty")
	}
	press(p, tea.KeyEsc)
	if p.quitting || len(p.visible) != 1 {
		t.Fatal("first escape should clear the query")
	}
	press(p, tea.KeyEsc)
	if !p.quitting || p.submitted {
		t.Fatal("second escape should cancel without submitting")
	}
}
