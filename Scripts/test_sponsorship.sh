#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_test() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

print_pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

test_url() {
    local url="$1"
    local description="$2"
    local expected_status="${3:-200}"
    
    print_test
    
    if command -v curl >/dev/null 2>&1; then
        local status_code
        status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null || echo "000")
        
        if [ "$status_code" = "$expected_status" ]; then
            print_pass "$description accessible"
        else
            print_fail "$description returned HTTP $status_code"
        fi
    fi
}

test_file() {
    local file="$1"
    local description="$2"
    
    print_test
    
    if [ -f "$file" ] && [ -s "$file" ]; then
        print_pass "$description exists"
    else
        print_fail "$description missing or empty"
    fi
}

test_readme_sponsorship() {
    print_header "README Sponsorship"
    
    local readme="README.md"
    test_file "$readme" "README.md"
    
    if [ -f "$readme" ]; then
        print_test
        if grep -q "Support This Project" "$readme"; then
            print_pass "Sponsorship section found"
        else
            print_fail "Sponsorship section missing"
        fi
        
        print_test
        if grep -q "github.com/sponsors/ckdash-git" "$readme"; then
            print_pass "GitHub Sponsors link found"
        else
            print_fail "GitHub Sponsors link missing"
        fi
        
        print_test
        if grep -q "buymeacoffee.com/ckdash" "$readme"; then
            print_pass "Buy Me a Coffee link found"
        else
            print_fail "Buy Me a Coffee link missing"
        fi
        
        print_test
        if grep -q "<!-- SPONSORS_START -->" "$readme" && grep -q "<!-- SPONSORS_END -->" "$readme"; then
            print_pass "Sponsor markers found"
        else
            print_fail "Sponsor markers missing"
        fi
    fi
}

test_funding_yml() {
    print_header "FUNDING.yml"
    
    local funding_file=".github/FUNDING.yml"
    test_file "$funding_file" "FUNDING.yml"
    
    if [ -f "$funding_file" ]; then
        print_test
        if grep -q "github:" "$funding_file"; then
            print_pass "GitHub username found"
        else
            print_fail "GitHub username missing"
        fi
        
        print_test
        if grep -q "buy_me_a_coffee:" "$funding_file" || grep -q "buymeacoffee.com" "$funding_file"; then
            print_pass "Buy Me a Coffee found"
        else
            print_fail "Buy Me a Coffee missing"
        fi
    fi
}

test_sponsorship_docs() {
    print_header "Documentation"
    
    test_file "Documentation/Sponsorship.md" "Sponsorship docs"
    test_file "sponsors.json" "Sponsors data"
    test_file "Scripts/update_sponsors.sh" "Update script"
}

test_external_links() {
    print_header "External Links"
    
    print_test
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://github.com/sponsors/ckdash-git" 2>/dev/null || echo "000")
    
    if [ "$status_code" = "200" ] || [ "$status_code" = "302" ]; then
        print_pass "GitHub Sponsors accessible"
    else
        print_fail "GitHub Sponsors returned HTTP $status_code"
    fi
    
    test_url "https://buymeacoffee.com/ckdash" "Buy Me a Coffee" "200"
}

test_sponsor_recognition() {
    print_header "Sponsor System"
    
    if [ -f "sponsors.json" ]; then
        print_test
        if command -v python3 >/dev/null 2>&1; then
            if python3 -c "import json; json.load(open('sponsors.json'))" 2>/dev/null; then
                print_pass "sponsors.json valid"
            else
                print_fail "sponsors.json invalid"
            fi
        fi
    fi
}

run_all_tests() {
    if [ ! -f "ColorsKit.podspec" ]; then
        echo -e "${RED}✗${NC} Run from ColorsKit root directory"
        exit 1
    fi
    
    test_readme_sponsorship
    test_funding_yml
    test_sponsorship_docs
    test_external_links
    test_sponsor_recognition
    
    print_header "Results"
    echo -e "Tests: ${TESTS_TOTAL} | Passed: ${GREEN}${TESTS_PASSED}${NC} | Failed: ${RED}${TESTS_FAILED}${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Sponsorship system ready"
    else
        exit 1
    fi
}

run_all_tests