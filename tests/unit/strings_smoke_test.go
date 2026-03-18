package unit_test

import (
	"testing"

	"github.com/orbiter/orbiter/pkg/util"
)

func TestNormalizeNameSmoke(t *testing.T) {
	got := util.NormalizeName("  Orbiter-API  ")
	if got != "orbiter-api" {
		t.Fatalf("expected normalized name %q, got %q", "orbiter-api", got)
	}
}
