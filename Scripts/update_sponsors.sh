#!/bin/bash

set -e

README_FILE="README.md"
SPONSORS_FILE="Documentation/Sponsors.md"
TEMP_FILE=$(mktemp)

# Cleanup trap to remove temp file on exit, error, or interrupt
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

update_readme_sponsors() {
    if [ ! -f "sponsors.json" ]; then
        print_warning "sponsors.json not found. Creating template..."
        cat > sponsors.json << 'EOF'
{
  "sponsors": [
    {
      "name": "Example Sponsor",
      "tier": "Champion",
      "url": "https://github.com/example",
      "avatar": "https://github.com/example.png",
      "since": "2024-01"
    }
  ],
  "total_sponsors": 0,
  "monthly_goal": 500,
  "current_monthly": 0
}
EOF
        print_warning "Please update sponsors.json with actual sponsor data"
        return 1
    fi
    
    python3 -c "
import json
import sys

try:
    with open('sponsors.json', 'r') as f:
        data = json.load(f)
    
    sponsors = data.get('sponsors', [])
    
    if not sponsors:
        print('*Become our first sponsor and see your name here!*')
        sys.exit(0)
    
    tiers = {'Champion': [], 'Advocate': [], 'Supporter': [], 'Coffee': []}
    
    for sponsor in sponsors:
        tier = sponsor.get('tier', 'Coffee')
        if tier in tiers:
            tiers[tier].append(sponsor)
    
    sponsor_html = []
    
    for tier_name, tier_sponsors in tiers.items():
        if tier_sponsors:
            sponsor_html.append(f'### {tier_name} Sponsors')
            sponsor_html.append('')
            
            for sponsor in tier_sponsors:
                name = sponsor.get('name', 'Anonymous')
                url = sponsor.get('url', '#')
                avatar = sponsor.get('avatar', '')
                since = sponsor.get('since', '')
                
                if avatar:
                    sponsor_html.append(f'<a href=\"{url}\"><img src=\"{avatar}\" width=\"60\" height=\"60\" alt=\"{name}\" title=\"{name} (since {since})\"></a>')
                else:
                    sponsor_html.append(f'- [{name}]({url}) (since {since})')
            
            sponsor_html.append('')
    
    print('\\n'.join(sponsor_html))
    
except Exception as e:
    print(f'*Error loading sponsor data: {e}*')
    print('*Become our first sponsor and see your name here!*')
" > "$TEMP_FILE"
    
    if grep -q "<!-- SPONSORS_START -->" "$README_FILE"; then
        awk '
        /<!-- SPONSORS_START -->/ { 
            print $0
            system("cat '"$TEMP_FILE"'")
            skip = 1
            next
        }
        /<!-- SPONSORS_END -->/ {
            skip = 0
        }
        !skip { print }
        ' "$README_FILE" > "${README_FILE}.tmp"
        
        mv "${README_FILE}.tmp" "$README_FILE"
        print_success "README.md sponsors section updated"
    else
        print_error "Sponsor markers not found in README.md"
        return 1
    fi
    
    rm -f "$TEMP_FILE"
}

generate_sponsors_doc() {
    cat > "$SPONSORS_FILE" << 'EOF'
# ColorsKit Sponsors

Thank you to all our amazing sponsors who make ColorsKit development possible!

## Current Sponsors

EOF
    
    if [ -f "sponsors.json" ]; then
        python3 -c "
import json
import datetime

try:
    with open('sponsors.json', 'r') as f:
        data = json.load(f)
    
    sponsors = data.get('sponsors', [])
    total = data.get('total_sponsors', 0)
    goal = data.get('monthly_goal', 500)
    current = data.get('current_monthly', 0)
    
    print(f'**Total Sponsors**: {total}')
    print(f'**Monthly Goal**: \${goal}')
    print(f'**Current Monthly**: \${current}')
    print(f'**Progress**: {int((current/goal)*100) if goal > 0 else 0}%')
    print()
    
    if sponsors:
        tiers = {'Champion': [], 'Advocate': [], 'Supporter': [], 'Coffee': []}
        
        for sponsor in sponsors:
            tier = sponsor.get('tier', 'Coffee')
            if tier in tiers:
                tiers[tier].append(sponsor)
        
        for tier_name, tier_sponsors in tiers.items():
            if tier_sponsors:
                print(f'### {tier_name} Tier')
                print()
                
                for sponsor in tier_sponsors:
                    name = sponsor.get('name', 'Anonymous')
                    url = sponsor.get('url', '#')
                    since = sponsor.get('since', 'Unknown')
                    
                    print(f'- **[{name}]({url})** - Supporting since {since}')
                
                print()
    else:
        print('*No sponsors yet. Be the first to support ColorsKit!*')
        print()
    
except Exception as e:
    print(f'*Error loading sponsor data: {e}*')
" >> "$SPONSORS_FILE"
    fi
    
    cat >> "$SPONSORS_FILE" << 'EOF'

## Become a Sponsor

Support ColorsKit development by becoming a sponsor:

- **[GitHub Sponsors](https://github.com/sponsors/ckdash-git)** - Recurring monthly support with tiered benefits
- **[Buy Me a Coffee](https://buymeacoffee.com/ckdash)** - One-time or recurring donations

## Sponsor Benefits

| Tier | Monthly | Benefits |
|------|---------|----------|
| ☕ **Coffee** | $5 | Sponsor badge, early access to releases |
| 🌟 **Supporter** | $15 | Above + priority issue responses |
| 🚀 **Advocate** | $50 | Above + feature request priority |
| 💎 **Champion** | $100+ | Above + direct consultation access |

## Recognition

Sponsors are recognized in:
- README.md sponsor section
- Release notes and changelogs
- Project documentation
- Social media acknowledgments

---

*Last updated: $(date '+%Y-%m-%d')*
EOF
    
    print_success "Sponsors documentation generated"
}

validate_sponsor_links() {
    if curl -s -o /dev/null -w "%{http_code}" "https://github.com/sponsors/ckdash-git" | grep -q "200"; then
        print_success "GitHub Sponsors link is valid"
    else
        print_warning "GitHub Sponsors link may not be accessible"
    fi
    
    if curl -s -o /dev/null -w "%{http_code}" "https://buymeacoffee.com/ckdash" | grep -q "200"; then
        print_success "Buy Me a Coffee link is valid"
    else
        print_warning "Buy Me a Coffee link may not be accessible"
    fi
}

main() {
    if [ ! -f "ColorsKit.podspec" ]; then
        print_error "Please run this script from the ColorsKit root directory"
        exit 1
    fi
    
    mkdir -p Documentation
    
    update_readme_sponsors || print_warning "README update failed - continuing..."
    generate_sponsors_doc
    validate_sponsor_links
    
    print_success "Sponsor recognition update completed!"
}

main "$@"