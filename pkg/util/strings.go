package util

import "strings"

// NormalizeName trims surrounding whitespace and lower-cases a name value.
func NormalizeName(name string) string {
	return strings.ToLower(strings.TrimSpace(name))
}
