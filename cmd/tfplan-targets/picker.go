package main

import (
	"fmt"
	"slices"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/huh"
	"github.com/sahilm/fuzzy"
)

type picker struct {
	targets   []target
	visible   []target
	selected  map[string]bool
	values    []string
	list      *huh.MultiSelect[string]
	filter    textinput.Model
	width     int
	height    int
	message   string
	submitted bool
	quitting  bool
}

func newPicker(targets []target) *picker {
	filter := textinput.New()
	filter.Prompt = "Filter: "
	filter.Placeholder = "type to fuzzy-search addresses and actions"
	p := &picker{targets: targets, selected: make(map[string]bool), filter: filter, width: 80, height: 24}
	p.rebuild()
	return p
}

func (p *picker) Init() tea.Cmd { return p.filter.Focus() }

func (p *picker) rebuild() {
	p.visible = p.targets
	if query := p.filter.Value(); query != "" {
		labels := make([]string, len(p.targets))
		for i, t := range p.targets {
			labels[i] = t.address + " " + t.action
		}
		p.visible = nil
		for _, match := range fuzzy.Find(query, labels) {
			p.visible = append(p.visible, p.targets[match.Index])
		}
	}
	p.values = nil
	options := make([]huh.Option[string], 0, len(p.visible))
	for _, t := range p.visible {
		options = append(options, huh.NewOption(fmt.Sprintf("[%s] %s", t.action, t.address), t.address).Selected(p.selected[t.address]))
	}
	// Huh's built-in filter is substring-only. Rebuild its visible options for
	// ranked fuzzy results; keep selections outside the field so hidden items
	// survive filtering and toggling all visible results.
	p.list = huh.NewMultiSelect[string]().Options(options...).Value(&p.values).Filterable(false).Height(max(3, p.height-7))
	p.list.WithTheme(huh.ThemeCharm())
	p.list.WithKeyMap(huh.NewDefaultKeyMap())
	p.list.WithWidth(max(10, p.width))
	p.list.Focus()
	p.filter.Width = max(10, p.width-10)
}

func (p *picker) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		p.width, p.height = msg.Width, msg.Height
		p.list.WithWidth(max(10, p.width))
		p.list.Height(max(3, p.height-7))
		p.filter.Width = max(10, p.width-10)
		return p, nil
	case tea.KeyMsg:
		p.message = ""
		switch msg.String() {
		case "ctrl+c":
			p.quitting = true
			return p, tea.Quit
		case "esc":
			if p.filter.Value() != "" {
				p.filter.SetValue("")
				p.rebuild()
				return p, nil
			}
			p.quitting = true
			return p, tea.Quit
		case "enter":
			if len(p.selected) == 0 {
				p.message = "Select at least one resource."
				return p, nil
			}
			p.submitted = true
			return p, tea.Quit
		case "up", "down", "ctrl+p", "ctrl+n", "pgup", "pgdown", " ", "tab", "ctrl+a":
			if len(p.visible) == 0 {
				return p, nil
			}
			switch msg.String() {
			case "tab":
				msg = tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{' '}}
			case "pgup":
				msg = tea.KeyMsg{Type: tea.KeyCtrlU}
			case "pgdown":
				msg = tea.KeyMsg{Type: tea.KeyCtrlD}
			}
			_, cmd := p.list.Update(msg)
			for _, t := range p.visible {
				delete(p.selected, t.address)
			}
			for _, address := range p.values {
				p.selected[address] = true
			}
			return p, cmd
		}
	}
	previous := p.filter.Value()
	var cmd tea.Cmd
	p.filter, cmd = p.filter.Update(msg)
	if p.filter.Value() != previous {
		p.rebuild()
	}
	return p, cmd
}

func (p *picker) View() string {
	if p.submitted || p.quitting {
		return ""
	}
	list := p.list.View()
	if len(p.visible) == 0 {
		list = "No matching resources."
	}
	return fmt.Sprintf("Select Terraform targets · %d selected · %d/%d matching\n\n%s\n\n%s\n\n↑/↓ move · space/tab toggle · ctrl+a all matches · enter submit · esc clear/cancel\n%s",
		len(p.selected), len(p.visible), len(p.targets), p.filter.View(), list, p.message)
}

func (p *picker) addresses() []string {
	var addresses []string
	for address := range p.selected {
		addresses = append(addresses, address)
	}
	slices.Sort(addresses)
	return addresses
}
